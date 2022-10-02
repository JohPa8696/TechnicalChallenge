az login --service-principal -u ${client_id} -p ${client_secret} --tenant ${tenant_id}
az account set --subscription ${subscription_id}

# Seed database
az webapp config set --resource-group ${resource_group_name} --name ${resource_name} --startup-file ${seed_command} 
az webapp restart --name ${resource_name} --resource-group ${resource_group_name}

az webapp config set --resource-group ${resource_group_name} --name ${resource_name} --startup-file ${serve_command}
az webapp restart --name ${resource_name} --resource-group ${resource_group_name}