local PreviewManager = {} do
    PreviewManager.Library = nil
    PreviewManager.Enabled = false
    PreviewManager.Role = "Survivor"
    PreviewManager.Config = nil

    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local Camera = Workspace.CurrentCamera
    local CoreGui = game:GetService("CoreGui")
    local lp = Players.LocalPlayer

    local StateColors = {
        Knocked = Color3.fromRGB(200, 100, 0),
        Damaged = Color3.fromRGB(200, 200, 0),
        Item = Color3.fromRGB(0, 255, 255)
    }

    local function getRoleCfg(role)
        if not PreviewManager.Config then return nil end
        if role == "Survivor" then
            return {
                enabled = PreviewManager.Config.SurvivorEnabled,
                box = PreviewManager.Config.SurvivorBox,
                boxFilled = PreviewManager.Config.SurvivorBoxFilled,
                name = PreviewManager.Config.SurvivorName,
                distance = PreviewManager.Config.SurvivorDistance,
                health = PreviewManager.Config.SurvivorHealth,
                healthNumber = PreviewManager.Config.SurvivorHealthNumber,
                tracers = PreviewManager.Config.SurvivorTracers,
                color = PreviewManager.Config.SurvivorColor,
            }
        elseif role == "Killer" then
            return {
                enabled = PreviewManager.Config.KillerEnabled,
                box = PreviewManager.Config.KillerBox,
                boxFilled = PreviewManager.Config.KillerBoxFilled,
                name = PreviewManager.Config.KillerName,
                distance = PreviewManager.Config.KillerDistance,
                health = PreviewManager.Config.KillerHealth,
                healthNumber = PreviewManager.Config.KillerHealthNumber,
                tracers = PreviewManager.Config.KillerTracers,
                color = PreviewManager.Config.KillerColor,
            }
        end
        return nil
    end

    local previewGui
    local previewFrame
    local previewDummies = {}

    local function createPreviewGui()
        if previewGui then return end
        local Library = PreviewManager.Library

        previewGui = Library:Create("ScreenGui", {
            Name = "IrreverencePreview",
            ResetOnSpawn = false,
            DisplayOrder = 9999,
            Parent = CoreGui,
            Enabled = false,
        })

        previewFrame = Library:Create("Frame", {
            Name = "PreviewBox",
            Size = UDim2.new(0, 340, 0, 260),
            Position = UDim2.new(0.5, -170, 0.5, -130),
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Active = true,
            Draggable = true,
            ClipsDescendants = true,
            Parent = previewGui,
        })
        Library:AddToRegistry(previewFrame, {
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
        })

        local titleBar = Library:Create("Frame", {
            Name = "TitleBar",
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundColor3 = Library.BackgroundColor,
            BorderSizePixel = 0,
            Parent = previewFrame,
        })
        Library:AddToRegistry(titleBar, {
            BackgroundColor3 = "BackgroundColor",
        })

        local accentBar = Library:Create("Frame", {
            Name = "AccentBar",
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = Library.AccentColor,
            BorderSizePixel = 0,
            Parent = titleBar,
        })
        Library:AddToRegistry(accentBar, {
            BackgroundColor3 = "AccentColor",
        })

        local titleLabel = Library:CreateLabel({
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
            Text = "ESP Preview (Drag me)",
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = Library.FontSize,
            Parent = titleBar,
        })

        local function createDummyUI()
            local dummy = {}

            dummy.Box = Library:Create("Frame", {
                Name = "Box",
                BorderSizePixel = 1,
                BackgroundTransparency = 1,
                Parent = previewFrame,
            })

            dummy.Name = Library:CreateLabel({
                Name = "NameLabel",
                BackgroundTransparency = 1,
                Font = Library.Font,
                TextSize = Library.FontSize + 2,
                TextStrokeTransparency = 0,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = previewFrame,
            })

            dummy.Distance = Library:CreateLabel({
                Name = "DistanceLabel",
                BackgroundTransparency = 1,
                Font = Library.Font,
                TextSize = Library.FontSize,
                TextStrokeTransparency = 0,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = previewFrame,
            })

            dummy.State = Library:CreateLabel({
                Name = "StateLabel",
                BackgroundTransparency = 1,
                Font = Library.Font,
                TextSize = Library.FontSize,
                TextStrokeTransparency = 0,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = previewFrame,
            })

            dummy.HealthBg = Library:Create("Frame", {
                Name = "HealthBg",
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.new(0, 0, 0),
                Parent = previewFrame,
            })

            dummy.HealthFill = Library:Create("Frame", {
                Name = "HealthFill",
                BorderSizePixel = 0,
                Parent = dummy.HealthBg,
            })

            dummy.HealthNumber = Library:CreateLabel({
                Name = "HealthNumberLabel",
                BackgroundTransparency = 1,
                Font = Library.Font,
                TextSize = Library.FontSize - 1,
                TextStrokeTransparency = 0,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = previewFrame,
            })

            dummy.Tracer = Library:Create("Frame", {
                Name = "Tracer",
                BorderSizePixel = 0,
                Parent = previewFrame,
            })

            return dummy
        end

        previewDummies.Survivor = createDummyUI()
        previewDummies.Killer = createDummyUI()
    end

    local function drawDummy(dummy, cfg, role, centerX, centerY)
        if not dummy or not cfg then return end
        local Library = PreviewManager.Library

        local boxHeight = 160
        local boxWidth = 96
        local boxX = centerX
        local boxY = centerY
        local barX = boxX - boxWidth/2 - 6

        local color = cfg.color and cfg.color.Value or Color3.new(1, 1, 1)
        local displayText = role == "Survivor" and "Survivor_Preview" or "Killer_Preview"
        local dist = role == "Survivor" and 45 or 60
        local health = role == "Survivor" and 80 or 100
        local maxHealth = 100
        local stateText = role == "Survivor" and "Medkit" or ""
        local stateColor = StateColors.Item

        if cfg.box and cfg.box.Value then
            dummy.Box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
            dummy.Box.Position = UDim2.new(0, boxX - boxWidth/2, 0, boxY - boxHeight/2)
            dummy.Box.BorderColor3 = color
            dummy.Box.BackgroundTransparency = (cfg.boxFilled and cfg.boxFilled.Value) and 0.5 or 1
            dummy.Box.Visible = true
        else
            dummy.Box.Visible = false
        end

        if cfg.name and cfg.name.Value then
            dummy.Name.Text = displayText
            dummy.Name.Position = UDim2.new(0, boxX - 100, 0, boxY - boxHeight/2 - 18)
            dummy.Name.Size = UDim2.new(0, 200, 0, 16)
            dummy.Name.TextColor3 = color
            dummy.Name.Visible = true
        else
            dummy.Name.Visible = false
        end

        if cfg.distance and cfg.distance.Value then
            dummy.Distance.Text = string.format("%d studs", dist)
            dummy.Distance.Position = UDim2.new(0, boxX - 100, 0, boxY + boxHeight/2 + 2)
            dummy.Distance.Size = UDim2.new(0, 200, 0, 16)
            dummy.Distance.TextColor3 = Color3.fromRGB(200, 200, 200)
            dummy.Distance.Visible = true
        else
            dummy.Distance.Visible = false
        end

        if stateText ~= "" then
            dummy.State.Text = stateText
            dummy.State.Position = UDim2.new(0, boxX - 100, 0, boxY + boxHeight/2 + 18)
            dummy.State.Size = UDim2.new(0, 200, 0, 16)
            dummy.State.TextColor3 = stateColor
            dummy.State.Visible = true
        else
            dummy.State.Visible = false
        end

        local healthPct = health / maxHealth
        local barHeight = boxHeight * healthPct

        if cfg.health and cfg.health.Value then
            dummy.HealthBg.Size = UDim2.new(0, 3, 0, boxHeight + 2)
            dummy.HealthBg.Position = UDim2.new(0, barX - 1, 0, boxY - boxHeight/2 - 1)
            dummy.HealthBg.Visible = true

            dummy.HealthFill.Size = UDim2.new(0, 1, 0, barHeight)
            dummy.HealthFill.Position = UDim2.new(0, 1, 0, boxHeight + 2 - barHeight)
            dummy.HealthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(255, 0, 0), 1 - healthPct)
            dummy.HealthFill.Visible = true
        else
            dummy.HealthBg.Visible = false
            dummy.HealthFill.Visible = false
        end

        if cfg.healthNumber and cfg.healthNumber.Value then
            dummy.HealthNumber.Text = string.format("%d / %d", health, maxHealth)
            dummy.HealthNumber.Position = UDim2.new(0, barX - 42, 0, boxY - 8)
            dummy.HealthNumber.Size = UDim2.new(0, 40, 0, 16)
            dummy.HealthNumber.TextColor3 = Color3.fromRGB(255, 255, 255)
            dummy.HealthNumber.Visible = true
        else
            dummy.HealthNumber.Visible = false
        end

        if cfg.tracers and cfg.tracers.Value then
            dummy.Tracer.Size = UDim2.new(0, 1, 0, 260 - (boxY + boxHeight/2))
            dummy.Tracer.Position = UDim2.new(0, boxX, 0, boxY + boxHeight/2)
            dummy.Tracer.BackgroundColor3 = color
            dummy.Tracer.Visible = true
        else
            dummy.Tracer.Visible = false
        end
    end

    local function hideDummy(dummy)
        if not dummy then return end
        dummy.Box.Visible = false
        dummy.Name.Visible = false
        dummy.Distance.Visible = false
        dummy.State.Visible = false
        dummy.HealthBg.Visible = false
        dummy.HealthFill.Visible = false
        dummy.HealthNumber.Visible = false
        dummy.Tracer.Visible = false
    end

    local function updatePreview()
        if not PreviewManager.Enabled then return end
        if not previewGui then createPreviewGui() end

        local role = PreviewManager.Role
        local survCfg = getRoleCfg("Survivor")
        local killCfg = getRoleCfg("Killer")

        local frameSizeX = (role == "Both") and 520 or 340
        if previewFrame.Size.X.Offset ~= frameSizeX then
            previewFrame.Size = UDim2.new(0, frameSizeX, 0, 260)
        end
        local centerY = 130

        if role == "Survivor" or role == "Both" then
            if role == "Both" then
                drawDummy(previewDummies.Survivor, survCfg, "Survivor", frameSizeX * 0.3, centerY)
            else
                drawDummy(previewDummies.Survivor, survCfg, "Survivor", frameSizeX * 0.5, centerY)
            end
        else
            hideDummy(previewDummies.Survivor)
        end

        if role == "Killer" or role == "Both" then
            if role == "Both" then
                drawDummy(previewDummies.Killer, killCfg, "Killer", frameSizeX * 0.7, centerY)
            else
                drawDummy(previewDummies.Killer, killCfg, "Killer", frameSizeX * 0.5, centerY)
            end
        else
            hideDummy(previewDummies.Killer)
        end
    end

    local renderConn
    local function startRenderLoop()
        if renderConn then return end
        renderConn = RunService.RenderStepped:Connect(function()
            if not PreviewManager.Enabled then
                if previewGui then previewGui.Enabled = false end
                return
            end
            if not previewGui then createPreviewGui() end
            if not previewGui.Enabled then previewGui.Enabled = true end
            updatePreview()
        end)
    end

    function PreviewManager:SetLibrary(lib)
        self.Library = lib
    end

    function PreviewManager:SetConfig(cfg)
        self.Config = cfg
    end

    function PreviewManager:SetEnabled(state)
        self.Enabled = state
        if state then
            startRenderLoop()
        else
            if previewGui then previewGui.Enabled = false end
        end
    end

    function PreviewManager:SetRole(role)
        self.Role = role
    end

    function PreviewManager:BuildPreviewSection(groupbox)
        assert(self.Library, "Must set PreviewManager.Library first!")
        groupbox:AddToggle("ESP_Preview", {
            Text = "Enable ESP Preview",
            Default = false,
            Tooltip = "Shows a live preview of your ESP settings",
            Callback = function(val)
                self:SetEnabled(val)
            end
        })
        groupbox:AddDropdown("ESP_PreviewRole", {
            Text = "Preview Role",
            Default = "Survivor",
            Values = { "Survivor", "Killer", "Both" },
            Tooltip = "Which role to preview",
            Callback = function(val)
                self:SetRole(val)
            end
        })
    end

    function PreviewManager:Unload()
        if renderConn then renderConn:Disconnect() renderConn = nil end
        if previewGui then previewGui:Destroy() previewGui = nil end
        previewDummies = {}
        self.Enabled = false
    end
end

return PreviewManager
