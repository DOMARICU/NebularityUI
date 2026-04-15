# Nebularity UI Library

> Practical reference for uinew.lua.
> Built for fast integration without trial-and-error.

---

## What Is This?

NebularityUI is a Roblox UI library with:

- Tab system
- Section system (max 3 sections per tab)
- Controls (Toggle, Slider, Dropdown, Keybind, Button, Label, Paragraph)
- Flag binding (UI <-> script state)
- JSON config save/load
- Preset system (remote JSON and optional script presets)
- Live theme switching
- Built-in notifications

Main file: uinew.lua

---

## Quick Start

```lua
local NebularityUI = loadfile("SniperDuels/uinew.lua")()

local ui = NebularityUI:CreateUI({
    Theme = "Nebula",
    Title = "Nebularity",
    SubTitle = "v2.0",
    Flags = {
        aimbot = false,
        fov = 180,
    },
    ConfigFolder = "NebularityConfigs",
    ConfigName = "default",
})

local combatTab = ui:AddTab("Combat")
local sec = combatTab:AddSection("Aimbot", "CORE")

sec:AddToggle({
    text = "Enable Aimbot",
    flag = "aimbot",
    default = false,
    callback = function(v)
        print("Aimbot:", v)
    end,
})

sec:AddSlider({
    text = "FOV",
    flag = "fov",
    min = 20,
    max = 400,
    inc = 5,
    default = 180,
    callback = function(v)
        print("FOV:", v)
    end,
})
```

---

## Table Of Contents

1. [CreateUI Settings](#createui-settings)
2. [UI Object API](#ui-object-api)
3. [Tab And Section API](#tab-and-section-api)
4. [Control API](#control-api)
5. [Flags And Binding Behavior](#flags-and-binding-behavior)
6. [Config API](#config-api)
7. [Preset API](#preset-api)
8. [Theme API](#theme-api)
9. [Notification API](#notification-api)
10. [Best Practices](#best-practices)

---

## CreateUI Settings

```lua
local ui = NebularityUI:CreateUI(settings)
```

### Core Settings

| Key | Type | Default | Description |
|---|---|---|---|
| Theme | string | "Nebula" | Initial theme (Nebula, Crimson, Emerald) |
| Title | string | "Nebularity" | Bottom bar title |
| SubTitle | string | LocalPlayer.Name | Bottom bar subtitle |
| Flags | table | {} | Initial flag values |
| Position | UDim2 | UDim2.new(0.5,0,0.5,0) | Initial panel position |
| Size | UDim2 | UDim2.new(0,1023,0,471) | Default panel size |

### Layout And Minimize

| Key | Type | Default |
|---|---|---|
| BottomBarHeight | number | 64 |
| MinimizedBarHeight | number | 46 |
| BottomBarInset | number | 10 |
| MinimizedBarInset | number | 10 |
| MinimizedWidth | number | auto-calculated |
| MinimizedSize | UDim2 | auto-calculated |

### Notification Defaults

| Key | Type | Default |
|---|---|---|
| NotifyDuration | number | 3 |
| NotifyMaxVisible | number | 5 |
| NotifySoundId | string/number | nil |
| NotifySoundVolume | number | 0.35 |
| NotifySoundPlaybackSpeed | number | 1 |

### Config Defaults

| Key | Type | Default |
|---|---|---|
| ConfigFolder | string | "NebularityConfigs" |
| ConfigName | string | "default" |

### Register Presets On Startup

settings.Presets supports:

```lua
Presets = {
    Legit = "https://host/presets/legit.json", -- auto

    {
        Name = "Rage",
        Url = "https://host/presets/rage.json",
        Type = "json", -- json | script | auto
    }
}
```

---

## UI Object API

CreateUI returns a UI object with fields and methods.

### Important Fields

| Field | Type | Purpose |
|---|---|---|
| Gui | ScreenGui | Root GUI object |
| Panel | Frame | Main panel |
| Flags | table | Current flag state store |
| Theme | string | Active theme name |
| ThemeData | table | Active theme data |

### Core Methods

| Method | Signature | Description |
|---|---|---|
| Show | ui:Show() | Opens the UI with animation |
| Hide | ui:Hide() | Closes the UI with animation |
| Destroy | ui:Destroy() | Disconnects events and destroys GUI |
| Notify | ui:Notify(payload) | Shows a notification |
| AddTab | ui:AddTab(name, icon?) | Creates a tab |
| SelectTab | ui:SelectTab(name) | Selects a tab |
| GetTabContent | ui:GetTabContent(tabName) | Returns tab content frame |
| GetSectionContent | ui:GetSectionContent(tabName, sectionName) | Returns section content frame |
| GetFlag | ui:GetFlag(name, default?) | Reads flag value |
| SetFlag | ui:SetFlag(name, value) | Sets flag and syncs bound controls |

---

## Tab And Section API

### Create Tab

```lua
local tab = ui:AddTab("Visual", "rbxassetid://123456")
```

- name is required (string)
- icon is optional (string)
- duplicate tab names are rejected

### Create Section

```lua
local section = tab:AddSection("ESP", "VISION")
```

- sectionName is required
- sectioninfo is optional (right-side badge)
- maximum of 3 sections per tab

---

## Control API

All controls are created on a section object.

### Toggle

```lua
local t = section:AddToggle({
    text = "Enabled",
    flag = "enabled",
    default = false,
    callback = function(v) end,
})
```

Config keys:

| Key | Type | Required |
|---|---|---|
| text | string | no |
| flag | string | recommended |
| default | boolean | no |
| callback | function(value:boolean) | no |

Return API:

- t:Set(boolean)
- t:Toggle()
- t:Get()
- t.Frame

---

### Slider

```lua
local s = section:AddSlider({
    text = "FOV",
    flag = "fov",
    min = 20,
    max = 400,
    inc = 5,
    default = 180,
    suffix = "px",
    callback = function(v) end,
})
```

Config keys:

| Key | Type | Default |
|---|---|---|
| text | string | "Slider" |
| flag | string | derived from text |
| min | number | 0 |
| max | number | 100 |
| inc / step | number | 1 |
| decimals | number | auto |
| default | number | min |
| suffix | string | "" |
| callback | function(value:number) | nil |

Return API:

- s:Set(number)
- s:Get()
- s.Frame

---

### Dropdown

```lua
local d = section:AddDropdown({
    text = "Target Part",
    flag = "target_part",
    options = {"Head", "UpperTorso"},
    default = "Head",
    callback = function(v) end,
})
```

Multi-select:

```lua
actions:AddDropdown({
    text = "Filters",
    flag = "filters",
    options = {"Visible", "Close", "LowHP"},
    multi = true,
    default = {Visible = true},
})
```

Config keys:

| Key | Type | Default |
|---|---|---|
| text | string | "Dropdown" |
| flag | string | derived from text |
| options | table | {} |
| default | any | nil |
| multi / Multi | boolean | false |
| callback | function(value) | nil |

Return API:

- d:Set(value)
- d:Get()
- d.Frame

---

### Keybind

```lua
local kb = section:AddKeybind({
    text = "Aimbot Key",
    flag = "aim_key",
    default = "E",        -- KeyCode name or UserInputType name
    mode = "hold",        -- hold | toggle
    callback = function(active, bindName) end,
    onBind = function(bindName) end,
})
```

Supports keyboard and mouse buttons (MouseButton1, MouseButton2, ...).

Config keys:

| Key | Type | Default |
|---|---|---|
| text | string | "Keybind" |
| flag | string | derived from text |
| default / key | string/EnumItem | nil |
| mode | string | "toggle" |
| callback | function(active:boolean, bindName:string) | nil |
| onBind | function(bindName:string) | nil |

Return API:

- kb:Set(key)
- kb:Get()
- kb.Frame

---

### Button

```lua
local b = section:AddButton({
    text = "Do Action",
    callback = function() end,
})
```

Return API:

- b:SetText(text)
- b:Press()
- b.Frame

---

### Label

```lua
local l = section:AddLabel({
    text = "Status: idle",
    color = Color3.fromRGB(200, 200, 200),
    size = 12,
})
```

Return API:

- l:Set(text)
- l:Get()
- l.Frame

---

### Paragraph

```lua
local p = section:AddParagraph({
    title = "Info",
    text = "This is a longer info message.",
})
```

Return API:

- p:Set(text)
- p:Get()
- p.Frame

---

### Lowercase Alias Methods

Available aliases:

- Addslider
- Addtoggle
- Addbutton
- Adddropdown
- Addkeybind
- Addlabel
- Addparagraph

---

## Flags And Binding Behavior

### Core Rules

- Controls write values into ui.Flags[flagName].
- ui:SetFlag(name, value) immediately syncs UI state and bound callbacks.
- ui:GetFlag(name, default) reads current value.

### Common Pattern

```lua
ui:SetFlag("sa_enabled", true)
local enabled = ui:GetFlag("sa_enabled", false)
```

---

## Config API

Config data is saved as JSON.

### Top-Level Methods (with Notify)

- ui:SaveConfig(name?)
- ui:LoadConfig(name?)
- ui:DeleteConfig(name?)
- ui:ListConfigs()

### Raw Config API (no notify)

```lua
ui.Config.Available() -- file api available?
ui.Config.Save(name)
ui.Config.Load(name)
ui.Config.Delete(name)
ui.Config.List()
```

### File Format

```json
{
  "Theme": "Nebula",
  "Flags": {
    "sa_enabled": true,
    "sa_fov": 200
  },
  "SavedAt": 1760000000
}
```

### Startup Auto-Load

If the file from ConfigName exists, it is auto-loaded right after UI startup.

---

## Preset API

Preset registry lives on the UI object.

### Methods

- ui:AddPreset(name, url) -> type auto
- ui:AddPresetJson(name, url) -> type json
- ui:LoadPreset(name, runtimeContext?)
- ui:LoadPresetJson(name)
- ui:RemovePreset(name)
- ui:ListPresets()

Additional interface:

```lua
ui.Presets.Add(name, url, presetType)
ui.Presets.AddJson(name, url)
ui.Presets.Load(name, runtimeContext, forcedType)
ui.Presets.LoadJson(name)
ui.Presets.Remove(name)
ui.Presets.List()
```

### Loading Behavior

- json: attempts JSON decode and applies Theme + Flags
- script: executes with loadstring
- auto: tries JSON first, then script fallback

### JSON Preset Example

```json
{
  "Theme": "Crimson",
  "Flags": {
    "sa_enabled": true,
    "sa_fov": 175,
    "thirdperson_enabled": false
  }
}
```

### Script Preset Context

When calling LoadPreset(...) without custom context, the default context contains:

- UI
- Flags
- SetFlag(flagName, value)
- GetFlag(flagName, defaultValue)
- Notify(payload)

---

## Theme API

- ui:SetTheme(themeName)
- ui:GetThemeName()

Supported themes:

- Nebula
- Crimson
- Emerald

Theme changes are live. No UI recreate is needed.

---

## Notification API

```lua
ui:Notify({
    Title = "Nebularity",
    Message = "Loaded",
    Duration = 3,
    MaxVisible = 5,
    Image = "rbxassetid://123456",
    Sound = {
        SoundId = "rbxassetid://9118823102",
        Volume = 0.35,
        PlaybackSpeed = 1,
    }
})
```

Payload keys:

| Key | Type | Description |
|---|---|---|
| Title | string | Title text |
| Message / Text | string | Body message |
| Duration | number | Visible time in seconds |
| MaxVisible | number | Max visible cards at once |
| Image / Icon | string/number | Asset or URL |
| Sound | bool/string/number/table | Sound behavior |

Return:

```lua
local n = ui:Notify("Hello")
n:Close()
```

---

## Best Practices

1. Give every control a unique and stable flag.
2. Keep config names consistent so users can reliably load the same setup.
3. Prefer JSON presets for community sharing.
4. Use ui:SetFlag(...) whenever values are changed from outside UI controls.
5. Keep tabs focused and sections clean for readability.

---

## Full Example With Presets

```lua
local NebularityUI = loadfile("SniperDuels/uinew.lua")()

local ui = NebularityUI:CreateUI({
    Theme = "Nebula",
    Title = "Nebularity",
    Flags = {
        sa_enabled = false,
        sa_fov = 200,
    },
    Presets = {
        {
            Name = "Legit",
            Url = "https://host/presets/legit.json",
            Type = "json",
        }
    }
})

local tab = ui:AddTab("Main")
local sec = tab:AddSection("Combat", "CORE")

sec:AddToggle({
    text = "Silent Aim",
    flag = "sa_enabled",
    callback = function(v)
        print("Silent Aim:", v)
    end,
})

sec:AddSlider({
    text = "FOV",
    flag = "sa_fov",
    min = 20,
    max = 400,
    inc = 5,
    callback = function(v)
        print("FOV:", v)
    end,
})

ui:AddPresetJson("Rage", "https://host/presets/rage.json")
ui:LoadPresetJson("Legit")
```

---

## Field Notes

- If loadstring is missing in the executor, JSON presets still work.
- If file APIs are missing (readfile/writefile/etc.), config functions are unavailable and notify the user.
- Section count is intentionally capped at 3 to keep layout clean and readable.

---

Made for people shipping real scripts, not just screenshot demos.
