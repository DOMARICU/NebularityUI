--[[
Nebularity UI Library
Copyright (c) 2026 Nebularity Team. Alle Rechte vorbehalten.

Nutzungs-Hinweis:
- Dieses Script darf nicht als eigenes Werk ausgegeben werden.
- Copyright-Vermerk nicht entfernen oder aendern.
- Veraenderungen nur mit ausdruecklicher Erlaubnis der Rechteinhaber.

Kurze Info:
- Datei: uinew.lua
- Zweck: UI Framework (Tabs, Sections, Controls, Theme, Config)
]]

local NebularityUI = {}



local function loadService(name)
	local service = game:GetService(name)
	return if cloneref then cloneref(service) else service
end

local TweenService = loadService("TweenService")
local UserInputService = loadService("UserInputService")
local Workspace = loadService("Workspace")
local SoundService = loadService("SoundService")

local function GenerateString()
	return "" --SOON
end

local function NewInstance(className, parent)
	return function(props)
		local inst = Instance.new(className)
		for k, v in pairs(props or {}) do
			if k == "Children" and type(v) == "table" then
				for _, child in ipairs(v) do
					child.Parent = inst
				end
			elseif type(k) == "string" then
				inst[k] = v
			end
		end
		if parent then
			inst.Parent = parent
		end
		return inst
	end
end

local Themes = {
	Nebula = {
		PanelGradient = {
			Color3.fromRGB(10, 12, 18),
			Color3.fromRGB(22, 25, 35),
		},
		PanelStroke = Color3.fromRGB(95, 110, 255),
		PanelStrokeTransparency = 0.72,

		TopGlow = Color3.fromRGB(130, 145, 255),
		TopGlowTransparency = 0.88,

		BottomBar = Color3.fromRGB(20, 22, 30),
		BottomBarGradient = {
			Color3.fromRGB(24, 26, 35),
			Color3.fromRGB(18, 20, 28),
		},
		BottomBarStroke = Color3.fromRGB(110, 125, 255),
		BottomBarStrokeTransparency = 0.84,

		Accent = Color3.fromRGB(125, 140, 255),
		AccentSoft = Color3.fromRGB(85, 100, 220),

		Text = Color3.fromRGB(245, 247, 255),
		SubText = Color3.fromRGB(170, 176, 196),

		AvatarStroke = Color3.fromRGB(125, 140, 255),
		AvatarStrokeTransparency = 0.6,
	},

	Crimson = {
		PanelGradient = {
			Color3.fromRGB(18, 10, 12),
			Color3.fromRGB(34, 18, 22),
		},
		PanelStroke = Color3.fromRGB(255, 92, 117),
		PanelStrokeTransparency = 0.74,

		TopGlow = Color3.fromRGB(255, 120, 145),
		TopGlowTransparency = 0.9,

		BottomBar = Color3.fromRGB(29, 17, 21),
		BottomBarGradient = {
			Color3.fromRGB(34, 20, 25),
			Color3.fromRGB(24, 14, 18),
		},
		BottomBarStroke = Color3.fromRGB(255, 92, 117),
		BottomBarStrokeTransparency = 0.84,

		Accent = Color3.fromRGB(255, 92, 117),
		AccentSoft = Color3.fromRGB(190, 60, 88),

		Text = Color3.fromRGB(255, 244, 247),
		SubText = Color3.fromRGB(210, 170, 180),

		AvatarStroke = Color3.fromRGB(255, 92, 117),
		AvatarStrokeTransparency = 0.62,
	},

	Emerald = {
		PanelGradient = {
			Color3.fromRGB(8, 16, 14),
			Color3.fromRGB(14, 28, 24),
		},
		PanelStroke = Color3.fromRGB(66, 255, 185),
		PanelStrokeTransparency = 0.78,

		TopGlow = Color3.fromRGB(90, 255, 196),
		TopGlowTransparency = 0.9,

		BottomBar = Color3.fromRGB(14, 24, 22),
		BottomBarGradient = {
			Color3.fromRGB(18, 31, 28),
			Color3.fromRGB(12, 21, 19),
		},
		BottomBarStroke = Color3.fromRGB(66, 255, 185),
		BottomBarStrokeTransparency = 0.86,

		Accent = Color3.fromRGB(66, 255, 185),
		AccentSoft = Color3.fromRGB(42, 186, 134),

		Text = Color3.fromRGB(240, 255, 250),
		SubText = Color3.fromRGB(165, 201, 190),

		AvatarStroke = Color3.fromRGB(66, 255, 185),
		AvatarStrokeTransparency = 0.64,
	},
}

local function GetTheme(themeName)
	if typeof(themeName) ~= "string" then
		return Themes.Nebula, "Nebula"
	end

	for name, theme in pairs(Themes) do
		if string.lower(name) == string.lower(themeName) then
			return theme, name
		end
	end

	return Themes.Nebula, "Nebula"
end

local function shiftTransparency(value, delta)
	return math.clamp(value + delta, 0, 1)
end

local function SetIconColor(icon, color)
	if not icon then
		return
	end

	if icon:IsA("TextLabel") then
		icon.TextColor3 = color
		return
	end

	for _, descendant in ipairs(icon:GetDescendants()) do
		if descendant:IsA("Frame") then
			descendant.BackgroundColor3 = color
		end
	end
end

local function MakeGhostHover(button, stroke, icon, baseBg, hoverBg, baseStrokeTransparency, hoverStrokeTransparency, baseIconColor, hoverIconColor)
	button.BackgroundColor3 = baseBg
	stroke.Transparency = baseStrokeTransparency
	SetIconColor(icon, baseIconColor)

	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = hoverBg
		stroke.Transparency = hoverStrokeTransparency
		SetIconColor(icon, hoverIconColor)
	end)

	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = baseBg
		stroke.Transparency = baseStrokeTransparency
		SetIconColor(icon, baseIconColor)
	end)
end

local function Tween(object, goals, duration, style, direction)
	return TweenService:Create(
		object,
		TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
		goals
	)
end

local function CollectTransparencyTargets(root)
	local targets = {}
	local nodes = {root}
	for _, descendant in ipairs(root:GetDescendants()) do
		table.insert(nodes, descendant)
	end

	for _, node in ipairs(nodes) do
		if node:IsA("GuiObject") then
			if node.BackgroundTransparency ~= nil then
				table.insert(targets, {Object = node, Property = "BackgroundTransparency", Base = node.BackgroundTransparency})
			end
			if node:IsA("TextLabel") or node:IsA("TextButton") or node:IsA("TextBox") then
				table.insert(targets, {Object = node, Property = "TextTransparency", Base = node.TextTransparency})
			end
			if node:IsA("ImageLabel") or node:IsA("ImageButton") then
				table.insert(targets, {Object = node, Property = "ImageTransparency", Base = node.ImageTransparency})
			end
		end

		if node:IsA("UIStroke") then
			table.insert(targets, {Object = node, Property = "Transparency", Base = node.Transparency})
		end
	end

	return targets
end

local function ApplyTransparency(targets, alpha)
	for _, target in ipairs(targets) do
		target.Object[target.Property] = math.clamp(target.Base + alpha, 0, 1)
	end
end

local function TweenTransparency(targets, alpha, duration)
	for _, target in ipairs(targets) do
		Tween(target.Object, {
			[target.Property] = math.clamp(target.Base + alpha, 0, 1),
		}, duration):Play()
	end
end

local function AppendTargets(targets, additionalTargets)
	for _, target in ipairs(additionalTargets) do
		table.insert(targets, target)
	end

	return targets
end

local function SetObjectsVisible(objects, visible)
	for _, object in ipairs(objects) do
		object.Visible = visible
	end
end

local function CreateSymbolButton(parent, name, iconType, symbolSize, theme, isClose)
	local baseBg = Color3.fromRGB(255, 255, 255)
	local hoverBg = isClose and Color3.fromRGB(135, 34, 52) or theme.AccentSoft
	local baseIconColor = theme.SubText
	local hoverIconColor = isClose and Color3.fromRGB(255, 240, 245) or theme.Text
	local baseStrokeTransparency = 0.94
	local hoverStrokeTransparency = isClose and 0.2 or 0.45

	local button = NewInstance("TextButton")({
		Name = name,
		Size = UDim2.new(0, 28, 0, 28),
		BackgroundColor3 = baseBg,
		BackgroundTransparency = 0.92,
		AutoButtonColor = false,
		Text = "",
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = parent,
	})

	NewInstance("UICorner")({
		Name = GenerateString(),
		CornerRadius = UDim.new(0, 8),
		Parent = button,
	})

	local stroke = NewInstance("UIStroke")({
		Name = GenerateString(),
		Color = isClose and Color3.fromRGB(255, 90, 120) or theme.Accent,
		Transparency = baseStrokeTransparency,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = button,
	})

	local icon
	if iconType == "close" then
		icon = NewInstance("Frame")({
			Name = "Icon",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 7,
			Parent = button,
		})

		for _, rotation in ipairs({45, -45}) do
			local line = NewInstance("Frame")({
				Name = GenerateString(),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(0, 12, 0, 2),
				Rotation = rotation,
				BackgroundColor3 = baseIconColor,
				BorderSizePixel = 0,
				ZIndex = 8,
				Parent = icon,
			})

			NewInstance("UICorner")({
				Name = GenerateString(),
				CornerRadius = UDim.new(1, 0),
				Parent = line,
			})
		end
	else
		icon = NewInstance("TextLabel")({
			Name = "Icon",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = iconType,
			TextColor3 = baseIconColor,
			TextSize = symbolSize,
			Font = Enum.Font.GothamBold,
			ZIndex = 7,
			Parent = button,
		})
	end

	MakeGhostHover(
		button,
		stroke,
		icon,
		baseBg,
		hoverBg,
		baseStrokeTransparency,
		hoverStrokeTransparency,
		baseIconColor,
		hoverIconColor
	)

	return {
		Button = button,
		Icon = icon,
		Stroke = stroke,
		SetText = function(_, text)
			if icon:IsA("TextLabel") then
				icon.Text = text
			end
		end,
	}
end

function NebularityUI:CreateUI(settings)
	settings = settings or {}

	local theme, resolvedThemeName = GetTheme(settings.Theme)
	local players = loadService("Players")
	local localPlayer = players.LocalPlayer

	local mainGui = NewInstance("ScreenGui")({
		Name = GenerateString(),
		Parent = loadService("CoreGui") or localPlayer:WaitForChild("PlayerGui"),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Enabled = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 10000,
	})

	local notifyDefaults = {
		Duration = tonumber(settings.NotifyDuration) or 3,
		MaxVisible = tonumber(settings.NotifyMaxVisible) or 5,
		SoundId = settings.NotifySoundId,
		SoundVolume = tonumber(settings.NotifySoundVolume) or 0.35,
		SoundPlaybackSpeed = tonumber(settings.NotifySoundPlaybackSpeed) or 1,
	}

	local normalSize = settings.Size or UDim2.new(0, 1023, 0, 471)
	local normalBarHeight = settings.BottomBarHeight or 64
	local minimizedBarHeight = settings.MinimizedBarHeight or 46
	local normalBarInset = settings.BottomBarInset or 10
	local minimizedBarInset = settings.MinimizedBarInset or 10
	local minimizedWidth = settings.MinimizedWidth or math.clamp(math.floor((normalSize.X.Offset > 0 and normalSize.X.Offset or 1023) * 0.42), 420, 520)
	local minimizedSize = settings.MinimizedSize or UDim2.new(0, minimizedWidth, 0, minimizedBarHeight + minimizedBarInset + 12)

	local normalPosition = settings.Position or UDim2.new(0.5, 0, 0.5, 0)

	local isMinimized = false
	local isAnimating = false

	local Panel = NewInstance("Frame")({
		Name = GenerateString(),
		Size = normalSize,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = normalPosition,
		BackgroundColor3 = theme.PanelGradient[1],
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 1,
		Parent = mainGui,
	})

	local NotifyRoot = NewInstance("Frame")({
		Name = "NotifyRoot",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.new(0, 360, 0, 420),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 50,
		Parent = mainGui,
	})

	local NotifyList = NewInstance("Frame")({
		Name = "NotifyList",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = NotifyRoot,
	})

	NewInstance("UIListLayout")({
		Name = GenerateString(),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = NotifyList,
	})

	local PanelScale = NewInstance("UIScale")({
		Name = GenerateString(),
		Scale = 1,
		Parent = Panel,
	})

	NewInstance("UICorner")({
		Name = GenerateString(),
		CornerRadius = UDim.new(0, 24),
		Parent = Panel,
	})

	NewInstance("UIStroke")({
		Name = GenerateString(),
		Color = theme.PanelStroke,
		Transparency = shiftTransparency(theme.PanelStrokeTransparency, -0.18),
		Thickness = 1.35,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = Panel,
	})

	NewInstance("UIStroke")({
		Name = GenerateString(),
		Color = theme.Text,
		Transparency = 0.92,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = Panel,
	})

	NewInstance("UIGradient")({
		Name = GenerateString(),
		Color = ColorSequence.new(theme.PanelGradient[1], theme.PanelGradient[2]),
		Rotation = 112,
		Parent = Panel,
	})

	local ContentContainer = NewInstance("Frame")({
		Name = "ContentContainer",
		Size = UDim2.new(1, 0, 1, -84),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Panel,
	})

	local TabsContent = NewInstance("Frame")({
		Name = "TabsContent",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.new(0, 0, 0, 5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = ContentContainer,
	})

	local TopGlow = NewInstance("Frame")({
		Name = GenerateString(),
		Size = UDim2.new(1, 0, 0, 168),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = theme.TopGlow,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = ContentContainer,
	})

	NewInstance("UICorner")({
		Name = GenerateString(),
		CornerRadius = UDim.new(0, 20),
		Parent = TopGlow,
	})

	NewInstance("UIGradient")({
		Name = GenerateString(),
		Color = ColorSequence.new(theme.TopGlow, theme.PanelGradient[1]),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, theme.TopGlowTransparency),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Rotation = 90,
		Parent = TopGlow,
	})

	local MainSteering = NewInstance("Frame")({
		Name = GenerateString(),
		Size = UDim2.new(1, -34, 0, normalBarHeight),
		Position = UDim2.new(0.5, 0, 1, -normalBarInset),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = theme.BottomBar,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = Panel,
	})

	NewInstance("UICorner")({
		Name = GenerateString(),
		CornerRadius = UDim.new(0, 14),
		Parent = MainSteering,
	})

	NewInstance("UIStroke")({
		Name = GenerateString(),
		Color = theme.BottomBarStroke,
		Transparency = shiftTransparency(theme.BottomBarStrokeTransparency, -0.16),
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = MainSteering,
	})

	NewInstance("UIGradient")({
		Name = GenerateString(),
		Color = ColorSequence.new(theme.BottomBarGradient[1], theme.BottomBarGradient[2]),
		Rotation = 110,
		Parent = MainSteering,
	})

	local PlayerFaceImage = NewInstance("ImageLabel")({
		Name = GenerateString(),
		Size = UDim2.new(0, 48, 0, 48),
		Position = UDim2.new(0, 10, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = theme.AccentSoft,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ScaleType = Enum.ScaleType.Crop,
		Image = "",
		ZIndex = 4,
		Parent = MainSteering,
	})

	NewInstance("UICorner")({
		Name = GenerateString(),
		CornerRadius = UDim.new(1, 0),
		Parent = PlayerFaceImage,
	})

	NewInstance("UIStroke")({
		Name = GenerateString(),
		Color = theme.AvatarStroke,
		Transparency = theme.AvatarStrokeTransparency,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = PlayerFaceImage,
	})

	local AccentLine = NewInstance("Frame")({
		Name = GenerateString(),
		Size = UDim2.new(0, 2, 0, 34),
		Position = UDim2.new(0, 68, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = MainSteering,
	})

	NewInstance("UICorner")({
		Name = GenerateString(),
		CornerRadius = UDim.new(1, 0),
		Parent = AccentLine,
	})

	local TitleLabel = NewInstance("TextLabel")({
		Name = GenerateString(),
		Size = UDim2.new(0, 260, 0, 26),
		Position = UDim2.new(0, 82, 0, 3),
		BackgroundTransparency = 1,
		Text = settings.Title or "Nebularity",
		TextColor3 = theme.Text,
		TextTransparency = 0,
		TextSize = 20,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
		Parent = MainSteering,
	})

	local normalTitlePosition = UDim2.new(0, 82, 0, 3)
	local normalTitleSize = UDim2.new(0, 260, 0, 26)
	local normalSubTitlePosition = UDim2.new(0, 82, 0, 28)
	local normalSubTitleSize = UDim2.new(0, 320, 0, 18)
	local compactTitlePosition = UDim2.new(0, 18, 0.5, -11)
	local compactTitleSize = UDim2.new(1, -96, 0, 22)

	local SubTitleLabel = NewInstance("TextLabel")({
		Name = GenerateString(),
		Size = normalSubTitleSize,
		Position = normalSubTitlePosition,
		BackgroundTransparency = 1,
		Text = settings.SubTitle or localPlayer.Name,
		TextColor3 = theme.SubText,
		TextTransparency = 0,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
		Parent = MainSteering,
	})

	local TabsHolder = NewInstance("Frame")({
		Name = "TabsHolder",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -470, 1, 0),
		Position = UDim2.new(0, 410, 0, 0),
		ZIndex = 4,
		Parent = MainSteering,
	})

	local TabsScrolling = NewInstance("ScrollingFrame")({
		Name = "TabsScrolling",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
		HorizontalScrollBarInset = Enum.ScrollBarInset.None,
		ZIndex = 4,
		Parent = TabsHolder,
	})

	NewInstance("UIListLayout")({
		Name = GenerateString(),
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = TabsScrolling,
	})

	NewInstance("UIPadding")({
		Name = GenerateString(),
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		PaddingTop = UDim.new(0, 16),
		PaddingBottom = UDim.new(0, 16),
		Parent = TabsScrolling,
	})

	local WindowControls = NewInstance("Frame")({
		Name = "WindowControls",
		Size = UDim2.new(0, 62, 0, 28),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = MainSteering,
	})

	NewInstance("UIListLayout")({
		Name = GenerateString(),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = WindowControls,
	})

	local MinimizeButton = CreateSymbolButton(WindowControls, "MinimizeButton", "-", 18, theme, false)
	local CloseButton = CreateSymbolButton(WindowControls, "CloseButton", "close", 13, theme, true)

	local function updateTabArea()
		TabsHolder.Size = UDim2.new(1, -480, 1, 0)
		TabsHolder.Position = UDim2.new(0, 410, 0, 0)
	end

	updateTabArea()

	local connections = {}
	local function track(connection)
		table.insert(connections, connection)
		return connection
	end

	local panelFadeTargets = CollectTransparencyTargets(Panel)
	local contentFadeTargets = CollectTransparencyTargets(ContentContainer)
	local notifications = {}
	local notificationCounter = 0
	local steeringCompactObjects = {
		PlayerFaceImage,
		AccentLine,
		SubTitleLabel,
		TabsHolder,
	}
	local steeringFadeTargets = {}
	for _, object in ipairs(steeringCompactObjects) do
		AppendTargets(steeringFadeTargets, CollectTransparencyTargets(object))
	end
	local tabs = {}
	local selectedTabName = nil
	local isTabAnimating = false
	local flags = type(settings.Flags) == "table" and settings.Flags or {}
	local flagBindings = {}
	local notify
	local applyThemeByName

	local configFolderName = type(settings.ConfigFolder) == "string" and settings.ConfigFolder ~= "" and settings.ConfigFolder or "NebularityConfigs"
	local configFileName = type(settings.ConfigName) == "string" and settings.ConfigName ~= "" and settings.ConfigName or "default"
	local presets = {}

	local function normalizePresetName(name)
		local text = tostring(name or "")
		text = text:gsub("^%s+", ""):gsub("%s+$", "")
		if text == "" then
			return nil
		end
		return text
	end

	local function addPreset(name, url)
		local presetName = normalizePresetName(name)
		if not presetName then
			return false, "invalid preset name"
		end

		if type(url) ~= "string" or url:gsub("%s", "") == "" then
			return false, "invalid preset url"
		end

		presets[presetName] = {
			Url = url,
			Type = "auto",
		}
		return true, presetName
	end

	local function normalizePresetType(presetType)
		local text = string.lower(tostring(presetType or "auto"))
		if text == "json" or text == "script" or text == "auto" then
			return text
		end
		return "auto"
	end

	local function addTypedPreset(name, url, presetType)
		local presetName = normalizePresetName(name)
		if not presetName then
			return false, "invalid preset name"
		end

		if type(url) ~= "string" or url:gsub("%s", "") == "" then
			return false, "invalid preset url"
		end

		presets[presetName] = {
			Url = url,
			Type = normalizePresetType(presetType),
		}
		return true, presetName
	end

	local function removePreset(name)
		local presetName = normalizePresetName(name)
		if not presetName then
			return false, "invalid preset name"
		end

		if presets[presetName] == nil then
			return false, "preset not found"
		end

		presets[presetName] = nil
		return true, presetName
	end

	local function listPresets()
		local names = {}
		for name in pairs(presets) do
			table.insert(names, name)
		end
		table.sort(names)
		return names
	end

	local function getPresetEntry(name)
		local presetName = normalizePresetName(name)
		if not presetName then
			return nil
		end

		if presets[presetName] then
			local entry = presets[presetName]
			if type(entry) == "string" then
				return {
					Url = entry,
					Type = "auto",
				}, presetName
			end
			if type(entry) == "table" and type(entry.Url) == "string" then
				return {
					Url = entry.Url,
					Type = normalizePresetType(entry.Type),
				}, presetName
			end
		end

		local targetLower = string.lower(presetName)
		for existingName, entry in pairs(presets) do
			if string.lower(existingName) == targetLower then
				if type(entry) == "string" then
					return {
						Url = entry,
						Type = "auto",
					}, existingName
				end
				if type(entry) == "table" and type(entry.Url) == "string" then
					return {
						Url = entry.Url,
						Type = normalizePresetType(entry.Type),
					}, existingName
				end
			end
		end

		return nil
	end

	local function fetchRemotePreset(url)
		local globalTable = _G
		local globalHttpGet = globalTable and globalTable.httpget
		local globalRequest = globalTable and globalTable.request
		local globalHttpRequest = globalTable and globalTable.http_request
		local globalSyn = globalTable and globalTable.syn
		local globalHttp = globalTable and globalTable.http

		if type(game.HttpGet) == "function" then
			local ok, body = pcall(function()
				return game:HttpGet(url)
			end)
			if ok and type(body) == "string" and body ~= "" then
				return true, body
			end
		end

		if type(globalHttpGet) == "function" then
			local ok, body = pcall(globalHttpGet, url)
			if ok and type(body) == "string" and body ~= "" then
				return true, body
			end
		end

		local req = globalRequest or (globalSyn and globalSyn.request) or (globalHttp and globalHttp.request) or globalHttpRequest
		if type(req) == "function" then
			local ok, response = pcall(req, {
				Url = url,
				Method = "GET",
			})
			if ok and type(response) == "table" then
				local statusCode = tonumber(response.StatusCode) or tonumber(response.Status)
				local body = response.Body
				if statusCode and statusCode >= 200 and statusCode < 300 and type(body) == "string" and body ~= "" then
					return true, body
				end
			end
		end

		return false, "http unavailable or request failed"
	end

	local function decodePresetPayload(body)
		if type(body) ~= "string" or body == "" then
			return false, "empty payload"
		end

		local httpService = loadService("HttpService")
		local ok, decoded = pcall(function()
			return httpService:JSONDecode(body)
		end)
		if not ok or type(decoded) ~= "table" then
			return false, "invalid json"
		end

		return true, decoded
	end

	local function applyPresetPayload(decoded)
		if type(decoded) ~= "table" then
			return false, "invalid preset payload"
		end

		if type(decoded.Theme) == "string" and applyThemeByName then
			applyThemeByName(decoded.Theme)
		end

		local loadedFlags = type(decoded.Flags) == "table" and decoded.Flags or type(decoded.flags) == "table" and decoded.flags or nil
		if loadedFlags == nil then
			return false, "missing flags table"
		end

		for flagName, value in pairs(loadedFlags) do
			setFlagAndSync(flagName, value, true)
		end

		return true, "applied"
	end

	local function loadPreset(name, runtimeContext, forcedType)
		local presetEntry, resolvedName = getPresetEntry(name)
		if not presetEntry then
			return false, "preset not found"
		end

		local okFetch, bodyOrErr = fetchRemotePreset(presetEntry.Url)
		if not okFetch then
			return false, tostring(bodyOrErr)
		end

		local targetType = normalizePresetType(forcedType or presetEntry.Type)

		local function tryLoadJson()
			local okDecode, decodedOrErr = decodePresetPayload(bodyOrErr)
			if not okDecode then
				return false, decodedOrErr
			end
			return applyPresetPayload(decodedOrErr)
		end

		local function tryLoadScript()
			if type(loadstring) ~= "function" then
				return false, "loadstring unavailable"
			end

			local chunk, compileErr = loadstring(bodyOrErr, "NebularityPreset_" .. tostring(resolvedName))
			if type(chunk) ~= "function" then
				return false, tostring(compileErr or "compile failed")
			end

			local context = runtimeContext or {}
			local okRun, runResult = pcall(chunk, context)
			if not okRun then
				return false, tostring(runResult)
			end

			if type(runResult) == "function" then
				local okReturned, returnedErr = pcall(runResult, context)
				if not okReturned then
					return false, tostring(returnedErr)
				end
			end

			return true, resolvedName
		end

		if targetType == "json" then
			return tryLoadJson()
		end

		if targetType == "script" then
			return tryLoadScript()
		end

		local okJson, jsonResult = tryLoadJson()
		if okJson then
			return true, resolvedName
		end

		local okScript, scriptResult = tryLoadScript()
		if okScript then
			return true, resolvedName
		end

		return false, "preset decode failed (json: " .. tostring(jsonResult) .. ", script: " .. tostring(scriptResult) .. ")"
	end

	local function loadPresetJson(name)
		return loadPreset(name, nil, "json")
	end

	if type(settings.Presets) == "table" then
		for key, value in pairs(settings.Presets) do
			if type(key) == "string" and type(value) == "string" then
				addPreset(key, value)
			elseif type(value) == "table" then
				addTypedPreset(value.Name or value.name or key, value.Url or value.url, value.Type or value.type)
			end
		end
	end

	local function hasFileApi()
		return type(readfile) == "function"
			and type(writefile) == "function"
			and type(isfile) == "function"
	end

	local function canManageFolders()
		return type(makefolder) == "function" and type(isfolder) == "function"
	end

	local function ensureConfigFolder()
		if not canManageFolders() then
			return false
		end

		if not isfolder(configFolderName) then
			makefolder(configFolderName)
		end

		return true
	end

	local function configPath(name)
		local safeName = tostring(name or configFileName):gsub("[^%w_%-.]", "_")
		return configFolderName .. "/" .. safeName .. ".json"
	end

	local function resolveFlagName(flagName, fallback)
		if type(flagName) == "string" and flagName ~= "" then
			return flagName
		end

		if type(fallback) == "string" and fallback ~= "" then
			return fallback
		end

		return nil
	end

	local function getFlagValue(flagName, defaultValue)
		if flagName == nil then
			return defaultValue
		end

		local value = flags[flagName]
		if value == nil then
			return defaultValue
		end

		return value
	end

	local function setFlagValue(flagName, value)
		if flagName == nil then
			return
		end

		flags[flagName] = value
	end

	local function registerFlagBinding(flagName, apply)
		if flagName == nil or type(apply) ~= "function" then
			return
		end

		flagBindings[flagName] = apply
	end

	local function setFlagAndSync(flagName, value, runCallback)
		setFlagValue(flagName, value)
		local binding = flagBindings[flagName]
		if binding then
			binding(value, runCallback == true)
		end
	end

	local function shade(color, delta)
		local function channel(value)
			return math.clamp(math.floor(value * 255 + delta + 0.5), 0, 255)
		end

		return Color3.fromRGB(channel(color.R), channel(color.G), channel(color.B))
	end

	local function colorToKey(color)
		return string.format("%d,%d,%d", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
	end

	local function buildThemeColorMap(oldThemeData, newThemeData)
		local map = {}
		local keys = {
			"PanelStroke",
			"TopGlow",
			"BottomBar",
			"BottomBarStroke",
			"Accent",
			"AccentSoft",
			"Text",
			"SubText",
			"AvatarStroke",
		}

		for _, key in ipairs(keys) do
			local oldColor = oldThemeData[key]
			local newColor = newThemeData[key]
			if typeof(oldColor) == "Color3" and typeof(newColor) == "Color3" then
				map[colorToKey(oldColor)] = newColor
			end
		end

		if type(oldThemeData.PanelGradient) == "table" and type(newThemeData.PanelGradient) == "table" then
			for i = 1, math.min(#oldThemeData.PanelGradient, #newThemeData.PanelGradient) do
				map[colorToKey(oldThemeData.PanelGradient[i])] = newThemeData.PanelGradient[i]
			end
		end

		if type(oldThemeData.BottomBarGradient) == "table" and type(newThemeData.BottomBarGradient) == "table" then
			for i = 1, math.min(#oldThemeData.BottomBarGradient, #newThemeData.BottomBarGradient) do
				map[colorToKey(oldThemeData.BottomBarGradient[i])] = newThemeData.BottomBarGradient[i]
			end
		end

		return map
	end

	local function remapColor(colorMap, color)
		if typeof(color) ~= "Color3" then
			return color
		end
		return colorMap[colorToKey(color)] or color
	end

	local function remapGradient(colorMap, gradient)
		if not gradient then
			return gradient
		end

		local keypoints = gradient.Keypoints
		if not keypoints or #keypoints == 0 then
			return gradient
		end

		local mapped = {}
		for _, kp in ipairs(keypoints) do
			table.insert(mapped, ColorSequenceKeypoint.new(kp.Time, remapColor(colorMap, kp.Value)))
		end

		return ColorSequence.new(mapped)
	end

	local function notifyConfigUnavailable(action)
		if type(notify) == "function" then
			notify({
				Title = "Config",
				Message = "Config " .. tostring(action or "action") .. " is not available in this executor (missing readfile/writefile).",
				Duration = 4,
			})
		end
	end

	local function encodeFlags()
		local encoded = {}
		for key, value in pairs(flags) do
			local valueType = type(value)
			if valueType == "boolean" or valueType == "number" or valueType == "string" then
				encoded[key] = value
			elseif valueType == "table" then
				encoded[key] = value
			end
		end
		return encoded
	end

	local function saveConfig(name)
		if not hasFileApi() then
			notifyConfigUnavailable("save")
			return false, "file api unavailable"
		end

		if not ensureConfigFolder() then
			notifyConfigUnavailable("save")
			return false, "folder api unavailable"
		end

		local httpService = loadService("HttpService")
		local payload = {
			Theme = resolvedThemeName,
			Flags = encodeFlags(),
			SavedAt = os.time(),
		}

		local ok, encoded = pcall(function()
			return httpService:JSONEncode(payload)
		end)
		if not ok then
			return false, "encode failed"
		end

		local filePath = configPath(name)
		local writeOk, writeErr = pcall(function()
			writefile(filePath, encoded)
		end)
		if not writeOk then
			return false, tostring(writeErr)
		end

		return true, filePath
	end

	local function loadConfig(name)
		if not hasFileApi() then
			notifyConfigUnavailable("load")
			return false, "file api unavailable"
		end

		local filePath = configPath(name)
		if not isfile(filePath) then
			return false, "config not found"
		end

		local readOk, content = pcall(function()
			return readfile(filePath)
		end)
		if not readOk then
			return false, tostring(content)
		end

		local httpService = loadService("HttpService")
		local decodeOk, decoded = pcall(function()
			return httpService:JSONDecode(content)
		end)
		if not decodeOk or type(decoded) ~= "table" then
			return false, "decode failed"
		end

		local loadedFlags = type(decoded.Flags) == "table" and decoded.Flags or {}
		if type(decoded.Theme) == "string" and applyThemeByName then
			applyThemeByName(decoded.Theme)
		end

		for flagName, value in pairs(loadedFlags) do
			setFlagAndSync(flagName, value, true)
		end

		return true, filePath
	end

	local function deleteConfig(name)
		if not hasFileApi() or type(delfile) ~= "function" then
			notifyConfigUnavailable("delete")
			return false, "delete api unavailable"
		end

		local filePath = configPath(name)
		if not isfile(filePath) then
			return false, "config not found"
		end

		local ok, err = pcall(function()
			delfile(filePath)
		end)
		if not ok then
			return false, tostring(err)
		end

		return true, filePath
	end

	local function listConfigs()
		if type(listfiles) ~= "function" or not canManageFolders() then
			return {}
		end

		if not isfolder(configFolderName) then
			return {}
		end

		local ok, files = pcall(function()
			return listfiles(configFolderName)
		end)
		if not ok or type(files) ~= "table" then
			return {}
		end

		local names = {}
		for _, path in ipairs(files) do
			local normalized = tostring(path):gsub("\\", "/")
			local fileName = normalized:match("([^/]+)$")
			if fileName and fileName:sub(-5) == ".json" then
				table.insert(names, fileName:sub(1, -6))
			end
		end

		table.sort(names)
		return names
	end

	applyThemeByName = function(nextThemeName)
		local nextTheme, nextName = GetTheme(nextThemeName)
		if nextName == resolvedThemeName then
			return true, nextName
		end

		local oldThemeData = theme
		local colorMap = buildThemeColorMap(oldThemeData, nextTheme)
		local targets = {mainGui}
		for _, descendant in ipairs(mainGui:GetDescendants()) do
			table.insert(targets, descendant)
		end

		for _, node in ipairs(targets) do
			if node:IsA("GuiObject") then
				if node.BackgroundColor3 then
					node.BackgroundColor3 = remapColor(colorMap, node.BackgroundColor3)
				end

				if node:IsA("TextLabel") or node:IsA("TextButton") or node:IsA("TextBox") then
					node.TextColor3 = remapColor(colorMap, node.TextColor3)
					node.TextStrokeColor3 = remapColor(colorMap, node.TextStrokeColor3)
				end

				if node:IsA("ImageLabel") or node:IsA("ImageButton") then
					node.ImageColor3 = remapColor(colorMap, node.ImageColor3)
				end
			end

			if node:IsA("UIStroke") then
				node.Color = remapColor(colorMap, node.Color)
			end

			if node:IsA("UIGradient") then
				node.Color = remapGradient(colorMap, node.Color)
			end
		end

		theme = nextTheme
		resolvedThemeName = nextName
		return true, nextName
	end

	local selectTab  -- Forward declaration

	local function addTab(selfOrTabName, arg2, arg3)
		local tabName, tabIcon
		if type(selfOrTabName) == "table" and (selfOrTabName.Notify or selfOrTabName.Gui) then
			tabName = arg2
			tabIcon = arg3
		else
			tabName = selfOrTabName
			tabIcon = arg2
		end

		if type(tabName) ~= "string" then
			return nil
		end

		if tabs[tabName] then
			warn("Tab '" .. tabName .. "' already exists!")
			return nil
		end
		local tabButton = NewInstance("TextButton")({
			Name = tabName,
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			ZIndex = 4,
			Parent = TabsScrolling,
		})

		local tabPill = NewInstance("Frame")({
			Name = GenerateString(),
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = theme.BottomBar,
			BackgroundTransparency = 0.82,
			BorderSizePixel = 0,
			ZIndex = 4,
			Parent = tabButton,
		})

		NewInstance("UICorner")({
			Name = GenerateString(),
			CornerRadius = UDim.new(1, 0),
			Parent = tabPill,
		})

		local tabPillStroke = NewInstance("UIStroke")({
			Name = GenerateString(),
			Color = theme.PanelStroke,
			Transparency = 0.76,
			Thickness = 1,
			Parent = tabPill,
		})

		local tabContainer = NewInstance("Frame")({
			Name = GenerateString(),
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 4,
			Parent = tabPill,
		})

		NewInstance("UIListLayout")({
			Name = GenerateString(),
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
			Parent = tabContainer,
		})

		NewInstance("UIPadding")({
			Name = GenerateString(),
			PaddingLeft = UDim.new(0, 13),
			PaddingRight = UDim.new(0, 13),
			PaddingTop = UDim.new(0, 7),
			PaddingBottom = UDim.new(0, 7),
			Parent = tabContainer,
		})
		if tabIcon and tabIcon ~= "" then
			local iconImage = NewInstance("ImageLabel")({
				Name = "TabIcon",
				Size = UDim2.new(0, 20, 0, 20),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = tabIcon,
				ScaleType = Enum.ScaleType.Fit,
				ZIndex = 5,
				Parent = tabContainer,
			})
		end
		local tabTitle = NewInstance("TextLabel")({
			Name = GenerateString(),
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = tabName,
			TextColor3 = theme.SubText,
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			ZIndex = 5,
			Parent = tabContainer,
		})
		tabButton.MouseEnter:Connect(function()
			if selectedTabName ~= tabName then
				Tween(tabPill, {BackgroundTransparency = 0.7}, 0.12):Play()
				Tween(tabPillStroke, {Transparency = 0.62}, 0.12):Play()
				tabTitle.TextColor3 = theme.Text
			end
		end)

		tabButton.MouseLeave:Connect(function()
			if selectedTabName ~= tabName then
				Tween(tabPill, {BackgroundTransparency = 0.82}, 0.12):Play()
				Tween(tabPillStroke, {Transparency = 0.76}, 0.12):Play()
				tabTitle.TextColor3 = theme.SubText
			end
		end)
		local tabIndicator = NewInstance("Frame")({
			Name = "TabIndicator",
			Size = UDim2.new(0.6, 0, 0, 2),
			Position = UDim2.new(0.5, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = theme.Accent,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 6,
			Parent = tabButton,
		})

		NewInstance("UICorner")({
			Name = GenerateString(),
			CornerRadius = UDim.new(1, 0),
			Parent = tabIndicator,
		})
		local contentFrame = NewInstance("Frame")({
			Name = tabName .. "Content",
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 3,
			Parent = TabsContent,
		})

		NewInstance("UIPadding")({
			Name = GenerateString(),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
			PaddingTop = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 16),
			Parent = contentFrame,
		})
		local contentWrapper = {}
		contentWrapper._frame = contentFrame

		function contentWrapper:AddSection(sectionName, sectioninfo)
			if type(sectionName) ~= "string" then
				return nil
			end

			local panelWrapper = contentFrame:FindFirstChild("_PanelWrapper")
			if not panelWrapper then
				panelWrapper = NewInstance("Frame")({
					Name = "_PanelWrapper",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 3,
					Parent = contentFrame,
				})

				NewInstance("UIListLayout")({
					Name = GenerateString(),
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 16),
					Parent = panelWrapper,
				})
			end

			local function getSections()
				local sections = {}
				for _, child in ipairs(panelWrapper:GetChildren()) do
					if child:IsA("ScrollingFrame") and child.Name:match("Section_") then
						table.insert(sections, child)
					end
				end

				table.sort(sections, function(a, b)
					return (a.LayoutOrder or 0) < (b.LayoutOrder or 0)
				end)

				return sections
			end

			local function refreshSectionSizes()
				local sections = getSections()
				local count = #sections
				if count <= 0 then
					return
				end

				local gap = 16
				local widthScale = 1 / count
				local widthOffset = -((count - 1) * gap) / count

				for index, sectionFrame in ipairs(sections) do
					sectionFrame.LayoutOrder = index
					Tween(sectionFrame, {
						Size = UDim2.new(widthScale, widthOffset, 1, 0),
					}, 0.18):Play()
				end
			end

			local sectionCount = 0
			for _, child in ipairs(panelWrapper:GetChildren()) do
				if child:IsA("ScrollingFrame") and child.Name:match("Section_") then
					sectionCount = sectionCount + 1
				end
			end

			if sectionCount >= 3 then
				warn("Maximum 3 sections per tab reached!")
				return nil
			end
			local sectionHeaderHeight = 52
			local sectionHeaderGap = 30
			local sectionContentOffset = sectionHeaderHeight + sectionHeaderGap
			local section = NewInstance("ScrollingFrame")({
				Name = "Section_" .. sectionName,
				Size = UDim2.new(1, 0, 1, -4),
				BackgroundColor3 = shade(theme.PanelGradient[1], -8),
				BackgroundTransparency = 0.02,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 5,
				CanvasSize = UDim2.new(0, 0, 0, 1),
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
				LayoutOrder = sectionCount + 1,
				ZIndex = 4,
				Parent = panelWrapper,
			})

			refreshSectionSizes()

			NewInstance("UICorner")({
				Name = GenerateString(),
				CornerRadius = UDim.new(0, 18),
				Parent = section,
			})
			NewInstance("UIGradient")({
				Name = GenerateString(),
				Color = ColorSequence.new(
					shade(theme.PanelGradient[1], -18),
					shade(theme.PanelGradient[2], 8)
				),
				Rotation = 100,
				Parent = section,
			})

			NewInstance("UIStroke")({
				Name = GenerateString(),
				Color = theme.PanelStroke,
				Transparency = shiftTransparency(theme.PanelStrokeTransparency, -0.2),
				Thickness = 1.4,
				Parent = section,
			})

			local sectionTopAmbient = NewInstance("Frame")({
				Name = GenerateString(),
				Size = UDim2.new(1, -14, 0, 28),
				Position = UDim2.new(0, 7, 0, 7),
				BackgroundColor3 = theme.Accent,
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0,
				ZIndex = 5,
				Parent = section,
			})

			NewInstance("UICorner")({
				Name = GenerateString(),
				CornerRadius = UDim.new(0, 14),
				Parent = sectionTopAmbient,
			})

			NewInstance("UIGradient")({
				Name = GenerateString(),
				Color = ColorSequence.new(theme.Accent, theme.AccentSoft),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Rotation = 90,
				Parent = sectionTopAmbient,
			})
			local sectionHeader = NewInstance("Frame")({
				Name = "SectionHeader",
				Size = UDim2.new(1, 0, 0, sectionHeaderHeight),
				BackgroundColor3 = theme.Accent,
				BackgroundTransparency = 0.08,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				ZIndex = 8,
				Parent = section,
			})

			NewInstance("UICorner")({
				Name = GenerateString(),
				CornerRadius = UDim.new(0, 16),
				Parent = sectionHeader,
			})
			NewInstance("UIGradient")({
				Name = GenerateString(),
				Color = ColorSequence.new(shade(theme.Accent, -14), shade(theme.AccentSoft, 10)),
				Rotation = 15,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.28),
					NumberSequenceKeypoint.new(1, 0.56),
				}),
				Parent = sectionHeader,
			})

			NewInstance("UIStroke")({
				Name = GenerateString(),
				Color = theme.Accent,
				Transparency = 0.18,
				Thickness = 1.2,
				Parent = sectionHeader,
			})

			local headerAccentRail = NewInstance("Frame")({
				Name = GenerateString(),
				Size = UDim2.new(0, 3, 1, -18),
				Position = UDim2.new(0, 10, 0, 9),
				BackgroundColor3 = theme.Text,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				ZIndex = 9,
				Parent = sectionHeader,
			})

			NewInstance("UICorner")({
				Name = GenerateString(),
				CornerRadius = UDim.new(1, 0),
				Parent = headerAccentRail,
			})
			local accentGlow = NewInstance("Frame")({
				Name = GenerateString(),
				Size = UDim2.new(1, -16, 0, 2),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 1, 0),
				BackgroundColor3 = theme.Accent,
				BackgroundTransparency = 0.08,
				BorderSizePixel = 0,
				ZIndex = 9,
				Parent = sectionHeader,
			})

			NewInstance("UICorner")({
				Name = GenerateString(),
				CornerRadius = UDim.new(1, 0),
				Parent = accentGlow,
			})
			NewInstance("TextLabel")({
				Name = "Title",
				Size = UDim2.new(1, -130, 1, 0),
				Position = UDim2.new(0, 22, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = sectionName,
				TextColor3 = theme.Text,
				TextSize = 14,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 10,
				Parent = sectionHeader,
			})

			local sectionBadge =  nil
			if sectioninfo and type(sectioninfo) == "string" then
				sectionBadge = NewInstance("Frame")({
					Name = GenerateString(),
					Size = UDim2.new(0, 78, 0, 24),
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
					BackgroundColor3 = shade(theme.BottomBar, -6),
					BackgroundTransparency = 0.08,
					BorderSizePixel = 0,
					ZIndex = 10,
					Parent = sectionHeader,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(1, 0),
					Parent = sectionBadge,
				})

				NewInstance("UIStroke")({
					Name = GenerateString(),
					Color = theme.Accent,
					Transparency = 0.3,
					Thickness = 1,
					Parent = sectionBadge,
				})
				NewInstance("TextLabel")({
					Name = GenerateString(),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = sectioninfo,
					TextColor3 = theme.Accent,
					TextSize = 11,
					Font = Enum.Font.GothamBold,
					ZIndex = 11,
					Parent = sectionBadge,
				})
			end
			--just 4 Testing
--[[ 			local sectionPattern = NewInstance("Frame")({
				Name = GenerateString(),
				Size = UDim2.new(1, -16, 1, -(sectionContentOffset + 12)),
				Position = UDim2.new(0, 8, 0, sectionContentOffset + 6),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 5,
				Parent = section,
			}) ]]

--[[ 			for index = 0, 2 do
				local line = NewInstance("Frame")({
					Name = GenerateString(),
					Size = UDim2.new(1, 0, 0, 1),
					Position = UDim2.new(0, 0, 0, 18 + (index * 36)),
					BackgroundColor3 = theme.Accent,
					BackgroundTransparency = 0.92,
					BorderSizePixel = 0,
					Rotation = -3,
					ZIndex = 5,
					Parent = sectionPattern,
				})
			end ]]

			local sectionContent = NewInstance("Frame")({
				Name = "Content",
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, sectionContentOffset),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 6,
				Parent = section,
			})

			NewInstance("UIPadding")({
				Name = GenerateString(),
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12),
				PaddingTop = UDim.new(0, 0),
				PaddingBottom = UDim.new(0, 14),
				Parent = sectionContent,
			})

			local layoutList = NewInstance("UIListLayout")({
				Name = GenerateString(),
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
				Parent = sectionContent,
			})
			layoutList.Changed:Connect(function()
				section.CanvasSize = UDim2.new(0, 0, 0, sectionContentOffset + layoutList.AbsoluteContentSize.Y + 24)
			end)

			local sectionWrapper = {}
			sectionWrapper._frame = sectionContent

			local function getDecimals(number)
				local asNumber = tonumber(number)
				if not asNumber then
					return 0
				end

				local text = tostring(asNumber)
				local dotIndex = string.find(text, ".", 1, true)
				if not dotIndex then
					return 0
				end

				return #text - dotIndex
			end

			local function formatNumber(value, decimals)
				if decimals <= 0 then
					return tostring(math.floor(value + 0.5))
				end

				local formatted = string.format("%." .. tostring(decimals) .. "f", value)
				formatted = formatted:gsub("(%..-)0+$", "%1")
				formatted = formatted:gsub("%.$", "")
				return formatted
			end

			function sectionWrapper:AddLabel(config)
				if type(config) == "string" then
					config = {text = config}
				end
				config = config or {}

				local labelFrame = NewInstance("Frame")({
					Name = config.flag or config.text or "Label",
					Size = UDim2.new(1, -2, 0, 28),
					Position = UDim2.new(0, 1, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 7,
					Parent = sectionContent,
				})

				local textLabel = NewInstance("TextLabel")({
					Name = "Text",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = tostring(config.text or config.title or "Label"),
					TextColor3 = config.color or theme.SubText,
					TextSize = tonumber(config.size) or 12,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = 7,
					Parent = labelFrame,
				})

				return {
					Set = function(text)
						textLabel.Text = tostring(text or "")
					end,
					Get = function()
						return textLabel.Text
					end,
					Frame = labelFrame,
				}
			end

			function sectionWrapper:AddParagraph(config)
				if type(config) == "string" then
					config = {text = config}
				end
				config = config or {}

				local titleText = tostring(config.title or "Info")
				local bodyText = tostring(config.text or config.description or "")
				local bodyLines = math.clamp(math.ceil((utf8.len(bodyText) or #bodyText) / 42), 1, 6)
				local totalHeight = 34 + (bodyLines * 14)

				local paragraphFrame = NewInstance("Frame")({
					Name = config.flag or titleText,
					Size = UDim2.new(1, -2, 0, totalHeight),
					Position = UDim2.new(0, 1, 0, 0),
					BackgroundColor3 = shade(theme.PanelGradient[1], -12),
					BackgroundTransparency = 0.08,
					BorderSizePixel = 0,
					ZIndex = 7,
					Parent = sectionContent,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(0, 10),
					Parent = paragraphFrame,
				})

				NewInstance("UIStroke")({
					Name = GenerateString(),
					Color = theme.PanelStroke,
					Transparency = 0.6,
					Thickness = 1,
					Parent = paragraphFrame,
				})

				NewInstance("TextLabel")({
					Name = "Title",
					Size = UDim2.new(1, -16, 0, 18),
					Position = UDim2.new(0, 8, 0, 6),
					BackgroundTransparency = 1,
					Text = titleText,
					TextColor3 = theme.Text,
					TextSize = 12,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 8,
					Parent = paragraphFrame,
				})

				local bodyLabel = NewInstance("TextLabel")({
					Name = "Body",
					Size = UDim2.new(1, -16, 0, bodyLines * 14),
					Position = UDim2.new(0, 8, 0, 24),
					BackgroundTransparency = 1,
					Text = bodyText,
					TextColor3 = theme.SubText,
					TextSize = 12,
					Font = Enum.Font.Gotham,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					ZIndex = 8,
					Parent = paragraphFrame,
				})

				return {
					Set = function(text)
						bodyLabel.Text = tostring(text or "")
					end,
					Get = function()
						return bodyLabel.Text
					end,
					Frame = paragraphFrame,
				}
			end

			function sectionWrapper:AddButton(config)
				if type(config) == "string" then
					config = {text = config}
				end
				config = config or {}

				local buttonFrame = NewInstance("Frame")({
					Name = config.flag or config.text or "Button",
					Size = UDim2.new(1, -2, 0, 50),
					Position = UDim2.new(0, 1, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 7,
					Parent = sectionContent,
				})

				local actionButton = NewInstance("TextButton")({
					Name = "Action",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = shade(theme.PanelGradient[1], -10),
					BackgroundTransparency = 0.02,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 7,
					Parent = buttonFrame,
				})

				local actionLabel = NewInstance("TextLabel")({
					Name = "Label",
					Size = UDim2.new(1, -16, 1, 0),
					Position = UDim2.new(0, 8, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = tostring(config.text or "Button"),
					TextColor3 = theme.Text,
					TextStrokeColor3 = shade(theme.PanelGradient[1], -35),
					TextStrokeTransparency = 0.55,
					TextSize = 13,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 8,
					Parent = actionButton,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(0, 11),
					Parent = actionButton,
				})

				local actionStroke = NewInstance("UIStroke")({
					Name = GenerateString(),
					Color = theme.PanelStroke,
					Transparency = 0.35,
					Thickness = 1.2,
					Parent = actionButton,
				})

				track(actionButton.MouseEnter:Connect(function()
					Tween(actionButton, {BackgroundTransparency = 0}, 0.12):Play()
					Tween(actionStroke, {Transparency = 0.12, Color = theme.Accent}, 0.12):Play()
				end))

				track(actionButton.MouseLeave:Connect(function()
					Tween(actionButton, {BackgroundTransparency = 0.02}, 0.12):Play()
					Tween(actionStroke, {Transparency = 0.35, Color = theme.PanelStroke}, 0.12):Play()
				end))

				track(actionButton.MouseButton1Click:Connect(function()
					if type(config.callback) == "function" then
						task.spawn(config.callback)
					end
				end))

				return {
					SetText = function(text)
						actionLabel.Text = tostring(text or "")
					end,
					Press = function()
						if type(config.callback) == "function" then
							task.spawn(config.callback)
						end
					end,
					Frame = buttonFrame,
				}
			end

			function sectionWrapper:AddDropdown(config)
				config = config or {}
				if type(config) ~= "table" then
					return nil
				end

				local options = type(config.options) == "table" and config.options or {}
				local isMulti = config.multi == true or config.Multi == true
				local dropdownFlag = resolveFlagName(config.flag, config.text)
				local expanded = false

				local dropdownFrame = NewInstance("Frame")({
					Name = dropdownFlag or config.text or "Dropdown",
					Size = UDim2.new(1, -2, 0, 58),
					Position = UDim2.new(0, 1, 0, 0),
					BackgroundColor3 = shade(theme.PanelGradient[1], -10),
					BackgroundTransparency = 0.03,
					BorderSizePixel = 0,
					ClipsDescendants = true,
					ZIndex = 7,
					Parent = sectionContent,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(0, 11),
					Parent = dropdownFrame,
				})

				NewInstance("UIStroke")({
					Name = GenerateString(),
					Color = theme.PanelStroke,
					Transparency = shiftTransparency(theme.PanelStrokeTransparency, -0.3),
					Thickness = 1.2,
					Parent = dropdownFrame,
				})

				local titleLabel = NewInstance("TextLabel")({
					Name = "Title",
					Size = UDim2.new(0.45, -10, 0, 24),
					Position = UDim2.new(0, 15, 0, 6),
					BackgroundTransparency = 1,
					Text = tostring(config.text or "Dropdown"),
					TextColor3 = theme.Text,
					TextSize = 13,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 8,
					Parent = dropdownFrame,
				})

				local valueButton = NewInstance("TextButton")({
					Name = "ValueButton",
					Size = UDim2.new(0.55, -18, 0, 28),
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -10, 0, 6),
					BackgroundColor3 = shade(theme.BottomBar, -8),
					BackgroundTransparency = 0.04,
					Text = "Select",
					TextColor3 = theme.SubText,
					TextSize = 12,
					Font = Enum.Font.Gotham,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					ZIndex = 8,
					Parent = dropdownFrame,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(0, 8),
					Parent = valueButton,
				})

				local optionsHolder = NewInstance("Frame")({
					Name = "Options",
					Size = UDim2.new(1, -16, 0, 0),
					Position = UDim2.new(0, 8, 0, 38),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 8,
					Parent = dropdownFrame,
				})

				local optionsLayout = NewInstance("UIListLayout")({
					Name = GenerateString(),
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4),
					Parent = optionsHolder,
				})

				local selected
				if isMulti then
					selected = type(getFlagValue(dropdownFlag, config.default)) == "table" and getFlagValue(dropdownFlag, config.default) or {}
				else
					selected = getFlagValue(dropdownFlag, config.default)
				end

				local function selectedText()
					if isMulti then
						local parts = {}
						for _, option in ipairs(options) do
							if selected[tostring(option)] == true then
								table.insert(parts, tostring(option))
							end
						end
						if #parts == 0 then
							return "Select"
						end
						return table.concat(parts, ", ")
					end

					if selected == nil or tostring(selected) == "" then
						return "Select"
					end
					return tostring(selected)
				end

				local optionButtons = {}
				local function applyDropdownValue(nextValue, runCallback)
					if isMulti then
						if type(nextValue) == "table" then
							selected = {}
							for key, value in pairs(nextValue) do
								if value == true then
									selected[tostring(key)] = true
								end
							end
						end
						setFlagValue(dropdownFlag, selected)
					else
						selected = nextValue
						setFlagValue(dropdownFlag, selected)
					end

					valueButton.Text = selectedText()
					for optionValue, button in pairs(optionButtons) do
						local active = isMulti and selected[optionValue] == true or tostring(selected) == optionValue
						button.TextColor3 = active and theme.Text or theme.SubText
						button.BackgroundTransparency = active and 0.02 or 0.18
						button.BackgroundColor3 = active and shade(theme.AccentSoft, -8) or shade(theme.BottomBar, -6)
					end

					if runCallback and type(config.callback) == "function" then
						task.spawn(config.callback, selected)
					end
				end

				registerFlagBinding(dropdownFlag, applyDropdownValue)

				for _, option in ipairs(options) do
					local optionValue = tostring(option)
					local optionButton = NewInstance("TextButton")({
						Name = optionValue,
						Size = UDim2.new(1, 0, 0, 24),
						BackgroundColor3 = shade(theme.BottomBar, -6),
						BackgroundTransparency = 0.18,
						BorderSizePixel = 0,
						Text = optionValue,
						TextColor3 = theme.SubText,
						TextSize = 12,
						Font = Enum.Font.Gotham,
						AutoButtonColor = false,
						ZIndex = 8,
						Parent = optionsHolder,
					})

					optionButtons[optionValue] = optionButton

					NewInstance("UICorner")({
						Name = GenerateString(),
						CornerRadius = UDim.new(0, 6),
						Parent = optionButton,
					})

					track(optionButton.MouseButton1Click:Connect(function()
						if isMulti then
							selected[optionValue] = not selected[optionValue]
							applyDropdownValue(selected, true)
						else
							applyDropdownValue(optionValue, true)
							expanded = false
						end
					end))
				end

				local function refreshExpanded()
					local listHeight = optionsLayout.AbsoluteContentSize.Y
					local targetHeight = expanded and (44 + listHeight + 8) or 58
					Tween(dropdownFrame, {Size = UDim2.new(1, -2, 0, targetHeight)}, 0.14):Play()
					Tween(optionsHolder, {Size = UDim2.new(1, -16, 0, expanded and listHeight or 0)}, 0.14):Play()
				end

				track(optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshExpanded))
				track(valueButton.MouseButton1Click:Connect(function()
					expanded = not expanded
					refreshExpanded()
				end))

				applyDropdownValue(selected, false)
				if type(config.callback) == "function" then
					task.spawn(config.callback, selected)
				end

				return {
					Set = function(nextValue)
						applyDropdownValue(nextValue, true)
					end,
					Get = function()
						return selected
					end,
					Frame = dropdownFrame,
				}
			end

			function sectionWrapper:AddKeybind(config)
				config = config or {}
				if type(config) ~= "table" then
					return nil
				end

				local bindFlag = resolveFlagName(config.flag, config.text)
				local mode = string.lower(tostring(config.mode or "toggle")) == "hold" and "hold" or "toggle"
				local capturing = false
				local active = false

				local function isMouseButtonInputType(userInputType)
					if typeof(userInputType) ~= "EnumItem" or userInputType.EnumType ~= Enum.UserInputType then
						return false
					end
					return string.sub(userInputType.Name, 1, 11) == "MouseButton"
				end

				local function parseBind(value)
					if typeof(value) == "EnumItem" then
						if value.EnumType == Enum.KeyCode then
							return value
						elseif value.EnumType == Enum.UserInputType then
							return value
						end
					end
					if type(value) == "string" then
						if Enum.KeyCode[value] then
							return Enum.KeyCode[value]
						end
						if Enum.UserInputType[value] then
							return Enum.UserInputType[value]
						end
					end
					return nil
				end

				local boundKey = parseBind(getFlagValue(bindFlag, config.default or config.key))

				local keybindFrame = NewInstance("Frame")({
					Name = bindFlag or config.text or "Keybind",
					Size = UDim2.new(1, -2, 0, 58),
					Position = UDim2.new(0, 1, 0, 0),
					BackgroundColor3 = shade(theme.PanelGradient[1], -10),
					BackgroundTransparency = 0.03,
					BorderSizePixel = 0,
					ZIndex = 7,
					Parent = sectionContent,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(0, 11),
					Parent = keybindFrame,
				})

				NewInstance("UIStroke")({
					Name = GenerateString(),
					Color = theme.PanelStroke,
					Transparency = shiftTransparency(theme.PanelStrokeTransparency, -0.32),
					Thickness = 1.2,
					Parent = keybindFrame,
				})

				NewInstance("TextLabel")({
					Name = "Title",
					Size = UDim2.new(0.6, -8, 1, 0),
					Position = UDim2.new(0, 15, 0, 0),
					BackgroundTransparency = 1,
					Text = tostring(config.text or "Keybind") .. " [" .. string.upper(mode) .. "]",
					TextColor3 = theme.Text,
					TextSize = 13,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 8,
					Parent = keybindFrame,
				})

				local bindButton = NewInstance("TextButton")({
					Name = "BindButton",
					Size = UDim2.new(0, 92, 0, 28),
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -12, 0.5, 0),
					BackgroundColor3 = shade(theme.BottomBar, -8),
					BackgroundTransparency = 0.02,
					BorderSizePixel = 0,
					Text = "Unbound",
					TextColor3 = theme.SubText,
					TextSize = 12,
					Font = Enum.Font.GothamBold,
					AutoButtonColor = false,
					ZIndex = 8,
					Parent = keybindFrame,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(1, 0),
					Parent = bindButton,
				})

				local function updateBindVisual()
					bindButton.Text = capturing and "..." or (boundKey and boundKey.Name or "Unbound")
					bindButton.TextColor3 = (capturing or boundKey) and theme.Text or theme.SubText
				end

				local function applyBindValue(nextValue, runCallback)
					boundKey = parseBind(nextValue)
					setFlagValue(bindFlag, boundKey and boundKey.Name or "")
					updateBindVisual()
					if runCallback and type(config.onBind) == "function" then
						task.spawn(config.onBind, boundKey and boundKey.Name or "")
					end
				end

				registerFlagBinding(bindFlag, applyBindValue)
				applyBindValue(boundKey, false)

				track(bindButton.MouseButton1Click:Connect(function()
					capturing = true
					updateBindVisual()
				end))

				track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
					local mouseInput = isMouseButtonInputType(input.UserInputType)
					if gameProcessed and not mouseInput then
						return
					end

					if capturing then
						if input.UserInputType == Enum.UserInputType.Keyboard then
							capturing = false
							if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape then
								applyBindValue(nil, true)
							else
								applyBindValue(input.KeyCode, true)
							end
						elseif mouseInput then
							capturing = false
							applyBindValue(input.UserInputType, true)
						end
						return
					end

					local isTriggered = false
					if boundKey then
						if boundKey.EnumType == Enum.KeyCode then
							isTriggered = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == boundKey
						elseif boundKey.EnumType == Enum.UserInputType then
							isTriggered = input.UserInputType == boundKey
						end
					end

					if isTriggered then
						if mode == "hold" then
							if not active then
								active = true
								if type(config.callback) == "function" then
									task.spawn(config.callback, true, boundKey.Name)
								end
							end
						else
							active = not active
							if type(config.callback) == "function" then
								task.spawn(config.callback, active, boundKey.Name)
							end
						end
					end
				end))

				track(UserInputService.InputEnded:Connect(function(input)
					if mode ~= "hold" or not boundKey then
						return
					end

					local isReleased = false
					if boundKey.EnumType == Enum.KeyCode then
						isReleased = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == boundKey
					elseif boundKey.EnumType == Enum.UserInputType then
						isReleased = input.UserInputType == boundKey
					end

					if isReleased and active then
						active = false
						if type(config.callback) == "function" then
							task.spawn(config.callback, false, boundKey.Name)
						end
					end
				end))

				return {
					Set = function(nextKey)
						applyBindValue(nextKey, true)
					end,
					Get = function()
						return boundKey and boundKey.Name or ""
					end,
					Frame = keybindFrame,
				}
			end

			function sectionWrapper:AddSlider(config)
				config = config or {}
				if type(config) ~= "table" then
					return nil
				end

				local minimum = tonumber(config.min) or 0
				local maximum = tonumber(config.max) or 100
				if maximum < minimum then
					minimum, maximum = maximum, minimum
				end

				local increment = tonumber(config.inc) or tonumber(config.step) or 1
				if increment <= 0 then
					increment = 1
				end

				local decimals = math.max(getDecimals(increment), tonumber(config.decimals) or 0)
				local suffix = config.suffix ~= nil and tostring(config.suffix) or ""
				local sliderFlag = resolveFlagName(config.flag, config.text)
				local sliderValue = math.clamp(tonumber(getFlagValue(sliderFlag, config.default)) or minimum, minimum, maximum)

				local sliderFrame = NewInstance("Frame")({
					Name = config.flag or config.text or "Slider",
					Size = UDim2.new(1, -2, 0, 58),
					Position = UDim2.new(0, 1, 0, 0),
					BackgroundColor3 = shade(theme.PanelGradient[1], -10),
					BackgroundTransparency = 0.03,
					BorderSizePixel = 0,
					ZIndex = 7,
					Parent = sectionContent,
				})

				local sliderAccentStrip = NewInstance("Frame")({
					Name = GenerateString(),
					Size = UDim2.new(0, 2, 1, -20),
					Position = UDim2.new(0, 7, 0, 10),
					BackgroundColor3 = theme.Accent,
					BackgroundTransparency = 0.2,
					BorderSizePixel = 0,
					ZIndex = 8,
					Parent = sliderFrame,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(1, 0),
					Parent = sliderAccentStrip,
				})

				NewInstance("UIGradient")({
					Name = GenerateString(),
					Color = ColorSequence.new(theme.Accent, theme.AccentSoft),
					Rotation = 90,
					Parent = sliderAccentStrip,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(0, 11),
					Parent = sliderFrame,
				})

				NewInstance("UIStroke")({
					Name = GenerateString(),
					Color = theme.PanelStroke,
					Transparency = shiftTransparency(theme.PanelStrokeTransparency, -0.34),
					Thickness = 1.2,
					Parent = sliderFrame,
				})

				NewInstance("UIGradient")({
					Name = GenerateString(),
					Color = ColorSequence.new(shade(theme.PanelGradient[1], -22), shade(theme.PanelGradient[2], -4)),
					Rotation = 105,
					Parent = sliderFrame,
				})

				local titleLabel = NewInstance("TextLabel")({
					Name = "Title",
					Size = UDim2.new(0.44, -8, 1, 0),
					Position = UDim2.new(0, 15, 0, 0),
					BackgroundTransparency = 1,
					Text = config.text or "Slider",
					TextColor3 = theme.Text,
					TextSize = 13,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 5,
					Parent = sliderFrame,
				})

				local sliderArea = NewInstance("Frame")({
					Name = "SliderArea",
					Size = UDim2.new(0.56, -18, 1, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 5,
					Parent = sliderFrame,
				})

				local valueLabel = NewInstance("TextLabel")({
					Name = "Value",
					Size = UDim2.new(0, 56, 0, 22),
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					BackgroundTransparency = 1,
					Text = "",
					TextColor3 = theme.Accent,
					TextSize = 13,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = 6,
					Parent = sliderArea,
				})

				local valueChip = NewInstance("Frame")({
					Name = GenerateString(),
					Size = UDim2.new(0, 56, 0, 22),
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					BackgroundColor3 = shade(theme.BottomBar, -4),
					BackgroundTransparency = 0.02,
					BorderSizePixel = 0,
					ZIndex = 5,
					Parent = sliderArea,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(1, 0),
					Parent = valueChip,
				})

				local valueChipStroke = NewInstance("UIStroke")({
					Name = GenerateString(),
					Color = theme.PanelStroke,
					Transparency = 0.32,
					Thickness = 1,
					Parent = valueChip,
				})

				local trackBar = NewInstance("Frame")({
					Name = "Track",
					Size = UDim2.new(1, -70, 0, 6),
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 0, 0.5, 0),
					BackgroundColor3 = shade(theme.BottomBar, -8),
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					ZIndex = 6,
					Parent = sliderArea,
				})

				NewInstance("UIStroke")({
					Name = GenerateString(),
					Color = theme.PanelStroke,
					Transparency = 0.28,
					Thickness = 1,
					Parent = trackBar,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(1, 0),
					Parent = trackBar,
				})

				local fillBar = NewInstance("Frame")({
					Name = "Fill",
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundColor3 = theme.Accent,
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					ZIndex = 7,
					Parent = trackBar,
				})

				NewInstance("UIGradient")({
					Name = GenerateString(),
					Color = ColorSequence.new(theme.Accent, theme.AccentSoft),
					Rotation = 0,
					Parent = fillBar,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(1, 0),
					Parent = fillBar,
				})

				local knob = NewInstance("Frame")({
					Name = "Knob",
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, -9, 0.5, -9),
					BackgroundColor3 = shade(theme.Text, -6),
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					ZIndex = 8,
					Parent = trackBar,
				})

				local knobDot = NewInstance("Frame")({
					Name = "KnobDot",
					Size = UDim2.new(0, 8, 0, 8),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundColor3 = theme.Accent,
					BorderSizePixel = 0,
					ZIndex = 9,
					Parent = knob,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(1, 0),
					Parent = knobDot,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(1, 0),
					Parent = knob,
				})

				NewInstance("UIStroke")({
					Name = GenerateString(),
					Color = theme.Accent,
					Transparency = 0,
					Thickness = 1.8,
					Parent = knob,
				})

				track(sliderFrame.MouseEnter:Connect(function()
					Tween(sliderFrame, {BackgroundTransparency = 0}, 0.12):Play()
					Tween(knob, {Size = UDim2.new(0, 20, 0, 20)}, 0.12):Play()
					Tween(knobDot, {Size = UDim2.new(0, 9, 0, 9)}, 0.12):Play()
					titleLabel.TextColor3 = theme.Text
				end))

				track(sliderFrame.MouseLeave:Connect(function()
					Tween(sliderFrame, {BackgroundTransparency = 0.03}, 0.12):Play()
					Tween(knob, {Size = UDim2.new(0, 18, 0, 18)}, 0.12):Play()
					Tween(knobDot, {Size = UDim2.new(0, 8, 0, 8)}, 0.12):Play()
					titleLabel.TextColor3 = theme.Text
				end))

				local function normalize(value)
					if maximum == minimum then
						return 0
					end
					return math.clamp((value - minimum) / (maximum - minimum), 0, 1)
				end

				local function snapValue(value)
					local snapped = minimum + math.floor(((value - minimum) / increment) + 0.5) * increment
					return math.clamp(snapped, minimum, maximum)
				end

				local function setVisual(value)
					local alpha = normalize(value)
					Tween(fillBar, {Size = UDim2.new(alpha, 0, 1, 0)}, 0.08):Play()
					Tween(knob, {Position = UDim2.new(alpha, -9, 0.5, -9)}, 0.08):Play()
					valueLabel.Text = formatNumber(value, decimals) .. suffix
					local width = math.max(56, (#valueLabel.Text * 7) + 16)
					valueLabel.Size = UDim2.new(0, width, 0, 22)
					valueChip.Size = UDim2.new(0, width, 0, 22)
					valueChipStroke.Color = alpha > 0.01 and theme.Accent or theme.PanelStroke
				end

				local function updateValue(nextValue, shouldCallback)
					sliderValue = snapValue(tonumber(nextValue) or minimum)
					setVisual(sliderValue)
					setFlagValue(sliderFlag, sliderValue)

					if shouldCallback and type(config.callback) == "function" then
						task.spawn(config.callback, sliderValue)
					end
				end

				local function applyFromX(xPosition, shouldCallback)
					local absoluteWidth = trackBar.AbsoluteSize.X
					if absoluteWidth <= 0 then
						return
					end

					local relative = math.clamp((xPosition - trackBar.AbsolutePosition.X) / absoluteWidth, 0, 1)
					local mappedValue = minimum + (maximum - minimum) * relative
					updateValue(mappedValue, shouldCallback)
				end

				registerFlagBinding(sliderFlag, function(nextValue, runCallback)
					updateValue(nextValue, runCallback)
				end)

				sliderValue = snapValue(sliderValue)
				setVisual(sliderValue)
				setFlagValue(sliderFlag, sliderValue)

				if type(config.callback) == "function" then
					task.spawn(config.callback, sliderValue)
				end

				local dragging = false
				local activeInput = nil

				local function beginDrag(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
						return
					end

					dragging = true
					activeInput = input
					applyFromX(input.Position.X, true)
				end

				local function endDrag(input)
					if input == activeInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
						activeInput = nil
					end
				end

				track(trackBar.InputBegan:Connect(beginDrag))
				track(knob.InputBegan:Connect(beginDrag))

				track(trackBar.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						endDrag(input)
					end
				end))

				track(knob.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						endDrag(input)
					end
				end))

				track(UserInputService.InputChanged:Connect(function(input)
					if not dragging then
						return
					end

					if input.UserInputType == Enum.UserInputType.MouseMovement then
						applyFromX(input.Position.X, true)
					elseif input.UserInputType == Enum.UserInputType.Touch and input == activeInput then
						applyFromX(input.Position.X, true)
					end
				end))

				track(UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						endDrag(input)
					end
				end))

				return {
					Set = function(nextValue)
						updateValue(nextValue, true)
					end,
					Get = function()
						return sliderValue
					end,
					Frame = sliderFrame,
				}
			end

			function sectionWrapper:AddToggle(config)
				config = config or {}
				if type(config) ~= "table" then
					return nil
				end

				local toggleFlag = resolveFlagName(config.flag, config.text)
				local state = getFlagValue(toggleFlag, config.default) == true

				local toggleFrame = NewInstance("Frame")({
					Name = config.flag or config.text or "Toggle",
					Size = UDim2.new(1, -2, 0, 58),
					Position = UDim2.new(0, 1, 0, 0),
					BackgroundColor3 = shade(theme.PanelGradient[1], -10),
					BackgroundTransparency = 0.03,
					BorderSizePixel = 0,
					ZIndex = 7,
					Parent = sectionContent,
				})

				local toggleAccentStrip = NewInstance("Frame")({
					Name = GenerateString(),
					Size = UDim2.new(0, 2, 1, -20),
					Position = UDim2.new(0, 7, 0, 10),
					BackgroundColor3 = theme.Accent,
					BackgroundTransparency = 0.2,
					BorderSizePixel = 0,
					ZIndex = 8,
					Parent = toggleFrame,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(1, 0),
					Parent = toggleAccentStrip,
				})

				NewInstance("UIGradient")({
					Name = GenerateString(),
					Color = ColorSequence.new(theme.Accent, theme.AccentSoft),
					Rotation = 90,
					Parent = toggleAccentStrip,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(0, 11),
					Parent = toggleFrame,
				})

				NewInstance("UIStroke")({
					Name = GenerateString(),
					Color = theme.PanelStroke,
					Transparency = shiftTransparency(theme.PanelStrokeTransparency, -0.32),
					Thickness = 1.2,
					Parent = toggleFrame,
				})

				NewInstance("UIGradient")({
					Name = GenerateString(),
					Color = ColorSequence.new(shade(theme.PanelGradient[1], -22), shade(theme.PanelGradient[2], -4)),
					Rotation = 105,
					Parent = toggleFrame,
				})

				local titleLabel = NewInstance("TextLabel")({
					Name = "Title",
					Size = UDim2.new(0.7, -8, 1, 0),
					Position = UDim2.new(0, 15, 0, 0),
					BackgroundTransparency = 1,
					Text = config.text or "Toggle",
					TextColor3 = theme.SubText,
					TextSize = 13,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 5,
					Parent = toggleFrame,
				})

				local toggleButton = NewInstance("TextButton")({
					Name = "Switch",
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -12, 0.5, 0),
					Size = UDim2.new(0, 54, 0, 28),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
					BorderSizePixel = 0,
					ZIndex = 6,
					Parent = toggleFrame,
				})

				local switchTrack = NewInstance("Frame")({
					Name = "Track",
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = shade(theme.BottomBar, -8),
					BackgroundTransparency = 0.04,
					BorderSizePixel = 0,
					ZIndex = 6,
					Parent = toggleButton,
				})

				local switchGlow = NewInstance("Frame")({
					Name = GenerateString(),
					Size = UDim2.new(1, 8, 1, 8),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundColor3 = theme.Accent,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 5,
					Parent = toggleButton,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(1, 0),
					Parent = switchGlow,
				})

				NewInstance("UIStroke")({
					Name = GenerateString(),
					Color = theme.PanelStroke,
					Transparency = 0.3,
					Thickness = 1,
					Parent = switchTrack,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(1, 0),
					Parent = switchTrack,
				})

				local switchKnob = NewInstance("Frame")({
					Name = "Knob",
					Size = UDim2.new(0, 22, 0, 22),
					Position = UDim2.new(0, 3, 0.5, -11),
					BackgroundColor3 = shade(theme.Text, -6),
					BorderSizePixel = 0,
					ZIndex = 7,
					Parent = toggleButton,
				})

				NewInstance("UICorner")({
					Name = GenerateString(),
					CornerRadius = UDim.new(1, 0),
					Parent = switchKnob,
				})

				NewInstance("UIStroke")({
					Name = GenerateString(),
					Color = theme.Accent,
					Transparency = 0.1,
					Thickness = 1.4,
					Parent = switchKnob,
				})

				local function renderToggle(playTween)
					local trackColor = state and shade(theme.AccentSoft, 6) or shade(theme.BottomBar, -8)
					local knobGoal = state and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
					local glowTransparency = state and 0.78 or 1

					if playTween then
						Tween(switchTrack, {
							BackgroundColor3 = trackColor,
							BackgroundTransparency = state and 0.0 or 0.04,
						}, 0.14):Play()
						Tween(switchKnob, {Position = knobGoal}, 0.14):Play()
						Tween(switchGlow, {BackgroundTransparency = glowTransparency}, 0.14):Play()
					else
						switchTrack.BackgroundColor3 = trackColor
						switchTrack.BackgroundTransparency = state and 0.0 or 0.04
						switchKnob.Position = knobGoal
						switchGlow.BackgroundTransparency = glowTransparency
					end

					titleLabel.TextColor3 = state and theme.Text or theme.SubText
					setFlagValue(toggleFlag, state)
				end

				local function setToggle(nextState, runCallback)
					state = nextState == true
					renderToggle(true)
					if runCallback and type(config.callback) == "function" then
						task.spawn(config.callback, state)
					end
				end

				registerFlagBinding(toggleFlag, function(nextValue, runCallback)
					setToggle(nextValue, runCallback)
				end)

				renderToggle(false)
				if type(config.callback) == "function" then
					task.spawn(config.callback, state)
				end

				track(toggleButton.MouseButton1Click:Connect(function()
					setToggle(not state, true)
				end))

				return {
					Set = function(nextState)
						setToggle(nextState, true)
					end,
					Toggle = function()
						setToggle(not state, true)
					end,
					Get = function()
						return state
					end,
					Frame = toggleFrame,
				}
			end

			function sectionWrapper:Addslider(config)
				return self:AddSlider(config)
			end

			function sectionWrapper:Addtoggle(config)
				return self:AddToggle(config)
			end

			function sectionWrapper:Addbutton(config)
				return self:AddButton(config)
			end

			function sectionWrapper:Adddropdown(config)
				return self:AddDropdown(config)
			end

			function sectionWrapper:Addkeybind(config)
				return self:AddKeybind(config)
			end

			function sectionWrapper:Addlabel(config)
				return self:AddLabel(config)
			end

			function sectionWrapper:Addparagraph(config)
				return self:AddParagraph(config)
			end

			setmetatable(sectionWrapper, {
				__index = function(t, k)
					if k == "AddSlider" or k == "Addslider"
						or k == "AddToggle" or k == "Addtoggle"
						or k == "AddButton" or k == "Addbutton"
						or k == "AddDropdown" or k == "Adddropdown"
						or k == "AddKeybind" or k == "Addkeybind"
						or k == "AddLabel" or k == "Addlabel"
						or k == "AddParagraph" or k == "Addparagraph"
						or k == "_frame" then
						return rawget(t, k)
					end
					return sectionContent[k]
				end,
				__newindex = function(t, k, v)
					if k == "_frame" then
						rawset(t, k, v)
					else
						sectionContent[k] = v
					end
				end,
			})

			return sectionWrapper
		end
		setmetatable(contentWrapper, {
			__index = function(t, k)
				if k == "AddSection" or k == "_frame" then
					return rawget(t, k)
				end
				return contentFrame[k]
			end,
			__newindex = function(t, k, v)
				if k == "_frame" then
					rawset(t, k, v)
				else
					contentFrame[k] = v
				end
			end
		})
		tabs[tabName] = {
			Button = tabButton,
			Pill = tabPill,
			PillStroke = tabPillStroke,
			Container = tabContainer,
			Title = tabTitle,
			Content = contentFrame,
			Icon = tabIcon,
			Indicator = tabIndicator,
		}
		tabButton.MouseButton1Click:Connect(function()
			selectTab(tabName)
		end)
		if selectedTabName == nil then
			selectTab(tabName)
		end

		return contentWrapper
	end

	selectTab = function(selfOrTabName, optionalTabName)
		local tabName = selfOrTabName
		if type(selfOrTabName) == "table" and (selfOrTabName.Notify or selfOrTabName.Gui) then
			tabName = optionalTabName
		end

		if type(tabName) ~= "string" then
			return
		end

		if not tabs[tabName] or isTabAnimating then
			return
		end

		local oldTabName = selectedTabName
		local isFirstTab = oldTabName == nil

		if not isFirstTab then
			isTabAnimating = true
		end

		selectedTabName = tabName
		if oldTabName and tabs[oldTabName] then
			local oldContent = tabs[oldTabName].Content
			local oldIndicator = tabs[oldTabName].Indicator
			local oldTitle = tabs[oldTabName].Title
			local oldPill = tabs[oldTabName].Pill
			local oldPillStroke = tabs[oldTabName].PillStroke

			oldTitle.TextColor3 = theme.SubText
			Tween(oldPill, {BackgroundTransparency = 0.82}, 0.14):Play()
			Tween(oldPillStroke, {Transparency = 0.76}, 0.14):Play()
			Tween(oldIndicator, {Size = UDim2.new(0, 0, 0, 2)}, 0.15):Play()

			Tween(oldContent, {Position = UDim2.new(0, 1920, 0, 0)}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()

			task.wait(0.02)
			oldContent.Visible = false
		end
		local newTab = tabs[tabName]
		local newContent = newTab.Content
		local newIndicator = newTab.Indicator
		local newTitle = newTab.Title
		local newPill = newTab.Pill
		local newPillStroke = newTab.PillStroke

		newContent.Visible = true
		newTitle.TextColor3 = theme.Text
		Tween(newPill, {BackgroundTransparency = 0.54}, 0.16):Play()
		Tween(newPillStroke, {Transparency = 0.2}, 0.16):Play()
		newIndicator.Visible = true

		if isFirstTab then
			newContent.Position = UDim2.new(0, 0, 0, 0)
			newIndicator.Size = UDim2.new(0.6, 0, 0, 2)
		else
			newContent.Position = UDim2.new(0, -1920, 0, 0)
			Tween(newContent, {Position = UDim2.new(0, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()

			task.delay(0.05, function()
				Tween(newIndicator, {Size = UDim2.new(0.6, 0, 0, 2)}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
			end)

			task.delay(0.22, function()
				isTabAnimating = false
			end)
		end
	end

	local function getTabContent(selfOrTabName, optionalTabName)
		local tabName = selfOrTabName
		if type(selfOrTabName) == "table" and (selfOrTabName.Notify or selfOrTabName.Gui) then
			tabName = optionalTabName
		end

		if type(tabName) ~= "string" then
			return nil
		end

		if tabs[tabName] then
			return tabs[tabName].Content
		end
		return nil
	end

	local function getSectionContent(selfOrTabName, arg2, arg3)
		local tabName, sectionName
		if type(selfOrTabName) == "table" and (selfOrTabName.Notify or selfOrTabName.Gui) then
			tabName = arg2
			sectionName = arg3
		else
			tabName = selfOrTabName
			sectionName = arg2
		end

		if type(tabName) ~= "string" or type(sectionName) ~= "string" then
			return nil
		end

		if not tabs[tabName] then
			return nil
		end

		local tabContent = tabs[tabName].Content
		local panelWrapper = tabContent:FindFirstChild("_PanelWrapper")

		if panelWrapper then
			local section = panelWrapper:FindFirstChild("Section_" .. sectionName)
			if section then
				return section:FindFirstChild("Content")
			end
		end

		return nil
	end

	notify = function(payloadOrSelf, optionalPayload)
		local payload = optionalPayload
		if payload == nil then
			if type(payloadOrSelf) == "table" and (payloadOrSelf.Message or payloadOrSelf.Text or payloadOrSelf.Title or payloadOrSelf.Image or payloadOrSelf.Icon or payloadOrSelf.Duration) then
				payload = payloadOrSelf
			else
				payload = {}
			end
		end

		payload = payload or {}
		if type(payload) == "string" then
			payload = {Message = payload}
		end

		notificationCounter = notificationCounter + 1

		local title = tostring(payload.Title or settings.Title or "Nebularity")
		local message = tostring(payload.Message or payload.Text or "Notification")
		local duration = math.clamp(tonumber(payload.Duration) or notifyDefaults.Duration, 0.8, 15)
		local maxVisible = math.clamp(math.floor(tonumber(payload.MaxVisible) or notifyDefaults.MaxVisible), 1, 8)
		local imageRequest = payload.Image or payload.Icon
		local imageCandidates = {}
		if type(imageRequest) == "string" or type(imageRequest) == "number" then
			local rawImage = tostring(imageRequest)
			if rawImage ~= "" then
				if string.find(rawImage, "rbxassetid://", 1, true) or string.find(rawImage, "rbxthumb://", 1, true) or string.find(rawImage, "http://", 1, true) or string.find(rawImage, "https://", 1, true) then
					table.insert(imageCandidates, rawImage)
				else
					local numericId = rawImage:gsub("%D", "")
					if numericId ~= "" then
						table.insert(imageCandidates, "rbxassetid://" .. numericId)
						table.insert(imageCandidates, "http://www.roblox.com/asset/?id=" .. numericId)
						table.insert(imageCandidates, "rbxthumb://type=Asset&id=" .. numericId .. "&w=420&h=420")
					end
				end
			end
		end
		local hasImage = #imageCandidates > 0

		local charCount = utf8.len(message) or #message
		local lineCount = math.clamp(math.ceil(charCount / 42), 1, 3)
		local messageHeight = 14 * lineCount
		local targetHeight = math.max(44 + messageHeight + 16, hasImage and 64 or 0)

		local card = NewInstance("Frame")({
			Name = "NotificationCard",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.None,
			BackgroundColor3 = theme.BottomBar,
			BackgroundTransparency = 0.06,
			BorderSizePixel = 0,
			LayoutOrder = notificationCounter,
			ZIndex = 51,
			Parent = NotifyList,
		})

		NewInstance("UICorner")({
			Name = GenerateString(),
			CornerRadius = UDim.new(0, 12),
			Parent = card,
		})

		NewInstance("UIStroke")({
			Name = GenerateString(),
			Color = theme.PanelStroke,
			Transparency = shiftTransparency(theme.PanelStrokeTransparency, 0.12),
			Thickness = 1,
			Parent = card,
		})

		local accentBar = NewInstance("Frame")({
			Name = GenerateString(),
			Size = UDim2.new(0, 3, 0, math.max(targetHeight - 24, 22)),
			Position = UDim2.new(0, 8, 0, 10),
			BackgroundColor3 = theme.Accent,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			ZIndex = 52,
			Parent = card,
		})

		NewInstance("UICorner")({
			Name = GenerateString(),
			CornerRadius = UDim.new(1, 0),
			Parent = accentBar,
		})

		local textStartX = 18
		if hasImage then
			local iconImage = NewInstance("ImageLabel")({
				Name = "NotifyImage",
				Size = UDim2.new(0, 34, 0, 34),
				Position = UDim2.new(0, 18, 0, 9),
				BackgroundColor3 = theme.AccentSoft,
				BackgroundTransparency = 0.2,
				BorderSizePixel = 0,
				Image = imageCandidates[1],
				ImageTransparency = 0,
				ScaleType = Enum.ScaleType.Fit,
				ZIndex = 53,
				Parent = card,
			})

			NewInstance("UICorner")({
				Name = GenerateString(),
				CornerRadius = UDim.new(0, 8),
				Parent = iconImage,
			})

			NewInstance("UIStroke")({
				Name = GenerateString(),
				Color = theme.Accent,
				Transparency = 0.55,
				Thickness = 1,
				Parent = iconImage,
			})

			task.spawn(function()
				local contentProvider = game:GetService("ContentProvider")

				for _, candidate in ipairs(imageCandidates) do
					print("Teste Bild:", candidate)

					iconImage.Image = candidate

					local success, err = pcall(function()
						contentProvider:PreloadAsync({iconImage})
					end)

					print("Preload success:", success, err)
					print("Image nach Setzen:", iconImage.Image)

					task.wait(0.2)

					local status = contentProvider:GetAssetFetchStatus(candidate)
					print("FetchStatus:", status.Name)
				end

				Tween(iconImage, {ImageTransparency = 0}, 0.12):Play()
			end)

			textStartX = 58
		end

		NewInstance("TextLabel")({
			Name = "Title",
			Text = title,
			Size = UDim2.new(1, -(textStartX + 8), 0, 18),
			Position = UDim2.new(0, textStartX, 0, 6),
			BackgroundTransparency = 1,
			TextColor3 = theme.Text,
			TextSize = 14,
			Font = Enum.Font.GothamSemibold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 52,
			Parent = card,
		})

		NewInstance("TextLabel")({
			Name = "Message",
			Text = message,
			Size = UDim2.new(1, -(textStartX + 8), 0, messageHeight),
			Position = UDim2.new(0, textStartX, 0, 24),
			BackgroundTransparency = 1,
			TextColor3 = theme.SubText,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 52,
			Parent = card,
		})

		local progressTrack = NewInstance("Frame")({
			Name = GenerateString(),
			Size = UDim2.new(1, -22, 0, 2),
			Position = UDim2.new(0, 11, 1, -7),
			BackgroundColor3 = theme.AccentSoft,
			BackgroundTransparency = 0.75,
			BorderSizePixel = 0,
			ZIndex = 52,
			Parent = card,
		})

		NewInstance("UICorner")({
			Name = GenerateString(),
			CornerRadius = UDim.new(1, 0),
			Parent = progressTrack,
		})

		local progressFill = NewInstance("Frame")({
			Name = GenerateString(),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = theme.Accent,
			BackgroundTransparency = 0.08,
			BorderSizePixel = 0,
			ZIndex = 53,
			Parent = progressTrack,
		})

		NewInstance("UICorner")({
			Name = GenerateString(),
			CornerRadius = UDim.new(1, 0),
			Parent = progressFill,
		})

		local fadeTargets = CollectTransparencyTargets(card)
		ApplyTransparency(fadeTargets, 1)
		Tween(card, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.18):Play()
		TweenTransparency(fadeTargets, 0, 0.18)

		Tween(progressFill, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear):Play()

		local removed = false
		local function removeCard(speed)
			if removed or not card.Parent then
				return
			end
			removed = true

			for index = #notifications, 1, -1 do
				if notifications[index] == card then
					table.remove(notifications, index)
					break
				end
			end

			local outTime = speed or 0.16
			TweenTransparency(fadeTargets, 1, outTime)
			Tween(card, {Size = UDim2.new(1, 0, 0, 0)}, outTime):Play()
			task.delay(outTime + 0.02, function()
				if card then
					card:Destroy()
				end
			end)
		end

		table.insert(notifications, card)
		while #notifications > maxVisible do
			local oldest = table.remove(notifications, 1)
			if oldest and oldest.Parent then
				local oldestTargets = CollectTransparencyTargets(oldest)
				TweenTransparency(oldestTargets, 1, 0.1)
				Tween(oldest, {Size = UDim2.new(1, 0, 0, 0)}, 0.1):Play()
				task.delay(0.12, function()
					if oldest then
						oldest:Destroy()
					end
				end)
			end
		end

		task.delay(duration, function()
			removeCard(0.16)
		end)

		local soundRequest = payload.Sound
		local shouldPlaySound = soundRequest ~= false
		local requestedSoundId = notifyDefaults.SoundId
		local requestedVolume = notifyDefaults.SoundVolume
		local requestedSpeed = notifyDefaults.SoundPlaybackSpeed

		if type(soundRequest) == "string" or type(soundRequest) == "number" then
			requestedSoundId = soundRequest
		elseif type(soundRequest) == "table" then
			if soundRequest.Enabled == false then
				shouldPlaySound = false
			end
			requestedSoundId = soundRequest.SoundId or soundRequest.Id or requestedSoundId
			requestedVolume = tonumber(soundRequest.Volume) or requestedVolume
			requestedSpeed = tonumber(soundRequest.PlaybackSpeed) or requestedSpeed
		end

		if shouldPlaySound and requestedSoundId then
			local soundIdString = tostring(requestedSoundId)
			if not string.find(soundIdString, "rbxassetid://", 1, true) then
				soundIdString = "rbxassetid://" .. soundIdString:gsub("%D", "")
			end

			if soundIdString ~= "rbxassetid://" then
				local sound = NewInstance("Sound", SoundService)({
					Name = GenerateString(),
					SoundId = soundIdString,
					Volume = math.clamp(requestedVolume, 0, 4),
					PlaybackSpeed = math.clamp(requestedSpeed, 0.5, 2),
				})
				sound:Play()
				task.delay(4, function()
					if sound then
						sound:Destroy()
					end
				end)
			end
		end

		return {
			Close = removeCard,
			Frame = card,
		}
	end

	local function updateResponsiveScale()
		local camera = Workspace.CurrentCamera
		local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
		local baseWidth = normalSize.X.Offset > 0 and normalSize.X.Offset or 1023
		local baseHeight = normalSize.Y.Offset > 0 and normalSize.Y.Offset or 471
		local widthScale = viewport.X / (baseWidth + 120)
		local heightScale = viewport.Y / (baseHeight + 160)
		PanelScale.Scale = math.clamp(math.min(widthScale, heightScale), 0.72, 1)
	end

	updateResponsiveScale()
	if Workspace.CurrentCamera then
		track(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale))
	end
	track(Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		updateResponsiveScale()
		if Workspace.CurrentCamera then
			track(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale))
		end
	end))

	local dragging = false
	local dragStart
	local dragOrigin

	local function beginDrag(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		dragging = true
		dragStart = input.Position
		dragOrigin = Panel.Position
	end

	for _, dragObject in ipairs({MainSteering, TitleLabel, SubTitleLabel, PlayerFaceImage, AccentLine}) do
		track(dragObject.InputBegan:Connect(beginDrag))
	end

	track(UserInputService.InputChanged:Connect(function(input)
		if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end

		local delta = input.Position - dragStart
		Panel.Position = UDim2.new(
			dragOrigin.X.Scale,
			dragOrigin.X.Offset + delta.X,
			dragOrigin.Y.Scale,
			dragOrigin.Y.Offset + delta.Y
		)
	end))

	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end))

	local function setNormalTitleLayout()
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		Tween(TitleLabel, {
			Position = normalTitlePosition,
			Size = normalTitleSize,
			TextSize = 20,
		}, 0.2):Play()
	end

	local function setCompactTitleLayout()
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		Tween(TitleLabel, {
			Position = compactTitlePosition,
			Size = compactTitleSize,
			TextSize = 18,
		}, 0.2):Play()
	end

	local function primeClosedState()
		ApplyTransparency(panelFadeTargets, 1)
		Panel.Size = UDim2.new(normalSize.X.Scale, math.max(normalSize.X.Offset - 32, 0), normalSize.Y.Scale, math.max(normalSize.Y.Offset - 24, 0))
		Panel.Position = UDim2.new(normalPosition.X.Scale, normalPosition.X.Offset, normalPosition.Y.Scale, normalPosition.Y.Offset + 18)
		MainSteering.Size = UDim2.new(1, -34, 0, normalBarHeight)
		MainSteering.Position = UDim2.new(0.5, 0, 1, -normalBarInset)
		ContentContainer.Visible = true
		SetObjectsVisible(steeringCompactObjects, true)
		ApplyTransparency(contentFadeTargets, 0)
		ApplyTransparency(steeringFadeTargets, 0)
		TitleLabel.Position = normalTitlePosition
		TitleLabel.Size = normalTitleSize
		TitleLabel.TextSize = 20
	end

	local function animateOpen()
		if isAnimating then
			return
		end

		isAnimating = true
		mainGui.Enabled = true
		Panel.Visible = true
		TweenTransparency(panelFadeTargets, 0, 0.22)
		Tween(Panel, {Size = normalSize, Position = normalPosition}, 0.22):Play()
		task.delay(0.24, function()
			isAnimating = false
		end)
	end

	local function applyMinimizeState()
		if isAnimating then
			return
		end

		isAnimating = true
		if isMinimized then
			TweenTransparency(contentFadeTargets, 1, 0.16)
			TweenTransparency(steeringFadeTargets, 1, 0.14)
			setCompactTitleLayout()
			Tween(MainSteering, {
				Size = UDim2.new(1, -16, 0, minimizedBarHeight),
				Position = UDim2.new(0.5, 0, 1, -minimizedBarInset),
			}, 0.22):Play()
			local shrinkTween = Tween(Panel, {Size = minimizedSize}, 0.22)
			shrinkTween:Play()
			task.delay(0.14, function()
				ContentContainer.Visible = false
				SetObjectsVisible(steeringCompactObjects, false)
			end)
			task.delay(0.24, function()
				isAnimating = false
			end)
		else
			ContentContainer.Visible = true
			SetObjectsVisible(steeringCompactObjects, true)
			ApplyTransparency(contentFadeTargets, 1)
			ApplyTransparency(steeringFadeTargets, 1)
			setNormalTitleLayout()
			Tween(MainSteering, {
				Size = UDim2.new(1, -34, 0, normalBarHeight),
				Position = UDim2.new(0.5, 0, 1, -normalBarInset),
			}, 0.22):Play()
			Tween(Panel, {Size = normalSize}, 0.22):Play()
			task.delay(0.06, function()
				TweenTransparency(contentFadeTargets, 0, 0.18)
				TweenTransparency(steeringFadeTargets, 0, 0.18)
			end)
			task.delay(0.24, function()
				isAnimating = false
			end)
		end
	end

	local function animateClose()
		if isAnimating then
			return
		end

		isAnimating = true
		TweenTransparency(panelFadeTargets, 1, 0.18)
		Tween(
			Panel,
			{
				Size = UDim2.new(normalSize.X.Scale, math.max(normalSize.X.Offset - 36, 0), normalSize.Y.Scale, math.max(normalSize.Y.Offset - 24, 0)),
				Position = UDim2.new(normalPosition.X.Scale, normalPosition.X.Offset, normalPosition.Y.Scale, normalPosition.Y.Offset + 14),
			},
			0.18
		):Play()

		task.delay(0.2, function()
			mainGui.Enabled = false
			isAnimating = false
		end)
	end

	MinimizeButton.Button.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		MinimizeButton:SetText(isMinimized and "+" or "-")
		applyMinimizeState()
	end)

	CloseButton.Button.MouseButton1Click:Connect(function()
		animateClose()
	end)

	if localPlayer then
		local ok, thumb = pcall(function()
			return players:GetUserThumbnailAsync(
				localPlayer.UserId,
				Enum.ThumbnailType.AvatarBust,
				Enum.ThumbnailSize.Size420x420
			)
		end)

		if ok and thumb then
			PlayerFaceImage.Image = thumb
		end
	end

	primeClosedState()
	animateOpen()

	task.defer(function()
		if hasFileApi() and isfile(configPath(configFileName)) then
			local ok, result = loadConfig(configFileName)
			if ok and type(notify) == "function" then
				notify({
					Title = "Config",
					Message = "Settings automatisch geladen: " .. tostring(configFileName),
					Duration = 3,
				})
			end
		end
	end)

	return {
		Gui = mainGui,
		Panel = Panel,
		ContentContainer = ContentContainer,
		MainSteering = MainSteering,
		PlayerFaceImage = PlayerFaceImage,
		AccentLine = AccentLine,
		TitleLabel = TitleLabel,
		SubTitleLabel = SubTitleLabel,
		TabsHolder = TabsHolder,
		TabsScrolling = TabsScrolling,
		WindowControls = WindowControls,
		MinimizeButton = MinimizeButton,
		Show = animateOpen,
		Hide = animateClose,
		Notify = notify,
		AddTab = addTab,
		SelectTab = selectTab,
		GetTabContent = getTabContent,
		GetSectionContent = getSectionContent,
		Flags = flags,
		GetFlag = function(_, flagName, defaultValue)
			return getFlagValue(flagName, defaultValue)
		end,
		SetFlag = function(_, flagName, value)
			setFlagAndSync(flagName, value, true)
		end,
		SaveConfig = function(_, name)
			local ok, result = saveConfig(name)
			if not ok and type(notify) == "function" then
				notify({Title = "Config", Message = "Save failed: " .. tostring(result), Duration = 4})
			elseif ok and type(notify) == "function" then
				notify({Title = "Config", Message = "Saved: " .. tostring(name or configFileName), Duration = 3})
			end
			return ok, result
		end,
		LoadConfig = function(_, name)
			local ok, result = loadConfig(name)
			if not ok and type(notify) == "function" then
				notify({Title = "Config", Message = "Load failed: " .. tostring(result), Duration = 4})
			elseif ok and type(notify) == "function" then
				notify({Title = "Config", Message = "Loaded: " .. tostring(name or configFileName), Duration = 3})
			end
			return ok, result
		end,
		DeleteConfig = function(_, name)
			local ok, result = deleteConfig(name)
			if not ok and type(notify) == "function" then
				notify({Title = "Config", Message = "Delete failed: " .. tostring(result), Duration = 4})
			elseif ok and type(notify) == "function" then
				notify({Title = "Config", Message = "Deleted: " .. tostring(name or configFileName), Duration = 3})
			end
			return ok, result
		end,
		ListConfigs = function()
			return listConfigs()
		end,
		Config = {
			Available = hasFileApi,
			Save = saveConfig,
			Load = loadConfig,
			Delete = deleteConfig,
			List = listConfigs,
		},
		AddPreset = function(self, presetName, presetUrl)
			local ok, result = addTypedPreset(presetName, presetUrl, "auto")
			if type(notify) == "function" then
				if ok then
					notify({Title = "Preset", Message = "Added: " .. tostring(result), Duration = 3})
				else
					notify({Title = "Preset", Message = "Add failed: " .. tostring(result), Duration = 4})
				end
			end
			return ok, result
		end,
		AddPresetJson = function(self, presetName, presetUrl)
			local ok, result = addTypedPreset(presetName, presetUrl, "json")
			if type(notify) == "function" then
				if ok then
					notify({Title = "Preset", Message = "JSON added: " .. tostring(result), Duration = 3})
				else
					notify({Title = "Preset", Message = "JSON add failed: " .. tostring(result), Duration = 4})
				end
			end
			return ok, result
		end,
		LoadPreset = function(self, presetName, runtimeContext)
			local context = runtimeContext
			if type(context) ~= "table" then
				context = {
					UI = self,
					Flags = flags,
					SetFlag = function(flagName, value)
						setFlagAndSync(flagName, value, true)
					end,
					GetFlag = function(flagName, defaultValue)
						return getFlagValue(flagName, defaultValue)
					end,
					Notify = function(payload)
						if type(notify) == "function" then
							notify(payload)
						end
					end,
				}
			end

			local ok, result = loadPreset(presetName, context)
			if type(notify) == "function" then
				if ok then
					notify({Title = "Preset", Message = "Loaded: " .. tostring(result), Duration = 3})
				else
					notify({Title = "Preset", Message = "Load failed: " .. tostring(result), Duration = 4})
				end
			end
			return ok, result
		end,
		LoadPresetJson = function(self, presetName)
			local ok, result = loadPresetJson(presetName)
			if type(notify) == "function" then
				if ok then
					notify({Title = "Preset", Message = "JSON loaded: " .. tostring(presetName), Duration = 3})
				else
					notify({Title = "Preset", Message = "JSON load failed: " .. tostring(result), Duration = 4})
				end
			end
			return ok, result
		end,
		RemovePreset = function(self, presetName)
			local ok, result = removePreset(presetName)
			if type(notify) == "function" then
				if ok then
					notify({Title = "Preset", Message = "Removed: " .. tostring(result), Duration = 3})
				else
					notify({Title = "Preset", Message = "Remove failed: " .. tostring(result), Duration = 4})
				end
			end
			return ok, result
		end,
		ListPresets = function()
			return listPresets()
		end,
		Presets = {
			Add = addTypedPreset,
			AddJson = function(name, url)
				return addTypedPreset(name, url, "json")
			end,
			Load = loadPreset,
			LoadJson = loadPresetJson,
			Remove = removePreset,
			List = listPresets,
		},
		SetTheme = function(_, themeName)
			local ok, themeResult = applyThemeByName(themeName)
			if type(notify) == "function" then
				if ok then
					notify({Title = "Theme", Message = "Applied: " .. tostring(themeResult), Duration = 2})
				else
					notify({Title = "Theme", Message = "Failed to apply theme.", Duration = 3})
				end
			end
			return ok, themeResult
		end,
		GetThemeName = function()
			return resolvedThemeName
		end,
		Destroy = function()
			for _, connection in ipairs(connections) do
				pcall(function()
					connection:Disconnect()
				end)
			end
			mainGui:Destroy()
		end,
		CloseButton = CloseButton,
		Theme = resolvedThemeName,
		ThemeData = theme,
	}
end

return NebularityUI
