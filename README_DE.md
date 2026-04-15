# Nebularity UI Bibliothek

> Praxisreferenz für uinew.lua.
> Gebaut für schnelle Integration ohne Trial-and-Error.

---

## Was ist das?

NebularityUI ist eine Roblox-UI-Bibliothek mit:

- Tab-System
- Sektions-System (max. 3 Sektionen pro Tab)
- Controls (Toggle, Slider, Dropdown, Keybind, Button, Label, Paragraph)
- Flag-Binding (UI <-> Script-State)
- JSON-Config speichern/laden
- Preset-System (Remote-JSON und optionale Script-Presets)
- Live-Theme-Wechsel
- Eingebaute Benachrichtigungen

Hauptdatei: uinew.lua

---

## Schnellstart

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
    text = "Aimbot aktivieren",
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

## Inhaltsverzeichnis

1. [CreateUI-Einstellungen](#createui-einstellungen)
2. [UI-Objekt-API](#ui-objekt-api)
3. [Tab- und Sektions-API](#tab--und-sektions-api)
4. [Control-API](#control-api)
5. [Flags und Binding-Verhalten](#flags-und-binding-verhalten)
6. [Config-API](#config-api)
7. [Preset-API](#preset-api)
8. [Theme-API](#theme-api)
9. [Benachrichtigungs-API](#benachrichtigungs-api)
10. [Best Practices](#best-practices)

---

## CreateUI-Einstellungen

```lua
local ui = NebularityUI:CreateUI(settings)
```

### Kerneinstellungen

| Schlüssel | Typ | Standard | Beschreibung |
|---|---|---|---|
| Theme | string | "Nebula" | Initiales Theme (Nebula, Crimson, Emerald) |
| Title | string | "Nebularity" | Titelleisten-Text |
| SubTitle | string | LocalPlayer.Name | Untertitel der Titelleiste |
| Flags | table | {} | Initiale Flag-Werte |
| Position | UDim2 | UDim2.new(0.5,0,0.5,0) | Startposition des Panels |
| Size | UDim2 | UDim2.new(0,1023,0,471) | Standard-Panelgröße |

### Layout und Minimieren

| Schlüssel | Typ | Standard |
|---|---|---|
| BottomBarHeight | number | 64 |
| MinimizedBarHeight | number | 46 |
| BottomBarInset | number | 10 |
| MinimizedBarInset | number | 10 |
| MinimizedWidth | number | automatisch berechnet |
| MinimizedSize | UDim2 | automatisch berechnet |

### Benachrichtigungs-Standards

| Schlüssel | Typ | Standard |
|---|---|---|
| NotifyDuration | number | 3 |
| NotifyMaxVisible | number | 5 |
| NotifySoundId | string/number | nil |
| NotifySoundVolume | number | 0.35 |
| NotifySoundPlaybackSpeed | number | 1 |

### Config-Standards

| Schlüssel | Typ | Standard |
|---|---|---|
| ConfigFolder | string | "NebularityConfigs" |
| ConfigName | string | "default" |

### Presets beim Start registrieren

settings.Presets unterstützt:

```lua
Presets = {
    Legit = "https://host/presets/legit.json", -- automatisch

    {
        Name = "Rage",
        Url = "https://host/presets/rage.json",
        Type = "json", -- json | script | auto
    }
}
```

---

## UI-Objekt-API

CreateUI gibt ein UI-Objekt mit Feldern und Methoden zurück.

### Wichtige Felder

| Feld | Typ | Zweck |
|---|---|---|
| Gui | ScreenGui | Root-GUI-Objekt |
| Panel | Frame | Hauptpanel |
| Flags | table | Aktueller Flag-Zustandsspeicher |
| Theme | string | Aktiver Theme-Name |
| ThemeData | table | Aktive Theme-Daten |

### Kernmethoden

| Methode | Signatur | Beschreibung |
|---|---|---|
| Show | ui:Show() | Öffnet die UI mit Animation |
| Hide | ui:Hide() | Schließt die UI mit Animation |
| Destroy | ui:Destroy() | Trennt Events und zerstört GUI |
| Notify | ui:Notify(payload) | Zeigt eine Benachrichtigung |
| AddTab | ui:AddTab(name, icon?) | Erstellt einen Tab |
| SelectTab | ui:SelectTab(name) | Wählt einen Tab aus |
| GetTabContent | ui:GetTabContent(tabName) | Gibt Tab-Content-Frame zurück |
| GetSectionContent | ui:GetSectionContent(tabName, sectionName) | Gibt Sektions-Content-Frame zurück |
| GetFlag | ui:GetFlag(name, default?) | Liest Flag-Wert |
| SetFlag | ui:SetFlag(name, value) | Setzt Flag und synchronisiert gebundene Controls |

---

## Tab- und Sektions-API

### Tab erstellen

```lua
local tab = ui:AddTab("Visual", "rbxassetid://123456")
```

- name ist erforderlich (string)
- icon ist optional (string)
- Doppelte Tab-Namen werden abgelehnt

### Sektion erstellen

```lua
local section = tab:AddSection("ESP", "VISION")
```

- sectionName ist erforderlich
- sectioninfo ist optional (Rechts-Badge)
- Maximal 3 Sektionen pro Tab

---

## Control-API

Alle Controls werden auf einem Sektions-Objekt erstellt.

### Toggle

```lua
local t = section:AddToggle({
    text = "Aktiviert",
    flag = "aktiviert",
    default = false,
    callback = function(v) end,
})
```

Konfigurations-Schlüssel:

| Schlüssel | Typ | Erforderlich |
|---|---|---|
| text | string | nein |
| flag | string | empfohlen |
| default | boolean | nein |
| callback | function(value:boolean) | nein |

Rückgabe-API:

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

Konfigurations-Schlüssel:

| Schlüssel | Typ | Standard |
|---|---|---|
| text | string | "Slider" |
| flag | string | aus text abgeleitet |
| min | number | 0 |
| max | number | 100 |
| inc / step | number | 1 |
| decimals | number | automatisch |
| default | number | min |
| suffix | string | "" |
| callback | function(value:number) | nil |

Rückgabe-API:

- s:Set(number)
- s:Get()
- s.Frame

---

### Dropdown

```lua
local d = section:AddDropdown({
    text = "Ziel-Part",
    flag = "target_part",
    options = {"Head", "UpperTorso"},
    default = "Head",
    callback = function(v) end,
})
```

Mehrfachauswahl:

```lua
actions:AddDropdown({
    text = "Filter",
    flag = "filter",
    options = {"Sichtbar", "Nah", "WenigHP"},
    multi = true,
    default = {Sichtbar = true},
})
```

Konfigurations-Schlüssel:

| Schlüssel | Typ | Standard |
|---|---|---|
| text | string | "Dropdown" |
| flag | string | aus text abgeleitet |
| options | table | {} |
| default | any | nil |
| multi / Multi | boolean | false |
| callback | function(value) | nil |

Rückgabe-API:

- d:Set(value)
- d:Get()
- d.Frame

---

### Keybind

```lua
local kb = section:AddKeybind({
    text = "Aimbot-Taste",
    flag = "aim_key",
    default = "E",        -- KeyCode-Name oder UserInputType-Name
    mode = "hold",        -- hold | toggle
    callback = function(active, bindName) end,
    onBind = function(bindName) end,
})
```

Unterstützt Tastatur- und Maustasten (MouseButton1, MouseButton2, ...).

Konfigurations-Schlüssel:

| Schlüssel | Typ | Standard |
|---|---|---|
| text | string | "Keybind" |
| flag | string | aus text abgeleitet |
| default / key | string/EnumItem | nil |
| mode | string | "toggle" |
| callback | function(active:boolean, bindName:string) | nil |
| onBind | function(bindName:string) | nil |

Rückgabe-API:

- kb:Set(key)
- kb:Get()
- kb.Frame

---

### Button

```lua
local b = section:AddButton({
    text = "Aktion ausführen",
    callback = function() end,
})
```

Rückgabe-API:

- b:SetText(text)
- b:Press()
- b.Frame

---

### Label

```lua
local l = section:AddLabel({
    text = "Status: inaktiv",
    color = Color3.fromRGB(200, 200, 200),
    size = 12,
})
```

Rückgabe-API:

- l:Set(text)
- l:Get()
- l.Frame

---

### Paragraph

```lua
local p = section:AddParagraph({
    title = "Info",
    text = "Dies ist eine längere Info-Nachricht.",
})
```

Rückgabe-API:

- p:Set(text)
- p:Get()
- p.Frame

---

### Kleingeschriebene Alias-Methoden

Verfügbare Aliase:

- Addslider
- Addtoggle
- Addbutton
- Adddropdown
- Addkeybind
- Addlabel
- Addparagraph

---

## Flags und Binding-Verhalten

### Kernregeln

- Controls schreiben Werte in ui.Flags[flagName].
- ui:SetFlag(name, value) synchronisiert sofort den UI-Zustand und gebundene Callbacks.
- ui:GetFlag(name, default) liest den aktuellen Wert.

### Übliches Muster

```lua
ui:SetFlag("sa_enabled", true)
local enabled = ui:GetFlag("sa_enabled", false)
```

---

## Config-API

Config-Daten werden als JSON gespeichert.

### Oberste Methoden (mit Benachrichtigung)

- ui:SaveConfig(name?)
- ui:LoadConfig(name?)
- ui:DeleteConfig(name?)
- ui:ListConfigs()

### Rohe Config-API (ohne Benachrichtigung)

```lua
ui.Config.Available() -- Datei-API verfügbar?
ui.Config.Save(name)
ui.Config.Load(name)
ui.Config.Delete(name)
ui.Config.List()
```

### Dateiformat

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

### Automatisches Laden beim Start

Wenn die Datei aus ConfigName existiert, wird sie direkt nach dem UI-Start automatisch geladen.

---

## Preset-API

Das Preset-Register befindet sich am UI-Objekt.

### Methoden

- ui:AddPreset(name, url) -> Typ auto
- ui:AddPresetJson(name, url) -> Typ json
- ui:LoadPreset(name, runtimeContext?)
- ui:LoadPresetJson(name)
- ui:RemovePreset(name)
- ui:ListPresets()

Zusätzliches Interface:

```lua
ui.Presets.Add(name, url, presetType)
ui.Presets.AddJson(name, url)
ui.Presets.Load(name, runtimeContext, forcedType)
ui.Presets.LoadJson(name)
ui.Presets.Remove(name)
ui.Presets.List()
```

### Ladeverhalten

- json: Versucht JSON-Dekodierung und wendet Theme + Flags an
- script: Führt mit loadstring aus
- auto: Versucht zuerst JSON, dann Script als Fallback

### JSON-Preset-Beispiel

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

### Script-Preset-Kontext

Beim Aufruf von LoadPreset(...) ohne eigenen Kontext enthält der Standard-Kontext:

- UI
- Flags
- SetFlag(flagName, value)
- GetFlag(flagName, defaultValue)
- Notify(payload)

---

## Theme-API

- ui:SetTheme(themeName)
- ui:GetThemeName()

Unterstützte Themes:

- Nebula
- Crimson
- Emerald

Theme-Wechsel sind live. Kein UI-Neustart erforderlich.

---

## Benachrichtigungs-API

```lua
ui:Notify({
    Title = "Nebularity",
    Message = "Geladen",
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

Payload-Schlüssel:

| Schlüssel | Typ | Beschreibung |
|---|---|---|
| Title | string | Titeltext |
| Message / Text | string | Nachrichtentext |
| Duration | number | Sichtbarkeitszeit in Sekunden |
| MaxVisible | number | Max. sichtbare Karten gleichzeitig |
| Image / Icon | string/number | Asset oder URL |
| Sound | bool/string/number/table | Soundverhalten |

Rückgabe:

```lua
local n = ui:Notify("Hallo")
n:Close()
```

---

## Best Practices

1. Gib jedem Control ein eindeutiges und stabiles Flag.
2. Halte Config-Namen konsistent, damit Nutzer zuverlässig dieselbe Konfiguration laden können.
3. Bevorzuge JSON-Presets für Community-Sharing.
4. Verwende ui:SetFlag(...) immer dann, wenn Werte außerhalb von UI-Controls geändert werden.
5. Halte Tabs fokussiert und Sektionen übersichtlich.

---

## Vollständiges Beispiel mit Presets

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

## Hinweise

- Wenn loadstring im Executor fehlt, funktionieren JSON-Presets trotzdem.
- Wenn Datei-APIs fehlen (readfile/writefile/etc.), sind Config-Funktionen nicht verfügbar und der Nutzer wird benachrichtigt.
- Die Sektionsanzahl ist bewusst auf 3 begrenzt, um das Layout sauber und lesbar zu halten.

---

Gemacht für Leute, die echte Scripts shippen — nicht nur Screenshot-Demos.
