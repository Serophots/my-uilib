local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Serophots/my-uilib/main/uilib_main.lua"))()
--V1.0.0 by Serophots
UI = UI.init("Showcase", "v1.0.0", "Serophots", "SHOWCASE")

local TabAim = UI:AddTab("Aim", "Silent Aim") do
  local SectionSilentAim = TabAim:AddSection("Silent Aim") do
		SectionSilentAim:AddButton({
			title = "button",
			callback = function() print("First button clicked") end,
		})
		SectionSilentAim:AddOneTimeClickButton({
			title = "onebutton",
			callback = function() print("One time click button clicked") end,
		})

		SectionSilentAim:AddLabel({
			title = "Random label",
		})

		SectionSilentAim:AddToggle({
			title = "toggle",
			callback = function(v) print("Toggle callback", v) end,
			checked = true,
		})
		SectionSilentAim:AddDropdown({
			title = "dropdown",
			placeholder = "Placeholder text",
			options = {"one", "two", "three"},
			callback = function(...) print("Dropdown callback", ...) end,
			default = 1
		})
		SectionSilentAim:AddDropdown({
			title = "dropdown",
			placeholder = "Placeholder text",
			options = {["text to show"]:"value to be callbacked", "two", "three"},
			callback = function(...) print("Dropdown callback", ...) end,
		})
		SectionSilentAim:AddDropdown({
			title = "dropdown",
			placeholder = "Placeholder text",
			options = "players", --built in players dropdpown, auto-updates, includes displaynames, etc
			callback = function(...) print("Dropdown callback", ...) end,
		})
		SectionSilentAim:AddSlider({
			title = "slider",
			values = {min = 500, max = 1000, default = 750},
			callback = function(v) print("Slider callback", v) end,
			round = 1000, -- 3 decimal places
		})
		SectionSilentAim:AddKeybind({
			title = "keybind",
			default = Enum.KeyCode.Nine,
			callback = function() print("Keybind clicked") end,
			changeCallback = function(new) print("Keybind changed", new.Name) end,
		})

		
		SectionSilentAim:AddKeybind({ --// GUI keybind change
			title = "GUI keybind",
			default = Enum.KeyCode.LeftControl,
			changeCallback = function(new)
				UI:SetKeybind(new)
				print(UI.keybind)
			end,
		})


		SectionSilentAim:AddButton({
			title = "See toggle",
			callback = function()
				print(UI.values["Aim"]["Silent Aim"].toggle) --UI.values.SectionName.Sub-SectionName."title" of interactable
			end
		})
		SectionSilentAim:AddButton({
			title = "See dropdown",
			callback = function()
				print(UI.values["Aim"]["Silent Aim"].dropdown) --UI.values.SectionName.Sub-SectionName."title" of interactable
			end
		})
		SectionSilentAim:AddButton({
			title = "See slider",
			callback = function()
				print(UI.values["Aim"]["Silent Aim"].slider) --UI.values.SectionName.Sub-SectionName."title" of interactable
			end
		})
		SectionSilentAim:AddButton({
			title = "See keybind",
			callback = function()
				print(UI.values["Aim"]["Silent Aim"].keybind) --UI.values.SectionName.Sub-SectionName."title" of interactable
			end
		})
  end
end

--other cool things


--[[

Some functions

UI:ToggleGUI(true/false) to set visible/invisible
or
UI:ToggleGUI() to simply toggle

UI:SetKeybind(Enum.KeyCode.Something) to set the keybind
and
print(UI.keybind) to get current GUI keybind

]]




--your script
print(UI.values["Aim"]["Silent Aim"].slider)