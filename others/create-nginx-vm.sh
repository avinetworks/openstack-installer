set -e
set -x

# needed to create with admin login as Ocata policies don't allow users to create ports with specific IP addresses
source /root/files/admin-openrc.sh
#source /root/files/demo-openrc.sh
export OS_PROJECT_NAME=demo

# create client in vip ipv4 and vip6 network
netid=`neutron net-show vip4 -c 'id' --format 'value'`
net6id=`neutron net-show vip6 -c 'id' --format 'value'`
net2id=`neutron net-show vip42 -c 'id' --format 'value'`
openstack server create --flavor m1.se \
    --image trusty \
    --user-data ./cloud-init-client.sh \
    --config-drive True \
    --nic net-id=$netid,v4-fixed-ip=10.0.2.20 \
    --nic net-id=$net6id,v6-fixed-ip='a100::20' \
    --nic net-id=$net2id,v4-fixed-ip=192.168.2.12 \
    client1

sleep 5

# Wait/Check for Client VM
count=0
cnt=0
while :
do
    status=`openstack server show client1 | grep status | awk '{print $4}'`
    if [[ "$status" == "ACTIVE" ]];
    then
        echo "Client VM ACTIVE"
        break
    elif [[ "$status" == "ERROR" ]];
    then
        if [[ $count -lt 3 ]];
        then
            echo "Deleting the client vm in error state ..."
            openstack server delete client1
            s=`openstack server list | grep client1`
            while [[ ! -z "$s" ]];
            do
                sleep 5
                s=`openstack server list | grep client1`
            done
            echo "Client VM deleted"
            sleep 5
            openstack server create --flavor m1.se \
                --image trusty \
                --user-data ./cloud-init-client.sh \
                --config-drive True \
                --nic net-id=$netid,v4-fixed-ip=10.0.2.20 \
                --nic net-id=$net6id,v6-fixed-ip='a100::20' \
                --nic net-id=$net2id,v4-fixed-ip=192.168.2.12 \
                client1
            sleep 5
            count=$((count+1))
        else
            echo "Exiting as Client VM in ERROR state"
            exit 1
        fi
    elif [[ $cnt -lt 60 ]];
    then
        echo "Waiting for Client VM to be ACTIVE"
        sleep 5
        cnt=$((cnt+1))
    else
        echo "Exiting as Client VM didn't come up"
        exit 1
    fi
done

# create server in data IPv4 and data IPv6 network
netid=`neutron net-show data4 -c 'id' --format 'value'`
net6id=`neutron net-show data6 -c 'id' --format 'value'`
openstack server create --flavor m1.se \
    --image trusty \
    --user-data ./cloud-init-server.sh \
    --config-drive True \
    --nic net-id=$netid,v4-fixed-ip=10.0.3.10 \
    --nic net-id=$net6id,v6-fixed-ip='b100::10' \
    server1

sleep 5

# Wait/Check for Server VM
count=0
cnt=0
while :
do
    status=`openstack server show server1 | grep status | awk '{print $4}'`
    if [[ "$status" == "ACTIVE" ]];
    then
        echo "Server VM ACTIVE"
        break
    elif [[ "$status" == "ERROR" ]];
    then
        if [[ $count -lt 3 ]];
        then
            echo "Deleting the server vm in error state ..."
            openstack server delete server1
            s=`openstack server list | grep server1`
            while [[ ! -z "$s" ]];
            do
                sleep 5
                s=`openstack server list | grep server1`
            done
            echo "Server VM deleted"
            sleep 5
            openstack server create --flavor m1.se \
                --image trusty \
                --user-data ./cloud-init-server.sh \
                --config-drive True \
                --nic net-id=$netid,v4-fixed-ip=10.0.3.10 \
                --nic net-id=$net6id,v6-fixed-ip='b100::10' \
                server1
            sleep 5
            count=$((count+1))
        else
            echo "Exiting as Server VM in ERROR state"
            exit 1
        fi
    elif [[ $cnt -lt 60 ]];
    then
        echo "Waiting for Server VM to be ACTIVE"
        sleep 5
        cnt=$((cnt+1))
    else
        echo "Exiting as Server VM didn't come up"
        exit 1
    fi
done

openstack server list
