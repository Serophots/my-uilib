--V1.0.0 by Serophots

local input = game:GetService("UserInputService")
local mouse = game.Players.LocalPlayer:GetMouse()
local guiInset = game:GetService("GuiService"):GetGuiInset()

local function EmptyFunction() end

--Utilities
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

--Classes
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
  BackColor = Color3.fromRGB(24, 24, 24),
  SubFrameColor = Color3.fromRGB(29, 29, 29),
  InnerFrameColor = Color3.fromRGB(35, 35, 35),
  InteractiveBackColor = Color3.fromRGB(41, 41, 41),

  ButtonClickedColor = Color3.fromRGB(52, 52, 52),
  ButtonUsedColor = Color3.fromRGB(29, 29, 29),

  TabHoverColor = Color3.fromRGB(235, 64, 52),
  TabSelectedColor = Color3.fromRGB(64, 235, 52),

  MainTextColor = Color3.fromRGB(255,255,255),
  SubTextColor = Color3.fromRGB(200,200,200),
  
  SliderBar = Color3.fromRGB(200,200,200),
  SliderBarValue = Color3.fromRGB(255, 255, 255),
}

do --Library class
  function library.init(title, version, owner, id)
    local MasterContainer = util:CreateObject("ScreenGui", { Parent = game:GetService("CoreGui") }, {
      util:CreateObject("RoundedFrame", {
        Size = util:Offsets(510, 430),
        Position = util:Centered(510, 430), --UDim2.new(0.5, -(510/2), 0.5, -(430/2)),
        BackgroundColor3 = theme.BackColor,
        Name = "ScreenGui"
      })
    }, true)[1]

    if getgenv()[id] then getgenv()[id]:Destroy() end
    getgenv()[id] = MasterContainer.Parent

    --Frame structure
    local TopBarContainer, ContentContainer = unpack(util:CreateChildren(MasterContainer, {
      util:CreateObject("Frame", { --TopBarContainer
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = theme.SubFrameColor,
        Name = "TopBarContainer",
      }, { --TopBarContianer children
        util:CreateObject("TextLabel", {
          Size = UDim2.new(1, -12, 1, 0),
          Position = UDim2.new(0, 12, -0.05, 0),
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
          Position = UDim2.new(0, 12, 0.7, 1),
          BackgroundTransparency = 1,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextColor3 = theme.SubTextColor,
          TextSize = 13,
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

    
    --Draggability
    local isDragging = false
    local draggingOffset
   
    input.InputBegan:Connect(function(inp)
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
    input.InputEnded:Connect(function(inp)
      if isDragging and inp.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
      end
    end)
    input.InputChanged:Connect(function(inp)
      if isDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        MasterContainer.Position = util:VectorToOffsets(input:GetMouseLocation() - draggingOffset - guiInset)
      end
    end)

    return setmetatable({
      MainContainer = MainContainer,
      TabsSelectContainer = TabSelectContainer,
      TabsContentContainer = TabContentContainer,
      tabs = {},
      values = {}, --UI.values.tab.section["a toggle"] = its current set value
      selectedTab = 1,
    }, library)
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
    -- return interactableBuilder.new(self):AddButton(text, callback)
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
    table.insert(self.interactables, interactable.new(self):button(data).returns)
    return self
  end

  function interactableBuilder:AddOneTimeClickButton(data)
    table.insert(self.interactables, interactable.new(self):buttononetime(data).returns)
    return self
  end

  function interactableBuilder:AddToggle(data)
    table.insert(self.interactables, interactable.new(self):toggle(data).returns)
    return self
  end

  function interactableBuilder:AddDropdown(data)
    table.insert(self.interactables, interactable.new(self):dropdown(data).returns)
    return self
  end

  function interactableBuilder:AddKeybind(data)
    table.insert(self.interactables, interactable.new(self):keybind(data).returns)
    return self
  end

  function interactableBuilder:AddSlider(data)
    table.insert(self.interactables, interactable.new(self):slider(data).returns)
    return self
  end

  function interactableBuilder:_blank(parentHeight)
    table.insert(self.interactables, interactable.new(self):blank(parentHeight).returns)
  end

  function interactableBuilder:AddLabel(data)
    table.insert(self.interactables, interactable.new(self):label(data).returns)
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
      callback(self.checked)
      updateCheck()
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
      end,
    }
    return self
  end

  function interactable:dropdown(data)
    local text, placeholder, options, callback, preselected = data.title or "", data.placeholder or "", data.options or {}, data.callback or EmptyFunction, data.default
    local GlobalTable = self:_GlobalTable()

    self.options = options
    self.optionObjects = {}
    self.dropdownVisible = false
    self.selectedOption = preselected or 0 --Index of options table
    GlobalTable[text] = self.options[self.selectedOption]

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
          PlaceholderText = placeholder,
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
    local DropdownInputBox = DropdownInput:FindFirstChildOfClass("TextBox")

    local SectionColorExtension,UIListLayout,_,DropdownMenuContainer = unpack(util:CreateObject("RoundedFrame", { --Extension of Section color
      Parent = self.InteractableContainer,
      Position = UDim2.new(0, 0, 1, 4),
      Size = UDim2.new(1,0,500,0),
      BackgroundColor3 = theme.InnerFrameColor,
      ZIndex = 10,
      Visible = self.dropdownVisible,
      Name = "SectionColorExtension"
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
      util:CreateObject("RoundedFrame", { --Extension of inner section color --DropdownMenuContainer
        Size = UDim2.new(1, -14, 0, 0),
        BackgroundColor3 = theme.InteractiveBackColor,
        LayoutOrder = 2,
        ZIndex = 10,
        Name = "DropdownMenuContainer"
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

    local function updateVisibility(newVisibility)
      self.dropdownVisible = newVisibility
      SectionColorExtension.Visible = self.dropdownVisible
    end

    local function optionClicked(i, clicked)
      self.selectedOption = i
      GlobalTable[text] = self.options[self.selectedOption]
      callback(clicked, i)
      updateVisibility(false)

      DropdownInputBox:ReleaseFocus()
      DropdownInputBox.Text = clicked
    end

    local function updateOptions(optionss)
      if #optionss == 0 then updateVisibility(false) end

      for i,v in pairs(self.optionObjects) do v:Destroy() end
      self.optionObjects = {}

      for i, option in pairs(optionss) do
        local OptionContainer = TemplateDropdownOption:Clone()
        OptionContainer.Parent = DropdownMenuContainer
        OptionContainer.LayoutOrder = i

        local OptionText = OptionContainer:FindFirstChildOfClass("TextLabel")
        OptionText.Text = option

        OptionContainer.MouseButton1Click:Connect(function() optionClicked(i, option) end)

        table.insert(self.optionObjects, OptionContainer)
      end

      self.options = optionss
      DropdownMenuContainer.Size = UDim2.new(1, -14, 0, DropdownMenuContainer:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y+7)
    end
    updateOptions(options)
    
    DropdownMenuToggle.MouseButton1Click:Connect(function()
      updateVisibility(not self.dropdownVisible)
      DropdownInputBox.Text = ""
    end)

    DropdownInputBox.Focused:Connect(function()
      if DropdownInputBox.Text == self.options[self.selectedOption] then
        DropdownInputBox.Text = ""
        self.selectedOption = 0
        GlobalTable[text] = self.options[self.selectedOption]
        callback("", 0)
      end

      updateVisibility(true)
    end)

    DropdownInputBox.FocusLost:Connect(function()
      wait(0.1)
      if DropdownInputBox.Text ~= self.options[self.selectedOption] then
        self.selectedOption = 0
        GlobalTable[text] = self.options[self.selectedOption]
        callback("", 0)
      end

      updateVisibility(false)
    end)

    DropdownInputBox:GetPropertyChangedSignal("Text"):Connect(function()
      local newText = DropdownInputBox.Text

      for i, option in pairs(self.optionObjects) do
        option.Visible = newText:lower() == self.options[i]:lower():sub(1, #newText)
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
    }
    return self
  end

  function interactable:keybind(data)
    local text, defaultKeybind, callback = data.title or "", data.default, data.callback or EmptyFunction
    local GlobalTable = self:_GlobalTable()

    self.key = defaultKeybind
    GlobalTable[text] = self.key

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

    local function updateKeybindBoxSize()
      KeybindBox.Size = UDim2.new(0, KeybindBox.TextBounds.X+10, 0, 27-12)
      KeybindBox.Position = UDim2.new(1, -KeybindBox.Size.X.Offset-6, 0, 6)
    end
    updateKeybindBoxSize()
    KeybindBox:GetPropertyChangedSignal("Text"):Connect(updateKeybindBoxSize)

    local function ListenForNewKey()
      KeybindBox.Text = "Listening..."
      self.key = nil
      GlobalTable[text] = self.key
      callback(self.key)

      local prevWS = util:GetLocalCharacter("Humanoid").WalkSpeed or 0
      util:GetLocalCharacter("Humanoid").WalkSpeed = 0 -- /shrug pretty lazzy but it works

      self.key = util:ListenForKeypress().KeyCode
      GlobalTable[text] = self.key
      KeybindBox.Text = self.key.Name
      callback(self.key)

      wait(0.1)
      util:GetLocalCharacter("Humanoid").WalkSpeed = prevWS
    end

    local function SetKey(newKey)
      self.key = newKey
      GlobalTable[text] = self.key
      KeybindBox.Text = self.key.Name
      callback(self.key)
    end

    KeybindBox.MouseButton1Click:Connect(ListenForNewKey)
    
    self.InteractableBuilder:_updateSize()
    self.InteractableBuilder.section:_updateSize()

    self.type = "keybind"
    self.returns = {
      key = self.key,
      SetKey = SetKey,
      ListenForNewKey = ListenForNewKey,
    }
    return self
  end

  function interactable:slider(data)
    local text, values, callback = data.title or "", data.values or {min=1,max=100,default=50}, data.callback or EmptyFunction
    local GlobalTable = self:_GlobalTable()

    local function round(x)
      return math.floor((x*data.round or 100)+0.5)/data.round or 100
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
      end
    }
    return self
  end

  function interactable:label(data)
    local text = data.title or ""

    local textLabel = util:CreateObject("TextLabel", {
      Parent = self.InteractableContainer,
      Position = UDim2.new(0, 7, 0, 0),
      Size = UDim2.new(1, -14, 1, 0),
      BackgroundTransparency = 1,
      TextXAlignment = Enum.TextXAlignment.Center,
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
      UpdateText = function(text) textLabel.Text = text end
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