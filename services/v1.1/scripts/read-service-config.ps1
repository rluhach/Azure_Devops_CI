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
Write-Host "$args[6] verify"
$serviceconfig = [IO.File]::ReadAllText(".\user-service-repo\" + $args[6])
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

$value = $parsedYAML.parameter.applicationName
Write-Host "##vso[task.setvariable variable=param.applicationName;isOutput=true]$value"
Write-Host "Testing Application Name: $value"

$value = $parsedYAML.parameter.cxProjectName
Write-Host "##vso[task.setvariable variable=param.cxProjectName;isOutput=true]$value"


$value = $parsedYAML.parameter.imageName
Write-Host "##vso[task.setvariable variable=param.imageName;isOutput=true]$value"

$value = $parsedYAML.parameter.cxPreset
Write-Host "##vso[task.setvariable variable=param.cxPreset;isOutput=true]$value"

$value = $parsedYAML.parameter.CxFolderExclusions
Write-Host "##vso[task.setvariable variable=param.CxFolderExclusions;isOutput=true]$value"

$value = $parsedYAML.parameter.solution
Write-Host "##vso[task.setvariable variable=param.solution;isOutput=true]$value"

$value = $parsedYAML.parameter.checkmarxThreshold
Write-Host "##vso[task.setvariable variable=param.checkmarxThreshold;isOutput=true]$value"

$value = $parsedYAML.parameter.blackduckThreshold
Write-Host "##vso[task.setvariable variable=param.blackduckThreshold;isOutput=true]$value"

$value = $parsedYAML.parameter.sonarqubeThreshold
Write-Host "##vso[task.setvariable variable=param.sonarqubeThreshold;isOutput=true]$value"

$value = $parsedYAML.parameter.majorVersion
Write-Host "##vso[task.setvariable variable=param.majorVersion;isOutput=true]$value"

$value = $parsedYAML.parameter.artifactoryDockerImageProject
Write-Host "##vso[task.setvariable variable=param.artifactoryDockerImageProject;isOutput=true]$value"

$value = $parsedYAML.parameter.artifactoryDockerImageName
Write-Host "##vso[task.setvariable variable=param.artifactoryDockerImageName;isOutput=true]$value"

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
	$branch="sast"
}
if($args[3] -eq $True)
{
	$branch="release"
}
if($args[4] -eq $True)
{
	$branch="hotfix"
}
if($args[5] -eq $True)
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

$value = $parsedYAML.build.branches.$branch.imageScan
Write-Host "##vso[task.setvariable variable=pipeline.imageScan;isOutput=true]$value"


$value = $parsedYAML.build.branches.$branch.dockerBuild
Write-Host "##vso[task.setvariable variable=pipeline.dockerBuild;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.publishImage
Write-Host "##vso[task.setvariable variable=pipeline.publishImage;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.prepareHelm
Write-Host "##vso[task.setvariable variable=pipeline.prepareHelm;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.publishHelm
Write-Host "##vso[task.setvariable variable=pipeline.publishHelm;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.deployToK8s
Write-Host "##vso[task.setvariable variable=pipeline.deployToK8s;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.specFlowTest
Write-Host "##vso[task.setvariable variable=pipeline.specFlowTest;isOutput=true]$value"


####################Read service variables
$value = $parsedYAML.service.serviceName
Write-Host "##vso[task.setvariable variable=service.serviceName;isOutput=true]$value"

$value = $parsedYAML.service.serviceType
Write-Host "##vso[task.setvariable variable=service.serviceType;isOutput=true]$value"

$value = $parsedYAML.service.meshName
Write-Host "##vso[task.setvariable variable=service.meshName;isOutput=true]$value"

$value = $parsedYAML.service.serviceExposure
Write-Host "##vso[task.setvariable variable=service.serviceExposure;isOutput=true]$value"

$value = $parsedYAML.service.servicePort
Write-Host "##vso[task.setvariable variable=service.servicePort;isOutput=true]$value"

$value = $parsedYAML.service.rollingStrategy
Write-Host "##vso[task.setvariable variable=service.rollingStrategy;isOutput=true]$value"

$value = $parsedYAML.service.rollingUpdateMaxUnavailable
Write-Host "##vso[task.setvariable variable=service.rollingUpdateMaxUnavailable;isOutput=true]$value"

$value = $parsedYAML.service.rollingUpdateMaxSurge
Write-Host "##vso[task.setvariable variable=service.rollingUpdateMaxSurge;isOutput=true]$value"