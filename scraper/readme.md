# WoWhead Drink Table Scraper

## Usage

Here's a step-by-step guide to using this scraper:

 1. **Find IDs**: Navigate to [Wowhead consumables](https://www.wowhead.com/items/consumables/type:5). At the time of writing, approximately 1800 items could be considered for our drinks table. Due to the limit of 1000 displayed results, you may need to filter results by each expansion. This can be done with the "Additional Filters" drop-down menu on the page.

2. **Copy IDs**: On the results table, there's an icon in the header for "Copy". Click that and select "ID". Your clipboard will now contain a comma-separated list of numbers.

3. **Update SEARCH_ITEMS**: Near the top of `wowhead-drink-scraper.py` you'll find a configuration section. In there is a list called `SEARCH_ITEMS`. Copy any IDs you want to include in the table here. Retrieve more IDs per Step 2 until you have all the expansions, or whatever subset you want to process.

4. **Python Modules**: Ensure you have the "requests" and "BeautifulSoup" modules for python.

5. **Run the Script**: Yep. `python3 wowhead-drink-scraper.py`. No arguments. Config was all done in the script body.

6. **Update the Lua File**: Optionally (but highly recommended), remove the current contents of the `local drinks = {}` table in `DrinkMacroCreator.lua`. Paste the table entries produced by the scriptinto the table. Save the file, and you should have a working update.

## Known issues:
* The time remaining indicator sometimes shows stupid values like 1:60 instead of 1:00.