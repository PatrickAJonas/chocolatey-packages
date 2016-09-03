
function resolveRelease {
	param(
		$response,
		[boolean] $usePrerelease
	)
	$verRegex = "((\d+)(\.\d+){0,3}(\-[a-z]+[0-9]+)?)$";
	if ($usePrerelease) {
		$release = $response | ? tag_name -Match $verRegex | select -First 1;
	} else {
		$release = $response | ? prerelease -EQ $usePrerelease | ? tag_name -Match $verRegex | select -First 1;
	}
	
	if (!$release) {
		return @{};
	}
	
	$version = $matches[1];
	
	$assetUrls = $release.assets | ? name -Match "\.(msi|exe)$" | select -expand browser_download_url;
	
	return @{
		Name = $release.name
		Version = $version
		Assets = $assetUrls
	};
}

function getLatestReleases {
	param(
		[string]$repoUser,
		[string]$repoName,
		[boolean]$includePreRelease = $true
	)
	
	If (!$includePreRelease) {
		$apiUrl = "https://api.github.com/repos/$($repoUser)/$($repoName)/releases/latest";
	} Else {
		$apiUrl = "https://api.github.com/repos/$($repoUser)/$($repoName)/releases";
	}
	
	$response = Invoke-RestMethod -Uri $apiUrl;
	
	$latestStableRelease = resolveRelease -response $response -usePrerelease $false;
	$latestRelease = resolveRelease -response $response -usePrerelease $includePreRelease;
	
	return @{ latest = $latestRelease ; latestStable = $latestStableRelease};
}