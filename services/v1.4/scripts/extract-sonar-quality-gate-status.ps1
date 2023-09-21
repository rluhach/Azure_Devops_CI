param ($sqprojectname,$branchName,$pullRequestId)


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

if($pullRequestId -ne "")
{
    Write-Host "This is a PR build. PR ID: $pullRequestId"
    $url = "https://sonar.transunion.com/api/qualitygates/project_status?projectKey=" + $sqprojectname + "&pullRequest="+ $pullRequestId
}
else{
    Write-Host "This result is for the branch: $branchSourcePath"
    $url = "https://sonar.transunion.com/api/qualitygates/project_status?projectKey=" + $sqprojectname + "&branch="+ $branchSourcePath
}

$Headers = @{
    Authorization = $basicAuth
}

Invoke-restmethod -Uri $url -Headers $Headers

$QualityGateSummary = Invoke-restmethod -Uri $url -Headers $Headers
$QualityGateResult = $QualityGateSummary.projectStatus.status

if($QualityGateResult -ne "OK")
{
    throw 'Quality gate condition(s) failed. Please check the Sonar portal to know about failed conditions'; exit 1;
}
else
{
    Write-Host "Quality Gate Condition(s) passed!"
}
