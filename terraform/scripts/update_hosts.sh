#!/bin/bash

extlbip=`aws ec2 describe-network-interfaces --filters Name=description,Values="ELB net/okd4-extlb/8dd8b940121dd36d" --query 'NetworkInterfaces[*].PrivateIpAddresses[*].Association.PublicIp' --output te

printf "\n${extlbip}  api.okd4.agility.lab\n" | sudo tee -a /etc/hosts
