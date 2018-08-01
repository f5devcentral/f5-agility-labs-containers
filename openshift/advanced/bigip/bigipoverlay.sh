echo Creating overlay self-ip
ssh root@10.10.200.98 tmsh create net self 10.131.0.98/14 vlan ocp-tunnel
ssh root@10.10.200.99 tmsh create net self 10.131.2.99/14 vlan ocp-tunnel

echo Creating floating IP for overlay network
ssh root@10.10.200.98 tmsh create net self 10.131.4.200/14 vlan ocp-tunnel
ssh root@10.10.200.98 tmsh run cm config-sync to-group ocp-devicegroup

echo Saving configuration

ssh root@10.10.200.98 tmsh save sys config
ssh root@10.10.200.99 tmsh save sys config
