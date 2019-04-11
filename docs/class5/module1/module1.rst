Module 1: Working with BIG-IP HA Pairs or Device Groups
=======================================================

Each Container Connector is uniquely suited to its specific container
orchestration environment and purpose, utilizing the architecture and language
appropriate for the environment. Application Developers interact with the
platform’s API; the CCs watch the API for certain events, then act accordingly.

The Container Connector is stateless (Stateless means there is no record of
previous interactions and each interaction request has to be handled based
entirely on information that comes with it). The inputs are:

* the container orchestration environment’s config
* the BIG-IP device config
* the CC config (provided via the appropriate means from the container
  orchestration environment).

.. image:: images/ha-cluster.jpg

Wherever a Container Connector runs, it always watches the API and attempts to
bring the BIG-IP up-to-date with the latest applicable configurations.

You can use the F5 Container Connectors (also called F5 BIG-IP Controller) to
manage a BIG-IP HA active-standby pair or device group. The deployment details
vary depending on the platform. For most, the basic principle is the same: You
should run one BIG-IP Controller instance for each BIG-IP device. You will
deploy two BIG-IP Controller instances - one for each BIG-IP device. To help
ensure Controller HA, you will deploy each Controller instance on a separate
Node in the cluster.

.. warning:: If Class 4 was previously attempted be sure to remove the
   objects created before attempting this lab. See
   `Class 4 / Module 2 / Lab 2.2 - F5 Container Connector Usage <../../class4/module2/lab2.html>`_
   and scroll down to bottom of the page for instructions.

.. toctree::
   :maxdepth: 1
   :glob:
   
   lab*
