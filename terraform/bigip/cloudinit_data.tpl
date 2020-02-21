#cloud-config   
runcmd:
  - echo "${admin_username}:${admin_password}" | chpasswd
