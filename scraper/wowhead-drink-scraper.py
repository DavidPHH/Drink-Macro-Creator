import requests
from bs4 import BeautifulSoup as bs
import sys
import argparse
import re

DEBUG = False

def shorten(value):
    if value >= 1000:
        return f"{value // 1000}k"
    else:
        return value
    
parser = argparse.ArgumentParser()
parser.add_argument('url')
args = parser.parse_args()

url = args.url
if re.match(r"https://www\.wowhead\.com/item=\d+/[\w-]+", url) is not None:
    url = f"{'/'.join(url.split('/')[:-1])}"
elif re.match(r"https://www\.wowhead\.com/item=\d+", url) is not None:
    pass
else:
    print("Unrecognized URL")
    exit(1)

soup = bs(requests.get(url).content, 'html.parser')
name = soup.find('h1', class_='heading-size-1').text
spell = soup.find('a', href=re.compile(r"^/spell=\d+")).text
itemid = re.findall(r"\d+", url)[0]

# This all involves making some assumptions about how the data is returned to us
# health and mana should be either None or a string like (1 / 1 * 1)
# duration should be either None or a string like 1
# This is all very dirty a does not consider language differences and will break if the tooltip changes
pattern_health = r"\(\d+ (/|\*) \d+ (/|\*) (\d+)\) health"
pattern_mana = r"\(\d+ (/|\*) \d+ (/|\*) (\d+)\) mana"
pattern_duration = r"(\d+) sec"
if DEBUG: print(f"Processing itemid {itemid} ({name}): {spell}", out=sys.stderr)
health_match = re.search(pattern_health, spell)
mana_match = re.search(pattern_mana, spell)
duration_match = re.search(pattern_duration, spell)
health = health_match.group(0) if health_match is not None else None
mana = mana_match.group(0) if mana_match is not None else None
duration = duration_match.group(0) if duration_match is not None else None
if health and re.match(pattern_health, health) is not None:
    if DEBUG: print(f"health match: {health}", out=sys.stderr)
    a, b, c = map(int, re.findall(r"\d+", health))
    if re.match(r"^\(\d+ \* \d+ / \d+", health) is not None:
        health = int(a * b / c)
    elif re.match(r"^\(\d+ / \d+ \* \d+", health) is not None:
        health = int(a / b * c)
    elif re.match(r"^\(\d+ / \d+", health) is not None:
        health = int(a / b)
    elif re.match(r"^\(\d+ \* \d+", health) is not None:
        health = int(a * b)
    else:
        print("Unrecognized health format")
        exit(1)
if mana and re.match(pattern_mana, mana) is not None:
    if DEBUG: print(f"mana match: {mana}", out=sys.stderr)
    a, b, c = map(int, re.findall(r"\d+", mana))
    if re.match(r"^\(\d+ \* \d+ / \d+", mana) is not None:
        mana = int(a * b / c)
    elif re.match(r"^\(\d+ / \d+ \* \d+", mana) is not None:
        mana = int(a / b * c)
    elif re.match(r"^\(\d+ / \d+", mana) is not None:
        mana = int(a / b)
    elif re.match(r"^\(\d+ \* \d+", mana) is not None:
        mana = int(a * b)
    else:
        print("Unrecognized mana format")
        exit(1)
if duration and re.match(pattern_duration, duration) is not None:
    if DEBUG: print(f"duration match: {duration}", out=sys.stderr)
    duration = int(re.findall(r"\d+", duration)[0])

#Format our output to omit None values
if health is not None and mana is not None: # Health and mana
    out = f"{itemid}, -- {name} ... ({shorten(mana)} MP, {shorten(health)} HP) [{int(mana / duration)}] ### {spell}"
elif health is not None: # Health only
    out = f"{itemid}, -- {name} ... ({shorten(health)} HP) [0] ### {spell}"
elif mana is not None: # Mana only
    out = f"{itemid}, -- {name} ... ({shorten(mana)} MP) [{int(mana / duration)}] ### {spell}"
else: # No health or mana
    out = f"{itemid}, -- {name} ### {spell}"

print(out)