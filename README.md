# Azure-Projects

Collection of Azure Commands, Guides and ARM Projects

# Azure CLI Guide

- Connecting to Azure
  - If you have a GUI, then you can use the browser to authenticate
    - `az login`
  - Incase you do not have GUI or a browser
    - `az login --use-device-code`
- Get the current tenant and subscription
  - `az account show --query ”name”` (subscription name)
- Search a command syntax

  - `az    *resource_name    sub_resource    resource_action    action_parameters*`
  - Say if we are looking for resource group, we could look for “resource” “group” or “resource group”
    - `az | Select-String "resource”`
    - `az | Select-String “resource group”`

- If say you need to find more examples us `az find`

  - `az find "az group create"` basically it will search a command database for this exact string. The string is case insensitive.

- To get an exact match in az find results, we need to use the OS string compare function to filter out the results
  - `az find "az group create" | Select-String "az group create”`
- Typical syntax help
  - `az -h`
  - `az deployment -h`
  - `az deployment group -h`
