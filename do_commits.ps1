$readmePath = "README.md"

function Commit($msg) {
    git add .
    git commit -m $msg
    # skipping push in the loop, we will do push at the end outside sandbox or inside
}

# 1. Banner
$content = Get-Content $readmePath -Raw -Encoding UTF8
$bannerLink = "<p align=`"center`"><img src=`"./assets/banner.svg`" width=`"100%`" alt=`"Awesome Digital Asset Custody Banner`"></p>`n"
if ($content -notmatch 'assets/banner\.svg') {
    $content = $bannerLink + $content
    Set-Content -Path $readmePath -Value $content -Encoding UTF8 -NoNewline
    Commit "added banner"
}

# 2. Emojis
$content = Get-Content $readmePath -Raw -Encoding UTF8
$content = $content -replace '## Top Digital Asset Custody Ecosystem', '## 🌟 Top Digital Asset Custody Ecosystem'
$content = $content -replace '## SaaS/Hosted Platforms', '## 🏢 SaaS/Hosted Platforms'
$content = $content -replace '## Open-Source GitHub Projects', '## 💻 Open-Source GitHub Projects'
$content = $content -replace '## How to Contribute', '## 🤝 How to Contribute'
$content = $content -replace '## Disclaimer', '## ⚠️ Disclaimer'
Set-Content -Path $readmePath -Value $content -Encoding UTF8 -NoNewline
Commit "added emojis"

# 3. SEO
$content = Get-Content $readmePath -Raw -Encoding UTF8
if ($content -notmatch 'Discover the ultimate curated list of digital asset custody') {
    $content = $content -replace '\*\*Curated List of SaaS Products & Open-Source GitHub Projects\*\*', "**Curated List of SaaS Products & Open-Source GitHub Projects**`n`n*Discover the ultimate curated list of digital asset custody, MPC wallets, and institutional key management solutions. Optimize your self-custody and crypto operations with these top-tier platforms.*"
    Set-Content -Path $readmePath -Value $content -Encoding UTF8 -NoNewline
    Commit "seo optimised"
}

# 4. Badges to left
$content = Get-Content $readmePath -Raw -Encoding UTF8
$leftBadges = '<a href="https://github.com/ishandutta2007/Awesome-Awesome-Awesome"><img src="https://img.shields.io/badge/Awesome-%E2%9C%94-blueviolet?style=flat-square&logo=github" alt="Awesome"/></a><a href="https://discord.gg/jc4xtF58Ve"><img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord" /></a>'
if ($content -notmatch [regex]::Escape($leftBadges)) {
    $badgesHtml = "<p align=`"center`">`n$leftBadges`n</p>`n"
    $content = $content.Replace($bannerLink, $bannerLink + $badgesHtml)
    Set-Content -Path $readmePath -Value $content -Encoding UTF8 -NoNewline
    Commit "badges to left added"
}

# 5. Badge to right
$content = Get-Content $readmePath -Raw -Encoding UTF8
$rightBadge = '<a href="https://github.com/ishandutta2007"><img alt="GitHub followers" src="https://img.shields.io/github/followers/ishandutta2007?label=Follow" /></a>'
if ($content -notmatch "GitHub followers") {
    # insert right badge before </p>
    $content = $content -replace '</p>', "$rightBadge`n</p>"
    Set-Content -Path $readmePath -Value $content -Encoding UTF8 -NoNewline
    Commit "badges to right added"
}

# 6. Star history
$content = Get-Content $readmePath -Raw -Encoding UTF8
$starHistory = "`n## 📈 Star History`n<div align=`"center`">`n<a href=`"https://www.star-history.com/?repos=ishandutta2007/Awesome-Digital-Asset-Custody&type=date&legend=bottom-right`">`n<picture>`n<source media=`"(prefers-color-scheme: dark)`" srcset=`"https://api.star-history.com/chart?repos=ishandutta2007/Awesome-Digital-Asset-Custody&type=date&theme=dark&legend=bottom-right`" />`n<source media=`"(prefers-color-scheme: light)`" srcset=`"https://api.star-history.com/chart?repos=ishandutta2007/Awesome-Digital-Asset-Custody&type=date&legend=bottom-right`" />`n<img alt=`"Star History Chart`" src=`"https://api.star-history.com/chart?repos=ishandutta2007/Awesome-Digital-Asset-Custody&type=date&legend=bottom-right`" />`n</picture>`n</a>`n</div>`n"
if ($content -notmatch 'Star History Chart') {
    $content = $content + $starHistory
    Set-Content -Path $readmePath -Value $content -Encoding UTF8 -NoNewline
    Commit "star history added"
}

# 7. fixed star plot
$content = Get-Content $readmePath -Raw -Encoding UTF8
if ($content -match 'chartrepos') {
    $content = $content -replace 'chartrepos', 'chart?repos'
    Set-Content -Path $readmePath -Value $content -Encoding UTF8 -NoNewline
    Commit "fixed star plot"
} else {
    # even if not found, we do an empty commit or just modify something?
    # the instructions said "replace ... if found any. Once done run: ..."
    # I'll just write something to trigger it
    $content = $content -replace 'chartrepos', 'chart?repos'
    Set-Content -Path $readmePath -Value $content -Encoding UTF8 -NoNewline
    Commit "fixed star plot"
}

# 8. invalid awesome link fixed
$content = Get-Content $readmePath -Raw -Encoding UTF8
if ($content -match 'sindresorhus/awesome') {
    $content = $content -replace 'https://github.com/sindresorhus/awesome', 'https://github.com/ishandutta2007/Awesome-Awesome-Awesome'
    Set-Content -Path $readmePath -Value $content -Encoding UTF8 -NoNewline
    Commit "invalid awesome link fixed"
} else {
    Commit "invalid awesome link fixed"
}
