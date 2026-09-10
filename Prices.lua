--[[
	FishKeeper prices
	TSM_API.GetCustomPriceValue is the only AH source this addon uses.
	When TSM is missing or has no data, vendor sell from C_Item is used.
]]

local FK = FishKeeper

function FK:IsTSMReady()
	return type(TSM_API) == "table"
		and type(TSM_API.GetCustomPriceValue) == "function"
		and type(TSM_API.ToItemString) == "function"
end

function FK:IsCustomPriceValid(priceStr)
	if not priceStr or priceStr == "" then
		return false
	end
	if self:IsTSMReady() and type(TSM_API.IsCustomPriceValid) == "function" then
		local ok, valid = pcall(TSM_API.IsCustomPriceValid, priceStr)
		if ok then
			return valid and true or false
		end
	end
	-- Allow the string through if TSM is not loaded yet; it will be used later
	return true
end

local function TSMItemString(link, itemID)
	if not TSM_API or type(TSM_API.ToItemString) ~= "function" then
		if itemID and type(itemID) == "number" then
			return "i:" .. tostring(itemID)
		end
		return nil
	end
	if link then
		local ok, str = pcall(TSM_API.ToItemString, link)
		if ok and type(str) == "string" and str ~= "" then
			return str
		end
	end
	if itemID and type(itemID) == "number" then
		local ok, str = pcall(TSM_API.ToItemString, "i:" .. tostring(itemID))
		if ok and type(str) == "string" and str ~= "" then
			return str
		end
		return "i:" .. tostring(itemID)
	end
	return nil
end

local function VendorSell(link, itemID)
	if C_Item and C_Item.GetItemInfo then
		local target = link or itemID
		if target then
			local ok, sell = pcall(function()
				return select(11, C_Item.GetItemInfo(target))
			end)
			if ok and type(sell) == "number" and sell > 0 then
				return sell
			end
		end
	end
	return 0
end

-- Returns copper (integer >= 0). Never nil.
-- Price toggle: Region avg (dbregionmarketavg) or Min buyout (dbminbuyout).
-- If the chosen source has no data, try the other, then vendor sell.
function FK:GetPriceSource()
	local mode = self.db and self.db.settings and self.db.settings.priceMode
	if mode == "minbuyout" then
		return "dbminbuyout"
	end
	return "dbregionmarketavg"
end

function FK:ItemQuality(link, itemID, quality)
	if type(quality) == "number" then
		return quality
	end
	if itemID and C_Item and C_Item.GetItemQualityByID then
		local ok, q = pcall(C_Item.GetItemQualityByID, itemID)
		if ok and type(q) == "number" then
			return q
		end
	end
	if (link or itemID) and C_Item and C_Item.GetItemInfo then
		local ok, q = pcall(function()
			return select(3, C_Item.GetItemInfo(link or itemID))
		end)
		if ok and type(q) == "number" then
			return q
		end
	end
	return 1
end

function FK:GetItemPrice(link, itemID, quality)
	if type(itemID) == "string" and itemID:find("^cur:") then
		return 0
	end
	quality = self:ItemQuality(link, itemID, quality)
	-- Poor / grey always uses vendor sell, never AH.
	if quality == 0 then
		return VendorSell(link, itemID)
	end
	local primary = self:GetPriceSource()
	local secondary = primary == "dbminbuyout" and "dbregionmarketavg" or "dbminbuyout"

	if self:IsTSMReady() then
		local itemString = TSMItemString(link, itemID)
		if itemString then
			for _, source in ipairs({ primary, secondary }) do
				local ok, value = pcall(TSM_API.GetCustomPriceValue, source, itemString)
				if ok and type(value) == "number" and value > 0 then
					return math.floor(value + 0.5)
				end
			end
		end
	end

	return VendorSell(link, itemID)
end

function FK:FormatMoney(copper)
	copper = math.floor(tonumber(copper) or 0)
	if copper < 0 then
		copper = 0
	end
	if self:IsTSMReady() and type(TSM_API.FormatMoneyString) == "function" then
		local ok, s = pcall(TSM_API.FormatMoneyString, copper)
		if ok and type(s) == "string" and s ~= "" then
			return s
		end
	end
	if GetMoneyString then
		local ok, s = pcall(GetMoneyString, copper, true)
		if ok and type(s) == "string" then
			return s
		end
	end
	if C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString then
		local ok, s = pcall(C_CurrencyInfo.GetCoinTextureString, copper)
		if ok and type(s) == "string" then
			return s
		end
	end
	local g = math.floor(copper / 10000)
	local s = math.floor((copper % 10000) / 100)
	local c = copper % 100
	if g > 0 then
		return string.format("%dg %ds %dc", g, s, c)
	elseif s > 0 then
		return string.format("%ds %dc", s, c)
	end
	return string.format("%dc", c)
end

function FK:FormatMoneyPlain(copper)
	copper = math.floor(tonumber(copper) or 0)
	if copper < 0 then
		copper = 0
	end
	local g = math.floor(copper / 10000)
	local s = math.floor((copper % 10000) / 100)
	local c = copper % 100
	if g > 0 then
		if s > 0 and c > 0 then
			return string.format("%dg %ds %dc", g, s, c)
		elseif s > 0 then
			return string.format("%dg %ds", g, s)
		elseif c > 0 then
			return string.format("%dg %dc", g, c)
		end
		return string.format("%dg", g)
	elseif s > 0 then
		if c > 0 then
			return string.format("%ds %dc", s, c)
		end
		return string.format("%ds", s)
	end
	return string.format("%dc", c)
end

function FK:FormatGoldNumber(copper)
	return string.format("%.2f", (tonumber(copper) or 0) / 10000)
end

function FK:PriceSourceLabel()
	if self.db and self.db.settings and self.db.settings.priceMode == "minbuyout" then
		return "Min BO"
	end
	return "Region"
end
