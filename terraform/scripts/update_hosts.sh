#!/bin/bash

extlbip=`aws ec2 describe-network-interfaces --filters Name=description,Values="ELB net/okd4-extlb/*" --query 'NetworkInterfaces[*].PrivateIpAddresses[*].Association.PublicIp' --output text`

printf "\n${extlbip}  api.okd4.agility.lab\n" | sudo tee -a /etc/hosts
printf "${extlbip}  oauth-openshift.apps.okd4.agility.lab\n" | sudo tee -a /etc/hosts
printf "${extlbip}  console-openshift-console.apps.okd4.agility.lab\n" | sudo tee -a /etc/hosts

