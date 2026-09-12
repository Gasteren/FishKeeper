--[[
	FishKeeper window: compact fishing bar + expanded catch list.
	Transparent, wide, no TSM chrome on the main view.
]]

local FK = FishKeeper

local WIDE = 640
local COMPACT_H = 40
local EXPANDED_H = 352
local ROW_HEIGHT = 22
local VISIBLE_ROWS = 8
local QUALITY_COLORS = ITEM_QUALITY_COLORS

local THEMES = {
	steel = {
		label = "Steel",
		bg = { 0.04, 0.05, 0.06 },
		bga = { 0.42, 0.52 },
		border = { 0.55, 0.58, 0.60, 0.45 },
		title = { 0.88, 0.79, 0.53 },
		text = { 0.84, 0.82, 0.78 },
		muted = { 0.55, 0.60, 0.63 },
		sep = { 0.55, 0.58, 0.60, 0.45 },
		swatch = { 0.45, 0.50, 0.55 },
	},
	gold = {
		label = "Gold",
		bg = { 0.12, 0.09, 0.03 },
		bga = { 0.62, 0.78 },
		border = { 0.78, 0.62, 0.22, 0.75 },
		title = { 1.00, 0.82, 0.20 },
		text = { 0.95, 0.90, 0.72 },
		muted = { 0.70, 0.60, 0.38 },
		sep = { 0.78, 0.62, 0.22, 0.55 },
		swatch = { 0.82, 0.64, 0.18 },
	},
	night = {
		label = "Night",
		bg = { 0.03, 0.07, 0.11 },
		bga = { 0.50, 0.62 },
		border = { 0.28, 0.55, 0.68, 0.65 },
		title = { 0.55, 0.86, 0.95 },
		text = { 0.78, 0.90, 0.95 },
		muted = { 0.42, 0.62, 0.70 },
		sep = { 0.28, 0.55, 0.68, 0.50 },
		swatch = { 0.22, 0.52, 0.68 },
	},
	horde = {
		label = "Horde",
		bg = { 0.12, 0.03, 0.03 },
		bga = { 0.55, 0.70 },
		border = { 0.72, 0.18, 0.14, 0.70 },
		title = { 1.00, 0.72, 0.28 },
		text = { 0.95, 0.82, 0.78 },
		muted = { 0.72, 0.42, 0.38 },
		sep = { 0.72, 0.22, 0.18, 0.50 },
		swatch = { 0.72, 0.16, 0.12 },
	},
	alliance = {
		label = "Alliance",
		bg = { 0.04, 0.07, 0.14 },
		bga = { 0.52, 0.66 },
		border = { 0.32, 0.48, 0.82, 0.70 },
		title = { 0.55, 0.72, 1.00 },
		text = { 0.82, 0.88, 0.98 },
		muted = { 0.48, 0.58, 0.78 },
		sep = { 0.32, 0.48, 0.82, 0.50 },
		swatch = { 0.28, 0.42, 0.78 },
	},
	simple = {
		label = "Simple",
		bg = { 0.02, 0.02, 0.02 },
		bga = { 0.22, 0.32 },
		border = { 0.40, 0.42, 0.44, 0.28 },
		title = { 0.90, 0.90, 0.90 },
		text = { 0.82, 0.82, 0.82 },
		muted = { 0.58, 0.58, 0.58 },
		sep = { 0.55, 0.55, 0.55, 0.35 },
		swatch = { 0.70, 0.70, 0.70 },
	},
}
local THEME_ORDER = { "steel", "gold", "night", "horde", "alliance", "simple" }

local function QualityColor(quality)
	local c = QUALITY_COLORS and QUALITY_COLORS[quality or 1]
	if c then
		return c.r, c.g, c.b
	end
	return 1, 1, 1
end

local function TinyButton(parent, w, label)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(w, 18)
	b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	b.text:SetPoint("CENTER")
	b.text:SetText(label or "")
	b:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	b:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	return b
end

local function MakePipe(parent)
	local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	fs:SetText("|")
	fs:SetTextColor(0.55, 0.60, 0.63)
	return fs
end

local function MakeChip(parent, iconSize)
	local chip = CreateFrame("Button", nil, parent)
	chip:SetHeight(18)
	chip.icon = chip:CreateTexture(nil, "ARTWORK")
	chip.icon:SetSize(iconSize or 14, iconSize or 14)
	chip.icon:SetPoint("LEFT", 0, 0)
	chip.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	chip.text = chip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	chip.text:SetPoint("LEFT", chip.icon, "RIGHT", 3, 0)
	chip:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	return chip
end

local function MakeColHeader(parent, label, width, justify, mode)
	local b = CreateFrame("Button", nil, parent)
	b:SetHeight(16)
	if width then
		b:SetWidth(width)
	end
	b.text = b:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	b.text:SetAllPoints()
	b.text:SetJustifyH(justify or "LEFT")
	b.text:SetText(label)
	b.mode = mode
	b.label = label
	b:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	b:SetScript("OnClick", function()
		FK:SetSort(mode)
	end)
	b:SetScript("OnEnter", function(selfBtn)
		GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
		GameTooltip:SetText("Sort by " .. label)
		GameTooltip:AddLine("Click again to reverse.", 1, 1, 1)
		GameTooltip:Show()
	end)
	b:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	return b
end

function FK:Theme()
	local id = self.db and self.db.settings.theme or "steel"
	return THEMES[id] or THEMES.steel, id
end

function FK:SetTheme(id)
	if not THEMES[id] then
		return
	end
	self.db.settings.theme = id
	self:ApplyLayout()
	self:RefreshUI()
end

function FK:CycleTheme(name)
	name = name and name:lower() or ""
	if THEMES[name] then
		self:SetTheme(name)
		return name
	end
	local cur = self.db.settings.theme or "steel"
	local nextId = THEME_ORDER[1]
	for i = 1, #THEME_ORDER do
		if THEME_ORDER[i] == cur then
			nextId = THEME_ORDER[(i % #THEME_ORDER) + 1]
			break
		end
	end
	self:SetTheme(nextId)
	return nextId
end

function FK:ApplyTheme()
	local frame = self.frame
	if not frame then
		return
	end
	local theme = self:Theme()
	local compact = self.db.settings.compact
	local a = compact and theme.bga[1] or theme.bga[2]
	frame:SetBackdropColor(theme.bg[1], theme.bg[2], theme.bg[3], a)
	frame:SetBackdropBorderColor(theme.border[1], theme.border[2], theme.border[3], theme.border[4] or 0.45)
	local function paint(fs, color)
		if fs then
			fs:SetTextColor(color[1], color[2], color[3])
		end
	end
	paint(frame.title, theme.title)
	paint(frame.clock, theme.text)
	paint(frame.gold, theme.title)
	paint(frame.catchChip and frame.catchChip.text, theme.text)
	if frame.pauseBtn and frame.pauseBtn.text then
		paint(frame.pauseBtn.text, theme.muted)
	end
	if frame.reset and frame.reset.text then
		paint(frame.reset.text, theme.muted)
	end
	if frame.exportBtn and frame.exportBtn.text then
		paint(frame.exportBtn.text, theme.muted)
	end
	if frame.priceBtn and frame.priceBtn.text then
		paint(frame.priceBtn.text, theme.title)
	end
	if frame.sizeBtn and frame.sizeBtn.text then
		paint(frame.sizeBtn.text, theme.title)
	end
	if frame.close and frame.close.text then
		paint(frame.close.text, theme.muted)
	end
	paint(frame.dash1, theme.muted)
	paint(frame.dash2, theme.muted)
	local pipes = { frame.sep1, frame.sep2, frame.sep3, frame.sep4, frame.sep5 }
	for i = 1, #pipes do
		paint(pipes[i], theme.muted)
	end
	if frame.rule then
		frame.rule:SetColorTexture(theme.sep[1], theme.sep[2], theme.sep[3], theme.sep[4] or 0.45)
	end
	if frame.rule2 then
		frame.rule2:SetColorTexture(theme.sep[1], theme.sep[2], theme.sep[3], theme.sep[4] or 0.45)
	end
end

function FK:SaveFramePosition()
	local frame = self.frame
	if not frame then
		return
	end
	local point, _, rel, x, y = frame:GetPoint()
	local s = self.db.settings
	s.point = point or "CENTER"
	s.relPoint = rel or "CENTER"
	s.x = x or 0
	s.y = y or 0
end

function FK:ToggleCompact()
	if self.confirm and self.confirm:IsShown() then
		self.confirm:Hide()
	end
	local s = self.db.settings
	s.compact = not s.compact
	self.userExpanded = not s.compact
	if s.compact and self.options then
		self.options:Hide()
	end
	if s.compact and self.export then
		self.export:Hide()
	end
	self:ApplyLayout()
	self:RefreshUI()
end

function FK:TogglePriceMode()
	local s = self.db.settings
	if s.priceMode == "minbuyout" then
		s.priceMode = "region"
	else
		s.priceMode = "minbuyout"
	end
	self:UpdateUI()
end

function FK:ApplyLayout()
	local frame = self.frame
	if not frame then
		return
	end
	local compact = self.db.settings.compact
	frame:SetSize(WIDE, compact and COMPACT_H or EXPANDED_H)
	self:ApplyTheme()

	if compact then
		frame.title:Hide()
		frame.sub:Hide()
		frame.footer:Hide()
		frame.grand:Hide()
		if frame.venom then
			frame.venom:Hide()
		end
		if frame.venomIcon then
			frame.venomIcon:Hide()
		end
		if frame.colHead then
			frame.colHead:Hide()
		end
		if frame.rule then
			frame.rule:Hide()
		end
		if frame.rule2 then
			frame.rule2:Hide()
		end
		if self.body then
			self.body:Hide()
		end
		if self.options then
			self.options:Hide()
		end
		if frame.grandIcon then
			frame.grandIcon:Hide()
		end
		if frame.compactBar then
			frame.compactBar:Show()
		end
		if frame.stats then
			frame.stats:Hide()
		end
		frame.gear:Hide()
		frame.sizeBtn:ClearAllPoints()
		frame.sizeBtn:SetPoint("LEFT", 6, 0)
		frame.close:ClearAllPoints()
		frame.close:SetPoint("RIGHT", -4, 0)
		frame.priceBtn:SetWidth(70)
		frame.priceBtn:ClearAllPoints()
		frame.priceBtn:SetPoint("RIGHT", frame.close, "LEFT", -2, 0)
		if frame.dash2 then
			frame.dash2:Show()
			frame.dash2:ClearAllPoints()
			frame.dash2:SetPoint("RIGHT", frame.priceBtn, "LEFT", -2, 0)
		end
		frame.reset:Show()
		frame.reset:SetWidth(58)
		frame.reset:ClearAllPoints()
		if frame.dash2 then
			frame.reset:SetPoint("RIGHT", frame.dash2, "LEFT", -2, 0)
		else
			frame.reset:SetPoint("RIGHT", frame.priceBtn, "LEFT", -4, 0)
		end
		if frame.dash1 then
			frame.dash1:Show()
			frame.dash1:ClearAllPoints()
			frame.dash1:SetPoint("RIGHT", frame.reset, "LEFT", -2, 0)
		end
		frame.pauseBtn:SetWidth(58)
		frame.pauseBtn:ClearAllPoints()
		if frame.dash1 then
			frame.pauseBtn:SetPoint("RIGHT", frame.dash1, "LEFT", -2, 0)
		else
			frame.pauseBtn:SetPoint("RIGHT", frame.reset, "LEFT", -4, 0)
		end
		if frame.compactBar then
			frame.compactBar:ClearAllPoints()
			frame.compactBar:SetPoint("LEFT", frame.sizeBtn, "RIGHT", 8, 0)
			frame.compactBar:SetPoint("RIGHT", frame.pauseBtn, "LEFT", -8, 0)
			frame.compactBar:SetHeight(20)
		end
		if frame.sep5 then
			frame.sep5:Show()
			frame.sep5:ClearAllPoints()
			frame.sep5:SetPoint("RIGHT", frame.compactBar, "RIGHT", 0, 0)
		end
		if frame.rateHit and frame.gold then
			frame.rateHit:ClearAllPoints()
			frame.rateHit:SetPoint("TOPLEFT", frame.gold, "TOPLEFT", 0, 2)
			frame.rateHit:SetPoint("BOTTOMRIGHT", frame.gold, "BOTTOMRIGHT", 0, -2)
		end
		frame.last:ClearAllPoints()
		frame.last:SetPoint("LEFT", frame.sep3, "RIGHT", 6, 0)
		frame.last:SetJustifyH("LEFT")
		frame.last:Show()
		if frame.venomChip then
			frame.venomChip:Hide()
		end
		if frame.exportBtn then
			frame.exportBtn:Hide()
		end
		if self.export then
			self.export:Hide()
		end
		frame.sizeBtn.text:SetText("+")
	else
		frame.title:Show()
		frame.sub:Show()
		frame.footer:Show()
		frame.grand:Show()
		if frame.grandIcon then
			frame.grandIcon:Show()
		end
		if frame.compactBar then
			frame.compactBar:Hide()
		end
		if frame.stats then
			frame.stats:Show()
		end
		if frame.venomChip then
			frame.venomChip:Hide()
		end
		if frame.venom then
			frame.venom:Show()
		end
		if frame.colHead then
			frame.colHead:Show()
		end
		if frame.rule then
			frame.rule:Show()
		end
		if frame.rule2 then
			frame.rule2:Show()
		end
		if self.options and self.options:IsShown() then
			self.body:Hide()
		elseif self.body then
			self.body:Show()
		end
		frame.gear:Show()
		frame.sizeBtn:ClearAllPoints()
		frame.sizeBtn:SetPoint("TOPLEFT", 6, -8)
		frame.close:ClearAllPoints()
		frame.close:SetPoint("TOPRIGHT", -4, -8)
		frame.priceBtn:SetWidth(70)
		frame.priceBtn:ClearAllPoints()
		frame.priceBtn:SetPoint("TOPRIGHT", frame.close, "TOPLEFT", -2, 0)
		if frame.dash1 then
			frame.dash1:Hide()
		end
		if frame.dash2 then
			frame.dash2:Hide()
		end
		if frame.sep5 then
			frame.sep5:Hide()
		end
		frame.gear:ClearAllPoints()
		frame.gear:SetPoint("TOPRIGHT", frame.priceBtn, "TOPLEFT", -2, 0)
		frame.pauseBtn:SetWidth(58)
		frame.pauseBtn:ClearAllPoints()
		frame.pauseBtn:SetPoint("TOPRIGHT", frame.gear, "TOPLEFT", -4, 1)
		frame.reset:Show()
		frame.reset:SetWidth(58)
		frame.reset:ClearAllPoints()
		frame.reset:SetPoint("BOTTOMRIGHT", -10, 34)
		if frame.exportBtn then
			frame.exportBtn:Show()
			frame.exportBtn:SetWidth(58)
			frame.exportBtn:ClearAllPoints()
			frame.exportBtn:SetPoint("TOP", frame.reset, "BOTTOM", 0, -1)
		end
		frame.stats:ClearAllPoints()
		frame.stats:SetPoint("TOPLEFT", 14, -28)
		frame.stats:SetPoint("RIGHT", frame.pauseBtn, "LEFT", -8, 0)
		if frame.rateHit then
			frame.rateHit:ClearAllPoints()
			frame.rateHit:SetPoint("LEFT", frame.stats, "LEFT", 0, 0)
			frame.rateHit:SetPoint("RIGHT", frame.stats, "RIGHT", 0, 0)
			frame.rateHit:SetHeight(16)
		end
		frame.last:Hide()
		frame.sizeBtn.text:SetText("-")
	end
	self:RefreshPauseButton()
	self:ApplyTheme()
end

function FK:CreateUI()
	if self.frame then
		return
	end

	local frame = CreateFrame("Frame", "FishKeeperFrame", UIParent, "BackdropTemplate")
	frame:SetSize(WIDE, COMPACT_H)
	frame:SetFrameStrata("MEDIUM")
	frame:SetToplevel(true)
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(selfFrame)
		if not FK.db.settings.lockWindow then
			selfFrame:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", function(selfFrame)
		selfFrame:StopMovingOrSizing()
		FK:SaveFramePosition()
	end)
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 8,
		edgeSize = 12,
		insets = { left = 3, right = 3, top = 3, bottom = 3 },
	})
	frame:SetBackdropColor(0.04, 0.05, 0.06, 0.42)
	frame:SetBackdropBorderColor(0.55, 0.58, 0.60, 0.45)

	local s = self.db.settings
	frame:ClearAllPoints()
	frame:SetPoint(s.point or "CENTER", UIParent, s.relPoint or "CENTER", s.x or 0, s.y or 0)
	frame:SetScale(s.scale or 1)

	local sizeBtn = TinyButton(frame, 18, "+")
	sizeBtn:SetPoint("LEFT", 6, 0)
	sizeBtn:SetScript("OnClick", function()
		FK:ToggleCompact()
	end)
	sizeBtn:SetScript("OnEnter", function(selfBtn)
		GameTooltip:SetOwner(selfBtn, "ANCHOR_RIGHT")
		GameTooltip:SetText(FK.db.settings.compact and "Expand" or "Compact")
		GameTooltip:Show()
	end)
	sizeBtn:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	frame.sizeBtn = sizeBtn

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOP", 0, -8)
	title:SetText("FishKeeper")
	frame.title = title

	local close = TinyButton(frame, 18, "x")
	close:SetPoint("RIGHT", -4, 0)
	close:SetScript("OnClick", function()
		frame:Hide()
		FK.db.settings.shown = false
	end)
	frame.close = close

	local priceBtn = TinyButton(frame, 70, "[Region]")
	priceBtn:SetPoint("RIGHT", close, "LEFT", -2, 0)
	priceBtn:SetScript("OnClick", function()
		FK:TogglePriceMode()
	end)
	priceBtn:SetScript("OnEnter", function(selfBtn)
		GameTooltip:SetOwner(selfBtn, "ANCHOR_LEFT")
		GameTooltip:SetText("TSM price")
		GameTooltip:AddLine("Region avg  or  Min buyout", 1, 1, 1)
		GameTooltip:Show()
	end)
	priceBtn:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	frame.priceBtn = priceBtn

	local reset = TinyButton(frame, 58, "[Reset]")
	reset:SetPoint("RIGHT", priceBtn, "LEFT", -2, 0)
	reset:SetScript("OnClick", function()
		FK:ConfirmReset()
	end)
	reset:SetScript("OnEnter", function(selfBtn)
		GameTooltip:SetOwner(selfBtn, "ANCHOR_LEFT")
		GameTooltip:SetText("Reset session")
		GameTooltip:Show()
	end)
	frame.reset = reset

	local exportBtn = TinyButton(frame, 58, "[Export]")
	exportBtn:SetPoint("TOP", reset, "BOTTOM", 0, -1)
	exportBtn:Hide()
	exportBtn:SetScript("OnClick", function()
		FK:ShowExport()
	end)
	exportBtn:SetScript("OnEnter", function(selfBtn)
		GameTooltip:SetOwner(selfBtn, "ANCHOR_LEFT")
		GameTooltip:SetText("Export session")
		GameTooltip:AddLine("Copy as text. Paste into chat, Discord, or a spreadsheet.", 1, 1, 1)
		GameTooltip:Show()
	end)
	frame.exportBtn = exportBtn

	local pauseBtn = TinyButton(frame, 58, "[Pause]")
	pauseBtn:SetPoint("RIGHT", reset, "LEFT", -4, 0)
	pauseBtn:SetScript("OnClick", function()
		FK:TogglePause()
	end)
	pauseBtn:SetScript("OnEnter", function(selfBtn)
		GameTooltip:SetOwner(selfBtn, "ANCHOR_LEFT")
		if not FK:Session().started then
			GameTooltip:SetText("Timer starts on your first cast")
		else
			GameTooltip:SetText(FK:IsPaused() and "Start timer" or "Pause timer")
			GameTooltip:AddLine("Loot still counts.", 1, 1, 1)
		end
		GameTooltip:Show()
	end)
	frame.pauseBtn = pauseBtn

	local dash1 = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	dash1:SetText("-")
	dash1:Hide()
	frame.dash1 = dash1
	local dash2 = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	dash2:SetText("-")
	dash2:Hide()
	frame.dash2 = dash2

	local gear = CreateFrame("Button", nil, frame)
	gear:SetSize(16, 16)
	gear:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
	gear:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	gear:SetPoint("RIGHT", priceBtn, "LEFT", -2, 0)
	gear:SetScript("OnClick", function()
		if FK.db.settings.compact then
			FK.db.settings.compact = false
			FK.userExpanded = true
			FK:ApplyLayout()
		end
		if FK.export then
			FK.export:Hide()
		end
		if FK.confirm then
			FK.confirm:Hide()
		end
		if FK.options:IsShown() then
			FK.options:Hide()
			FK.body:Show()
			if FK.frame.colHead then
				FK.frame.colHead:Show()
			end
		else
			FK.body:Hide()
			FK.options:Show()
			if FK.frame.colHead then
				FK.frame.colHead:Hide()
			end
			FK:RefreshOptions()
		end
	end)
	gear:SetScript("OnEnter", function(selfBtn)
		GameTooltip:SetOwner(selfBtn, "ANCHOR_LEFT")
		GameTooltip:SetText("Options")
		GameTooltip:Show()
	end)
	gear:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	frame.gear = gear

	local stats = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	stats:SetJustifyH("LEFT")
	stats:SetWordWrap(false)
	frame.stats = stats

	local rateHit = CreateFrame("Button", nil, frame)
	rateHit:SetHeight(16)
	rateHit:EnableMouse(true)
	rateHit:SetScript("OnEnter", function(selfBtn)
		local totals = FK:SessionTotals()
		local gph, cph = FK:GoldPerHour(totals)
		GameTooltip:SetOwner(selfBtn, "ANCHOR_BOTTOM")
		GameTooltip:SetText("Session rate")
		GameTooltip:AddLine("Gold/hour   " .. FK:FormatMoney(gph), 1, 0.82, 0)
		GameTooltip:AddLine(string.format("Catches/hour   %.1f", cph), 1, 1, 1)
		if (totals.elapsed or 0) < 60 then
			GameTooltip:AddLine("More accurate after a minute.", 0.6, 0.65, 0.68)
		end
		GameTooltip:Show()
	end)
	rateHit:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	frame.rateHit = rateHit

	local last = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	last:SetJustifyH("LEFT")
	last:SetWordWrap(false)
	frame.last = last

	local compactBar = CreateFrame("Frame", nil, frame)
	compactBar:SetHeight(20)
	frame.compactBar = compactBar

	local catchChip = MakeChip(compactBar, 14)
	catchChip:SetPoint("LEFT", 0, 0)
	catchChip:SetWidth(40)
	catchChip.icon:SetTexture("Interface\\Icons\\Trade_Fishing")
	catchChip:SetScript("OnEnter", function(selfBtn)
		GameTooltip:SetOwner(selfBtn, "ANCHOR_BOTTOM")
		GameTooltip:SetText("Catches this session")
		GameTooltip:Show()
	end)
	frame.catchChip = catchChip

	local sep1 = MakePipe(compactBar)
	sep1:SetPoint("LEFT", catchChip, "RIGHT", 6, 0)
	frame.sep1 = sep1

	local clock = compactBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	clock:SetPoint("LEFT", sep1, "RIGHT", 6, 0)
	clock:SetJustifyH("LEFT")
	frame.clock = clock

	local sep2 = MakePipe(compactBar)
	sep2:SetPoint("LEFT", clock, "RIGHT", 6, 0)
	frame.sep2 = sep2

	local gold = compactBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	gold:SetPoint("LEFT", sep2, "RIGHT", 6, 0)
	gold:SetJustifyH("LEFT")
	frame.gold = gold

	local sep3 = MakePipe(compactBar)
	sep3:SetPoint("LEFT", gold, "RIGHT", 6, 0)
	frame.sep3 = sep3

	local sep4 = MakePipe(compactBar)
	sep4:Hide()
	frame.sep4 = sep4

	local sep5 = MakePipe(compactBar)
	sep5:SetPoint("RIGHT", 0, 0)
	frame.sep5 = sep5

	-- last fish is parented to compactBar in compact layout
	last:SetParent(compactBar)

	local sub = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	sub:SetPoint("TOPLEFT", 14, -44)
	sub:SetJustifyH("LEFT")
	frame.sub = sub

	local rule = frame:CreateTexture(nil, "ARTWORK")
	rule:SetColorTexture(0.35, 0.38, 0.40, 0.45)
	rule:SetHeight(1)
	rule:SetPoint("TOPLEFT", 10, -60)
	rule:SetPoint("TOPRIGHT", -10, -60)
	frame.rule = rule

	local colHead = CreateFrame("Frame", nil, frame)
	colHead:SetPoint("TOPLEFT", 10, -62)
	colHead:SetPoint("TOPRIGHT", -10, -62)
	colHead:SetHeight(16)
	frame.colHead = colHead

	local colGold = MakeColHeader(colHead, "Value", 130, "RIGHT", "value")
	colGold:SetPoint("RIGHT", -6, 0)
	local colRate = MakeColHeader(colHead, "%", 40, "RIGHT", "rate")
	colRate:SetPoint("RIGHT", colGold, "LEFT", -8, 0)
	local colQty = MakeColHeader(colHead, "Qty", 52, "RIGHT", "count")
	colQty:SetPoint("RIGHT", colRate, "LEFT", -8, 0)
	local colName = MakeColHeader(colHead, "Catch", nil, "LEFT", "name")
	colName:SetPoint("LEFT", 22, 0)
	colName:SetPoint("RIGHT", colQty, "LEFT", -8, 0)
	frame.colName = colName
	frame.colQty = colQty
	frame.colRate = colRate
	frame.colGold = colGold

	-- Catch list
	local body = CreateFrame("Frame", nil, frame)
	body:SetPoint("TOPLEFT", 8, -78)
	body:SetPoint("BOTTOMRIGHT", -8, 56)
	self.body = body

	local scroll = CreateFrame("ScrollFrame", "FishKeeperScroll", body)
	scroll:SetPoint("TOPLEFT", 2, -2)
	scroll:SetPoint("BOTTOMRIGHT", -2, 2)
	scroll:EnableMouseWheel(true)
	scroll:SetScript("OnMouseWheel", function(selfScroll, delta)
		local cur = selfScroll:GetVerticalScroll()
		local max = selfScroll:GetVerticalScrollRange() or 0
		selfScroll:SetVerticalScroll(math.min(max, math.max(0, cur - delta * ROW_HEIGHT * 3)))
	end)
	local child = CreateFrame("Frame", "FishKeeperScrollChild", scroll)
	child:SetSize(WIDE - 24, VISIBLE_ROWS * ROW_HEIGHT)
	scroll:SetScrollChild(child)
	frame.scroll = scroll
	frame.child = child
	frame.rows = {}

	for i = 1, 80 do
		local row = CreateFrame("Button", nil, child)
		row:SetHeight(ROW_HEIGHT)
		row:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_HEIGHT)
		row:SetPoint("TOPRIGHT", 0, -(i - 1) * ROW_HEIGHT)
		row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		row:Hide()

		row.icon = row:CreateTexture(nil, "ARTWORK")
		row.icon:SetSize(16, 16)
		row.icon:SetPoint("LEFT", 2, 0)
		row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.name:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
		row.name:SetPoint("RIGHT", row, "RIGHT", -246, 0)
		row.name:SetJustifyH("LEFT")
		row.name:SetWordWrap(false)

		row.count = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.count:SetPoint("RIGHT", row, "RIGHT", -186, 0)
		row.count:SetJustifyH("RIGHT")
		row.count:SetWidth(52)
		row.count:SetWordWrap(false)

		row.rate = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		row.rate:SetPoint("RIGHT", row, "RIGHT", -138, 0)
		row.rate:SetJustifyH("RIGHT")
		row.rate:SetWidth(40)
		row.rate:SetWordWrap(false)

		row.value = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.value:SetPoint("RIGHT", row, "RIGHT", -6, 0)
		row.value:SetJustifyH("RIGHT")
		row.value:SetWidth(124)
		row.value:SetWordWrap(false)

		row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
		row:SetScript("OnEnter", function(selfRow)
			if selfRow.link then
				GameTooltip:SetOwner(selfRow, "ANCHOR_RIGHT")
				GameTooltip:SetHyperlink(selfRow.link)
				GameTooltip:Show()
			end
		end)
		row:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		row:SetScript("OnClick", function(selfRow)
			if selfRow.link and ChatEdit_InsertLink and IsModifiedClick("CHATLINK") then
				ChatEdit_InsertLink(selfRow.link)
			end
		end)

		frame.rows[i] = row
	end

	-- Options
	local options = CreateFrame("Frame", nil, frame)
	options:SetPoint("TOPLEFT", 8, -78)
	options:SetPoint("BOTTOMRIGHT", -8, 56)
	options:Hide()
	self.options = options

	local function AddCheckbox(parent, y, label, key, onChange)
		local box = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
		box:SetPoint("TOPLEFT", 8, y)
		box:SetSize(22, 22)
		local text = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		text:SetPoint("LEFT", box, "RIGHT", 2, 0)
		text:SetText(label)
		box:SetScript("OnClick", function(selfBox)
			FK.db.settings[key] = selfBox:GetChecked() and true or false
			if onChange then
				onChange()
			end
			FK:UpdateUI()
		end)
		box.key = key
		return box
	end

	options.compactOnFish = AddCheckbox(options, -4, "Compact when I start fishing", "compactOnFish", function()
		if FK.db.settings.compactOnFish and FK:IsFishingSpell() then
			FK.userExpanded = false
			FK.db.settings.compact = true
			FK:ApplyLayout()
		end
	end)
	options.announce = AddCheckbox(options, -26, "Announce catches", "announce")
	options.trackJunk = AddCheckbox(options, -48, "Count junk", "trackJunk")
	options.lockWindow = AddCheckbox(options, -70, "Lock window", "lockWindow")
	options.resetSessionOnLogin = AddCheckbox(options, -92, "Reset session on login", "resetSessionOnLogin")

	local themeLabel = options:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	themeLabel:SetPoint("TOPLEFT", 12, -120)
	themeLabel:SetText("Theme")
	options.themeBtns = {}
	for i = 1, #THEME_ORDER do
		local id = THEME_ORDER[i]
		local t = THEMES[id]
		local b = CreateFrame("Button", nil, options, "BackdropTemplate")
		b:SetSize(18, 18)
		b:SetPoint("TOPLEFT", 58 + (i - 1) * 22, -118)
		b:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8X8",
			edgeFile = "Interface\\Buttons\\WHITE8X8",
			edgeSize = 1,
		})
		b:SetBackdropColor(t.swatch[1], t.swatch[2], t.swatch[3], 1)
		b:SetBackdropBorderColor(0.15, 0.15, 0.15, 0.9)
		b:SetScript("OnClick", function()
			FK:SetTheme(id)
		end)
		b:SetScript("OnEnter", function(selfBtn)
			GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
			GameTooltip:SetText(t.label)
			GameTooltip:Show()
		end)
		b:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		b.themeId = id
		options.themeBtns[i] = b
	end

	local hint = options:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	hint:SetPoint("TOPLEFT", 12, -144)
	hint:SetPoint("RIGHT", -12, 0)
	hint:SetJustifyH("LEFT")
	hint:SetText("Prices: Region avg or Min buyout.\nAnnounce replaces default loot chat while fishing.")

	local footer = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	footer:SetPoint("BOTTOMLEFT", 12, 36)
	footer:SetJustifyH("LEFT")
	frame.footer = footer

	local rule2 = frame:CreateTexture(nil, "ARTWORK")
	rule2:SetColorTexture(0.35, 0.38, 0.40, 0.45)
	rule2:SetHeight(1)
	rule2:SetPoint("BOTTOMLEFT", 10, 50)
	rule2:SetPoint("BOTTOMRIGHT", -10, 50)
	frame.rule2 = rule2

	local grandIcon = frame:CreateTexture(nil, "ARTWORK")
	grandIcon:SetSize(12, 12)
	grandIcon:SetPoint("BOTTOMLEFT", 12, 22)
	grandIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	frame.grandIcon = grandIcon

	local grand = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	grand:SetPoint("LEFT", grandIcon, "RIGHT", 4, 0)
	grand:SetJustifyH("LEFT")
	frame.grand = grand

	local venomIcon = frame:CreateTexture(nil, "ARTWORK")
	venomIcon:SetSize(12, 12)
	venomIcon:SetPoint("BOTTOMLEFT", 12, 8)
	venomIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	venomIcon:Hide()
	frame.venomIcon = venomIcon

	local venom = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	venom:SetPoint("LEFT", venomIcon, "RIGHT", 4, 0)
	venom:SetJustifyH("LEFT")
	frame.venom = venom

	local venomChip = CreateFrame("Button", nil, frame)
	venomChip:SetSize(44, 18)
	venomChip:Hide()
	local chipIcon = venomChip:CreateTexture(nil, "ARTWORK")
	chipIcon:SetSize(14, 14)
	chipIcon:SetPoint("LEFT", 0, 0)
	chipIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	venomChip.icon = chipIcon
	local chipText = venomChip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	chipText:SetPoint("LEFT", chipIcon, "RIGHT", 3, 0)
	chipText:SetTextColor(0.15, 0.85, 0.32)
	venomChip.text = chipText
	venomChip:SetScript("OnEnter", function(selfBtn)
		GameTooltip:SetOwner(selfBtn, "ANCHOR_BOTTOM")
		GameTooltip:SetText("Venom: " .. tostring(selfBtn.amount or 0))
		GameTooltip:Show()
	end)
	venomChip:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	frame.venomChip = venomChip

	-- Reset confirmation overlay
	local confirm = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	confirm:SetAllPoints(frame)
	confirm:SetFrameStrata("HIGH")
	confirm:EnableMouse(true)
	confirm:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 8,
		edgeSize = 12,
		insets = { left = 3, right = 3, top = 3, bottom = 3 },
	})
	confirm:SetBackdropColor(0.05, 0.06, 0.07, 0.94)
	confirm:SetBackdropBorderColor(0.55, 0.58, 0.60, 0.7)
	confirm:Hide()
	self.confirm = confirm

	local cTitle = confirm:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	cTitle:SetPoint("TOP", 0, -16)
	cTitle:SetText("Reset this session?")
	confirm.title = cTitle

	local cBody = confirm:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	cBody:SetPoint("TOPLEFT", 16, -40)
	cBody:SetPoint("TOPRIGHT", -16, -40)
	cBody:SetJustifyH("LEFT")
	confirm.body = cBody

	local yes = CreateFrame("Button", nil, confirm, "UIPanelButtonTemplate")
	yes:SetSize(80, 22)
	yes:SetPoint("BOTTOMRIGHT", -14, 12)
	yes:SetText("Reset")
	yes:SetScript("OnClick", function()
		confirm:Hide()
		FK:ResetSession()
	end)

	local no = CreateFrame("Button", nil, confirm, "UIPanelButtonTemplate")
	no:SetSize(80, 22)
	no:SetPoint("RIGHT", yes, "LEFT", -8, 0)
	no:SetText("Cancel")
	no:SetScript("OnClick", function()
		confirm:Hide()
	end)

	-- Export overlay
	local export = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	export:SetAllPoints(frame)
	export:SetFrameStrata("HIGH")
	export:EnableMouse(true)
	export:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 8,
		edgeSize = 12,
		insets = { left = 3, right = 3, top = 3, bottom = 3 },
	})
	export:SetBackdropColor(0.05, 0.06, 0.07, 0.94)
	export:SetBackdropBorderColor(0.55, 0.58, 0.60, 0.7)
	export:Hide()
	self.export = export

	local eTitle = export:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	eTitle:SetPoint("TOP", 0, -12)
	eTitle:SetText("Export session")
	export.title = eTitle

	local eHint = export:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	eHint:SetPoint("TOP", eTitle, "BOTTOM", 0, -2)
	eHint:SetText("Ctrl+C to copy")
	export.hint = eHint

	local eScroll = CreateFrame("ScrollFrame", "FishKeeperExportScroll", export)
	eScroll:SetPoint("TOPLEFT", 14, -40)
	eScroll:SetPoint("BOTTOMRIGHT", -14, 38)
	eScroll:EnableMouseWheel(true)
	eScroll:SetScript("OnMouseWheel", function(selfScroll, delta)
		local cur = selfScroll:GetVerticalScroll()
		local max = selfScroll:GetVerticalScrollRange() or 0
		selfScroll:SetVerticalScroll(math.min(max, math.max(0, cur - delta * 24)))
	end)
	export.scroll = eScroll

	local eEdit = CreateFrame("EditBox", "FishKeeperExportEdit", eScroll)
	eEdit:SetMultiLine(true)
	eEdit:SetAutoFocus(false)
	if not pcall(eEdit.SetFont, eEdit, "Fonts\\ARIALN.TTF", 12, "") then
		eEdit:SetFontObject(GameFontHighlightSmall)
	end
	eEdit:SetMaxLetters(0)
	eEdit:SetTextInsets(2, 2, 2, 2)
	eEdit:SetScript("OnEscapePressed", function(selfBox)
		selfBox:ClearFocus()
		export:Hide()
	end)
	eEdit:SetScript("OnEditFocusGained", function(selfBox)
		selfBox:HighlightText()
	end)
	eEdit:SetScript("OnTextChanged", function(selfBox, userInput)
		if userInput then
			selfBox:SetText(FK._exportText or "")
			selfBox:HighlightText()
		end
	end)
	eScroll:SetScrollChild(eEdit)
	export.edit = eEdit

	local eClose = CreateFrame("Button", nil, export, "UIPanelButtonTemplate")
	eClose:SetSize(80, 22)
	eClose:SetPoint("BOTTOMRIGHT", -14, 10)
	eClose:SetText("Close")
	eClose:SetScript("OnClick", function()
		eEdit:ClearFocus()
		export:Hide()
	end)

	local eDiscord = TinyButton(export, 70, "[Discord]")
	eDiscord:SetPoint("BOTTOMLEFT", 14, 12)
	eDiscord:SetScript("OnClick", function()
		FK:SetExportFormat("discord")
	end)
	eDiscord:SetScript("OnEnter", function(selfBtn)
		GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
		GameTooltip:SetText("Discord")
		GameTooltip:AddLine("Wraps the dump in ``` so columns stay aligned.", 1, 1, 1)
		GameTooltip:Show()
	end)
	export.discordBtn = eDiscord

	local eWowhead = TinyButton(export, 78, "[Wowhead]")
	eWowhead:SetPoint("LEFT", eDiscord, "RIGHT", 4, 0)
	eWowhead:SetScript("OnClick", function()
		FK:SetExportFormat("wowhead")
	end)
	eWowhead:SetScript("OnEnter", function(selfBtn)
		GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
		GameTooltip:SetText("Wowhead")
		GameTooltip:AddLine("Wraps the dump in [code] so columns stay aligned.", 1, 1, 1)
		GameTooltip:Show()
	end)
	export.wowheadBtn = eWowhead

	export:SetScript("OnShow", function()
		local w = math.max(220, (export:GetWidth() or WIDE) - 36)
		eEdit:SetWidth(w)
	end)

	frame:SetScript("OnShow", function()
		FK.db.settings.shown = true
		FK:ApplyLayout()
		FK:RefreshUI()
	end)
	frame:SetScript("OnUpdate", function(_, elapsed)
		FK._tick = (FK._tick or 0) + elapsed
		if FK._tick < 0.25 then
			return
		end
		FK._tick = 0
		if FK.RefreshTimer then
			FK:RefreshTimer()
		end
	end)

	self.frame = frame
	self:ApplyLayout()
	if s.shown then
		frame:Show()
	else
		frame:Hide()
	end
end

function FK:ConfirmReset()
	if not self.frame then
		self:CreateUI()
	end
	local totals = self:SessionTotals()
	if (totals.catches or 0) == 0 and (totals.items or 0) == 0 and (totals.copper or 0) == 0 then
		self:ResetSession()
		return
	end
	if self.db.settings.compact then
		self.db.settings.compact = false
		self.userExpanded = true
		self:ApplyLayout()
	end
	local list = self:SortedItems(self:Session().items)
	local lines = {
		string.format("%d catches    %s    %s", totals.catches, self:FormatDuration(totals.elapsed), self:FormatMoney(totals.copper)),
		string.format("%d items    %d chest%s", totals.items, totals.treasures or 0, (totals.treasures or 0) == 1 and "" or "s"),
		"",
		"This session will be cleared. Lifetime is kept.",
		"",
	}
	local n = math.min(4, #list)
	if n > 0 then
		lines[#lines + 1] = "Top loot:"
		for i = 1, n do
			local row = list[i]
			lines[#lines + 1] = string.format("  %s  x%d", row.name or "?", row.count or 0)
		end
	end
	self.confirm.body:SetText(table.concat(lines, "\n"))
	if self.options then
		self.options:Hide()
	end
	if self.export then
		self.export:Hide()
	end
	if self.body then
		self.body:Show()
	end
	self.confirm:Show()
	self:RefreshUI()
end

function FK:ShowExportOverlay()
	if not self.frame then
		self:CreateUI()
	end
	if not self.export then
		return
	end
	local text = self:BuildExportText()
	self._exportText = text
	local edit = self.export.edit
	if edit then
		local w = math.max(220, (self.export:GetWidth() or WIDE) - 36)
		edit:SetWidth(w)
		edit:SetText(text)
		edit:SetCursorPosition(0)
		edit:HighlightText()
		edit:SetFocus()
	end
	self:RefreshExportFormatButtons()
	if self.confirm then
		self.confirm:Hide()
	end
	if self.options then
		self.options:Hide()
	end
	self.export:Show()
	self:RefreshUI()
end

function FK:RefreshExportFormatButtons()
	local export = self.export
	if not export then
		return
	end
	local theme = self:Theme()
	local mode = self.db and self.db.settings.exportFormat or "discord"
	local function paint(btn, active)
		if not btn or not btn.text then
			return
		end
		if active then
			btn.text:SetTextColor(theme.title[1], theme.title[2], theme.title[3])
		else
			btn.text:SetTextColor(theme.muted[1], theme.muted[2], theme.muted[3])
		end
	end
	paint(export.discordBtn, mode == "discord")
	paint(export.wowheadBtn, mode == "wowhead")
	if export.hint then
		if mode == "wowhead" then
			export.hint:SetText("Ctrl+C to copy. Paste into Wowhead.")
		else
			export.hint:SetText("Ctrl+C to copy. Paste into Discord.")
		end
	end
end

function FK:RefreshPauseButton()
	local frame = self.frame
	if not frame or not frame.pauseBtn then
		return
	end
	frame.pauseBtn.text:SetText(self:IsPaused() and "[Start]" or "[Pause]")
	if frame.reset and frame.reset.text then
		frame.reset.text:SetText("[Reset]")
	end
	if frame.exportBtn and frame.exportBtn.text then
		frame.exportBtn.text:SetText("[Export]")
	end
end

function FK:RefreshSortHeaders()
	local frame = self.frame
	if not frame then
		return
	end
	local theme = self:Theme()
	local mode = self.db and self.db.settings.sort or "value"
	local arrow = (self.db and self.db.settings.sortDir == "asc") and " ^" or " v"
	local cols = {
		{ btn = frame.colName, id = "name" },
		{ btn = frame.colQty, id = "count" },
		{ btn = frame.colRate, id = "rate" },
		{ btn = frame.colGold, id = "value" },
	}
	for i = 1, #cols do
		local col = cols[i]
		local btn = col.btn
		if btn and btn.text then
			if col.id == mode then
				btn.text:SetText(btn.label .. arrow)
				btn.text:SetTextColor(theme.title[1], theme.title[2], theme.title[3])
			else
				btn.text:SetText(btn.label)
				btn.text:SetTextColor(theme.muted[1], theme.muted[2], theme.muted[3])
			end
		end
	end
end

function FK:RefreshTimer()
	local frame = self.frame
	if not frame or not frame:IsShown() or not self.db then
		return
	end
	local totals = self:SessionTotals()
	local clock = self:FormatDuration(totals.elapsed)
	if totals.paused then
		clock = clock .. "  paused"
	end
	if self.db.settings.compact then
		if frame.catchChip then
			frame.catchChip.icon:SetTexture(self:FishIconTexture())
			frame.catchChip.text:SetText(tostring(totals.catches or 0))
			local cw = 16 + 3 + (frame.catchChip.text:GetStringWidth() or 12)
			frame.catchChip:SetWidth(math.max(32, cw))
		end
		if frame.clock then
			frame.clock:SetText(clock)
		end
		if frame.gold then
			frame.gold:SetText(self:FormatMoney(totals.copper))
		end
	else
		frame.stats:SetText(string.format("%d catches    %s    %s", totals.catches, clock, self:FormatMoney(totals.copper)))
	end
	self:RefreshVenomDisplay()
end

function FK:RefreshVenomDisplay()
	local frame = self.frame
	if not frame then
		return
	end
	local equipped, amount = self:GetHuntressVenom()
	local tex = self:VenomIconTexture()
	if not equipped then
		if frame.venomChip then
			frame.venomChip:Hide()
		end
		if frame.venom then
			frame.venom:Hide()
		end
		if frame.venomIcon then
			frame.venomIcon:Hide()
		end
		if frame.grand and not self.db.settings.compact then
			if frame.grandIcon then
				frame.grandIcon:ClearAllPoints()
				frame.grandIcon:SetPoint("BOTTOMLEFT", 12, 8)
				frame.grand:ClearAllPoints()
				frame.grand:SetPoint("LEFT", frame.grandIcon, "RIGHT", 4, 0)
			else
				frame.grand:ClearAllPoints()
				frame.grand:SetPoint("BOTTOMLEFT", 12, 8)
			end
		end
		if self.db.settings.compact then
			if frame.sep5 then
				frame.sep5:Show()
			end
			if frame.last then
				frame.last:ClearAllPoints()
				frame.last:SetPoint("LEFT", frame.sep3, "RIGHT", 6, 0)
				frame.last:SetPoint("RIGHT", frame.sep5 or frame.compactBar, "LEFT", -6, 0)
			end
			if frame.sep4 then
				frame.sep4:Hide()
			end
		end
		return
	end
	if self.db.settings.compact then
		if frame.venom then
			frame.venom:Hide()
		end
		if frame.venomIcon then
			frame.venomIcon:Hide()
		end
		local chip = frame.venomChip
		if chip then
			chip.icon:SetTexture(tex)
			chip.text:SetText(tostring(amount or 0))
			chip.text:SetTextColor(0.15, 0.85, 0.32)
			chip.amount = amount or 0
			chip:SetParent(frame.compactBar)
			chip:ClearAllPoints()
			local vw = 14 + 4 + (chip.text:GetStringWidth() or 12) + 4
			chip:SetWidth(math.max(40, vw))
			chip:SetPoint("RIGHT", frame.sep5, "LEFT", -6, 0)
			chip:Show()
			if frame.sep4 then
				frame.sep4:ClearAllPoints()
				frame.sep4:SetPoint("RIGHT", chip, "LEFT", -6, 0)
				frame.sep4:Show()
			end
			if frame.last then
				frame.last:ClearAllPoints()
				frame.last:SetPoint("LEFT", frame.sep3, "RIGHT", 6, 0)
				frame.last:SetPoint("RIGHT", frame.sep4 or chip, "LEFT", -6, 0)
			end
		end
	else
		if frame.venomChip then
			frame.venomChip:Hide()
		end
		if frame.grand then
			if frame.grandIcon then
				frame.grandIcon:SetTexture(self:GrandLineIconTexture())
				frame.grandIcon:ClearAllPoints()
				frame.grandIcon:SetPoint("BOTTOMLEFT", 12, 22)
				frame.grandIcon:Show()
				frame.grand:ClearAllPoints()
				frame.grand:SetPoint("LEFT", frame.grandIcon, "RIGHT", 4, 0)
			else
				frame.grand:ClearAllPoints()
				frame.grand:SetPoint("BOTTOMLEFT", 12, 22)
			end
		end
		if frame.venomIcon then
			frame.venomIcon:SetTexture(tex)
			frame.venomIcon:Show()
		end
		if frame.venom then
			frame.venom:SetText(string.format("Venom: %d", amount or 0))
			frame.venom:SetTextColor(0.15, 0.85, 0.32)
			frame.venom:Show()
		end
	end
end

function FK:RefreshOptions()
	local o = self.options
	if not o then
		return
	end
	local s = self.db.settings
	o.compactOnFish:SetChecked(s.compactOnFish)
	o.announce:SetChecked(s.announce)
	o.trackJunk:SetChecked(s.trackJunk)
	o.lockWindow:SetChecked(s.lockWindow)
	o.resetSessionOnLogin:SetChecked(s.resetSessionOnLogin)
	if o.themeBtns then
		local cur = s.theme or "steel"
		for i = 1, #o.themeBtns do
			local b = o.themeBtns[i]
			if b.themeId == cur then
				b:SetBackdropBorderColor(1, 0.92, 0.55, 1)
			else
				b:SetBackdropBorderColor(0.15, 0.15, 0.15, 0.9)
			end
		end
	end
end

function FK:RefreshUI()
	local frame = self.frame
	if not frame or not self.db then
		return
	end

	local totals = self:SessionTotals()
	local life = self:LifetimeTotals()
	local compact = self.db.settings.compact

	frame.priceBtn.text:SetText("[" .. self:PriceSourceLabel() .. "]")
	self:RefreshPauseButton()
	self:RefreshSortHeaders()
	self:RefreshTimer()

	if compact then
		local last = self.lastCatch
		if last and last.name then
			frame.last:SetText(string.format("%s x%d", last.name, last.qty or 1))
			local r, g, b = QualityColor(last.quality)
			frame.last:SetTextColor(r, g, b)
		else
			frame.last:SetText("")
		end
	else
		local chest = ""
		if totals.treasures and totals.treasures > 0 then
			chest = string.format("    %d chest%s", totals.treasures, totals.treasures == 1 and "" or "s")
		end
		frame.sub:SetText(string.format("%d items%s", totals.items, chest))
		frame.footer:SetText(string.format("Lifetime  %d   %s", life.catches, self:FormatMoney(life.copper)))
		if self:HasGrandLine() then
			frame.grand:SetText("Grand Line: ON")
			frame.grand:SetTextColor(0.15, 0.85, 0.32)
		else
			frame.grand:SetText("Grand Line: OFF")
			frame.grand:SetTextColor(0.92, 0.28, 0.24)
		end
		if frame.grandIcon then
			frame.grandIcon:SetTexture(self:GrandLineIconTexture())
			frame.grandIcon:Show()
		end
	end
	self:RefreshVenomDisplay()

	local list = self:SortedItems(self:Session().items)
	local n = #list
	frame.child:SetHeight(math.max(VISIBLE_ROWS, n) * ROW_HEIGHT)

	for i, row in ipairs(frame.rows) do
		local data = list[i]
		if data and not compact then
			row:Show()
			if data.icon then
				row.icon:SetTexture(data.icon)
			else
				row.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
			end
			row.name:SetText((data.from == "treasure" and "|cffcfc3a4[chest]|r " or "") .. (data.name or UNKNOWN))
			local r, g, b = QualityColor(data.quality)
			row.name:SetTextColor(r, g, b)
			row.count:SetText("x" .. tostring(data.count or 0))
			local catches = math.max(1, totals.catches)
			local hits = data.hits or data.count or 0
			row.rate:SetText(self:FormatRate(hits, catches))
			local value = self:GetItemPrice(data.link, data.itemID, data.quality) * (data.count or 0)
			row.value:SetText(self:FormatMoneyPipes(value))
			row.link = data.link
		else
			row:Hide()
			row.link = nil
		end
	end

	if self.options and self.options:IsShown() then
		if frame.colHead then
			frame.colHead:Hide()
		end
		self:RefreshOptions()
	elseif not compact and frame.colHead then
		frame.colHead:Show()
	end
end

function FK:Toggle()
	if not self.frame then
		self:CreateUI()
	end
	if self.frame:IsShown() then
		self.frame:Hide()
		self.db.settings.shown = false
	else
		self.frame:Show()
		self.db.settings.shown = true
		self:ApplyLayout()
		self:RefreshUI()
	end
end

function FK:Show()
	if not self.frame then
		self:CreateUI()
	end
	self.frame:Show()
	self.db.settings.shown = true
	self:ApplyLayout()
	self:RefreshUI()
end

function FishKeeper_OnCompartmentClick()
	FK:Toggle()
end

function FishKeeper_OnCompartmentEnter(_, button)
	GameTooltip:SetOwner(button, "ANCHOR_LEFT")
	GameTooltip:SetText("FishKeeper")
	if FK.db then
		local t = FK:SessionTotals()
		GameTooltip:AddLine(string.format("%d catches   %s", t.catches, FK:FormatMoney(t.copper)), 1, 1, 1)
		GameTooltip:AddLine(FK:PriceSourceLabel(), 0.7, 0.85, 0.9)
	end
	GameTooltip:Show()
end

function FishKeeper_OnCompartmentLeave()
	GameTooltip:Hide()
end
