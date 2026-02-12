--[[ 
    OREKERNEL - UI BACKEND ENGINE
    Version: Core_1.1 (The "Brain" Update)
    
    Changelog:
      + Identity Shift (Dynahax -> ORE)
      + Deferred Load Sync (Fixes "Load did nothing")
      + Registry System (Defaults + UI Hooks)
      + Slider Throttling (FPS Protection)
      + PLNT|01|ORE Save Format
]]

local ORE = {}
ORE.__index = ORE

-- [ 1. CONFIGURATION & STATE ]
local CONFIG = {
    NAME = "OREkernel",
    FOLDER = "DynahaxConfig",   -- Kept folder name for legacy compatibility (optional)
    SAVE_FILE = "config.plnt",
    HEADER = "PLNT|01|ORE",     -- New Header
    
    -- Throttles
    GLOBAL_THROTTLE = 0.05,     -- 50ms (Click spam protection)
    SLIDER_THROTTLE = 0.1,      -- 100ms (Callback execution limit)
}

ORE.State = {
    Toggles = {}, 
    Values = {},
    -- We can expand this later (Colors, Keybinds)
}

-- The Registry stores Metadata: Defaults, Callbacks, and Visual Hooks
-- Structure: { [id] = { Default=false, Callback=func, UIHook=func, Type="Toggle" } }
ORE.Registry = {}
ORE.Cooldowns = {} 

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- [ 2. SAFETY KERNEL ]
function ORE:SafeCall(func, ...)
    if not func or type(func) ~= "function" then return end
    local success, err = pcall(func, ...)
    if not success then
        warn("["..CONFIG.NAME.." PANIC]: " .. tostring(err))
    end
end

function ORE:CanInteract(id, type)
    local now = tick()
    
    -- Global Click Throttle (Ignore for sliders to allow dragging)
    if type ~= "Slider" and (now - (self._lastInput or 0) < CONFIG.GLOBAL_THROTTLE) then
        return false
    end
    
    -- Element Specific Cooldowns are handled in logic
    self._lastInput = now
    return true
end

-- [ 3. THE REGISTRY & SYNC SYSTEM ]
-- This is the new "Deferred Load" logic.

function ORE:Register(id, props)
    -- props = { Type="Toggle", Default=false, Callback=func, UIHook=func }
    self.Registry[id] = props
    
    -- Ensure state exists (Anti-Nil)
    if props.Type == "Toggle" and self.State.Toggles[id] == nil then
        self.State.Toggles[id] = props.Default
    elseif props.Type == "Slider" and self.State.Values[id] == nil then
        self.State.Values[id] = props.Default
    end
end

-- Call this AFTER your UI is built to apply saved settings
function ORE:SyncAll()
    print(CONFIG.NAME, "Syncing State to UI...")
    for id, data in pairs(self.Registry) do
        self:SyncElement(id)
    end
end

function ORE:SyncElement(id)
    local data = self.Registry[id]
    if not data then return end
    
    local state
    if data.Type == "Toggle" then
        state = self.State.Toggles[id]
    elseif data.Type == "Slider" then
        state = self.State.Values[id]
    end
    
    -- 1. Update Visuals (The Button Color/Text)
    if data.UIHook then 
        self:SafeCall(data.UIHook, state) 
    end
    
    -- 2. Execute Logic (The Cheat Feature)
    if data.Callback then 
        self:SafeCall(data.Callback, state) 
    end
end

-- [ 4. LOGIC CONTROLLERS ]

function ORE:HandleToggle(id)
    if not self:CanInteract(id, "Toggle") then return end
    
    local data = self.Registry[id]
    if not data then return warn("ORE: Unregistered Toggle ID:", id) end
    
    -- Flip State
    self.State.Toggles[id] = not self.State.Toggles[id]
    local newState = self.State.Toggles[id]
    
    -- Execute Visuals & Logic
    if data.UIHook then self:SafeCall(data.UIHook, newState) end
    if data.Callback then self:SafeCall(data.Callback, newState) end
    
    self:Save()
end

function ORE:HandleSlider(id, value)
    -- 1. Store Value Instantly (No Lag)
    self.State.Values[id] = value
    local data = self.Registry[id]
    if not data then return end
    
    -- 2. Visual Update (Always Run - allows smooth dragging)
    if data.UIHook then 
        self:SafeCall(data.UIHook, value) 
    end
    
    -- 3. Logic Execution (Throttled - Prevents FPS Nuke)
    local now = tick()
    local last = self.Cooldowns[id] or 0
    if now - last > CONFIG.SLIDER_THROTTLE then
        self.Cooldowns[id] = now
        if data.Callback then 
            self:SafeCall(data.Callback, value) 
        end
        -- We don't save on every pixel drag, maybe save on release? 
        -- For now, we won't auto-save inside HandleSlider to prevent file corruption.
        -- Trigger ORE:Save() manually on input ended.
    end
end

-- [ 5. SAVE SYSTEM (.PLNT ENGINE) ]
function ORE:Save()
    if not writefile then return end
    if not isfolder(CONFIG.FOLDER) then makefolder(CONFIG.FOLDER) end
    
    local path = CONFIG.FOLDER .. "/" .. CONFIG.SAVE_FILE
    local data = CONFIG.HEADER .. "\n"
    
    -- Encode Toggles
    for id, state in pairs(self.State.Toggles) do
        data = data .. "t." .. id .. "=" .. (state and "1" or "0") .. "\n"
    end
    
    -- Encode Values
    for id, val in pairs(self.State.Values) do
        data = data .. "v." .. id .. "=" .. tostring(val) .. "\n"
    end
    
    writefile(path, data)
end

function ORE:Load()
    if not (readfile and isfile) then return end
    local path = CONFIG.FOLDER .. "/" .. CONFIG.SAVE_FILE
    if not isfile(path) then return end
    
    local content = readfile(path)
    -- Verify Header
    if not content:find("PLNT|01|ORE") and not content:find("PLNT|01|DYNA") then 
        return warn("ORE: Save file version mismatch.") 
    end

    for line in content:gmatch("[^\r\n]+") do
        -- Toggles
        local t_id, t_val = line:match("t%.([^=]+)=([01])")
        if t_id then 
            self.State.Toggles[t_id] = (t_val == "1")
        end
        
        -- Values
        local v_id, v_val = line:match("v%.([^=]+)=(.+)")
        if v_id then
            self.State.Values[v_id] = tonumber(v_val) or v_val
        end
    end
    print(CONFIG.NAME, "State Loaded into Memory.")
end

-- [ 6. INITIALIZATION ]
function ORE.new()
    local self = setmetatable({}, ORE)
    
    -- Attempt to load state immediately into memory
    -- Note: Callbacks won't fire yet because Registry is empty.
    -- This fixes the "Load runs before UI" bug.
    self:Load()
    
    return self
end

return ORE
