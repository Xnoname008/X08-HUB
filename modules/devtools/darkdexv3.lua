local BaseUrl = "https://cdn.jsdelivr.net/gh/Xnoname008/X08-HUB@main/"

local function safeGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and type(res) == "string" and #res > 0 then return res end
    local reqFn = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request
    if reqFn then
        local rOk, rRes = pcall(function() return reqFn({ Url = url, Method = "GET" }) end)
        if rOk and type(rRes) == "table" and type(rRes.Body or rRes.body) == "string" then
            return rRes.Body or rRes.body
        end
    end
    return nil
end

local function safeRun(url)
    local src = safeGet(url)
    if not src then return end
    local fn = (loadstring or load)
    local chunk = fn(src)
    if chunk then chunk() end
end

-- cloneref
pcall(safeRun, BaseUrl .. "modules/devtools/cloneref.lua")

-- Dex Bypasses
pcall(safeRun, BaseUrl .. "modules/devtools/bypasses.lua")

-- Dex with CloneRef Support (made as global)
local genv = (type(getgenv) == "function" and getgenv()) or _G
local dexObj = game:GetObjects("rbxassetid://9352453730")[1]
genv.Bypassed_Dex = dexObj

local charset = {}
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end
function RandomCharacters(length)
    if length > 0 then
        return RandomCharacters(length - 1) .. charset[math.random(1, #charset)]
    else
        return ""
    end
end

dexObj.Name = RandomCharacters(math.random(5, 20))
local cloneRefFn = (type(cloneref) == "function") and cloneref or function(inst) return inst end
local parented = false
if type(gethui) == "function" then
    parented = pcall(function() dexObj.Parent = gethui() end)
end
if not parented then
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(dexObj)
        elseif protect_gui then protect_gui(dexObj)
        elseif protectgui then protectgui(dexObj) end
    end)
    parented = pcall(function() dexObj.Parent = cloneRefFn(game:GetService("CoreGui")) end)
end
if not parented or not dexObj.Parent then
    pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        if lp then dexObj.Parent = lp:FindFirstChildOfClass("PlayerGui") end
    end)
end

local function Load(Obj, Url)
    local function GiveOwnGlobals(Func, Script)
        if not Func then return function() end end
        local Fenv = {}
        local RealFenv = {script = Script}
        local FenvMt = {}
        function FenvMt:__index(b)
            if RealFenv[b] == nil then
                return getfenv()[b]
            else
                return RealFenv[b]
            end
        end
        function FenvMt:__newindex(b, c)
            if RealFenv[b] == nil then
                getfenv()[b] = c
            else
                RealFenv[b] = c
            end
        end
        setmetatable(Fenv, FenvMt)
        pcall(setfenv, Func, Fenv)
        return Func
    end
    
    local function LoadScripts(Script)
        if Script.ClassName == "Script" or Script.ClassName == "LocalScript" then
            local ok2, ch = pcall(function() return loadstring(Script.Source, "=" .. Script:GetFullName()) end)
            if not ok2 or not ch then
                local ok1, ch1 = pcall(function() return loadstring(Script.Source) end)
                if ok1 then ch = ch1 end
            end
            if ch then
                task.spawn(GiveOwnGlobals(ch, Script))
            end
        end
        for _,v in ipairs(Script:GetChildren()) do
            LoadScripts(v)
        end
    end
    
    LoadScripts(Obj)
end

Load(dexObj)