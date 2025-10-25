local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Acradia Script",
   Icon = 0,
   LoadingTitle = "Hello to Arcadia Script",
   LoadingSubtitle = "by Amongus hub",
   ShowText = "Arcadia Script",
   Theme = "AmberGlow",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "Amongus hub",
      FileName = "Arcadia Script"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "Hello",
      Subtitle = "Arcadia Script",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Time to pay"}
   }
})

local PartyTab = Window:CreateTab("Party", 4483362458)

-- Переменные для работы
local Players = game:GetService("Players")
local SelectedPlayer = "None"
local PlayerDropdown

-- Функция для обновления списка игроков
local function UpdatePlayerList()
    local playerNames = {"None"}
    
    -- Получаем список всех игроков кроме локального
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    
    -- Обновляем выпадающий список
    PlayerDropdown:Refresh(playerNames)
end

-- Создаем выпадающий список для выбора игроков
PlayerDropdown = PartyTab:CreateDropdown({
   Name = "Select Player",
   Options = {"None"},
   CurrentOption = "None",
   Callback = function(Option)
        SelectedPlayer = Option
   end,
})

-- Кнопка для обновления выпадающего списка
PartyTab:CreateButton({
   Name = "Refresh DropDown",
   Callback = function()
        UpdatePlayerList()
   end,
})

-- Кнопка для добавления игрока в партию
PartyTab:CreateButton({
   Name = "Add to Party",
   Callback = function()
        if SelectedPlayer and SelectedPlayer ~= "None" then
            -- Получаем объект игрока и передаем его
            local targetPlayer = game.Players:WaitForChild(SelectedPlayer)
            local args = {
                targetPlayer  -- Передаем объект игрока
            }
            
            -- Пробуем вызвать RemoteEvent
            local success, error = pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CreateParty"):FireServer(unpack(args))
            end)
            
            if success then
                print("Successfully invited " .. SelectedPlayer .. " to party!")
            else
                warn("Error inviting player: " .. tostring(error))
            end
        else
            warn("Please select a player first!")
        end
   end,
})

-- Первоначальное обновление списка
UpdatePlayerList()

-- Новая вкладка ESP
local EspTab = Window:CreateTab("ESP", 4483362458)

-- Переменные для ESP
local espEnabled = false
local xpEnabled = false
local goldEnabled = false
local tokensEnabled = false
local arcsEnabled = false
local espBillboards = {}
local espUpdateConnection

-- Функция для получения текста ESP
local function GetESPText(player)
    local parts = {}
    
    if espEnabled then
        table.insert(parts, "Level: " .. (player:FindFirstChild("Level") and player.Level.Value or "N/A"))
    end
    
    if xpEnabled then
        table.insert(parts, "XP: " .. (player:FindFirstChild("XP") and player.XP.Value or "N/A"))
    end
    
    if goldEnabled then
        table.insert(parts, "Gold: " .. (player:FindFirstChild("Gold") and player.Gold.Value or "N/A"))
    end
    
    if tokensEnabled then
        table.insert(parts, "Tokens: " .. (player:FindFirstChild("Tokens") and player.Tokens.Value or "N/A"))
    end
    
    if arcsEnabled then
        table.insert(parts, "Arcs: " .. (player:FindFirstChild("Arcs") and player.Arcs.Value or "N/A"))
    end
    
    -- Комбинируем текст через разделитель
    if #parts > 0 then
        return table.concat(parts, " | ")
    else
        return ""
    end
end

-- Функция для создания ESP
local function CreateESP(player)
    if player == Players.LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Удаляем старый ESP если есть
    if espBillboards[player] then
        espBillboards[player]:Destroy()
    end
    
    -- Создаем BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. player.Name
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(0, 200, 0, 50) -- Увеличили размер для большего текста
    billboard.StudsOffset = Vector3.new(0, 7.5, 0) -- 7.5 stud над головой
    billboard.AlwaysOnTop = true
    billboard.Parent = humanoidRootPart
    
    -- Создаем текст
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "ESPText"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = GetESPText(player)
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 12 -- Уменьшили размер текста для вмещения больше информации
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextWrapped = true -- Перенос текста
    textLabel.Parent = billboard
    
    -- Сохраняем ссылку
    espBillboards[player] = billboard
end

-- Функция для удаления ESP
local function RemoveESP(player)
    if espBillboards[player] then
        espBillboards[player]:Destroy()
        espBillboards[player] = nil
    end
end

-- Функция для обновления всех ESP
local function UpdateAllESP()
    if not (espEnabled or xpEnabled or goldEnabled or tokensEnabled or arcsEnabled) then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                CreateESP(player)
            end
        end
    end
end

-- Функция для обновления текста ESP
local function UpdateESPText()
    for player, billboard in pairs(espBillboards) do
        local textLabel = billboard:FindFirstChild("ESPText")
        if textLabel then
            textLabel.Text = GetESPText(player)
        end
    end
end

-- Обработчик появления новых игроков
Players.PlayerAdded:Connect(function(player)
    if espEnabled or xpEnabled or goldEnabled or tokensEnabled or arcsEnabled then
        player.CharacterAdded:Connect(function(character)
            wait(1) -- Ждем немного чтобы персонаж полностью загрузился
            if espEnabled or xpEnabled or goldEnabled or tokensEnabled or arcsEnabled then
                CreateESP(player)
            end
        end)
    end
end)

-- Обработчик ухода игроков
Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- Общая функция для управления ESP
local function ManageESP()
    local anyESPEnabled = espEnabled or xpEnabled or goldEnabled or tokensEnabled or arcsEnabled
    
    if anyESPEnabled then
        -- Включаем ESP для всех существующих игроков
        UpdateAllESP()
        
        -- Запускаем автоматическое обновление каждую секунду
        if not espUpdateConnection then
            espUpdateConnection = game:GetService("RunService").Heartbeat:Connect(function()
                UpdateAllESP()
                UpdateESPText()
                task.wait(1) -- Обновляем каждую секунду
            end)
        end
    else
        -- Выключаем ESP и останавливаем обновление
        if espUpdateConnection then
            espUpdateConnection:Disconnect()
            espUpdateConnection = nil
        end
        
        for player, billboard in pairs(espBillboards) do
            billboard:Destroy()
        end
        espBillboards = {}
    end
end

-- Toggle для Level ESP
EspTab:CreateToggle({
   Name = "Show Player Levels",
   CurrentValue = false,
   Callback = function(Value)
        espEnabled = Value
        ManageESP()
   end,
})

-- Toggle для XP ESP
EspTab:CreateToggle({
   Name = "Show Player XP",
   CurrentValue = false,
   Callback = function(Value)
        xpEnabled = Value
        ManageESP()
   end,
})

-- Toggle для Gold ESP
EspTab:CreateToggle({
   Name = "Show Player Gold",
   CurrentValue = false,
   Callback = function(Value)
        goldEnabled = Value
        ManageESP()
   end,
})

-- Toggle для Tokens ESP
EspTab:CreateToggle({
   Name = "Show Player Tokens",
   CurrentValue = false,
   Callback = function(Value)
        tokensEnabled = Value
        ManageESP()
   end,
})

-- Toggle для Arcs ESP
EspTab:CreateToggle({
   Name = "Show Player Arcs",
   CurrentValue = false,
   Callback = function(Value)
        arcsEnabled = Value
        ManageESP()
   end,
})
