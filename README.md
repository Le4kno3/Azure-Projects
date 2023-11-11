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
        
        ![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/61d8a36d-ff7e-447a-a30b-dcc7237cd817/8c783613-49f9-46bd-99bc-2b89561f551a/Untitled.png)
        
- Search a command syntax
    - `az    *resource_name    sub_resource    resource_action    action_parameters*`
    - Say if we are looking for resource group, we could look for “resource” “group” or “resource group”
        - `az | Select-String "resource”`
        - `az | Select-String “resource group”`
        
        ![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/61d8a36d-ff7e-447a-a30b-dcc7237cd817/e5b17326-c3e9-4fc5-b446-89bd2b601522/Untitled.png)
        

- If say you need to find more examples us `az find`
    - `az find "az group create"` basically it will search a command database for this exact string. The string is case insensitive.
        
        ![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/61d8a36d-ff7e-447a-a30b-dcc7237cd817/e25b2f0b-0bcc-40ca-a1ad-d0c00bccf134/Untitled.png)
        

- To get an exact match in az find results, we need to use the OS string compare function to filter out the results
    - `az find "az group create" | Select-String "az group create”`
    
    ![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/61d8a36d-ff7e-447a-a30b-dcc7237cd817/3d8ef903-b679-440b-805c-2edd5f8315c5/Untitled.png)
    
- Typical syntax help
    - `az -h`
    - `az deployment -h`
    - `az deployment group -h`