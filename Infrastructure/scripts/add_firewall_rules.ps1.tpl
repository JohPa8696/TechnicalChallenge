az login --service-principal -u "${client_id}" -p "${client_secret}" --tenant "${tenant_id}"
az account set --subscription "${subscription_id}"

$app_1_ips = az webapp show --name "${app_service_stamp_1}" --resource-group "${resource_group_name}"  --query outboundIpAddresses 
$app_2_ips = az webapp show --name "${app_service_stamp_2}" --resource-group "${resource_group_name}"  --query outboundIpAddresses 

$app_1_ips = $app_1_ips.Replace("`"", "").Split(',')
$app_2_ips = $app_2_ips.Replace("`"", "").Split(',')

$all_ips = $app_1_ips + $app_2_ips | Select -unique

foreach($ip in $all_ips)
{
    $rule_name = $ip.Replace(".", "")
    $res = az postgres flexible-server firewall-rule create --resource-group "${resource_group_name}" --name "${server_name}" --rule-name "Allow_$rule_name"  --start-ip-address $ip --end-ip-address $ip 
}