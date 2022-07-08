local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Serophots/my-uilib/main/uilib_compact.lua"))()
UI = UI.init("Showcase", "v1.0.0", "SHOWCASE")

local AimOne, AimTwo = UI:AddTab("Aim", "Silent Aim") do
	local Section = AimOne:AddSeperator("Silent Aim") do
		Section:AddToggle({
			title = "Enabled"
		})
		Section:AddToggle({
			title = "Display field of view",
			checked = true
		})
		Section:AddSlider({
			title = "Field of view",
			values = {min=0,max=250,default=50}
		})
		Section:AddToggle({
		    title = "Display dead field of view"
		})
		Section:AddSlider({
		    title = "Dead field of view"
		})
		Section:AddSelection({
			title = "Bodyparts",
			options = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Arm" }
		})
	end
	local Section = AimOne:AddSeperator("Tuning") do
	    Section:AddToggle({
	        title = "Do tuning"
	    })
	end
end
local TabTwo = UI:AddTab("Second tab", "some other things")