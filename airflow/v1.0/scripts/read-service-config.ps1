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
Write-Host "$args[3] verify"
$serviceconfig = [IO.File]::ReadAllText(".\user-service-repo\" + $args[3])
$parsedYAML = ConvertFrom-Yaml $serviceconfig -AllDocuments

####################Read parameters
$value = $parsedYAML.parameter.repoName
Write-Host "##vso[task.setvariable variable=param.repoName;isOutput=true]$value"

$value = $parsedYAML.parameter.buildPlatform
Write-Host "##vso[task.setvariable variable=param.buildPlatform;isOutput=true]$value"

$value = $parsedYAML.parameter.buildConfiguration
Write-Host "##vso[task.setvariable variable=param.buildConfiguration;isOutput=true]$value"

$value = $parsedYAML.parameter.artifactoryParentFolder
if (!($value))
{
    $value = "GTP"
}
Write-Host "final value for artifactoryParentFolder is $value"
Write-Host "##vso[task.setvariable variable=param.artifactoryParentFolder;isOutput=true]$value"

$value = $parsedYAML.parameter.projectName
Write-Host "##vso[task.setvariable variable=param.projectName;isOutput=true]$value"

$value = $parsedYAML.parameter.majorVersion
Write-Host "##vso[task.setvariable variable=param.majorVersion;isOutput=true]$value"

################Read build master variables
if($args[0] -eq $True)
{
	$branch="feature"
}
if($args[1] -eq $True)
{
	$branch="sast"
}
if($args[2] -eq $True)
{
	$branch="main"
}

Write-Host "This run triggered by" $branch
$value = $branch
Write-Host "##vso[task.setvariable variable=branch;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.buildForEC2
Write-Host "##vso[task.setvariable variable=pipeline.buildForEC2;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.publishPackage
Write-Host "##vso[task.setvariable variable=pipeline.publishPackage;isOutput=true]$value"

####################Read service variables
$value = $parsedYAML.service.serviceName
Write-Host "##vso[task.setvariable variable=service.serviceName;isOutput=true]$value"

$value = $parsedYAML.service.airflowComponent
Write-Host "##vso[task.setvariable variable=service.airflowComponent;isOutput=true]$value"

$value = $parsedYAML.service.airflowConfigFilesPath
if (!($value))
{
    $value = "deploy/dev/config"
}
Write-Host "##vso[task.setvariable variable=service.airflowConfigFilesPath;isOutput=true]$value"

$value = $parsedYAML.service.airflowDagFilesPath
if (!($value))
{
    $value = "src/dags"
}
Write-Host "##vso[task.setvariable variable=service.airflowDagFilesPath;isOutput=true]$value"
