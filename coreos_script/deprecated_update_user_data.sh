#! /bin/bash

echo " "
echo " "
echo "Auto-configuration"

. ./auto_generated/coreos-config.sh


# json parser
jq=$project_folder/tools/jq
chmod 755 $jq

echo -e "Searching for existing etcd cluster"
# this command will run a broadcast to find an etcd cluster
# it runs in ~25"
time=1

for i in $(seq 255)
do
    curl --silent --max-time $time $network_mask.$i:2379/v2/members > /tmp/$i &
done

sleep $(($time+2))

for i in $(seq 255)
do
    read=`cat /tmp/$i`
    if [[ -n $read ]]; then
    	echo $read > $project_folder/auto_generated/result
    	echo $i > $project_folder/auto_generated/ip
      echo "Found etcd member at $network_mask.$i"
    fi
    rm -f /tmp/$i
done

echo "Request for joining cluster"
etcd_leader_name=`cat $project_folder/auto_generated/result | $jq '.members[0].name'  | sed "s/\"//g"`
etcd_leader_client_url=`cat $project_folder/auto_generated/result | $jq '.members[0].clientURLs[0]'  | sed "s/\"//g"`
etcd_leader_peer_url=`cat $project_folder/auto_generated/result | $jq '.members[0].peerURLs[0]'  | sed "s/\"//g"`

#curl_content="Content-Type: application/json"
curl_json_value="{\"peerURLs\":[\"http://$public_ip:2380\"]}"
curl                                  \
  --silent                            \
  $etcd_leader_client_url/v2/members  \
  -XPOST                              \
  -H "Content-Type: application/json" \
  -d $curl_json_value                 \
  > $project_folder/auto_generated/addmember_response

# TODO: Add here code for no cluster found => starting one and becoming leader
# the cloud-config.etcd2 for that :
# name:                        __HOSTNAME__
# initial-cluster-state:       'new'
# initial-cluster:             '__HOSTNAME__=http://__PUBLIC_IP__:2380'
# initial-advertise-peer-urls: http://__PUBLIC_IP__:2380
# listen-peer-urls:            http://__PUBLIC_IP__:2380
# listen-client-urls:          http://__PUBLIC_IP__:2379, http://127.0.0.1:2379

# actual cloud-config :
# name:                         __HOSTNAME__
# initial-cluster-state:        'existing'
# initial-cluster:              '__ETCD_LEAD_NAME__=__ETCD_LEAD_PEER__,__HOSTNAME__=http://__IP_PUBLIC__:2380'
# initial-advertise-peer-urls:  http://__IP_PUBLIC__:2380
# listen-peer-urls:             http://__IP_PUBLIC__:2380
# listen-client-urls:           http://__IP_PUBLIC__:2379,http://127.0.0.1:2379
# advertise-client-urls:        http://__IP_PUBLIC__:2379

echo "Generating cloud-config for $public_ip"

cp $cloud_config_template_file $cloud_config_file
echo $public_ip > $project_folder/auto_generated/coreos_address

#id=`cat $project_folder/auto_generated/addmember_response | $jq '.id' | sed "s/\"//g"`

sed "s|__PASSWORD__|$password|g"                   $cloud_config_file > $cloud_config_file
sed "s|__ID_RSA__|$id_rsa|g"                       $cloud_config_file > $cloud_config_file
sed "s|__HOSTNAME__|$coreos_hostname|g"            $cloud_config_file > $cloud_config_file
sed "s|__DISCOVERY_TOKEN__|$discovery_token|g"     $cloud_config_file > $cloud_config_file
sed "s|__IMAGE_KUBERNETES__|$image_kubernetes|g"   $cloud_config_file > $cloud_config_file
sed "s|__IP_PUBLIC__|$public_ip|g"                 $cloud_config_file > $cloud_config_file
sed "s|__ETCD_LEAD_NAME__|$etcd_leader_name|g"     $cloud_config_file > $cloud_config_file
sed "s|__ETCD_LEAD_PEER__|$etcd_leader_peer_url|g" $cloud_config_file > $cloud_config_file

echo " "
echo -e "\e[94mwill restart ... a moment please\e[39m"
echo " "
coreos-cloudinit -validate=true --from-file $cloud_config_file && sudo cp $cloud_config_file $user_data_file && sudo reboot
