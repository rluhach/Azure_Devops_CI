param ($sqprojectname,$sonarqubeThreshold,$branchName)


add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@

[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


$token = [System.Text.Encoding]::UTF8.GetBytes("27cbe5ca23fa51190421646a027f7dfb3f9604ef" + ":")
#Converting the token to Base64 String
$base64 = [System.Convert]::ToBase64String($token)
$basicAuth = [string]::Format("Basic {0}", $base64)


$branchSourcePath = $branchName -replace "refs/heads/", ""

Write-Host "Branch $branchSourcePath"

#Get the history for develop branch and pass the current branch name for the latest results
$url = "https://sonar.transunion.com/api/measures/search_history?component=" + $sqprojectname + "&metrics=bugs%2Cvulnerabilities%2Csqale_index%2Cduplicated_lines_density%2Cncloc%2Ccoverage%2Ccode_smells&ps=1000"
$bugsUrl = "https://sonar.transunion.com/api/issues/search?componentKeys=" + $sqprojectname + "&s=FILE_LINE&resolved=false&sinceLeakPeriod=true&types=BUG&ps=100&organization=default-organization&facets=severities%2Ctypes&additionalFields=_all&branch="+ $branchSourcePath
$codeSmellsUrl = "https://sonar.transunion.com/api/issues/search?componentKeys=" + $sqprojectname + "&s=FILE_LINE&resolved=false&sinceLeakPeriod=true&types=CODE_SMELL&ps=100&organization=default-organization&facets=severities%2Ctypes&additionalFields=_all&branch="+ $branchSourcePath
$vulnerabilitiesUrl = "https://sonar.transunion.com/api/issues/search?componentKeys=" + $sqprojectname + "&s=FILE_LINE&resolved=false&sinceLeakPeriod=true&types=VULNERABILITY&ps=100&organization=default-organization&facets=severities%2CsonarsourceSecurity%2Ctypes&additionalFields=_all&branch="+ $branchSourcePath
$dldUrl = "https://sonar.transunion.com/api/measures/component?component=" + $sqprojectname+ "&metricKeys=new_duplicated_lines_density"
$coverageUrl = "https://sonar.transunion.com/api/measures/component?component=" + $sqprojectname + "&metricKeys=new_coverage&branch="+ $branchSourcePath

$Headers = @{
    Authorization = $basicAuth
}

$history = Invoke-restmethod -Uri $url -Headers $Headers 

foreach ($item in $history)
{
       
  foreach($val in $item.measures)
  {
     
    if ($val.metric -eq  "bugs")
    {
        
        $newBugs = Invoke-restmethod -Uri $bugsUrl -Headers $Headers 
        [string]$BugsStr = $val.history.value[-1]
        [int]$Bugs = $BugsStr 
        [string]$newBugsCountStr= $newBugs.total
        [int]$newBugsCount = $newBugsCountStr 
        Write-Host "Bugs :" $Bugs
        Write-Host "New Bugs :" $newBugsCount
        
    }
    if ($val.metric -eq  "code_smells")
    {  
        $newcode_smells = Invoke-restmethod -Uri $codeSmellsUrl -Headers $Headers 
        Write-Host "Code_smells :" $val.history.value[-1]
        Write-Host "New Code_smells :" $newcode_smells.total
        $Code_smells =  $val.history.value[-1]
        $newcode_smellsCount = $newcode_smells.total
    }
     
    if ($val.metric -eq  "vulnerabilities")
    {
        $newVulnerabilities = Invoke-restmethod -Uri $vulnerabilitiesUrl -Headers $Headers 
        [string]$VulnerabilitiesStr = $val.history.value[-1]
        [string]$newVulnerabilitiesCountStr = $newVulnerabilities.total
        [int]$Vulnerabilities = $VulnerabilitiesStr 
        [int]$newVulnerabilitiesCount = $newVulnerabilitiesCountStr
        Write-Host "Vulnerabilities :" $Vulnerabilities
        Write-Host "New Vulnerabilities :" $newVulnerabilitiesCount
    }
    if ($val.metric -eq  "duplicated_lines_density")
    {
        $newDupLineDensity = Invoke-restmethod -Uri $dldUrl  -Headers $Headers 
        Write-Host "Duplicated_lines_density :" $val.history.value[-1]
        Write-Host "New Duplicated_lines_density :" $newDupLineDensity.component.measures.periods.value
        $Duplicated_lines_densit = $val.history.value[-1]
        $new_duplicated_lines_density = $newDupLineDensity.component.measures.periods.value
        $componentName = $newDupLineDensity.component.name
    }
     
    if ($val.metric -eq  "coverage")
    {
        $newcoverage = Invoke-restmethod -Uri $coverageUrl  -Headers $Headers 
        Write-Host "Coverage :" $val.history.value[-1]
        Write-Host "New Coverage :" $newcoverage.component.measures.periods.value
        $Coverage = $val.history.value[-1]
        $newcoverageCount =  $newcoverage.component.measures.periods.value       
    }   

  }    
}
switch ($sonarqubeThreshold)
        {
            OFF
            {    
              Write-Host "Enforcement disabled!"; 
              Break 
            }
            LENIENT 
            {
              Write-Host "LOW enforcement enabled!"; 
              if($Vulnerabilities -gt 0 -OR  $newVulnerabilitiesCount -gt 0)
              {
                throw 'Code did not meet SonarQube scan standards, failing this pipeline...'; exit 1;
              }              
              Break
            }
            MODERATE 
            {
              Write-Host "MODERATE enforcement enabled!";  
              if($Bugs -gt 3 -OR $newBugsCount -gt 3 -OR  $Vulnerabilities -gt 3 -OR  $newVulnerabilitiesCount -gt 3)
              {
                  throw 'Code did not meet SonarQube scan standards, failing this pipeline...'; exit 1;
              }
              Break
            }
            STRICT 
            {          
             Write-Host "STRICT enforcement enabled!";   
             if($Bugs -gt 0 -OR $newBugsCount -gt 0 -OR  $Vulnerabilities -gt 0 -OR  $newVulnerabilitiesCount -gt 0)
             {
               throw 'Code did not meet SonarQube scan standards, failing this pipeline...'; exit 1;
             }
              Break
            }
        }





