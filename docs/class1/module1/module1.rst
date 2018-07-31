Module 1: Introduction to Docker
================================

Introduction to Docker
----------------------

Docker, Docker, Docker.  It has been a buzzword in recent years, with a steady uptick in use, as companies started asking for integration with F5 in 2017, F5 assign PD resources to build the integration via .yaml (more later) and a BIG-IP service (more later) that runs within Docker to automate F5 into the process. (Example: release notes for Kubernetes/F5)

To the question what Docker is, and for you reading that haven’t researched what Docker is. let us step back for a moment and look at the context of technologies as they apply to I.T. and history.  While some products only last moments, others seem to endure forever (COBOL for example - I still know of customers using it today).  Some of you reading this will be new to the world of IT, while others have seen the progression from mainframes, mini, physical servers, Hypervisors, and as of late Docker/microservices, and serverless.  Docker is one of those steps of technology that might not be the end state of IT, but just like COBOL, this technology might stay around for a very long time.  In much of the same way that VMWare and other hypervisors over the past dozen or so years have transformed most businesses physical servers into a world of virtual servers saving cost, floor space, enabling easier management, ability to support snapshots and many other technologies only dreamed of decades ago.  In a way, Docker is doing what Hypervisors did to physical servers.  Docker essential development is the simplification of using some old features of Linux (going back to Sun Solaris or FreeBSD), by delivering packaging management needed to run specific code i.e. Tomcat, PHP, or WordPress for example in a “container”.  As Docker removes the need to support the Guest OS, this has immediate benefits: running a single file(Container) with all the software/code embedded within that image.  Containers are typically much smaller, faster, and easier to swap in/out as needed with code upgrades.  For example my laptop can spin up a dozen TomCat Apache servers in about a second.  This could be a generic TomCat image that nees to be initialized to go and pull down HTML code that I want them to host. Or, they could be embedded already into the container my specific HTML code I need them to run.  Lastly I could update the container of my image with new HTML code and spin down the old containers and spin back up the new containers of the image in seconds.  All while saving over a traditional OS and Tomcat install anywhere from 5X to 25X(or more) less memory and disk requirements.

Today all these labs will run in the cloud, due to the number of guests needed to host a few different management platforms for Docker (RedHat Openshift K8s, Mesos/Marathon, and Generic Kubernetes), and not the time to setup all these environments.  Next page we will install Docker and run a small container for a “hello world”.

Windows versus Linux:
You are in luck (mostly), containers are cross platform or “agnostic” of OS that Docker runs on.
If you decide to install Docker on Linux on your own (as in next page) you install only the Docker Engine and management tools. You don’t need to create a virtual machine or virtual networks, because docker via it’s containers will handle the setup for you.

For Windows:  having another hypervisor can cause conflicts.  During Docker installation, Docker creates a Linux-based virtual machine called MobyLinuxVM.  The Docker application connects to this machine, so that you can create your container with the necessary apparatus for operation. This installation also configures a subnet for the virtual machine to communicate with the local network / NAT for your containers to use in the application. All of these steps occur behind the scenes and, as the user, you don’t really have to worry about them. Still, the fact that Docker on Windows runs a virtual machine in the background is another major difference between Docker on Windows and Docker on Linux.

.. tip:: For more information please come back and visit any of these links below:

    https://www.docker.com

    https://www.infoworld.com/article/3204171/linux/what-is-docker-linux-containers-explained.html

    https://www.zdnet.com/article/what-is-docker-and-why-is-it-so-darn-popular/

Next we're going to install Docker and learn some of the basic commands.  We'll do this on 3 Ubuntu servers (Kubernetes VM's in the lab).

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
