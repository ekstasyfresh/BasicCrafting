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

-- Reclaim Thread Logic
-- -----------------------------------
-- [ ] TODO: Is it possible to just set the amount of uses left rather than "using"
--           to the desired value? This would be better for performance, but I'm sure
--           a small for loop like this won't hurt anything.
     
function ReclaimThread_OnCreate(items, result, player, selectedItem)
    local tailoringLevel = player:getPerkLevel(Perks.Tailoring);

    local useLevel = math.min(tailoringLevel + ZombRand(0, 3), 10);

    for i = useLevel + 1, 9 do
            result:Use();
    end
end

-- Chipped Stone Logic
-- -----------------------------------
-- [x] TODO: I want to make this chance based on a skill, but uncertain which skill
--           to base it on. Foraging?

-- [x] TODO: You can still fail to knap stones even at 10 Foraging. The logic seems
--           fine, so why? - turns out it's because it's "PlantScavenging" and not the
--           name "Foraging". :-(

function AddChippedStone_OnCreate(items, result, player, selectedItem)
    local foragingLevel = player:getPerkLevel(Perks.PlantScavenging) * 10;
    local successLevel = ZombRand(foragingLevel, 100);
    local challengeRating = 20;

    -- success
    if successLevel >= challengeRating then
        player:getXp():AddXP(Perks.PlantScavenging, 5);
    else
        -- failure
        local item = player:getInventory():getItemFromType("SharpedStone");
        player:getInventory():Remove(item);
        player:getXp():AddXP(Perks.PlantScavenging, 1);
    end
end

-- Chipped Stone Logic Using Tools
-- ----------------------------------
-- [ ] TODO: Make it check for selectedItem as well. Currently, it will select the first
--           item it finds even if you selected a specific tool. Also, clean this code up 
--           in the process.

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
                    if ZombRand(0, 100) > 80 then
                        curItem:setCondition(curItem:getCondition() - 1);
                    end
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