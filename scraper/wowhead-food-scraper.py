import re
import shutil
import sys
import time
import xml.etree.ElementTree as ET

import requests
from bs4 import BeautifulSoup as bs

### Begin configuration ###
DISCARD_BUFF_FOOD = True              # Discard buff food
DISCARD_NO_HEALTH = True              # Discard items with no health regen
SHORTEN = True                        # Shorten values: 1000 -> 1k
SHOW_PROGRESS = True                  # Show progress indicator
REPORT_FAILURES = True                # If we can't process an item, print to stderr at end of run
RATE_LIMIT = 0                        # Rate limit in seconds
BASE_URL = "https://www.wowhead.com/" # Base URL for item links
from search_items import SEARCH_ITEMS # Search items table
SEPARATOR_LEN = 3
DEBUG = False
### End configuration ###

def shorten(value):
    if value >= 1000:
        return f"{value // 1000}k"
    else:
        return value
    
class Item():
    def __init__(self, id, name, mana, health, duration, tooltip):
        self.id = id
        self.name = name
        self.mana = 0 if mana is None else mana
        self.health = 0 if health is None else health
        self.duration = duration
        self.tooltip = tooltip
        self.mps = self.mana / self.duration if self.mana > 0 and self.duration > 0 else 0
        self.hps = self.health / self.duration if self.health > 0 and self.duration > 0 else 0
        
    def __str__(self):
        # Special handling for mage food
        if self.mana == -1 and self.health == -1:
            return f"{str(self.id) + ',':<7} -- {self.name} {'.' * (SEPARATOR_LEN - len(self.name))} (100% MP/HP) [Mage Food]"
        # Health and Mana
        if self.mana is not None and self.health is not None:
            return f"{str(self.id) + ',':<7} -- {self.name} {'.' * (SEPARATOR_LEN - len(self.name))} ({shorten(self.mana) if SHORTEN else self.mana} MP, {shorten(self.health if SHORTEN else self.health)} HP) [{self.hps}]"
        # Health only
        if self.health is not None:
            return f"{str(self.id) + ',':<7} -- {self.name} {'.' * (SEPARATOR_LEN - len(self.name))} ({shorten(self.health) if SHORTEN else self.health} HP) [{self.hps}]"
        # Mana only
        if self.mana is not None:
            return f"{str(self.id) + ',':<7} -- {self.name} {'.' * (SEPARATOR_LEN - len(self.name))} ({shorten(self.mana) if SHORTEN else self.mana} MP) [{self.hps}]"


    __repr__ = __str__

final = [   # The beginnings of our output table, mage food (100% MP/HP) is static, stored at the top
    Item(113509, "Conjured Mana Bun", -1, -1, 20, ""),
    Item(80618, "Conjured Mana Fritter", -1, -1, 20, ""),
    Item(80610, "Conjured Mana Pudding", -1, -1, 20, ""),
    Item(65499, "Conjured Mana Cake", -1, -1, 20, ""),
    Item(43523, "Conjured Mana Strudel", -1, -1, 20, ""),
    Item(43518, "Conjured Mana Pie", -1, -1, 20, ""),
    Item(65517, "Conjured Mana Lollipop", -1, -1, 20, ""),
    Item(65516, "Conjured Mana Cupcake", -1, -1, 20, ""),
    Item(65515, "Conjured Mana Brownie", -1, -1, 20, ""),
    Item(65500, "Conjured Mana Cookie", -1, -1, 20, "")

]

presort = [] # Holding table for items as they're processed, not yet sorted
error = [] # Table for holding unrecognized items

# This all involves making some assumptions about how the data is returned to us
# health and mana should be either None or a string like (1 / 1 * 1)
# duration should be either None or a string like 1
# This is all very dirty a does not consider language differences and will break if the tooltip changes
pattern_health = r"\(\d+ (/|\*) \d+ (/|\*) (\d+)\) health"
pattern_mana = r"\(\d+ (/|\*) \d+ (/|\*) (\d+)\) mana"

start_time = time.time()
for index, itemid in enumerate(SEARCH_ITEMS):
    if SHOW_PROGRESS:
        average = (time.time() - start_time) / (index + 1)
        remaining = average * (len(SEARCH_ITEMS) - index - 1)
        remaining = f"{remaining // 60:.0f}:{remaining % 60:02.0f}"
        print(' ' * shutil.get_terminal_size().columns, end='\r', file=sys.stderr)
        print(f"[{(index+1)/len(SEARCH_ITEMS)*100:6.2f}%] ({remaining} remaining): {itemid}", end='\r', file=sys.stderr)
    res = requests.get(f"{BASE_URL}item={itemid}&xml").content
    try:
        root = ET.fromstring(res)
        soup = bs(root.find("./item/htmlTooltip").text, 'html.parser')
        name = root.find("./item/name").text
        tooltip = soup.find_all('table')[1].find('span').text
    except:
        print(f"Error parsing item {itemid}", end='\r' if SHOW_PROGRESS else '\n', file=sys.stderr)
        error.append({'res': res, 'itemid': itemid})
        continue
    
    if DEBUG: print({k: v for k, v in locals().items() if k in ['name', 'itemid', 'tooltip']}, file=sys.stderr)

    health_match = re.search(pattern_health, tooltip)
    mana_match = re.search(pattern_mana, tooltip)
    health = health_match.group(0) if health_match is not None else None
    mana = mana_match.group(0) if mana_match is not None else None
    duration = 0 # Intial value, see below
    # Most items appear to have a pattern of (resource-per-tick / tick-interval * duration)
    # I've only seen a few items that follow (a / b or a * b), not sure yet the best way to handle these
    if health and re.match(pattern_health, health) is not None:
        a, b, c = map(int, re.findall(r"\d+", health))
        if re.match(r"^\(\d+ \* \d+ / \d+", health) is not None:
            health = int(a * b / c)
            duration = c if c > duration else duration
        elif re.match(r"^\(\d+ / \d+ \* \d+", health) is not None:
            health = int(a / b * c)
            duration = c if c > duration else duration
        elif re.match(r"^\(\d+ / \d+", health) is not None:
            health = int(a / b)
            duration = b if b > duration else duration
        elif re.match(r"^\(\d+ \* \d+", health) is not None:
            health = int(a * b)
            duration = b if b > duration else duration
        else:
            print("Unrecognized health format")
            exit(1)
    
    if mana and re.match(pattern_mana, mana) is not None:
        a, b, c = map(int, re.findall(r"\d+", mana))
        if re.match(r"^\(\d+ \* \d+ / \d+", mana) is not None:
            mana = int(a * b / c)
            duration = c if c > duration else duration
        elif re.match(r"^\(\d+ / \d+ \* \d+", mana) is not None:
            mana = int(a / b * c)
            duration = c if c > duration else duration
        elif re.match(r"^\(\d+ / \d+", mana) is not None:
            mana = int(a / b)
            duration = b if b > duration else duration
        elif re.match(r"^\(\d+ \* \d+", mana) is not None:
            mana = int(a * b)
            duration = b if b > duration else duration
        else:
            print("Unrecognized mana format")
            exit(1)

    if DISCARD_NO_HEALTH and health is None:
        time.sleep(RATE_LIMIT)
    elif DISCARD_BUFF_FOOD and 'well fed' in tooltip.lower():
        time.sleep(RATE_LIMIT)
    elif re.match('^conjured', name, re.IGNORECASE) is not None:
        time.sleep(RATE_LIMIT)
    else:
        presort.append(Item(itemid, name, mana, health, duration, tooltip))
        if DEBUG: print(presort[-1], file=sys.stderr)
        time.sleep(RATE_LIMIT)

# Prepare for presentation
presort.sort(key=lambda x: (x.hps, x.health, x.mana, x.name), reverse=True)
final.extend(presort)
SEPARATOR_LEN = max([len(str(item.name)) for item in final]) + 3

for index, line in enumerate(final):
    if index + 1 < len(final):
        print(line)
    else:
        print(re.sub(r",", " ", str(line), 1))


if error and REPORT_FAILURES:
    print("\n\nErrors encountered while parsing:", file=sys.stderr)
    for index, item in enumerate(error):
        print(f"{error[index]['itemid']}: {error[index]['res']}\n", file=sys.stderr)