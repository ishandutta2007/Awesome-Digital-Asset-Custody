$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$readmePath = "README.md"
$content = Get-Content $readmePath -Encoding UTF8
$openSourceStartIndex = $content.IndexOf("## Open-Source GitHub Projects")

$additionalStartIndex = -1
for ($i = $openSourceStartIndex; $i -lt $content.Length; $i++) {
    if ($content[$i] -match "^### Additional Strong Open-Source Options") {
        $additionalStartIndex = $i
        break
    }
}

function Get-GithubStars {
    param([string]$url)
    
    if ($url -match "github\.com/([^/]+)/?([^/ \)]+)?") {
        $owner = $matches[1]
        $repo = $matches[2]
        
        if (-not $repo) {
            try {
                $apiUrl = "https://api.github.com/users/$owner/repos?sort=updated"
                $response = Invoke-RestMethod -Uri $apiUrl -Headers @{"User-Agent"="Mozilla/5.0"}
                if ($response.Count -gt 0) {
                    $best = $response | Sort-Object stargazers_count -Descending | Select-Object -First 1
                    return @($best.stargazers_count, "$owner/$($best.name)")
                }
            } catch {
                return @(0, $owner)
            }
        } else {
            try {
                $apiUrl = "https://api.github.com/repos/$owner/$repo"
                $response = Invoke-RestMethod -Uri $apiUrl -Headers @{"User-Agent"="Mozilla/5.0"}
                return @($response.stargazers_count, "$owner/$repo")
            } catch {
                Write-Host "Error fetching $apiUrl : $_"
                return @(0, "$owner/$repo")
            }
        }
    }
    return @(0, "")
}

$entries = @()
$currentEntry = $null

for ($i = $openSourceStartIndex + 1; $i -lt $additionalStartIndex; $i++) {
    $line = $content[$i]
    if ($line -match "^- \*\*\[([^\]]+)\]\(([^)]+)\)\*\*") {
        if ($currentEntry) { $entries += $currentEntry }
        $currentEntry = @{
            name = $matches[1]
            url = $matches[2]
            lines = @($line)
            stars = 0
            repo = ""
        }
    } elseif ($currentEntry -and $line.Trim() -ne "") {
        $currentEntry.lines += $line
    } elseif ($currentEntry -and $line.Trim() -eq "") {
        $currentEntry.lines += $line
        $entries += $currentEntry
        $currentEntry = $null
    }
}
if ($currentEntry) { $entries += $currentEntry }

$addEntries = @()
$currentAdd = $null
$endIndex = $content.Length

for ($i = $additionalStartIndex + 1; $i -lt $content.Length; $i++) {
    $line = $content[$i]
    if ($line -match "^\*\*Frameworks for building custom systems\*\*" -or $line -match "^## How to Contribute") {
        $endIndex = $i
        break
    }
    
    if ($line -match "^- \*\*\[([^\]]+)\]\(([^)]+)\)\*\*") {
        if ($currentAdd) { $addEntries += $currentAdd }
        $currentAdd = @{
            name = $matches[1]
            url = $matches[2]
            lines = @($line)
            stars = 0
            repo = ""
            raw = $false
        }
    } elseif ($line -match "^- \*\*MPC" -or $line -match "^- \*\*Hardware") {
        if ($currentAdd) { $addEntries += $currentAdd; $currentAdd = $null }
        $addEntries += @{raw=$true; line=$line}
    } elseif ($line -match "^- Many community") {
        $addEntries += @{raw=$true; line=$line}
    } elseif ($currentAdd -and $line.Trim() -ne "") {
        $currentAdd.lines += $line
    } elseif ($currentAdd -and $line.Trim() -eq "") {
        $currentAdd.lines += $line
        $addEntries += $currentAdd
        $currentAdd = $null
    }
}
if ($currentAdd) { $addEntries += $currentAdd }

Write-Host "Fetching stars..."
foreach ($e in $entries) {
    $result = Get-GithubStars -url $e.url
    $e.stars = $result[0]
    $e.repo = $result[1]
    # Remove existing badge if it exists (since we ran it once and it might have put 0s)
    $e.lines[0] = $e.lines[0] -replace " \[!\[Stars\]\([^)]+\)\]\([^)]+\)", ""
    
    if ($e.repo) {
        $badge = "[![Stars](https://img.shields.io/github/stars/$($e.repo)?style=social&color=white)](https://github.com/$($e.repo)/stargazers)"
        $target = "]($($e.url))**"
        $e.lines[0] = $e.lines[0].Replace($target, "$target $badge")
    }
    Write-Host "$($e.name): $($e.stars)"
}

$addSortable = $addEntries | Where-Object { $_.raw -eq $false }
$addRaw = $addEntries | Where-Object { $_.raw -eq $true }

foreach ($e in $addSortable) {
    $result = Get-GithubStars -url $e.url
    $e.stars = $result[0]
    $e.repo = $result[1]
    
    $e.lines[0] = $e.lines[0] -replace " \[!\[Stars\]\([^)]+\)\]\([^)]+\)", ""

    if ($e.repo) {
        $badge = "[![Stars](https://img.shields.io/github/stars/$($e.repo)?style=social&color=white)](https://github.com/$($e.repo)/stargazers)"
        $target = "]($($e.url))**"
        $e.lines[0] = $e.lines[0].Replace($target, "$target $badge")
    }
    Write-Host "$($e.name): $($e.stars)"
}

$entries = $entries | Sort-Object -Property stars -Descending
$addSortable = $addSortable | Sort-Object -Property stars -Descending

$newLines = @()
for ($i = 0; $i -le $openSourceStartIndex; $i++) {
    $newLines += $content[$i]
}
$newLines += ""

foreach ($e in $entries) {
    foreach ($line in $e.lines) {
        $newLines += $line
    }
}

$newLines += $content[$additionalStartIndex]
foreach ($e in $addSortable) {
    foreach ($line in $e.lines) {
        $newLines += $line
    }
}
foreach ($e in $addRaw) {
    $newLines += $e.line
}

for ($i = $endIndex; $i -lt $content.Length; $i++) {
    $newLines += $content[$i]
}

Set-Content -Path $readmePath -Value $newLines -Encoding UTF8
Write-Host "Done"
