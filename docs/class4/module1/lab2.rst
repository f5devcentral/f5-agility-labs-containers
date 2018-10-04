Lab 1.2 - Install Openshift
===========================

.. important:: The following commands need to be run on the **master** only,
   unless otherwise specified.

#. Install Ansible

   .. code-block:: bash

      sudo yum install -y epel-release
      sudo yum install -y ansible

#. Prep openshift AUTH

   .. code-block:: bash

      sudo mkdir -p /etc/origin/master/
      sudo touch /etc/origin/master/htpasswd

#. Clone the openshift-ansible repo

   .. code-block:: bash

      git clone -b release-3.10 https://github.com/openshift/openshift-ansible.git $HOME/openshift-ansible

#. Install Openshift with Ansible

   .. code-block:: bash

      ansible-playbook -i $HOME/agilitydocs/openshift/ansible/inventory.ini $HOME/openshift-ansible/playbooks/prerequisites.yml
      ansible-playbook -i $HOME/agilitydocs/openshift/ansible/inventory.ini $HOME/openshift-ansible/playbooks/deploy_cluster.yml

   Here's the "inventory" (refrenced by our ansible playbook) used for the
   deployment.

   .. literalinclude:: ../../../openshift/ansible/inventory.ini
      :language: bash

#. Enable oc bash completion

   .. code-block:: bash
      
      oc completion bash >>/etc/bash_completion.d/oc_completion

#. Add user "centos" to openshift users

   .. code-block:: bash

      sudo htpasswd -b /etc/origin/master/htpasswd centos centos

#. Add user "centos" to "cluster-admin"

   .. code-block:: bash

      oc adm policy add-cluster-role-to-user cluster-admin centos
