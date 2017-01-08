import-module au
import-module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1"

$releases = "https://www.xvid.com/download/"

function global:au_BeforeUpdate {
  $Latest.ChecksumType32 = 'sha256'
  Get-RemoteFiles -Purge -DontAppendArch
}

function global:au_SearchReplace {
  @{
    ".\legal\VERIFICATION.txt" = @{
      "(?i)(mirror on\s*)\<.*\>" = "`${1}<$releases>"
      "(?i)(1\..+)\<.*\>"        = "`${1}<$($Latest.URL32)>"
      "(?i)(checksum type:).*"   = "`${1} $($Latest.ChecksumType32)"
      "(?i)(checksum:).*"        = "`${1} $($Latest.Checksum32)"
    }
    ".\tools\chocolateyInstall.ps1" = @{
      "(?i)(`"`[$]toolsDir\\).*`"" = "`${1}$($Latest.FileName32)`""
    }
  }
}

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing

    $re = "Xvid.*\.exe";
    $url = $download_page.links | ? href -Match $re | select -First 1 -ExpandProperty href;

    $version = $url -split '-' | select -Last 1 -Skip 1;

    @{
      Version = $version
      URL32 = $url
    }
}

update -ChecksumFor none
