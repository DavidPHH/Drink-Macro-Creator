local frame = CreateFrame("Frame", nil, UIParent);
local inWorld = false;
local bestDrink = nil;
frame:RegisterEvent("BAG_UPDATE");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_REGEN_ENABLED");

---@class ns
local ns = select(2, ...)
local drinks = ns.drinks

local function SetBestDrink()
    local lvl = UnitLevel("player");
    for _, drink in pairs(drinks) do
        local item = C_Item.GetItemInfo(drink);
        local itemLvl = select(5, C_Item.GetItemInfo(drink));
        local itemCount = C_Item.GetItemCount(drink);
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
        CreateMacro("DrinkMacro", "INV_MISC_QUESTIONMARK", "#showtooltip\n/use " .. bestDrink);
    elseif (oldBest ~= bestDrink) then
        EditMacro(iMacro, "DrinkMacro", "INV_MISC_QUESTIONMARK", "#showtooltip\n/use " .. bestDrink);
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
