#! /usr/bin/bash

echo -e "\e[92mStart Services\e[32m"
echo "Get config"
. /home/core/repository/homecores/auto_generated/coreos-config.sh


# prepare json parser
jq=$project_folder/tools/jq
chmod 755 $jq

# add ip to auto_generated
echo "$public_ip" > auto_generated/ip





# =============== CONSUL ================
# =======================================
echo "Prepare Folders"
consul_config_path="/etc/consul.d"
consul_main_dir="/home/core/programs/consul"
consul_data_dir="$consul_main_dir/data-dir"
consul="$consul_main_dir/consul"

sudo mkdir -p $consul_data_dir
sudo mkdir -p $consul_config_path
sudo chown core $consul_config_path $consul_main_dir

sudo rm -rf /tmp/*
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

# find another way to wait for consul to be clustered
sleep 5






# ================ ETCD2 ================
# =======================================
echo "Adding etcd"

# need to remove our address
one_etcd_member_ip=`consul members | grep -v $public_ip | grep alive | head -n 1 | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`
hostname=`hostname`

# if one_etcd_member_ip is empty, we need to create a new cluster
# == BOOTSTRAPING
if [[ -z $one_etcd_member_ip ]]; then
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
  # the cluster is alive, let's try to join it
  # == BOOTSTRAPING
  etcd_members_json=`curl --silent --max-time 2 $one_etcd_member_ip:2379/v2/members`
  initial_cluster_table=`echo $etcd_members_json | jq '.members[] | "\(.name)=\(.peerURLs[0])"' | sed 's/"//g'`


  echo "ask for joining cluster"
  curl_json_value="{\"peerURLs\":[\"http://$public_ip:2380\"]}"
  curl                                  \
    --silent                            \
    $one_etcd_member_ip/v2/members      \
    -XPOST                              \
    -H "Content-Type: application/json" \
    -d $curl_json_value                 \
    > $project_folder/auto_generated/addmember_response

  # create the initial-cluster string
  initial_cluster=""
  while read peer
  do
    $initial_cluster="$initial_cluster,$peer"
  done < $initial_cluster_table

  cat <<EOF > etcd2.service
[Unit]
Description=etcd2

[Service]
ExecStart=/usr/bin/etcd2                                                          \
    --name                         '$hostname'                                    \ 
    --initial-cluster-state        'existing'                                     \
    --initial-advertise-peer-urls  'http://$public_ip:2380'                       \
    --listen-peer-urls             'http://$public_ip:2380'                       \
    --listen-client-urls           'http://$public_ip:2379,http://127.0.0.1:2379' \
    --advertise-client-urls        'http://$public_ip:2379'                       \
    --initial-cluster              '$etcd_leader_name=$etcd_leader_peer_url,$hostname=http://$public_ip:2380'

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
fi

sudo mv etcd2.service /etc/systemd/system/etcd2.service
sudo systemctl enable etcd2
sudo systemctl start etcd2




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



