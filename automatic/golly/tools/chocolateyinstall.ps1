﻿$ErrorActionPreference = 'Stop'

$toolsPath = Split-Path -parent $MyInvocation.MyCommand.Definition

$packageName = $env:ChocolateyPackageName

$packageArgs = @{
  packageName    = $packageName
  file           = "$toolsPath\golly-3.1-win-32bit.zip"
  file64         = "$toolsPath\golly-3.1-win-64bit.zip"
  destination    = "$toolsPath"
}

Get-ChocolateyUnzip @packageArgs
Remove-Item $toolsPath\*.zip -ea 0

$exeLocation = Get-ChildItem $toolsPath "Golly.exe" -Recurse | select -first 1
if ($exeLocation) {
  Set-Content "$($exeLocation.FullName).gui" -Value ''
  Register-Application "$($exeLocation.FullName)"
  Write-Host "$packageName registered as $($exeLocation.Name)"
} else {
  Write-Warning "Can't find $PackageName install location"
}
