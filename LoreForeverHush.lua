-- Lore Forever Hush: Lore Forever pauses while Spoken reads, and picks up again when Spoken is done.
--
-- WoW has no real pause for a sound, so "pause" is Lore Forever's own stop (the same as /lore stop), which
-- remembers where the story was. "Continue" is Lore Forever's own play/pause key (LoreForever_PlaylistToggle),
-- which picks up what was stopped: stories recorded in pieces go on from the piece they stopped in, a story in
-- one recording starts over.

local PREFIX = "|cffb48cffLore Forever Hush:|r "
local RESUME_DELAY = 1.5   -- seconds of quiet from Spoken before Lore Forever goes on (Spoken's gap between lines)
local POLL = 0.25

LoreForeverHushDB = LoreForeverHushDB or {}

-- Lore Forever's sounds: its voice packs live in folders named LoreForever*. Lore Forever keeps its sound handles
-- private, so note the ones it gets back from PlaySoundFile.
local loreHandles = {}
local origPlaySoundFile = PlaySoundFile
PlaySoundFile = function(path, ...)
    local willPlay, handle = origPlaySoundFile(path, ...)
    if willPlay and handle and type(path) == "string" and path:lower():find("addons\\loreforever", 1, true) then
        loreHandles[#loreHandles + 1] = handle
    end
    return willPlay, handle
end

local function LorePlaying()
    if not (C_Sound and C_Sound.IsPlaying) then return false end
    local playing = false
    for i = #loreHandles, 1, -1 do
        local ok, on = pcall(C_Sound.IsPlaying, loreHandles[i])
        if ok and on then
            playing = true
        else
            table.remove(loreHandles, i)
        end
    end
    return playing
end

local loreSlash
local function LoreSlash()
    if loreSlash then return loreSlash end
    for key, fn in pairs(SlashCmdList) do
        for i = 1, 9 do
            local cmd = _G["SLASH_" .. key .. i]
            if not cmd then break end
            cmd = cmd:lower()
            if cmd == "/lore" or cmd == "/lf" then
                loreSlash = fn
                return fn
            end
        end
    end
end

local function SpokenSpeaking()
    local Spoken = _G.Spoken
    return Spoken and Spoken.IsPlaying and Spoken:IsPlaying() or false
end

local pausedByUs = false
local quietSince = nil

local function PauseLore()
    local stop = LoreSlash()
    if not stop then return end
    pcall(stop, "stop")
    wipe(loreHandles)
    pausedByUs = true
end

local function ResumeLore()
    pausedByUs = false
    -- The play/pause key stops whatever plays, so only press it over silence.
    if LorePlaying() or not LoreForever_PlaylistToggle then return end
    pcall(LoreForever_PlaylistToggle)
end

-- Spoken started a line, or Lore Forever started something while Spoken speaks: Lore Forever makes way.
-- Spoken has been quiet for RESUME_DELAY: what Lore Forever was saying goes on.
local function Check()
    if LoreForeverHushDB.disabled then
        pausedByUs, quietSince = false, nil
        return
    end
    if SpokenSpeaking() then
        quietSince = nil
        if LorePlaying() then PauseLore() end
    elseif pausedByUs then
        local t = GetTime()
        quietSince = quietSince or t
        if t - quietSince >= RESUME_DELAY then
            quietSince = nil
            ResumeLore()
        end
    end
end

local frame = CreateFrame("Frame")
local elapsed = 0
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    local Spoken = _G.Spoken
    if not (Spoken and Spoken.IsCompatible and Spoken:IsCompatible(1) and Spoken.IsPlaying) then
        print(PREFIX .. "Spoken's API was not found, so Lore Forever won't be paused.")
        return
    end
    if Spoken.RegisterCallback then
        Spoken:RegisterCallback("CLIP_STARTED", Check)   -- pause at once, not on the next poll
    end
    if not (LoreSlash() and LoreForever_PlaylistToggle) then
        print(PREFIX .. "Lore Forever was not found. Is it enabled?")
        return
    end
    frame:SetScript("OnUpdate", function(_, dt)
        elapsed = elapsed + dt
        if elapsed < POLL then return end
        elapsed = 0
        Check()
    end)
end)

SLASH_LOREFOREVERHUSH1 = "/lfhush"
SlashCmdList.LOREFOREVERHUSH = function(msg)
    msg = (msg or ""):lower()
    if msg == "on" then
        LoreForeverHushDB.disabled = nil
    elseif msg == "off" then
        LoreForeverHushDB.disabled = true
    elseif msg == "" or msg == "toggle" then
        LoreForeverHushDB.disabled = not LoreForeverHushDB.disabled or nil
    end
    print(PREFIX .. (LoreForeverHushDB.disabled and "off" or "on")
        .. ((LoreSlash() and LoreForever_PlaylistToggle) and "" or " (Lore Forever not found)"))
end
