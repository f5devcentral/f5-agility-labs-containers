Lab 1.2 - Install Openshift
===========================

.. important:: The following commands need to be run on the **master** only,
   unless otherwise specified.

#. Install Ansible

   .. code-block:: bash

      sudo yum install -y epel-release
      sudo yum install -y ansible

#. Disable "epel-release"

   .. code-block:: bash

      sudo vim /etc/yum.repos.d/epel.repo

      # Change the value enabled=1 to 0 (zero).

   .. note:: This is done to prevent future OS updates from including packages
      from outside the standard packages.

#. Prep openshift AUTH

   .. code-block:: bash

      sudo mkdir -p /etc/origin/master/
      sudo touch /etc/origin/master/htpasswd

#. Clone the openshift-ansible repo

   .. code-block:: bash

      git clone -b release-3.11 https://github.com/openshift/openshift-ansible.git $HOME/openshift-ansible

#. Install Openshift with Ansible

   .. code-block:: bash

      ansible-playbook -i $HOME/agilitydocs/openshift/ansible/inventory.ini $HOME/openshift-ansible/playbooks/prerequisites.yml
      ansible-playbook -i $HOME/agilitydocs/openshift/ansible/inventory.ini $HOME/openshift-ansible/playbooks/deploy_cluster.yml

   .. tip:: For troubleshooting you can validate system variables with the
      following command:

      .. code-block:: bash

         ansible-playbook -i $HOME/agilitydocs/openshift/ansible/inventory.ini $HOME/openshift-ansible/playbooks/byo/openshift_facts.yml

   .. tip:: If needed, to uninstall Openshift run the following command:

      .. code-block:: bash

         ansible-playbook -i $HOME/agilitydocs/openshift/ansible/inventory.ini $HOME/openshift-ansible/playbooks/adhoc/uninstall.yml

   Here's the "inventory" (refrenced by our ansible playbook) used for the
   deployment.

   .. code-block:: yaml

      [OSEv3:children]
      masters
      nodes
      etcd

      [masters]
      ose-master1

      [etcd]
      ose-master1

      [nodes]
      ose-master1 openshift_public_hostname=ose-master1 openshift_schedulable=true openshift_node_group_name="node-config-master-infra"
      ose-node1 openshift_public_hostname=ose-node1 openshift_schedulable=true openshift_node_group_name="node-config-compute"
      ose-node2 openshift_public_hostname=ose-node2 openshift_schedulable=true openshift_node_group_name="node-config-compute"

      [OSEv3:vars]
      ansible_ssh_user=centos
      ansible_become=true
      enable_excluders=false
      enable_docker_excluder=false
      ansible_service_broker_install=false

      containerized=true
      openshift_disable_check=disk_availability,memory_availability,docker_storage,docker_image_availability

      deployment_type=origin
      openshift_deployment_type=origin

      openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]

      openshift_master_api_port=8443
      openshift_master_console_port=8443

      openshift_metrics_install_metrics=false
      openshift_logging_install_logging=false

#. Enable oc bash completion

   .. code-block:: bash
      
      oc completion bash >>/etc/bash_completion.d/oc_completion

#. Add user "centos" to openshift users

   .. code-block:: bash

      sudo htpasswd -b /etc/origin/master/htpasswd centos centos

#. Add user "centos" to "cluster-admin"

   .. code-block:: bash

      oc adm policy add-cluster-role-to-user cluster-admin centos
