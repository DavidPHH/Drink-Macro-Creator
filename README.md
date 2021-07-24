
## Simple light weight addon, no config required. Just does what it says. 
Made for shadowlands, won't work in classic. If anyone wants to make it work with classic feel free to open a pull request.

 ## Q/A:
 
 **What does it do?**
This addon will make a macro under "General Macros" called "Drink Macro". This macro will just be two lines:

	#showtooltip
	/use <drink>
"*\<drink>*" will be whatever food or drink you have in your bags that gives the most mana, mage food being highest priority.

**Why?**

I often found myself replacing the drink in my action bar with mage food then replacing back when that disapeared. Also frequently had multiple forms of drinks in my bags, which sometimes one ran out before the others, forcing me to replace again. 

**What's the difference between this and similar addons?**

This addon has no settings or anything to configure, that might be a drawback or a plus depending on your needs. I made itafter trying all the other similar addons, some of which kept bugging out on me, some who didn't work at all, and some which didn't have the newest shadowlands drinks.
In the end it was easier to make my own bugfree one that suits my needs and I'm sharing here in case anyone else is in the same boat as me.

**You keep mentioning drinks, does it work with food too?**

Mostly. The high level food has both mp and health and are priod in the addon, so if you're max level and not a mana user and also want some macro that auto changes mage food / normal food this will work for you. I'm willing to add low level / other hp-only foods as well if someone makes a pull request with a food list akin to the drink list in the main lua file.
