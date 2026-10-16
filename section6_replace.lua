-- ===== 6. ЖАҢА: пароль тексеру (Firebase) + онлайн + командалар =====
-- Осы блокты ескі "6. Пароль тексеру логикасы" орнына қойыңыз

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local DB = "https://play-lag-default-rtdb.firebaseio.com"
local req = (syn and syn.request) or http_request or request

local function dbGet(path)
    local ok, res = pcall(req, {Url = DB .. path .. ".json", Method = "GET"})
    if not ok or not res or res.StatusCode ~= 200 then return nil, false end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, res.Body)
    return ok2 and data or nil, true
end

local function dbPut(path, tbl)
    pcall(req, {Url = DB .. path .. ".json", Method = "PUT",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(tbl)})
end

local function notify(title, text, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",
            {Title = title, Text = text, Duration = dur or 6})
    end)
end

local function keyValid(pw)
    if pw == "" or pw:find("[%.#%$%[%]/]") then return false end
    local data, reached = dbGet("/keys/" .. HttpService:UrlEncode(pw))
    if not reached then return false, "Серверге қосылу мүмкін емес" end
    if type(data) ~= "table" then return false end
    if data.expires and os.time() * 1000 > data.expires then
        return false, "Пароль мерзімі бітті"
    end
    return true
end

local function startSession(pw)
    local lp = Players.LocalPlayer
    local uid = tostring(lp.UserId)
    local lastBroadcast, lastCmd, lastUpd = nil, nil, false
    local gameName = "?"
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)

    task.spawn(function()
        while task.wait(10) do
            -- онлайн белгісі
            dbPut("/online/" .. uid, {name = lp.DisplayName, user = lp.Name,
                game = gameName, t = os.time()})

            -- пароль әлі жарамды ма?
            local ok = keyValid(pw)
            if not ok then
                lp:Kick("Пароль өзгертілді немесе мерзімі бітті")
                return
            end

            -- жаңарту режимі
            local st = dbGet("/status")
            if type(st) == "table" and st.updating and not lastUpd then
                notify("Nurlykhan HUB 🔧", st.text or "Скрипт жаңартылып жатыр", 10)
            end
            lastUpd = type(st) == "table" and st.updating or false

            -- жалпы хабарлама
            local b = dbGet("/broadcast")
            if type(b) == "table" then
                if lastBroadcast and b.id ~= lastBroadcast then
                    notify("Nurlykhan HUB 📢", b.text)
                end
                lastBroadcast = b.id
            end

            -- жеке команда
            local c = dbGet("/commands/" .. uid)
            if type(c) == "table" and c.id ~= lastCmd then
                lastCmd = c.id
                if c.type == "msg" then notify("Админ ✉", c.text, 10)
                elseif c.type == "kick" then lp:Kick(c.text or "Админ шығарды") return end
            end
        end
    end)
end

SubmitBtn.MouseButton1Click:Connect(function()
    local pw = PassBox.Text
    local ok, err = keyValid(pw)
    if ok then
        ScreenGui:Destroy()
        createFireworks()
        notify("Nurlykhan HUB 👑", "Nurlykhan script жүктелді!", 5)
        startSession(pw)
        startMainScript()
    else
        SubmitBtn.Text = err or "Пароль қате!"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        task.wait(1.5)
        SubmitBtn.Text = "Кіру"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end
end)
