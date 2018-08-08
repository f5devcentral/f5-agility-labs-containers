Module 1: Introduction to Docker
================================

Introduction to Docker
----------------------

Docker and containers have been a growing buzzword in recent years.  As companies started asking for integration with F5, F5 PD resources have been building BIG-IP integration with a BIG-IP controller (more later in the labs) with a container.  Via some configs.yaml files (more later in the labs), you can automate F5 into dynamic services being deployed within your organization as well for both on-prem and cloud locations.

To the question what Docker is, and for you reading that haven’t researched what Docker is, Docker is a company that figured out to simplify some old linux services into an extremely easy and quick way to deploy smaller images than entire guest images as we have been doing for the past 10-15 years on hypervisor systems.

Let us step back for a moment and look at the context of technologies as they apply to I.T. history.  While some products only last moments, others seem to endure forever (COBOL for example – there are companies still using it today).  Some of you reading this will be new to the world of IT, while others have seen the progression from mainframes, mini, physical servers, Hypervisors, and as of late docker/containers/microservices, and serverless.  Docker is one of companies’ technology that might not be the end state of IT, but just like COBOL, this docker technology has the power stay around for a very long time.  In much of the same way that VMWare and other hypervisors over the past dozen or so years have transformed most businesses physical servers into a world of virtual servers saving cost, floor space, enabling easier management, ability to support snapshots and many other technologies only dreamed of decades ago.

In a way, containers are doing what hypervisors did to physical servers.  Docker essential development deploying containers via a simplification of old features of Unix (going back to Sun Solaris or FreeBSD from early 2000’s with zones and jail to separate users, file system views, and processes).   By delivering this in a container to run specific code i.e. Tomcat, PHP, or WordPress for example.  As containers removes the need to support the Guest OS, this has immediate benefits: running a single file/container with all the software/code embedded within that “image”.  Containers are typically much smaller, faster, and easier to swap in/out as needed with code upgrades.  A decent laptop can spin up a dozen TomCat Apache servers in about a second with embedded HTML code for your site, or within a few seconds have pulled down new html code.  Lastly, one can update the container image with new HTML code, save the new container.  All while saving over a traditional OS and Tomcat install anywhere from 5X to 25X(or more) less memory and disk requirements.

For today labs at Agility, all these labs will run in the cloud, due to the number of guests needed to host a few different management platforms for containers (RedHat Openshift, Kubernetes (K8s), and Mesos/Marathon).  Next page we will install Docker and run a small container for a “hello world”.

Side note for your own work after today: Windows versus Linux
You are in luck (mostly), containers are cross platform or “agnostic” of OS that containers run on. If you decide to install Docker on Linux on your own (as in next page) you install only the Docker Engine and management tools. You don’t need to create a virtual machine or virtual networks, because Docker via it’s containers will handle the setup for you.

For Windows:  having another hypervisor can cause conflicts.  During Docker installation, Docker creates a Linux-based virtual machine called MobyLinuxVM.  The Docker application connects to this machine, so that you can create your container with the necessary apparatus for operation. This installation also configures a subnet for the virtual machine to communicate with the local network / NAT for your containers to use in the application. All of these steps occur behind the scenes and, as the user, you don’t really have to worry about them. Still, the fact that Docker on Windows runs a virtual machine in the background is a major difference between Docker on Windows and Docker on Linux.

.. tip:: For more information please come back and visit any of these links below:

    https://www.docker.com

    https://www.infoworld.com/article/3204171/linux/what-is-docker-linux-containers-explained.html

    https://www.zdnet.com/article/what-is-docker-and-why-is-it-so-darn-popular/

Next, we're going to install Docker and learn some of the basic commands.  We'll do this on a few Ubuntu servers (Kubernetes VM's in the lab).

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
