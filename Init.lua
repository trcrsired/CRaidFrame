local CRaidFrame = LibStub("AceAddon-3.0"):NewAddon("CRaidFrame","AceConsole-3.0","AceEvent-3.0")

local C_AddOns = C_AddOns
if C_AddOns == nil then
	C_AddOns = _G
end

local LoadAddOn = C_AddOns.LoadAddOn
local GetNumAddOns = C_AddOns.GetNumAddOns
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local GetAddOnInfo = C_AddOns.GetAddOnInfo

function CRaidFrame:OnInitialize()
	local LSM = LibStub("LibSharedMedia-3.0")
	local nulltb = {}
	self.db = LibStub("AceDB-3.0"):New("CRaidFrameDB",
	{
		profile =
		{
			bottom = 370,
			left = 0,
			width = 70,
			height = 60,
			refresh_rate = 0.05,
			font_size = 12,
			resourcebar_length = 10,
			font = LSM:GetDefault("font"),
			statusbar = "Solid",
			background = LSM:GetDefault("background"),
			border = "None",
			border_size = 0,
			bindings = {{"type1","target"},{"type2","togglemenu"}},
			self_buff = nulltb,
			buffs = 5,
			debuffs = 5,
			font_scale = 0.8,
			max_font_width_diff = -8,
			[1] = nulltb,
			[2] = nulltb
		}
	})
	local LibDualSpec = LibStub('LibDualSpec-1.0',true)
	if LibDualSpec then
		LibDualSpec:EnhanceDatabase(self.db, "CRaidFrame")
	end
	self:RegisterChatCommand("CRaidFrame", "ChatCommand")
	self:RegisterChatCommand("CRF", "ChatCommand")
--	self:RegisterEvent("GROUP_ROSTER_UPDATE")
--	self:RegisterEvent("PLAYER_REGEN_ENABLED","GROUP_ROSTER_UPDATE")
	if not self.db.profile.enable_blizzardcompactraidframes then
		self:RegisterEvent("ADDON_LOADED")
		CRaidFrame:ADDON_LOADED("ADDON_LOADED","Blizzard_CompactRaidFrames")
	end
	local class = select(2,UnitClass("player"))
	for i = 1, GetNumAddOns() do
		local metadata = GetAddOnMetadata(i, "X-CRF")
		if metadata and (metadata == "1" or metadata == class) then
			LoadAddOn(i)
		end
		local event = GetAddOnMetadata(i, "X-CRF-EVENT")
		if event then
			self:RegisterEvent(event,"loadevent",i)
		end
		local message = GetAddOnMetadata(i,"X-CRF-MESSAGE")
		if message then
			self:RegisterMessage(message,"loadevent",i)
		end
	end
end

function CRaidFrame:loadevent(p,event,...)
	self:UnregisterEvent(event)
	self:UnregisterMessage(event)
	LoadAddOn(p)
	if IsAddOnLoaded(p) then
		local addon = GetAddOnInfo(p)
		local a = LibStub("AceAddon-3.0"):GetAddon(addon)
		a[event](a,event,...)
		return true
	end
end

function CRaidFrame:ChatCommand(input)
	self:SendMessage("CRF_ChatCommand",input)
end

function CRaidFrame:ADDON_LOADED(_,addonname)
	if addonname ~= "Blizzard_CompactRaidFrames" then
		return
	end
	if not self.db.profile.enable_blizzardcompactraidframes then
		local CompactRaidFrameManager = CompactRaidFrameManager
		if CompactRaidFrameManager then
			local UIHider = CRaidFrame.UIHider
			if UIHider == nil then
				UIHider = CreateFrame("Frame")
				UIHider:Hide()
				CRaidFrame.UIHider = UIHider
			end
			CompactRaidFrameManager:SetParent(UIHider)
			CompactRaidFrameManager:UnregisterAllEvents()
			if CompactRaidFrameContainer then
				CompactRaidFrameContainer:SetParent(UIHider)
				CompactRaidFrameContainer:UnregisterAllEvents()
			end
			self:UnregisterEvent("ADDON_LOADED")
		end
	end
end

local UnitAura = UnitAura
if UnitAura then
CRaidFrame.UnitAura = UnitAura
else

local C_UnitAuras_GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local AuraUtil_UnpackAuraData = AuraUtil.UnpackAuraData

function CRaidFrame.UnitAura(...)
	local auraData = C_UnitAuras_GetAuraDataByIndex(...)
	if not auraData then
		return
	end
	return AuraUtil_UnpackAuraData(auraData)
end

end


if GetSpellInfo then
	CRaidFrame.GetSpellInfo = GetSpellInfo
else
	local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
	function CRaidFrame.GetSpellInfo(...)
		local spellInfo = C_Spell_GetSpellInfo(...)
		if spellInfo == nil then
			return
		end
		-- name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon
		return spellInfo.name, spellInfo.rank, spellInfo.iconID, spellInfo.castTime,
			spellInfo.minRange, spellInfo.maxRange, spellInfo.maxRange, spellInfo.originalIconID
	end
end