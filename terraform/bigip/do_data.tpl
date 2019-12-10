{
    "schemaVersion": "1.9.0",
    "class": "Device",
    "async": true,
        "Common": {
            "class": "Tenant",
                "hostname": "${host_name}",
                "myDns": {
                    "class": "DNS",
                    "nameServers": [
                        "${aws_dns}",
                        "8.8.8.8",
                        "8.8.4.4"
                    ],
                    "search": [
                        "f5demos.com",
                        "tognaci.com"
                    ]
                },
                "myNtp": {
                    "class": "NTP",
                    "servers": [
                        "pool.ntp.org"
                    ],
                    "timezone": "America/Chicago"
                },
                "myProvisioning": {
                    "class": "Provision",
                    "ltm": "nominal"
                },
                "kubernetes": {
                    "class": "VLAN",
                    "interfaces": [
                        {
                            "name": "1.1"
                        }
                    ]
                },
                "kubernetes-self": {
                    "class": "SelfIp",
                    "address": "${kubernetes_ip}/24",
                    "vlan": "kubernetes",
                    "allowService": "none",
                    "trafficGroup": "traffic-group-local-only"
                },
                "openshift": {
                    "class": "VLAN",
                    "interfaces": [
                        {
                            "name": "1.2"
                        }
                    ]
                },
                "openshift-self": {
                    "class": "SelfIp",
                    "address": "${openshift_ip}/24",
                    "vlan": "openshift",
                    "allowService": "all",
                    "trafficGroup": "traffic-group-local-only"
                },
                "configsync": {
                    "class": "ConfigSync",
                    "configsyncIp": "/Common/openshift-self/address"
                },
                "failoverAddress": {
                    "class": "FailoverUnicast",
                    "address": "/Common/openshift-self/address"
                },
                "device-group-1": {
                    "class": "DeviceGroup",
                    "type": "sync-failover",
                    "members": [${members}],
                    "owner": "//Common/device-group-1/members/0",
                    "autoSync": true,
                    "saveOnAutoSync": false,
                    "networkFailover": true,
                    "fullLoadOnSync": false,
                    "asmSync": false
                },
                "trust": {
                    "class": "DeviceTrust",
                    "localUsername": "${admin}",
                    "localPassword": "${password}",
                    "remoteHost": "/Common/device-group-1/members/0",
                    "remoteUsername": "${admin}",
                    "remotePassword": "${password}"
                },
                "dbvars": {
                    "class": "DbVariables",
                    "ui.system.preferences.recordsperscreen": "100",
                    "ui.system.preferences.advancedselection": "advanced"
                }
        }
}
