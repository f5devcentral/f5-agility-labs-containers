Lab 1.1 - Install OpenShift
===========================

Via RDP connect to the UDF lab "jumpbox" host.

.. note:: Username and password are: **ubuntu/ubuntu**

#. On the jumphost open a terminal and start an SSH session with kube-master1.

   .. image:: images/start-term.png

#. "git" the OKD Installer and Client tools

   .. note:: These files are preinstalled on the Jumpbox image. If files are
      missing use the following instructions.

   a. Download the linux client tools
 
      `Client tools for OpenShift <https://github.com/openshift/okd/releases/tag/4.7.0-0.okd-2021-09-19-013247>`_
 
   #. Untar both files
 
      .. code-block:: bash
 
         tar -xzvf openshift-client-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz
         tar -zxvf openshift-install-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz
 
   #. Move "oc" & "kubectl" to "/usr/local/bin"
 
      .. code-block:: bash
 
         sudo mv oc /usr/local/bin
         suod mv kubectl /usr/local/bin
   
   #. Move "openshift-install" to user home directory
 
      .. code-block:: bash
 
         mv openshift-install ~

#. "git" the demo files

   .. note:: These files should be here by default, if **NOT** run the
      following commands.

   .. code-block:: bash

      git clone -b develop https://github.com/f5devcentral/f5-agility-labs-containers.git ~/agilitydocs

#. Go to the Terraform deployment directory

   .. code-block:: bash

      cd ~/agilitydocs/terraform

#. Create openshift ignition config

   .. important:: This config is specific to the F5 UDF environment.

   .. code-block:: bash

      ./scripts/deploy_okd.sh

#. Export KUBECONFIG for cluster access

   .. code-block:: bash
      
      export KUBECONFIG=$PWD/ignition/auth/kubeconfig

#. Prep terraform (Run each command one by one)

   .. important:: If any errors are returned from the following commands, be
      sure to report them to the lab team.

   .. code-block:: bash

      terraform init --upgrade
      terraform validate
      terraform plan

#. Deploy cluster

   .. attention:: Due to the nature of UDF this process can sometimes errors
      out and fail. Simply rerun the command until the process finishes.

   .. code-block:: bash

      terraform apply -auto-approve

#. Update local hosts file with openshift api info

   .. important:: This script finds the external LB's public IP and adds an
      entry to /etc/hosts. This is required to find and connect to the newly
      created cluster from the jumpbox.

   .. code-block:: bash

      ./scripts/update_hosts.sh

#. Once terraform successfully creates all the openshift objects, monitor the
   process for active control nodes

   .. note:: Run this command several times until all nodes show active.

   .. code-block:: bash

      oc get nodes

#. Once the control nodes go active we need to approve the worker nodes CSR's

   View all CSR's

   .. code-block:: bash

      oc get csr

   Approve pending CSR's

   .. note:: This command will need to be run twice. Run "oc get csr" between
      attemtps to see the approved and newly created pending csr's.

   .. code-block:: bash

      oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs --no-run-if-empty oc adm certificate approve 

#. Watch for cluster operators to deploy

   .. note:: This process can take up to 30 minutes

   .. code-block:: bash
      
      watch -n3 oc get co

#. Connect to the openshift web console

   https://console-openshift-console.apps.okd4.agility.lab

   .. hint:: To find the console password

      .. code-block:: bash

         cat ~/agilitydocs/terraform/ignition/auth/kubeadmin-password

   username = kubeadmin
   
   password = `see hint above`

   .. hint:: The console will not be available until the "console" operator
      finishes deploying.

