param ($sqprojectname,$blackduckThreshold)

Start-Sleep -m 15000
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Token='NTJmZmVmODUtNGI5My00NGY4LThjZWMtOWQ4M2VkMDhlNDA3OjI1ZjcxNjA2LTg4NjgtNGJhMi1iNTg3LTA0MDhjMDM4MGE4ZQ=='
$authHeaders = @{'Authorization' = "token ${Token}"}
$responseBody = Invoke-RestMethod -Method Post -Uri "https://blackduck.aws.transunion.com/api/tokens/authenticate" -Headers $authHeaders 

$bearerToken = $responseBody.bearerToken 
$invocationHeaders = @{'Cookie'= "AUTHORIZATION_BEARER=$($responseBody.bearerToken)" }  

$authBearerHeaders = @{'Authorization' = "Bearer $bearerToken"}

Write-Host $sqprojectname
$url="https://blackduck.aws.transunion.com/api/projects?q=name:"+$sqprojectname
Write-Host $url

$projectInfo = Invoke-restmethod -Uri $url -Headers $authBearerHeaders

Write-Output "==========VersionUrl=============="
Write-Output $projectInfo
$projectidUrl= $projectInfo.items[0]._meta.href+"/versions"
Write-Output $projectidUrl

$projectIDInfo= Invoke-restmethod -Uri $projectidUrl -Headers $authBearerHeaders

Write-Output "===========RiskUrl============="
Write-Output $projectIDInfo
$riskUrl= $projectIDInfo.items[0]._meta.href+"/risk-profile"
Write-Output $riskUrl

$riskProfile = Invoke-restmethod -Uri $riskUrl -Headers $authBearerHeaders

Write-Output " ========Vulnerability Scores======== "
$High =$riskProfile.categories.VULNERABILITY.High
$Medium= $riskProfile.categories.VULNERABILITY.Medium
$Low=$riskProfile.categories.VULNERABILITY.Low
$Unknown= $riskProfile.categories.VULNERABILITY.UNKNOWN
$Critical= $riskProfile.categories.VULNERABILITY.CRITICAL
$OK= $riskProfile.categories.VULNERABILITY.OK

Write-Output "Vulnerability High: $High"
Write-Output "Vulnerability Medium: $Medium"
Write-Output "Vulnerability Low: $Low"
Write-Output "Vulnerability Unknown: $Unknown"
Write-Output "Vulnerability Critical: $Critical"
Write-Output "Vulnerability OK: $OK"
Write-Output "blackduckThreshold: $blackduckThreshold";   

switch ($blackduckThreshold)
        {
            OFF
            {    
              Write-Host "Enforcement disabled!"; 
              Break 
            }
            LENIENT 
            {
              Write-Host "LOW enforcement enabled!"; 
              if($High -gt 0){
                throw 'Code did not meet Back Duck scan standards, failing this pipeline...'; exit 1;
              }              
              Break
            }
            MODERATE 
            {
              Write-Host "MODERATE enforcement enabled!";     
              if($High -gt 0 -OR $Medium -gt 0)
              {
                  throw 'Code did not meet Back Duck scan standards, failing this pipeline...'; exit 1;
              }
              Break
            }
            STRICT 
            {          
             Write-Host "STRICT enforcement enabled!";   
             if($High -gt 0 -OR $Medium -gt 0 -OR  $Low -gt 0)
             {
               throw 'Code did not meet Back Duck scan standards, failing this pipeline...'; exit 1;
             }
              Break
            }
        }

