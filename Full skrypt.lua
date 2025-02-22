local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

local Window = Rayfield:CreateWindow({
   Name = "Qwee Hub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Qwee Hub Loading....",
   LoadingSubtitle = "by KLPN",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "pyEJhdxzPq", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

-- Main
local MainTab = Window:CreateTab("🏠 Home", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Main")

local player = game:GetService("Players").LocalPlayer
local humanoid = nil

-- Variables to store WalkSpeed and JumpPower values
local savedWalkSpeed = 16 -- Default walk speed value
local savedJumpPower = 50 -- Default jump power value

-- WalkSpeed Input (created only once)
local WalkSpeedInput = MainTab:CreateInput({
   Name = "WalkSpeed (Normal Speed = 16)",
   CurrentValue = tostring(savedWalkSpeed), -- Set initial value to savedWalkSpeed
   PlaceholderText = "Enter Speed",
   RemoveTextAfterFocusLost = false,
   Flag = "input_ws",
   Callback = function(Text)
       local Value = tonumber(Text)
       if humanoid and Value then
           savedWalkSpeed = math.clamp(Value, 1, 350) -- Save the new value
           humanoid.WalkSpeed = savedWalkSpeed -- Apply the value
       end
   end,
})

-- JumpPower Input (created only once)
local JumpPowerInput = MainTab:CreateInput({
   Name = "JumpPower (Normal Jump = 50)",
   CurrentValue = tostring(savedJumpPower), -- Set initial value to savedJumpPower
   PlaceholderText = "Enter Power",
   RemoveTextAfterFocusLost = false,
   Flag = "input_jp",
   Callback = function(Text)
       local Value = tonumber(Text)
       if humanoid and Value then
           savedJumpPower = math.clamp(Value, 1, 350) -- Save the new value
           humanoid.JumpPower = savedJumpPower -- Apply the value
       end
   end,
})

-- Function to reset humanoid and inputs when respawning
local function onCharacterAdded(character)
    humanoid = character:WaitForChild("Humanoid")

    -- Apply saved WalkSpeed and JumpPower to the new character's humanoid
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        humanoid.WalkSpeed = savedWalkSpeed
    end)
    humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        humanoid.JumpPower = savedJumpPower
    end)

    -- Ensure the values are set immediately
    humanoid.WalkSpeed = savedWalkSpeed
    humanoid.JumpPower = savedJumpPower

    -- Update the input boxes with the saved values
    WalkSpeedInput:Set(tostring(savedWalkSpeed))
    JumpPowerInput:Set(tostring(savedJumpPower))
end

-- Rebind humanoid and inputs when character respawns
player.CharacterAdded:Connect(onCharacterAdded)

-- Initialize for the first time in case the character is already in the game
if player.Character then
    onCharacterAdded(player.Character)
end

--Infinity Jump

local localPlayer = game:GetService("Players").LocalPlayer
local userInputService = game:GetService("UserInputService")
local infiniteJumpEnabled = false

local Toggle = MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "infinite_jump_flag",
   Callback = function(Value)
        infiniteJumpEnabled = Value

        if infiniteJumpEnabled then
            -- Powiadomienie o aktywacji
            game.StarterGui:SetCore("SendNotification", {
                Title = "Qwee Hub",
                Text = "Infinite Jump Activated!",
                Duration = 5
            })
        end
   end
})

-- Obsługa skoku
userInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)


-- Noclip

local RunService = game:GetService("RunService")
local localPlayer = game:GetService("Players").LocalPlayer
local noclipLoop

local Toggle = MainTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "klpn444",
   Callback = function(Value)
        if Value then
            -- Włączanie Noclip
            noclipLoop = RunService.Stepped:Connect(function()
                if localPlayer.Character then
                    for _, part in pairs(localPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- Natychmiastowe wyłączenie Noclip
            if noclipLoop then 
                noclipLoop:Disconnect()
                noclipLoop = nil
            end
            
            -- Przywrócenie kolizji od razu po wyłączeniu
            if localPlayer.Character then
                for _, part in pairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
   end
})

--Fly------------------------------------------------------------------------------------------------------------------
local localPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local flyEnabled = false
local flySpeed = 50
local FLY_SPEED_MULTIPLIER = 2
local activeKeys = {}
local bodyVelocity
local bodyGyro
local flyConnection

-- Klawisze sterowania lotem
local flyKeys = {
    Forward = Enum.KeyCode.S,
    Backward = Enum.KeyCode.W,
    Left = Enum.KeyCode.A,
    Right = Enum.KeyCode.D,
    Up = Enum.KeyCode.Space,
    Down = Enum.KeyCode.LeftShift
}

local function getHumanoid()
    return localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
end

local function toggleFly()
    flyEnabled = not flyEnabled

    if flyEnabled then
        -- Włączenie lotu
        local humanoid = getHumanoid()
        local rootPart = humanoid and humanoid.RootPart

        if humanoid and rootPart then
            humanoid.PlatformStand = true
            
            -- Tworzenie obiektów fizyki
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = 10000
            bodyGyro.D = 100
            bodyGyro.MaxTorque = Vector3.new(20000, 20000, 20000)
            bodyGyro.CFrame = rootPart.CFrame
            bodyGyro.Parent = rootPart
            
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new()
            bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
            bodyVelocity.Parent = rootPart
            
            -- Start lotu
            flyConnection = RunService.Heartbeat:Connect(function()
                if not flyEnabled or not bodyVelocity or not bodyGyro then return end
                
                local currentSpeed = flySpeed
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    currentSpeed = flySpeed * FLY_SPEED_MULTIPLIER
                end
                
                -- Kierunek lotu
                local camera = workspace.CurrentCamera
                local cameraCFrame = camera.CFrame
                local direction = Vector3.new()

                if activeKeys[flyKeys.Forward] then direction -= cameraCFrame.LookVector end
                if activeKeys[flyKeys.Backward] then direction += cameraCFrame.LookVector end
                if activeKeys[flyKeys.Left] then direction -= cameraCFrame.RightVector end
                if activeKeys[flyKeys.Right] then direction += cameraCFrame.RightVector end
                if activeKeys[flyKeys.Up] then direction += cameraCFrame.UpVector end
                if activeKeys[flyKeys.Down] then direction -= cameraCFrame.UpVector end

                if direction.Magnitude > 0 then
                    bodyVelocity.Velocity = direction.Unit * currentSpeed
                else
                    bodyVelocity.Velocity = Vector3.new()
                end

                bodyGyro.CFrame = cameraCFrame
            end)
        end
    else
        -- Wyłączenie lotu
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

-- Obsługa klawiszy
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if flyEnabled and not gameProcessed then
        activeKeys[input.KeyCode] = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if flyEnabled then
        activeKeys[input.KeyCode] = nil
    end
end)

-- Tworzenie Toggle dla Fly
local flyToggle = MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "fly_toggle",
    Callback = function(Value)
        toggleFly()
    end
})

-----------------blerelroew

-- Przycisk do załadowania i uruchomienia kodu
local LoadButton = MainTab:CreateButton({
    Name = "Load Infinite Yield",
    Flag = "Button1", -- Flag identyfikująca przycisk
    Callback = function()
        -- Wykonanie kodu z zewnętrznego URL
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end)
    end,
})


---------------------------------------------------Auto Farm-----------------------------------------------------------------------------------------------------------
local AutoTab = Window:CreateTab("Auto things", nil)
local AutoSection = AutoTab:CreateSection("Main")


-- Flaga teleportacji
local teleportEnabled = false

-- Lista odwiedzonych Coin_Server
local visitedCoinServers = {}

-- Funkcja znajdowania dostępnych Coin_Server
local function getAvailableCoinServers()
    local availableServers = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("CoinContainer") then
            local coinContainer = obj.CoinContainer
            local coinServer = coinContainer:FindFirstChild("Coin_Server")
            if coinServer and not visitedCoinServers[coinServer] then
                table.insert(availableServers, coinServer)
            end
        end
    end
    return availableServers
end

-- Funkcja teleportowania do Coin_Server
local function teleportToCoinServer()
    local availableServers = getAvailableCoinServers()
    if #availableServers > 0 then
        local randomServer = availableServers[math.random(1, #availableServers)]
        if randomServer and randomServer:IsA("Part") then
            local rootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(randomServer.Position)
                visitedCoinServers[randomServer] = true
                wait(0.5) 
            end
        end
    end
end

-- Toggle funkcja
local ToggleCoinFarm = AutoTab:CreateToggle({ 
   Name = "Auto Coin Farm",
   CurrentValue = false,
   Flag = "ToggleCoinFarm",
   Callback = function(Value)
       teleportEnabled = Value
       if teleportEnabled then
           while teleportEnabled do
               teleportToCoinServer()
               wait(0.5)
           end
       end
   end
})

----kill all


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Ensure the player has a knife
local function ensureKnife()
    local char = LocalPlayer.Character
    if not char then return false end
    
    local knife = char:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    if knife then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:EquipTool(knife)
        end
        return true
    end

    -- Notification if the player is not the murderer
    Rayfield:Notify({
        Title = "Error",
        Content = "You are not the murderer!",
        Duration = 3,
        
    })

    return false
end

-- Kill all players function
local function killAllPlayers()
    if not ensureKnife() then return end  -- Ensure the knife is equipped

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if targetRoot and localRoot then
                -- Ensure they don't get stuck
                targetRoot.Anchored = false
                
                -- Move the player near the murderer (small offset)
                targetRoot.CFrame = localRoot.CFrame * CFrame.new(0, 0, -2)
                wait(0.1)  -- Prevents the script from freezing
            end
        end
    end

    -- Fire the stab action
    local knife = LocalPlayer.Character:FindFirstChild("Knife")
    if knife and knife:FindFirstChild("Stab") then
        knife.Stab:FireServer("Slash")
    else
        warn("Knife Stab action missing!")
    end
end

-- Create button
local Button = AutoTab:CreateButton({ 
   Name = "Kill All (Works with Murder)", 
   Callback = function()
       killAllPlayers() -- Calls the function when pressed
   end,
})











----- esp

local espTab = Window:CreateTab("👩🏻ESP", nil)
local espSection = espTab:CreateSection("Main")


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Flaga ESP
local espEnabled = false

-- Funkcja do pobierania roli gracza
local function getPlayerRole(player)
    if player.Backpack then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("knife") then return "Murderer" end
                if name:find("gun") then return "Sheriff" end
            end
        end
    end

    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("knife") then return "Murderer" end
                if name:find("gun") then return "Sheriff" end
            end
        end
    end

    return "Innocent"
end

-- Funkcja do tworzenia lub usuwania ESP
local function toggleESP(state)
    espEnabled = state
    if not espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChild("ESP_Highlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

-- Funkcja aktualizująca ESP dla wszystkich graczy
local function updateESP()
    if not espEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local role = getPlayerRole(player)
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.Parent = player.Character
                highlight.Adornee = player.Character
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Widoczne przez ściany
                highlight.FillTransparency = 0.5 -- Półprzezroczysty overlay
            end
            
            -- Ustawianie koloru według roli
            if role == "Murderer" then
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Czerwony
            elseif role == "Sheriff" then
                highlight.FillColor = Color3.fromRGB(0, 0, 255) -- Niebieski
            else
                highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Zielony (Innocent)
            end
        end
    end
end

-- Regularne odświeżanie ESP
RunService.RenderStepped:Connect(updateESP)

-- Toggle funkcja
local ToggleESP = espTab:CreateToggle({ 
   Name = "ESP Toggle",
   CurrentValue = false,
   Flag = "ToggleESP",
   Callback = function(Value)
       toggleESP(Value)
   end,
})

---3132

-- Funkcja włączająca/wyłączająca ESP
local function toggleESP(enabled)
    local normal = workspace:FindFirstChild("Normal")
    if normal then
        for _, gunDrop in ipairs(normal:GetChildren()) do
            if gunDrop.Name == "GunDrop" then
                local highlight = gunDrop:FindFirstChild("Highlight")
                if enabled and not highlight then
                    -- Tworzymy Highlight dla broni, jeśli nie istnieje
                    local blah = Instance.new("Highlight")
                    blah.Parent = gunDrop
                    blah.FillColor = Color3.fromRGB(7, 0, 255)
                    blah.OutlineTransparency = 0.75
                elseif not enabled and highlight then
                    -- Usuwamy Highlight, jeśli istnieje
                    highlight:Destroy()
                end
            end
        end
    end
end

-- Funkcja sprawdzająca nowe "GunDrop" i dodająca do nich highlight
local function checkForNewGunDrops()
    workspace.ChildAdded:Connect(function(child)
        if child.Name == "Normal" then
            for _, gunDrop in ipairs(child:GetChildren()) do
                if gunDrop.Name == "GunDrop" and not gunDrop:FindFirstChild("Highlight") then
                    -- Dodajemy Highlight, jeśli go nie ma
                    local blah = Instance.new("Highlight")
                    blah.Parent = gunDrop
                    blah.FillColor = Color3.fromRGB(7, 0, 255)
                    blah.OutlineTransparency = 0.75
                end
            end
        end
    end)
end

-- Przełącznik do włączania/wyłączania ESP
local Toggle = espTab:CreateToggle({
    Name = "Toggle ESP",
    CurrentValue = false,
    Flag = "Toggle1",  -- Flag do zapisywania stanu
    Callback = function(Value)
        toggleESP(Value)  -- Włączamy lub wyłączamy ESP w zależności od wartości przełącznika
    end,
})

-- Uruchomienie funkcji sprawdzającej nowe "GunDrop" (tylko raz, po załadowaniu gry)
spawn(function()
    checkForNewGunDrops()
end)


------- Fun

local funTab = Window:CreateTab("🏠Fun", nil) -- Title, Image
local funSection = funTab:CreateSection("Main")

local Button = funTab:CreateButton({
    Name = "Chat Expose Roles",
    Callback = function()
        local allPlayers = game.Players:GetPlayers()

        for _, player in pairs(allPlayers) do
            local backpack = player:FindFirstChild("Backpack")
            
            if backpack then
                if backpack:FindFirstChild("Knife") then
                    local args = {
                        [1] = player.Name .. ": Has The Knife",
                        [2] = "normalchat"
                    }

                    game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(unpack(args))
                end
                
                if backpack:FindFirstChild("Gun") then
                    local args = {
                        [1] = player.Name .. ": Has The Gun",
                        [2] = "normalchat"
                    }

                    game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(unpack(args))
                end
            end
        end
    end,
})

local Label = funTab:CreateLabel("Gun Not Dropped")
coroutine.wrap(function()
    local gunDropped = false
    while wait(1) do
        local gunExists = Workspace:FindFirstChild("GunDrop")
        
        if gunExists then
            Label:Set("Gun Dropped")
            
            if not gunDropped then
                gunDropped = true
                Rayfield:Notify({
                    Title = "Gun Status",
                    Content = "Gun Dropped",
                    Duration = 6.5,
                    Image = 5578470911,
                    Actions = {
                        Ignore = {
                            Name = "Okay!",
                            Callback = function()
                                print("The user tapped Okay!")
                            end
                        },
                    },
                })
            end
        else
            Label:Set("Gun Not Dropped")
            gunDropped = false
        end
    end
end)()

-- Correct labels for murderer and sheriff
local MurdererLabel = funTab:CreateLabel("Murderer is: Unknown")
local SheriffLabel = funTab:CreateLabel("Sheriff is: Unknown")

-- Function to check and update the roles based on tools in players' backpacks
local function updateRolesInfo()
    while true do
        local players = game:GetService("Players"):GetPlayers()
        local murderer, sheriff = "Unknown", "Unknown"

        for _, player in ipairs(players) do
            if player.Character and player.Backpack then
                local backpack = player.Backpack
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        if tool.Name == "Knife" then
                            murderer = player.Name
                        elseif tool.Name == "Gun" then
                            sheriff = player.Name
                        end
                    end
                end
            end
        end

        -- Update the labels with the correct names
        MurdererLabel:Set("Murderer is: " .. murderer)
        SheriffLabel:Set("Sheriff is: " .. sheriff)

        wait(1)
    end
end

-- Run the updateRolesInfo function in a coroutine to continuously update roles for all players
coroutine.wrap(updateRolesInfo)()


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local speaker = Players.LocalPlayer
local walkflinging = false

local function getRoot(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local Toggle = funTab:CreateToggle({
   Name = "Walk Fling",
   CurrentValue = false,
   Flag = "ToggleWalkFling",
   Callback = function(Value)
       walkflinging = Value
   end,
})

task.spawn(function()
    while true do
        if walkflinging then
            local character = speaker.Character
            local root = getRoot(character)

            if character and root then
                local originalVelocity = root.Velocity

                -- Dodaj efekt flingu
                root.Velocity = originalVelocity * 10000 + Vector3.new(0, 10000, 0)

                RunService.RenderStepped:Wait()

                -- Przywróć poprzednią prędkość
                if character.Parent and root.Parent then
                    root.Velocity = originalVelocity
                end

                RunService.Stepped:Wait()

                -- Delikatny efekt "bujania"
                root.Velocity = originalVelocity + Vector3.new(0, 0.1, 0)
            end
        end
        RunService.Heartbeat:Wait()
    end
end)



-----------------------------------bry


-- Objects
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")



-- Create BodyAngularVelocity (Increased Angular Velocity)
local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
BodyAngularVelocity.AngularVelocity = Vector3.new(10^8, 10^8, 10^8) -- Bigger number for stronger fling
BodyAngularVelocity.MaxTorque = Vector3.new(10^8, 10^8, 10^8) -- Larger max torque to apply more force
BodyAngularVelocity.P = 10^8 -- Increase the force applied

-- Function to get the player's role (Murderer, Sheriff, Innocent)
local function getPlayerRole(player)
    if player.Backpack then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("knife") then return "Murderer" end
                if name:find("gun") then return "Sheriff" end
            end
        end
    end
    return "Innocent"
end



-- Fling Murderer Button
local flingMurdererButton = funTab:CreateButton({
    Name = "Fling Murderer",
    Callback = function()
        -- Loop through all players to find Murderer
        for _, player in pairs(Players:GetPlayers()) do
            if getPlayerRole(player) == "Murderer" then
                local targetCharacter = player.Character
                if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
                    -- Apply BodyAngularVelocity to the target for fling
                    BodyAngularVelocity.Parent = targetCharacter.HumanoidRootPart

                    -- Teleport LocalPlayer to Target
                    while targetCharacter.HumanoidRootPart and LocalPlayer.Character.HumanoidRootPart do
                        RunService.RenderStepped:Wait()

                        -- Teleport LocalPlayer's CFrame to Target's CFrame without affecting movement
                        LocalPlayer.Character.HumanoidRootPart.CFrame = targetCharacter.HumanoidRootPart.CFrame * LocalPlayer.Character.HumanoidRootPart.CFrame.Rotation
                        LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new()  -- Prevent unwanted movement

                        -- Apply the AngularVelocity to fling the target
                        BodyAngularVelocity.AngularVelocity = Vector3.new(10^7, 10^7, 10^7)  -- Stronger fling effect
                    end
                end
                break  -- Stop the loop after finding the Murderer
            end
        end
    end,
})

-- Fling Sheriff Button
local flingSheriffButton = funTab:CreateButton({
    Name = "Fling Sheriff",
    Callback = function()
        -- Loop through all players to find Sheriff
        for _, player in pairs(Players:GetPlayers()) do
            if getPlayerRole(player) == "Sheriff" then
                local targetCharacter = player.Character
                if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
                    -- Apply BodyAngularVelocity to the target for fling
                    BodyAngularVelocity.Parent = targetCharacter.HumanoidRootPart

                    -- Teleport LocalPlayer to Target
                    while targetCharacter.HumanoidRootPart and LocalPlayer.Character.HumanoidRootPart do
                        RunService.RenderStepped:Wait()

                        -- Teleport LocalPlayer's CFrame to Target's CFrame without affecting movement
                        LocalPlayer.Character.HumanoidRootPart.CFrame = targetCharacter.HumanoidRootPart.CFrame * LocalPlayer.Character.HumanoidRootPart.CFrame.Rotation
                        LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new()  -- Prevent unwanted movement

                        -- Apply the AngularVelocity to fling the target
                        BodyAngularVelocity.AngularVelocity = Vector3.new(10^7, 10^7, 10^7)  -- Stronger fling effect
                    end
                end
                break  -- Stop the loop after finding the Sheriff
            end
        end
    end,
})










---- teleport

local TeleportTab = Window:CreateTab("👽 Teleport", nil) -- Title, Image
local TeleportSection = TeleportTab:CreateSection("Main")


-------------------------------------------------------Teleport to PLayer----------------------------------------------------------------

-- Reference to the Players service
local playersFolder = game:GetService("Players")
local localPlayer = playersFolder.LocalPlayer

-- Toggle for enabling/disabling teleportation
local TELEPORT_ENABLED = false
TeleportTab:CreateToggle({
    Name = "Enable Teleport",
    CurrentValue = TELEPORT_ENABLED,
    Flag = "Teleport_Toggle",
    Callback = function(value)
        TELEPORT_ENABLED = value
    end
})

-- Function to get all player names (excluding local player)
local function getPlayerNames()
    local playerNames = {}
    for _, player in ipairs(playersFolder:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

-- Variable to store the dropdown instance
local playerDropdown = nil

-- Variable to track if the dropdown selection is being updated programmatically
local isProgrammaticUpdate = false

-- Function to create or update the dropdown
local function updateDropdown()
    local playerNames = getPlayerNames()

    -- If dropdown already exists, refresh and update its options
    if playerDropdown then
        -- Set flag to indicate programmatic update
        isProgrammaticUpdate = true

        -- Refresh options only if there is a change in the player list
        local currentOption = playerDropdown.CurrentOption
        if currentOption and not table.find(playerNames, currentOption) then
            currentOption = playerNames[1]  -- Default to first player if the previous selection is no longer valid
        end

        playerDropdown:Refresh(playerNames)  -- Update the options list
        playerDropdown:Set({currentOption or playerNames[1]})  -- Update the selected option

        -- Reset flag after programmatic update
        isProgrammaticUpdate = false
    else
        -- Create a new dropdown if it doesn't exist
        playerDropdown = TeleportTab:CreateDropdown({
            Name = "Select Player",
            Options = playerNames,
            CurrentOption = #playerNames > 0 and playerNames[1] or "",
            Flag = "Teleport_Dropdown",
            Callback = function(selected)
                -- Skip teleportation if the update is programmatic
                if isProgrammaticUpdate then
                    return
                end

                -- Handle manual selection
                local selectedName = type(selected) == "table" and selected[1] or selected

                -- Validate selected player
                local selectedPlayer = playersFolder:FindFirstChild(selectedName)
                if not selectedPlayer then
                    return
                end

                -- Validate teleportation conditions
                if TELEPORT_ENABLED then
                    local targetChar = selectedPlayer.Character
                    if not targetChar then
                        return
                    end

                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then
                        return
                    end

                    local localChar = localPlayer.Character
                    if not localChar then
                        return
                    end

                    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                    if not localRoot then
                        return
                    end

                    -- Perform teleportation
                    localRoot.CFrame = targetRoot.CFrame
                end
            end
        })
    end
end

-- Create the dropdown initially
updateDropdown()

-- Update dropdown when players join/leave, but don't trigger teleportation
local lastPlayerCount = #getPlayerNames()

playersFolder.PlayerAdded:Connect(function(player)
    local currentPlayerCount = #getPlayerNames()
    if currentPlayerCount > lastPlayerCount then
        updateDropdown()  -- Recreate or refresh dropdown with updated player list
        lastPlayerCount = currentPlayerCount
    end
end)

playersFolder.PlayerRemoving:Connect(function(player)
    local currentPlayerCount = #getPlayerNames()
    if currentPlayerCount < lastPlayerCount then
        updateDropdown()  -- Recreate or refresh dropdown with updated player list
        lastPlayerCount = currentPlayerCount
    end
end)

------ teleport to map and lobby


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Funkcja teleportująca do lobby
local function Teleport_to_lobby()
    LocalPlayer.Character:MoveTo(Vector3.new(-107, 152, 41))
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Funkcja do znalezienia aktywnej mapy (wykluczając lobby)
local function getMap()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Spawns") and not obj.Name:lower():find("lobby") then
            return obj
        end
    end
    return nil
end

-- Funkcja teleportująca do losowego miejsca na mapie
local function Teleport_to_map()
    local map = getMap()
    if map then
        local spawnsFolder = map:FindFirstChild("Spawns")
        if spawnsFolder then
            -- Przechodzimy po wszystkich częściach w folderze 'Spawns'
            local spawnParts = {}
            for _, spawn in ipairs(spawnsFolder:GetChildren()) do
                if spawn:IsA("BasePart") then
                    table.insert(spawnParts, spawn)
                end
            end

            -- Teleportuj do losowego spawn, jeśli istnieje
            if #spawnParts > 0 then
                local randomSpawn = spawnParts[math.random(1, #spawnParts)]
                LocalPlayer.Character:MoveTo(randomSpawn.Position)
            end
        end
    end
end




-- Tworzenie przycisku teleportacji do lobby
local TeleportToLobbyButton = TeleportTab:CreateButton({
    Name = "Teleport to Lobby",
    Callback = function()
        Teleport_to_lobby() -- Teleportacja do lobby
    end,
})

-- Tworzenie przycisku teleportacji na mapę
local TeleportToMapButton = TeleportTab:CreateButton({
    Name = "Teleport to Map",
    Callback = function()
        Teleport_to_map() -- Teleportacja na losowy spawn na mapie
    end,
})



-- Funkcja teleportująca do GunDrop
local function Teleport_to_gun()
    local map = getMap()  -- Pobierz mapę
    if map and map:FindFirstChild("GunDrop") then
        local gunDrop = map:FindFirstChild("GunDrop")  -- Znajdź GunDrop
        local previousPosition = LocalPlayer.Character:GetPivot()  -- Zapisz poprzednią pozycję

        -- Teleportuj gracza do GunDrop
        LocalPlayer.Character:PivotTo(gunDrop:GetPivot())

        -- Czekaj, aż gracz podniesie broń z ziemi
        LocalPlayer.Backpack.ChildAdded:Wait()

        -- Po podniesieniu broni, teleportuj gracza z powrotem do poprzedniej pozycji
        LocalPlayer.Character:PivotTo(previousPosition)
    end
end

-- Tworzenie przycisku teleportacji do GunDrop
local TeleportToGunButton = TeleportTab:CreateButton({
    Name = "Teleport to Gun",
    Callback = function()
        Teleport_to_gun()  -- Wywołaj funkcję teleportacji do GunDrop
    end,
})




local sheriffDeadNotified = false  -- Flaga do sprawdzania, czy powiadomienie o martwym sheriffie zostało już wyświetlone
local gunDroppedNotified = false  -- Flaga do sprawdzania, czy powiadomienie o broń leżącej na ziemi zostało już wyświetlone

-- Funkcja monitorująca stan sheriffa i sprawdzająca, czy broń leży na ziemi
local function MonitorGunDrop()
    local map = getMap()  -- Pobierz mapę
    if map then
        local gunDrop = map:FindFirstChild("GunDrop")  -- Szukaj GunDrop w modelu mapy
        if gunDrop and gunDrop:IsA("BasePart") then
            -- Sprawdź, czy broń leży na ziemi (możesz dostosować warunki)
            if gunDrop.Position.Y < 0 then  -- Zakładamy, że broń leży na ziemi, gdy Y jest mniejsze niż 0
                -- Wyświetl powiadomienie tylko jeśli jeszcze nie było wyświetlone
                if not gunDroppedNotified then
                    Rayfield:Notify({
                        Title = "Gun Dropped",
                        Content = "The gun is on the floor and ready for pickup!",
                        Duration = 4,
                        
                    })
                    gunDroppedNotified = true  -- Ustaw flagę, aby nie pokazywać powiadomienia ponownie
                end
            end
        end
    end
end


-- Funkcja monitorująca stan sheriffa (martwy sheriff)
local function MonitorSheriffDeath()
    local sheriffDead = true  -- Zmienna oznaczająca, że sheriff jest martwy

    -- Sprawdzamy, czy sheriff nie żyje
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            -- Jeżeli gracz jest sheriffem i jego zdrowie wynosi 0, oznacza to, że jest martwy
            if getPlayerRole(player) == "Sheriff" and humanoid.Health <= 0 then
                sheriffDead = true
                break
            else
                sheriffDead = false
            end
        end
    end

    -- Jeśli sheriff jest martwy, sprawdzamy stan broni
    if sheriffDead and not sheriffDeadNotified then
        -- Wyświetl powiadomienie o śmierci sheriffa i broni na ziemi
        Rayfield:Notify({
            Title = "Sheriff is Dead",
            Content = "Gun is On the floor! Pick it up!",
            Duration = 4,
            
        })
        sheriffDeadNotified = true  -- Ustaw flagę, aby nie pokazywać powiadomienia ponownie
    end
end

-- Funkcja do resetowania flag, jeśli sheriff wróci do życia lub broń zostanie zabrana
local function ResetNotifications()
    -- Resetuj powiadomienia, jeśli sheriff żyje lub broń została zabrana
    sheriffDeadNotified = false
    gunDroppedNotified = false
end

-- Wywołanie monitorowania co sekundę
while true do
    MonitorSheriffDeath()
    MonitorGunDrop()
    wait(1)  -- Sprawdza stan sheriffa i broni co sekundę
end


