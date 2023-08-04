function _OnInit()
if (GAME_ID == 0xF266B00B or GAME_ID == 0xFAF99301) and ENGINE_TYPE == "ENGINE" then --PCSX2
	if ENGINE_VERSION < 3.0 then
		print('LuaEngine is Outdated. Things might not work properly.')
	end
	OnPC = false
	Btl0Pointer = 0x1C61AFC --00battle.bin
	Slot1    = 0x1C6C750 --Unit Slot 1
	NextSlot = 0x268
elseif GAME_ID == 0x431219CC and ENGINE_TYPE == 'BACKEND' then --PC
	if ENGINE_VERSION < 5.0 then
		ConsolePrint('LuaBackend is Outdated. Things might not work properly.',2)
	end
	OnPC = true
	Btl0Pointer = 0x2AE3558 - 0x56454E
	Slot1    = 0x2A20C58 - 0x56450E
	NextSlot = 0x278
end
end

function BAR(File,Subfile,Offset) --Get address within a BAR file
local Subpoint = File + 0x08 + 0x10*Subfile
local Address
--Detect errors
if ReadInt(File,OnPC) ~= 0x01524142 then --Header mismatch
	return
elseif Subfile > ReadInt(File+4,OnPC) then --Subfile over count
	return
elseif Offset >= ReadInt(Subpoint+4,OnPC) then --Offset exceed subfile length
	return
end
--Get address
Address = File + (ReadInt(Subpoint,OnPC) - ReadInt(File+8,OnPC)) + Offset
return Address
end

function _OnFrame()
if Place == 0xFFFF or not MSN then
	if not OnPC then
		Btl0 = ReadInt(Btl0Pointer)
		MSN = 0x04FA440
	else
		Btl0 = ReadLong(Btl0Pointer)
		MSN = 0x0BF08C0 - 0x56450E
	end
end
local DHP_Now, GHP_Now = PartyHP()
if DHP_Now == 999 or GHP_Now == 999 then return end
	if DHP_Now == 0 or GHP_Now == 0 then
		WriteByte(BAR(Btl0,0x0C,0x449),0xFF,OnPC) --Trinity WI
	    WriteByte(BAR(Btl0,0x0C,0x489),0xFF,OnPC) --Trinity Full
	else
		WriteByte(BAR(Btl0,0x0C,0x449),0x01,OnPC)
	    WriteByte(BAR(Btl0,0x0C,0x489),0x01,OnPC)
	end
end

function PartyHP()
local HP_D = 999
local HP_G = 999
	--Check slots for D&G currentHP
	for i = 0,7 do
		CharID = ReadShort(Slot1-(NextSlot*i)+0x260)
		if CharID == 2 and HP_D == 999 then --Donald
			HP_D = ReadShort(Slot1-(NextSlot*i))
		end
		if CharID == 3 and HP_G == 999 then --Goofy
			HP_G = ReadShort(Slot1-(NextSlot*i))
		end
	end
return HP_D, HP_G
end