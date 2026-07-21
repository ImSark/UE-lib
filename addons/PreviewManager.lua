local PreviewManager = {} do
    PreviewManager.Library = nil
    PreviewManager.Enabled = false
    PreviewManager.Role = "Survivor"
    PreviewManager.Config = nil

    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")

    local StateColors = {
        Knocked = Color3.fromRGB(200, 100, 0),
        Damaged = Color3.fromRGB(200, 200, 0),
        Item = Color3.fromRGB(0, 255, 255)
    }

    local function getRoleCfg(role)
        if not PreviewManager.Config then return nil end
        if role == "Survivor" then
            return {
                box = PreviewManager.Config.SurvivorBox,
                boxFilled = PreviewManager.Config.SurvivorBoxFilled,
                name = PreviewManager.Config.SurvivorName,
                distance = PreviewManager.Config.SurvivorDistance,
                health = PreviewManager.Config.SurvivorHealth,
                healthNumber = PreviewManager.Config.SurvivorHealthNumber,
                tracers = PreviewManager.Config.SurvivorTracers,
                chams = PreviewManager.Config.SurvivorChams,
                chamsOpacity = PreviewManager.Config.SurvivorChamsOpacity,
                color = PreviewManager.Config.SurvivorColor,
            }
        elseif role == "Killer" then
            return {
                box = PreviewManager.Config.KillerBox,
                boxFilled = PreviewManager.Config.KillerBoxFilled,
                name = PreviewManager.Config.KillerName,
                distance = PreviewManager.Config.KillerDistance,
                health = PreviewManager.Config.KillerHealth,
                healthNumber = PreviewManager.Config.KillerHealthNumber,
                tracers = PreviewManager.Config.KillerTracers,
                chams = PreviewManager.Config.KillerChams,
                chamsOpacity = PreviewManager.Config.KillerChamsOpacity,
                color = PreviewManager.Config.KillerColor,
            }
        end
        return nil
    end

    local previewGui
    local previewFrame
    local previewObjs = {}

    local function makeLabel(parent, textSize, zindex)
        local Library = PreviewManager.Library
        local label = Library:Create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Code,
            TextSize = textSize,
            TextColor3 = Color3.new(1, 1, 1),
            TextStrokeTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = zindex,
            Visible = false,
            Parent = parent,
        })
        Library:Create("UIStroke", {
            Color = Color3.new(0, 0, 0),
            Thickness = 1,
            Parent = label,
        })
        return label
    end

    local function createPreviewGui()
        if previewGui then return end
        local Library = PreviewManager.Library

        previewGui = Library:Create("ScreenGui", {
            Name = "IrreverencePreview",
            ResetOnSpawn = false,
            DisplayOrder = 9999,
            IgnoreGuiInset = true,
            Parent = CoreGui,
            Enabled = false,
        })

        previewFrame = Library:Create("Frame", {
            Name = "PreviewBox",
            Size = UDim2.new(0, 240, 0, 1120),
            Position = UDim2.new(0.5, -120, 0.5, -560),
            BackgroundColor3 = Library.BackgroundColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            ZIndex = 50,
            Parent = previewGui,
        })
        Library:AddToRegistry(previewFrame, {
            BackgroundColor3 = "BackgroundColor",
            BorderColor3 = "OutlineColor",
        })

        local dragging = false
        local dragInput, mousePos, framePos

        previewFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                mousePos = input.Position
                framePos = previewFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        previewFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - mousePos
                previewFrame.Position = UDim2.new(
                    framePos.X.Scale, framePos.X.Offset + delta.X,
                    framePos.Y.Scale, framePos.Y.Offset + delta.Y
                )
            end
        end)

        local titleBar = Library:Create("Frame", {
            Name = "TitleBar",
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundColor3 = Library.MainColor,
            BorderSizePixel = 0,
            ZIndex = 51,
            Parent = previewFrame,
        })
        Library:AddToRegistry(titleBar, {
            BackgroundColor3 = "MainColor",
        })

        local accentBar = Library:Create("Frame", {
            Name = "AccentBar",
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = Library.AccentColor,
            BorderSizePixel = 0,
            ZIndex = 52,
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
            ZIndex = 53,
            Parent = titleBar,
        })
    end

    local function createPreviewObj(role)
        local Library = PreviewManager.Library
        local container = Library:Create("Frame", {
            Name = role .. "Container",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            ZIndex = 54,
            Visible = false,
            Parent = previewFrame,
        })

        local obj = {}
        obj.Container = container

        obj.Cham = Library:Create("Frame", {
            Name = "Cham",
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 54,
            Parent = container,
        })

        obj.Box = Library:Create("Frame", {
            Name = "Box",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 55,
            Parent = container,
        })
        obj.BoxStroke = Library:Create("UIStroke", {
            Color = Color3.new(1, 1, 1),
            Thickness = 1,
            Parent = obj.Box,
        })

        obj.Tracer = Library:Create("Frame", {
            Name = "Tracer",
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 55,
            Parent = container,
        })

        obj.HealthBarBg = Library:Create("Frame", {
            Name = "HealthBarBg",
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 55,
            Parent = container,
        })

        obj.HealthBarFill = Library:Create("Frame", {
            Name = "HealthBarFill",
            BackgroundColor3 = Color3.new(0, 1, 0),
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 56,
            Parent = container,
        })

        obj.Name = makeLabel(container, 14, 57)
        obj.Distance = makeLabel(container, 12, 57)
        obj.State = makeLabel(container, 12, 57)
        obj.HealthNumber = makeLabel(container, 11, 57)
        obj.HealthNumber.TextXAlignment = Enum.TextXAlignment.Right

        return obj
    end

    local function hidePreviewObj(obj)
        if not obj then return end
        obj.Container.Visible = false
    end

    local function destroyPreviewObj(obj)
        if not obj then return end
        pcall(function()
            obj.Container:Destroy()
        end)
    end

    local function drawPreviewESP(obj, cfg, role, centerXScale)
        if not obj or not cfg then return end

        local boxHeight = 600
        local boxWidth = 100
        local boxY = 336
        local boxXOffset = -boxWidth / 2
        local barXOffset = boxXOffset - 6

        local color = cfg.color and cfg.color.Value or Color3.new(1, 1, 1)
        local displayText = role == "Survivor" and "Survivor_Preview" or "Killer_Preview"
        local dist = role == "Survivor" and 45 or 60
        local health = role == "Survivor" and 80 or 100
        local maxHealth = 100
        local stateText = role == "Survivor" and "Medkit" or ""
        local stateColor = StateColors.Item

        obj.Container.Visible = true

        if cfg.chams and cfg.chams.Value then
            obj.Cham.Position = UDim2.new(centerXScale, boxXOffset, 0, boxY)
            obj.Cham.Size = UDim2.new(0, boxWidth, 0, boxHeight)
            obj.Cham.BackgroundColor3 = color
            obj.Cham.BackgroundTransparency = 1 - (cfg.chamsOpacity and cfg.chamsOpacity.Value or 0.5)
            obj.Cham.Visible = true
        else
            obj.Cham.Visible = false
        end

        if cfg.box and cfg.box.Value then
            obj.Box.Position = UDim2.new(centerXScale, boxXOffset, 0, boxY)
            obj.Box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
            obj.BoxStroke.Color = color
            if cfg.boxFilled and cfg.boxFilled.Value then
                obj.Box.BackgroundTransparency = 0.5
                obj.Box.BackgroundColor3 = color
            else
                obj.Box.BackgroundTransparency = 1
            end
            obj.Box.Visible = true
        else
            obj.Box.Visible = false
        end

        if cfg.name and cfg.name.Value then
            obj.Name.Text = displayText
            obj.Name.Position = UDim2.new(centerXScale, -120, 0, boxY - 18)
            obj.Name.Size = UDim2.new(0, 240, 0, 16)
            obj.Name.TextColor3 = color
            obj.Name.Visible = true
        else
            obj.Name.Visible = false
        end

        if cfg.distance and cfg.distance.Value then
            obj.Distance.Text = string.format("%d studs", dist)
            obj.Distance.Position = UDim2.new(centerXScale, -120, 0, boxY + boxHeight + 4)
            obj.Distance.Size = UDim2.new(0, 240, 0, 14)
            obj.Distance.TextColor3 = Color3.fromRGB(200, 200, 200)
            obj.Distance.Visible = true
        else
            obj.Distance.Visible = false
        end

        if stateText ~= "" then
            obj.State.Text = stateText
            obj.State.Position = UDim2.new(centerXScale, -120, 0, boxY + boxHeight + 20)
            obj.State.Size = UDim2.new(0, 240, 0, 14)
            obj.State.TextColor3 = stateColor
            obj.State.Visible = true
        else
            obj.State.Visible = false
        end

        local healthPct = health / maxHealth
        local barHeight = boxHeight * healthPct

        if cfg.health and cfg.health.Value then
            obj.HealthBarBg.Position = UDim2.new(centerXScale, barXOffset - 1, 0, boxY - 1)
            obj.HealthBarBg.Size = UDim2.new(0, 4, 0, boxHeight + 2)
            obj.HealthBarBg.Visible = true

            obj.HealthBarFill.Position = UDim2.new(centerXScale, barXOffset, 0, boxY + boxHeight - barHeight)
            obj.HealthBarFill.Size = UDim2.new(0, 2, 0, barHeight)
            obj.HealthBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(255, 0, 0), 1 - healthPct)
            obj.HealthBarFill.Visible = true
        else
            obj.HealthBarBg.Visible = false
            obj.HealthBarFill.Visible = false
        end

        if cfg.healthNumber and cfg.healthNumber.Value then
            obj.HealthNumber.Text = string.format("%d / %d", health, maxHealth)
            obj.HealthNumber.Position = UDim2.new(centerXScale, barXOffset - 56, 0, boxY + boxHeight / 2 - 6)
            obj.HealthNumber.Size = UDim2.new(0, 54, 0, 12)
            obj.HealthNumber.TextColor3 = Color3.fromRGB(255, 255, 255)
            obj.HealthNumber.Visible = true
        else
            obj.HealthNumber.Visible = false
        end

        if cfg.tracers and cfg.tracers.Value then
            local tracerStartY = boxY + boxHeight / 2
            obj.Tracer.Position = UDim2.new(centerXScale, -0.5, 0, tracerStartY)
            obj.Tracer.Size = UDim2.new(0, 1, 0, 1110 - tracerStartY)
            obj.Tracer.BackgroundColor3 = color
            obj.Tracer.Visible = true
        else
            obj.Tracer.Visible = false
        end
    end

    local function updatePreview()
        if not PreviewManager.Enabled then return end
        if not previewGui then createPreviewGui() end
        if not previewGui.Enabled then previewGui.Enabled = true end

        local role = PreviewManager.Role
        local survCfg = getRoleCfg("Survivor")
        local killCfg = getRoleCfg("Killer")

        local targetSizeX = (role == "Both") and 480 or 240
        if previewFrame.Size.X.Offset ~= targetSizeX then
            previewFrame.Size = UDim2.new(0, targetSizeX, 0, 1120)
        end

        if role == "Survivor" or role == "Both" then
            if not previewObjs.Survivor then previewObjs.Survivor = createPreviewObj("Survivor") end
            local centerXScale = (role == "Both") and 0.25 or 0.5
            drawPreviewESP(previewObjs.Survivor, survCfg, "Survivor", centerXScale)
        else
            if previewObjs.Survivor then hidePreviewObj(previewObjs.Survivor) end
        end

        if role == "Killer" or role == "Both" then
            if not previewObjs.Killer then previewObjs.Killer = createPreviewObj("Killer") end
            local centerXScale = (role == "Both") and 0.75 or 0.5
            drawPreviewESP(previewObjs.Killer, killCfg, "Killer", centerXScale)
        else
            if previewObjs.Killer then hidePreviewObj(previewObjs.Killer) end
        end
    end

    local renderConn
    local function startRenderLoop()
        if renderConn then return end
        renderConn = RunService.RenderStepped:Connect(function()
            if not PreviewManager.Enabled then
                if previewGui then previewGui.Enabled = false end
                for _, obj in pairs(previewObjs) do hidePreviewObj(obj) end
                return
            end
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
            for _, obj in pairs(previewObjs) do hidePreviewObj(obj) end
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
        previewFrame = nil
        previewObjs = {}
        self.Enabled = false
    end
end

return PreviewManager
