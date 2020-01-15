# This script builds a Cura release using the cura-build-environment Windows docker image.
Param (
  # Docker parameters
  [string]$DockerImage = "stereotech/ste-slicer-build-environment:stable",
  # Branch parameters
  [string]$SteSlicerBranchOrTag = "develop",
  [string]$UraniumBranchOrTag = "3.6.0",
  [string]$CuraEngineBranchOrTag = "3.6.0",
  [string]$CuraBinaryDataBranchOrTag = "3.6.0",
  [string]$CharonBranchOrTag = "3.6.0",
  # Cura release parameters
  [Parameter(Mandatory = $true)]
  [Int32]$SteSlicerVersionMajor,
  [Parameter(Mandatory = $true)]
  [Int32]$SteSlicerVersionMinor,
  [Parameter(Mandatory = $true)]
  [Int32]$SteSlicerVersionPatch,
  [Parameter(Mandatory = $false)]
  [AllowEmptyString()]
  [string]$SteSlicerVersionExtra = "",
  [Parameter(Mandatory = $false)]
  [string]$SteSlicerBuildName = "win64",
  [Parameter(Mandatory = $false)]
  [string]$SteSlicerWindowsInstallerType = "EXE"
)

$outputDirName = "windows-installers"

New-Item $outputDirName -ItemType "directory" -Force
$repoRoot = Join-Path $PSScriptRoot -ChildPath "..\.." -Resolve
$outputRoot = Join-Path (Get-Location).Path -ChildPath $outputDirName -Resolve

if ($SteSlicerWindowsInstallerType = "EXE") {
  $CPACK_GENERATOR = "NSIS"
}
elseif ($SteSlicerWindowsInstallerType = "MSI") {
  $CPACK_GENERATOR = "WIX"
}
else {
  Write-Error `
    -Message "Invalid value [$SteSlicerWindowsInstallerType] for SteSlicerWindowsInstallerType. Must be EXE or MSI" `
    -Category InvalidArgument
  exit 1
}

& docker.exe run --rm `
  --volume ${repoRoot}:C:\steslicer-build-src `
  --volume ${outputRoot}:C:\steslicer-build-output `
  --env STESLICER_BUILD_SRC_PATH=C:\steslicer-build-src `
  --env STESLICER_BUILD_OUTPUT_PATH=C:\steslicer-build-output `
  --env STESLICER_BRANCH_OR_TAG=$SteSlicerBranchOrTag `
  --env URANIUM_BRANCH_OR_TAG=$UraniumBranchOrTag `
  --env CURAENGINE_BRANCH_OR_TAG=$CuraEngineBranchOrTag `
  --env LIBCHARON_BRANCH_OR_TAG=$CharonBranchOrTag `
  --env CURABINARYDATA_BRANCH_OR_TAG=$CuraBinaryDataBranchOrTag `
  --env STESLICER_VERSION_MAJOR=$SteSlicerVersionMajor `
  --env STESLICER_VERSION_MINOR=$SteSlicerVersionMinor `
  --env STESLICER_VERSION_PATCH=$SteSlicerVersionPatch `
  --env STESLICER_VERSION_EXTRA=$SteSlicerVersionExtra `
  --env STESLICER_BUILD_NAME=$SteSlicerBuildName `
  --env CPACK_GENERATOR=$CPACK_GENERATOR `
  $DockerImage `
  powershell.exe -Command cmd /c "C:\steslicer-build-src\scripts\windows\build_in_docker_vs2015.cmd"