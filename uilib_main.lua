--V1.0.0 by Serophots

local input = game:GetService("UserInputService")
local mouse = game.Players.LocalPlayer:GetMouse()
local guiInset = game:GetService("GuiService"):GetGuiInset()

local function EmptyFunction() end

--// Utilities
local util = {} do 
  local letters = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
  function util.RandomString(length)
    local random = Random.new()
    local str = ''
    for _= 1, length do
        local randomLetter = letters[random:NextInteger(1, #letters)]
        if random:NextNumber() > .5 then
            randomLetter = string.upper(randomLetter)
        end
        str = str .. randomLetter
    end
    return str
  end

  function util:CreateObject(type, options, children, selectChildren, includeParent)
    local t = type

    local roundedFrame = type == "RoundedFrame"
    local roundedButton = type == "RoundedButton"

    if roundedFrame then t = "ImageLabel" elseif roundedButton then t = "ImageButton" end

    local instance = Instance.new(t)
    
    if instance:IsA("GuiObject") then
      instance.BorderSizePixel = 0
    end

    if roundedFrame or roundedButton then
      instance.BackgroundTransparency = 1
    end

    for i,v in pairs(options) do
        instance[i] = v
    end
    if roundedFrame or roundedButton then
      instance.Image = "rbxassetid://4641149554"
      instance.ScaleType = Enum.ScaleType.Slice
      instance.SliceCenter = Rect.new(4, 4, 296, 296)
      instance.ImageColor3 = instance.BackgroundColor3
    end

    instance.Name = util.RandomString(10)

    if children == nil then
      return instance
    end

    local toReturn = {}
    if includeParent then table.insert(toReturn, instance) end
    for i,v in pairs(children) do
      v.Parent = instance
      table.insert(toReturn, v)
    end

    if selectChildren == true then
      return toReturn --Allow to select from defined children in order to store in variable easily
    end
    return instance
  end

  function util:CreateChildren(parent, children)
    local toReturn = {}
    for i,v in pairs(children) do
      v.Parent = parent
      table.insert(toReturn, v)
    end

    return toReturn --Allow to select from defined children in order to store in variable easily
  end

	function util:Tween(instance, properties, duration)
    for i,v in pairs(properties) do
      if i == "BackgroundColor3" then
        properties["ImageColor3"] = v
      end
    end
		game:GetService("TweenService"):Create(instance, TweenInfo.new(duration), properties):Play()
	end

  function util:Offsets(x, y) return UDim2.new(0, x, 0, y) end --UDim2 class has a .fromOffsets function already, woops

  function util:Centered(x, y) return UDim2.new(0.5, -(x/2), 0.5, -(y/2)) end

  function util:VectorToOffsets(v) return UDim2.new(0, v.X, 0, v.Y) end

  function util:ListenForKeypress()
    local key
    repeat key = input.InputBegan:Wait() until key.UserInputType == Enum.UserInputType.Keyboard
    wait()

		return key
  end

  function util:GetLocalCharacter(child)
    local character = game.Players.LocalPlayer.Character
    if character then
      if child ~= nil then
        local ch = character:FindFirstChild(child)
        if ch then return ch end
      else
        return character
      end
    end
    return setmetatable({
      __index = function() end,
      __newindex = function() end,
    }, {}) --No errors if nothing is returned
  end
end

--// Keybinds
local keybindBindings = {}
local keybindFunctions = {}
local function keybindConnection(inp, gpe) --connected in library init
  if inp.UserInputType == Enum.UserInputType.Keyboard and not gpe then
    for i,v in pairs(keybindBindings) do
      if inp.KeyCode == v then
        keybindFunctions[i]()
        -- dont break
      end
    end
  end
end

--// Players dropdowns
local PlayerDropdowns = {}
local PlayerList = {}
local function updatePlayerList()
  PlayerList = {}
  for _,p in pairs(game.Players:GetPlayers()) do
    PlayerList[p.DisplayName] = p
    PlayerList[p.Name] = p
  end
  for _,v in pairs(PlayerDropdowns) do
    v.setOptions(PlayerList)
  end
end
updatePlayerList()
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)

--// Classes
local library = {}
library.__index = library
local tab = {}
tab.__index = tab
local section = {}
section.__index = section
local interactableBuilder = {} --Chain differnet interactables together
interactableBuilder.__index = interactableBuilder
local interactable = {} -- Anything the user interacts with. Button, toggle, input, etc
interactable.__index = interactable

--Theme
local theme = getgenv().theme or {
  BackColor = Color3.fromRGB(45, 45, 50),
  SubFrameColor = Color3.fromRGB(50, 50, 58),
  InnerFrameColor = Color3.fromRGB(55, 55, 62),
  InteractiveBackColor = Color3.fromRGB(60, 60, 70),
  
  ButtonClickedColor = Color3.fromRGB(55, 55, 62),
  ButtonUsedColor = Color3.fromRGB(48, 48, 54),
  
  TabHoverColor = Color3.fromRGB(86, 86, 96),
  TabSelectedColor = Color3.fromRGB(70, 70, 106),
  
  MainTextColor = Color3.fromRGB(255,255,255),
  SubTextColor = Color3.fromRGB(200,200,200),
  
  SliderBar = Color3.fromRGB(200,200,200),
  SliderBarValue = Color3.fromRGB(240,240,255),
}

do --Library class
  function library.init(title, version, owner, id)
    local MasterContainer = util:CreateObject("ScreenGui", { Parent = game:GetService("CoreGui") }, {
      util:CreateObject("RoundedFrame", {
        Size = util:Offsets(510, 430),
        Position = util:Centered(510, 430),
        BackgroundColor3 = theme.BackColor,
        ClipsDescendants = true,
        Name = "ScreenGui"
      })
    }, true)[1]

    if getgenv()[id] then
      for i,v in pairs(getgenv()[id.."_conns"]) do v:Disconnect() end
      getgenv()[id]:Destroy()
    end
    getgenv()[id] = MasterContainer.Parent
    getgenv()[id.."_conns"] = table.create(5) --//rough figure
    --//Conn set in initKeybind() below

    --Frame structure
    local TopBarContainer, ContentContainer = unpack(util:CreateChildren(MasterContainer, {
      util:CreateObject("Frame", { --TopBarContainer
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = theme.SubFrameColor,
        Name = "TopBarContainer",
      }, { --TopBarContianer children
        util:CreateObject("TextLabel", {
          Size = UDim2.new(1, -12, 1, 0),
          Position = UDim2.new(0, 8, -0.18, 0),
          BackgroundTransparency = 1,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextColor3 = theme.MainTextColor,
          TextSize = 15,
          Font = Enum.Font.GothamBold,
          Text = title,
          Name = "TopBarTitle",
        }),
        --Script Credit
        util:CreateObject("TextLabel", {
          Size = UDim2.new(1, -12, 0.3, 0),
          Position = UDim2.new(0, 8, 0.56, 1),
          BackgroundTransparency = 1,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextColor3 = theme.SubTextColor,
          TextSize = 12,
          Font = Enum.Font.Gotham,
          Text = "By "..owner,
          Name = "TopBarTitle",
        }),
        --Version stuff
        util:CreateObject("TextLabel", {
          Size = UDim2.new(1, -4, 0.3, 0),
          Position = UDim2.new(0, 0, 0, 5),
          BackgroundTransparency = 1,
          TextXAlignment = Enum.TextXAlignment.Right,
          TextColor3 = theme.SubTextColor,
          TextSize = 13,
          Font = Enum.Font.GothamBold,
          Text = version,
          Name = "TopBarTitle",
        })
      }),
      util:CreateObject("Frame", { --ContentContainer
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40),
        BackgroundTransparency = 1,
        Name = "ContentContainer"
      }, {
        util:CreateObject("TextLabel", { --UI Lib Credit
          Size = UDim2.new(1, -4, 0, 20),
          Position = UDim2.new(0, 0, 1, -18),
          BackgroundTransparency = 1,
          TextXAlignment = Enum.TextXAlignment.Right,
          TextColor3 = theme.SubTextColor,
          TextSize = 11,
          ZIndex = 5,
        	Font = Enum.Font.GothamBold,
          Text = "UI Library by Serophots",
          Name = "UILibCredit",
        })
      }),
    }))
    local TabSelectContainer, TabContentContainer = unpack(util:CreateChildren(ContentContainer, {
      util:CreateObject("RoundedFrame", { --TabSelectContainer
        Size = UDim2.new(0, 151, 1, -14),
        Position = util:Offsets(7, 7), --Padding
        BackgroundColor3 = theme.SubFrameColor,
        Name = "TabSelectContainer"
      }),
      util:CreateObject("RoundedFrame", { --TabContentContainer
        Size = UDim2.new(0, 336, 1, -14),
        Position = util:Offsets(167, 7),
        BackgroundColor3 = theme.SubFrameColor,
        Name = "TabContentContainer",
      })
    }))

    --// All keybinds
    local conn4 = input.InputBegan:Connect(keybindConnection)
    
    --// Draggability
    local isDragging = false
    local draggingOffset
   
    local conn1 = input.InputBegan:Connect(function(inp)
      if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        local m = input:GetMouseLocation() - guiInset
        local topLeft = MasterContainer.AbsolutePosition
        local bottomRight = topLeft + Vector2.new(MasterContainer.AbsoluteSize.X, 40)

        if m.X > topLeft.X and m.X < bottomRight.X then
          if m.Y > topLeft.Y and m.Y < bottomRight.Y then
            isDragging = true
            draggingOffset = m - topLeft
          end
        end
      end
    end)
    local conn2 = input.InputEnded:Connect(function(inp)
      if isDragging and inp.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
      end
    end)
    local conn3 = input.InputChanged:Connect(function(inp)
      if isDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        MasterContainer.Position = util:VectorToOffsets(input:GetMouseLocation() - draggingOffset - guiInset)
      end
    end)
    table.insert(getfenv()[id.."_conns"], conn1)
    table.insert(getfenv()[id.."_conns"], conn2)
    table.insert(getfenv()[id.."_conns"], conn3)
    table.insert(getfenv()[id.."_conns"], conn4)

    return setmetatable({
      MasterContainer = MasterContainer,
      MainContainer = MainContainer,
      TabsSelectContainer = TabSelectContainer,
      TabsContentContainer = TabContentContainer,
      tabs = {},
      values = {}, --UI.values.tab.section["a toggle"] = its current set value
      selectedTab = 1,
      keybind = Enum.KeyCode.RightControl,
      isVisible = true,
    }, library):_initKeybind(id) --botchy?
  end

  function library:AddTab(title, desc)
    local newTab = tab.new(self, title, desc, #self.tabs+1)
    newTab:_RegisterConnections()
    
    table.insert(self.tabs, newTab)

    if #self.tabs == 1 then
      newTab:SelectTab()
    end

    return newTab
  end

  function library:_initKeybind(id)
    --// GUI Keybind
    local stop = false
    table.insert(getfenv()[id.."_conns"], input.InputBegan:Connect(function(inp)
      if inp.UserInputType == Enum.UserInputType.Keyboard then
        if inp.KeyCode == self.keybind and not stop then
          stop = true
          self:ToggleGUI()
          wait(0.2)
          stop = false
        end
      end
    end))
    return self
  end

  function library:_HideGUI()
    self.MasterContainer:TweenSize(util:Offsets(510,0), "In", "Quad", 0.2, true)
  end
  
  function library:_ShowGUI()
    self.MasterContainer:TweenSize(util:Offsets(510, 430), "Out", "Quad", 0.2, true)
  end

  function library:ToggleGUI(yesno)
    self.isVisible = (yesno == nil) and (not self.isVisible) or yesno
    if self.isVisible then self:_ShowGUI() else self:_HideGUI() end
    return self.isVisible
  end

  function library:SetKeybind(new)
    self.keybind = new
    return self.keybind
  end
end

do --Tab class
  function tab.new(library, title, desc, tabNumber)
    local tabNumberM = tabNumber
    if tabNumber == 1 then tabNumberM = 2.5/53.7+1 end --Makes the first tab's borders match up with the rest

    local TabSelectorColor, TabSelectorContainer = unpack(util:CreateObject("RoundedFrame", {
      Parent = library.TabsSelectContainer,
      Size = UDim2.new(1, -7-5, 0, 53.7 - 6),
      Position = UDim2.new(0, 3.5, 0, (53.7 * (tabNumberM-1) ) + 3.5 ),
      Name = "TabSelectorColor",
    }, {
      util:CreateObject("RoundedButton", {
        Size = UDim2.new(1, 5, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.InnerFrameColor,
        Name = "TabSelectorContainer",
      }, {
        util:CreateObject("Frame", { --Grey tab button, overlays green/red selector
          Size = UDim2.new(1, 0, 1, 0),
          BackgroundColor3 = theme.InnerFrameColor,
        }),
        util:CreateObject("TextLabel", { --Tab title
          Size = UDim2.new(1, -7, 1, 0),
          Position = UDim2.new(0, 7, 0, 3.5),
          BackgroundTransparency = 1,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Top,
          TextColor3 = theme.MainTextColor,
          TextSize = 15,
          Font = Enum.Font.GothamBold,
          Text = title,
        }),
        util:CreateObject("TextLabel", { --Tab description
          Size = UDim2.new(1, -7, 1, 0),
          Position = UDim2.new(0, 7, 0, -6),
          BackgroundTransparency = 1,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Bottom,
          TextColor3 = theme.SubTextColor,
          TextSize = 12,
          Font = Enum.Font.GothamBold,
          Text = desc,
        })
      })
    }, true, true))

    local TabContentContainer = util:CreateObject("Frame", {
      Parent = library.TabsContentContainer,
      Size = UDim2.new(1,0,1,0),
      Name = title,
      BackgroundTransparency = 1,
      Visible = false
    }, {
      util:CreateObject("ScrollingFrame", {
        Size = UDim2.new(1, -14, 1, -54),
        Position = UDim2.new(0, 7, 0, 47),
        Name = "Padding",
        BackgroundTransparency = 1,
        ScrollBarImageColor3 = theme.InnerFrameColor,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 1, -54),
      }, {
        util:CreateObject("UIListLayout", {
          VerticalAlignment = Enum.VerticalAlignment.Top,
          Padding = UDim.new(0, 8), --symmetry states 7, but I perfer 8
          SortOrder = Enum.SortOrder.LayoutOrder,
        })
      })
    }, true)[1]

    local TabTitleText = util:CreateObject("RoundedFrame", { --Top bar
      Parent = TabContentContainer.Parent,
      Position = UDim2.new(0, 0, 0, 0),
      Size = UDim2.new(1, 0, 0, 35),
      BackgroundColor3 = theme.InnerFrameColor,
      Name = "TabContentTopBar"
    }, {
      util:CreateObject("Frame", { --Bottom black bar
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = theme.InnerFrameColor,
        Name = "TabContentTopBarBottom"
      }),
      util:CreateObject("TextLabel", { --Title text
        Size = UDim2.new(0, 0, 1, 0),
        Position = UDim2.new(0, 13, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = theme.MainTextColor,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        Text = title,
        Name = "Tab Title",
      }, {
        util:CreateObject("TextLabel", { --Description Text
          Size = UDim2.new(5, 0, 1, 0),
          Position = UDim2.new(1, 6, 0, 0),
          BackgroundTransparency = 1,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextColor3 = theme.SubTextColor,
          TextSize = 12,
          Font = Enum.Font.GothamBold,
          Text = desc,
          Name = "Tab Desc",
        })
      })
    }, true)[2]

    TabTitleText.Size = UDim2.new(0, TabTitleText.TextBounds.X, 1, 0)

    return setmetatable({
      library = library,
      title = title,
      isSelected = false,
      TabSelectorColor = TabSelectorColor,
      TabSelectorContainer = TabSelectorContainer,
      TabContentContainer = TabContentContainer,
      sections = {},
    }, tab)
  end

  function tab:AddSection(title)
    local newSection = section.new(self, title)
    table.insert(self.sections, newSection)
    return newSection
  end

  function tab:_deselectOthers()
    for i,v in pairs(self.library.tabs) do
      if v ~= self then
        v:DeselectTab()
      end
    end
  end

  function tab:_tweenSelect()
    util:Tween(self.TabSelectorContainer, {
      Position = UDim2.new(0, 7, 0, 0),
      Size = UDim2.new(1, -7+5, 1, 0),
    }, .1)
    util:Tween(self.TabSelectorColor, { BackgroundColor3 = theme.TabSelectedColor }, .2)
  end

  function tab:_tweenHover()
    if not self.isSelected then
      util:Tween(self.TabSelectorContainer, {
        Position = UDim2.new(0, 7, 0, 0),
        Size = UDim2.new(1, -7+5, 1, 0),
      }, .1)
      util:Tween(self.TabSelectorColor, { BackgroundColor3 = theme.TabHoverColor }, .2)
    end
  end
  
  function tab:_tweenUnselect()
    if not self.isSelected then
      util:Tween(self.TabSelectorContainer, {
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 5, 1, 0),
      }, .1)
      util:Tween(self.TabSelectorColor, { BackgroundColor3 = theme.TabHoverColor }, .2)
    end
  end

  function tab:_RegisterConnections()
    self.TabSelectorColor.MouseEnter:Connect(function() self:_tweenHover() end)
    self.TabSelectorColor.MouseLeave:Connect(function() self:_tweenUnselect() end)

    self.TabSelectorContainer.MouseButton1Down:Connect(function()
      self.isSelected = not self.isSelected

      if self.isSelected then
        self:_deselectOthers()
        self:_tweenSelect()
        self.TabContentContainer.Parent.Visible = true
      else
        self:_tweenHover()
        self.TabContentContainer.Parent.Visible = false
      end
    end)
  end

  function tab:SelectTab(library)
    self.isSelected = true
    self:_deselectOthers()
    self:_tweenSelect()
    self.TabContentContainer.Parent.Visible = true
  end

  function tab:DeselectTab(library)
    self.isSelected = false
    self:_tweenUnselect()
    self.TabContentContainer.Parent.Visible = false
  end
end

do --Section class
  --tab.library = library
  function section.new(tab, title)
    local SectionContainer = util:CreateObject("RoundedFrame", {
      Parent = tab.TabContentContainer,
      Position = UDim2.new(0, 0, 0, 0),
      Size = UDim2.new(1, 0, 0, 22),
      LayoutOrder = #tab.sections+1,
      BackgroundColor3 = theme.InnerFrameColor,
      Name = title
    })

    local UIListLayout = util:CreateChildren(SectionContainer, {
      util:CreateObject("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
      }),
      util:CreateObject("TextLabel", {
        Size = UDim2.new(1, -14, 0, 17),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        TextColor3 = theme.SubTextColor,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Text = title,
      }),
    })[1]
    SectionContainer.Size = UDim2.new(1, 0, 0, UIListLayout.AbsoluteContentSize.Y+7)


    return setmetatable({
      tab = tab,
      title = title,
      items = {},
      SectionContainer = SectionContainer,
      UIListLayout = UIListLayout,
    }, section)
  end

  function section:AddButton(data)
    return interactableBuilder.new(self):AddButton(data)
  end

  function section:AddOneTimeClickButton(data)
    return interactableBuilder.new(self):AddOneTimeClickButton(data)
  end
  
  function section:AddToggle(data)
    return interactableBuilder.new(self):AddToggle(data)
  end

  function section:AddDropdown(data)
    return interactableBuilder.new(self):AddDropdown(data)
  end

  function section:AddKeybind(data)
    return interactableBuilder.new(self):AddKeybind(data)
  end

  function section:AddSlider(data)
    local r = interactableBuilder.new(self):AddSlider(data)
    interactableBuilder.new(self):_blank(10)
    return r
  end

  function section:AddLabel(data)
    return interactableBuilder.new(self):AddLabel(data)
  end

  function section:_updateSize()
    self.SectionContainer.Size = UDim2.new(1, 0, 0, self.UIListLayout.AbsoluteContentSize.Y+7)
    self.SectionContainer.Parent.CanvasSize = UDim2.new(0, 0, 0, self.SectionContainer.Parent:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y)
  end
end

do --InteractableBuilder
  --section.tab.library
  function interactableBuilder.new(section)
    local InteractableBuilderContainer = util:CreateObject("Frame", {
      Parent = section.SectionContainer,
      Size = UDim2.new(1, 0, 0, 27),
      BackgroundTransparency = 1,
      Name = "InteractableBuilderContainer"
    })

    return setmetatable({
      section = section,
      interactables = {},
      interactable = nil,
      InteractableBuilderContainer = InteractableBuilderContainer,
    }, interactableBuilder)
  end

  function interactableBuilder:_updateSize()
    local diviser = 1/#self.InteractableBuilderContainer:GetChildren()

    for i,v in pairs(self.InteractableBuilderContainer:GetChildren()) do
      v.Size = UDim2.new(diviser, 0, 1, 0)
      v.Position = UDim2.new(diviser*(i-1), 0, 0, 0)
      i=i+1
    end
  end

  function interactableBuilder:AddButton(data)
    local button = interactable.new(self):button(data).returns
    table.insert(self.interactables, button)
    self.interactable = button
    return self
  end

  function interactableBuilder:AddOneTimeClickButton(data)
    local oneTimeClickButton = interactable.new(self):buttononetime(data).returns
    table.insert(self.interactables, oneTimeClickButton)
    self.interactable = oneTimeClickButton
    return self
  end

  function interactableBuilder:AddToggle(data)
    local toggle = interactable.new(self):toggle(data).returns
    table.insert(self.interactables, toggle)
    self.interactable = toggle
    return self
  end

  function interactableBuilder:AddDropdown(data)
    local dropdown = interactable.new(self):dropdown(data).returns
    table.insert(self.interactables, dropdown)
    self.interactable = dropdown
    return self
  end

  function interactableBuilder:AddKeybind(data)
    local keybind = interactable.new(self):keybind(data).returns
    table.insert(self.interactables, keybind)
    self.interactable = keybind
    return self
  end

  function interactableBuilder:AddSlider(data)
    local slider = interactable.new(self):slider(data).returns
    table.insert(self.interactables, slider)
    self.interactable = slider
    return self
  end

  function interactableBuilder:_blank(parentHeight)
    local blank = interactable.new(self):blank(parentHeight).returns
    table.insert(self.interactables, blank)
    self.interactable = blank
  end

  function interactableBuilder:AddLabel(data)
    local label = interactable.new(self):label(data).returns
    table.insert(self.interactables, label)
    self.interactable = label
    return self
  end
end

do --Interactable
  --InteractableBuilder.section.tab.library
  function interactable.new(InteractableBuilder)
    local InteractableContainer = util:CreateObject("ImageLabel", {
      Size = UDim2.new(0, 0, 1, 0),
      Parent = InteractableBuilder.InteractableBuilderContainer,
      BackgroundTransparency = 1,
      Name = "InteractableContainer"
    })

    return setmetatable({
      InteractableBuilder = InteractableBuilder,
      InteractableContainer = InteractableContainer,
      library = InteractableBuilder.section.tab.library,
      type = "",
    }, interactable)
  end

  function interactable:_GlobalTable()
    local values = self.library.values
    local tab = self.InteractableBuilder.section.tab.title
    local section = self.InteractableBuilder.section.title

    if not values[tab] then values[tab] = {} end
    if not values[tab][section] then values[tab][section] = {} end

    return values[tab][section]
  end

  function interactable:button(data)
    local text, callback = data.title or "", data.callback or EmptyFunction

    local button = util:CreateObject("RoundedButton", {
      Parent = self.InteractableContainer,
      Position = UDim2.new(0, 7, 0, 0),
      Size = UDim2.new(1, -14, 1, 0),
      BackgroundColor3 = theme.InteractiveBackColor,
    }, {
      util:CreateObject("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextColor3 = theme.SubTextColor,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Text = text,
      })
    })

    button.MouseButton1Click:Connect(function()
      button.ImageColor3 = theme.ButtonClickedColor
      callback()
      util:Tween(button, { ImageColor3 = theme.InteractiveBackColor }, .3)
    end)

    self.InteractableBuilder:_updateSize()
    self.InteractableBuilder.section:_updateSize()

    self.type = "button"
    self.returns = {
      interactable = self,
      text = text,
      callback = callback
    }
    return self
  end

  function interactable:buttononetime(data)
    local text, callback = data.title or "", data.callback or EmptyFunction

    local button = util:CreateObject("RoundedButton", {
      Parent = self.InteractableContainer,
      Position = UDim2.new(0, 7, 0, 0),
      Size = UDim2.new(1, -14, 1, 0),
      BackgroundColor3 = theme.InteractiveBackColor,
    }, {
      util:CreateObject("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextColor3 = theme.SubTextColor,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Text = text,
      })
    })

    local connection
    connection = button.MouseButton1Click:Connect(function()
      button.ImageColor3 = theme.ButtonClickedColor
      callback()
      util:Tween(button, { ImageColor3 = theme.ButtonUsedColor }, .3)
      connection:Disconnect()
    end)

    self.InteractableBuilder:_updateSize()
    self.InteractableBuilder.section:_updateSize()

    self.type = "buttononetime"
    self.returns = {
      interactable = self,
      text = text,
      callback = callback
    }
    return self
  end

  function interactable:toggle(data)
    local text, callback, c = data.title or "", data.callback or EmptyFunction, data.checked or false
    local GlobalTable = self:_GlobalTable()
    
    self.checked = c
    GlobalTable[text] = self.checked

    local checkbox = util:CreateObject("RoundedButton", {
      Parent = self.InteractableContainer,
      Position = UDim2.new(0, 7, 0, 0),
      Size = UDim2.new(1, -14, 1, 0),
      BackgroundColor3 = theme.InteractiveBackColor,
      Name = "Toggle",
    }, {
      util:CreateObject("RoundedFrame", {
        Size = UDim2.new(0, 27-12, 0, 27-12),
        Position = UDim2.new(0, 7, 0, 6),
        BorderSizePixel = 1,
        BackgroundColor3 = theme.InnerFrameColor,
        BorderColor3 = theme.ButtonClickedColor,
        BackgroundTransparency = 0,
        Name = "Checkbox",
      }, {
        util:CreateObject("TextLabel", {
          Size = UDim2.new(1, 0, 1, 0),
          BackgroundTransparency = 1,
          TextXAlignment = Enum.TextXAlignment.Center,
          TextYAlignment = Enum.TextYAlignment.Center,
          TextColor3 = theme.SubTextColor,
          TextSize = 10,
          Font = Enum.Font.GothamBold,
          Text = "X",
        })
      }),
      util:CreateObject("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextColor3 = theme.SubTextColor,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Text = text,
        Name = "Text",
      })
    })

    local CheckLabel = checkbox:GetChildren()[1]:GetChildren()[1]

    local function updateCheck()
      util:Tween(CheckLabel, { TextTransparency = self.checked and 0 or 1 }, .1)
    end
    updateCheck()
    
    local function toggle()
      self.checked = not self.checked
      GlobalTable[text] = self.checked
      updateCheck()
      callback(self.checked)
    end

    checkbox.MouseButton1Click:Connect(toggle)

    self.InteractableBuilder:_updateSize()
    self.InteractableBuilder.section:_updateSize()

    self.type = "toggle"
    self.returns = {
      toggle = toggle,
      setToggled = function(i)
        self.checked = i
        GlobalTable[text] = self.checked
        updateCheck()
        callback(self.checked)
      end,
      callback = callback,
    }
    return self
  end

  function interactable:dropdown(data)
    local callback = data.callback or EmptyFunction
    local GlobalTable = self:_GlobalTable()

    local ISPLAYERS = (data.options == "players")
    if ISPLAYERS then
      self.options = PlayerList
    else
      self.options = data.options or {}
    end
    self.optionObjects = {}

    local DropdownInput, DropdownMenuToggle = unpack(util:CreateObject("RoundedFrame", {
      Parent = self.InteractableContainer,
      Position = UDim2.new(0, 7, 0, 0),
      Size = UDim2.new(1, -14, 1, 0),
      BackgroundColor3 = theme.InteractiveBackColor,
      Name = "DropdownBox"
    }, {
      util:CreateObject("RoundedFrame", { --Input Box
        Size = UDim2.new(1, -22, 0, 27-12),
        Position = UDim2.new(0, 7, 0, 6),
        BorderSizePixel = 1,
        BackgroundColor3 = theme.InnerFrameColor,
        BorderColor3 = theme.ButtonClickedColor,
        BackgroundTransparency = 0,
        Name = "DropdownInput",
      }, {
        util:CreateObject("TextBox", {
          Size = UDim2.new(1,-10,1,0),
          Position = UDim2.new(0, 5, 0, 0),
          BackgroundTransparency = 1,
          TextColor3 = theme.MainTextColor,
          TextSize = 10,
          TextXAlignment = Enum.TextXAlignment.Left,
          Font = Enum.Font.GothamBold,
          PlaceholderText = data.placeholder or "",
          Text = "",
          PlaceholderColor3 = theme.SubTextColor,
          ClipsDescendants = true,
        })
      }),
      util:CreateObject("RoundedButton", { --Dropdown arrow symbol
        Size = UDim2.new(0, 27-12, 0, 27-12),
        Position = UDim2.new(1, -22, 0, 6),
        BorderSizePixel = 1,
        BackgroundColor3 = theme.InnerFrameColor,
        BorderColor3 = theme.ButtonClickedColor,
        BackgroundTransparency = 0,
        Name = "LowerSymbol",
        AutoButtonColor = false,
      }, {
        util:CreateObject("TextLabel", {
          Size = UDim2.new(1, 0, 1, 0),
          BackgroundTransparency = 1,
          TextXAlignment = Enum.TextXAlignment.Center,
          TextYAlignment = Enum.TextYAlignment.Center,
          TextColor3 = theme.SubTextColor,
          TextSize = 6,
          Font = Enum.Font.GothamBold,
          Text = "\\/",
        })
      })
    }, true)) --exclude parent
    local SectionColorExtension,UIListLayout,_,DropdownMenuContainer = unpack(util:CreateObject("RoundedFrame", {
      Parent = self.InteractableContainer,
      Size = UDim2.new(1,0,0,2000),
      Position = UDim2.new(0, 0, 1, 4),
      BackgroundColor3 = theme.InnerFrameColor,
      ZIndex = 10,
      Visible = self.dropdownVisible,
    }, {
      util:CreateObject("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
      }),
      util:CreateObject("Frame", { --Padding
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
      }),
      util:CreateObject("ScrollingFrame", { --Extension of inner section color --DropdownMenuContainer
        Size = UDim2.new(1, -14, 0, 220),
        BackgroundColor3 = theme.InteractiveBackColor,
        LayoutOrder = 2,
        ZIndex = 10,
        Name = "DropdownMenuContainer",
        ScrollBarImageColor3 = theme.InnerFrameColor,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(1, 0, 1, 0),
      }, {
        util:CreateObject("UIListLayout", { --Sorts all dropdown items
          VerticalAlignment = Enum.VerticalAlignment.Top,
          HorizontalAlignment = Enum.HorizontalAlignment.Center,
          SortOrder = Enum.SortOrder.LayoutOrder,
          Padding = UDim.new(0, 1)
        }),
        util:CreateObject("Frame", { --Padding
          Size = UDim2.new(1, 0, 0, 6),
          BackgroundTransparency = 1,
          LayoutOrder = 0,
        }),
      })
    }, true, true))
    local TemplateDropdownOption = util:CreateObject("RoundedButton", {
      Size = UDim2.new(1, -14, 0, 16),
      BorderSizePixel = 1,
      BackgroundColor3 = theme.InnerFrameColor,
      BorderColor3 = theme.ButtonClickedColor,
      BackgroundTransparency = 0,
      Name = "InputBox",
      ZIndex = 10,
      AutoButtonColor = false,
    }, {
      util:CreateObject("TextLabel", {
        Size = UDim2.new(1,-10,1,0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = theme.SubTextColor,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        Text = "",
        ClipsDescendants = true,
        ZIndex = 10,
      })
    })
    local DropdownInputBox = DropdownInput:FindFirstChildOfClass("TextBox")
    local DropdownMenuContainerUIListLayout = DropdownMenuContainer:FindFirstChildOfClass("UIListLayout")

    local function updateVisibility(newVisibility)
      self.dropdownVisible = newVisibility
      SectionColorExtension.Visible = self.dropdownVisible
      if newVisibility then
        --//Room to scroll
        --//MAKE THIS A HECK OF A LOT BETTER. IT *IS* POSSIBLE TO CALCULATE.
        --TODO
        self.InteractableBuilder.section.SectionContainer.Parent.CanvasSize = UDim2.new(0, 0, 5, 0)
      else
        self.InteractableBuilder.section:_updateSize()
      end
    end
    updateVisibility(false)

    local function optionClicked(clicked, text, setDefault)
      self.selectedOptionText = text
      self.selectedOptionObj = clicked

      GlobalTable[data.title] = clicked
      if not setDefault then callback(clicked) end

      DropdownInputBox.Text = text or ""
    end

    local function updateOptions(options, first) -- options = {"opt1", "opt2"} or {"text" = obj}
      if #options == 0 then updateVisibility(false) end

      --//Destroy current options
      for i,_ in pairs(self.optionObjects) do i:Destroy() end
      self.optionObjects = {}

      local count = 1
      for i, v in pairs(options) do
        local text, clicked = v, v
        if type(i) ~= "number" then
          text, clicked = i, v
        end

        --//default
        if first and (data.default == text or data.default == clicked or data.default == count) then
          optionClicked(clicked, text, true)
        end

        local OptionContainer = TemplateDropdownOption:Clone()
        OptionContainer.Parent = DropdownMenuContainer
        OptionContainer.LayoutOrder = count
        local OptionText = OptionContainer:FindFirstChildOfClass("TextLabel")
        OptionText.Text = text

        OptionContainer.MouseButton1Click:Connect(function()
          optionClicked(clicked, text, false)
          updateVisibility(false)
        end)

        self.optionObjects[OptionContainer] = text
        count=count+1
      end

      self.options = options
      DropdownMenuContainer.CanvasSize = UDim2.new(0, 0, 0, DropdownMenuContainerUIListLayout.AbsoluteContentSize.Y+7)
    end
    updateOptions(self.options, true)
    
    DropdownMenuToggle.MouseButton1Click:Connect(function()
      updateVisibility(not self.dropdownVisible)
      DropdownInputBox.Text = ""
    end)

    DropdownInputBox.Focused:Connect(function()
      DropdownInputBox.Text = ""
      updateVisibility(true)
    end)

    DropdownInputBox.FocusLost:Connect(function()
      wait(0.1)
      updateVisibility(false)
    end)

    DropdownInputBox:GetPropertyChangedSignal("Text"):Connect(function()
      local newText = DropdownInputBox.Text

      for option, text in pairs(self.optionObjects) do
        option.Visible = newText:lower() == text:lower():sub(1, #newText)
      end

      DropdownMenuContainer.Size = UDim2.new(1, -14, 0, DropdownMenuContainer:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y+7)
    end)

    self.InteractableBuilder:_updateSize()
    self.InteractableBuilder.section:_updateSize()

    self.type = "dropdown"
    self.returns = {
      options = options,
      setOptions = updateOptions,
      setMenuOpen = updateVisibility,
      callback = callback
    }
    if ISPLAYERS then
      table.insert(PlayerDropdowns, self.returns)
    end
    return self
  end

  function interactable:keybind(data)
    local text, defaultKeybind, callback, changeCallback = data.title or "", data.default, data.callback or EmptyFunction, data.changeCallback or EmptyFunction
    local GlobalTable = self:_GlobalTable()

    self.key = defaultKeybind
    GlobalTable[text] = self.key
    self.bindingsIndex = #keybindBindings+1

    local function SetBindings(newKey)
      keybindBindings[self.bindingsIndex] = newKey
      keybindFunctions[self.bindingsIndex] = callback
    end
    SetBindings(self.key)

    local _,KeybindBox = unpack(util:CreateObject("RoundedFrame", {
      Parent = self.InteractableContainer,
      Position = UDim2.new(0, 7, 0, 0),
      Size = UDim2.new(1, -14, 1, 0),
      BackgroundColor3 = theme.InteractiveBackColor,
      Name = "Keybind"
    }, {
      util:CreateObject("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextColor3 = theme.SubTextColor,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Text = text,
        Name = "Text",
      }),
      util:CreateObject("TextButton", {
        Size = UDim2.new(0, 27-12, 0, 27-12),
        Position = UDim2.new(1, -80, 0, 6),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextColor3 = theme.SubTextColor,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        Text = self.key.Name,
        ZIndex = 2,
        AutoButtonColor = false,
      }, {
        util:CreateObject("RoundedFrame", {
          Size = UDim2.new(1,0,1,0),
          BorderSizePixel = 1,
          BackgroundColor3 = theme.InnerFrameColor,
          BorderColor3 = theme.ButtonClickedColor,
          BackgroundTransparency = 0,
          Name = "Checkbox",
        })
      })
    }, true))

    local function SetKey(newKey)
      self.key = newKey
      GlobalTable[text] = self.key
      KeybindBox.Text = self.key.Name
      changeCallback(self.key)
      SetBindings(self.key)
    end
    
    local function ListenForNewKey()
      KeybindBox.Text = "Listening..."
      self.key = nil
      GlobalTable[text] = self.key
      SetBindings(self.key)

      local prevWS = util:GetLocalCharacter("Humanoid").WalkSpeed or 0
      util:GetLocalCharacter("Humanoid").WalkSpeed = 0 -- /shrug pretty lazzy but it works

      SetKey(util:ListenForKeypress().KeyCode)

      wait(0.1)
      util:GetLocalCharacter("Humanoid").WalkSpeed = prevWS
    end

    local function updateKeybindBoxSize()
      KeybindBox.Size = UDim2.new(0, KeybindBox.TextBounds.X+10, 0, 27-12)
      KeybindBox.Position = UDim2.new(1, -KeybindBox.Size.X.Offset-6, 0, 6)
    end
    updateKeybindBoxSize()
    KeybindBox:GetPropertyChangedSignal("Text"):Connect(updateKeybindBoxSize)
    KeybindBox.MouseButton1Click:Connect(ListenForNewKey)
    
    self.InteractableBuilder:_updateSize()
    self.InteractableBuilder.section:_updateSize()

    self.type = "keybind"
    self.returns = {
      key = self.key,
      SetKey = SetKey,
      ListenForNewKey = ListenForNewKey,
      callback = callback,
      changeKeyCallback = changeCallback
    }
    return self
  end

  function interactable:slider(data)
    local text, values, callback = data.title or "", data.values or {min=1,max=100,default=50}, data.callback or EmptyFunction
    local GlobalTable = self:_GlobalTable()

    local function round(x)
      return math.floor((x*(data.round or 100))+0.5)/(data.round or 100)
    end

    self.value = values.default
    GlobalTable[text] = self.value

    local SliderText, SliderContainer = unpack(util:CreateObject("RoundedFrame", {
      Parent = self.InteractableContainer,
      Position = UDim2.new(0, 7, 0, 0),
      Size = UDim2.new(1, -14, 1, 10+7), --relies on :_blank
      BackgroundColor3 = theme.InteractiveBackColor,
      Name = "Slider",
    }, {
      util:CreateObject("TextLabel", { --Slider text
        Position = UDim2.new(0, 7, 0, 0),
        Size = UDim2.new(1, -14, 0, 25),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextColor3 = theme.SubTextColor,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        Text = text,
      }),
      util:CreateObject("TextButton", {
        Size = UDim2.new(1, -8, 0, 25-12),
        Position = UDim2.new(0, 4, 0.5, 2),
        BackgroundTransparency = 1,
        Name = "SliderContainer"
      }, {
      })
    }, true))

    local SliderValueBox = util:CreateChildren(SliderText, {
      util:CreateObject("TextLabel", { --Value box
        Size = UDim2.new(0, 27-12, 0, 27-12),
        Position = UDim2.new(1, -15, 0, 6),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextColor3 = theme.SubTextColor,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        Text = round(self.value),
        ZIndex = 2,
      }, {
        util:CreateObject("RoundedFrame", {
          Size = UDim2.new(1,0,1,0),
          BorderSizePixel = 1,
          BackgroundColor3 = theme.InnerFrameColor,
          BorderColor3 = theme.ButtonClickedColor,
          BackgroundTransparency = 0,
        })
      })
    })[1]

    local SliderBar = util:CreateChildren(SliderContainer, {
      util:CreateObject("Frame", {
        BorderSizePixel = 0,
        Size = UDim2.new(1, -15, 0, 2),
        Position = UDim2.new(0, 7, 0.5, -1),
        BackgroundColor3 = theme.SliderBar,
        Name = "SliderBar"
      }, {
        util:CreateObject("Frame", {
          BorderSizePixel = 0,
          Size = UDim2.new(0, 2, 0, 6),
          Position = UDim2.new(0, 0, 0.5, -3),
          BackgroundColor3 = theme.SliderBar,
          Name = "LeftEnd",
        }),
        util:CreateObject("Frame", {
          BorderSizePixel = 0,
          Size = UDim2.new(0, 2, 0, 6),
          Position = UDim2.new(1, -2, 0.5, -3),
          BackgroundColor3 = theme.SliderBar,
          Name = "RightEnd",
        }),
      })
    })[1]

    local SliderSelector = util:CreateObject("RoundedFrame", {
      Parent = SliderBar,
      BorderSizePixel = 0,
      Size = UDim2.new(0, 10, 0, 10),
      Position = UDim2.new((self.value-values.min)/(values.max-values.min), -5, 0.5, -5),
      ZIndex = 5,
      BackgroundColor3 = theme.SliderBarValue,
      Name = "SliderSelector"
    })

    local isHoldingSlider = false
    local function updateSlider(mousePosX)
      SliderSelector.Position = UDim2.new(math.clamp(math.clamp(mousePosX - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1), -5, 0.5, -5)
    end
    local function endInput()
      isHoldingSlider = false
      
      self.value = values.min + (SliderSelector.Position.X.Scale * (values.max - values.min))
      GlobalTable[text] = self.value
      SliderValueBox.Text = round(self.value)

      callback(self.value)
    end

    SliderContainer.MouseButton1Down:Connect(function(x) updateSlider(x) isHoldingSlider = true end)
    input.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 and isHoldingSlider then endInput() end end)
    input.InputChanged:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseMovement and isHoldingSlider then updateSlider(inp.Position.X) end end)

    self.InteractableBuilder:_updateSize()
    self.InteractableBuilder.section:_updateSize()

    self.type = "slider"
    self.returns = {
      value = function() return self.value end,
      SetValue = function(newValue)
        SliderSelector.Position = UDim2.new(0, math.clamp((newValue-values.min)/(values.max-values.min), 0, 1) * SliderBar.AbsoluteSize.X, 0.5, -5)
        endInput()
      end,
      callback = callback
    }
    return self
  end

  function interactable:label(data)
    local text = data.title or ""
    local XAlignment = data.XAlignment or Enum.TextXAlignment.Center

    local textLabel = util:CreateObject("TextLabel", {
      Parent = self.InteractableContainer,
      Position = UDim2.new(0, 7, 0, 0),
      Size = UDim2.new(1, -14, 1, 0),
      BackgroundTransparency = 1,
      TextXAlignment = XAlignment,
      TextYAlignment = Enum.TextYAlignment.Center,
      TextColor3 = theme.SubTextColor,
      TextSize = 12,
      Font = Enum.Font.GothamBold,
      Text = text,
    })

    self.InteractableBuilder:_updateSize()
    self.InteractableBuilder.section:_updateSize()

    self.type = "label"
    self.returns = {
      interactable = self,
      text = text,
      UpdateText = function(newText)
        textLabel.Text = newText
      end
    }
    return self
  end

  function interactable:blank(parentHeight)
    self.InteractableBuilder.InteractableBuilderContainer.Size = UDim2.new(1, 0, 0, parentHeight)

    self.InteractableBuilder:_updateSize()
    self.InteractableBuilder.section:_updateSize()

    self.type = "blank"
    return self
  end
end

return library