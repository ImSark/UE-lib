local PreviewManager = {} do
    PreviewManager.Library = nil
    PreviewManager.Enabled = false
    PreviewManager.Role = "Survivor"
    PreviewManager.Config = nil

    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local Camera = Workspace.CurrentCamera
    local CoreGui = game:GetService("CoreGui")
    local GuiService = game:GetService("GuiService")

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
                chams = PreviewManager.Config.SurvivorChams,
                chamsOpacity = PreviewManager.Config.SurvivorChamsOpacity,
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
                chams = PreviewManager.Config.KillerChams,
                chamsOpacity = PreviewManager.Config.KillerChamsOpacity,
                color = PreviewManager.Config.KillerColor,
            }
        end
        return nil
    end

    local previewObjs = {}
    local previewCenters = {
        Survivor = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.35),
        Killer = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.35)
    }

    local draggingPreview = nil
    local dragStartMouse = Vector2.zero
    local dragStartCenter = Vector2.zero

    local function createPreviewObj()
        local obj = {}
        
        obj.Bg = Drawing.new("Square")
        obj.Bg.Thickness = 0
        obj.Bg.Filled = true
        obj.Bg.Transparency = 0.2
        obj.Bg.Color = Color3.fromRGB(0, 0, 0)
        obj.Bg.Visible = false
        
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

    local function drawPreviewESP(obj, cfg, role, centerX, centerY)
        if not obj or not cfg then return end
        
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
        
        local pad = 8
        local bgX = boxX - boxWidth/2 - pad
        local bgY = boxY - 22
        local bgW = boxWidth + pad * 2
        local bgH = boxHeight + 44
        
        obj.Bg.Size = Vector2.new(bgW, bgH)
        obj.Bg.Position = Vector2.new(bgX, bgY)
        obj.Bg.Visible = true
        
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
            obj.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            obj.Tracer.To = Vector2.new(boxX, boxY + boxHeight / 2)
            obj.Tracer.Color = color
            obj.Tracer.Visible = true
        else
            obj.Tracer.Visible = false
        end
    end

    local dragBeginConn, dragChangedConn, dragEndConn

    local function setupDrag()
        if dragBeginConn then return end
        
        dragBeginConn = UserInputService.InputBegan:Connect(function(input)
            if not PreviewManager.Enabled then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
                local role = PreviewManager.Role
                
                if (role == "Survivor" or role == "Both") and previewObjs.Survivor and previewObjs.Survivor.Bg.Visible then
                    local bg = previewObjs.Survivor.Bg
                    if mousePos.X >= bg.Position.X and mousePos.X <= bg.Position.X + bg.Size.X and mousePos.Y >= bg.Position.Y and mousePos.Y <= bg.Position.Y + bg.Size.Y then
                        draggingPreview = "Survivor"
                        dragStartMouse = mousePos
                        dragStartCenter = previewCenters.Survivor
                        return
                    end
                end
                
                if (role == "Killer" or role == "Both") and previewObjs.Killer and previewObjs.Killer.Bg.Visible then
                    local bg = previewObjs.Killer.Bg
                    if mousePos.X >= bg.Position.X and mousePos.X <= bg.Position.X + bg.Size.X and mousePos.Y >= bg.Position.Y and mousePos.Y <= bg.Position.Y + bg.Size.Y then
                        draggingPreview = "Killer"
                        dragStartMouse = mousePos
                        dragStartCenter = previewCenters.Killer
                        return
                    end
                end
            end
        end)

        dragChangedConn = UserInputService.InputChanged:Connect(function(input)
            if draggingPreview and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
                local delta = mousePos - dragStartMouse
                previewCenters[draggingPreview] = dragStartCenter + delta
            end
        end)

        dragEndConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingPreview = nil
            end
        end)
    end

    local function updatePreview()
        local role = PreviewManager.Role
        local vp = Camera.ViewportSize
        
        if role == "Both" and previewCenters.Survivor == previewCenters.Killer then
            previewCenters.Survivor = Vector2.new(vp.X * 0.3, vp.Y * 0.35)
            previewCenters.Killer = Vector2.new(vp.X * 0.7, vp.Y * 0.35)
        end
        
        local survCfg = getRoleCfg("Survivor")
        local killCfg = getRoleCfg("Killer")
        
        if role == "Survivor" or role == "Both" then
            if not previewObjs.Survivor then previewObjs.Survivor = createPreviewObj() end
            local c = previewCenters.Survivor
            drawPreviewESP(previewObjs.Survivor, survCfg, "Survivor", c.X, c.Y)
        else
            if previewObjs.Survivor then hidePreviewObj(previewObjs.Survivor) end
        end
        
        if role == "Killer" or role == "Both" then
            if not previewObjs.Killer then previewObjs.Killer = createPreviewObj() end
            local c = previewCenters.Killer
            drawPreviewESP(previewObjs.Killer, killCfg, "Killer", c.X, c.Y)
        else
            if previewObjs.Killer then hidePreviewObj(previewObjs.Killer) end
        end
    end

    local renderConn
    local function startRenderLoop()
        if renderConn then return end
        setupDrag()
        renderConn = RunService.RenderStepped:Connect(function()
            if not PreviewManager.Enabled then
                for _, obj in pairs(previewObjs) do
                    hidePreviewObj(obj)
                end
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
            for _, obj in pairs(previewObjs) do
                hidePreviewObj(obj)
            end
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
        if dragBeginConn then dragBeginConn:Disconnect() dragBeginConn = nil end
        if dragChangedConn then dragChangedConn:Disconnect() dragChangedConn = nil end
        if dragEndConn then dragEndConn:Disconnect() dragEndConn = nil end
        
        for _, obj in pairs(previewObjs) do
            destroyPreviewObj(obj)
        end
        previewObjs = {}
        self.Enabled = false
    end
end

return PreviewManager
