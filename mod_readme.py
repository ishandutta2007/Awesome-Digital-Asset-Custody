import re

with open('README.md', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Emojis and SEO
content = content.replace('## Top Digital Asset Custody Ecosystem', '## 🌟 Top Digital Asset Custody Ecosystem')
content = content.replace('## SaaS/Hosted Platforms', '## 🏢 SaaS/Hosted Platforms')
content = content.replace('## Open-Source GitHub Projects', '## 💻 Open-Source GitHub Projects')
content = content.replace('## How to Contribute', '## 🤝 How to Contribute')
content = content.replace('## Disclaimer', '## ⚠️ Disclaimer')

if 'Discover the ultimate curated list of digital asset custody' not in content:
    content = content.replace('**Curated List of SaaS Products & Open-Source GitHub Projects**', '**Curated List of SaaS Products & Open-Source GitHub Projects**\n\n*Discover the ultimate curated list of digital asset custody, MPC wallets, and institutional key management solutions. Optimize your self-custody and crypto operations with these top-tier platforms.*')

# 2. Add SVG Banner link
banner_link = '<p align="center"><img src="./assets/banner.svg" width="100%" alt="Awesome Digital Asset Custody Banner"></p>\n'
if 'assets/banner.svg' not in content:
    content = banner_link + content

# 3. Badges
left_badges = '<a href="https://github.com/ishandutta2007/Awesome-Awesome-Awesome"><img src="https://img.shields.io/badge/Awesome-%E2%9C%94-blueviolet?style=flat-square&logo=github" alt="Awesome"/></a><a href="https://discord.gg/jc4xtF58Ve"><img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord" /></a>'
right_badge = '<a href="https://github.com/ishandutta2007"><img alt="GitHub followers" src="https://img.shields.io/github/followers/ishandutta2007?label=Follow" /></a>'

if left_badges not in content:
    badges_html = f'<p align="center">\n{left_badges}\n{right_badge}\n</p>\n'
    # Insert badges after banner
    if banner_link in content:
        content = content.replace(banner_link, banner_link + badges_html)
    else:
        content = badges_html + content

# 4. Star History
star_history = """
## 📈 Star History
<div align="center">
<a href="https://www.star-history.com/?repos=ishandutta2007/Awesome-Digital-Asset-Custody&type=date&legend=bottom-right">
<picture>
<source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=ishandutta2007/Awesome-Digital-Asset-Custody&type=date&theme=dark&legend=bottom-right" />
<source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=ishandutta2007/Awesome-Digital-Asset-Custody&type=date&legend=bottom-right" />
<img alt="Star History Chart" src="https://api.star-history.com/chart?repos=ishandutta2007/Awesome-Digital-Asset-Custody&type=date&legend=bottom-right" />
</picture>
</a>
</div>
"""
if 'Star History' not in content:
    content += star_history

# 5. Fix chartrepos
content = content.replace('chartrepos', 'chart?repos')

# 6. Replace sindresorhus awesome
content = content.replace('https://github.com/sindresorhus/awesome', 'https://github.com/ishandutta2007/Awesome-Awesome-Awesome')

with open('README.md', 'w', encoding='utf-8') as f:
    f.write(content)
