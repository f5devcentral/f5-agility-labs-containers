Lab Setup
~~~~~~~~~

Welcome to the Advanced Labs for Red Hat OpenShift Container Platform (OCP)

In the environment, there is a three-node OpenShift cluster with one master and two nodes. There is a pair of BIG-IPs setup in an HA configuration:

==================   ==================  =============================
   Hostname             Mgt IP            Login / Password
==================   ==================  =============================
   ose-master           10.10.199.100       ssh: root/default
   ose-node01           10.10.199.101       ssh: root/default
   ose-node02           10.10.199.102       ssh: root/default
 Windows Jumpbox        10.10.200.199       student/Student!Agility!
    BIG-IP              10.10.200.98        GUI: admin/admin
    BIG-IP              10.10.200.98        ssh: root/admin
==================   ==================  =============================