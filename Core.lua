local ADDON_NAME = ...

FishKeeper = FishKeeper or {}
local FK = FishKeeper
FK.name = ADDON_NAME
FK.version = "1.6.3"
FK.recentItems = {}

BINDING_HEADER_FISHKEEPER = "FishKeeper"
BINDING_NAME_FISHKEEPER_TOGGLE = "Toggle window"
BINDING_NAME_FISHKEEPER_RESETSESSION = "Reset session"
BINDING_NAME_FISHKEEPER_PAUSE = "Pause / resume timer"

local SLOT_ITEM = (Enum and Enum.LootSlotType and Enum.LootSlotType.Item) or 1
local SLOT_MONEY = (Enum and Enum.LootSlotType and Enum.LootSlotType.Money) or 2
local SLOT_CURRENCY = (Enum and Enum.LootSlotType and Enum.LootSlotType.Currency) or 3

-- Patient Treasure (Midnight fishing chest). Object loot is NOT IsFishingLoot().
local PATIENT_TREASURE_OBJECTS = {
	[540505] = true,
}
local PATIENT_TREASURE_AURAS = {
	[1269521] = true,
	[1235378] = true,
}
local TREASURE_NAME_MARKERS = {
	"patient treasure",
	"patient chest",
	"trésor patient",
	"tresor patient",
	"tesoro paciente",
	"tesouro paciente",
	"geduldiger schatz",
	"tesoro paziente",
	"耐心",
}
local FISHING_SPELL_IDS = {
	[7620] = true,
	[7731] = true,
	[7732] = true,
	[18248] = true,
	[33095] = true,
	[51294] = true,
	[88868] = true,
	[131474] = true,
	[158743] = true,
	[227675] = true,
	[271616] = true,
	[377895] = true,
	[471008] = true, -- Midnight Fishing (profession)
}

local FISH_ITEM_IDS = {
	-- Classic
	[6289] = true, -- Raw Longjaw Mud Snapper
	[6291] = true, -- Raw Brilliant Smallfish
	[6292] = true, -- 10 Pound Mud Snapper
	[6294] = true, -- 12 Pound Mud Snapper
	[6295] = true, -- 15 Pound Mud Snapper
	[6303] = true, -- Raw Slitherskin Mackerel
	[6307] = true, -- Message in a Bottle
	[6308] = true, -- Raw Bristle Whisker Catfish
	[6309] = true, -- 17 Pound Catfish
	[6310] = true, -- 19 Pound Catfish
	[6311] = true, -- 22 Pound Catfish
	[6317] = true, -- Raw Loch Frenzy
	[6358] = true, -- Oily Blackmouth
	[6359] = true, -- Firefin Snapper
	[6360] = true, -- Steelscale Crushfish
	[6361] = true, -- Raw Rainbow Fin Albacore
	[6362] = true, -- Raw Rockscale Cod
	[6363] = true, -- 26 Pound Catfish
	[6364] = true, -- 32 Pound Catfish
	[6458] = true, -- Oil Covered Fish
	[6522] = true, -- Deviate Fish
	[6643] = true, -- Bloated Smallfish
	[6645] = true, -- Bloated Mud Snapper
	[6647] = true, -- Bloated Catfish
	[8365] = true, -- Raw Mithril Head Trout
	[8366] = true, -- Bloated Trout
	[12238] = true, -- Darkshore Grouper
	[13422] = true, -- Stonescale Eel
	[13754] = true, -- Raw Glossy Mightfish
	[13755] = true, -- Winter Squid
	[13756] = true, -- Raw Summer Bass
	[13757] = true, -- Lightning Eel
	[13758] = true, -- Raw Redgill
	[13759] = true, -- Raw Nightfin Snapper
	[13760] = true, -- Raw Sunscale Salmon
	[13876] = true, -- 40 Pound Grouper
	[13877] = true, -- 47 Pound Grouper
	[13878] = true, -- 53 Pound Grouper
	[13879] = true, -- 59 Pound Grouper
	[13880] = true, -- 68 Pound Grouper
	[13881] = true, -- Bloated Redgill
	[13882] = true, -- 42 Pound Redgill
	[13883] = true, -- 45 Pound Redgill
	[13884] = true, -- 49 Pound Redgill
	[13885] = true, -- 34 Pound Redgill
	[13886] = true, -- 37 Pound Redgill
	[13888] = true, -- Darkclaw Lobster
	[13889] = true, -- Raw Whitescale Salmon
	[13893] = true, -- Large Raw Mightfish
	[13901] = true, -- 15 Pound Salmon
	[13902] = true, -- 18 Pound Salmon
	[13903] = true, -- 22 Pound Salmon
	[13904] = true, -- 24 Pound Salmon
	[13905] = true, -- 32 Pound Salmon
	[21071] = true, -- Raw Sagefish
	[21153] = true, -- Raw Greater Sagefish
	[4603] = true, -- Raw Spotted Yellowtail
	[5523] = true, -- Small Barnacled Clam
	[5524] = true, -- Thick-shelled Clam
	[7973] = true, -- Big-mouth Clam
	[15874] = true, -- Soft-shelled Clam
	[19803] = true, -- Keefer's Angelfish
	[19804] = true, -- Pale Ghoulfish
	[19805] = true, -- Keefer's Angelfish (alt)
	[19806] = true, -- Dezian Queenfish
	[19807] = true, -- Speckled Tastyfish
	[19808] = true, -- Rockhide Strongfish
	[19975] = true, -- Zulian Mudskunk
	[20766] = true, -- Slimy Bag
	[20767] = true, -- Scum Covered Bag
	[20768] = true, -- Oozing Bag
	[21113] = true, -- Watertight Trunk
	[21150] = true, -- Iron Bound Trunk
	[21228] = true, -- Mistslicked Bag
	[21741] = true, -- Scum Covered Bag
	[34109] = true, -- Weather-Beaten Journal
	[45328] = true, -- Bloated Dreadfin
	[45902] = true, -- Giant Sewer Rat
	[46109] = true, -- Sea Turtle

	-- Burning Crusade
	[24476] = true, -- Jaggal Clam
	[27422] = true, -- Barbed Gill Trout
	[27425] = true, -- Spotted Feltail
	[27429] = true, -- Zangarian Sporefish
	[27435] = true, -- Figluster's Mudfish
	[27437] = true, -- Icefin Bluefish
	[27438] = true, -- Golden Darter
	[27439] = true, -- Furious Crawdad
	[27515] = true, -- Huge Spotted Feltail
	[27516] = true, -- Enormous Barbed Gill Trout
	[33823] = true, -- Bloodfin Catfish
	[33824] = true, -- Crescent-Tail Skullfish
	[34861] = true, -- Sharpened Fish Hook
	[34863] = true, -- Bag of Fishing Treasures
	[35313] = true, -- Bloated Barbed Gill Trout
	[35348] = true, -- Bag of Fishing Treasures

	-- Wrath
	[40199] = true, -- Pygmy Suckerfish
	[41800] = true, -- Deep Sea Monsterbelly
	[41801] = true, -- Moonglow Cuttlefish
	[41802] = true, -- Imperial Manta Ray
	[41803] = true, -- Rockfin Grouper
	[41805] = true, -- Borean Man O' War
	[41806] = true, -- Musselback Sculpin
	[41807] = true, -- Dragonfin Angelfish
	[41808] = true, -- Bonescale Snapper
	[41809] = true, -- Glacial Salmon
	[41810] = true, -- Fangtooth Herring
	[41812] = true, -- Barrelhead Goby
	[41813] = true, -- Nettlefish
	[41814] = true, -- Glassfin Minnow
	[43646] = true, -- Fountain Goldfish
	[43647] = true, -- Shimmering Minnow
	[43652] = true, -- Slippery Eel
	[45904] = true, -- Terrorfish
	[45905] = true, -- Bloodtooth Frenzy
	[46007] = true, -- Bag of Fishing Treasures

	-- Cataclysm
	[53062] = true, -- Sharptooth
	[53063] = true, -- Mountain Trout
	[53064] = true, -- Highland Guppy
	[53065] = true, -- Albino Cavefish
	[53066] = true, -- Blackbelly Mudfish
	[53067] = true, -- Striped Lurker
	[53068] = true, -- Algaefin Rockfish
	[53069] = true, -- Murglesnout
	[53070] = true, -- Fathom Eel
	[53071] = true, -- Algaefin Rockfish (alt)
	[53072] = true, -- Deepsea Sagefish
	[67539] = true, -- Tiny Chest
	[67495] = true, -- Strange Bloated Stomach

	-- Mists of Pandaria
	[74856] = true, -- Jade Lungfish
	[74857] = true, -- Giant Mantis Shrimp
	[74859] = true, -- Emperor Salmon
	[74860] = true, -- Redbelly Mandarin
	[74861] = true, -- Tiger Gourami
	[74863] = true, -- Jewel Danio
	[74864] = true, -- Reef Octopus
	[74865] = true, -- Krasarang Paddlefish
	[74866] = true, -- Golden Carp
	[83064] = true, -- Spinefish
	[88496] = true, -- Sealed Crate
	[94932] = true, -- Tiny Red Carp
	[94933] = true, -- Tiny Blue Carp
	[94934] = true, -- Tiny Green Carp
	[94935] = true, -- Tiny White Carp

	-- Warlords of Draenor
	[111589] = true, -- Crescent Saberfish
	[111595] = true, -- Crescent Saberfish Flesh
	[111601] = true, -- Enormous Crescent Saberfish
	[111651] = true, -- Small Jawless Skulker
	[111652] = true, -- Small Blind Lake Sturgeon
	[111656] = true, -- Jawless Skulker
	[111658] = true, -- Small Fat Sleeper
	[111659] = true, -- Small Fire Ammonite
	[111660] = true, -- Small Sea Scorpion
	[111662] = true, -- Small Abyssal Gulper Eel
	[111663] = true, -- Small Blackwater Whiptail
	[111664] = true, -- Blackwater Whiptail
	[111665] = true, -- Fat Sleeper
	[111666] = true, -- Blind Lake Sturgeon
	[111667] = true, -- Fire Ammonite
	[111668] = true, -- Sea Scorpion
	[111669] = true, -- Jawless Skulker Flesh
	[111670] = true, -- Fire Ammonite Tentacle
	[111671] = true, -- Enormous Jawless Skulker
	[111672] = true, -- Enormous Fat Sleeper
	[111673] = true, -- Enormous Blind Lake Sturgeon
	[111674] = true, -- Enormous Fire Ammonite
	[111675] = true, -- Enormous Sea Scorpion
	[111676] = true, -- Enormous Jawless Skulker
	[112623] = true, -- Pack of Fishing Supplies
	[112633] = true, -- Frostdeep Minnow
	[116817] = true, -- Blackwater Whiptail Lunker
	[116818] = true, -- Jawless Skulker Lunker
	[116819] = true, -- Fat Sleeper Lunker
	[116820] = true, -- Blind Lake Sturgeon Lunker
	[116821] = true, -- Fire Ammonite Lunker
	[116822] = true, -- Sea Scorpion Lunker
	[118565] = true, -- Savage Piranha
	[124669] = true, -- Darkmoon Daggermaw
	[127994] = true, -- Felmouth Frenzy

	-- Legion
	[124107] = true, -- Cursed Queenfish
	[124108] = true, -- Mossgill Perch
	[124109] = true, -- Highmountain Salmon
	[124110] = true, -- Stormray
	[124111] = true, -- Runescale Koi
	[124112] = true, -- Black Barracuda
	[133607] = true, -- Silver Mackerel
	[133725] = true, -- Leyshimmer Blenny
	[133739] = true, -- Barnacled Bag of Goods
	[138967] = true, -- Silver Mackerel (alt)
	[139573] = true, -- The Witchmother's Beckoning
	[139653] = true, -- Ancient Highmountain Salmon
	[139654] = true, -- Ghostly Queenfish
	[139655] = true, -- Terrorfin
	[139656] = true, -- Thundering Stormray
	[139657] = true, -- Ancient Mossgill
	[139658] = true, -- Mountain Puffer
	[139660] = true, -- Ancient Black Barracuda
	[146848] = true, -- Fragmented Enchantment

	-- Battle for Azeroth
	[152543] = true, -- Sand Shifter
	[152544] = true, -- Slimy Mackerel
	[152545] = true, -- Frenzied Fangtooth
	[152546] = true, -- Lane Snapper
	[152547] = true, -- Great Sea Catfish
	[152548] = true, -- Tiragarde Perch
	[152549] = true, -- Redtail Loach
	[160711] = true, -- Aromatic Fish Oil
	[162515] = true, -- Midnight Salmon
	[168302] = true, -- Viper Fish
	[168645] = true, -- Moist Fillet
	[168646] = true, -- Mauve Stinger
	[174327] = true, -- Malformed Gnasher
	[174328] = true, -- Aberrant Voidfin

	-- Shadowlands
	[173032] = true, -- Lost Sole
	[173033] = true, -- Iridescent Amberjack
	[173034] = true, -- Silvergill Pike
	[173035] = true, -- Pocked Bonefish
	[173036] = true, -- Spinefin Piranha
	[173037] = true, -- Elysian Thade
	[187702] = true, -- Precursor Placoderm
	[187704] = true, -- Protoflesh
	[187707] = true, -- Progenitor Essentia

	-- Dragonflight
	[194701] = true, -- Ominous Conch
	[194730] = true, -- Scalebelly Mackerel
	[194966] = true, -- Thousandbite Piranha
	[194967] = true, -- Aileron Seamoth
	[194968] = true, -- Cerulean Spinefish
	[194969] = true, -- Temporal Dragonhead
	[194970] = true, -- Islefin Dorado
	[197742] = true, -- Ribbed Mollusk Meat
	[198395] = true, -- Dull Spined Clam
	[198397] = true, -- Rainbow Pearl
	[198438] = true, -- Draconic Recipe in a Bottle
	[198614] = true, -- Soggy Clump of Darkmoon Cards
	[199338] = true, -- Copper Coin of the Isles
	[199339] = true, -- Silver Coin of the Isles
	[199340] = true, -- Gold Coin of the Isles
	[199344] = true, -- Magma Thresher
	[199696] = true, -- Iskaaran Ice Axe
	[200061] = true, -- Prismatic Leaper
	[200074] = true, -- Frosted Rimefin Tuna
	[202072] = true, -- Frigid Floe Fish
	[202073] = true, -- Calamitous Carp
	[202074] = true, -- Kingfin, the Wise Whiskerfish
	[202105] = true, -- Rusted Coin of the Isles

	-- The War Within
	[220134] = true, -- Dilly-Dally Dace
	[220135] = true, -- Bloody Perch
	[220136] = true, -- Crystalline Sturgeon
	[220137] = true, -- Bismuth Bitterling
	[220138] = true, -- Nibbling Minnow
	[220139] = true, -- Whispering Stargazer
	[220140] = true, -- Goldengill Trout
	[220141] = true, -- Quiet River Bass
	[220142] = true, -- Dornish Pike
	[220143] = true, -- Specular Rainbowfish
	[220144] = true, -- Roaring Anglerseeker
	[220145] = true, -- Pale Huskfish
	[220146] = true, -- Kaheti Slum Shark
	[220148] = true, -- Arathor Hammerfish
	[220149] = true, -- Sanguine Dogfish
	[220150] = true, -- Queen's Lurefish
	[220151] = true, -- Regal Dottyback
	[220152] = true, -- Cursed Ghoulfish
	[220153] = true, -- Spiked Sea Raven
	[220154] = true, -- Awoken Coelacanth
	[220155] = true, -- "Gold" Fish
	[222096] = true, -- Goldengill Trout (quality)
	[222533] = true, -- Goldengill Trout (quality)
	[225559] = true, -- Hungering Shimmerfin
	[227668] = true, -- Undermine Clam
	[227669] = true, -- Undermine Clam Meat

	-- Midnight
	[238365] = true, -- Sin'dorei Swarmer
	[238366] = true, -- Lynxfish
	[238367] = true, -- Root Crab
	[238368] = true, -- Twisted Tetra
	[238369] = true, -- Bloomtail Minnow
	[238370] = true, -- Shimmer Spinefish
	[238371] = true, -- Arcane Wyrmfish
	[238372] = true, -- Restored Songfish
	[238373] = true, -- Ominous Octopus
	[238374] = true, -- Tender Lumifin
	[238375] = true, -- Fungalskin Pike
	[238376] = true, -- Lucky Loa
	[238377] = true, -- Blood Hunter
	[238378] = true, -- Shimmersiren
	[238379] = true, -- Warping Wise
	[238380] = true, -- Null Voidfish
	[238381] = true, -- Hollow Grouper
	[238382] = true, -- Gore Guppy
	[238383] = true, -- Eversong Trout
	[238384] = true, -- Sunwell Fish
	[274587] = true, -- Spotted Killifish
	[274588] = true, -- Toxic Tlhapi
	[274589] = true, -- Ula'tek Snakehead
	[274590] = true, -- Sulfurous Sludgefish
	[274591] = true, -- Coiled Stargorger
	[274592] = true, -- Dirty Darter
	[274593] = true, -- Blightswarmer
	[279091] = true, -- Oozing Goby
	[279093] = true, -- Giggling Skull
	[279094] = true, -- Grotesque Sturgeon
	[279100] = true, -- Many-Eyed Flounder
	[279105] = true, -- Twin-Headed Snipefish
	[279106] = true, -- Loathsome Anglerfish
}

-- Patient Treasure / Careless Cargo reagents that often arrive via chat, not the loot window.
local CHEST_ITEM_IDS = {
	[236949] = true, -- Mote of Light
	[236950] = true, -- Mote of Primal Energy
	[236951] = true, -- Mote of Wild Magic
	[236952] = true, -- Mote of Pure Void
	[243343] = true, -- Angler's Anomaly
	[262649] = true, -- An Angler's Deep Dive
	[268730] = true, -- Nether-Warped Egg
	[243302] = true, -- Aquarius Bloom
	[243342] = true, -- Bloom Bauble
}

local GRAND_LINE_ENCHANT = 8638
local GRAND_LINE_SPELL = 1269474
local GRAND_LINE_ITEM = 262796
local HUNTRESS_ITEM_ID = 244790
local HUNTRESS_SLOTS = { 16, 17, 18, 20, 21, 22, 23, 24, 25, 26, 27, 28 }
local VENOM_SPELL = 25645
local VENOM_ICON_FALLBACK = 136067 -- Spell_Nature_CorrosiveBreath
local FISH_ICON_FALLBACK = 136245 -- Trade_Fishing

local defaults = {
	version = 2,
	settings = {
		priceMode = "region", -- region (dbregionmarketavg) | minbuyout (dbminbuyout)
		announce = false,
		announceMin = 0,
		trackMoney = true,
		trackJunk = true,
		minQuality = 0,
		lockWindow = false,
		scale = 1,
		point = "CENTER",
		relPoint = "CENTER",
		x = 0,
		y = 0,
		shown = true,
		resetSessionOnLogin = false,
		sort = "value",
		compact = true,
		compactOnFish = true,
		theme = "steel",
	},
	chars = {},
	sessions = {},
}

local function CopyDefaults(src)
	local t = {}
	for k, v in pairs(src) do
		if type(v) == "table" then
			t[k] = CopyDefaults(v)
		else
			t[k] = v
		end
	end
	return t
end

local function MergeDefaults(dest, src)
	for k, v in pairs(src) do
		if type(v) == "table" then
			if type(dest[k]) ~= "table" then
				dest[k] = CopyDefaults(v)
			else
				MergeDefaults(dest[k], v)
			end
		elseif dest[k] == nil then
			dest[k] = v
		end
	end
end

function FK:CharKey()
	local name, realm = UnitFullName("player")
	if not name then
		return "Unknown"
	end
	realm = realm or GetRealmName() or "Unknown"
	return name .. " - " .. realm
end

function FK:Char()
	local key = self:CharKey()
	local chars = self.db.chars
	if not chars[key] then
		chars[key] = {
			lifetimeCatches = 0,
			lifetimeCasts = 0,
			lifetimeTreasures = 0,
			moneyCopper = 0,
			items = {},
		}
	end
	local c = chars[key]
	c.lifetimeTreasures = c.lifetimeTreasures or 0
	return c
end

function FK:Session()
	local key = self:CharKey()
	local sessions = self.db.sessions
	if not sessions[key] then
		sessions[key] = self:NewSession(key)
	end
	local s = sessions[key]
	if s.started == nil then
		if s.timerStart or ((s.elapsed or 0) > 0) then
			s.started = true
		else
			s.started = false
			s.timerStart = nil
		end
	end
	s.treasures = s.treasures or 0
	s.elapsed = s.elapsed or 0
	return s
end

function FK:NewSession(key)
	return {
		charKey = key or self:CharKey(),
		start = time(),
		timerStart = nil,
		elapsed = 0,
		paused = false,
		started = false,
		catches = 0,
		casts = 0,
		treasures = 0,
		moneyCopper = 0,
		items = {},
		zone = "",
	}
end

function FK:SessionElapsed()
	local s = self:Session()
	if not s.started then
		return 0
	end
	local base = s.elapsed or 0
	if s.paused then
		return base
	end
	local t0 = s.timerStart
	if not t0 then
		return base
	end
	return base + math.max(0, time() - t0)
end

function FK:EnsureTimerStarted()
	local s = self:Session()
	if s.started then
		return
	end
	s.started = true
	s.paused = false
	s.elapsed = 0
	s.timerStart = time()
end

function FK:MaybeCompactOnFish()
	if not self.db or not self.db.settings.compactOnFish then
		return
	end
	self.userExpanded = false
	self.db.settings.compact = true
	if self.ApplyLayout then
		self:ApplyLayout()
	end
end

function FK:IsPaused()
	local s = self:Session()
	return s.paused and true or false
end

function FK:TogglePause()
	local s = self:Session()
	if not s.started then
		return
	end
	if s.paused then
		s.paused = false
		s.timerStart = time()
	else
		s.elapsed = self:SessionElapsed()
		s.paused = true
		s.timerStart = nil
	end
	self:UpdateUI()
end

function FK:FormatDuration(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	if h > 0 then
		return string.format("%d:%02d:%02d", h, m, s)
	end
	return string.format("%d:%02d", m, s)
end

function FK:IsTreasureName(name)
	if type(name) ~= "string" or name == "" then
		return false
	end
	local lower = name:lower()
	for i = 1, #TREASURE_NAME_MARKERS do
		if lower:find(TREASURE_NAME_MARKERS[i], 1, true) then
			return true
		end
	end
	return false
end

function FK:ObjectIDFromGUID(guid)
	if type(guid) ~= "string" then
		return nil
	end
	return tonumber(guid:match("^GameObject%-%d+%-%d+%-%d+%-%d+%-(%d+)"))
end

function FK:HasPatientTreasureAura()
	if not C_UnitAuras or not C_UnitAuras.GetPlayerAuraBySpellID then
		return false
	end
	for id in pairs(PATIENT_TREASURE_AURAS) do
		local ok, info = pcall(C_UnitAuras.GetPlayerAuraBySpellID, id)
		if ok and info then
			return true
		end
	end
	return false
end

function FK:IsFishingContext()
	local now = GetTime()
	if now <= (self.fishingUntil or 0) then
		return true
	end
	if self.lastCastTime and (now - self.lastCastTime) < 180 then
		return true
	end
	return false
end

function FK:MarkTreasureWindow(seconds)
	self.treasureUntil = GetTime() + (seconds or 10)
end

function FK:IsPatientTreasureLoot()
	local n = GetNumLootItems() or 0
	if GetLootSourceInfo then
		for i = 1, math.max(1, n) do
			local guid = GetLootSourceInfo(i)
			local id = self:ObjectIDFromGUID(guid)
			if id and PATIENT_TREASURE_OBJECTS[id] then
				return true
			end
		end
	end
	if GetTime() <= (self.treasureUntil or 0) then
		return true
	end
	if self:HasPatientTreasureAura() and self:IsFishingContext() then
		return true
	end
	return false
end

function FK:OnSpellcastSent(unit, target, spellID)
	if unit and unit ~= "player" then
		return
	end
	if self:IsFishingSpell(spellID) then
		self:OnFishingCast(spellID)
	elseif type(target) == "string" and target ~= "" then
		local lower = target:lower()
		if lower:find("bobber", 1, true) or lower:find("fishing", 1, true) then
			self:OnFishingCast(spellID or 131474)
		end
	end
	if self:IsTreasureName(target) then
		self:MarkTreasureWindow(10)
	end
end

function FK:InitDB()
	FishKeeperDB = FishKeeperDB or {}
	MergeDefaults(FishKeeperDB, defaults)
	self.db = FishKeeperDB
	if (self.db.version or 1) < 2 then
		local s = self.db.settings
		s.priceMode = "region"
		s.compact = true
		s.compactOnFish = true
		s.tsmPrice = nil
		self.db.version = 2
	end
end

function FK:IsFishingSpell(spellID)
	if spellID and FISHING_SPELL_IDS[spellID] then
		return true
	end
	local name
	if spellID then
		if C_Spell and C_Spell.GetSpellName then
			name = C_Spell.GetSpellName(spellID)
		elseif C_Spell and C_Spell.GetSpellInfo then
			local info = C_Spell.GetSpellInfo(spellID)
			name = info and info.name
		end
	end
	if not name then
		name = UnitChannelInfo("player")
	end
	if not name and UnitCastingInfo then
		name = UnitCastingInfo("player")
	end
	if not name then
		return false
	end
	if PROFESSIONS_FISHING and name == PROFESSIONS_FISHING then
		return true
	end
	local lower = name:lower()
	return lower == "fishing" or lower:find("fishing", 1, true) and true or false
end

function FK:CurrentZone()
	local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
	if mapID and C_Map.GetMapInfo then
		local info = C_Map.GetMapInfo(mapID)
		if info and info.name then
			return info.name
		end
	end
	return GetZoneText() or ""
end

local function ItemIDFromLink(link)
	if not link then
		return nil
	end
	if C_Item and C_Item.GetItemInfoInstant then
		local id = C_Item.GetItemInfoInstant(link)
		if id then
			return id
		end
	end
	return tonumber(link:match("item:(%d+)"))
end

-- Retail 11+/12 item colors are |cnIQ1:|Hitem:... not |cffffffff|Hitem:...
local function ExtractItemLink(msg)
	if type(msg) ~= "string" then
		return nil
	end
	return msg:match("(|cn[%w_]+:|Hitem:%d+:.-|h%b[]|h|r)")
		or msg:match("(|c%x+|Hitem:%d+:.-|h%b[]|h|r)")
		or msg:match("(|Hitem:%d+:.-|h%b[]|h|r)")
end

function FK:IsFishItem(itemID, name, link)
	if itemID and FISH_ITEM_IDS[itemID] then
		return true
	end
	local target = link or itemID
	if target and C_Item and C_Item.GetItemInfoInstant then
		local ok, _, itemType, itemSubType = pcall(C_Item.GetItemInfoInstant, target)
		if ok then
			if itemType == "Fish" or itemSubType == "Fish" then
				return true
			end
			if type(itemSubType) == "string" and itemSubType:lower() == "fish" then
				return true
			end
			if type(itemType) == "string" and itemType:lower() == "fish" then
				return true
			end
		end
	end
	if type(name) == "string" and name ~= "" then
		local l = name:lower()
		if l:find("feast", 1, true) or l:find("recipe", 1, true) or l:find("fishing pole", 1, true) then
			return false
		end
		if l:find("fish", 1, true) or l:find("trout", 1, true) or l:find("salmon", 1, true)
			or l:find("perch", 1, true) or l:find("clam", 1, true) or l:find("minnow", 1, true)
			or l:find("sturgeon", 1, true) or l:find("bloated", 1, true) then
			return true
		end
	end
	return false
end

function FK:IsChestItem(itemID, name)
	if itemID and CHEST_ITEM_IDS[itemID] then
		return true
	end
	if type(name) ~= "string" or name == "" then
		return false
	end
	local l = name:lower()
	if l:find("mote of", 1, true) then
		return true
	end
	if l:find("bloomline", 1, true) or l:find("glimmerline", 1, true) then
		return true
	end
	if l:find("bloom bauble", 1, true) or l:find("nether-warped", 1, true) then
		return true
	end
	if l:find("angler's deep dive", 1, true) or l:find("angler's anomaly", 1, true) then
		return true
	end
	return false
end

function FK:HasGrandLine()
	if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
		local ok, info = pcall(C_UnitAuras.GetPlayerAuraBySpellID, GRAND_LINE_SPELL)
		if ok and info then
			return true
		end
	end
	local slots = { 16, 17, 18, 20, 21, 22, 23, 24, 25, 26, 27, 28 }
	for i = 1, #slots do
		local link = GetInventoryItemLink("player", slots[i])
		if type(link) == "string" then
			local enchant = tonumber(link:match("item:%d+:(%d+)"))
			if enchant == GRAND_LINE_ENCHANT then
				return true
			end
			local lower = link:lower()
			if lower:find("grand line", 1, true) or lower:find("grandline", 1, true) then
				return true
			end
		end
	end
	if GetWeaponEnchantInfo then
		local has, _, _, enchantId = GetWeaponEnchantInfo()
		if has and (enchantId == GRAND_LINE_ENCHANT or enchantId == GRAND_LINE_SPELL) then
			return true
		end
	end
	return false
end

function FK:FindHuntressSlot()
	for i = 1, #HUNTRESS_SLOTS do
		local slot = HUNTRESS_SLOTS[i]
		local id = GetInventoryItemID and GetInventoryItemID("player", slot)
		if id == HUNTRESS_ITEM_ID then
			return slot
		end
		local link = GetInventoryItemLink("player", slot)
		if type(link) == "string" and link:lower():find("coiled huntress", 1, true) then
			return slot
		end
	end
	return nil
end

function FK:ParseVenomText(text)
	if type(text) ~= "string" or text == "" then
		return nil
	end
	local n = text:match("%+(%d+)%s+[Vv]enom") or text:match("(%d+)%s+[Vv]enom")
	if n then
		return tonumber(n)
	end
	return nil
end

function FK:ReadVenomFromTooltipData(data)
	if not data then
		return nil
	end
	if TooltipUtil and TooltipUtil.SurfaceArgs then
		pcall(TooltipUtil.SurfaceArgs, data)
	end
	local lines = data.lines
	if not lines then
		return nil
	end
	for i = 1, #lines do
		local line = lines[i]
		if line and TooltipUtil and TooltipUtil.SurfaceArgs then
			pcall(TooltipUtil.SurfaceArgs, line)
		end
		local text = line and (line.leftText or line.text)
		local n = self:ParseVenomText(text)
		if n then
			return n
		end
	end
	return nil
end

function FK:ReadVenomFromSlot(slot)
	if C_TooltipInfo and C_TooltipInfo.GetInventoryItem then
		local ok, data = pcall(C_TooltipInfo.GetInventoryItem, "player", slot)
		if ok then
			local n = self:ReadVenomFromTooltipData(data)
			if n then
				return n
			end
		end
	end
	local tip = self._scanTip
	if not tip then
		tip = CreateFrame("GameTooltip", "FishKeeperScanTip", nil, "GameTooltipTemplate")
		tip:SetOwner(UIParent, "ANCHOR_NONE")
		self._scanTip = tip
	end
	tip:ClearLines()
	if tip.SetInventoryItem then
		tip:SetInventoryItem("player", slot)
		local nLines = tip:NumLines() or 0
		for i = 1, nLines do
			local fs = _G["FishKeeperScanTipTextLeft" .. i]
			local n = self:ParseVenomText(fs and fs:GetText())
			if n then
				return n
			end
		end
	end
	return 0
end

function FK:GetHuntressVenom()
	local now = GetTime()
	if self._venomAt and (now - self._venomAt) < 0.4 then
		return self._venomEquipped, self._venomValue
	end
	local slot = self:FindHuntressSlot()
	if not slot then
		self._venomAt = now
		self._venomEquipped = false
		self._venomValue = nil
		return false, nil
	end
	local amount = self:ReadVenomFromSlot(slot) or 0
	self._venomAt = now
	self._venomEquipped = true
	self._venomValue = amount
	return true, amount
end

function FK:VenomIconTexture()
	if C_Spell and C_Spell.GetSpellTexture then
		local tex = C_Spell.GetSpellTexture(VENOM_SPELL)
		if tex then
			return tex
		end
	end
	if GetSpellTexture then
		local tex = GetSpellTexture(VENOM_SPELL)
		if tex then
			return tex
		end
	end
	return VENOM_ICON_FALLBACK
end

function FK:FishIconTexture()
	return "Interface\\Icons\\Trade_Fishing"
end

function FK:GrandLineIconTexture()
	if C_Item and C_Item.GetItemIconByID then
		local tex = C_Item.GetItemIconByID(GRAND_LINE_ITEM)
		if tex then
			return tex
		end
	end
	if C_Spell and C_Spell.GetSpellTexture then
		local tex = C_Spell.GetSpellTexture(1269472)
		if tex then
			return tex
		end
	end
	return "Interface\\Icons\\inv_10_tailoring_embroiderythread_color1"
end

function FK:GoldPerHour(totals)
	totals = totals or self:SessionTotals()
	local elapsed = totals.elapsed or 0
	if elapsed <= 0 then
		return 0, 0
	end
	local gph = (totals.copper or 0) * 3600 / elapsed
	local cph = (totals.catches or 0) * 3600 / elapsed
	return gph, cph
end

local chatFilterInstalled = false
function FK:ShouldHideLootChat(msg)
	if not self.db or not self.db.settings.announce then
		return false
	end
	local now = GetTime()
	local fishing = now <= (self.fishingUntil or 0) or now <= (self.treasureUntil or 0)
	local link = ExtractItemLink(msg)
	if not link then
		return fishing
	end
	local itemID = ItemIDFromLink(link)
	if itemID and self.recentItems[itemID] and (now - self.recentItems[itemID]) < 6 then
		return true
	end
	local name = link:match("%[(.-)%]")
	if self:IsFishItem(itemID, name, link) or self:IsChestItem(itemID, name) then
		return true
	end
	return fishing
end

function FK:InstallChatFilter()
	if chatFilterInstalled or not ChatFrame_AddMessageEventFilter then
		return
	end
	chatFilterInstalled = true
	ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", function(_, _, msg)
		return FK:ShouldHideLootChat(msg)
	end)
end

function FK:ParseCoinString(text)
	if not text or text == "" then
		return 0
	end
	local gold = tonumber(text:match("(%d+)%s*|T.-GoldIcon")) or tonumber(text:match("(%d+)%s+[Gg]old")) or 0
	local silver = tonumber(text:match("(%d+)%s*|T.-SilverIcon")) or tonumber(text:match("(%d+)%s+[Ss]ilver")) or 0
	local copper = tonumber(text:match("(%d+)%s*|T.-CopperIcon")) or tonumber(text:match("(%d+)%s+[Cc]opper")) or 0
	if gold == 0 and silver == 0 and copper == 0 then
		-- Bare number is treated as copper only when no coin words/textures exist
		local digits = text:match("(%d+)")
		if digits and not text:find("[A-Za-z]") then
			copper = tonumber(digits) or 0
		end
	end
	return gold * 10000 + silver * 100 + copper
end

function FK:NoteCatch()
	local now = GetTime()
	if now - (self.lastCatchTime or 0) < 0.85 then
		return
	end
	self.lastCatchTime = now
	self:EnsureTimerStarted()
	self:MaybeCompactOnFish()
	local session = self:Session()
	local char = self:Char()
	session.catches = (session.catches or 0) + 1
	char.lifetimeCatches = (char.lifetimeCatches or 0) + 1
	session.zone = self:CurrentZone()
end

function FK:NoteTreasure()
	local now = GetTime()
	if now - (self.lastTreasureTime or 0) < 12 then
		return
	end
	self.lastTreasureTime = now
	self:EnsureTimerStarted()
	local session = self:Session()
	local char = self:Char()
	session.treasures = (session.treasures or 0) + 1
	char.lifetimeTreasures = (char.lifetimeTreasures or 0) + 1
	session.zone = self:CurrentZone()
end

local function EnsureItem(store, itemID, name, link, quality, icon)
	local key = itemID or name or "?"
	local row = store[key]
	if not row then
		row = {
			itemID = itemID,
			name = name or UNKNOWN,
			link = link,
			quality = quality or 0,
			icon = icon,
			count = 0,
			hits = 0,
		}
		store[key] = row
	else
		if link and (not row.link or row.link == "") then
			row.link = link
		end
		if name then
			row.name = name
		end
		if icon then
			row.icon = icon
		end
		if quality and (not row.quality or quality > row.quality) then
			row.quality = quality
		end
	end
	return row
end

function FK:AddItem(itemID, name, link, quality, icon, qty, from)
	qty = qty or 1
	if qty < 1 then
		return
	end
	quality = quality or 0
	local settings = self.db.settings
	if quality < (settings.minQuality or 0) then
		return
	end
	if (not settings.trackJunk) and quality == 0 then
		return
	end

	if itemID and C_Item and C_Item.RequestLoadItemDataByID then
		C_Item.RequestLoadItemDataByID(itemID)
	end

	local session = self:Session()
	local char = self:Char()
	local srow = EnsureItem(session.items, itemID, name, link, quality, icon)
	srow.count = srow.count + qty
	srow.hits = (srow.hits or 0) + 1
	if from == "treasure" then
		srow.from = "treasure"
	end
	local lrow = EnsureItem(char.items, itemID, name, link, quality, icon)
	lrow.count = lrow.count + qty
	lrow.hits = (lrow.hits or 0) + 1
	if from == "treasure" then
		lrow.from = "treasure"
	end

	if itemID then
		self.recentItems[itemID] = GetTime()
	end

	local unitPrice = self:GetItemPrice(link, itemID, quality)
	self.lastCatch = {
		name = name,
		link = link,
		qty = qty,
		quality = quality,
		value = unitPrice * qty,
		itemID = itemID,
	}

	if settings.announce then
		local total = unitPrice * qty
		if total >= (settings.announceMin or 0) then
			local label = link or name or UNKNOWN
			print("|cff7eb8c9FishKeeper|r " .. label .. " x" .. qty .. "  " .. self:FormatMoney(total))
		end
	end
end

function FK:AddMoney(copper)
	copper = tonumber(copper) or 0
	if copper <= 0 then
		return
	end
	if not self.db.settings.trackMoney then
		return
	end
	local session = self:Session()
	local char = self:Char()
	session.moneyCopper = (session.moneyCopper or 0) + copper
	char.moneyCopper = (char.moneyCopper or 0) + copper
	self.lastCatch = {
		name = "Coins",
		link = nil,
		qty = 1,
		quality = 1,
		value = copper,
		itemID = nil,
	}
end

function FK:RecordLootSlot(slot)
	local lootType = GetLootSlotType(slot)
	local icon, name, qty, currencyID, quality, locked, isQuestItem, questID, isActive, isCoin = GetLootSlotInfo(slot)
	if locked and not self.lootFromTreasure then
		return
	end

	local isMoney = isCoin or lootType == SLOT_MONEY
	if isMoney then
		self:AddMoney(self:ParseCoinString(name))
		return
	end

	local from = self.lootFromTreasure and "treasure" or nil
	if lootType == SLOT_CURRENCY then
		local id = currencyID and ("cur:" .. tostring(currencyID)) or name
		self:AddItem(id, name, nil, quality or 1, icon, qty or 1, from)
		return
	end

	local link = GetLootSlotLink(slot)
	qty = (qty and qty > 0) and qty or 1
	local itemID = ItemIDFromLink(link)
	if self:IsChestItem(itemID, name) then
		from = "treasure"
	end
	self:AddItem(itemID, name, link, quality, icon, qty, from)
end

function FK:OnLootReady()
	local ok, fishing = pcall(IsFishingLoot)
	fishing = ok and fishing
	local treasure = self:IsPatientTreasureLoot()
	if not fishing and not treasure then
		return
	end

	local n = GetNumLootItems() or 0
	if n < 1 then
		return
	end

	-- LOOT_READY can fire twice for the same window (data-ready + auto-loot).
	local parts = {}
	for i = 1, n do
		local link = GetLootSlotLink(i)
		local _, name, qty = GetLootSlotInfo(i)
		parts[#parts + 1] = tostring(link or name or i)
		parts[#parts + 1] = tostring(qty or 0)
	end
	local sig = table.concat(parts, "#")
	local now = GetTime()
	if sig == self.lootSig and now < (self.lootLockUntil or 0) then
		return
	end
	self.lootSig = sig
	self.lootLockUntil = now + 1.25

	if treasure and not fishing then
		self.lootFromTreasure = true
		self.treasureUntil = now + 20
		self:NoteTreasure()
	else
		self.lootFromTreasure = false
		self.fishingUntil = now + 2
		self:NoteCatch()
	end
	for i = 1, n do
		self:RecordLootSlot(i)
	end
	self.lootFromTreasure = false
	self:UpdateUI()
end

function FK:OnChatLoot(msg)
	if not msg then
		return
	end
	local now = GetTime()
	local fromTreasure = now <= (self.treasureUntil or 0)
	local link = ExtractItemLink(msg)
	if not link then
		return
	end
	local itemID = ItemIDFromLink(link)
	local name = link:match("%[(.-)%]")
	if not fromTreasure and self:IsChestItem(itemID, name) and self:IsFishingContext() then
		fromTreasure = true
		self.treasureUntil = now + 8
	end
	if not fromTreasure and now > (self.fishingUntil or 0) then
		return
	end
	if itemID and self.recentItems[itemID] and (now - self.recentItems[itemID]) < 2 then
		return
	end
	local qty = tonumber(msg:match("|h|r%s*[xX](%d+)"))
		or tonumber(msg:match("%][xX](%d+)"))
		or tonumber(msg:match("%s[xX](%d+)"))
		or 1
	local quality, icon
	if itemID and C_Item then
		if C_Item.GetItemNameByID then
			name = C_Item.GetItemNameByID(itemID) or name
		end
		if C_Item.GetItemQualityByID then
			quality = C_Item.GetItemQualityByID(itemID)
		end
		if C_Item.GetItemIconByID then
			icon = C_Item.GetItemIconByID(itemID)
		end
	end
	if fromTreasure then
		self:NoteTreasure()
		self:AddItem(itemID, name, link, quality, icon, qty, "treasure")
	else
		self:NoteCatch()
		self:AddItem(itemID, name, link, quality, icon, qty)
	end
	self:UpdateUI()
end

function FK:OnFishingCast(spellID)
	if not self:IsFishingSpell(spellID) then
		return false
	end
	-- One cast per channel start. Ignore repeats while already fishing.
	local now = GetTime()
	if now - (self.lastCastTime or 0) < 0.4 then
		return true
	end
	self.lastCastTime = now
	self.fishingUntil = now + 45
	self:EnsureTimerStarted()
	self:MaybeCompactOnFish()
	local session = self:Session()
	local char = self:Char()
	session.casts = (session.casts or 0) + 1
	char.lifetimeCasts = (char.lifetimeCasts or 0) + 1
	self:UpdateUI()
	return true
end

function FK:OnFishingStop(spellID)
	if not self:IsFishingSpell(spellID) then
		return
	end
	-- Keep a short window so auto-loot / chat loot still counts
	self.fishingUntil = GetTime() + 4
end

function FK:SortedItems(store)
	local list = {}
	if not store then
		return list
	end
	for _, row in pairs(store) do
		list[#list + 1] = row
	end
	local sortMode = self.db.settings.sort or "value"
	table.sort(list, function(a, b)
		if sortMode == "count" then
			if a.count ~= b.count then
				return a.count > b.count
			end
		elseif sortMode == "name" then
			return (a.name or "") < (b.name or "")
		elseif sortMode == "quality" then
			if (a.quality or 0) ~= (b.quality or 0) then
				return (a.quality or 0) > (b.quality or 0)
			end
		else
			local va = self:GetItemPrice(a.link, a.itemID, a.quality) * (a.count or 0)
			local vb = self:GetItemPrice(b.link, b.itemID, b.quality) * (b.count or 0)
			if va ~= vb then
				return va > vb
			end
		end
		return (a.name or "") < (b.name or "")
	end)
	return list
end

function FK:CountItems(store)
	local n = 0
	if not store then
		return 0
	end
	for _, row in pairs(store) do
		n = n + (row.count or 0)
	end
	return n
end

function FK:SumValue(store)
	local total = 0
	if not store then
		return 0
	end
	for _, row in pairs(store) do
		total = total + self:GetItemPrice(row.link, row.itemID) * (row.count or 0)
	end
	return total
end

function FK:SessionTotals()
	local s = self:Session()
	local itemCopper = self:SumValue(s.items)
	return {
		catches = s.catches or 0,
		casts = s.casts or 0,
		treasures = s.treasures or 0,
		items = self:CountItems(s.items),
		copper = itemCopper + (s.moneyCopper or 0),
		itemCopper = itemCopper,
		moneyCopper = s.moneyCopper or 0,
		start = s.start or time(),
		elapsed = self:SessionElapsed(),
		paused = s.paused and true or false,
		zone = s.zone or "",
	}
end

function FK:LifetimeTotals()
	local c = self:Char()
	local itemCopper = self:SumValue(c.items)
	return {
		catches = c.lifetimeCatches or 0,
		casts = c.lifetimeCasts or 0,
		treasures = c.lifetimeTreasures or 0,
		items = self:CountItems(c.items),
		copper = itemCopper + (c.moneyCopper or 0),
	}
end

function FK:ResetSession()
	local key = self:CharKey()
	self.db.sessions[key] = self:NewSession(key)
	self.lastCatch = nil
	self:UpdateUI()
	print("|cff7eb8c9FishKeeper|r Session reset.")
end

function FK:ResetLifetime()
	local key = self:CharKey()
	self.db.chars[key] = {
		lifetimeCatches = 0,
		lifetimeCasts = 0,
		lifetimeTreasures = 0,
		moneyCopper = 0,
		items = {},
	}
	self.db.sessions[key] = self:NewSession(key)
	self.lastCatch = nil
	self:UpdateUI()
	print("|cff7eb8c9FishKeeper|r Lifetime stats cleared for " .. key .. ".")
end

function FK:UpdateUI()
	if self.RefreshUI then
		self:RefreshUI()
	end
end

function FK:PrintHelp()
	print("|cff7eb8c9FishKeeper|r v" .. self.version .. "  Retail fishing tracker")
	print("  /fk                Toggle the window")
	print("  /fk pause          Pause / resume the session timer")
	print("  /fk compact        Compact / expanded")
	print("  /fk price          Toggle Region / Min BO")
	print("  /fk price region   TSM dbregionmarketavg")
	print("  /fk price min      TSM dbminbuyout")
	print("  /fk session        Reset this session")
	print("  /fk reset confirm  Clear lifetime stats for this character")
	print("  /fk lock           Lock/unlock window")
	print("  /fk theme          Cycle window theme")
end

local function Trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

function FK:OnSlash(msg)
	msg = Trim(msg or "")
	local cmd, rest = msg:match("^(%S+)%s*(.-)$")
	cmd = cmd and cmd:lower() or ""
	if cmd == "" or cmd == "toggle" or cmd == "show" or cmd == "hide" then
		self:Toggle()
	elseif cmd == "session" or cmd == "reset" and rest == "session" then
		self:ResetSession()
	elseif cmd == "reset" then
		if rest:lower() == "confirm" or rest:lower() == "lifetime confirm" then
			self:ResetLifetime()
		else
			print("|cff7eb8c9FishKeeper|r Type |cffffffff/fk reset confirm|r to wipe lifetime stats.")
		end
	elseif cmd == "pause" or cmd == "resume" then
		self:TogglePause()
		print("|cff7eb8c9FishKeeper|r Timer " .. (self:IsPaused() and "paused" or "running") .. ".")
	elseif cmd == "compact" or cmd == "small" or cmd == "mini" then
		self:ToggleCompact()
	elseif cmd == "price" then
		rest = rest:lower()
		if rest == "" then
			self:TogglePriceMode()
		elseif rest == "region" or rest == "avg" or rest == "dbregionmarketavg" then
			self.db.settings.priceMode = "region"
			self:UpdateUI()
			print("|cff7eb8c9FishKeeper|r Price: Region avg")
		elseif rest == "min" or rest == "minbuyout" or rest == "dbminbuyout" then
			self.db.settings.priceMode = "minbuyout"
			self:UpdateUI()
			print("|cff7eb8c9FishKeeper|r Price: Min buyout")
		else
			print("|cff7eb8c9FishKeeper|r Use |cffffffff/fk price region|r or |cffffffff/fk price min|r")
		end
	elseif cmd == "announce" then
		self.db.settings.announce = not self.db.settings.announce
		print("|cff7eb8c9FishKeeper|r Announce " .. (self.db.settings.announce and "on" or "off") .. ".")
	elseif cmd == "lock" then
		self.db.settings.lockWindow = not self.db.settings.lockWindow
		print("|cff7eb8c9FishKeeper|r Window " .. (self.db.settings.lockWindow and "locked" or "unlocked") .. ".")
	elseif cmd == "theme" then
		if self.CycleTheme then
			local id = self:CycleTheme(rest)
			print("|cff7eb8c9FishKeeper|r Theme: " .. id)
		end
	elseif cmd == "sort" then
		rest = rest:lower()
		if rest == "value" or rest == "count" or rest == "name" or rest == "quality" then
			self.db.settings.sort = rest
			self:UpdateUI()
			print("|cff7eb8c9FishKeeper|r Sort: " .. rest)
		else
			print("|cff7eb8c9FishKeeper|r Sort must be value, count, name, or quality.")
		end
	elseif cmd == "help" or cmd == "?" then
		self:PrintHelp()
	else
		self:PrintHelp()
	end
end

-- Events
local driver = CreateFrame("Frame", "FishKeeperDriver")
driver:RegisterEvent("ADDON_LOADED")
driver:RegisterEvent("PLAYER_LOGIN")
driver:RegisterEvent("PLAYER_ENTERING_WORLD")
driver:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
driver:RegisterEvent("LOOT_READY")
driver:RegisterEvent("LOOT_CLOSED")
driver:RegisterEvent("CHAT_MSG_LOOT")
driver:RegisterEvent("GET_ITEM_INFO_RECEIVED")
driver:RegisterEvent("UNIT_SPELLCAST_SENT")
driver:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
driver:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
driver:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
driver:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")

driver:SetScript("OnEvent", function(_, event, ...)
	if event == "ADDON_LOADED" then
		local name = ...
		if name ~= ADDON_NAME then
			return
		end
		FK.recentItems = FK.recentItems or {}
		FK:InitDB()
		if FK.CreateUI then
			FK:CreateUI()
		end
		FK:InstallChatFilter()
		return
	end
	if not FK.db then
		return
	end
	if event == "PLAYER_LOGIN" then
		FK:InstallChatFilter()
		if FK.db.settings.resetSessionOnLogin then
			FK.db.sessions[FK:CharKey()] = FK:NewSession()
		end
		FK:UpdateUI()
	elseif event == "PLAYER_ENTERING_WORLD" then
		FK:UpdateUI()
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		FK:UpdateUI()
	elseif event == "LOOT_READY" then
		FK:OnLootReady()
	elseif event == "LOOT_CLOSED" then
		-- Release the double-fire lock shortly after close, keep recent-item de-dupe
		FK.lootLockUntil = GetTime() + 0.3
	elseif event == "CHAT_MSG_LOOT" then
		FK:OnChatLoot(...)
	elseif event == "GET_ITEM_INFO_RECEIVED" then
		if FK.frame and FK.frame:IsShown() then
			FK:UpdateUI()
		end
	elseif event == "UNIT_SPELLCAST_SENT" then
		local unit, target, _, spellID = ...
		FK:OnSpellcastSent(unit, target, spellID)
	elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_START" then
		local _, a, b = ...
		local spellID = b
		if type(b) ~= "number" and type(a) == "number" then
			spellID = a
		end
		if not FK:OnFishingCast(spellID) and C_Timer and C_Timer.After then
			C_Timer.After(0, function()
				FK:OnFishingCast(spellID)
			end)
		end
	elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_STOP" then
		local _, _, spellID = ...
		FK:OnFishingStop(spellID)
	end
end)

if C_Timer and C_Timer.NewTicker then
	C_Timer.NewTicker(8, function()
		if FK.frame and FK.frame:IsShown() then
			FK:UpdateUI()
		end
	end)
end

SLASH_FISHKEEPER1 = "/fishkeeper"
SLASH_FISHKEEPER2 = "/fk"
SlashCmdList.FISHKEEPER = function(msg)
	FK:OnSlash(msg)
end
