-- Firebase базасы сілтемесі (сіздің жобаңыз бойынша қосылды)
local FIREBASE_URL = "https://play-lag-default-rtdb.firebaseio.com/Usuarios"

-- Интерфейс (UI) жасау: Логин мен пароль сұрайтын терезе
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LoginAuthGui"
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Хубқа кіру үшін логин жазыңыз"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local userBox = Instance.new("TextBox")
userBox.Size = UDim2.new(0.8, 0, 0, 35)
userBox.Position = UDim2.new(0.1, 0, 0.3, 0)
userBox.PlaceholderText = "Логин"
userBox.Text = ""
userBox.TextColor3 = Color3.fromRGB(255, 255, 255)
userBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
userBox.Parent = frame

local passBox = Instance.new("TextBox")
passBox.Size = UDim2.new(0.8, 0, 0, 35)
passBox.Position = UDim2.new(0.1, 0, 0.5, 0)
passBox.PlaceholderText = "Пароль"
passBox.Text = ""
passBox.SecretText = true
passBox.TextColor3 = Color3.fromRGB(255, 255, 255)
passBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
passBox.Parent = frame

local loginBtn = Instance.new("TextButton")
loginBtn.Size = UDim2.new(0.8, 0, 0, 35)
loginBtn.Position = UDim2.new(0.1, 0, 0.75, 0)
loginBtn.Text = "Кіру"
loginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loginBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
loginBtn.Parent = frame

-- Firebase арқылы тексеру функциясы
local function checkLogin(username, password)
    local HttpService = game:GetService("HttpService")
    -- Firebase-ден мәліметті алу
    local success, response = pcall(function()
        return game:HttpGet(FIREBASE_URL .. "/" .. username .. ".json")
    end)
    
    if success and response and response ~= "null" then
        local data = HttpService:JSONDecode(response)
        if data and data.Password == password then
            return true
        end
    end
    return false
end

-- Батырманы басқан кездегі әрекет
loginBtn.MouseButton1Click:Connect(function()
    local u = userBox.Text
    local p = passBox.Text
    
    if u == "" or p == "" then
        title.Text = "Барлық өрісті толтырыңыз!"
        return
    end
    
    title.Text = "Тексеруде..."
    
    if checkLogin(u, p) then
        title.Text = "Сәтті кірдіңіз!"
        task.wait(1)
        screenGui:Destroy()
        
        -- Логин дұрыс болса орындалатын негізгі скриптіңіз
        local SAE = "https://raw.githubusercontent.com/tienkhanh1/Chilli-Hub-Script/refs/heads/main/StealAnEgg"
        local RAP = "https://api.luarmor.net/files/v4/loaders/0dbcaa9e992477523d38a8284d7dbdef.lua"
        local JFA = "https://raw.githubusercontent.com/tienkhanh1/Chilli-Hub-Script/refs/heads/main/JumpForAnimals"
        local SAB = "https://raw.githubusercontent.com/tienkhanh1/spicy/refs/heads/main/Steal-a-Brainrot"
        local MM2 = "https://api.luarmor.net/files/v4/loaders/2bf348894416e1d3deee40be756d42ff.lua"
        local BROOK = "https://api.luarmor.net/files/v4/loaders/89190a03fd337349cef140d576357ba3.lua"

        local byGameId = {
            [10563114921] = SAE,
            [10035204815] = RAP,
            [10690360998] = JFA,
            [7709344486] = SAB,
            [66654135] = MM2,
            [1686885941] = BROOK,
        }

        local byPlaceId = {
            [107778070777162] = SAE,
            [124216119978534] = RAP,
            [126870639873289] = JFA,
            [109983668079237] = SAB,
            [142823291] = MM2,
            [4924922222] = BROOK,
        }

        local gameId = game.GameId
        while gameId == 0 and game.PlaceId == 0 do
            task.wait()
            gameId = game.GameId
        end

        local url = byGameId[gameId] or byPlaceId[game.PlaceId]
        if not url then return end

        for _ = 1, 3 do
            local ok, source = pcall(game.HttpGet, game, url)
            if ok and type(source) == "string" and source ~= "" then
                local chunk = loadstring(source)
                if chunk then chunk() end
                return
            end
            task.wait(0.5)
        end
    else
        title.Text = "Қате логин немесе пароль!"
    end
end)
