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
Write-Host "$args[4] verify"
$serviceconfig = [IO.File]::ReadAllText(".\user-service-repo\" + $args[4])
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

$value = $parsedYAML.parameter.cxProjectName
Write-Host "##vso[task.setvariable variable=param.cxProjectName;isOutput=true]$value"

$value = $parsedYAML.parameter.vaultAgentStartup
$LOWERSN=$value.ToString().ToLower()
Write-Host "##vso[task.setvariable variable=param.vaultAgentStartup;isOutput=true]$LOWERSN"
Write-Host $LOWERSN

$value = $parsedYAML.parameter.imageName
Write-Host "##vso[task.setvariable variable=param.imageName;isOutput=true]$value"

$value = $parsedYAML.parameter.cxPreset
Write-Host "##vso[task.setvariable variable=param.cxPreset;isOutput=true]$value"

$value = $parsedYAML.parameter.solution
Write-Host "##vso[task.setvariable variable=param.solution;isOutput=true]$value"

$value = $parsedYAML.parameter.applicationName
Write-Host "##vso[task.setvariable variable=param.applicationName;isOutput=true]$value"
Write-Host "Testing Application Name: $value"

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

$value = $parsedYAML.parameter.testPlatform
Write-Host "##vso[task.setvariable variable=param.testPlatform;isOutput=true]$value"

$value = $parsedYAML.parameter.serviceDirectory
Write-Host "##vso[task.setvariable variable=param.serviceDirectory;isOutput=true]$value"

$value = $parsedYAML.parameter.artifactoryPath
Write-Host "##vso[task.setvariable variable=param.artifactoryPath;isOutput=true]$value"

$value = $parsedYAML.parameter.nodeVersion
Write-Host "##vso[task.setvariable variable=param.nodeVersion;isOutput=true]$value"

$value = $parsedYAML.parameter.node_Env
Write-Host "##vso[task.setvariable variable=param.node_Env;isOutput=true]$value"

$value = $parsedYAML.parameter.sharedInfra
if (!($value))
{
    $value = "false"
}
Write-Host "final value for sharedInfra is $value"
Write-Host "##vso[task.setvariable variable=param.sharedInfra;isOutput=true]$value"

$value = $parsedYAML.parameter.apacheServer
if (!($value))
{
    $value = "false"
}
Write-Host "final value for apacheServer is $value"
Write-Host "##vso[task.setvariable variable=param.apacheServer;isOutput=true]$value"

$value = $parsedYAML.parameter.publishWebProjects 
if (!($value))
{
    $value = "true"
}
Write-Host "final value for publishWebProjects is $value"
Write-Host "##vso[task.setvariable variable=param.publishWebProjects;isOutput=true]$value"

$value = $parsedYAML.parameter.lcovCoveragePath 
if (!($value))
{
    $value = "coverage/lcov.info"
}
Write-Host "final value for lcovCoveragePath is $value"
Write-Host "##vso[task.setvariable variable=param.lcovCoveragePath;isOutput=true]$value"

$value = $parsedYAML.parameter.buildProjectPath
if (!($value))
{
    $value = ""
}
Write-Host "final value for buildProjectPath is $value"
Write-Host "##vso[task.setvariable variable=param.buildProjectPath;isOutput=true]$value"

$value = $parsedYAML.parameter.nodeApplication
if (!($value))
{
    $value = "false"
}
Write-Host "final value for nodeApplication is $value"
Write-Host "##vso[task.setvariable variable=param.nodeApplication;isOutput=true]$value"

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
if($args[3] -eq $True)
{
	$branch="develop"
}

Write-Host "This run triggered by" $branch
$value = $branch
Write-Host "##vso[task.setvariable variable=branch;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.checkMarxScan
Write-Host "##vso[task.setvariable variable=pipeline.checkMarxScan;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.build
Write-Host "##vso[task.setvariable variable=pipeline.build;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.buildForEC2
Write-Host "##vso[task.setvariable variable=pipeline.buildForEC2;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.deployOnEC2
Write-Host "##vso[task.setvariable variable=pipeline.deployOnEC2;isOutput=true]$value"

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

$value = $parsedYAML.build.branches.$branch.unitTestCommand 
if (!($value))
{
    $value = "test:coverage"
}
Write-Host "final value for unitTestCommand is $value"
Write-Host "##vso[task.setvariable variable=pipeline.unitTestCommand;isOutput=true]$value"


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



################Read build master variables
$value = $parsedYAML.build.branches.$branch.deployOnDevEC2
Write-Host "final value for deployOnDevEC2 is $value"
Write-Host "##vso[task.setvariable variable=pipeline.deployOnDevEC2;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.devBuildCommand
if (!($value))
{
    $value = "buildDev"
}
Write-Host "final value for devBuildCommand is $value"
Write-Host "##vso[task.setvariable variable=pipeline.devBuildCommand;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.deployOnIntEC2
Write-Host "final value for deployOnIntEC2 is $value"
Write-Host "##vso[task.setvariable variable=pipeline.deployOnIntEC2;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.intBuildCommand
if (!($value))
{
    $value = "buildInt"
}
Write-Host "final value for intBuildCommand is $value"
Write-Host "##vso[task.setvariable variable=pipeline.intBuildCommand;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.deployOnPrdEC2
Write-Host "final value for deployOnPrdEC2 is $value"
Write-Host "##vso[task.setvariable variable=pipeline.deployOnPrdEC2;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.prdBuildCommand
if (!($value))
{
    $value = "buildPrd"
}
Write-Host "final value for prdBuildCommand is $value"
Write-Host "##vso[task.setvariable variable=pipeline.prdBuildCommand;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.deployOnDevOpsEC2
Write-Host "final value for deployOnDevOpsEC2 is $value"
Write-Host "##vso[task.setvariable variable=pipeline.deployOnDevOpsEC2;isOutput=true]$value"

$value = $parsedYAML.build.branches.$branch.devOpsBuildCommand
if (!($value))
{
    $value = "buildQa"
}
Write-Host "final value for devOpsBuildCommand is $value"
Write-Host "##vso[task.setvariable variable=pipeline.devOpsBuildCommand;isOutput=true]$value"
