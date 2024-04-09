Remove-Variable $tenantId $subscriptionName -ErrorAction SilentlyContinue

#Hardcode Tenant ID and Subscription Name (Optional) to bypass console entry
#Subscription Name may be required for some Tenant IDs and should be included if you run into an sign-in error
$tenantId = "ddbccd57-634a-4bea-bd43-e76ae4dff37d"
$subscriptionName  = "ACP3 ST AUS"

#Check for Azure Accounts Powershell Module used to connect to Azure
$result = Get-Module -Name Az.Accounts -ListAvailable
If ($null -eq $result) {
    Write-Host "Please install Az.Accounts Powershell Module by running this command [Install-Module -Name Az.Accounts -Repository PSGallery -Force]"
    exit
}

#Get the Azure Tenant and Subscription you wish to sign into and scan
if ($null -eq $tenantId) {
    $tenantId = Read-Host "Enter the ID of the tenant/subscription you wish to scan"
    if (-not($tenantId -match '[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}')) {
        Read-Host "Enter the ID of the tenant/subscription you wish to scan in the format of ********-****-****-****-************"
    }
}

#Connect to Azure
$azAccessToken = (Get-AzAccessToken).Token
if ($null -eq $azAccessToken) {
    Connect-AzAccount -TenantId $tenantId #-Subscription $subscriptionName
    $azAccessToken = (Get-AzAccessToken).Token
}
$azHeader = @{ Authorization = "Bearer $azAccessToken" }

#Get the list of all organizations in the signed in tenant and save as a csv
$url = "https://aexprodeus21.vsaex.visualstudio.com/_apis/EnterpriseCatalog/Organizations?tenantId=$tenantId"
$entOrgs = (Invoke-WebRequest -Uri $url -Method Get -ContentType 'application/json' -Headers $azHeader).Content
$entOrgs = $entOrgs -replace ", ", ","
$entOrgs > ".\Documents\Azure_DevOps_Orgs_$($SubscriptionName)_$($TenantID)_$(get-date -f yyyy-MM-dd).csv"

Disconnect-AzAccount