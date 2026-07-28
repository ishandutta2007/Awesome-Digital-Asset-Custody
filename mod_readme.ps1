$readmePath = "README.md"
$content = Get-Content $readmePath -Raw -Encoding UTF8

$content = $content -replace '## Top Digital Asset Custody Ecosystem', '## 🌟 Top Digital Asset Custody Ecosystem'
$content = $content -replace '## SaaS/Hosted Platforms', '## 🏢 SaaS/Hosted Platforms'
$content = $content -replace '## Open-Source GitHub Projects', '## 💻 Open-Source GitHub Projects'
$content = $content -replace '## How to Contribute', '## 🤝 How to Contribute'
$content = $content -replace '## Disclaimer', '## ⚠️ Disclaimer'

if ($content -notmatch 'Discover the ultimate curated list of digital asset custody') {
    $content = $content -replace '\*\*Curated List of SaaS Products & Open-Source GitHub Projects\*\*', "**Curated List of SaaS Products & Open-Source GitHub Projects**`n`n*Discover the ultimate curated list of digital asset custody, MPC wallets, and institutional key management solutions. Optimize your self-custody and crypto operations with these top-tier platforms.*"
}

$bannerLink = "<p align=`"center`"><img src=`"./assets/banner.svg`" width=`"100%`" alt=`"Awesome Digital Asset Custody Banner`"></p>`n"
if ($content -notmatch 'assets/banner\.svg') {
    $content = $bannerLink + $content
}

$leftBadges = '<a href="https://github.com/ishandutta2007/Awesome-Awesome-Awesome"><img src="https://img.shields.io/badge/Awesome-%E2%9C%94-blueviolet?style=flat-square&logo=github" alt="Awesome"/></a><a href="https://discord.gg/jc4xtF58Ve"><img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord" /></a>'
$rightBadge = '<a href="https://github.com/ishandutta2007"><img alt="GitHub followers" src="https://img.shields.io/github/followers/ishandutta2007?label=Follow" /></a>'

if ($content -notmatch [regex]::Escape($leftBadges)) {
    $badgesHtml = "<p align=`"center`">`n$leftBadges`n$rightBadge`n</p>`n"
    if ($content -match 'assets/banner\.svg') {
        $content = $content.Replace($bannerLink, $bannerLink + $badgesHtml)
    } else {
        $content = $badgesHtml + $content
    }
}

$starHistory = "`n## 📈 Star History`n<div align=`"center`">`n<a href=`"https://www.star-history.com/?repos=ishandutta2007/Awesome-Digital-Asset-Custody&type=date&legend=bottom-right`">`n<picture>`n<source media=`"(prefers-color-scheme: dark)`" srcset=`"https://api.star-history.com/chart?repos=ishandutta2007/Awesome-Digital-Asset-Custody&type=date&theme=dark&legend=bottom-right`" />`n<source media=`"(prefers-color-scheme: light)`" srcset=`"https://api.star-history.com/chart?repos=ishandutta2007/Awesome-Digital-Asset-Custody&type=date&legend=bottom-right`" />`n<img alt=`"Star History Chart`" src=`"https://api.star-history.com/chart?repos=ishandutta2007/Awesome-Digital-Asset-Custody&type=date&legend=bottom-right`" />`n</picture>`n</a>`n</div>`n"
if ($content -notmatch 'Star History') {
    $content = $content + $starHistory
}

$content = $content -replace 'chartrepos', 'chart?repos'
$content = $content -replace 'https://github.com/sindresorhus/awesome', 'https://github.com/ishandutta2007/Awesome-Awesome-Awesome'

Set-Content -Path $readmePath -Value $content -Encoding UTF8 -NoNewline
