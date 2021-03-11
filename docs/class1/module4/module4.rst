Module 4: Using F5 IngressLink
==============================

The F5 IngressLink is addressing modern app delivery at scale/large.
IngressLink is a resource definition defined between BIG-IP and Nginx using F5
Container Ingress Service and Nginx Ingress Service. The purpose of this lab is
to demonstrates the configuration and steps required to Configure IngressLink.

F5 IngressLink is the first true integration between BIG-IP and NGINX
technologies. F5 IngressLink was built to support customers with modern,
container application workloads that use both BIG-IP Container Ingress Services
and NGINX Ingress Controller for Kubernetes. It’s an elegant control plane
solution that offers a unified method of working with both technologies from a
single interface—offering the best of BIG-IP and NGINX and fostering better
collaboration across NetOps and DevOps teams.

This architecture diagram demonstrates the IngressLink solution

.. image:: ../images/ingresslink-architecture-diagram.png

.. important:: This module and following labs assume Module2/Lab1 &
   Module3/Lab1 were atempted and working without issue. This module reuses the
   deployed objects. If you haven't done so be sure to attempt these labs now.
   You can review the content here:

   `Lab 2.1 - Install & Configure CIS in ClusterIP Mode <../module2/lab1.html>`_

   `Lab 3.1 - Deploy the NGINX Ingress Controller <../module3/lab1.html>`_

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
