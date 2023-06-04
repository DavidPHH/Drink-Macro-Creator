# WoWhead Drink Table Scraper

To make the drink table easier to update, a quick and dirty scraper has been created to make the drink table lines from a WoWhead URL. This partially automates the process but still requires a significant amount of manual cleaning to extract all the necessary data. 

**Please note**: This does not allow for automatic sorting of the entries. The script is currently implemented to take a URL as an argument and send a properly formatted line to stdout.

## Usage

Here's a step-by-step guide to using this scraper:

1. **Access Wowhead**: Navigate to [Wowhead consumables](https://www.wowhead.com/items/consumables/type:5). At the time of writing, approximately 1800 items could be considered for our drinks table. Due to the limit of 1000 displayed results, you may need to filter results by each expansion. This can be done with the "Additional Filters" drop-down menu on the page.

2. **Copy IDs**: On the results table, there's an icon in the header for "Copy". Click that and select "ID". Your clipboard will now contain a comma-separated list of numbers.

3. **Paste IDs into editor**: Paste the list of numbers into Visual Studio Code (or any other editor of your choice). Repeat the above steps until you've got all the IDs.

4. **Create a list**: In VSCode, replace all instances of ", " with "\n" using a regex replace. This should give you a newline-delimited list. 

5. **Generate URLs**: Do another regex replace for "(^\d+)" to "https://www.wowhead.com/item=$1". This will give you a list of usable URLs. Save this file (for instance, as "urls.txt").

6. **Python Modules**: Ensure you have the "requests" and "BeautifulSoup" modules for python.

7. **Run the Script**: Read in the list of URLs and use it to output the results from `wowhead-drink-scraper.py` to a file. Use the following command on the system:

    ```bash
    while IFS= read -r url; do if [[ -n "$url" ]]; then python3 wowhead-drink-scraper.py $url | tee -a out.txt; fi; done < urls.txt
    ```

    This should result in a file ("out.txt") that contains lines ready to be added to our drinks table. Each line should follow this pattern:
    
    ```
    "id, -- name ... (mp/hp gain) [mp/s]"
    ```

8. **Clean Up**: Remove unwanted lines. For example, to remove any lines that don't mention mana: 

    ```bash
    sed -i '' '/mana/I!d' out.txt
    ```

    To delete any lines that are for buff food:

    ```bash
    sed -i '' '/well fed/Id' out.txt
    ```

    To delete conjured items:
    ```bash
    sed -i '' '/-- conjured/Id' out.txt
    ```

9. **Sort the List**: Sort the list as desired, for example, with the highest mp/s at the top.

10. **Remove Extra Text**: Remove spell text once we're done filtering and sorting (optional):

    ```bash
    sed -i '' 's/ ### .*$//' out.txt
    ```

    Remove the comma from the final entry in the list.

11. **Update the Lua File**: Optionally (but highly recommended), remove the current contents of the `local drinks = {}` table in `DrinkMacroCreator.lua`. Paste the contents of our "out.txt" (or whatever you called it) into the table. Save the file, and you should have a working update. Conjured food will be added in automatically from the `magefood` table and will still take precedence over regular consumables.
