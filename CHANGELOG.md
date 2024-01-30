# Changelog

## Version 1.4 (2024/01/29)
* Updated TOC for 10.2.5
* Script will now create two macros: one for food and one for drink.
  * Macro names have been changed to `dmcDrink` and `dmcFood` to make them easier to spot next to each other in the macro window. Your existing macros and keybinds will not be removed; you'll need to place the new ones on the hotkey bar.
* Scraper
  * Split item ID table into its own file and cleaned it up a bit.
  * Created new food scraper based on the drink scraper. Both use the new list.
    * Will probably eventually merge the two scrapers into one that just puts out both lists. This works for now though.
  * Item list consists of three parts now: A base item list (which is intended to be add-only), an ignore list (for bugged, miscategorized, or otherwise unwanted items), and the search items list, generated from the sets of the first two lists.
* Updated tables with fresh-scraped datas. Yum.

## Version 1.3.2 (2023/11/28)
* Updated TOC for 10.2.0
* Added drinks for 10.1.5-10.2.0 to scraper
* Updated drinks table

## Version 1.3.1 (2023/07/12)
* Updated TOC for 10.1.5

## Version 1.3.0 (2023/06/04)
* Recreated drinks table to have updated values. There were quite a few since last update.
* Created a scraper build the table for drinks automatically. See `scraper/readme.md` for more details

## Version 1.2.1 (2023/06/02)
* Updated TOC for 10.1

## Version 1.2.0 (2022/10/31)
* Updated the drinks table to more clearly show what each entry corresponds to, as well as updating the values to match their current MP/HP gains (as of 10.0)
* Removed 115351, "Rylak Claws" (5k HP) -- No MP gain
* Re-sorted the drinks table with the following priority:
    1. Average mana gain per second
    2. Mana + Health regen items
    3. Mana only regen items
    4. Mana + Health regen items with a Well Fed buff
    5. Mana only regen items with a Well Fed buff
    6. Alphabetical sort
* Added CHANGELOG.md
* Added a bit fo README.md

## Version 1.1.1 (2022/10/30)
* Added Dragonflight consumables (from Wowhead as of 2022/10/30) ([Search query](https://www.wowhead.com/items/consumables/food-and-drinks?filter=166;10;0))