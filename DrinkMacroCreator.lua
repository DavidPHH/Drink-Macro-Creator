local frame = CreateFrame("Frame", nil, UIParent);
local inWorld = false;
local bestDrink = nil;
frame:RegisterEvent("BAG_UPDATE");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_REGEN_ENABLED");

--[[
Drinks Table (haha) Notes:

* This works like a preference list. When the function is called, it runs down the list and stops and the first applicable item it finds.
  * If you want to give preference to a particular item over another, put it higher in the list.
* Note that most (all?) newer consumables are over 20s, so older or very low level items may have a "/ <n>s" note. They may look like they give more, but it could be less per tick.
* You may want to avoid using certain items, e.g.: if they provide a well-fed buff, or if you need them for crafting. Prefix these lines with -- to comment them out.
--]]

-- Mage Food, probably don't need to update more often than every expansion, but always use them first
local magefood = {
    -- itemID, -- name ..................................... (Mana / HP Gain) [Avg Mana/Second]
    113509, -- Conjured Mana Bun ........................... (100% MP, 100% HP)
    80618,  -- Conjured Mana Fritter ....................... (100% MP, 100% HP)
    80610,  -- Conjured Mana Pudding ....................... (100% MP, 100% HP)
    65499,  -- Conjured Mana Cake .......................... (100% MP, 100% HP)
    43523,  -- Conjured Mana Strudel ....................... (100% MP, 100% HP)
    43518,  -- Conjured Mana Pie ........................... (100% MP, 100% HP)
    65517,  -- Conjured Mana Lollipop ...................... (100% MP, 100% HP)
    65516,  -- Conjured Mana Cupcake ....................... (100% MP, 100% HP)
    65515,  -- Conjured Mana Brownie ....................... (100% MP, 100% HP)
    65500,  -- Conjured Mana Cookie ........................ (100% MP, 100% HP)
}

-- Other drinks, may need to update with new patches
local drinks = {
    -- itemID, -- name ..................................... (Mana / HP Gain) [Avg Mana/Second]
    197762, -- Sweet and Sour Clam Chowder ................. (285k MP, 214k HP) [14285]
    197763, -- Breakfast of Draconic Champions ............. (285k MP, 214k HP) [14285]
    197771, -- Delicious Dragon Spittle .................... (285k MP) [14285]
    204729, -- Freshly Squeezed Mosswater .................. (250k MP) [12500]
    205794, -- Beetle Juice ................................ (250k MP) [12500]
    202315, -- Frozen Solid Tea ............................ (250k MP) [12500]
    201697, -- Coldarra Coldbrew ........................... (250k MP) [12500]
    201698, -- Black Dragon Red Eye ........................ (250k MP) [12500]
    201721, -- Life Fire Latte ............................. (250k MP) [12500]
    201725, -- Flappuccino ................................. (250k MP) [12500]
    75028, -- Stormwind Surprise ........................... (240k MP) [12000]
    201046, -- Dreamwarding Dripbrew ....................... (250k MP) [12500]
    197856, -- Cup o' Wakeup ............................... (250k MP) [12500]
    194683, -- Buttermilk .................................. (250k MP) [12500]
    194684, -- Azure Leywine ............................... (250k MP) [12500]
    194685, -- Dragonspring Water .......................... (250k MP) [12500]
    195464, -- Sweetened Broadhoof Milk .................... (250k MP) [12500]
    21215, -- Graccu's Mince Meat Fruitcake ................ (240k MP, 180k HP) [12000]
    197770, -- Zesty Water ................................. (180k MP) [9000]
    20516, -- Bobbing Apple ................................ (180k MP, 135k HP) [7200]
    201820, -- Silithus Swiss .............................. (80k MP, 60k HP) [4000]
    204235, -- Kaldorei Fruitcake .......................... (80k MP, 60k HP) [4000]
    204790, -- Strong Sniffin' Soup for Niffen ............. (80k MP, 60k HP) [4000]
    205690, -- Barter-B-Q .................................. (80k MP, 60k HP) [4000]
    205692, -- Stellaviatori Soup .......................... (80k MP, 60k HP) [4000]
    201413, -- Eternity-Infused Burrata .................... (80k MP, 60k HP) [4000]
    201419, -- Apexis Asiago ............................... (80k MP, 60k HP) [4000]
    201420, -- Gnolan's House Special ...................... (80k MP, 60k HP) [4000]
    200871, -- Steamed Scarab Steak ........................ (80k MP, 60k HP) [4000]
    198356, -- Honey Snack ................................. (80k MP, 60k HP) [4000]
    198441, -- Thunderspine Tenders ........................ (80k MP, 60k HP) [4000]
    197854, -- Enchanted Argali Tenderloin ................. (80k MP, 60k HP) [4000]
    197847, -- Gorloc Fin Soup ............................. (80k MP, 60k HP) [4000]
    197848, -- Hearty Squash Stew .......................... (80k MP, 60k HP) [4000]
    195465, -- Stormwing Egg Breakfast ..................... (80k MP, 60k HP) [4000]
    195466, -- Frenzy and Chips ............................ (80k MP, 60k HP) [4000]
    196582, -- Syrup-Drenched Toast ........................ (80k MP, 60k HP) [4000]
    194680, -- Jerky Surprise .............................. (80k MP, 60k HP) [4000]
    194681, -- Sugarwing Cupcake ........................... (80k MP, 60k HP) [4000]
    194682, -- Mother's Gift ............................... (80k MP, 60k HP) [4000]
    196584, -- Acorn Milk .................................. (75k MP) [3750]
    200305, -- Dracthyr Water Rations ...................... (75k MP) [3750]
    197849, -- Ancient Firewine ............................ (75k MP) [3750]
    197857, -- Swog Slurp .................................. (75k MP) [3750]
    201813, -- Spoiled Firewine ............................ (75k MP) [3750]
    194690, -- Horn o' Mead ................................ (75k MP) [3750]
    194692, -- Distilled Fish Juice ........................ (75k MP) [3750]
    195459, -- Argali Milk ................................. (75k MP) [3750]
    195460, -- Fermented Musken Milk ....................... (75k MP) [3750]
    190936, -- Restorative Flow ............................ (53k MP) [2666]
    186704, -- Twilight Tea ................................ (53k MP) [2666]
    190880, -- Catalyzed Apple Pie ......................... (53k MP, 40k HP) [2666]
    190881, -- Circle of Subsistence ....................... (53k MP, 40k HP) [2666]
    180011, -- Stale Brewfest Pretzel ...................... (53k MP, 40k HP) [2666]
    174283, -- Stygian Stew ................................ (53k MP, 40k HP) [2666]
    174284, -- Empyrean Fruit Salad ........................ (53k MP, 40k HP) [2666]
    177041, -- Sunwarmed Xyfias ............................ (53k MP, 40k HP) [2666]
    177042, -- Five-Chime Batzos ........................... (53k MP, 40k HP) [2666]
    173859, -- Ethereal Pomegranate ........................ (53k MP, 40k HP) [2666]
    172047, -- Candied Amberjack Cakes ..................... (53k MP, 40k HP) [2666]
    177040, -- Ambroria Dew ................................ (53k MP) [2666]
    178539, -- Lukewarm Tauralus Milk ...................... (53k MP) [2666]
    178535, -- Suspicious Slime Shot ....................... (53k MP) [2666]
    178545, -- Bone Apple Tea .............................. (53k MP) [2666]
    179992, -- Shadespring Water ........................... (53k MP) [2666]
    178217, -- Azurebloom Tea .............................. (53k MP) [2666]
    187911, -- Sable "Soup" ................................ (37k MP, 28k HP) [1875]
    184201, -- Slushy Water ................................ (37k MP) [1875]
    178542, -- Cranial Concoction .......................... (37k MP) [1875]
    178534, -- Corpini Slurry .............................. (37k MP) [1875]
    174281, -- Purified Skyspring Water .................... (37k MP) [1875]
    173762, -- Flask of Ardendew ........................... (37k MP) [1875]
    179993, -- Infused Muck Water .......................... (37k MP) [1875]
    178538, -- Beetle Juice ................................ (37k MP) [1875]
    180006, -- Warm Brewfest Pretzel ....................... (25k MP, 8k HP) [1280]
    180054, -- Lunar Dumplings ............................. (25k MP, 8k HP) [1280]
    133980, -- Murky Cavewater ............................. (24k MP) [1200]
    163692, -- Scroll of Subsistence ....................... (18k MP, 30k HP) [900]
    154891, -- Seasoned Loins .............................. (18k MP, 30k HP) [900]
    172046, -- Biscuits and Caviar ......................... (16k MP, 20k HP) [800]
    163784, -- Seafoam Coconut Water ....................... (18k MP) [900]
    163785, -- Canteen of Rivermarsh Rainwater ............. (18k MP) [900]
    163786, -- Filtered Gloomwater ......................... (18k MP) [900]
    162570, -- Pricklevine Juice ........................... (18k MP) [900]
    159867, -- Rockskip Mineral Water ...................... (18k MP) [900]
    169949, -- Bioluminescent Ocean Punch .................. (18k MP) [900]
    169952, -- Sea Salt Java ............................... (18k MP) [900]
    169954, -- Steeped Kelp Tea ............................ (18k MP) [900]
    152717, -- Azuremyst Water Flask ....................... (15k MP) [750]
    138982, -- Pail of Warm Milk ........................... (15k MP) [750]
    140629, -- Bottled Maelstrom ........................... (15k MP) [750]
    128850, -- Chilled Conjured Water ...................... (15k MP) [750]
    139347, -- Underjelly .................................. (15k MP) [750]
    140204, -- 'Bottled' Ley-Enriched Water ................ (15k MP) [750]
    140265, -- Legendermainy Light Roast ................... (15k MP) [750]
    140266, -- Kafa Kicker ................................. (15k MP) [750]
    138292, -- Ley-Enriched Water .......................... (15k MP) [750]
    140269, -- Iced Highmountain Refresher ................. (15k MP) [750]
    140272, -- Suramar Spiced Tea .......................... (15k MP) [750]
    88578, -- Cup of Kafa .................................. (15k MP) [750]
    59229, -- Murky Water .................................. (21k MP) [708]
    43236, -- Star's Sorrow ................................ (21k MP) [708]
    33445, -- Honeymint Tea ................................ (21k MP) [708]
    41731, -- Yeti Milk .................................... (21k MP) [708]
    42777, -- Crusader's Waterskin ......................... (21k MP) [708]
    159868, -- Free-Range Goat's Milk ...................... (12k MP) [600]
    162547, -- Raw Nazmani Mineral Water ................... (12k MP) [600]
    162569, -- Sun-Parched Waterskin ....................... (12k MP) [600]
    163101, -- Drustvar Dark Roast ......................... (12k MP) [600]
    163102, -- Starhook Special Blend ...................... (12k MP) [600]
    163104, -- Sailor's Choice Coffee ...................... (12k MP) [600]
    163783, -- Mount Mugamba Spring Water .................. (12k MP) [600]
    169119, -- Enhanced Water .............................. (12k MP) [600]
    169120, -- Enhancement-Free Water ...................... (12k MP) [600]
    169948, -- Filtered Zanj'ir Water ...................... (12k MP) [600]
    133575, -- Dried Mackerel Strips ....................... (10k MP, 20k HP) [500]
    138983, -- Kurd's Soft Serve ........................... (10k MP, 20k HP) [500]
    138986, -- Kurdos Yogurt ............................... (10k MP, 20k HP) [500]
    141215, -- Arcberry Juice .............................. (10k MP) [500]
    140298, -- Mananelle's Sparkling Cider ................. (10k MP) [500]
    158926, -- Fried Turtle Bits ........................... (9k MP, 15k HP) [450]
    154889, -- Grilled Catfish ............................. (9k MP, 15k HP) [450]
    141527, -- Slightly Rusted Canteen ..................... (7k MP) [350]
    138975, -- Highmountain Runoff ......................... (7k MP) [350]
    139346, -- Thuni's Patented Drinking Fluid ............. (7k MP) [350]
    140203, -- 'Natural' Highmountain Spring Water ......... (7k MP) [350]
    117452, -- Gorgrond Mineral Water ...................... (7k MP) [350]
    117475, -- Clefthoof Milk .............................. (7k MP) [350]
    118424, -- Blind Palefish .............................. (7k MP) [350]
    128385, -- Elemental-Distilled Water ................... (7k MP) [350]
    128853, -- Highmountain Spring Water ................... (7k MP) [350]
    130259, -- Ancient Bandana ............................. (7k MP) [350]
    133586, -- Illidari Waterskin .......................... (7k MP) [350]
    111455, -- Saberfish Broth ............................. (7k MP) [350]
    111544, -- Frostboar Jerky ............................. (7k MP) [350]
    68140, -- Invigorating Pineapple Punch ................. (7k MP) [250]
    58257, -- Highland Spring Water ........................ (7k MP) [250]
    74822, -- Sasparilla Sinker ............................ (7k MP) [250]
    63251, -- Mei's Masterful Brew ......................... (7k MP) [250]
    112449, -- Iron Horde Rations .......................... (5k MP) [250]
    104348, -- Timeless Tea ................................ (5k MP) [250]
    88532, -- Lotus Water .................................. (5k MP) [250]
    81923, -- Cobo Cola .................................... (5k MP) [250]
    74636, -- Golden Carp Consomme ......................... (5k MP) [250]
    130192, -- Potato Axebeak Stew ......................... (4k MP, 9k HP) [210]
    116120, -- Tasty Talador Lunch ......................... (4k MP) [210]
    98111, -- K.R.E. ....................................... (4k MP) [203]
    98118, -- Scorpion Crunchies ........................... (4k MP) [203]
    58256, -- Sparkling Oasis Water ........................ (6k MP) [203]
    59029, -- Greasy Whale Milk ............................ (6k MP) [203]
    59230, -- Fungus Squeezings ............................ (6k MP) [203]
    86026, -- Perfectly Cooked Instant Noodles ............. (4k MP) [203]
    75026, -- Ginseng Tea .................................. (4k MP) [203]
    39520, -- Kungaloosh ................................... (5450 MP) [182]
    28399, -- Filtered Draenic Water ....................... (5k MP) [168]
    29454, -- Silverwine ................................... (5k MP) [168]
    32722, -- Enriched Terocone Juice ...................... (5k MP) [168]
    38430, -- Blackrock Mineral Water ...................... (5k MP) [168]
    44941, -- Fresh-Squeezed Limeade ....................... (5k MP) [167]
    43086, -- Fresh Apple Juice ............................ (5k MP) [167]
    33444, -- Pungent Seal Whey ............................ (5k MP) [167]
    38698, -- Bitter Plasma ................................ (5k MP) [167]
    140340, -- Bottled - Carbonated Water .................. (3k MP) [166]
    81924, -- Carbonated Water ............................. (3k MP) [166]
    85501, -- Viseclaw Soup ................................ (3k MP) [166]
    34759, -- Smoked Rockfin ............................... (4k MP) [142]
    34760, -- Grilled Bonescale ............................ (4k MP) [142]
    34761, -- Sauteed Goby ................................. (4k MP) [142]
    62675, -- Starfire Espresso ............................ (3k MP) [128]
    27860, -- Purified Draenic Water ....................... (2k MP) [94]
    29395, -- Ethermead .................................... (2k MP) [94]
    29401, -- Sparkling Southshore Cider ................... (2k MP) [94]
    30457, -- Gilneas Sparkling Water ...................... (2k MP) [94]
    40357, -- Grizzleberry Juice ........................... (2k MP) [94]
    44750, -- Mountain Water ............................... (2k MP) [94]
    34780, -- Naaru Ration ................................. (2k MP) [94]
    35954, -- Sweetened Goat's Milk ........................ (2k MP) [94]
    37253, -- Frostberry Juice ............................. (2k MP) [94]
    32453, -- Star's Tears ................................. (2k MP) [94]
    32668, -- Dos Ogris .................................... (2k MP) [94]
    33042, -- Black Coffee ................................. (2k MP) [94]
    38431, -- Blackrock Fortified Water .................... (2k MP) [94]
    61382, -- Garr's Limeade ............................... (2k MP) [80]
    32455, -- Star's Lament ................................ (2k MP) [72]
    18300, -- Hyjal Nectar ................................. (2k MP) [72]
    33053, -- Hot Buttered Trout ........................... (1574 MP, 1638HP) [52]
    38429, -- Blackrock Spring Water ....................... (1k MP) [45]
    8766, -- Morning Glory Dew ............................. (1k MP) [45]
    63530, -- Refreshing Pineapple Punch ................... (504 MP) [24]
    90659, -- Jasmine Tea .................................. (504 MP) [24]
    1179, -- Ice Cold Milk ................................. (504 MP) [24]
    17404, -- Blended Bean Brew ............................ (504 MP) [24]
    49601, -- Volcanic Spring Water ........................ (504 MP) [24]
    49602, -- Earl Black Tea ............................... (504 MP) [24]
    1645, -- Moonberry Juice ............................... (588 MP) [19]
    63023, -- Sweet Tea .................................... (588 MP) [19]
    19300, -- Bottled Winterspring Water ................... (588 MP) [19]
    1708, -- Sweet Nectar .................................. (324 MP) [12]
    4791, -- Enchanted Water ............................... (324 MP) [12]
    10841, -- Goldthorn Tea ................................ (324 MP) [12]
    1205, -- Melon Juice ................................... (288 MP) [12]
    9451, -- Bubbling Water ................................ (288 MP) [12]
    19299, -- Fizzy Faire Drink ............................ (288 MP) [12]
    90660, -- Black Tea .................................... (288 MP) [12]
    155909, -- Bottled Stillwater .......................... (288 MP) [12]
    1401, -- Riverpaw Tea Leaf ............................. (115 MP, 60 HP) [12]
    159, -- Refreshing Spring Water ........................ (180 MP) [10]
    49254, -- Tarp Collected Dew ........................... (180 MP) [10]
    60269 -- Well Water ................................... (180 MP) [10]
}

-- Merge the two tables
table.move(drinks, 1, #drinks, #magefood + 1, magefood)
for i = 1, #magefood do
    drinks[i] = magefood[i]
end

local function SetBestDrink()
    lvl = UnitLevel("player");
    for _, drink in pairs(drinks) do
        item = GetItemInfo(drink);
        itemLvl = select(5, GetItemInfo(drink));
        itemCount = GetItemCount(drink);
        if (item ~= nil and itemCount ~= nil and itemLvl ~= nil) then
            if (itemCount > 0) and (itemLvl <= lvl) then 
                bestDrink = item;
                return;
            end
        end
    end
end

local function MakeDrinkMacro()
    local oldBest = bestDrink; -- Avoids unecessary edits
    SetBestDrink();
    local iMacro = GetMacroIndexByName("DrinkMacro");
    if (iMacro == 0 and bestDrink ~= nil) then
        CreateMacro("DrinkMacro", "INV_MISC_QUESTIONMARK", "#showtooltip\n/use "..bestDrink);
    elseif (oldBest ~= bestDrink) then
        EditMacro(iMacro, "DrinkMacro", "INV_MISC_QUESTIONMARK", "#showtooltip\n/use "..bestDrink);
    end
end

local function eventHandler(self, event, ...)
    if (InCombatLockdown()) then
        return
    end
    -- If not in combat, make a macro or edit existing one
    if (event == "PLAYER_ENTERING_WORLD") then
        inWorld = true;
        MakeDrinkMacro();
    end
    if (event == "BAG_UPDATE" and inWorld) then
        MakeDrinkMacro();
    end
    if (event == "PLAYER_REGEN_ENABLED" and inWorld) then -- Exiting combat
        MakeDrinkMacro();
    end
end

frame:SetScript("OnEvent", eventHandler);
