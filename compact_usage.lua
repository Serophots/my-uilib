local UI = loadstring(game:HttpGet("http://127.0.0.1:5555/uilib_compact.lua"))()
UI = UI.init("Showcase", "v1.0.0", "Your Name Here", "SHOWCASE")

local TabAim = UI:AddTab("Aim", "Silent Aim") do
    local SectionSilentAim = TabAim:AddSection("Silent Aim") do
		SectionSilentAim:AddButton({
			title = "button",
		})
    end
end