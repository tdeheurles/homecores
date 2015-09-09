#! /usr/bin/bash

echo -e "\e[92mJoining Cluster\e[32m"

echo "Get config"
. /home/core/repository/homecores/auto_generated/coreos-config.sh

# prepare json parser
jq=$project_folder/tools/jq
chmod 755 $jq

# add ip to auto_generated
echo "Write auto_generated/ip"
echo "$public_ip" > auto_generated/ip




# =============== CONSUL ================
# =======================================
echo "Prepare Folders"
consul_config_path="/etc/consul.d"
consul_main_dir="/home/core/programs/consul"
consul_data_dir="$consul_main_dir/data-dir"
consul="$consul_main_dir/consul"

# create folders
sudo mkdir -p $consul_data_dir
sudo mkdir -p $consul_config_path
sudo chown core $consul_config_path $consul_main_dir

# clean /tmp
sudo rm -rf /tmp/*

# download, install consul and clean dl files
wget --quiet                                                    \
  https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip \
  -P /tmp
sudo unzip -q -o /tmp/0.5.2_linux_amd64.zip -d /tmp
sudo mv /tmp/consul $consul
sudo rm /tmp/0.5.2_linux_amd64.zip


echo "Add consul to systemd"

cat <<EOF > consul.service
[Unit]
Description=Consul
Documentation=https://www.consul.io/

[Service]
ExecStart=$consul agent            \
  -server                          \
  -data-dir $consul_data_dir       \
  -config-dir $consul_config_path  \
  -bind $public_ip                 \
  -atlas-join                      \
  -atlas=tdeheurles/infrastructure \
  -atlas-token=$atlas_token

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo mv consul.service /etc/systemd/system/consul.service
sudo systemctl enable consul
sudo systemctl start consul

# TODO: find another way to wait for consul to be clustered
echo "    waiting consul to reach cluster"
sleep 15






# ================ ETCD2 ================
# =======================================
echo "Adding etcd"

# need to remove our address
one_etcd_member_ip=`$consul members | grep -v $public_ip | grep alive | head -n 1 | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`
echo "   cluster response at $one_etcd_member_ip"
# hostname=`hostname`

# if one_etcd_member_ip is empty, we need to create a new cluster
# == BOOTSTRAPING
if [[ -z $one_etcd_member_ip ]]; then
  echo "consul cluster is empty, generating new etcd cluster"
  cat <<EOF > etcd2.service
[Unit]
Description=etcd2

[Service]
ExecStart=/usr/bin/etcd2                                              \
    --name                         '$hostname'                        \
    --initial-cluster-state        'new'                              \
    --initial-cluster              '$hostname=http://$public_ip:2380' \
    --initial-advertise-peer-urls  'http://$public_ip:2380'           \
    --listen-peer-urls             'http://$public_ip:2380'           \
    --listen-client-urls           'http://$public_ip:2379,http://127.0.0.1:2379' \
    --advertise-client-urls        'http://$public_ip:2379'
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
else
  # == BOOTSTRAPING
  echo "consul cluster is alive, joining as a proxy"
  etcd_members_json=`curl --silent --max-time 2 $one_etcd_member_ip:2379/v2/members`
  initial_cluster_table=`echo $etcd_members_json | jq '.members[] | "\(.name)=\(.peerURLs[0])"' | sed 's/"//g'`

  echo " -- debug: etcd_members_json:     $etcd_members_json"
  echo " -- debug: initial_cluster_table: $initial_cluster_table"
  echo " -- debug: public_ip:             $public_ip"
  echo " -- debug: one_etcd_member_ip:    $one_etcd_member_ip"

  # create the initial-cluster string
  initial_cluster=""
  while read peer
  do
    $initial_cluster="$initial_cluster,$peer"
  done < $initial_cluster_table

  echo " -- debug: initial_cluster_table:    $initial_cluster_table"

  cat <<EOF > etcd2.service
[Unit]
Description=etcd2

[Service]
ExecStart=/usr/bin/etcd2                            \
    -proxy                   on                     \
    -listen-client-urls      http://127.0.0.1:2379  \
    -initial-cluster         $initial_cluster_table

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
fi

sudo mv etcd2.service /etc/systemd/system/etcd2.service
sudo systemctl enable etcd2
sudo systemctl start etcd2




# =============== FLANNEL ===============
# =======================================
echo "Starting flanneld"
cat <<EOF > flanneld.service
[Service]
Environment=FLANNEL_INTERFACE=$public_ip
EOF

mkdir -p /etc/systemd/system/flanneld.service.d/
sudo mv flanneld.service /etc/systemd/system/flanneld.service.d/10-publicip.conf
sudo systemctl enable flanneld
sudo systemctl start flanneld




# =============== KUBELET ===============
# =======================================
sudo cp $project_folder/templates/units/kubelet.service /etc/systemd/system/kubelet.service
sudo systemctl enable kubelet
sudo systemctl start kubelet




# =============== KUBECTL ===============
# =======================================
sudo cp $project_folder/templates/units/kubectl.target /etc/systemd/system/kubectl.target
sudo systemctl enable kubectl.target
sudo systemctl start kubectl.target



