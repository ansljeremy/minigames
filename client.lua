local Minigame = {
    active = false,
    data = {},
    type = nil
}

local successCb = nil
local failCb = nil

function getNewRandomInt(min,max)
    min = math.ceil(min)
    max = math.floor(max)
    return math.floor(math.random() * (max - min + 1) + min);
end

function Minigame.Start(type,success, fail)

    if not Minigame.active then
        if success ~= nil then
            successCb = success
        end
        if fail ~= nil then
            failCb = fail
        end

        if type == 'skillcircle' then
            StartSkillCircle()
        end
    else
        QBCore.Functions.Notify("A minigame is already open", "error")
    end

end

function StartSkillCircle()
    local gameStart = getNewRandomInt(20,40)/10
    local gameEnd = getNewRandomInt(5,10)/10

    Minigame.data = {
        gameStart = gameStart,
        gameEnd = gameStart + gameEnd,
        gameKey = math.random(1,4),
        gameTime = (getNewRandomInt(1,3) * 5)
    }

    Minigame.active = true
    Minigame.type = "skillcircle"

    TriggerEvent('progressbar:client:ToggleBusyness', true)
    LocalPlayer.state:set("hotbar_busy", true, true)

    SetNuiFocus(true, false)
    SendNUIMessage({
        action = "start",
        type = "skillcircle",
        data = Minigame.data
    })

end

function Minigame.Repeat(type)
    if type == "skillcircle" then
        local gameStart = getNewRandomInt(20,40)/10
        local gameEnd = getNewRandomInt(5,10)/10

        Minigame.data = {
            gameStart = gameStart,
            gameEnd = gameStart + gameEnd,
            gameKey = math.random(1,4),
            gameTime = (getNewRandomInt(1,3) * 5)
        }

        Minigame.active = true
        TriggerEvent('progressbar:client:ToggleBusyness', true)
        LocalPlayer.state:set("hotbar_busy", true, true)

        Citizen.CreateThread(function()
            Wait(100)
            SetNuiFocus(true, false)
            SendNUIMessage({
                action = "start",
                type = "skillcircle",
                data = Minigame.data
            })
        end)

    end
end

function Minigame.End()
    successCb = nil
    failCb = nil
    Minigame.data = {}
    Minigame.active = false
    Minigame.type = nil

    Citizen.SetTimeout(1000, function()
        LocalPlayer.state:set("hotbar_busy", false, true)
    end)
end

function Minigame.Stop()
    Minigame.active = false
    TriggerEvent('progressbar:client:ToggleBusyness', false)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "stop"
    })
end

RegisterNUICallback('skillcirclecheck', function(data, cb)
    if successCb ~= nil then
        Minigame.active = false
        local degreeStart = (180 / math.pi) * Minigame.data.gameStart
        local degreeEnd = (180 / math.pi) * Minigame.data.gameEnd
        local correct = false

        if tonumber(data.degrees) < degreeStart or tonumber(data.degrees) > degreeEnd then
            correct = false
        else
            if tonumber(data.keyPressed) == Minigame.data.gameKey then
                correct = true
            else
                correct = false
            end
        end

        if correct then
            successCb()
        else
            failCb()
        end
    end
    Minigame.Stop()
    cb("ok")
end)

RegisterNUICallback('skillcirclefail', function(data, cb)
    failCb()
    Minigame.Stop()
    cb("ok")
end)

function GetMinigameObject()
    return Minigame
end


RegisterCommand('testminigame', function()
    Minigame.Start("skillcircle",function()
        Minigame.End()
        QBCore.Functions.Notify("Completed Minigame", "success")

    end, function()
        Minigame.End()
        QBCore.Functions.Notify("Failed Minigame", "error")
    end)
end)

RegisterCommand('testminigamerep', function()
    local repeatTimes = 0;

    Minigame.Start("skillcircle", function()
        if repeatTimes + 1 == math.random(1,5) then
            Minigame.End()
            QBCore.Functions.Notify("Completed Minigame", "success")
        else
            QBCore.Functions.Notify("Repeating Minigame", "primary")
            repeatTimes = repeatTimes + 1
            Minigame.Repeat("skillcircle")
        end

    end, function()
        Minigame.End()
        QBCore.Functions.Notify("Failed Minigame", "error")

    end)

end)