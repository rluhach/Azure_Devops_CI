#Install-Module powershell-yaml -Scope CurrentUser
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
$serviceconfig = [IO.File]::ReadAllText(".\user-service-repo\" + $args[4])
$parsedYAML = ConvertFrom-Yaml $serviceconfig -AllDocuments
####################Read parameters
$value = $parsedYAML.parameter.repoName
Write-Host "##vso[task.setvariable variable=param.repoName;isOutput=true]$value"
$value = $parsedYAML.parameter.buildPlatform
Write-Host "##vso[task.setvariable variable=param.buildPlatform;isOutput=true]$value"
$value = $parsedYAML.parameter.buildConfiguration
Write-Host "##vso[task.setvariable variable=param.buildConfiguration;isOutput=true]$value"
$value = $parsedYAML.parameter.projectName
Write-Host "##vso[task.setvariable variable=param.projectName;isOutput=true]$value"
$value = $parsedYAML.parameter.cxProjectName
Write-Host "##vso[task.setvariable variable=param.cxProjectName;isOutput=true]$value"
$value = $parsedYAML.parameter.cxPreset
Write-Host "##vso[task.setvariable variable=param.cxPreset;isOutput=true]$value"
$value = $parsedYAML.parameter.CxFolderExclusions
Write-Host "##vso[task.setvariable variable=param.CxFolderExclusions;isOutput=true]$value"
$value = $parsedYAML.parameter.solution
Write-Host "##vso[task.setvariable variable=param.solution;isOutput=true]$value"
$value = $parsedYAML.parameter.checkmarxThreshold
Write-Host "##vso[task.setvariable variable=param.checkmarxThreshold;isOutput=true]$value"
$value = $parsedYAML.parameter.sonarqubeThreshold
Write-Host "##vso[task.setvariable variable=param.sonarqubeThreshold;isOutput=true]$value"
################Read build master variables
if($args[0] -eq $True)
{
    $branch="develop"
}
if($args[1] -eq $True)
{
    $branch="feature"
}
if($args[2] -eq $True)
{
    $branch="release"
}
if($args[3] -eq $True)
{
    $branch="master"
}
Write-Host "This run triggered by" $branch
$value = $parsedYAML.build.branches.$branch.checkMarxScan
Write-Host "##vso[task.setvariable variable=pipeline.checkMarxScan;isOutput=true]$value"
$value = $parsedYAML.build.branches.$branch.build
Write-Host "##vso[task.setvariable variable=pipeline.build;isOutput=true]$value"
$value = $parsedYAML.build.branches.$branch.blackDuckScan
Write-Host "##vso[task.setvariable variable=pipeline.blackDuckScan;isOutput=true]$value"
$value = $parsedYAML.build.branches.$branch.unitTest
Write-Host "##vso[task.setvariable variable=pipeline.unitTest;isOutput=true]$value"
$value = $parsedYAML.build.branches.$branch.sonarqubeScan
Write-Host "##vso[task.setvariable variable=pipeline.sonarqubeScan;isOutput=true]$value"
$value = $parsedYAML.build.branches.$branch.publishPackage
Write-Host "##vso[task.setvariable variable=pipeline.publishPackage;isOutput=true]$value"