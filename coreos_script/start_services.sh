#! /bin/bash

echo -e "\e[92mStart Services\e[32m"
echo "Get config"
. /home/core/repository/homecores/auto_generated/coreos-config.sh


# prepare json parser
jq=$project_folder/tools/jq
chmod 755 $jq

# add ip to auto_generated
echo "$public_ip" > auto_generated/ip


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


# =============== CONSUL ================
# =======================================
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

echo -e "\e[94mfind a way to wait for consul to be clustered\e[32m"




# ================ ETCD2 ================
# =======================================
echo "Adding etcd"

# TODO: get this parameters from consul
etcd_lead_name="bm0-coreos"
etcd_lead_peer="http://192.168.1.13"
hostname=`hostname`

etcd_members=`curl --silent --max-time 1 192.168.1.13:2379/v2/members`
etcd_leader_name=`echo $etcd_members       | $jq '.members[0].name'          | sed "s/\"//g"`
etcd_leader_client_url=`echo $etcd_members | $jq '.members[0].clientURLs[0]' | sed "s/\"//g"`
etcd_leader_peer_url=`echo $etcd_members   | $jq '.members[0].peerURLs[0]'   | sed "s/\"//g"`

echo "ask for joining cluster"
curl_json_value="{\"peerURLs\":[\"http://$public_ip:2380\"]}"
curl                                  \
  --silent                            \
  $etcd_leader_client_url/v2/members  \
  -XPOST                              \
  -H "Content-Type: application/json" \
  -d $curl_json_value                 \
  > $project_folder/auto_generated/addmember_response


cat <<EOF > etcd2.service
[Unit]
Description=etcd2

[Service]
ExecStart=/usr/bin/etcd2 \
    -name:                         '$hostname'    \
    -initial-cluster-state:        'existing'   \
    -initial-cluster:              '$etcd_leader_name=$etcd_leader_peer_url,$hostname=http://$public_ip:2380' \
    -initial-advertise-peer-urls:  'http://$public_ip:2380' \
    -listen-peer-urls:             'http://$public_ip:2380' \
    -listen-client-urls:           'http://$public_ip:2379,http://127.0.0.1:2379' \
    -advertise-client-urls:        'http://$public_ip:2379'

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo mv etcd2.service /etc/systemd/system/etcd2.service
sudo systemctl enable etcd2
sudo systemctl start etcd2
