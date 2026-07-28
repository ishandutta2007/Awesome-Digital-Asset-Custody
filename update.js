const fs = require('fs');
const https = require('https');

async function getStars(url) {
    const match = url.match(/github\.com\/([^/]+)\/?([^/ \)]+)?/);
    if (!match) return [0, ''];
    const owner = match[1];
    let repo = match[2];

    if (!repo) {
        return new Promise((resolve) => {
            const options = {
                hostname: 'api.github.com',
                path: `/users/${owner}/repos?sort=updated`,
                headers: { 'User-Agent': 'Mozilla/5.0' }
            };
            https.get(options, (res) => {
                let data = '';
                res.on('data', chunk => data += chunk);
                res.on('end', () => {
                    try {
                        const json = JSON.parse(data);
                        if (json && json.length > 0) {
                            let best = json[0];
                            for (let r of json) {
                                if ((r.stargazers_count || 0) > (best.stargazers_count || 0)) {
                                    best = r;
                                }
                            }
                            repo = best.name;
                            resolve([best.stargazers_count || 0, `${owner}/${repo}`]);
                        } else {
                            resolve([0, owner]);
                        }
                    } catch (e) {
                        resolve([0, owner]);
                    }
                });
            }).on('error', () => resolve([0, owner]));
        });
    }

    return new Promise((resolve) => {
        const options = {
            hostname: 'api.github.com',
            path: `/repos/${owner}/${repo}`,
            headers: { 'User-Agent': 'Mozilla/5.0' }
        };
        https.get(options, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    const json = JSON.parse(data);
                    resolve([json.stargazers_count || 0, `${owner}/${repo}`]);
                } catch (e) {
                    resolve([0, `${owner}/${repo}`]);
                }
            });
        }).on('error', () => resolve([0, `${owner}/${repo}`]));
    });
}

async function main() {
    const lines = fs.readFileSync('README.md', 'utf-8').split('\n');
    let openSourceStart = 0;
    for (let i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('## Open-Source GitHub Projects')) {
            openSourceStart = i;
            break;
        }
    }

    let entries = [];
    let currentEntry = null;
    let additionalStart = 0;

    let i = openSourceStart + 1;
    while (i < lines.length) {
        let line = lines[i];
        if (line.startsWith('### Additional Strong Open-Source Options')) {
            additionalStart = i;
            break;
        }

        const m = line.match(/^- \*\*\[([^\]]+)\]\(([^)]+)\)\*\*.*/);
        if (m) {
            if (currentEntry) entries.push(currentEntry);
            currentEntry = { name: m[1], url: m[2], lines: [line], stars: 0, repo: '' };
        } else if (currentEntry && line.trim()) {
            currentEntry.lines.push(line);
        } else if (currentEntry && !line.trim()) {
            currentEntry.lines.push(line);
            entries.push(currentEntry);
            currentEntry = null;
        }
        i++;
    }
    if (currentEntry) entries.push(currentEntry);

    let addEntries = [];
    let currentAdd = null;
    i = additionalStart + 1;
    while (i < lines.length) {
        let line = lines[i];
        if (line.startsWith('**Frameworks for building custom systems**') || line.startsWith('## How to Contribute')) {
            break;
        }

        const m = line.match(/^- \*\*\[([^\]]+)\]\(([^)]+)\)\*\*.*/);
        if (m) {
            if (currentAdd) addEntries.push(currentAdd);
            currentAdd = { name: m[1], url: m[2], lines: [line], stars: 0, repo: '' };
        } else if (line.startsWith('- **MPC') || line.startsWith('- **Hardware')) {
            if (currentAdd) { addEntries.push(currentAdd); currentAdd = null; }
            addEntries.push({ raw: line });
        } else if (line.startsWith('- Many community')) {
            addEntries.push({ raw: line });
        } else if (currentAdd && line.trim()) {
            currentAdd.lines.push(line);
        } else if (currentAdd && !line.trim()) {
            currentAdd.lines.push(line);
            addEntries.push(currentAdd);
            currentAdd = null;
        }
        i++;
    }
    if (currentAdd) addEntries.push(currentAdd);

    console.log("Fetching stars...");
    for (let e of entries) {
        let [stars, repo] = await getStars(e.url);
        e.stars = stars;
        e.repo = repo;
        const badge = `[![Stars](https://img.shields.io/github/stars/${repo}?style=social&color=white)](https://github.com/${repo}/stargazers)`;
        const target = `](${e.url})**`;
        e.lines[0] = e.lines[0].replace(target, target + ` ${badge}`);
        console.log(`${e.name}: ${stars}`);
    }

    let addSortable = addEntries.filter(e => !e.raw);
    let addRaw = addEntries.filter(e => e.raw);

    for (let e of addSortable) {
        let [stars, repo] = await getStars(e.url);
        e.stars = stars;
        e.repo = repo;
        const badge = `[![Stars](https://img.shields.io/github/stars/${repo}?style=social&color=white)](https://github.com/${repo}/stargazers)`;
        const target = `](${e.url})**`;
        e.lines[0] = e.lines[0].replace(target, target + ` ${badge}`);
        console.log(`${e.name}: ${stars}`);
    }

    entries.sort((a, b) => b.stars - a.stars);
    addSortable.sort((a, b) => b.stars - a.stars);

    let newLines = lines.slice(0, openSourceStart + 1);
    newLines.push('');

    for (let e of entries) {
        newLines.push(...e.lines);
    }
    newLines.push(lines[additionalStart]);
    for (let e of addSortable) {
        newLines.push(...e.lines);
    }
    for (let e of addRaw) {
        newLines.push(e.raw);
    }

    for (let j = i; j < lines.length; j++) {
        newLines.push(lines[j]);
    }

    fs.writeFileSync('README.md', newLines.join('\n'));
    console.log("Done");
}

main();
