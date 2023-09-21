if (Get-Module -ListAvailable -Name powershell-yaml) {
    #Write-Host "powershell-yaml Already Installed"
} 
else {
    try {
        Install-Module -Name powershell-yaml -Scope CurrentUser -Force
    }
    catch [Exception] {
        $_.message 
        exit
    }
}
#Get-ChildItem
$serviceconfig = [IO.File]::ReadAllText(".\user-service-repo\service-config.yaml")
$parsedYAML = ConvertFrom-Yaml $serviceconfig -AllDocuments
Write-Host '##########################################'
Write-Host '#   Service Config Values
Write-Host '##########################################'
$parsedYAML
Write-Host '##########################################'

$serviceMap=@{}
$appsettingJson =Get-Content -Raw -Path ".\user-service-repo\src\**\**\appsettings.json"  | ConvertFrom-Json
Write-Host '##########################################'
Write-Host '#   Appsettings.json
Write-Host '##########################################'
Write-Host $appsettingJson

foreach ($item in $appsettingJson.psobject.properties.name) {
    if ($item -like "Svc-*") {
        Write-Host $appsettingJson.$item  
        Write-Host $item          
        $serviceMap.Add($item.ToString() , $appsettingJson.$item.ToString())      
    }
    # Support for HttpClient settings   
    if ($item -eq "TU.PS.ClientServices") {
           foreach ($clientMap in $appsettingJson.$item){
            foreach ($client in $clientMap) {
                if ($client.Type -eq "Mesh"){
                    Write-Host $client.SvcKey
                    $svc= $client.SvcKey.ToString()               
                    Write-Host $client.$svc
                    $serviceMap.Add($svc.ToString() , $client.$svc.ToString()) 
                }
            }                            
        }            
 }    
}

$envVars=""

foreach ($s in $serviceMap.GetEnumerator()) {
    Write-Host "$($s.Name): $($s.Value)"
    $svcName=$($s.Name)
    $svcValue=$($s.Value)
    $url= "http://"+$svcValue+":9090"
    $envVars+= "  - name: $svcName`n    value: $url`n"
}

Write-Host '##########################################'
Write-Host '#   Env Vars to replace
Write-Host '##########################################'
Write-Host $envVars

$SRVCVERSN= -join($args[0],'')
$IMGNM= $args[1]

#Perform validations
if($parsedYAML.service.serviceType -eq $null)
{
    throw 'serviceType not present in service-config.yaml. Cannot proceed. Failing this pipeline...';exit 1;
}
if($parsedYAML.service.serviceName -eq $null)
{
    throw 'serviceName not present in service-config.yaml. Cannot proceed. Failing this pipeline...';exit 1;
}
$SN=$parsedYAML.service.serviceName
$LOWERSN=$($SN).ToLower()
$FINAL_S_V=-join($SRVCVERSN,'.0')

((Get-Content -path .\base-helm-charts-repo\ps-api\Chart.yaml -Raw) -replace '- name: <REPLACE_MAINTAINER_NAME>', "- name: Platform Services"  ) | Set-Content -Path .\base-helm-charts-repo\ps-api\Chart.yaml

((Get-Content -path .\base-helm-charts-repo\ps-api\Chart.yaml -Raw) -replace 'email: <REPLACE_MAINTAINER_EMAIL>', "email: PDLPlatformServices@transunion.com"  ) | Set-Content -Path .\base-helm-charts-repo\ps-api\Chart.yaml

((Get-Content -path .\base-helm-charts-repo\ps-api\Chart.yaml -Raw) -replace 'name: <REPLACE_SERVICE_NAME>', "name: $LOWERSN"  ) | Set-Content -Path .\base-helm-charts-repo\ps-api\Chart.yaml

((Get-Content -path .\base-helm-charts-repo\ps-api\Chart.yaml -Raw) -replace 'version: <REPLACE_SERVICE_VERSION>', "version: $FINAL_S_V" ) | Set-Content -Path .\base-helm-charts-repo\ps-api\Chart.yaml

((Get-Content -path .\base-helm-charts-repo\ps-api\Chart.yaml -Raw) -replace 'appVersion: <REPLACE_APP_VERSION>', "appVersion: $FINAL_S_V" ) | Set-Content -Path .\base-helm-charts-repo\ps-api\Chart.yaml

switch -Exact ($parsedYAML.service.serviceType)
{
            'custom' {
                       Write-Host 'Service Type is custom..'; 
                       ((Get-Content -path .\user-service-repo\helm\Chart.yaml -Raw) -replace '- name: <REPLACE_MAINTAINER_NAME>', "- name: Platform Services"  ) | Set-Content -Path .\user-service-repo\helm\Chart.yaml

                       ((Get-Content -path .\user-service-repo\helm\Chart.yaml -Raw) -replace 'email: <REPLACE_MAINTAINER_EMAIL>', "email: PDLPlatformServices@transunion.com"  ) | Set-Content -Path .\user-service-repo\helm\Chart.yaml

                       ((Get-Content -path .\user-service-repo\helm\Chart.yaml -Raw) -replace 'name: <REPLACE_SERVICE_NAME>', "name: $LOWERSN"  ) | Set-Content -Path .\user-service-repo\helm\Chart.yaml

                       ((Get-Content -path .\user-service-repo\helm\Chart.yaml -Raw) -replace 'version: <REPLACE_SERVICE_VERSION>', "version: $FINAL_S_V" ) | Set-Content -Path .\user-service-repo\helm\Chart.yaml

                       ((Get-Content -path .\user-service-repo\helm\Chart.yaml -Raw) -replace 'appVersion: <REPLACE_APP_VERSION>', "appVersion: $FINAL_S_V" ) | Set-Content -Path .\user-service-repo\helm\Chart.yaml
                       
                       ((Get-Content -path .\user-service-repo\helm\values.yaml -Raw) -replace 'repository: <REPLACE_DOCKER_REPO_NAME>',"repository: $IMGNM") | Set-Content -Path .\user-service-repo\helm\values.yaml

                       ((Get-Content -path .\user-service-repo\helm\values.yaml -Raw) -replace 'tag: <REPLACE_DOCKER_TAG_VERSION>',"tag: V$SRVCVERSN") | Set-Content -Path .\user-service-repo\helm\values.yaml

                       Write-Host "##vso[task.setvariable variable=helmProjectTarget;isOutput=true].\user-service-repo\helm"; 
                       Write-Host '################################'
                       Write-Host 'Printing chart.yaml'
                       Write-Host '################################'
                       Get-Content -path .\user-service-repo\helm\Chart.yaml -Raw
                       Write-Host '################################'
                       Write-Host '################################'
                       Write-Host 'Printing values.yaml'
                       Write-Host '################################'
                       Get-Content -path .\user-service-repo\helm\values.yaml -Raw
                       Write-Host '################################'
                       
                       exit 0; 
                       Break}
            'basic' {
                      Write-Host 'Service Type is basic..'; 
                      Write-Host "##vso[task.setvariable variable=helmProjectTarget;isOutput=true].\base-helm-charts-repo\ps-api"; 
                      if ($parsedYAML.service.meshName -eq $null)
                      {
                          throw 'meshName is required when serviceType is basic. Failing this pipeline...'; exit 1;
                      }
                      if ($parsedYAML.service.serviceExposure -eq $null)
                      {
                          throw 'serviceExposure is required when serviceType is basic. Failing this pipeline...'; exit 1;
                      }
                      if ($parsedYAML.service.servicePort -eq $null)
                      {
                          throw 'servicePort is required when serviceType is basic. Failing this pipeline...'; exit 1;
                      }
                      if ($parsedYAML.service.rollingStrategy -eq $null)
                      {
                          throw 'rollingStrategy is required when serviceType is basic. Failing this pipeline...'; exit 1;
                      }
                      if ($parsedYAML.service.persistencesize -gt "5Gb" -or $parsedYAML.service.persistencesize -gt "5000Mb")
                      {
                          throw 'the Max persistence Claim value is 5GB'; exit 1;
                      }

                      if($parsedYAML.service.serviceExposure -eq "FrontEnd" -or $parsedYAML.service.serviceExposure -eq "BackEnd")
                      {
                        Write-Host 'Service Exposure type is ' $parsedYAML.service.serviceExposure
                      }
                      else
                      {
                          throw 'serviceExposure should be FrontEnd or BackEnd. Failing this pipeline...'; exit 1;
                      }
                      
                      if($parsedYAML.service.rollingStrategy -eq 'RollingUpdate')
                      {
                          if(($parsedYAML.service.rollingUpdateMaxUnavailable -eq $null) -and ($parsedYAML.service.rollingUpdateMaxSurge -eq $null))
                          {
                            throw 'rollingUpdateMaxUnavailable or rollingUpdateMaxSurge should be available when rollingStrategy is RollingUpdate. Failing this pipeline...'; 
                            exit 1;
                          }
                          if(($parsedYAML.service.rollingUpdateMaxUnavailable -eq "NA") -and ($parsedYAML.service.rollingUpdateMaxSurge -eq "NA"))
                          {
                             throw 'Atleast one out of rollingUpdateMaxUnavailable or rollingUpdateMaxSurge should be defined. Failing this pipeline...'; 
                            exit 1; 
                          }
                          if ((-not ($parsedYAML.service.rollingUpdateMaxUnavailable -eq "NA")) -and (-not ($parsedYAML.service.rollingUpdateMaxSurge -eq "NA")))
                          {
                             throw 'Only one out of rollingUpdateMaxUnavailable or rollingUpdateMaxSurge should be defined. Failing this pipeline...'; 
                            exit 1; 
                          }
                      }
                      Break}
             Default {throw 'Allowed values for serviceType: 1)basic or 2)custom. Supplied Value: ' + $parsedYAML[$key] + '. Please correct..Failing this pipeline...';exit 1; Break }
}


#Replace service name
((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'name: <REPLACE_SERVICE_NAME>',"name: $LOWERSN" ) | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

#Replace servicePort
$SP=$parsedYAML.service.servicePort
((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'port: <REPLACE_SERVICE_PORT>',"port: $SP" ) | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

#Replace Ingress enabled parameter
if ($parsedYAML.service.serviceExposure -eq 'BackEnd')
{
	((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'enabled: <REPLACE_INGRESS_ENABLED>',"enabled: false" ) | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml
}
else
{
	((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'enabled: <REPLACE_INGRESS_ENABLED>',"enabled: true" ) | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml
}

((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'repository: <REPLACE_DOCKER_REPO_NAME>',"repository: $IMGNM") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'tag: <REPLACE_DOCKER_TAG_VERSION>',"tag: V$SRVCVERSN") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'pullPolicy: <REPLACE_IMG_PULL_POLICY>',"pullPolicy: Always") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

$MN=$parsedYAML.service.meshName
((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'name: <REPLACE_MESH_NAME>',"name: $MN") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml
((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'kuma.io/mesh: <REPLACE_MESH_NAME>',"kuma.io/mesh: $MN") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

$NNS=$parsedYAML.service.needNamespacePrefix
if ($parsedYAML.service.needNamespacePrefix -eq $null)
{
    ((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'needNamespacePrefix: <REPLACE_NEEDPREFIX>',"needNamespacePrefix: true") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml
}
else
{
    ((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'needNamespacePrefix: <REPLACE_NEEDPREFIX>',"needNamespacePrefix: $NNS") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml
}

$NS=$parsedYAML.service.namespace
((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'namespace: <REPLACE_NAMESPACE>',"namespace: $NS") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

$PE=$parsedYAML.service.persistenceEnabled
((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'enabled: <REPLACE_ENABLED>',"enabled: $PE") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

$PS=$parsedYAML.service.persistencesize
((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'size: <REPLACE_SIZE>',"size: $PS") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

$PAM=$parsedYAML.service.persistenceAccessMode
((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'accessMode: <REPLACE_ACCESSMODE>',"accessMode: $PAM") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

$IP=$parsedYAML.service.ingressendpoint
((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'ingressendpoint: <REPLACE_INGRESS_ENDPOINT>',"ingressendpoint: $IP") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

$ISP=$parsedYAML.service.serviceendpoint
((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'serviceendpoint: <REPLACE_INGRESS_SERVICE_PATH>',"serviceendpoint: $ISP") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace '<REPLACE_ENV_SERVICE_VARS>',"$envVars") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

#Replace service account name

$SAN=$parsedYAML.service.serviceAccountName
((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'serviceAccountName: <REPLACE_SERVICEACCOUNTNAME>',"serviceAccountName: $SAN") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

$NSA=$parsedYAML.service.createServiceAccount
((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'createServiceAccount: <REPLACE_SERVICEACCOUNTUSAGE>',"createServiceAccount: $NSA") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

#Replace vault enabled parameter
$NV=$parsedYAML.vault.needsVault
((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'enabled: <REPLACE_VAULTUSAGE>',"enabled: $NV") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml
if ($parsedYAML.vault.needsVault -eq $true)
{
    $VA=$parsedYAML.vault.vaultActor
    ((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'vault.hashicorp.com/role: <REPLACE_ROLE>',"vault.hashicorp.com/role: $VA") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

    $VI=$parsedYAML.vault.vaultAgentInject
    ((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'vault.hashicorp.com/agent-inject: <REPLACE_AGENTINJECT>',"vault.hashicorp.com/agent-inject: $VI") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

    $VL=$parsedYAML.vault.vaultLogLevel
    ((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'vault.hashicorp.com/log-level: <REPLACE_LOGLEVEL>',"vault.hashicorp.com/log-level: $VL") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

    $VS=$parsedYAML.vault.vaultSkipTLS
    ((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'vault.hashicorp.com/tls-skip-verify: <REPLACE_TLSSKIPVERIIFY>',"vault.hashicorp.com/tls-skip-verify: $VS") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

    $ACM=$parsedYAML.vault.agentConfigMap
    ((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'vault.hashicorp.com/agent-configmap: <REPLACE_AGENTCONFIGMAP>',"vault.hashicorp.com/agent-configmap: $ACM") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml

    $IACM=$parsedYAML.vault.initAgentConfigMap
    ((Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw) -replace 'vault.hashicorp.com/init-agent-configmap: <REPLACE_INITAGENTCONFIGMAP>',"vault.hashicorp.com/init-agent-configmap: $IACM") | Set-Content -Path .\base-helm-charts-repo\ps-api\values.yaml
}

Write-Host '################################'
Write-Host 'Printing chart.yaml'
Write-Host '################################'
Get-Content -path .\base-helm-charts-repo\ps-api\Chart.yaml -Raw
Write-Host '################################'
Write-Host 'Printing values.yaml'
Write-Host '################################'
Get-Content -path .\base-helm-charts-repo\ps-api\values.yaml -Raw
