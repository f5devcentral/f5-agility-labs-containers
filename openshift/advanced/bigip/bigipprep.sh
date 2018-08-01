echo Creating OCP Partition
ssh root@10.10.200.98 tmsh create auth partition ocp
ssh root@10.10.200.99 tmsh create auth partition ocp

echo Creating ocp-profile
ssh root@10.10.200.98 tmsh create net tunnels vxlan ocp-profile flooding-type multipoint
ssh root@10.10.200.99 tmsh create net tunnels vxlan ocp-profile flooding-type multipoint

echo Creating floating IP for underlay network
ssh root@10.10.200.98 tmsh create net self 10.10.199.200/24 vlan internal traffic-group traffic-group-1
ssh root@10.10.200.98 tmsh run cm config-sync to-group ocp-devicegroup

echo Creating vxlan tunnel ocp-tunnel
ssh root@10.10.200.98 tmsh create net tunnels tunnel ocp-tunnel key 0 profile ocp-profile local-address 10.10.199.200 secondary-address  10.10.199.98 traffic-group traffic-group-1
ssh root@10.10.200.99 tmsh create net tunnels tunnel ocp-tunnel key 0 profile ocp-profile local-address 10.10.199.200 secondary-address  10.10.199.99 traffic-group traffic-group-1

echo Saving configuration
ssh root@10.10.200.98 tmsh save sys config
ssh root@10.10.200.99 tmsh save sys config
