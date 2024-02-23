.. image:: /_static/intro/AG-2021-light.jpg
   :align: left

Getting Started
===============

.. important::
   
   * All work for this lab can be performed exclusively from your workstation's
     browser via the *BIG-IP1* and *superjump* systems (*no installation or administrative 
     priviledges are required on your local workstation*).

.. attention::
   * For anyone wishing to take this lab at a later date, the lab is hosted on
     the F5 UDF Environment, and can be found by searching for **"Ingress Labs"**.
     Please work with your F5 Account Team for access.

Overview of the Lab Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The image below represents an overview of the lab environment, which is comprised of:

* F5 Unified Demo Framework (UDF) - *F5's dedicated Private Cloud for demos and labs*
* BIG-IP
* superjump
* kube-master1
* kube-node1
* kube-node2
* okd-master1
* okd-node1
* okd-node2

.. image:: /_static/intro/udf-start.png
   :width: 900
   :align: center

Accessing the UDF Virtual Lab Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is a multi-step process that will involve:

* Finding your invitation email for this UDF lab
* Creating your F5 UDF account (If you don't have one already)
* Setting up MFA for your F5 UDF account (If you haven't already)
* Signing into the UDF lab environment

#. Locate your UDF Course Registration email from F5 <courses@notify.udf.f5.com>.

   +---------------------------------------------------+
   | .. image:: /_static/intro/email-invite.png        |
   |   :width: 800px                                   |
   +---------------------------------------------------+

#. Click on the link below **You can login to the UDF here** (*link is unique for each account*). If you do not already have an F5 account you, will be prompted to create one.

   +---------------------------------------------------+
   | .. image:: /_static/intro/create-account.png      |
   |    :width: 400px                                  |
   +---------------------------------------------------+

   You should then receive a new email to activate your account.

   +---------------------------------------------------+
   | .. image:: /_static/intro/activate-account.png    |
   |    :width: 800px                                  |
   +---------------------------------------------------+

#. Click on **Activate Account**. You should then see the following screen.

   +---------------------------------------------------+
   | .. image:: /_static/intro/account-activated.png   |
   |    :width: 400px                                  |
   +---------------------------------------------------+

#. Browse to login at https://udf.f5.com if not automatically redirected there.

   +---------------------------------------------------+
   | .. image:: /_static/intro/udf-login.png           |
   |    :width: 400px                                  |
   +---------------------------------------------------+

#. Click on **Invited Users** and follow the instructions to complete
   account setup and sign in (2-step authentication is mandatory).

   +---------------------------------------------------+
   | .. image:: /_static/intro/mfa-setup.png           |
   |    :width: 400px                                  |
   +---------------------------------------------------+

#. Follow the instructions and prompts to complete the account setup.

   +---------------------------------------------------+
   | .. image:: /_static/intro/launch-course.png       |
   |    :width: 800px                                  |
   +---------------------------------------------------+

#. Click **-> LAUNCH** (it takes several minutes for the virtual machines to deploy and start.)

   +---------------------------------------------------+
   | .. image:: /_static/intro/UDFJoinClass.png        |
   |    :width: 800px                                  |
   +---------------------------------------------------+

#. *Click* **Join** *and* **Continue Anyway** *you can safely ignore warning for using an Unsupported Browser*.

   +---------------------------------------------------+
   | .. image:: /_static/intro/UDFDocumentationTab.png |
   |    :width: 800px                                  |
   +---------------------------------------------------+

#. The *Documentation* tab will appear. Click on the **Deployment** tab to view your virutal lab machines.
