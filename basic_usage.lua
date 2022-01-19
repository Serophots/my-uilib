wait(0.1)

local request = syn and syn.request or request
local uiResponse = request({Url = "https://raw.githubusercontent.com/Serophots/my-uilib/main/uilib_main.lua", Method = "GET"}).Body


local uiS, UI = pcall(loadstring(uiResponse))
if uiS then UI = UI.init("Example UI", "v1.0.0", "Serophots", "1") else error(UI) end

-- UI.init(title, version, author/creator, unique menu ID)    Creating another menu (through UI.init) will automatically destroy and replace any previous UI with the same ID

function callback() end

--Figure this out by looking at it

local tab1 = UI:AddTab("Tab 1", "Automate things") do
    local FirstSection = tab1:AddSection("First Section") do
        FirstSection:AddToggle("Test Toggle", callback, true):AddLabel("Stuck"):AddToggle("A new toggle", callback, false)
    end
    
    local SecondSection = tab1:AddSection("Second Section") do
        SecondSection:AddDropdown("A dropdown", "Placeholder Text", {"First option", "Second option"}, dropdownCallback):AddLabel("Hey")
        SecondSection:AddLabel("Status")
        SecondSection:AddKeybind("Keybind Test", Enum.KeyCode.F, callback)
    end
    
    local newSection = tab1:AddSection("Filling space") do
        newSection:AddOneTimeClickButton("A button! How cute", callback)
        newSection:AddButton("A button! How cute", callback)
        newSection:AddButton("A button! How cute", callback)
        newSection:AddButton("A button! How cute", callback)
        newSection:AddButton("A button! How cute", callback)
    end
end
local tab2 = UI:AddTab("Tab 2")
local tab3 = UI:AddTab("Tab 3")
local tab3 = UI:AddTab("Tab 4")
local tab3 = UI:AddTab("Tab 5")
local tab3 = UI:AddTab("Tab 6")
local tab3 = UI:AddTab("Tab 7")