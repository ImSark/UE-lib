local PreviewManager = {} do
    PreviewManager.Library = nil
    PreviewManager.Enabled = false
    PreviewManager.Role = "Survivor"
    PreviewManager.Config = nil

    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

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

    local previewFrame
    local previewObjs = {}

    local function createPreviewGui()
        if previewFrame then return end
        local Library = PreviewManager.Library

        -- Parent directly to Linoria's ScreenGui so it inherits modal and cursor behavior
        previewFrame = Library:Create("Frame", {
            Name = "PreviewBox",
            Size = UDim2.new(0, 140, 0, 260),
            Position = UDim2.new(0.5, -70, 0.5, -130),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.2,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            ZIndex = 50,
            Parent = Library.ScreenGui,
        })
        Library:AddToRegistry(previewFrame, {
            BorderColor3 = "OutlineColor",
        })
        
        -- Custom drag logic to avoid Linoria's MakeDraggable conflicts
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
            BackgroundColor3 = Library.BackgroundColor,
            BorderSizePixel = 0,
            ZIndex = 51,
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

    local function createPreviewObj()
        local obj = {}
        
        obj.Cham = Drawing.new("Square")
        obj.Cham.Thickness = 0
        obj.Cham.Filled = true
        obj.Cham.Transparency = 1
        obj.Cham.Visible = false
        
        obj.Box = Drawing.new("Square")
        obj.Box.Thickness = 1
        obj.Box.Filled = false
        obj.Box.Transparency = 1
        obj.Box.Visible = false
        
        obj.Name = Drawing.new("Text")
        obj.Name.Size = 14
        obj.Name.Center = true
        obj.Name.Outline = true
        obj.Name.Font = 2
        obj.Name.Visible = false
        
        obj.Distance = Drawing.new("Text")
        obj.Distance.Size = 12
        obj.Distance.Center = true
        obj.Distance.Outline = true
        obj.Distance.Font = 2
        obj.Distance.Visible = false
        
        obj.State = Drawing.new("Text")
        obj.State.Size = 12
        obj.State.Center = true
        obj.State.Outline = true
        obj.State.Font = 2
        obj.State.Visible = false
        
        obj.HealthNumber = Drawing.new("Text")
        obj.HealthNumber.Size = 11
        obj.HealthNumber.Center = false
        obj.HealthNumber.Outline = true
        obj.HealthNumber.Font = 2
        obj.HealthNumber.Visible = false
        
        obj.HealthBarBg = Drawing.new("Square")
        obj.HealthBarBg.Thickness = 1
        obj.HealthBarBg.Filled = false
        obj.HealthBarBg.Transparency = 1
        obj.HealthBarBg.Visible = false
        
        obj.HealthBarFill = Drawing.new("Square")
        obj.HealthBarFill.Thickness = 1
        obj.HealthBarFill.Filled = true
        obj.HealthBarFill.Transparency = 1
        obj.HealthBarFill.Visible = false
        
        obj.Tracer = Drawing.new("Line")
        obj.Tracer.Thickness = 1
        obj.Tracer.Transparency = 1
        obj.Tracer.Visible = false
        
        return obj
    end

    local function hidePreviewObj(obj)
        if not obj then return end
        obj.Cham.Visible = false
        obj.Box.Visible = false
        obj.Name.Visible = false
        obj.Distance.Visible = false
        obj.State.Visible = false
        obj.HealthNumber.Visible = false
        obj.HealthBarBg.Visible = false
        obj.HealthBarFill.Visible = false
        obj.Tracer.Visible = false
    end

    local function destroyPreviewObj(obj)
        if not obj then return end
        pcall(function()
            obj.Cham:Remove()
            obj.Box:Remove()
            obj.Name:Remove()
            obj.Distance:Remove()
            obj.State:Remove()
            obj.HealthNumber:Remove()
            obj.HealthBarBg:Remove()
            obj.HealthBarFill:Remove()
            obj.Tracer:Remove()
        end)
    end

    local function drawPreviewESP(obj, cfg, role, centerX, boxY, frameBottomY)
        if not obj or not cfg then return end
        
        local boxHeight = 160
        local boxWidth = 96
        local boxX = centerX
        local barX = boxX - boxWidth/2 - 6
        
        local color = cfg.color and cfg.color.Value or Color3.new(1, 1, 1)
        local displayText = role == "Survivor" and "Survivor_Preview" or "Killer_Preview"
        local dist = role == "Survivor" and 45 or 60
        local health = role == "Survivor" and 80 or 100
        local maxHealth = 100
        local stateText = role == "Survivor" and "Medkit" or ""
        local stateColor = StateColors.Item
        
        if cfg.chams and cfg.chams.Value then
            obj.Cham.Size = Vector2.new(boxWidth, boxHeight)
            obj.Cham.Position = Vector2.new(boxX - boxWidth/2, boxY)
            obj.Cham.Color = color
            obj.Cham.Transparency = 1 - (cfg.chamsOpacity and cfg.chamsOpacity.Value or 0.5)
            obj.Cham.Visible = true
        else
            obj.Cham.Visible = false
        end
        
        if cfg.box and cfg.box.Value then
            obj.Box.Size = Vector2.new(boxWidth, boxHeight)
            obj.Box.Position = Vector2.new(boxX - boxWidth/2, boxY)
            obj.Box.Color = color
            obj.Box.Filled = cfg.boxFilled and cfg.boxFilled.Value or false
            obj.Box.Visible = true
        else
            obj.Box.Visible = false
        end
        
        if cfg.name and cfg.name.Value then
            obj.Name.Text = displayText
            obj.Name.Position = Vector2.new(boxX, boxY - 16)
            obj.Name.Color = color
            obj.Name.Visible = true
        else
            obj.Name.Visible = false
        end
        
        if cfg.distance and cfg.distance.Value then
            obj.Distance.Text = string.format("%d studs", dist)
            obj.Distance.Position = Vector2.new(boxX, boxY + boxHeight + 2)
            obj.Distance.Color = Color3.fromRGB(200, 200, 200)
            obj.Distance.Visible = true
        else
            obj.Distance.Visible = false
        end
        
        if stateText ~= "" then
            obj.State.Text = stateText
            obj.State.Position = Vector2.new(boxX, boxY + boxHeight + 16)
            obj.State.Color = stateColor
            obj.State.Visible = true
        else
            obj.State.Visible = false
        end
        
        local healthPct = health / maxHealth
        local barHeight = boxHeight * healthPct
        
        if cfg.health and cfg.health.Value then
            obj.HealthBarBg.Size = Vector2.new(3, boxHeight + 2)
            obj.HealthBarBg.Position = Vector2.new(barX - 1, boxY - 1)
            obj.HealthBarBg.Color = Color3.new(0, 0, 0)
            obj.HealthBarBg.Visible = true
            
            obj.HealthBarFill.Size = Vector2.new(1, barHeight)
            obj.HealthBarFill.Position = Vector2.new(barX, boxY + boxHeight - barHeight)
            obj.HealthBarFill.Color = Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(255, 0, 0), 1 - healthPct)
            obj.HealthBarFill.Visible = true
        else
            obj.HealthBarBg.Visible = false
            obj.HealthBarFill.Visible = false
        end
        
        if cfg.healthNumber and cfg.healthNumber.Value then
            obj.HealthNumber.Text = string.format("%d / %d", health, maxHealth)
            obj.HealthNumber.Position = Vector2.new(barX - obj.HealthNumber.TextBounds.X - 2, boxY + boxHeight/2 - obj.HealthNumber.TextBounds.Y/2)
            obj.HealthNumber.Color = Color3.fromRGB(255, 255, 255)
            obj.HealthNumber.Visible = true
        else
            obj.HealthNumber.Visible = false
        end
        
        if cfg.tracers and cfg.tracers.Value then
            obj.Tracer.From = Vector2.new(boxX, frameBottomY)
            obj.Tracer.To = Vector2.new(boxX, boxY + boxHeight / 2)
            obj.Tracer.Color = color
            obj.Tracer.Visible = true
        else
            obj.Tracer.Visible = false
        end
    end

    local function updatePreview()
        if not PreviewManager.Enabled then return end
        if not previewFrame then createPreviewGui() end
        if not previewFrame.Visible then previewFrame.Visible = true end

        local role = PreviewManager.Role
        local survCfg = getRoleCfg("Survivor")
        local killCfg = getRoleCfg("Killer")

        local targetSizeX = (role == "Both") and 280 or 140
        if previewFrame.Size.X.Offset ~= targetSizeX then
            previewFrame.Size = UDim2.new(0, targetSizeX, 0, 260)
        end

        local framePos = previewFrame.AbsolutePosition
        local frameSize = previewFrame.AbsoluteSize
        
        local boxY = framePos.Y + 52
        local frameBottomY = framePos.Y + frameSize.Y

        if role == "Survivor" or role == "Both" then
            if not previewObjs.Survivor then previewObjs.Survivor = createPreviewObj() end
            local centerX = framePos.X + (role == "Both" and (frameSize.X * 0.25) or (frameSize.X * 0.5))
            drawPreviewESP(previewObjs.Survivor, survCfg, "Survivor", centerX, boxY, frameBottomY)
        else
            if previewObjs.Survivor then hidePreviewObj(previewObjs.Survivor) end
        end
        
        if role == "Killer" or role == "Both" then
            if not previewObjs.Killer then previewObjs.Killer = createPreviewObj() end
            local centerX = framePos.X + (role == "Both" and (frameSize.X * 0.75) or (frameSize.X * 0.5))
            drawPreviewESP(previewObjs.Killer, killCfg, "Killer", centerX, boxY, frameBottomY)
        else
            if previewObjs.Killer then hidePreviewObj(previewObjs.Killer) end
        end
    end

    local renderConn
    local function startRenderLoop()
        if renderConn then return end
        renderConn = RunService.RenderStepped:Connect(function()
            if not PreviewManager.Enabled then
                if previewFrame then previewFrame.Visible = false end
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
            if previewFrame then previewFrame.Visible = false end
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
        if previewFrame then previewFrame:Destroy() previewFrame = nil end
        
        for _, obj in pairs(previewObjs) do
            destroyPreviewObj(obj)
        end
        previewObjs = {}
        self.Enabled = false
    end
end

return PreviewManager
