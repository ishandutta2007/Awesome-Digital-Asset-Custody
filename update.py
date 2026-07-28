import urllib.request
import json
import re

with open('README.md', 'r', encoding='utf-8') as f:
    lines = f.readlines()

open_source_start = 0
for i, line in enumerate(lines):
    if line.startswith('## Open-Source GitHub Projects'):
        open_source_start = i
        break

def get_stars(url):
    # Extract owner/repo
    m = re.search(r'github\.com/([^/]+)/?([^/ \)]+)?', url)
    if not m:
        return 0, ''
    
    owner = m.group(1)
    repo = m.group(2)
    
    if not repo:
        # If it's an org, we will just query the user/org to see if we can find their main repo or just return 0
        api_url = f'https://api.github.com/users/{owner}/repos?sort=updated'
        try:
            req = urllib.request.Request(api_url)
            req.add_header('User-Agent', 'Mozilla/5.0')
            with urllib.request.urlopen(req) as response:
                data = json.loads(response.read().decode())
                if data:
                    # just take the first one or try to guess
                    best_repo = max(data, key=lambda x: x.get('stargazers_count', 0))
                    repo = best_repo['name']
                else:
                    return 0, f"{owner}"
        except:
            return 0, f"{owner}"

    api_url = f'https://api.github.com/repos/{owner}/{repo}'
    try:
        req = urllib.request.Request(api_url)
        req.add_header('User-Agent', 'Mozilla/5.0')
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            return data.get('stargazers_count', 0), f"{owner}/{repo}"
    except:
        return 0, f"{owner}/{repo}"

# We need to parse entries
# Format: - **[Name](url)** \n  Description
# Some might be single line: - **[Name](url)** — Description
# Let's extract them
entries = []
current_entry = None
additional_start = 0

i = open_source_start + 1
while i < len(lines):
    line = lines[i]
    if line.startswith('### Additional Strong Open-Source Options'):
        additional_start = i
        break
    
    m = re.match(r'^- \*\*\[([^\]]+)\]\(([^)]+)\)\*\*.*', line)
    if m:
        if current_entry:
            entries.append(current_entry)
        current_entry = {'name': m.group(1), 'url': m.group(2), 'lines': [line], 'stars': 0, 'badge_url': '', 'repo': ''}
    elif current_entry and line.strip():
        current_entry['lines'].append(line)
    elif current_entry and not line.strip():
        current_entry['lines'].append(line)
        entries.append(current_entry)
        current_entry = None
    i += 1

if current_entry:
    entries.append(current_entry)

# Parse additional options
add_entries = []
current_add = None

i = additional_start + 1
while i < len(lines):
    line = lines[i]
    if line.startswith('**Frameworks for building custom systems**') or line.startswith('## How to Contribute'):
        break
    
    m = re.match(r'^- \*\*\[([^\]]+)\]\(([^)]+)\)\*\*.*', line)
    if m:
        if current_add:
            add_entries.append(current_add)
        current_add = {'name': m.group(1), 'url': m.group(2), 'lines': [line], 'stars': 0, 'badge_url': '', 'repo': ''}
    elif line.startswith('- **MPC') or line.startswith('- **Hardware'):
        if current_add:
            add_entries.append(current_add)
            current_add = None
        add_entries.append({'raw': line})
    elif line.startswith('- Many community'):
        add_entries.append({'raw': line})
    elif current_add and line.strip():
        current_add['lines'].append(line)
    elif current_add and not line.strip():
        current_add['lines'].append(line)
        add_entries.append(current_add)
        current_add = None
    i += 1

if current_add:
    add_entries.append(current_add)

def process_entry(entry):
    if 'raw' in entry:
        return entry
    stars, repo = get_stars(entry['url'])
    entry['stars'] = stars
    entry['repo'] = repo
    badge = f"[![Stars](https://img.shields.io/github/stars/{repo}?style=social&color=white)](https://github.com/{repo}/stargazers)"
    
    # insert badge after the link
    # The format is `- **[Name](url)**`
    line0 = entry['lines'][0]
    # replace `](url)**` with `](url)** {badge}`
    entry['lines'][0] = re.sub(r'(\]\([^)]+\)\*\*)', r'\1 ' + badge.replace('[', '\\[').replace(']', '\\]'), line0) # wait, re.sub replacement should just be string
    
    # Actually just replace the exact match
    target = f"]({entry['url']})**"
    entry['lines'][0] = line0.replace(target, target + f" {badge}")
    return entry

print("Fetching stars...")
for e in entries:
    process_entry(e)
    print(f"{e['name']}: {e['stars']}")

for e in add_entries:
    if 'raw' not in e:
        process_entry(e)
        print(f"{e['name']}: {e['stars']}")

# Sort entries
entries.sort(key=lambda x: x['stars'], reverse=True)
add_sortable = [e for e in add_entries if 'raw' not in e]
add_raw = [e for e in add_entries if 'raw' in e]
add_sortable.sort(key=lambda x: x['stars'], reverse=True)

# Reconstruct lines
new_lines = lines[:open_source_start+1]
new_lines.append('\n')

for e in entries:
    new_lines.extend(e['lines'])

new_lines.append(lines[additional_start])
for e in add_sortable:
    new_lines.extend(e['lines'])
for e in add_raw:
    new_lines.append(e['raw'])

# Append the rest
rest_start = i
for j in range(rest_start, len(lines)):
    new_lines.append(lines[j])

with open('README.md', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print("Done")
