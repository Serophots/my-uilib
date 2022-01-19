wait(0.1)

local request = syn and syn.request or request
local uiResponse = request({Url = "https://raw.githubusercontent.com/Serophots/my-uilib/main/uilib_main.lua", Method = "GET"}).Body


local uiS, UI = pcall(loadstring(uiResponse))
if uiS then UI = UI.init("Example UI", "v1.0.0", "Serophots", "1") else error(UI) end

-- UI.init(title, version, author/creator, unique menu ID)    Creating another menu (through UI.init) will automatically destroy and replace any previous UI with the same ID


-- Interactable = A class which could be a button, toggle or any other element the user directly interacts wth
-- InteractableBuilder = A class which allows multiple interactables to be put together onto the same "line" in the menu.


-- Callbacks to various interactions
function buttonCallback()
	print("Button clicked!")
end
function toggleCallback(toggled)
	print("Toggled", toggled)
end
function dropdownCallback(selected)
	print("New selection", selected)
	statusLabel.UpdateText("Current selected option : "..selected) --Update the status label's text after a new dropdown is selected
end
function keybindCallback(newKey)
	if newKey == nil then
		print("Key unbound")
	else
		print("New key", newKey.Name)
	end
end

local tab1 = UI:AddTab("Tab 1", "Automate things") do
	local FirstSection = tab1:AddSection("First Section") do
		local one, two, three, four = unpack(FirstSection:AddButton("Click here", buttonCallback):AddButton("Click here", buttonCallback):AddButton("Click here", buttonCallback):AddLabel("Test").interactables)

		--:AddButton (or any similar function which creates an "interactable") will return the interactable builder, allowing for more interactables to be added. Once we are done with our :AddButton() chain, we must get the `.interactables` property in order to retreive a table of each interactable we created. Unpack simply unpacks that table into several variables for each interactable we created



		FirstSection:AddToggle("Test Toggle", toggleCallback, true):AddLabel("Stuck"):AddToggle("A new toggle", toggleCallback, false)
		--We dont have to use the .interactables property if we're not assigning to a variable. 
	end
	
	local SecondSection = tab1:AddSection("Second Section") do
		local one = unpack(SecondSection:AddDropdown("A dropdown", "Placeholder Text", {"First option", "Second option"}, dropdownCallback):AddLabel("Hey").interactables)
		statusLabel = unpack(SecondSection:AddLabel("Status").interactables)
		SecondSection:AddKeybind("Keybind Test", Enum.KeyCode.F, keybindCallback)
	end
	
	local newSection = tab1:AddSection("Filling space") do
		newSection:AddOneTimeClickButton("A button! How cute", buttonCallback)
		newSection:AddButton("A button! How cute", buttonCallback)
		newSection:AddButton("A button! How cute", buttonCallback)
		newSection:AddButton("A button! How cute", buttonCallback)
		newSection:AddButton("A button! How cute", buttonCallback)
	end
	
	local newSection = tab1:AddSection("Filling space") do
		newSection:AddButton("A button! How cute", buttonCallback)
		newSection:AddButton("A button! How cute", buttonCallback)
		newSection:AddButton("A button! How cute", buttonCallback)
		newSection:AddButton("A button! How cute", buttonCallback)
		newSection:AddButton("A button! How cute", buttonCallback)
	end
end