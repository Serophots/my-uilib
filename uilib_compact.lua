local RunService = game:GetService("RunService")
local input = game:GetService("UserInputService")
local mouse = game:GetService("Players").LocalPlayer:GetMouse()
local inset = game:GetService("GuiService"):GetGuiInset()

local function EmptyFunction() end

--//Utils
local util = {} do
    function util.new(type, options, children)
        local instance = Instance.new(type)
        
        if instance:IsA("GuiObject") then instance.BorderSizePixel = 0 end

        if instance:IsA("TextLabel") then
            instance.TextXAlignment = Enum.TextXAlignment.Left
            instance.TextYAlignment = Enum.TextYAlignment.Top
        end

        if instance:IsA("TextButton") or instance:IsA("ImageButton") then
            instance.AutoButtonColor = false
            if instance:IsA("TextButton") then instance.Text = "" end
        end
        
        for i,v in pairs(options) do
            instance[i] = v
        end

        if not children then return instance end

        local toReturn = {instance}

        for i,v in pairs(children) do
            v.Parent = instance
            table.insert(toReturn, v)
        end

        return unpack(toReturn)
    end

    function util.children(parent, children)
        local toReturn = {}

        for _,child in pairs(children) do
            child.Parent = parent
            table.insert(toReturn, child)
        end

        return unpack(toReturn)
    end

    local TweenService = game:GetService("TweenService")
    function util.tween(instance, properties, duration)
        TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Linear), properties):Play()
    end
end

--//Classes
local library = { values = {} } --> values is a table of positions of all interactables on the UI
library.__index = library
local tab = {}
tab.__index = tab
local panel = {}
panel.__index = panel
local interactable = {}
interactable.__index = interactable

--//Theme
local theme = getgenv().theme or {
    BackColor = Color3.fromRGB(45, 45, 50),
    TopBar = Color3.fromRGB(50, 50, 58),

    UpperContainer = Color3.fromRGB(50, 50, 58),
    InnerContainer = Color3.fromRGB(55, 55, 62),

    InteractableBackground = Color3.fromRGB(45, 45, 58),
    InteractableOutline = Color3.fromRGB(100, 100, 100),

    Accent = Color3.fromRGB(130, 130, 180), --> Used for hover outlines, selected tab

    NotSelectedTab = Color3.fromRGB(70, 70, 100), --> shows on all OTHER tabs

    TextColor = Color3.fromRGB(255,255,255),
    SubTextColor = Color3.fromRGB(200,200,200),
}

--//Library
do
    function library.init(title, version, id, position, size)
        local position = position or UDim2.new(0.2, 0, 0.2, 0)
        local size = size or UDim2.new(0, 720, 0, 420)

        local ScreenGui,MasterContainer = util.new("ScreenGui", { Parent = game:GetService("CoreGui"), Name=id }, {
            util.new("Frame", { --MasterContainer
                Size = size,
                Position = position,
                BackgroundColor3 = theme.BackColor,
                ClipsDescendants = true,
                Name = "MasterContainer"
            })
        })

        --//Remove & Disconnect pre-existing UI's under same ID
        local preexisting = getgenv()[id]
        if preexisting then
            for i,v in pairs(preexisting.connections) do
                v:Disconnect()
            end
            preexisting.GUI:Destroy()
        end

        local connections = {}
        getgenv()[id] = {
            connections = connections,
            GUI = ScreenGui
        }

        --//Main containers
        local TopBarContainer, ContentContainer = util.children(MasterContainer, {
            util.new("Frame", { --> TopBarContainer
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = theme.TopBar,
                Name = "TopBarContainer"
            }),
            util.new("Frame", { --> ContentContainer
                Size = UDim2.new(1, 0, 1, -30),
                Position = UDim2.new(0,0,0,30),
                BackgroundTransparency = 1,
                Name = "ContentContainer"
            })
        })

        --//TopBar
        local TopBarTitle = util.children(TopBarContainer, {
            util.new("TextLabel", { -->TopBarTitle
                Text = title,
                TextColor3 = theme.TextColor,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                Position = UDim2.new(0, 8, 0, 8),
                Name = "TopBarTitle"
            })
        })

        --//Content Containers
        local TabSelectContainer, TabContentContainer = util.children(ContentContainer, {
            util.new("Frame", { --> TabSelectContainer
                Size = UDim2.new(0, 150, 1, -14), --> X: 157
                Position = UDim2.new(0, 7, 0, 7),
                BackgroundColor3 = theme.UpperContainer,
                Name = "TabSelectContainer"
            }, {
                util.new("UIListLayout", { --> Layout for left-side tab selectors
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0,7),
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                }),
                util.new("Frame", { --So UIListLayout leaves gap at top
                    BackgroundTransparency = 1,
                    LayoutOrder = 0,
                    Size = UDim2.new(1,0,0,-2), --> padding 7, -2 = 5 which is uniform :+1:
                    Name = "gap"
                })
            }),
            util.new("Frame", { --> TabContentContainer
                Size = UDim2.new(1, -171, 1, -14),
                Position = UDim2.new(0, 164, 0, 7),
                BackgroundColor3 = theme.UpperContainer,
                Name = "TabContentContainer"
            })
        })

        --// Dragability
        local isDragging = false
        local draggingOffset --distance from topleft corner to mouse

        table.insert(connections, input.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = input:GetMouseLocation() - inset
                local topLeft = MasterContainer.AbsolutePosition
                local bottomRight = topLeft + Vector2.new(MasterContainer.AbsoluteSize.X, 30) -- of topbar -> for click area

                if mouse.X > topLeft.X and mouse.X < bottomRight.X then
                    if mouse.Y > topLeft.Y and mouse.Y < bottomRight.Y then
                        isDragging = true
                        draggingOffset = mouse - topLeft
                    end
                end
            end
        end))
        table.insert(connections, input.InputEnded:Connect(function(inp)
            if isDragging and inp.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end))
        table.insert(connections, input.InputChanged:Connect(function(inp)
            if isDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local guiPos = input:GetMouseLocation() - draggingOffset - inset
                MasterContainer.Position = UDim2.new(0, guiPos.X, 0, guiPos.Y)
            end
        end))

        --// External click "signal" -> Used for dropdowns to detect if someone clicks outside of the dropdown -> close dropdown
        local externalClickFunctions = {}
        local function registerExternalClickFunction(f) table.insert(externalClickFunctions, f) end
        MasterContainer.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                for _,f in pairs(externalClickFunctions) do f(inp) end
            end
        end)


        return setmetatable({
            _connections = connections,
            
            size = size,
            keybind = Enum.KeyCode.RightControl,
            visible = true,
            tabs = {},
            selectedTab = 1,

            MasterContainer = MasterContainer,
            TopBarContainer = TopBarContainer,
            ContentContainer = ContentContainer,
            TabSelectContainer = TabSelectContainer,
            TabContentContainer = TabContentContainer,

            registerExternalClickFunction = registerExternalClickFunction,
        }, library):_registerKeybind()
    end

    function library:AddTab(title, desc)
        local newTab = tab.new(self, title, desc, #self.tabs+1)


        table.insert(self.tabs, newTab)
        if #self.tabs == 1 then newTab:select() end

        return unpack(newTab.panels)
    end

    function library:ToggleGUI(yesno)
        self.visible = (yesno == nil) and (not self.visible) or yesno
        if self.visible then self:_ShowGUI() else self:_HideGUI() end
        return self.visible
    end

    function library:_ShowGUI()
        self.MasterContainer:TweenSize(self.size, "Out", "Linear", 0.15, true)
    end
    function library:_HideGUI()
        self.MasterContainer:TweenSize(UDim2.new(0, self.size.X.Offset, 0, 0), "In", "Linear", 0.15, true)
    end

    function library:SetKeybind(new)
        self.keybind = new
        return self.keybind
    end

    function library:_registerKeybind()
        local debounce = false
        table.insert(self._connections, input.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                if inp.KeyCode == self.keybind and not debounce then
                    debounce = true
                    self:ToggleGUI()
                    wait(0.15)
                    debounce = false
                end
            end
        end))

        return self
    end
end

--//Tab
do
    function tab.new(library, title, desc, id)
        --//Tab Selector
        local TabSelector, TabSelectorColour = util.new("TextButton", { --> TabSelector
            Parent = library.TabSelectContainer,
            Size = UDim2.new(1, -10, 0, 45), --> note: horizontal padding overriden by UIListLayour HorizontalAlignment property
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundColor3 = theme.InnerContainer,
            LayoutOrder = id,
            Name = "TabSelector"
        }, {
            util.new("Frame", {
                Size = UDim2.new(0, 4, 1, 0),
                BackgroundColor3 = theme.NotSelectedTab,
            }),
            util.new("TextLabel", { --Title
                Text = title,
                TextColor3 = theme.TextColor,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                Position = UDim2.new(0, 12, 0, 8),
                Name = "TopBarTitleText"
            }),
            util.new("TextLabel",  {
                Text = desc,
                TextColor3 = theme.SubTextColor,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                Position = UDim2.new(0, 12, 0, 26),
                Name = "TopBarTitleDesc"
            })
            
        })

        
        local panels = {}
        local self = setmetatable({
            library = library,
            title = title,

            selected = false,
            sections = {},
            panels = panels,

            TabSelector = TabSelector,
            TabSelectorColour = TabSelectorColour,

        }, tab)

        --//Panels
        panels[1] = panel.new(self, {
            Parent = library.TabContentContainer, --Padding of 5 all way around parent container. Padding of 4 between 2 pannels
            Size = UDim2.new(0.5, -9, 1, -10),
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundColor3 = theme.InnerContainer,
            ScrollBarThickness = 0,
            Visible = false,
            Name = "TabPanel1"
        }, 1)
        panels[2] = panel.new(self, {
            Parent = library.TabContentContainer,
            Size = UDim2.new(0.5, -9, 1, -10),
            Position = UDim2.new(0.5, 4, 0, 5),
            BackgroundColor3 = theme.InnerContainer,
            ScrollBarThickness = 0,
            Visible = false,
            Name = "TabPanel2"
        }, 2)

        return self:_connections()
    end

    function tab:_connections()
        self.TabSelector.MouseButton1Down:Connect(function()
            self.selected = not self.selected
            if self.selected then
                self:select()
            else
                self:deselect()
            end
        end)
        return self
    end
    function tab:_deselectOthers()
        for _,tab in pairs(self.library.tabs) do
            if tab ~= self then
                tab:deselect()
            end
        end
    end
    function tab:select()
        self.selected = true
        self:_deselectOthers()
        util.tween(self.TabSelectorColour, { BackgroundColor3 = theme.Accent }, 0.15)
        for i,v in pairs(self.panels) do v.PanelContainer.Visible = self.selected end
    end
    function tab:deselect()
        self.selected = false
        util.tween(self.TabSelectorColour, { BackgroundColor3 = theme.NotSelectedTab }, 0.15)
        for i,v in pairs(self.panels) do v.PanelContainer.Visible = self.selected end
    end

end

--//Interactable -> boilerplate, nothing substantial -> probably could just be a table
do
    function interactable.new()
        return setmetatable({}, interactable) 
    end
end

--//Panel
do
    function panel.new(tab, panelProperties, id)
        local PanelContainer = util.new("ScrollingFrame", panelProperties, {
            util.new("UIListLayout", {
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 7),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            util.new("Frame", { --So UIListLayout leaves gap at top
                BackgroundTransparency = 1,
                LayoutOrder = 0,
                Size = UDim2.new(1,0,0,0), --> padding 7 + 0 (y offset) = 7 which is uniform :+1:
                Name = "gap"
            })
        })

        return setmetatable({
            tab = tab,
            PanelContainer = PanelContainer,
            id = id,
        }, panel)
    end

    function panel:_GlobalTable()
        local values = self.tab.library.values
        local tab = self.tab.title
        local panel = self.id
        local seperator = self.currentSeperator
        
        if not values[tab] then values[tab] = {} end
        if not values[tab][panel] then values[tab][panel] = {} end
        if not values[tab][panel][seperator] then values[tab][panel][seperator] = {} end

        return values[tab][panel][seperator]
    end

    function panel:_Container(height, clickable)
        return util.new(clickable and "TextButton" or "Frame", {
            Parent = self.PanelContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -14, 0, height), --> centered by UIListLayout
            LayoutOrder = #self.PanelContainer:GetChildren(),
            Name = "Container"
        })
    end

    function panel:AddSeperator(text)
        self.currentSeperator = text
        util.children(self:_Container(22), {
            util.new("TextLabel", {
                Text = text,
                TextColor3 = theme.SubTextColor,
                TextSize = 16,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(0,0,1,0),
                Position = UDim2.new(0,2,0,-1),
                TextYAlignment = Enum.TextYAlignment.Center,
                Name = "TopBarTitleDesc"
            })
        })
        return self --Use for looping -> local Section = panel:AddSeperator("First section") do ... end
    end

    function panel.AddToggle(panel, data) --with ColorPicker
        local callback = data.callback or EmptyFunction
        local self = interactable.new()
        self.checked = data.checked or false

        local text = data.title
        local value = panel:_GlobalTable()
        value[text] = self.checked

        local Container = panel:_Container(15, true)

        --//Check box
        local CheckboxOutline, CheckboxInside = util.new("Frame", {
            Parent = Container,
            Size = UDim2.new(0, 15, 0, 15),
            BackgroundColor3 = theme.InteractableOutline,
            Name = "CheckboxOutline"
        }, {
            util.new("Frame", {
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                BackgroundColor3 = theme.InteractableBackground,
                Name = "CheckboxInside"
            })
        })
        
        --// Text label
        util.new("TextLabel", {
            Parent = Container,
            Text = text,
            TextColor3 = theme.SubTextColor,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(0,0,1,0),
            Position = UDim2.new(0, 23, 0, -1),
            TextYAlignment = Enum.TextYAlignment.Center,
            Name = "CheckboxText"
        })

        --//Connections
        local function render(override)
            if self.checked then
                util.tween(CheckboxInside, { BackgroundColor3 = theme.Accent }, 0.1)
            else
                util.tween(CheckboxInside, { BackgroundColor3 = theme.InteractableBackground }, 0.1)
            end
            value[text] = self.checked
            if override then else
                callback(self.checked)
            end
        end
        render(true)
        
        Container.MouseButton1Down:Connect(function()
            self.checked = not self.checked
            render()
        end)
        Container.MouseEnter:Connect(function()
            util.tween(CheckboxOutline, { BackgroundColor3 = theme.Accent }, 0.1)
        end)
        Container.MouseLeave:Connect(function()
            util.tween(CheckboxOutline, { BackgroundColor3 = theme.InteractableOutline }, 0.1)
        end)


        --//Optional colorpicker
        local colorpickerReturn = {}
        if data.colorpicker then
            local callback = data.colorpicker.callback or EmptyFunction
            self.expandedColor = false
            --//Toggle box
            local ColorpickerboxOutline, ColorpickerboxInside = util.new("Frame", {
                Parent = Container,
                Size = UDim2.new(0, 20, 0, 13),
                Position = UDim2.new(1,-20,0,1),
                BackgroundColor3 = theme.InteractableOutline,
                Name = "ColorpickerboxOutline"
            }, {
                util.new("TextButton", {
                    Size = UDim2.new(1,-2,1,-2),
                    Position = UDim2.new(0,1,0,1),
                    BackgroundColor3 = theme.Accent,
                    Name = "ColorpickerboxInside"
                })
            })

            --//Colorpicker window frame
            local ColorpickerWindowContainer, ColorpickerWindow = util.new("TextButton", { -->handle clicks so they dont go thru the frame to anything below
                Parent = ColorpickerboxOutline,
                Size = UDim2.new(0, 200, 0, 230),
                Position = UDim2.new(1, -200, 1, 0),
                BackgroundColor3 = theme.UpperContainer,
                ClipsDescendants = true,
                Visible = self.expandedColor,
                ZIndex = 70,
                Name = "ColorpickerWindowContainer"
            }, {
                util.new("Frame", {
                    Size = UDim2.new(1, -10, 1, -10),
                    Position = UDim2.new(0, 5, 0, 5),
                    BackgroundColor3 = theme.InnerContainer,
                    ZIndex = 70,
                    Name = "ColorpickerWindow"
                })
            })

            --[[
                Understanding HSV: https://colorpicker.me/

                As you move the bar on the side, Hue changes linearly. This "Side bar" is therefore a Hue Slider

                In the middle:
                - As you move left to right, Saturation linearly ranges 0-100
                - As you move Top to Bottom, Value linearly ranges 0-100
            ]]

            --//Saturation + Value BOX. Saturation is linear left-right, Value is linear top-bottom
            local SatValWindow = util.new("ImageButton", {
                Parent = ColorpickerWindow,
                Size = UDim2.new(0, 180, 0, 180),
                Position = UDim2.new(0, 5, 0, 5),
                Image = "rbxassetid://4805274903",
                BackgroundColor3 = Color3.new(1,1,1),
                ImageColor3 = Color3.new(1,0,0),
                ZIndex = 70,
                Name = "SatValWindow"
            })
            local SatValSelector = util.new("Frame", {
                Parent = SatValWindow,
                Size = UDim2.new(0,4,0,4),
                BackgroundColor3 = Color3.new(1,1,1),
                ZIndex = 70,
                Name = "SatValSelector"
            })

            --//Hue SLIDER -> https://en.wikipedia.org/wiki/Hue
            local HueBar = util.new("ImageButton", {
                Parent = ColorpickerWindow,
                Size = UDim2.new(0, 180, 0, 25),
                Position = UDim2.new(0, 5, 0, 190),
                Image = "rbxassetid://3551296450",
                BackgroundColor3 = Color3.new(1,1,1),
                ImageColor3 = Color3.new(1,1,1),
                ZIndex = 70,
                Name = "HueBar"
            })
            local HueSelector = util.new("Frame", {
                Parent = HueBar,
                Size = UDim2.new(0,2,1,6),
                Position = UDim2.new(0,0,0,-3),
                BackgroundColor3 = Color3.new(1,1,1),
                ZIndex = 70,
                Name = "HueSelector"
            })
            --> Hue slider controls HUE. Within hue slider, S and V are set to 100%
            --> ^ When calculating RGB for ShadeWindow, HSV(mousePos, 100%, 100%) -> rgb

            local currentHue, currentSat, curreentVal = 0,0,0
            local function hueFromPercent(percent, override)
                currentHue = percent
                SatValWindow.ImageColor3 = Color3.fromHSV(currentHue, 1, 1) --values range 0-1
                HueSelector.Position = UDim2.new(currentHue, -1, 0, -3)
                ColorpickerboxInside.BackgroundColor3 = Color3.fromHSV(currentHue, currentSat, currentVal)

                value[text.."_COLOR"] = ColorpickerboxInside.BackgroundColor3
                if override then else
                    callback(ColorpickerboxInside.BackgroundColor3)
                end
            end
            local function satValFromPercent(percentX, percentY, override)
                currentSat, currentVal = percentX, percentY
                SatValSelector.Position = UDim2.new(1-currentSat, -2, 1-currentVal, -2)
                ColorpickerboxInside.BackgroundColor3 = Color3.fromHSV(currentHue, currentSat, currentVal)

                value[text.."_COLOR"] = ColorpickerboxInside.BackgroundColor3
                if override then else
                    callback(ColorpickerboxInside.BackgroundColor3)
                end
            end
            
            local function hueFromMouse()
                local x = math.clamp((input:GetMouseLocation().X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0,1)
                hueFromPercent(x)
            end
            local function satValFromMouse()
                local mouse = input:GetMouseLocation()
                local x = 1-math.clamp((mouse.X           - SatValWindow.AbsolutePosition.X) / SatValWindow.AbsoluteSize.X, 0,1)
                local y = 1-math.clamp((mouse.Y - inset.Y - SatValWindow.AbsolutePosition.Y) / SatValWindow.AbsoluteSize.Y, 0,1)
                satValFromPercent(x, y)
            end

            local function setColor(Color, override)
                local hue, sat, val = Color3.toHSV(Color)
                hueFromPercent(hue, override)
                satValFromPercent(sat, val, override)
            end
            setColor(data.colorpicker.default or Color3.new(1,0,0), true)


            --//Connections
            local isUsingHueBar = false
            HueBar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    isUsingHueBar = true
                end
            end)
            HueBar.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    isUsingHueBar = false
                end
            end)

            local isUsingSatValWindow = false
            SatValWindow.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    isUsingSatValWindow = true
                end
            end)
            SatValWindow.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    isUsingSatValWindow = false
                end
            end)

            RunService.RenderStepped:Connect(function()
                if isUsingHueBar then
                    hueFromMouse()
                elseif isUsingSatValWindow then
                    satValFromMouse()
                end
            end)

            ColorpickerboxInside.MouseButton1Down:Connect(function()
                self.expandedColor = not self.expandedColor
                ColorpickerWindowContainer.Visible = self.expandedColor
            end)
            ColorpickerboxOutline.MouseEnter:Connect(function()
                util.tween(ColorpickerboxOutline, { BackgroundColor3 = theme.Accent }, 0.1)
            end)
            ColorpickerboxOutline.MouseLeave:Connect(function()
                util.tween(ColorpickerboxOutline, { BackgroundColor3 = theme.InteractableOutline }, 0.1)
            end)
            panel.tab.library.registerExternalClickFunction(function(inp) --click outside dropdown
                self.expandedColor = false
                ColorpickerWindowContainer.Visible = self.expandedColor
            end)

            colorpickerReturn = {
                setColor = setColor,
                getColor = function() return ColorpickerboxInside.BackgroundColor3 end,
                callback = callback
            }
        end

        return {
            colorpicker = colorpickerReturn,
            setToggled = function(toggled)
                self.checked = toggled
                render()
            end,
            toggle = function()
                self.checked = not self.checked
                render()
            end,
            getToggled = function() return self.checked end,
            callback = callback
        }, colorpickerReturn
    end
    
    function panel.AddSlider(panel, data)
        local callback = data.callback or EmptyFunction
        local self = interactable.new()
        self.values = data.values or {min=0,max=100,default=50,round=1}

        local text = data.title
        local value = panel:_GlobalTable()
        value[text] = self.values.default or 50

        local function round(x) --Number of 0's after 1 in data.values.round defines number of decimal places. 1 = x, 10 = x.x, 100 = x.xx
            return math.floor((x*(self.values.round or 1))+0.5)/(self.values.round or 1)
        end
        local Container = panel:_Container(26, true)

        --//Text
        util.new("TextLabel", {
            Parent = Container,
            Text = text,
            TextColor3 = theme.SubTextColor,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(0,0,0,16),
            Position = UDim2.new(0, 0, 0, -2),
            TextYAlignment = Enum.TextYAlignment.Center,
        })

        --//Value box
        local ValueboxOutline, ValueboxInside = util.new("Frame", {
            Parent = Container,
            Size = UDim2.new(0, 30, 0, 14), --Text is size Y 16, keep inline with that
            Position = UDim2.new(1, -30, 0, 0),
            BackgroundColor3 = theme.InteractableOutline,
            Name = "ValueboxOutline"
        }, {
            util.new("TextBox", {
                Text = "12.5",
                TextSize = 6,
                TextColor3 = theme.SubTextColor,
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                BackgroundColor3 = theme.InteractableBackground,
                Name = "ValueboxInside"
            })
        })

        --//Slider bar box
        local SliderboxOutline, SliderboxInside, SliderboxFill = util.new("Frame", {
            Parent = Container,
            Size = UDim2.new(1, 0, 0, 9),
            Position = UDim2.new(0, 0, 0, 17),
            BackgroundColor3 = theme.InteractableOutline,
            Name = "SliderboxOutline"
        }, {
            util.new("Frame", {
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                BackgroundColor3 = theme.InteractableBackground,
                Name = "SliderboxInside"
            }),
            util.new("Frame", {
                Size = UDim2.new(0, 0, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                BackgroundColor3 = theme.Accent,
                Name = "SliderboxFill",
            }),
            util.new("Frame", {
                Size = UDim2.new(0, 1, 1, 0),
                Position = UDim2.new(0, -1, 0, 0),
                BackgroundColor3 = theme.InteractableOutline,
                ZIndex = 2,
                Name = "SliderboxOutlineLeftWall" --Reinforce left wall since when SliderboxFill size is negative (scale: 0, offset: -2) it leaks over edge
            })
        })

        --//Functions
        local isInteracting = false

        local function renderFromPercent(percent, override)
            local percent = math.clamp(percent,0,1)

            local min = self.values.min or 0
            local max = self.values.max or 0
            local diff = max-min

            local actualValue = round(percent * diff + min)
            ValueboxInside.Text = tostring(actualValue)
            
            SliderboxFill:TweenSize(UDim2.new(percent, -2, 1, -2), "In", "Linear", 0.05, true, function()
                if SliderboxFill.AbsoluteSize.X < 0 then SliderboxFill.Size = UDim2.new(0,0,1,-2) end --negative size will show over outline. Works in conjunction with SliuderboxOutlineLeftWall
            end)

            value[text] = actualValue
            if override then else
                callback(actualValue)
            end
        end
        local function renderFromValue(value, override)
            local min = self.values.min or 0
            local max = self.values.max or 0
            local diff = max-min
            
            renderFromPercent((value - min)/diff, override)
        end
        local function renderFromMouse()
            local clickedPercentage = (input:GetMouseLocation().X - SliderboxOutline.AbsolutePosition.X) / SliderboxOutline.AbsoluteSize.X
            if clickedPercentage > 99.7/100 then clickedPercentage = 1 end
            if clickedPercentage < 0.3/100 then clickedPercentage = 0 end

            renderFromPercent(clickedPercentage)
        end
        renderFromValue(self.values.default or 0, true)
        
        --//Connections
        --Slider interact
        Container.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                isInteracting = true
            end
        end)
        Container.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                isInteracting = false
            end
        end)
        RunService.RenderStepped:Connect(function()
            if isInteracting then
                renderFromMouse()
            end
        end)

        --Value box hover
        local isFocused = false
        ValueboxInside.Focused:Connect(function()
            isFocused = true
            util.tween(ValueboxOutline, { BackgroundColor3 = theme.Accent }, 0.1)
        end)
        ValueboxInside.FocusLost:Connect(function()
            if tonumber(ValueboxInside.Text) then
                renderFromValue(tonumber(ValueboxInside.Text))
            end
            isFocused = false
            util.tween(ValueboxOutline, { BackgroundColor3 = theme.InteractableOutline }, 0.1)
        end)
        ValueboxOutline.MouseEnter:Connect(function()
            util.tween(ValueboxOutline, { BackgroundColor3 = theme.Accent }, 0.1)
        end)
        ValueboxOutline.MouseLeave:Connect(function()
            if not isFocused then util.tween(ValueboxOutline, { BackgroundColor3 = theme.InteractableOutline }, 0.1) end
        end)

        --Container hover
        Container.MouseEnter:Connect(function()
            util.tween(SliderboxOutline, { BackgroundColor3 = theme.Accent }, 0.1)
        end)
        Container.MouseLeave:Connect(function()
            util.tween(SliderboxOutline, { BackgroundColor3 = theme.InteractableOutline }, 0.1)
        end)

        return {
            setPercent = renderFromPercent, --NOTE: Despite name, this takes value 0-1, not 0-100
            setValue = renderFromValue,
            getValue = function() return value[text] end,
            callback = callback
        }
    end

    function panel.AddDropdown(panel, data) --> Select one
        local callback = data.callback or EmptyFunction
        local self = interactable.new()
        self.options = data.options or {}
        self.expanded = false
        
        --//ui.values
        local text = data.title
        local value = panel:_GlobalTable()
        --Default is set when renderOptions() is called for first time


        local Container = panel:_Container(34, true)
        --//Text
        util.new("TextLabel", {
            Parent = Container,
            Text = text,
            TextColor3 = theme.SubTextColor,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(0,0,0,16),
            Position = UDim2.new(0, 0, 0, -2),
            TextYAlignment = Enum.TextYAlignment.Center,
        })

        --//Dropdown bar box
        local DropdownboxOutline, DropdownboxInside, DropdownboxText = util.new("Frame", {
            Parent = Container,
            Size = UDim2.new(1, 0, 0, 17), --> Size Y of 20 to work with
            Position = UDim2.new(0, 0, 0, 17),
            BackgroundColor3 = theme.InteractableOutline,
            Name = "DropdownboxOutline"
        }, {
            util.new("Frame", {
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                BackgroundColor3 = theme.InteractableBackground,
                Name = "DropdownboxInside"
            }),
            util.new("TextLabel", {
                Text = "",
                TextColor3 = theme.SubTextColor,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(1,-5,1,0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                TextYAlignment = Enum.TextYAlignment.Center,
            })
        })
        
        --//Dropdown menu (contextmenu)
        local DropdownMenu, UIListLayout = util.new("Frame", {
            Parent = DropdownboxOutline,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = theme.InteractableOutline,
            ZIndex = 60,
            ClipsDescendants = true,
        }, {
            util.new("UIListLayout", { --> Layout for left-side tab selectors
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0,0),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            })
        })
        local DropdownItem = util.new("TextButton", { --Example item
            LayoutOrder = 1,
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 61,
            BackgroundColor3 = theme.InteractableOutline
        }, {
            util.new("Frame", {
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                ZIndex = 61,
                BackgroundColor3 = theme.InteractableBackground,
            }),
            util.new("TextLabel", {
                Text = "Option Example",
                TextColor3 = theme.SubTextColor,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(0,0,1,0),
                Position = UDim2.new(0, 5, 0, 0),
                ZIndex = 63,
                TextYAlignment = Enum.TextYAlignment.Center,
            })
        })
        
        --//Render functions
        local function renderDropdown()
            if self.expanded then
                DropdownMenu:TweenSize(UDim2.new(1,0,0,UIListLayout.AbsoluteContentSize.Y), "Out", "Linear", 0.1, true)
            else
                DropdownMenu:TweenSize(UDim2.new(1,0,0,0), "In", "Linear", 0.1, true)
                util.tween(DropdownboxOutline, { BackgroundColor3 = theme.InteractableOutline }, 0.07)
            end
        end


        local optionObjects = {}
        local function renderOptions()
            local options = self.options

            for i,v in pairs(optionObjects) do v:Destroy() end
            optionObjects = {}

            for count,text in pairs(options) do

                local DropdownItem = DropdownItem:Clone()
                DropdownItem.Parent = DropdownMenu
                DropdownItem.LayoutOrder = count
                local ItemText = DropdownItem:FindFirstChildOfClass("TextLabel")
                ItemText.Text = text

                local function select(override)
                    if self.expanded or override then --double clicks
                        DropdownboxText.Text = text
                        self.expanded = false
                        self.selected = count
                        renderDropdown()

                        value[text] = count
                        if override then else
                            callback(count, text)
                        end
                    end
                end
                DropdownItem.MouseButton1Click:Connect(select)

                if count == (data.default or 0) then
                    select(true)
                end

                DropdownItem.MouseEnter:Connect(function()
                    util.tween(ItemText, { TextColor3 = theme.Accent }, 0.1)
                end)
                DropdownItem.MouseLeave:Connect(function()
                    util.tween(ItemText, { TextColor3 = theme.SubTextColor }, 0.1)
                end)

                table.insert(optionObjects, DropdownItem)
            end
        end
        renderOptions()
        data.default = 0 --doesn't set to default again

        --//Basic connectionss
        Container.MouseButton1Down:Connect(function()
            self.expanded = not self.expanded
            renderDropdown()
        end)
        Container.MouseEnter:Connect(function()
            util.tween(DropdownboxOutline, { BackgroundColor3 = theme.Accent }, 0.07)
        end)
        Container.MouseLeave:Connect(function()
            if not self.expanded then
                util.tween(DropdownboxOutline, { BackgroundColor3 = theme.InteractableOutline }, 0.07)
            end
        end)
        panel.tab.library.registerExternalClickFunction(function(inp) --click outside dropdown
            self.expanded = false
            renderDropdown()
        end)

        return {
            setOptions = function(options)
                self.selected = 0
                self.options = options
                renderOptions()
            end,
            setSelected = function(count) --call with index of item in options list
                local text = self.options[count]
                DropdownboxText.Text = text
                self.selected = count

                value[text] = count
                callback(count, text)
            end,
            getSelected = function() return self.selected, self.options[self.selected] end, --returns index, text
            setDropdownExpanded = function(expanded)
                self.expanded = expanded
                renderDropdown()
            end,
            callback = callback
        }
    end
    
    function panel.AddSelection(panel, data) --> Select many
        local callback = data.callback or EmptyFunction
        local self = interactable.new()
        self.selected = {} --list of indexes. Use optionsText to then get text
        self.options = data.options or {}
        self.optionObjects = {} --[index] = guiInstance
        self.expanded = false
        
        --//ui.values
        local text = data.title
        local value = panel:_GlobalTable()
        --Default is set when renderOptions() is called for first time


        local Container = panel:_Container(34, true)
        --//Text
        util.new("TextLabel", {
            Parent = Container,
            Text = text,
            TextColor3 = theme.SubTextColor,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(0,0,0,16),
            Position = UDim2.new(0, 0, 0, -2),
            TextYAlignment = Enum.TextYAlignment.Center,
        })

        --//Dropdown bar box
        local DropdownboxOutline, DropdownboxInside, DropdownboxText = util.new("Frame", {
            Parent = Container,
            Size = UDim2.new(1, 0, 0, 17), --> Size Y of 20 to work with
            Position = UDim2.new(0, 0, 0, 17),
            BackgroundColor3 = theme.InteractableOutline,
            Name = "DropdownboxOutline"
        }, {
            util.new("Frame", {
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                BackgroundColor3 = theme.InteractableBackground,
                Name = "DropdownboxInside"
            }),
            util.new("TextLabel", {
                Text = "",
                TextColor3 = theme.SubTextColor,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(1,-5,1,0),
                Position = UDim2.new(0, 5, 0, 0),
                ClipsDescendants = true,
                BackgroundTransparency = 1,
                TextYAlignment = Enum.TextYAlignment.Center,
            })
        })
        
        --//Dropdown menu (contextmenu)
        local DropdownMenu, UIListLayout = util.new("Frame", {
            Parent = DropdownboxOutline,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = theme.InteractableOutline,
            ZIndex = 60,
            ClipsDescendants = true,
        }, {
            util.new("UIListLayout", { --> Layout for left-side tab selectors
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0,0),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            })
        })
        local DropdownItem = util.new("TextButton", { --Example item
            LayoutOrder = 1,
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 61,
            BackgroundColor3 = theme.InteractableOutline
        }, {
            util.new("Frame", {
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                ZIndex = 61,
                BackgroundColor3 = theme.InteractableBackground,
            }),
            util.new("TextLabel", {
                Text = "Option Example",
                TextColor3 = theme.SubTextColor,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(0,0,1,0),
                Position = UDim2.new(0, 5, 0, 0),
                ZIndex = 63,
                TextYAlignment = Enum.TextYAlignment.Center,
            })
        })
        
        --//Render functions
        local function renderDropdown()
            if self.expanded then
                DropdownMenu:TweenSize(UDim2.new(1,0,0,UIListLayout.AbsoluteContentSize.Y), "Out", "Linear", 0.1, true)
            else
                DropdownMenu:TweenSize(UDim2.new(1,0,0,0), "In", "Linear", 0.1, true)
                util.tween(DropdownboxOutline, { BackgroundColor3 = theme.InteractableOutline }, 0.07)
            end
        end

        local function renderSelected()
            local text = ""
            for _,count in pairs(self.selected) do
                text = text..self.optionObjects[count]:FindFirstChildOfClass("TextLabel").Text..", "
            end
            DropdownboxText.Text = text:sub(1, #text-2)

            value[text] = self.selected
        end


        local function renderOptions()
            local options = self.options

            for i,v in pairs(self.optionObjects) do v:Destroy() end
            self.optionObjects = {}

            for count,text in pairs(options) do
                local selected = false

                local DropdownItem = DropdownItem:Clone()
                DropdownItem.Parent = DropdownMenu
                DropdownItem.LayoutOrder = count
                local ItemText = DropdownItem:FindFirstChildOfClass("TextLabel")
                ItemText.Text = text

                local function select(override)
                    if self.expanded or override then --double clicks
                        local found = table.find(self.selected, DropdownItem.LayoutOrder)
                        if found then
                            table.remove(self.selected, found)
                            util.tween(ItemText, { TextColor3 = theme.SubTextColor }, 0.1)
                            selected = false
                        else
                            table.insert(self.selected, DropdownItem.LayoutOrder)
                            util.tween(ItemText, { TextColor3 = theme.Accent }, 0.1)
                            selected = true
                        end


                        if override then else
                            renderSelected() --if override then renderSelected() is called at the end, when all defaults are put in
                            --value[text] set in renderSelected()
                            callback(self.selected)
                        end
                    end
                end
                DropdownItem.MouseButton1Click:Connect(select)

                if data.default and table.find(data.default, count) then
                    select(true)
                end

                DropdownItem.MouseEnter:Connect(function()
                    util.tween(ItemText, { TextColor3 = theme.Accent }, 0.1)
                end)
                DropdownItem.MouseLeave:Connect(function()
                    if not selected then
                        util.tween(ItemText, { TextColor3 = theme.SubTextColor }, 0.1)
                    end
                end)

                self.optionObjects[count] = DropdownItem
            end
        end
        renderOptions()
        renderSelected()
        data.default = {} --dont set defaults again

        --//Basic connectionss
        Container.MouseButton1Down:Connect(function()
            self.expanded = not self.expanded
            renderDropdown()
        end)
        Container.MouseEnter:Connect(function()
            util.tween(DropdownboxOutline, { BackgroundColor3 = theme.Accent }, 0.07)
        end)
        Container.MouseLeave:Connect(function()
            if not self.expanded then
                util.tween(DropdownboxOutline, { BackgroundColor3 = theme.InteractableOutline }, 0.07)
            end
        end)
        panel.tab.library.registerExternalClickFunction(function(inp) --click outside dropdown
            self.expanded = false
            renderDropdown()
        end)

        
        return {
            setOptions = function(options)
                self.selected = {}
                self.options = options
                renderOptions()
            end,
            setSelected = function(table) --Table of indexes for all the items to be selected
                self.selected = table
                renderSelected()
            end,
            getSelected = function() return self.selected end, --returns list of indexes
            setDropdownExpanded = function(expanded)
                self.expanded = expanded
                renderDropdown()
            end,
            callback = callback
        }
    end
end

return library