## Simple light weight addon, no config required. Just does what it says.

Made for retail, probably won't work in classic.

## Q/A:

**How to use?**

Type /m then find and drag the macro called "Drink Macro" onto your action bars. That's all, this macro will be kept up to date and work on all your characters.

**What does it do?**

This addon will make a macro under "General Macros" called "Drink Macro". This macro will just be two lines:

    #showtooltip
    /use <drink>

"_\<drink>_" will be whatever food or drink you have in your bags that gives the most mana, mage food being highest priority.

**Why?**

I often found myself replacing the drink in my action bar with mage food then replacing back when that disappeared. Also frequently had multiple forms of drinks in my bags, which sometimes one ran out before the others, forcing me to replace again.

**What's the difference between this and similar addons?**

This addon has no settings or anything to configure, that might be a drawback or a plus depending on your needs. I made it after trying all the other similar addons, some of which kept bugging out on me, some who didn't work at all, and some which didn't have the newest drinks.
In the end it was easier to make my own bug-free one that suits my needs and I'm sharing here in case anyone else is in the same boat as me.

**Okay, you said "no config required" but I'm a control freak and really want to configure _something_.**

If you want to get your hands in the mix, you can adjust drink/food priorities or add new consumables in the table called **drinks** in **`DrinkPriorities.lua`**

**You keep mentioning drinks, does it work with food too?**

Mostly. High level food with both mp and health and are prioritized in the addon, so if you're max level and not a mana user and also want some macro that auto changes mage food / normal food this will work for you. If it doesn't you can manually add your food to **`DrinkPriorities.lua`** or open a PR.
