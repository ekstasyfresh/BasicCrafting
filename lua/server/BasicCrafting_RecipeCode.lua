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
--           a small for loop like this won't hurt anything, though.
     
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

function AddChippedStoneTool_OnCreate(items, result, player, selectedItem)
    -- define tool handling functions
    local function applyConditionChange(tool, minDamage, maxDamage)
        local damageAmount = ZombRand(minDamage, maxDamage + 1)
        tool:setCondition(tool:getCondition() - damageAmount)
    end

    local function attemptResourceRemoval(chance, itemType)
        if ZombRand(0, 100) > chance and player:getInventory():contains(itemType) then
            local item = player:getInventory():getItemFromType(itemType)
            player:getInventory():Remove(item)
        end
    end

    -- function to handle tool logic for each item
    local function processTool(tool)
        if not instanceof(tool, "HandWeapon") then return false end
        
        local toolType = tool:getType()
        local toolCategories = tool:getCategories()

        -- handle smallblunt tools (HammerStone)
        if toolCategories:contains("SmallBlunt") then
            if toolType == "HammerStone" then
                applyConditionChange(tool, 2, 6)
            else
                applyConditionChange(tool, 1, 1)
            end
            attemptResourceRemoval(25, "SharpedStone")
            return true
        end

        -- handle axe tools
        if toolCategories:contains("Axe") then
            if toolType == "StoneAxe" then
                applyConditionChange(tool, 4, 8)
            elseif toolType == "PickAxe" then
                -- pickaxe has a smaller chance to lose condition
                if ZombRand(0, 100) > 80 then
                    applyConditionChange(tool, 1, 1)
                end
                return true  -- Pickaxe always succeeds, no resource removal
            else
                applyConditionChange(tool, 2, 2)
            end
            attemptResourceRemoval(45, "SharpedStone")
            return true
        end
        return false
    end

    -- Main logic: attempt to process selected item, then fallback to other items
    if ZombRand(0, 100) > 35 then
        if selectedItem and processTool(selectedItem) then return end
        for i = 0, items:size() - 1 do
            if processTool(items:get(i)) then break end
        end
    end
end