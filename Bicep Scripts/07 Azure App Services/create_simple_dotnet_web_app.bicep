// Objective: 
//    1. Create a dotnet web application
//    2. Create a react web application

// - `Microsoft.Web`
//     - `servicePlan` module
//         1. name
//         2. location
//         3. sku.name
//             1. F1
//     - `service` module
//         - This is the final web service that will be run “Microsoft.Web”.
//         - It needs a “servicePlan” and “appSettings” to run.
//         1. name
//         2. location
//         3. kind
//             1. 'functionapp'
//         4. properties.serverFarmId
//             1. servicePlan.id
//     - `appSettings` module
//         1. name
//         2. parent: the service reference
//         3. properties
