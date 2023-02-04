function _OnInit()
if (GAME_ID == 0xF266B00B or GAME_ID == 0xFAF99301) and ENGINE_TYPE == "ENGINE" then --PCSX2
	if ENGINE_VERSION < 3.0 then
		print('LuaEngine is Outdated. Things might not work properly.')
	end
	Btl0 = 0x1CE5D80 --00battle.bin
	Slot1    = 0x1C6C750 --Unit Slot 1
	NextSlot = 0x268
elseif GAME_ID == 0x431219CC and ENGINE_TYPE == 'BACKEND' then --PC
	if ENGINE_VERSION < 5.0 then
		ConsolePrint('LuaBackend is Outdated. Things might not work properly.',2)
	end
	Btl0 = 0x2A74840 - 0x56450E
	Slot1    = 0x2A20C58 - 0x56450E
	NextSlot = 0x278
end
end

function _OnFrame()
local DHP_Now, GHP_Now = PartyHP()
if DHP_Now == 999 or GHP_Now == 999 then return end
	if DHP_Now == 0 or GHP_Now == 0 then
		WriteByte(Btl0+0x33519, 0xFF) --Trinity WI
	    WriteByte(Btl0+0x33559, 0xFF) --Trinity Full
	else
		WriteByte(Btl0+0x33519, 0x01)
	    WriteByte(Btl0+0x33559, 0x01)
	end
end

function PartyHP()
local HP_D = 999
local HP_G = 999
	--Check slots for D&G currentHP
	for i = 0,6 do
		CharID = ReadShort(Slot1-(NextSlot*i)+0x260)
		if CharID == 2 then --Donald
			HP_D = ReadShort(Slot1-(NextSlot*i))
		elseif CharID == 3 then --Goofy
			HP_G = ReadShort(Slot1-(NextSlot*i))
		end
		if i == 6 then 
			return HP_D, HP_G
		end
	end
end