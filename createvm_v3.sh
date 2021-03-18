#!/bin/bash
#set -e
# naming convention : resourcetype-envrionement-location-application-instance , such as vm-prod-us-gs-01
#locations=("hk" "us" "europe")
locations=("hk")
prefix="sohu"
#apps=("gs-01" "gs-02" "gd-01" "gd-02" "cache-01" "cache-02" "athene-01" "tunnel-01" "spider-01" "living-01" "living-02")
apps=("gs-02" "gd-01" "gd-02" "cache-01" "cache-02" "athene-01" "living-01" "living-02")
#apps=("living-01")

for i in ${!locations[@]}
do
  location="${locations[$i]}"
  echo "begin from location $location"
 

  # Create a resource group.  
  resourceGroup="rg-"${prefix}"-"${location}

  # Create a virtual network.
  virtualNetwork="vnet-"${prefix}"-"${location}
  subnet="snet-"${prefix}"-"${location}
  subnet2="outbound-"${location}
                 
    for j in ${!apps[@]}
    do

        if [[ "$location" == "hk" && "$app" == "gs-01" ]]
        then
            echo "${location} don't need to create app ${app}"
            continue
        elif [[ "$location" == "hk" && "$app" == "athene-01" ]]
        then
            echo "${location} don't need to create app ${app}"
            continue
        elif [[ "$location" != "hk" && "$app" == "cache-01" ]]
        then
            echo "${location} don't need to create app ${app}"
            continue          
        else 
        app="${apps[$j]}"
        echo $app
    
            availabilitySet="as-"${app%-*}"-"$location
            instance=${app#*-}
            appName=${app%-*}         

            vmName="vm"${appName}${location}${instance}

            nic2=${vmName}"-nic-02"
            nic1=${vmName}"-nic-01"
            echo "create nic $nic2"    
            echo "az network nic create --resource-group ${resourceGroup} --vnet-name ${virtualNetwork} --subnet ${subnet} --name ${nic2}"
            #az network nic create --resource-group ${resourceGroup} --vnet-name ${virtualNetwork} --subnet ${subnet} --name ${nic2}
            #echo "az vm stop --resource-group ${resourceGroup} --name ${vmName}"
            #az vm stop --resource-group ${resourceGroup} --name ${vmName}
            #echo "az network nic ip-config create --resource-group ${resourceGroup} -n ipconfig --nic-name ${nic} --make-primary --public-ip-address ${pip}"
            #az network nic ip-config create --resource-group ${resourceGroup} -n ipconfig --nic-name ${nic} --make-primary --public-ip-address ${pip}
            echo "az vm nic add -g ${resourceGroup} --vm-name ${vmName} --nics ${nic2}"        
            #az vm nic add -g ${resourceGroup} --vm-name ${vmName} --nics ${nic2}
            echo "az network nic ip-config update -g ${resourceGroup} --nic-name ${nic1} -n IpConfig1 --subnet ${subnet2}"
            #az network nic ip-config update -g ${resourceGroup} --nic-name ${nic1} -n IpConfig1 --subnet ${subnet2}
            #az network nic ip-config show --name ipconfigmyVM --nic-name myVMVMNic --resource-group myResourceGroup --query publicIPAddress.id
            echo "az vm start --resource-group ${resourceGroup} --name ${vmName}"
            #az vm start --resource-group ${resourceGroup} --name ${vmName}
            if [[ "$location" == "hk" ]]
            then
                echo "az vm run-command invoke -g ${resourceGroup} -n ${vmName} --command-id RunShellScript --scripts \"ip r a 10.0.0.0/8 via 10.52.32.1 ; ip r r a 192.168.0.0/16 via 10.52.32.1\" "
                #az vm extension set -g ${resourceGroup} -n ${vmName} --name customScript --publisher Microsoft.Azure.Extensions --settings '{"fileUris":[""],"commandToExecute": "./***.sh"}'
                az vm extension set --resource-group ${resourceGroup} --vm-name ${vmName} --name customScript --publisher Microsoft.Azure.Extensions --settings ./hk-script-config.json
                elif [[ "$location" == "us" ]]
            then
                echo "az vm run-command invoke -g ${resourceGroup} -n ${vmName} --command-id RunShellScript --scripts \"ip r a 10.0.0.0/8 via 10.52.34.1  ip r r a 192.168.0.0/16 via 10.52.34.1\" "
                #az vm extension set -g ${resourceGroup} -n ${vmName} --name customScript --publisher Microsoft.Azure.Extensions --settings '{"fileUris":[""],"commandToExecute": "./***.sh"}'
                az vm extension set --resource-group ${resourceGroup} --vm-name ${vmName} --name customScript --publisher Microsoft.Azure.Extensions --settings ./us-script-config.json
            elif [[ "$location" == "europe" ]]
            then
                echo "az vm run-command invoke -g ${resourceGroup} -n ${vmName} --command-id RunShellScript --scripts \"ip r a 10.0.0.0/8 via 10.52.36.1  ip r r a 192.168.0.0/16 via 10.52.34.1\" "
                #az vm extension set -g ${resourceGroup} -n ${vmName} --name customScript --publisher Microsoft.Azure.Extensions --settings '{"fileUris":[""],"commandToExecute": "./***.sh"}'
                az vm extension set --resource-group ${resourceGroup} --vm-name ${vmName} --name customScript --publisher Microsoft.Azure.Extensions --settings ./europe-script-config.json
            fi
         fi   
         
    done
        echo "done"
done