local SP = SmoothyPlates;

local Utils = {};

-- MISC --

Utils.percent = function(is, from)
	return Utils.round((is / from) * 100)
end

Utils.round = function(n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

Utils.contains = function(tbl, value)
	for i,n in pairs(tbl) do
		if n == value then return true end
	end
	return false
end

Utils.split = function(inputstr, sep, tbl)
	local i = 1;
	local t={};
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			t[i] = str
			i = i + 1
	end
	if tbl then return t else return t[1] end
end

Utils.fromRGB = function(r, g, b, a)
	return (r/255), (g/255), (b/255), (a/255)
end

Utils.getIndex = function(tbl, value)
	for i,n in pairs(tbl) do
		if n == value then return i end
	end
end

Utils.shallowCopy = function(obj)
	if type(obj) ~= 'table' then return obj end
	local res = {}
	for k, v in pairs(obj) do res[Utils.shallowCopy(k)] = Utils.shallowCopy(v) end
	return res
end

Utils.mergeTable = function(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                Utils.mergeTable(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

Utils.stringToTable = function(tableString)
	local tableStringFunction = loadstring(format("%s %s", "return", tableString))
	local message, table
	if tableStringFunction then
		message, table = pcall(tableStringFunction)
	end
	if table then
		return table;
	else
		Utils.print("Error importing:" .. message)
	end
end

Utils.tableToString = function(inTable)
	if type(inTable) ~= "table" then
		return ""
	end

	local ret = "{\n";
	local function recurse(table, level)
		for i,v in pairs(table) do
			ret = ret..strrep("    ", level).."[";
			if(type(i) == "string") then
				ret = ret.."\""..i.."\"";
			else
				ret = ret..i;
			end
			ret = ret.."] = ";

			if(type(v) == "number") then
				ret = ret..v..",\n"
			elseif(type(v) == "string") then
				ret = ret.."\""..v:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\"", "\\\""):gsub("\124", "\124\124").."\",\n"
			elseif(type(v) == "boolean") then
				if(v) then
					ret = ret.."true,\n"
				else
					ret = ret.."false,\n"
				end
			elseif(type(v) == "table") then
				ret = ret.."{\n"
				recurse(v, level + 1);
				ret = ret..strrep("    ", level).."},\n"
			else
				ret = ret.."\""..tostring(v).."\",\n"
			end
		end
	end

	if(inTable) then
		recurse(inTable, 1);
	end
	ret = ret.."}";

	return ret;
end

Utils.tprint = function(tbl, indent)
	if not indent then indent = 0 end
	local count = 0;
	for k, v in pairs(tbl) do
	  count = count + 1;
	  formatting = string.rep("  ", indent) .. k .. ": "
	  if type(v) == "table" then
		print(formatting)
		Utils.tprint(v, indent+1)
	  elseif type(v) == 'boolean' then
		print(formatting .. tostring(v))		
	  elseif type(v) == 'function' then
		print(formatting .. '[FUNCTION REF]')	
	  elseif type(v) == 'userdata' then
		print(formatting .. '[USERDATA REF]')	
	  else
		print(formatting .. v)
	  end
	end
	if count == 0 then print(string.rep("  ", indent) .. '[EMPTY]'); end
end

Utils.print = function(msg)
	print("|cffff0020SmoothyPlates|r: " .. msg)
end

-- GAME INFO --

local UnitDebuff = UnitDebuff;
Utils.getUnitDebuffByName = function(unitid, spellName) 
	for i=1,40 do 
		local name = UnitDebuff(unitid, i);
		if name == spellName then 
			return UnitDebuff(unitid, i);
		end
	end
end

-- UI --

Utils.createSimpleFrame = function(name, parent, useBackdrop)
	if (useBackdrop) then
		return CreateFrame("Frame", name, parent, BackdropTemplateMixin and "BackdropTemplate")
	else 
		return CreateFrame("Frame", name, parent)
	end
end

Utils.getBackdropWithEdge = function(path, tileN, tileSizeN, edgeSizeN, insetSize)
	insetSize = insetSize or 0
	return {
		edgeFile = SP.Vars.ui.textures.TOOLTIP_BORDER,
		bgFile = path,
		tile = tileN,
		tileSize = tileSizeN,
		edgeSize = edgeSizeN,
		insets = {
			left = insetSize,
			right = insetSize,
			top = insetSize,
			bottom = insetSize
		},
	}
end

Utils.getBackdrop = function(path, tileN, tileSizeN)
	return {
		bgFile = path,
		tile = tileN,
		tileSize = tileSizeN
	}
end

Utils.addBorder = function(frame)
	frame:SetBackdrop(SP.Vars.ui.backdrops.stdbd)
    frame:SetBackdropColor(0,0,0,0.6)
end

Utils.addSingleBorders = function(parent, r, g, b, a)
	local size = 1;
	parent.l = Utils.createSimpleFrame(nil, parent, true);
	parent.l:SetSize(size, parent:GetHeight())
	parent.l:SetPoint("LEFT", 0, 0)
	parent.l:SetBackdrop(SP.Vars.ui.backdrops.stdbd)
    parent.l:SetBackdropColor(r,g,b,a)

	parent.r = Utils.createSimpleFrame(nil, parent, true);
	parent.r:SetSize(size, parent:GetHeight())
	parent.r:SetPoint("RIGHT", 0, 0)
	parent.r:SetBackdrop(SP.Vars.ui.backdrops.stdbd)
    parent.r:SetBackdropColor(r,g,b,a)

	parent.t = Utils.createSimpleFrame(nil, parent, true);
	parent.t:SetSize(parent:GetWidth(), size)
	parent.t:SetPoint("TOP", 0, 0)
	parent.t:SetBackdrop(SP.Vars.ui.backdrops.stdbd)
    parent.t:SetBackdropColor(r,g,b,a)

	parent.b = Utils.createSimpleFrame(nil, parent, true);
	parent.b:SetSize(parent:GetWidth(), size)
	parent.b:SetPoint("BOTTOM", 0, 0)
	parent.b:SetBackdrop(SP.Vars.ui.backdrops.stdbd)
    parent.b:SetBackdropColor(r,g,b,a)
end

Utils.createTextureFrame = function(parent, w, h, a, x, y, alpha, defText, dx, dy, dw, dh)
	parent.textureBack = Utils.createSimpleFrame(nil, parent, true)
	parent.textureBack:SetSize(w, h)
	parent.textureBack:SetPoint(a, x, y)
	parent.textureBack:SetAlpha(alpha)

    parent.tex = parent.textureBack:CreateTexture()
	parent.tex:SetAllPoints()

	if defText then
		parent.tex:SetTexture(defText)
		parent.tex:SetTexCoord(dx or 0.07, dy or 0.93, dw or 0.07, dh or 0.93)
		parent.tex:SetAllPoints()
	end

	Utils.addSingleBorders(parent.textureBack, 0,0,0,1);
end


-- Register Global --
SP.Utils = Utils;