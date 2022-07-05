local input = game:GetService("UserInputService")
local mouse = game:GetService("Players").LocalPlayer:GetMouse()
local inset = game:GetService("GuiService"):GetGuiInset()

--//Utils
local util = {} do
    function util.new(type, options, children)
        local roundedFrame = type == "RoundedFrame"
        local roundedButton = type == "RoundedButton"
        local rounded = roundedFrame or roundedButton

        type = roundedFrame and "ImageLabel" or (roundedButton and "ImageButton" or type)

        local instance = Instance.new(type)
        
        if instance:IsA("GuiObject") then instance.BorderSizePixel = 0 end

        if instance:IsA("TextLabel") then
            instance.TextXAlignment = Enum.TextXAlignment.Left
            instance.TextYAlignment = Enum.TextYAlignment.Top
        end

        if rounded then
            instance.BackgroundTransparency = 0
            instance.Image = "rbxassetid://4641149554"
            instance.ScaleType = Enum.ScaleType.Slice
            instance.SliceCenter = Rect.new(4, 4, 296, 296)
            instance.ImageColor3 = options.BackgroundColor3 or Color3.new(1,1,1)
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
        for i,v in pairs(properties) do
            if i == "BackgroundColor3" then
                properties["ImageColor3"] = v --rounded compat
            end
        end
        
        TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Linear), properties):Play()
    end

    function util.keypress()
        local key
        repeat key = input.InputBegan:Wait() until key.UserInputType == Enum.UserInputType.Keyboard
        wait()
        return key
    end
end

--//Classes
local library = { values = {} } --> values is a table of positions of all interactables on the UI
library.__index = library
local tab = {}
tab.__index = tab

--//Theme
local theme = getgenv().theme or {
    BackColor = Color3.fromRGB(45, 45, 50),
    TopBar = Color3.fromRGB(50, 50, 58),

    UpperContainer = Color3.fromRGB(50, 50, 58),
    InnerContainer = Color3.fromRGB(55, 55, 62),

    TextColor = Color3.fromRGB(255,255,255),
    SubTextColor = Color3.fromRGB(200,200,200)
}

--//Library
do
    function library.init(title, version, owner, id)
        local ScreenGui,MasterContainer = util.new("ScreenGui", { Parent = game:GetService("CoreGui"), Name=id }, {
            util.new("Frame", { --MasterContainer
                Size = UDim2.new(0, 510, 0, 430),
                Position = UDim2.new(0.2,0,0.2,0),
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
            util.new("RoundedFrame", { --> TabSelectContainer
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
            util.new("RoundedFrame", { --> TabContentContainer
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

        return setmetatable({
            _connections = connections,
            
            keybind = Enum.KeyCode.RightControl,
            visible = true,
            tabs = {},
            selectedTab = 1,

            MasterContainer = MasterContainer,
            TopBarContainer = TopBarContainer,
            ContentContainer = ContentContainer,
            TabSelectContainer = TabSelectContainer,
            TabContentContainer = TabContentContainer,

        }, library):_registerKeybind()
    end

    function library:AddTab(title, desc)
        local newTab = tab.new(self, title, desc, #self.tabs+1)

        -- newTab:_RegisterConnections()
        table.insert(self.tabs, newTab)
        -- if #self.tabs == 1 then 

        return newTab
    end

    function library:ToggleGUI(yesno)
        self.visible = (yesno == nil) and (not self.visible) or yesno
        if self.visible then self:_ShowGUI() else self:_HideGUI() end
        return self.visible
    end

    function library:_ShowGUI()
        self.MasterContainer:TweenSize(UDim2.new(0, 510, 0, 430), "Out", "Linear", 0.15, true)
    end
    function library:_HideGUI()
        self.MasterContainer:TweenSize(UDim2.new(0, 510, 0, 0), "In", "Linear", 0.15, true)
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
                    wait(0.2)
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
        local TabSelector = util.new("RoundedFrame", { --> TabSelector
            Parent = library.TabSelectContainer,
            Size = UDim2.new(1, -10, 0, 45), --> note: horizontla padding overriden by UIListLayour HorizontalAlignment property
            Position = UDim2.new(0, 5, 0, 4),
            BackgroundColor3 = theme.InnerContainer,
            LayoutOrder = id,
            Name = "TabSelector"
        }, {
            util.new("Frame", {
                Size = UDim2.new(0, 4, 1, 0),
                BackgroundColor3 = Color3.new(1,0,0),
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

        return setmetatable({
            library = library,
            title = title,

            selected = false,
            sections = {},

        }, tab)
    end
end

return library