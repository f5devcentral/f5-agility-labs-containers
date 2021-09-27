#!/bin/bash

if [[ ! -f $PWD/openshift-install ]]; then
    #tar -xzvf openshift-install-linux-4.7.0-0.okd-2021-04-24-103438.tar.gz --exclude='README.md'
    printf "\nDownload and extract the openshift installer for Linux before continuing!"
    printf "\nhttps://github.com/openshift/okd/releases\n"
    exit
else
    printf "\nOpenshift installer found!\n\n"
fi

if [[ -d $PWD/ignition ]]; then
  rm -rf $PWD/ignition/
  mkdir -p $PWD/ignition
else
  mkdir -p $PWD/ignition
fi

cp  $PWD/okd/ignition/install-config.yaml $PWD/ignition/install-config.yaml
printf '  ' >> $PWD/ignition/install-config.yaml && cat ~/.ssh/id_rsa.pub >> $PWD/ignition/install-config.yaml

#ext=$(tr -dc a-z0-9 </dev/urandom | head -c 5 ; echo '')
#sed -i 's/name: okd-.*/'name:\ okd-"$ext"'/' $PWD/ignition/install-config.yaml
#sed -i 's/cluster_name.*/'cluster-name\ \ =\ \"okd-"$ext"\"'/' $PWD/terraform.tfvars

$PWD/openshift-install create install-config --dir=ignition
$PWD/openshift-install create manifests --dir=ignition

rm -f $PWD/ignition/openshift/99_openshift-cluster-api_master-machines-*.yaml
rm -f $PWD/ignition/openshift/99_openshift-cluster-api_worker-machineset-*.yaml
cp $PWD/okd/ignition/cluster-ingress-default-ingresscontroller.yaml $PWD/ignition/manifests/cluster-ingress-default-ingresscontroller.yaml
sed -i '/privateZone:/,+3 d' $PWD/ignition/manifests/cluster-dns-02-config.yml
#cp $PWD/okd/ignition/cluster-dns-02-config.yml $PWD/ignition/manifests/cluster-dns-02-config.yml
#sed -i 's/mastersSchedulable: false/mastersSchedulable: true/' $PWD/ignition/manifests/cluster-scheduler-02-config.yml

$PWD/openshift-install create ignition-configs --dir=ignition

