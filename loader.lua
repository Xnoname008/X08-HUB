-- =============================================================================
-- X08 Hub — Multi-CDN Standalone Enterprise Loader
-- =============================================================================
-- Repository: https://github.com/denoyey/X08-HUB
-- Multi-CDN Endpoints:
--   1. jsDelivr CDN (Jakarta / Singapore / Global Edge): Low-latency & High Speed
--   2. Raw GitHub CDN (Official raw user content)
--   3. Statically CDN (Global Fast Edge)
--
-- Supported Executors:
--   Delta Mobile, Codex, Arceus X, Fluxus, Hydrogen, Synapse Z, Xeno, Wave, etc.
-- =============================================================================

-- Pastikan game Roblox sudah fully loaded
if not game:IsLoaded() then
    pcall(function()
        if game.Loaded then
            game.Loaded:Wait()
        else
            repeat task.wait(0.1) until game:IsLoaded()
        end
    end)
end

local genv = (type(getgenv) == "function" and getgenv()) or _G
if genv.X08_LOADER_RUNNING then return end
genv.X08_LOADER_RUNNING = true

-- Notifikasi visual startup
pcall(function()
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("SendNotification", {
        Title = "X08 Hub",
        Text = "Memuat X08 Hub via Multi-CDN...",
        Duration = 3
    })
end)

-- Compiler & Anti-Hook Inspection
local function getTrustedCompiler()
    local renv = (type(getrenv) == "function" and getrenv()) or {}
    local rawLoadstring = renv.loadstring or loadstring
    local rawLoad = renv.load or load
    local isCClosure = (type(iscclosure) == "function" and iscclosure)
        or (debug and type(debug.iscclosure) == "function" and debug.iscclosure)

    if type(rawLoadstring) == "function" then
        if isCClosure and not isCClosure(rawLoadstring) then
            if type(rawLoad) == "function" and isCClosure(rawLoad) then
                return rawLoad
            end
        end
        return rawLoadstring
    end
    if type(rawLoad) == "function" then
        return rawLoad
    end
    return nil
end

local compiler = getTrustedCompiler()
if not compiler then
    warn("[X08 Loader] Gagal: Tidak ada compiler Lua (loadstring/load) yang valid.")
    genv.X08_LOADER_RUNNING = nil
    return
end

-- Robust HTTP Getter
local function robustGet(url)
    local result = nil
    local getFn = nil

    if type(game.HttpGet) == "function" then
        getFn = function(u) return game:HttpGet(u) end
    elseif type(request) == "function" then
        getFn = function(u)
            local res = request({ Url = u, Method = "GET" })
            return res and res.Body
        end
    elseif type(http_request) == "function" then
        getFn = function(u)
            local res = http_request({ Url = u, Method = "GET" })
            return res and res.Body
        end
    elseif syn and type(syn.request) == "function" then
        getFn = function(u)
            local res = syn.request({ Url = u, Method = "GET" })
            return res and res.Body
        end
    end

    if not getFn then return nil end

    for attempt = 1, 3 do
        local ok, body = pcall(getFn, url)
        if ok and type(body) == "string" and #body > 500 then
            result = body
            break
        end
        if attempt < 3 then
            task.wait(0.25)
        end
    end

    return result
end

-- Multi-CDN Endpoints untuk main.lua
local CDN_SOURCES = {
    "https://cdn.jsdelivr.net/gh/denoyey/X08-HUB@main/main.lua",
    "https://raw.githubusercontent.com/denoyey/X08-HUB/main/main.lua",
    "https://cdn.statically.io/gh/denoyey/X08-HUB/main/main.lua"
}

local mainScript = nil
for i = 1, #CDN_SOURCES do
    mainScript = robustGet(CDN_SOURCES[i])
    if mainScript and #mainScript > 1000 then
        break
    end
end

if not mainScript or #mainScript < 1000 then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "X08 Hub - Error",
            Text = "Gagal mengunduh script dari CDN. Periksa koneksi internet.",
            Duration = 5
        })
    end)
    genv.X08_LOADER_RUNNING = nil
    return
end

-- Eksekusi Main Script
local execFn, compileErr = compiler(mainScript, "@X08Hub/main.lua")
mainScript = nil -- Langsung bersihkan memori

if not execFn then
    warn("[X08 Loader] Syntax error pada payload: " .. tostring(compileErr))
    genv.X08_LOADER_RUNNING = nil
    return
end

local runOk, runErr = pcall(execFn)
if not runOk then
    warn("[X08 Loader] Runtime error saat eksekusi: " .. tostring(runErr))
end

genv.X08_LOADER_RUNNING = nil
