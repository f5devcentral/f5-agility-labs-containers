Lab 1.2 - OpenShift POD 1 & 2 Configuration
===========================================

VXLAN Config
----------------------------

#. Create new OpenShift HostSubnet's for bigip 1 & 2 on **POD1**.

   hs-bigip1-10.yaml

   .. literalinclude:: ../../../openshift/advanced/appendix1/hs-bigip1-10.yaml
      :language: yaml
      :emphasize-lines: 4,8,9

   hs-bigip2-10.yaml

   .. literalinclude:: ../../../openshift/advanced/appendix1/hs-bigip2-10.yaml
      :language: yaml
      :emphasize-lines: 4,8,9

   hs-bigip-float-10.yaml

   .. literalinclude:: ../../../openshift/advanced/appendix1/hs-bigip-float-10.yaml
      :language: yaml
      :emphasize-lines: 4,8,9

   Create the HostSubnet files to the OpenShift API server. Run the following
   commands from **master1**

   .. code-block:: bash

      oc create -f hs-bigip1-10.yaml
      oc create -f hs-bigip2-10.yaml
      oc create -f hs-bigip-float-10.yaml

#. Create new OpenShift HostSubnet's for bigip 1 & 2 on **POD2**.

   hs-bigip1-20.yaml

   .. literalinclude:: ../../../openshift/advanced/appendix1/hs-bigip1-20.yaml
      :language: yaml
      :emphasize-lines: 4,8,9

   hs-bigip2-20.yaml

   .. literalinclude:: ../../../openshift/advanced/appendix1/hs-bigip2-20.yaml
      :language: yaml
      :emphasize-lines: 4,8,9

   hs-bigip-float-20.yaml

   .. literalinclude:: ../../../openshift/advanced/appendix1/hs-bigip-float-20.yaml
      :language: yaml
      :emphasize-lines: 4,8,9

   Create the HostSubnet files to the OpenShift API server. Run the following
   commands from **master2**

   .. code-block:: bash

      oc create -f hs-bigip1-20.yaml
      oc create -f hs-bigip2-20.yaml
      oc create -f hs-bigip-float-20.yaml
