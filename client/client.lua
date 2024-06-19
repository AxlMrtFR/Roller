ESX = exports["es_extended"]:getSharedObject()

-- Fonction pour charger un dictionnaire d'animations
LoadAnim = function(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(1)
    end
end

sprinting = false
actif = false
oldCoords = vector3(0,0,0)
local rollersEquipped = false  -- Variable pour suivre l'état des rollers

local GlobSpeed = 0
local GlobCurAnim = ""
local RandWait = 0
local globTimer = 0

local RideDict = "move_m@jogger"
local RideAnim = "jogging"
local SprintAnim = "run"

-- Thread principal pour gérer les animations et les états des rollers
Citizen.CreateThread(function()
    -- Charger les animations nécessaires
    LoadAnim("move_f@jogger")
    LoadAnim("move_m@jogger")
    LoadAnim("anim@heists@heist_corona@team_idles@female_a")
    LoadAnim("move_crouch_proto")
    LoadAnim("move_m@generic")
    LoadAnim("amb@medic@standing@tendtodead@base") -- Charger l'animation pour mettre et enlever les rollers
    while true do
        Citizen.Wait(1)
        local oldCoords = GetEntityCoords(PlayerPedId())
        local oldTimer = GetGameTimer()
        while actif do
            Citizen.Wait(500)
            local currentTimer = GetGameTimer()
            local curCoords = GetEntityCoords(PlayerPedId())
            local dist = Vdist(curCoords, oldCoords)
            oldCoords = curCoords
            
            GlobSpeed = dist
            
            if dist > 0.1 then
                if not sprinting then
                    
                    if not IsEntityPlayingAnim(PlayerPedId(),"move_crouch_proto", "idle_intro",3) then
                        RandDeclench = math.random(1,1000)
                        
                        if (currentTimer-oldTimer) > 3000 then
                            globTimer = (currentTimer-oldTimer)
                            oldTimer = currentTimer
                            
                            if not IsEntityPlayingAnim(PlayerPedId(),RideDict, RideAnim,3) then
                                TaskPlayAnim(GetPlayerPed(-1), RideDict, RideAnim, 1.0, 1.0, 4000, 0, 0, 0, 0, 0)
                                GlobCurAnim = "Riding Forced"
                            end
                        else
                            if RandDeclench > 750 then
                                oldTimer = currentTimer
                                globTimer = (currentTimer-oldTimer)
                                if not IsEntityPlayingAnim(PlayerPedId(),RideDict, RideAnim,3) then
                                    TaskPlayAnim(GetPlayerPed(-1), RideDict, RideAnim, 1.0, 1.0, 4000, 0, 0, 0, 0, 0)
                                    GlobCurAnim = "Riding"
                                end
                            else
                                if not IsEntityPlayingAnim(PlayerPedId(),RideDict, RideAnim,3) then
                                    TaskPlayAnim(GetPlayerPed(-1), "anim@heists@heist_corona@team_idles@female_a", "idle", 8.0, 8.0, -1, 0, 0, 0, 0, 0)
                                    GlobCurAnim = "Idle Riding"
                                end
                            end
                        end
                    end
                else
                    if not IsEntityPlayingAnim(PlayerPedId(),SprintDict, SprintAnim,3) then
                        TaskPlayAnim(GetPlayerPed(-1), SprintDict, SprintAnim, 4.0, 8.0, -1, 1, 0, 0, 0, 0)
                        GlobCurAnim = "Riding Sprint"
                    end
                end
            else
                if IsEntityPlayingAnim(PlayerPedId(),"anim@heists@heist_corona@team_idles@female_a", "idle",3) then
                    StopAnimTask(PlayerPedId(), "anim@heists@heist_corona@team_idles@female_a", "idle", 1.0)
                end
                
                if IsEntityPlayingAnim(PlayerPedId(),RideDict, RideAnim,3) then
                    StopAnimTask(PlayerPedId(), RideDict, RideAnim, 1.0)
                end
            end
            
        end
    end
end)

local RCCar = {}
local player = nil

local isHomme = true
Attached = false

-- Fonction pour déterminer le sexe du joueur
function getSex()
    if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
        isHomme = true 
        RideDict = "move_m@jogger"
        RideAnim = "run"
        SprintDict = "move_m@jogger"
        SprintAnim = "run"
    elseif GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
        isHomme = false
        RideDict = "move_f@jogger"
        RideAnim = "run"
        SprintDict = "move_f@jogger"
        SprintAnim = "run"
    end
    return isHomme
end

local CurrentShoes = 0
local CurrentShoesColor = 0

-- Événement pour utiliser un item
RegisterNetEvent('esx:useItem')
AddEventHandler('esx:useItem', function(itemName)
    if itemName == Config.RollerItem then  -- Utiliser le nom de l'item configurable
        if rollersEquipped then
            -- Enlever les rollers
            TaskPlayAnim(GetPlayerPed(-1), "amb@medic@standing@tendtodead@base", "base", 1.0, 1.0, 3500, 0, 0, 0, 0, 0)
            Citizen.Wait(3000)
            rollersEquipped = false
            actif = false
            RCCar.AttachPlayer(false)
            SetPedComponentVariation(PlayerPedId(), 6, CurrentShoes, CurrentShoesColor, 2)
            ClearPedTasks(PlayerPedId())
            ResetPedMovementClipset(PlayerPedId(), 0) -- Réinitialiser le mouvement du joueur à la normale
            TriggerEvent('chat:addMessage', { args = { '[Roller]', 'Rollers removed!' } })
        else
            -- Mettre les rollers
            CurrentShoes = GetPedDrawableVariation(PlayerPedId(), 6)
            CurrentShoesColor = GetPedTextureVariation(PlayerPedId(), 6)
            
            TaskPlayAnim(GetPlayerPed(-1), "amb@medic@standing@tendtodead@base", "base", 1.0, 1.0, 3500, 0, 0, 0, 0, 0)
            
            TriggerEvent("roller:Riiide")
            
            Citizen.Wait(3000)
            
            if getSex() then
                SetPedComponentVariation(PlayerPedId(), 6, Config.RollerSlotHomme, Config.RollerColorHomme, 2)
            else
                SetPedComponentVariation(PlayerPedId(), 6, Config.RollerSlotFemme, Config.RollerColorFemme, 2)
            end
            
            TriggerEvent("roller:attach")
            
            Citizen.Wait(1500)
            TaskPlayAnim(GetPlayerPed(-1), "anim@heists@heist_corona@team_idles@female_a", "idle", 8.0, 8.0, -1, 0, 0, 0, 0, 0)
            rollersEquipped = true
            actif = true
            TriggerEvent('chat:addMessage', { args = { '[Roller]', 'Rollers equipped!' } })
        end
    end
end)

-- Événement pour démarrer le roller
RegisterNetEvent("roller:Riiide")
AddEventHandler("roller:Riiide", function(id)
    RCCar.Start()
end)

-- Événement pour attacher le joueur au roller
RegisterNetEvent("roller:attach")
AddEventHandler("roller:attach", function(id)
    RCCar.AttachPlayer(true)
end)

-- Fonction pour démarrer le roller
function RCCar.Start()
    if DoesEntityExist(RCCar.Entity) then RCCar.Clear() end

    RCCar.Spawn()
    
    while DoesEntityExist(RCCar.Entity) and DoesEntityExist(RCCar.Driver) do
        Citizen.Wait(5)
        GlobSpeed2 = GetEntitySpeed(RCCar.Driver) * 3.6
        
        local distanceCheck = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(RCCar.Entity), true)

        RCCar.HandleKeys(distanceCheck)

        if not IsPedInAnyVehicle(RCCar.Driver) then
            TaskWarpPedIntoVehicle(RCCar.Driver, RCCar.Entity, -1)
        end

        if distanceCheck <= Config.LoseConnectionDistance then
            if not NetworkHasControlOfEntity(RCCar.Driver) then
                NetworkRequestControlOfEntity(RCCar.Driver)
            elseif not NetworkHasControlOfEntity(RCCar.Entity) then
                NetworkRequestControlOfEntity(RCCar.Entity)
            end
        else
            TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 6, 2500)
        end
    end
end

-- Fonction pour gérer les touches de contrôle
RCCar.HandleKeys = function(distanceCheck)
    if not (distanceCheck <= 1.5) then

        if Attached then
            RCCar.AttachPlayer(false)
            actif = false
        end
        if IsControlJustReleased(0, 113) then
            RCCar.AttachPlayer(false)
            actif = false
        end
    end
    
    if distanceCheck < Config.LoseConnectionDistance then
        local overSpeed = (GetEntitySpeed(RCCar.Entity) * 3.6) > Config.MaxSpeedKmh
        local overSprint = (GetEntitySpeed(RCCar.Entity) * 3.6) > Config.MaxSpeedSprintKmh
        
        TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 1, 1)
        ForceVehicleEngineAudio(RCCar.Entity, 0)
        
        Citizen.CreateThread(function()
            player = GetPlayerPed(-1)
            Citizen.Wait(1)
            SetEntityInvincible(RCCar.Entity, true)
            StopCurrentPlayingAmbientSpeech(RCCar.Driver)
            if Attached then
                RCCar.Speed = GetEntitySpeed(RCCar.Entity) * 3.6
            end
        end)
        
        if Attached then
            if not overSpeed then
                if sprinting then
                    sprinting = false
                    StopAnimTask(PlayerPedId(), SprintDict, SprintAnim, 3)
                end
                if IsControlPressed(0, 71) and not IsControlPressed(0, 72) and not IsControlPressed(0, 21) then
                    TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 9, 1)
                end
                
                if IsControlJustReleased(0, 71) or IsControlJustReleased(0, 72) then
                    TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 6, 2500)
                end
                
                if IsControlPressed(0, 72) and not IsControlPressed(0, 71) then
                    TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 22, 1)
                end

                if IsControlPressed(0, 64) and IsControlPressed(0, 72) then
                    TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 13, 1)
                end

                if IsControlPressed(0, 63) and IsControlPressed(0, 72) then
                    TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 14, 1)
                end
            end
            
            if IsControlPressed(0, 71) and not IsControlPressed(0, 72) and IsControlPressed(0, 21) and not overSprint then
                TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 9, 1)
                if not sprinting then
                    sprinting = true
                    TaskPlayAnim(GetPlayerPed(-1), SprintDict, SprintAnim, 24.0, 8.0, -1, 1, 0, 0, 0, 0)
                end
            end
            
            if IsControlPressed(0, 63) and IsControlPressed(0, 71) and not overSprint then
                TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 7, 1)
            end

            if IsControlPressed(0, 64) and IsControlPressed(0, 71) and not overSprint then
                TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 8, 1)
            end
            
            if IsControlPressed(0, 22) and Attached then
                if not IsEntityInAir(RCCar.Entity) then
                    local vel = GetEntityVelocity(RCCar.Entity)
                    TaskPlayAnim(PlayerPedId(), "move_crouch_proto", "idle_intro", 5.0, 8.0, -1, 0, 0, false, false, false)
                    local duration = 0
                    local boost = 0
                    while IsControlPressed(0, 22) do
                        Citizen.Wait(10)
                        duration = duration + 10.0
                        if not IsEntityPlayingAnim(PlayerPedId(), "move_crouch_proto", "idle_intro", 3) then
                            TaskPlayAnim(PlayerPedId(), "move_crouch_proto", "idle_intro", 5.0, 8.0, -1, 0, 0, false, false, false)
                        end
                    end
                    boost = Config.maxJumpHeigh * duration / 250.0
                    if boost > Config.maxJumpHeigh then boost = Config.maxJumpHeigh end
                    if (Attached) then
                        SetEntityVelocity(RCCar.Entity, vel.x, vel.y, vel.z + boost)
                    end
                    TaskPlayAnim(GetPlayerPed(-1), "anim@heists@heist_corona@team_idles@female_a", "idle", 1.0, 1.0, 4000, 0, 0, 0, 0, 0)
                end
            end
        end
    end
end

-- Fonction pour faire apparaître le roller
function RCCar.Spawn()
    RCCar.LoadModels({ GetHashKey("bmx"), 68070371, GetHashKey("p_defilied_ragdoll_01_s"), "pickup_object", "move_strafe@stealth", "move_crouch_proto" })

    local spawnCoords, spawnHeading = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * 2.0, GetEntityHeading(PlayerPedId())

    RCCar.Entity = CreateVehicle(GetHashKey("bmx"), spawnCoords, spawnHeading, true)
    
    while not DoesEntityExist(RCCar.Entity) do
        Citizen.Wait(5)
    end

    SetEntityNoCollisionEntity(RCCar.Entity, player, false)
    SetEntityCollision(RCCar.Entity, false, true)
    SetEntityVisible(RCCar.Entity, false)

    RCCar.Driver = CreatePed(12, 68070371, spawnCoords, spawnHeading, true, true)

    SetEnableHandcuffs(RCCar.Driver, true)
    SetEntityInvincible(RCCar.Driver, true)
    SetEntityVisible(RCCar.Driver, false)
    SetEntityCollision(RCCar.Driver, false, true)
    FreezeEntityPosition(RCCar.Driver, true)
    TaskWarpPedIntoVehicle(RCCar.Driver, RCCar.Entity, -1)

    while not IsPedInVehicle(RCCar.Driver, RCCar.Entity) do
        Citizen.Wait(0)
    end

    RCCar.Attach("place")
end

-- Fonction pour attacher ou détacher le roller
function RCCar.Attach(param)
    if not DoesEntityExist(RCCar.Entity) then
        return
    end
    
    if param == "place" then
        AttachEntityToEntity(RCCar.Entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), -0.1, 0.0, -0.3, 70.0, 0.0, 270.0, 0, 0, 0, 0, 2, 1)
        Citizen.Wait(800)
        DetachEntity(RCCar.Entity, false, true)
        PlaceObjectOnGroundProperly(RCCar.Entity)
    elseif param == "pick" then
        Citizen.Wait(100)
        AttachEntityToEntity(RCCar.Entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), -0.1, 0.0, -0.2, 70.0, 0.0, 270.0, 0, 0, 0, 0, 2, 1)
        Citizen.Wait(900)
        RCCar.Clear()
    end
end

-- Fonction pour effacer le roller
function RCCar.Clear(models)
    DetachEntity(RCCar.Entity)
    DeleteVehicle(RCCar.Entity)
    DeleteEntity(RCCar.Driver)

    RCCar.UnloadModels()
    Attach = false
    Attached = false
    SetPedRagdollOnCollision(player, false)
end

-- Fonction pour charger les modèles
function RCCar.LoadModels(models)
    for modelIndex = 1, #models do
        local model = models[modelIndex]

        if not RCCar.CachedModels then
            RCCar.CachedModels = {}
        end

        table.insert(RCCar.CachedModels, model)

        if IsModelValid(model) then
            while not HasModelLoaded(model) do
                RequestModel(model)
                Citizen.Wait(10)
            end
        else
            while not HasAnimDictLoaded(model) do
                RequestAnimDict(model)
                Citizen.Wait(10)
            end
        end
    end
end

-- Fonction pour décharger les modèles
function RCCar.UnloadModels()
    for modelIndex = 1, #RCCar.CachedModels do
        local model = RCCar.CachedModels[modelIndex]

        if IsModelValid(model) then
            SetModelAsNoLongerNeeded(model)
        else
            RemoveAnimDict(model)
        end
    end
end

-- Fonction pour attacher le joueur au roller
RCCar.AttachPlayer = function(toggle)
    if toggle then
        AttachEntityToEntity(player, RCCar.Entity, 20, 0.0, 0, 0.70, 0.0, 0.0, 0.0, false, false, false, true, 1, true)
        SetEntityCollision(player, true, true)
    elseif not toggle then
        DetachEntity(player, false, false)
        TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 3, 1)
    end    
    Attached = toggle
end

---DEBUG
function DrawAdvancedText(x, y, w, h, sc, text, r, g, b, a, font, jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
    N_0x4e096588b13ffeca(jus)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.1 + w, y - 0.02 + h)
end

local ShowMenuHelp = false
-- Commandes de débogage (commentées)
-- RegisterCommand("rollerDBG", function()
--     ShowMenuHelp = not ShowMenuHelp
-- end)

-- RegisterCommand("rollerDBG1", function()
--     TaskPlayAnim(GetPlayerPed(-1), "move_m@generic", "run", 1.0, 1.0, -1, 1, 0, 0, 0, 0)
-- end)

-- RegisterCommand("rollerDBG2", function()
--     TaskPlayAnim(GetPlayerPed(-1), RideDict, SprintAnim, 1.0, 1.0, 4000, 0, 0, 0, 0, 0)
-- end)

-- RegisterCommand("rollerDBG3", function()
--     ClearPedTasks(PlayerPedId())
-- end)

-- Thread pour afficher les informations de débogage (commenté)
-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(0)
--         if ShowMenuHelp then
--             DrawRect(0.108, 0.760, 0.196, 0.415, 0, 0, 0, 150)
--             DrawAdvancedText(0.2, 0.578, 0.005, 0.0028, 0.4, "Running : " .. tostring(GlobSpeed), 255, 255, 255, 255, 6, 0)
--             DrawAdvancedText(0.2, 0.603, 0.005, 0.0028, 0.4, "Anim : " .. tostring(GlobCurAnim), 255, 255, 255, 255, 6, 0)
--             DrawAdvancedText(0.2, 0.628, 0.005, 0.0028, 0.4, "RandDeclench: " .. tostring(RandDeclench), 255, 255, 255, 255, 6, 0)
--             DrawAdvancedText(0.2, 0.653, 0.005, 0.0028, 0.4, "globTimer :" .. tostring(globTimer), 255, 255, 255, 255, 6, 0)
--             DrawAdvancedText(0.2, 0.681, 0.005, 0.0028, 0.4, "RideDict :" .. tostring(RideDict), 255, 255, 255, 255, 6, 0)
--             DrawAdvancedText(0.2, 0.711, 0.005, 0.0028, 0.4, "d speed :" .. tostring(GlobSpeed2), 255, 255, 255, 255, 6, 0)
--             DrawAdvancedText(0.2, 0.741, 0.005, 0.0028, 0.4, "d sprint :" .. tostring(sprinting), 255, 255, 255, 255, 6, 0)
--         end
--     end
-- end)
