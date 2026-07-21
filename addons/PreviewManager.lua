local PreviewManager = {} do
    PreviewManager.Library = nil
    PreviewManager.Enabled = false
    PreviewManager.Role = "Survivor"
    PreviewManager.Config = nil

    local RunService = game:GetService("RunService")
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
    local dragFrame
    local previewObjs = {}

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

        -- Transparent Linoria UI frame to handle dragging
        dragFrame = Library:Create("Frame", {
            Name = "DragHandler",
            Size = UDim2.new(0, 140, 0, 260),
            Position = UDim2.new(0.5, -70, 0.5, -130),
            BackgroundTransparency = 1,
            Active = true,
            Parent = previewGui,
        })
        Library:MakeDraggable(dragFrame, 20, false)
    end

    local function createPreviewObj()
        local obj = {}
        
        -- Drawing API Background (matches Linoria style)
        obj.Bg = Drawing.new("Square")
        obj.Bg.Thickness = 0
        obj.Bg.Filled = true
        obj.Bg.Transparency = 0.2
        obj.Bg.Color = Color3.fromRGB(0, 0, 0)
        obj.Bg.Visible = false
        
        obj.TitleBg = Drawing.new("Square")
        obj.TitleBg.Thickness = 0
        obj.TitleBg.Filled = true
        obj.TitleBg.Visible = false
        
        obj.AccentBar = Drawing.new("Square")
        obj.AccentBar.Thickness = 0
        obj.AccentBar.Filled = true
        obj.AccentBar.Visible = false
        
        obj.TitleText = Drawing.new("Text")
        obj.TitleText.Size = 14
        obj.TitleText.Center = false
        obj.TitleText.Outline = false
        obj.TitleText.Font = 2
        obj.TitleText.Text = "ESP Preview (Drag me)"
        obj.TitleText.Visible = false
        
        -- ESP Elements
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
        obj.Bg.Visible = false
        obj.TitleBg.Visible = false
        obj.AccentBar.Visible = false
        obj.TitleText.Visible = false
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
            obj.Bg:Remove()
            obj.TitleBg:Remove()
            obj.AccentBar:Remove()
            obj.TitleText:Remove()
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

    local function drawPreviewESP(obj, cfg, role, centerX, boxY, frameBottomY, framePos, frameSize)
        if not obj or not cfg then return end
        local Library = PreviewManager.Library
        
        -- Draw Linoria-styled background dynamically
        obj.Bg.Size = Vector2.new(frameSize.X, frameSize.Y)
        obj.Bg.Position = framePos
        obj.Bg.Visible = true
        
        obj.TitleBg.Size = Vector2.new(frameSize.X, 20)
        obj.TitleBg.Position = framePos
        obj.TitleBg.Color = Library.BackgroundColor
        obj.TitleBg.Visible = true
        
        obj.AccentBar.Size = Vector2.new(frameSize.X, 2)
        obj.AccentBar.Position = Vector2.new(framePos.X, framePos.Y + 20)
        obj.AccentBar.Color = Library.AccentColor
        obj.AccentBar.Visible = true
        
        obj.TitleText.Position = Vector2.new(framePos.X + 5, framePos.Y + 2)
        obj.TitleText.Color = Library.FontColor
        obj.TitleText.Visible = true
        
        -- Draw ESP
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
        if not previewGui then createPreviewGui() end
        if not previewGui.Enabled then previewGui.Enabled = true end

        local role = PreviewManager.Role
        local survCfg = getRoleCfg("Survivor")
        local killCfg = getRoleCfg("Killer")

        local targetSizeX = (role == "Both") and 280 or 140
        if dragFrame.Size.X.Offset ~= targetSizeX then
            dragFrame.Size = UDim2.new(0, targetSizeX, 0, 260)
        end

        local framePos = dragFrame.AbsolutePosition
        local frameSize = dragFrame.AbsoluteSize
        
        -- Perfectly center the ESP block vertically inside the frame
        local espTotalHeight = 208
        local availableHeight = frameSize.Y - 20
        local topPadding = (availableHeight - espTotalHeight) / 2
        local boxY = framePos.Y + 20 + topPadding + 16
        local frameBottomY = framePos.Y + frameSize.Y - 10

        if role == "Survivor" or role == "Both" then
            if not previewObjs.Survivor then previewObjs.Survivor = createPreviewObj() end
            local centerX = framePos.X + (role == "Both" and (frameSize.X * 0.25) or (frameSize.X * 0.5))
            drawPreviewESP(previewObjs.Survivor, survCfg, "Survivor", centerX, boxY, frameBottomY, framePos, frameSize)
        else
            if previewObjs.Survivor then hidePreviewObj(previewObjs.Survivor) end
        end
        
        if role == "Killer" or role == "Both" then
            if not previewObjs.Killer then previewObjs.Killer = createPreviewObj() end
            local centerX = framePos.X + (role == "Both" and (frameSize.X * 0.75) or (frameSize.X * 0.5))
            drawPreviewESP(previewObjs.Killer, killCfg, "Killer", centerX, boxY, frameBottomY, framePos, frameSize)
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
        
        for _, obj in pairs(previewObjs) do
            destroyPreviewObj(obj)
        end
        previewObjs = {}
        self.Enabled = false
    end
end

return PreviewManager
