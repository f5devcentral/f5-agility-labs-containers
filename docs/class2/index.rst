Lab - Mesos / Marathon
======================

The purpose of this lab is to give you more visibility on

* Overview of Mesos and Marathon and their key components
* Install Mesos and Marathon with 3 masters and 2 agents
* How to launch application from Marathon
* How to install Mesos-DNS for service discovery
* How to setup and install F5 solutions for Mesos / Marathon environment

The F5 Marathon Container Integration consists of the F5 Marathon BIG-IP Controller, the F5 Application Service Proxy (ASP), and the F5 Marathon ASP Controller.

The F5 Marathon BIG-IP Controller configures a BIG-IP to expose applications in a Mesos cluster as BIG-IP virtual servers, serving North-South traffic.

The F5 Application Service Proxy provides load balancing and telemetry for containerized applications, serving East-West traffic. The F5 Marathon ASP Controller deploys ASP instances ‘on-demand’ for Marathon Applications.

The official F5 documentation is available here: `F5 Marathon Container Integration <http://clouddocs.f5.com/containers/v1/marathon/>`_

You can either setup the whole F5 solutions yourself or use some scripts to automatically deploy everything

We also provide some ansible playbooks if you need to setup a Mesos/Marathon env.


Contents:


.. toctree::
   :maxdepth: 2
   :caption: Getting Started

   getting-started/mesos-introduction.rst

.. toctree::
   :maxdepth: 2
   :caption: Your lab

   your-lab/lab-setup.rst
   your-lab/access-lab.rst

.. toctree::
   :maxdepth: 2
   :caption: F5 Container connector

   f5-container-connector/f5-container-connector-overview.rst
   f5-container-connector/f5-container-connector-installation.rst
   f5-container-connector/f5-container-connector-usage.rst

.. toctree::
   :maxdepth: 2
   :caption: F5 ASP and ASP Controller

   f5-asp-and-controller/f5-asp-and-controller-overview.rst
   f5-asp-and-controller/f5-asp-and-controller-installation.rst
   f5-asp-and-controller/f5-asp-and-controller-usage.rst
   f5-asp-and-controller/f5-asp-and-controller-asp-review.rst
   f5-asp-and-controller/f5-asp-and-controller-final.rst

.. toctree::
   :maxdepth: 2
   :caption: Setup the masters

   setup-masters/install-mesos-marathon.rst
   setup-masters/setup-zookeeper-master.rst
   setup-masters/setup-mesos-master.rst
   setup-masters/setup-marathon.rst
   setup-masters/start-services-master.rst

.. toctree::
   :maxdepth: 2
   :caption: Setup the agents

   setup-agents/install-mesos-agent.rst
   setup-agents/setup-zookeeper-agent.rst
   setup-agents/setup-mesos-agent.rst
   setup-agents/start-services-agent.rst
   setup-agents/test-setup.rst

.. toctree::
   :maxdepth: 2
   :caption: Setup Mesos DNS

   setup-mesos-dns/setup-mesos-dns.rst
   setup-mesos-dns/test-mesos-dns.rst

