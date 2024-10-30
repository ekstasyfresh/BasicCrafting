--[[
    TODO: clean code up a lot. so much repeated code.
--]]

-- XP Functions
function Give1TailoringXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Tailoring, 1);
end

function Give2TailoringXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Tailoring, 2);
end

function Give10TailoringXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Tailoring, 10);
end

function Give25TailoringXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Tailoring, 25);
end

-- Chipped Stone Logic
function AddChippedStone_OnCreate(items, result, player, selectedItem)
    -- chance to "fail" to gather resource
    if (ZombRand(0, 100) > 15) and (player:getInventory():contains("SharpedStone")) then
        local item = player:getInventory():getItemFromType("SharpedStone");
        player:getInventory():Remove(item);
    end
end

function AddChippedStoneTool_OnCreate(items, result, player, selectedItem)
    -- chance to damage tool
    if (ZombRand(0, 100) > 35) then
        for i = 0, items:size() - 1 do
            local curItem = items:get(i);

            -- hammer
            if instanceof(items:get(i), "HandWeapon") and items:get(i):getCategories():contains("SmallBlunt") then
                if (items:get(i):getType() == "HammerStone") then
                    items:get(i):setCondition(items:get(i):getCondition() - ZombRand(2, 6));
                else
                    items:get(i):setCondition(items:get(i):getCondition() - 1);
                end

                -- chance to "fail" to gather an extra resource
                if (ZombRand(0, 100) > 25) and (player:getInventory():contains("SharpedStone")) then
                    local item = player:getInventory():getItemFromType("SharpedStone");
                    player:getInventory():Remove(item);
                end

                break;
            end

            -- axe
            if instanceof(items:get(i), "HandWeapon") and items:get(i):getCategories():contains("Axe") then
                if (items:get(i):getType() == "StoneAxe") then
                    items:get(i):setCondition(items:get(i):getCondition() - ZombRand(4, 8));
                elseif (curItem:getType() == "PickAxe") then
                    curItem:setCondition(curItem:getCondition() - 1);
                else
                    items:get(i):setCondition(items:get(i):getCondition() - 2);
                end

                -- always get bonus resource with pickaxe
                if (curItem:getType() == "PickAxe") then break; end

                -- chance to "fail" to gather an extra resource
                if (ZombRand(0, 100) > 45) and (player:getInventory():contains("SharpedStone")) then
                    local item = player:getInventory():getItemFromType("SharpedStone");
                    player:getInventory():Remove(item);
                end

                break;
            end
        end
    end
end