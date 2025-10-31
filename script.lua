local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.ZIndex = 10
FOVCircle.Transparency = 1
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 0) -- green
FOVCircle.Filled = false


local ESPHighlights = {}
local ESPConnections = {}

local Window = Library:CreateWindow({
    Title = 'sahur.lol | the greatest universal south bronx exploit',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
	Visuals = Window:AddTab('Visuals'),
    GunModsTab =  Window:AddTab('Gun Mods'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local MainGroupBox = Tabs.Main:AddLeftGroupbox('Kill Exploits')
local HitboxGroupBox = Tabs.Main:AddRightGroupbox('Hitbox')
local EspGroupBox = Tabs.Visuals:AddLeftGroupbox('ESP')
local SecondaryGroupBox = Tabs.Main:AddRightGroupbox('Secondary')
local GunModsGroup = Tabs.GunModsTab:AddLeftGroupbox('Gun Mods')



local function UpdateGunSettings(callback)
    for _, container in pairs({ LocalPlayer.Backpack, LocalPlayer.Character }) do
        for _, tool in pairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local module = tool:FindFirstChild("Setting")
                if module and module:IsA("ModuleScript") then
                    local success, settings = pcall(require, module)
                    if success and type(settings) == "table" then
                        local ok, err = pcall(callback, settings)
                        if ok then
                            -- Apply back any changed table fields (some games re-read modules)
                            for key, value in pairs(settings) do
                                settings[key] = value
                            end
                        else
                            warn("Failed to update setting:", err)
                        end
                    end
                end
            end
        end
    end
end



GunModsGroup:AddToggle('NoRecoil', {
    Text = 'No Recoil',
    Default = false,
    Tooltip = 'Disables gun recoil. (Non functional)',
    Callback = function(val)
        UpdateGunSettings(function(module)
            module.RecoilingEnabled = not val and true or false
        end)
    end
})

GunModsGroup:AddToggle('InfAmmo', {
    Text = 'Infinite Ammo',
    Default = false,
    Tooltip = 'Gives you infinite ammo',
    Callback = function(val)
        UpdateGunSettings(function(module)
            module.Ammo = math.huge
            module.MaxAmmo = math.huge
        end)
    end
})

-- // AUTO FIRE
GunModsGroup:AddToggle('FullAuto', {
    Text = 'Auto',
    Default = false,
    Tooltip = 'Forces guns to fire automatically.',
    Callback = function(val)
        UpdateGunSettings(function(module)
            module.Auto = val
        end)
    end
})

GunModsGroup:AddToggle('Explosive', {
    Text = 'Explosive (doesnt work in most games)',
    Default = false,
    Tooltip = 'Makes your gun explosive [Does NOT work in most games]',
    Callback = function(val)
        UpdateGunSettings(function(module)
            module.ExplosiveEnabled = val
        end)
    end
})

GunModsGroup:AddSlider('FireRate', {
    Text = 'Set FireRate',
    Default = 0.1,
    Min = 0.001,
    Max = 2,
    Rounding = 3,
    Tooltip = 'Sets how quickly your weapon fires.',
    Callback = function(value)
        UpdateGunSettings(function(module)
            module.FireRate = value
        end)
    end
})

-- // DAMAGE SLIDER
GunModsGroup:AddSlider('GunDamage', {
    Text = 'Set Damage',
    Default = 25,
    Min = 1,
    Max = 200,
    Rounding = 0,
    Tooltip = 'Sets weapon base damage.',
    Callback = function(value)
        UpdateGunSettings(function(module)
            module.BaseDamage = value
        end)
    end
})

SecondaryGroupBox:AddToggle('SilentAimMethod2', {
    Text = 'Silent Aim (Secondary Method)',
    Default = false, -- Default value (true / false)
    Tooltip = 'This toggle will enable silent aim.', -- Information shown when you hover over the toggle

	Callback = function(value)
    if value then
        -- Toggle turned ON
		FOVCircle.Visible = value
        SilentAimWallBangMethod2(value)  -- run your function or start connection
    else
        -- Toggle turned OFF
		FOVCircle.Visible = value
        SilentAimWallBangMethod2(value)  -- run your function or start connection
        -- You can also disconnect any connections here if needed
    end
end

})

EspGroupBox:AddToggle('ESPBoxes', {
	Text = 'ESP Highlight',
    Default = false, -- Default value (true / false)
    Tooltip = 'This toggle will enable ESP Highlight for characters.', -- Information shown when you hover over the toggle

	Callback = function(value)
    if value then
        StartESP()
    else
        StopESP()
    end
end
})

EspGroupBox:AddToggle('ESPNames', {
	Text = 'ESP Names',
	Default = false,
	Tooltip = 'This toggle will show player name labels above their heads.',
	Callback = function(value)
		if value then
			StartESPNames()
		else
			StopESPNames()
		end
	end
})

EspGroupBox:AddToggle('ESPHealthCheck', {
	Text = 'Health Check',
	Default = true,
	Tooltip = 'Only show ESP for alive players',
})
HitboxGroupBox:AddToggle('HitboxExpander', {
	Text = 'Hitbox Expander',
	Default = false,
	Tooltip = 'Expands enemy hitboxes for easier targeting.',
	Callback = function(enabled)
		if enabled then
			StartHitboxExpander()
		else
			StopHitboxExpander()
		end
	end
})

HitboxGroupBox:AddSlider('HitboxSize', {
	Text = 'Hitbox Size',
	Default = 1.5,
	Min = 1,
	Max = 5.8,
	Rounding = 2,
	Compact = false,
	Tooltip = 'Controls how large the hitboxes expand to.',
})







-- kill exploits
MainGroupBox:AddToggle('SilentAim', {
    Text = 'Silent Aim',
    Default = false, -- Default value (true / false)
    Tooltip = 'This toggle will enable silent aim.', -- Information shown when you hover over the toggle

	Callback = function(value)
    if value then
        -- Toggle turned ON
		FOVCircle.Visible = value
        SilentAimWallBang(value)  -- run your function or start connection
    else
        -- Toggle turned OFF
		FOVCircle.Visible = value
        SilentAimWallBang(value)  -- run your function or start connection
        -- You can also disconnect any connections here if needed
    end
end

})

MainGroupBox:AddSlider('SilentFOV', {
       Text = 'Silent Aim FOV',

    -- Text, Default, Min, Max, Rounding must be specified.
    -- Rounding is the number of decimal places for precision.

    -- Example:
    -- Rounding 0 - 5
    -- Rounding 1 - 5.1
    -- Rounding 2 - 5.15
    -- Rounding 3 - 5.155

    Default = 100,
    Min = 1,
    Max = 1000,
    Rounding = 0,

    Compact = false, -- If set to true, then it will hide the label
})

MainGroupBox:AddSlider('SilentDamage', {
       Text = 'Silent Aim Damage',

    -- Text, Default, Min, Max, Rounding must be specified.
    -- Rounding is the number of decimal places for precision.

    -- Example:
    -- Rounding 0 - 5
    -- Rounding 1 - 5.1
    -- Rounding 2 - 5.15
    -- Rounding 3 - 5.155

    Default = 28,
    Min = 1,
    Max = 100,
    Rounding = 0,

    Compact = false, -- If set to true, then it will hide the label
})

MainGroupBox:AddToggle('KillAll', {
    Text = 'Kill All',
    Default = false, -- Default value (true / false)
    Tooltip = 'This toggle will kill everyone in the game at once infinitely.', -- Information shown when you hover over the toggle

	Callback = function(value)
    if value then
        -- Toggle turned ON
        KillAll(value)  -- run your function or start connection
    else
        -- Toggle turned OFF
        KillAll(value)  -- run your function or start connection
        -- You can also disconnect any connections here if needed
    end
end
})


-- crash methods
local secondarygroupbox = Tabs.Main:AddLeftGroupbox('Crash Methods')

secondarygroupbox:AddToggle('DeleteMap', {
	Text = 'Delete Map',
	Default = false,
	Tooltip = 'Enabling this will delete the entire map.',
	Callback = function(value)
    	if value then
        -- Toggle turned ON
        DeleteMap(value)  -- run your function or start connection
    else
        -- Toggle turned OFF
        DeleteMap(value)  -- run your function or start connection
        -- You can also disconnect any connections here if needed
    	end
	end	
})
secondarygroupbox:AddToggle('AudioCrash', {
	Text = 'Audio Crash',
	Default = false,
	Tooltip = 'Enabling this will crash the game via audio spam. (Currently does not work.)'
})

Library:SetWatermarkVisibility(false)

-- Example of dynamically-updating watermark with common traits (fps and ping)
local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    Library:SetWatermark(('sahur.lol | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

Library.KeybindFrame.Visible = true; -- todo: add a function for this

Library:OnUnload(function()
    WatermarkConnection:Disconnect()

    print('Unloaded!')
    Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

-- I set NoUI so it does not show up in the keybinds menu
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'Insert', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('sahur')
SaveManager:SetFolder('sahur/SouthBronxTheTrenches')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

local clickConnection

-- actual scripts
function SilentAimWallBang(val)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local InflictTarget = ReplicatedStorage:FindFirstChild("InflictTarget", true)
if not InflictTarget then
    warn("InflictTarget not found")
    return
end

local function getNearestPlayerToCursor()
    local mousePos = UserInputService:GetMouseLocation()
    local closestPlayer
    local shortestDistance = Options.SilentFOV.Value -- <-- use the slider value as the limit

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
            local rootPos = player.Character.HumanoidRootPart.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end


local function onClick()
    local targetPlayer = getNearestPlayerToCursor()
    if not targetPlayer then return end

    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") 
                or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if not tool then
        warn("no tool")
        return
    end

    local toolPart = tool:FindFirstChildWhichIsA("BasePart")
    if not toolPart then
        warn("no basepart")
        return
    end

    local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    local args = {
        toolPart,
        LocalPlayer,
        humanoid,
        humanoid,
        Options.SilentDamage.Value,
        {0, 0, false, false, 100, 100},
        {false, 0, 3},
        rootPart,
        {false, {245631555, 245030056, 245631167}, 0, 10, nil},
        Vector3.new(-451.23, 4.08, -424.57),
        Vector3.new(0.731, -0.457, 0.507),
        1760303386.61,
        Vector3.new(1.558, 1.978, 1.149)
    }

    local success, result = pcall(function()
        return InflictTarget:InvokeServer(unpack(args))
    end)

    if not success then
        warn("failed to invoke: ", result)
    end
end
	if val then
        if not clickConnection then
            clickConnection = UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    onClick()
                end
            end)
        end
    else
        if clickConnection then
            clickConnection:Disconnect()
            clickConnection = nil
        end
    end
end




local clickConnection2 -- separate connection for method2

local function getNearestPlayerToCursorMethod2()
    -- independent nearest-player helper (keeps same behavior as your original)
    local mousePos = UserInputService:GetMouseLocation()
    local closestPlayer
    local shortestDistance = Options and Options.SilentFOV and Options.SilentFOV.Value or 100

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local rootPos = player.Character.HumanoidRootPart.Position
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end

    return closestPlayer
end

local function buildArgsMethod2(attackerPlayer, tool, attacker, targetHumanoid, targetRoot, targetHead)
    local idList = {8473920101, 8473920102, 8473920103}

    local args = {
        attackerPlayer,                                            -- 1: LocalPlayer (caller)
        tool,                                                      -- 2: tool instance
        attacker,                                                  -- 3: attacker (LocalPlayer)
        targetHumanoid,                                            -- 4: nearest player's humanoid
        targetRoot,                                                -- 5: nearest player's rootpart
        100,                                                       -- 6: kept as 100 per your sample
        {0, 0, false, false, nil, nil, 100, 100},                 -- 7: flags/values (placeholders)
        {false, 0, 3},                                             -- 8: small table
        targetHead,                                                -- 9: target head instance
        {                                                           -- 10: complex options table
            true,
            idList,
            0.9,
            1.2,
            1.0,
            (function()                                              -- create a particle emitter and return it
                local pe = Instance.new("ParticleEmitter")
                pe.Name = "TempESPEmitter"
                -- parent to workspace so it exists; destroy later if you want
                pe.Parent = workspace
                return pe
            end)()
        },
        Vector3.new(9.7, 119, 15),                                 -- 11: position vector
        Vector3.new(0, 0, 0),                                      -- 12: zero vector (kept as placeholder)
        true                                                       -- 13: boolean flag
    }

    return args
end

local function onClickMethod2()
    local targetPlayer = getNearestPlayerToCursorMethod2()
    if not targetPlayer then return end

    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if not tool then
        warn("no tool")
        return
    end

    local humanoid = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    local rootPart = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local head = targetPlayer.Character and (targetPlayer.Character:FindFirstChild("Head") or rootPart)

    if not humanoid or not rootPart or not head then
        warn("target missing required parts")
        return
    end

    local args = buildArgsMethod2(LocalPlayer, tool, LocalPlayer, humanoid, rootPart, head)

    local success, result = pcall(function()
        return InflictTarget:InvokeServer(unpack(args))
    end)

    if not success then
        warn("failed to invoke (method2):", result)
    end
end

-- Controller function that connects/disconnects input for method2 (called by your toggle callback)
function SilentAimWallBangMethod2(enabled)
    if enabled then
        if clickConnection2 then return end
        clickConnection2 = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                -- call method2 handler when toggled on
                onClickMethod2()
            end
        end)
    else
        if clickConnection2 then
            clickConnection2:Disconnect()
            clickConnection2 = nil
        end
    end
end




-- // GUN MODS































function DeleteMap(val)
	for i, v in pairs(workspace:GetDescendants()) do
    	if v:IsA("BasePart") then
    		game.ReplicatedStorage:FindFirstChild("BreakGlass", true):FireServer(v)
   		end
	end
end




local killAllThread -- store the spawned thread so we can stop it

function KillAll(val)
    if val then
        -- start the loop only if it's not already running
        if not killAllThread then
            killAllThread = task.spawn(function()
                while Toggles.KillAll.Value do -- loop only while toggle is true
                    for i, target in pairs(game.Players:GetPlayers()) do
                        if target ~= game.Players.LocalPlayer and target.Character and target.Character:FindFirstChild("Humanoid") then
                            local player = game.Players.LocalPlayer
                            local tool = player.Character:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
                            if not tool then continue end
                            local toolPart = tool:FindFirstChildWhichIsA("BasePart")
                            if not toolPart then continue end

                            local rootPart = target.Character:FindFirstChild("HumanoidRootPart")
                            if not rootPart then continue end

                            local args = {
                                toolPart,
                                player,
                                target.Character.Humanoid,
                                target.Character.Humanoid,
                                100,
                                {0, 0, false, false, 100, 100},
                                {false, 0, 3},
                                rootPart,
                                {false, {245631555, 245030056, 245631167}, 0, 10, nil},
                                Vector3.new(-451.23, 4.08, -424.57),
                                Vector3.new(0.731, -0.457, 0.507),
                                1760303386.61,
                                Vector3.new(1.558, 1.978, 1.149)
                            }

                            pcall(function()
                                game.ReplicatedStorage:FindFirstChild("InflictTarget", true):InvokeServer(unpack(args))
                            end)
                        end
                    end
                    task.wait(0.1) -- small wait to prevent locking up
                end
                killAllThread = nil -- reset when done
            end)
        end
    else
        -- stop the loop by setting toggle to false (loop checks this)
        Toggles.KillAll.Value = false
        if killAllThread then
            killAllThread = nil
        end
    end
end


--// ESP using Highlight objects
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function CreateESP(player)
	if player == LocalPlayer then return end
	if not player.Character then return end

	-- If already has one, skip
	if ESPHighlights[player] then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "PlayerESP"
	highlight.Adornee = player.Character
	highlight.FillTransparency = 0.8
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = Options.ESPColors.Value
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.Parent = game.CoreGui

	ESPHighlights[player] = highlight
end

local function RemoveESP(player)
	if ESPHighlights[player] then
		ESPHighlights[player]:Destroy()
		ESPHighlights[player] = nil
	end
end

local function UpdateESP()
	for _, player in pairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end

		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

		if Toggles.ESPHealthCheck and Toggles.ESPHealthCheck.Value then
			if humanoid and humanoid.Health <= 0 then
				if ESPHighlights[player] then
					ESPHighlights[player].Enabled = false
				end
			else
				-- normal ESP logic
				if player.Character and not ESPHighlights[player] then
					CreateESP(player)
				elseif not player.Character and ESPHighlights[player] then
					RemoveESP(player)
				elseif ESPHighlights[player] and ESPHighlights[player].Adornee ~= player.Character then
					ESPHighlights[player].Adornee = player.Character
				end
				if ESPHighlights[player] then
					ESPHighlights[player].Enabled = true
				end
			end
		else
			-- ignore health, always show ESP
			if player.Character and not ESPHighlights[player] then
				CreateESP(player)
			elseif not player.Character and ESPHighlights[player] then
				RemoveESP(player)
			elseif ESPHighlights[player] and ESPHighlights[player].Adornee ~= player.Character then
				ESPHighlights[player].Adornee = player.Character
			end
			if ESPHighlights[player] then
				ESPHighlights[player].Enabled = true
			end
		end
	end
end

function StartESP()
	if ESPConnections.Render then return end

	-- Add existing players
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			CreateESP(player)
		end
	end

	-- Keep updating highlights
	ESPConnections.Render = RunService.RenderStepped:Connect(UpdateESP)
	ESPConnections.Added = Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			task.wait(1) -- slight delay for character load
			CreateESP(player)
		end)
	end)
	ESPConnections.Removing = Players.PlayerRemoving:Connect(RemoveESP)
end

function StopESP()
	for _, conn in pairs(ESPConnections) do
		conn:Disconnect()
	end
	table.clear(ESPConnections)

	for _, highlight in pairs(ESPHighlights) do
		highlight:Destroy()
	end
	table.clear(ESPHighlights)
end
























--// ESP Names (separate system)
local ESPNametags = {}
local ESPNConnections = {}

local function CreateESPNametag(player)
	if player == LocalPlayer then return end
	if not player.Character then return end
	if ESPNametags[player] then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESPName"
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(0, 85, 0, 20) -- smaller size
	billboard.StudsOffset = Vector3.new(0, 2, 0) -- moves below the character
	billboard.MaxDistance = 5000

	local text = Instance.new("TextLabel")
	text.Parent = billboard
	text.BackgroundTransparency = 1
	text.Size = UDim2.new(1, 0, 1, 0)
	if player.DisplayName then text.Text = player.DisplayName.." ("..player.Name..")" end
	text.TextColor3 = Options.ESPColors.Value
	text.TextStrokeTransparency = 0.3
	text.TextScaled = true
	text.Font = Enum.Font.GothamBold -- cleaner, modern font

	billboard.Adornee = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Head")
	billboard.Parent = game.CoreGui

	ESPNametags[player] = billboard
end

local function RemoveESPNametag(player)
	if ESPNametags[player] then
		ESPNametags[player]:Destroy()
		ESPNametags[player] = nil
	end
end

local function UpdateESPNametags()
	for _, player in pairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end

		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

		if Toggles.ESPHealthCheck and Toggles.ESPHealthCheck.Value then
			if humanoid and humanoid.Health <= 0 then
				if ESPNametags[player] then
					ESPNametags[player].Enabled = false
				end
			else
				if player.Character and not ESPNametags[player] then
					CreateESPNametag(player)
				elseif not player.Character and ESPNametags[player] then
					RemoveESPNametag(player)
				elseif ESPNametags[player] then
					ESPNametags[player].Adornee = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
					ESPNametags[player].Enabled = true
				end
			end
		else
			if player.Character and not ESPNametags[player] then
				CreateESPNametag(player)
			elseif not player.Character and ESPNametags[player] then
				RemoveESPNametag(player)
			elseif ESPNametags[player] then
				ESPNametags[player].Adornee = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
				ESPNametags[player].Enabled = true
			end
		end
	end
end


function StartESPNames()
	if ESPNConnections.Render then return end

	-- Add existing players
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			CreateESPNametag(player)
		end
	end

	-- Keep updating
	ESPNConnections.Render = RunService.RenderStepped:Connect(UpdateESPNametags)
	ESPNConnections.Added = Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			task.wait(1)
			CreateESPNametag(player)
		end)
	end)
	ESPNConnections.Removing = Players.PlayerRemoving:Connect(RemoveESPNametag)
end

function StopESPNames()
	for _, conn in pairs(ESPNConnections) do
		conn:Disconnect()
	end
	table.clear(ESPNConnections)

	for _, billboard in pairs(ESPNametags) do
		billboard:Destroy()
	end
	table.clear(ESPNametags)
end
















-- HITBOX


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local OriginalHeadSizes = {}
local HitboxConnection

function StartHitboxExpander()
	StopHitboxExpander() -- prevent duplicates

	HitboxConnection = RunService.Heartbeat:Connect(function()
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
				local head = player.Character.Head

				if not OriginalHeadSizes[player] then
					OriginalHeadSizes[player] = head.Size
				end

				local expand = Options.HitboxSize.Value
				head.Size = Vector3.new(expand, expand, expand)
				head.Transparency = 0.7
				head.Color = Color3.fromRGB(255, 0, 0)
				head.Material = Enum.Material.ForceField
				head.CanCollide = false
			end
		end
	end)
end

function StopHitboxExpander()
	if HitboxConnection then
		HitboxConnection:Disconnect()
		HitboxConnection = nil
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			if OriginalHeadSizes[player] then
				head.Size = OriginalHeadSizes[player]
				head.Transparency = 0
				head.Material = Enum.Material.Plastic
				OriginalHeadSizes[player] = nil
			end
		end
	end
end



LocalPlayer.Backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        task.wait(0.2)
        UpdateGunSettings(function(module)
            module.RecoilingEnabled = not Toggles.NoRecoil.Value
            module.Auto = Toggles.FullAuto.Value
            module.ExplosiveEnabled = Toggles.Explosive.Value
            module.FireRate = Options.FireRate.Value
            module.BaseDamage = Options.GunDamage.Value
        end)
    end
end)




function UpdateESPColorfrmSetting(color)
	for _, highlight in pairs(ESPHighlights) do
        if highlight and highlight:IsA("Highlight") then
            highlight.FillColor = color
        end
    end
    for i, billboard in pairs(ESPNametags) do
        if billboard and billboard:IsA("BillboardGui") then
            local tb = billboard:FindFirstChildOfClass("TextLabel")
            if tb then tb.TextColor3 = color end
        end
    end
end

EspGroupBox:AddLabel('Color'):AddColorPicker('ESPColors', {
	Default = Color3.new(0, 0, 1), -- Bright green
    Title = 'ESP Color', -- Optional. Allows you to have a custom color picker title (when you open it)
    Transparency = 0, -- Optional. Enables transparency changing for this color picker (leave as nil to disable)

    Callback = function(Value)
        UpdateESPColorfrmSetting(Value)
    end
})




-- has to be at the bottom or we breaking stuff


RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    FOVCircle.Radius = Options.SilentFOV.Value or 100
	FOVCircle.Color = Options.ESPColors.Value
end)
