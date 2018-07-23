Lab 1.2 - F5 Container Connector Usage
======================================

App Deployment
--------------

#. Create the file called f5-vs2.yaml

    .. note:: This has the Virtual IP/port/LB method, health monitor, could have an APM policy or iRule for instance.

    .. tip:: Use the file in /root/f5-vs2.yaml You can ''cat f5-vs2.yaml'' or just review the config below.


    .. literalinclude:: ../../../openshift/f5-vs2.yaml
        :language: yaml
        :linenos:
        :emphasize-lines: 2,14,31,33

#. Last step: enter the command below to Launch this virtual server on the BIG-IP and create and populate a pool for the virtual server (VIP)

    .. code-block:: console

        oc create -f f5-vs2.yaml

#. Jump back over to the BIG-IP and look at the Virtual Server and Pool **Don't forget to be in the "ose" Partition**
