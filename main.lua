local mod = RegisterMod("The Specialist ABP", 1)
local game = Game()

function mod:getCostumeId(name)
    return Isaac.GetCostumeIdByPath("costumes/specialist_"..name..".anm2")
end

mod.config = {
    -- https://bindingofisaacrebirth.fandom.com/wiki/Items?dlcfilter=2
    items = {
        -- Actives
        [CollectibleType.COLLECTIBLE_SATANIC_BIBLE] = true,
        [CollectibleType.COLLECTIBLE_D6] = true,
        [CollectibleType.COLLECTIBLE_BROKEN_SHOVEL] = true,
        [CollectibleType.COLLECTIBLE_MOMS_SHOVEL] = true,
        [CollectibleType.COLLECTIBLE_VOID] = true,
        [CollectibleType.COLLECTIBLE_DINF] = true,

        -- Passives
        [CollectibleType.COLLECTIBLE_20_20] = true,
        [CollectibleType.COLLECTIBLE_BRIMSTONE] = true,
        [CollectibleType.COLLECTIBLE_MAXS_HEAD] = true,
        [CollectibleType.COLLECTIBLE_DR_FETUS] = true,
        [CollectibleType.COLLECTIBLE_EPIC_FETUS] = true,
        [CollectibleType.COLLECTIBLE_GODHEAD] = true,
        [CollectibleType.COLLECTIBLE_HOLY_MANTLE] = true,
        [CollectibleType.COLLECTIBLE_IPECAC] = true,
        [CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM] = true,
        [CollectibleType.COLLECTIBLE_MOMS_KNIFE] = true,
        [CollectibleType.COLLECTIBLE_POLYPHEMUS] = true,
        [CollectibleType.COLLECTIBLE_PYROMANIAC] = true,
        [CollectibleType.COLLECTIBLE_SACRED_HEART] = true,
        [CollectibleType.COLLECTIBLE_STOP_WATCH] = true,
        [CollectibleType.COLLECTIBLE_WAFER] = true,
        [CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT] = true,
        [CollectibleType.COLLECTIBLE_INCUBUS] = true,
        [CollectibleType.COLLECTIBLE_TECH_X] = true,
        [CollectibleType.COLLECTIBLE_HAEMOLACRIA] = true,
    },

    danceCostumes = {
        [PlayerType.PLAYER_ISAAC] = mod:getCostumeId("isaac"),
        [PlayerType.PLAYER_MAGDALENA] = mod:getCostumeId("magdalene"),
        [PlayerType.PLAYER_CAIN] = mod:getCostumeId("cain"),
        [PlayerType.PLAYER_JUDAS] = mod:getCostumeId("judas"),
        [PlayerType.PLAYER_BLACKJUDAS] = mod:getCostumeId("dark_judas"),
        [PlayerType.PLAYER_XXX] = mod:getCostumeId("xxx"),
        [PlayerType.PLAYER_EVE] = mod:getCostumeId("eve"),
        [PlayerType.PLAYER_SAMSON] = mod:getCostumeId("samson"),
        [PlayerType.PLAYER_AZAZEL] = mod:getCostumeId("azazer"),
        [PlayerType.PLAYER_LAZARUS] = mod:getCostumeId("lazarus"),
        [PlayerType.PLAYER_LAZARUS2] = mod:getCostumeId("lazarus2"),
        [PlayerType.PLAYER_EDEN] = mod:getCostumeId("eden"),
        [PlayerType.PLAYER_THELOST] = mod:getCostumeId("lost"),
        [PlayerType.PLAYER_LILITH] = mod:getCostumeId("lilith"),
        [PlayerType.PLAYER_KEEPER] = mod:getCostumeId("keeper"),
        [PlayerType.PLAYER_APOLLYON] = mod:getCostumeId("apollyon"),
        [PlayerType.PLAYER_THEFORGOTTEN] = mod:getCostumeId("forgor_bone"),
        [PlayerType.PLAYER_THESOUL] = mod:getCostumeId("forgor_soul"),
    
        DEFAULT = mod:getCostumeId("isaac")
    }
}

mod.isPlaying = false
mod.curPickup = nil
mod.items = {}
-- works for now, will optimize later
function mod:ClearItemList() 
    for i = 1, 552 do
        mod.items[i] = false
    end 
end

function mod:DoCostume(apply)
    local plr = game:GetPlayer(1)

    local costume = mod.config.danceCostumes.DEFAULT;
    if mod.config.danceCostumes[plr:GetPlayerType()] ~= nil then
        costume = mod.config.danceCostumes[plr:GetPlayerType()];
    end

    if costume == nil then return end

    if apply then
        mod.isPlaying = true
        
        plr:AddNullCostume(costume)

        -- music
        local specialist = Isaac.GetMusicIdByName("specialist")
        if MusicManager():GetCurrentMusicID() ~= specialist then
            MusicManager():UpdateVolume();
            MusicManager():Play(specialist, 1);
            MusicManager():UpdateVolume();
        end
    else
        mod.isPlaying = false
        plr:TryRemoveNullCostume(costume)
        game:GetRoom():PlayMusic()
    end
end

function mod:PostUpdate()
    -- accessing last index sometimes crushes the game and (i think) always is not an collectible, so i just iterate to #itemsNearby - 1
    local itemsNearby = game:GetRoom():GetEntities()

    if mod.curPickup ~= nil and mod.isPlaying then
        -- if it is still nearby, do NOT disable dance
        for i = 1, #itemsNearby - 1 do
            local v = itemsNearby:Get(i)
            if v and v.Type == EntityType.ENTITY_PICKUP and v.SubType == mod.curPickup then
                return
            end
        end

        mod.curPickup = nil
        mod:DoCostume(false)
    else
        for i = 1, #itemsNearby - 1 do
            local v = itemsNearby:Get(i)

            --[[ useful
            Isaac.ConsoleOutput("\n")
            Isaac.ConsoleOutput(tostring(i))
            Isaac.ConsoleOutput(" ")
            Isaac.ConsoleOutput(tostring(v.SubType))
            Isaac.ConsoleOutput(" ")
            Isaac.ConsoleOutput(tostring(v.Variant == PickupVariant.PICKUP_COLLECTIBLE))
            Isaac.ConsoleOutput(" ")
            Isaac.ConsoleOutput(tostring(v.SubType ~= 0))
            Isaac.ConsoleOutput(" ")
            Isaac.ConsoleOutput(tostring(not mod.items[v.SubType]))
            Isaac.ConsoleOutput(" ")
            Isaac.ConsoleOutput(tostring(mod.config.items[v.SubType]))
            Isaac.ConsoleOutput("\n")
            --]]

            if v and v.Type == EntityType.ENTITY_PICKUP and v.Variant == PickupVariant.PICKUP_COLLECTIBLE and v.SubType ~= 0 and not mod.items[v.SubType] and mod.config.items[v.SubType] then
                table.insert(mod.items, v.SubType, true)
                mod.curPickup = v.SubType
                mod:DoCostume(true)
            end
        end
    end
end

function mod:PostNewRoom()
    mod.curPickup = nil
    mod:DoCostume(false)
end

mod:ClearItemList()
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.PostNewRoom)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.PostUpdate)