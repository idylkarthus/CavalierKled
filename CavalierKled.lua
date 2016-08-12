if myHero.charName ~= "Kled" then return end
require("UPL")
UPL = UPL()
require "VPrediction"
TITANIC = false
TITANICSLOT = nil
TIAMAT = false
TIAMATSLOT = nil
Mount = true
smite = nil
ignite = nil
KledVersion = 1.7
MinionsLeft = 0
HitsLeft = 0
ShotsLeftMin = 0
ShotsLeftMax = 0
local VP = VPrediction()

function OnLoad()
	AutoUpdater()
    Config = scriptConfig("Cavalier Kled V1.7", "JJ")
    Config:addParam("shoot", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
    Config:addSubMenu("Combo", "combo")
    Config.combo:addParam("comboQm", "Use Mounted Q in combo", SCRIPT_PARAM_ONOFF, true)
    Config.combo:addParam("comboQ", "Use Gun Q in combo", SCRIPT_PARAM_ONOFF, true)
    Config.combo:addParam("comboCloseQ", "Limit Gun Q range", SCRIPT_PARAM_ONOFF, true)
    Config.combo:addParam("ComboCloseQRange", "Gun Q Range Limit", SCRIPT_PARAM_SLICE, 125, 0, 700, 0)
    Config.combo:addParam("comboE1", "Use First (E) dash in combo", SCRIPT_PARAM_ONOFF, true)
    Config.combo:addParam("comboE2", "Use Second(E) dash in combo", SCRIPT_PARAM_ONOFF, true)
    Config.combo:addParam("delayE", "Always Delay First (E)", SCRIPT_PARAM_ONOFF, true)
    Config:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
    Config:addSubMenu("Harass", "poke")
    Config.poke:addParam("harassQm", "Use Mounted (Q) in harass", SCRIPT_PARAM_ONOFF, false)
    Config.poke:addParam("harassQ", "Use Gun (Q) in harass", SCRIPT_PARAM_ONOFF, true)
    Config.poke:addParam("harassE1", "Use First (E) dash in harass", SCRIPT_PARAM_ONOFF, false)
    Config.poke:addParam("harassE2", "Use Second(E) dash in harass", SCRIPT_PARAM_ONOFF, false)
    Config:addSubMenu("Kill Steal", "ks")
    Config.ks:addParam("ksQm", "Use Mounted Q in KS", SCRIPT_PARAM_ONOFF, true)
    Config.ks:addParam("ksQ", "Use Gun Q in KS", SCRIPT_PARAM_ONOFF, true)
    Config.ks:addParam("ksQpellets", "Extra Pellets to Gun Q Dmg", SCRIPT_PARAM_LIST, 1, {"1", "2", "3","4"})
    Config.ks:addParam("ksE1", "Use First (E) dash in KS", SCRIPT_PARAM_ONOFF, true)
    Config.ks:addParam("ksE2", "Use Second(E) dash in KS", SCRIPT_PARAM_ONOFF, true)
    Config.ks:addParam("ksSmiteSum", "Smite them dead", SCRIPT_PARAM_ONOFF, true)
    Config.ks:addParam("ksIgniteSum", "Ignite the fuckers", SCRIPT_PARAM_ONOFF, true)
    Config:addParam("clear", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
    Config:addSubMenu("Farm", "clearsettings")
    Config.clearsettings:addParam("clearQm", "Farm with Mounted Q", SCRIPT_PARAM_LIST, 1, {"Last Hit", "Clear", "Disabled"})
    Config.clearsettings:addParam("clearQ", "Farm with Gun Q", SCRIPT_PARAM_LIST, 1, {"Last Hit", "Clear", "Disabled"})
    Config.clearsettings:addParam("clearE1", "Farm with First (E) Dash", SCRIPT_PARAM_LIST, 3, {"Last Hit", "Clear", "Disabled"})

    Config:addSubMenu("Draw", "draw")
    Config.draw:addParam("rangetest", "Champion Circle", SCRIPT_PARAM_SLICE, 500, 0, 2000, 1)
    Config.draw:addParam("customrange", "Draw Custom Range Circle", SCRIPT_PARAM_ONOFF, true)
    Config.draw:addParam("drawbar", "Draw Mount Info On HP Bar", SCRIPT_PARAM_ONOFF, true)
    Config.draw:addParam("drawscreen", "Draw Mount Info On Screen", SCRIPT_PARAM_ONOFF, true)
    Config.draw:addParam("ultrange", "Draw Minimap Ult Range", SCRIPT_PARAM_ONOFF, true)
    targetSelector = TargetSelector(TARGET_LESS_CAST, 900, DAMAGE_PHYSICAL, true)


    UPL:AddToMenu(Config)
    UPL:AddSpell(_Q, { speed = 1600, delay = 0.25, range = 750, width = 70, collision = false, aoe = false, type = "linear" })
    UPL:AddSpell(_W, { speed = 2800, delay = 0.50, range = 700, width = 70, collision = false, aoe = true, type = "cone" })
    UPL:AddSpell(_E, { speed = 1600, delay = 0.25, range = 550, width = 70, collision = false, aoe = true, type = "linear" })
end

function AutoUpdater()
    local ToUpdate = {}
    ToUpdate.Version = KledVersion
    ToUpdate.UseHttps = true
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/idylkarthus/CavalierKled/master/CavalierKled.Version"
    ToUpdate.ScriptPath =  "/idylkarthus/CavalierKled/master/CavalierKled.lua"
    ToUpdate.SavePath = SCRIPT_PATH.."/CavalierKled.lua"
    ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) print("<font color=\"#FF794C\"><b>CavalierKled: </b></font> <font color=\"#FFDFBF\">Updated to "..NewVersion..", Double F9. </b></font>") end
    ToUpdate.CallbackNoUpdate = function(OldVersion) print("<font color=\"#FF794C\"><b>CavalierKled: </b></font> <font color=\"#FFDFBF\">No Updates Found</b></font>") end
    ToUpdate.CallbackNewVersion = function(NewVersion) print("<font color=\"#FF794C\"><b>CavalierKled: </b></font> <font color=\"#FFDFBF\">New Version found ("..NewVersion.."). Please wait until its downloaded</b></font>") end
    ToUpdate.CallbackError = function(NewVersion) print("<font color=\"#FF794C\"><b>CavalierKled: </b></font> <font color=\"#FFDFBF\">Error while Downloading. Please try again.</b></font>") end
    ScriptUpdate(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
end

function OnTick()
	GetTiamat()
	GetTitanic()
	targetSelector:update()
	Target = targetSelector.target
	MinionsLeft = math.ceil((100-myHero.mana)/4)
	HitsLeft = math.ceil((100-myHero.mana)/15)
	ShotsLeftMin = math.ceil((100-myHero.mana)/25)
	ShotsLeftMax = math.ceil((100-myHero.mana)/5)
	
	--print(tostring( GetDistance(myHero, mousePos) ))
	if Config.shoot then
		Combo()
	end
	if Config.harass then
		Harass()
	end
	if Config.clear then
		Farm()
	end
	RSteal()
	smiteDmg = 20 + 8 * myHero.level
	igniteDmg = 50 + 20*myHero.level
	if smite == nil then
		smite = Slot("S5_SummonerSmitePlayerGanker")
	elseif Config.ks.ksSmiteSum then
		ksSmite()
	end
	if ignite == nil then
		ignite = Slot("SummonerDot")
	elseif Config.ks.ksIgniteSum then
		ksIgnite()
	end
	if Target then

	end
end

function Farm()
	for _, minion in pairs(minionManager(MINION_ENEMY, 750, myHero, MINION_SORT_HEALTH_ASC).objects) do
		local qDmg = GetQDamage(minion)
        local eDmg = GetEDamage(minion)
		if myHero:GetSpellData(_Q).name == "KledRiderQ"  then
			local hp = VP:GetPredictedHealth(minion, GetDistance(minion)/2800 + 0.250)
			if myHero:CanUseSpell(_Q) == READY and (hp < qDmg or Config.clearsettings.clearQ == 2) and hp > 0 and Config.clearsettings.clearQ ~= 3 and (GetDistance(minion) > myHero.range or Config.clearsettings.clearQ == 2) then
					CastSpell(_Q, minion.x, minion.z)
			end
		elseif myHero:GetSpellData(_Q).name == "KledQ"  then
			local hp = VP:GetPredictedHealth(minion, GetDistance(minion)/1600 + 0.250)
			if myHero:CanUseSpell(_Q) == READY and (hp < qDmg or Config.clearsettings.clearQm == 2) and hp > 0 and Config.clearsettings.clearQm ~= 3 and (GetDistance(minion) > 225 or Config.clearsettings.clearQm == 2) then
				CastSpell(_Q, minion)
			end
		end
		if myHero:GetSpellData(_E).name == "KledE" and GetDistance(minion) < 550 then
			local hp = VP:GetPredictedHealth(minion, GetDistance(minion)/1600 + 0.250)
			if myHero:CanUseSpell(_E) == READY and (hp < qDmg or Config.clearsettings.clearE1 == 2) and hp > 0 and Config.clearsettings.clearE1 ~= 3 and (GetDistance(minion) > myHero.range or Config.clearsettings.clearQ == 2) then
				CastSpell(_E, minion)
			end
		end	
    end
end

function ksSmite()
    if smite then
        for i, enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy, 500) then
                if enemy.health < smiteDmg then
                    CastSpell(smite, enemy)
                end
            end
        end
    end
end

function ksIgnite()
    if ignite then
        for i, enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy, 500) then
                if enemy.health < igniteDmg then
                    CastSpell(ignite, enemy)
                end
            end
        end
    end
end

function Slot(name)
    if myHero:GetSpellData(SUMMONER_1).name == name then
        return SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name == name then
        return SUMMONER_2
    end
end


function OnDraw()
	if Config.draw.customrange then
		DrawCircle(myHero.x, myHero.y, myHero.z, Config.draw.rangetest, ARGB(255,255,255,255))
	end
	if myHero.range >= 250 then
		if Config.draw.drawbar then
			local barPos = GetUnitHPBarPos(myHero);
			local off = GetUnitHPBarOffset(myHero);
			local y = barPos.y + (off.y * 53) + 2;
			local x = barPos.x + (0 * 140) - 25;
			if OnScreen(barPos.x, barPos.y) and not myHero.dead and myHero.visible then
				DrawText("Hit enemy's: ".. HitsLeft .. " times", 15, x-43, y-34, 0xFFFFFFFF);
				DrawText("Kill: ".. MinionsLeft .. " minions", 15, x-43, y-48, 0xFFFFFFFF);
				DrawText("Land: ".. ShotsLeftMin .. " - " .. ShotsLeftMax .. " (Q)s", 15, x-43, y-62, 0xFFFFFFFF);
			end
		end
		if Config.draw.drawscreen then
			DrawText("Hit enemy's: ".. HitsLeft .. " times", 30, 0, 34, 0xFFFFFFFF);
			DrawText("Kill: ".. MinionsLeft .. " minions", 30, 0, 62, 0xFFFFFFFF);
			DrawText("Land: ".. ShotsLeftMin .. " - " .. ShotsLeftMax .. " (Q)s", 30, 0, 90, 0xFFFFFFFF);
		end
	end
	if myHero:CanUseSpell(_R) == READY and Config.draw.ultrange then
		DrawCircleMinimap(myHero.x-50, myHero.y, myHero.z, 4800, 2, ARGB(255,255,255,255), 20)
	end
end

function FindSlotByName(name)
  	if name ~= nil then
    	for i=0, 12 do
      		if string.lower(myHero:GetSpellData(i).name) == string.lower(name) then
        		return i
      		end
    	end
  	end  
  	return nil
end

function GetItem(name)
  	local slot = FindSlotByName(name)
  	return slot 
end


function CastTiamat()
  	if TIAMAT then
    	if (myHero:CanUseSpell(TIAMATSLOT) == READY) then
     		CastSpell(TIAMATSLOT)
    	end
  	end
end

function CastTITANIC()
  	if TITANIC then
    	if (myHero:CanUseSpell(TITANICSLOT) == READY) then
      		CastSpell(TITANICSLOT)
    	end
  	end
end

function GetTiamat()
  	local slot = GetItem("ItemTiamatCleave")
  	if (slot ~= nil) then
    	TIAMAT = true
    	TIAMATSLOT = slot
  	else
    	TIAMAT = false
  	end
end

function GetTitanic()
  	local slot = GetItem("ItemTitanicHydraCleave")
  	if (slot ~= nil) then
    	TITANIC = true
    	TITANICSLOT = slot
  	else
    	TITANIC = false
  	end
end

function Harass()
	if Target then
		if myHero:CanUseSpell(_Q) == READY and GetDistance(Target) < 750 then		
			if Config.poke.harassQm == true and myHero:GetSpellData(_Q).name == "KledQ" then
				CastQ(Target)
			end
			if Config.poke.harassQ == true and myHero:GetSpellData(_Q).name == "KledRiderQ" then
				CastQ(Target)
			end
		end
		if myHero:CanUseSpell(_E) == READY and GetDistance(Target) < 550 then
			if Config.poke.harassE1 == true and myHero:GetSpellData(_E).name == "KledE" then
				CastE(Target)
			end
			if Config.poke.harassE2 == true and myHero:GetSpellData(_E).name == "KledE2" then
				CastE(Target)
			end
		end
	end
end

function Combo()
	if Target then
		if myHero:CanUseSpell(_Q) == READY then
			if Config.combo.comboQm == true and myHero:GetSpellData(_Q).name == "KledQ" then
				CastQ(Target)
				--DelayAction(function() CastE(Target) end, 1.0)
			end
			if Config.combo.comboQ == true and myHero:GetSpellData(_Q).name == "KledRiderQ" and ((GetDistance(Target) < Config.combo.ComboCloseQRange and Config.combo.comboCloseQ) or not Config.combo.comboCloseQ) then
				CastQ(Target)
			end
		end
		--TargetHaveBuff("kledqmark", target) == false 
		if myHero:CanUseSpell(_E) == READY and (GetSpellData(_Q).currentCd > 0 or GetSpellData(_Q).level < 1 or Config.combo.comboQm ~= true) and ((GetSpellData(_Q).currentCd < GetSpellData(_Q).cd-0.65 and GetSpellData(_Q).level >= 1) or (GetDistance(Target) > 210 and (Config.combo.delayE == false or GetSpellData(_Q).level < 1))) then
			if Config.combo.comboE1 == true and myHero:GetSpellData(_E).name == "KledE" then
				CastE(Target)
			end
			if Config.combo.comboE2 == true and myHero:GetSpellData(_E).name == "KledE2" and GetDistance(Target) > 210 then
				CastE(Target)
			end
		end
		if GetDistance(Target) < 440 and myHero:CanUseSpell(_Q) ~= READY and myHero:CanUseSpell(_E) ~= READY then
			CastTiamat()
		end
		if GetDistance(Target) < 440 and myHero:CanUseSpell(_Q) ~= READY and myHero:CanUseSpell(_E) ~= READY then
			CastTITANIC()
		end	
	end
end

function GetEDamage(unit)
	local Elvl = myHero:GetSpellData(_E).level
	if Elvl < 1 then return 0 end
	local EDmg = {20, 45, 70, 95, 120}
	local EDmgMod = 0.60
	local DmgRaw = EDmg[Elvl] + (myHero.addDamage * EDmgMod)
	local Dmg = myHero:CalcDamage(unit, DmgRaw)
	return Dmg
end

function GetQDamage(unit)
	if myHero:GetSpellData(_Q).name == "KledQ" then
		local Qlvl = myHero:GetSpellData(_Q).level
		if Qlvl < 1 then return 0 end
		local QDmg = {25, 50, 75, 100, 125}
		local QDmgMod = 0.60
		local DmgRaw = QDmg[Qlvl] + (myHero.addDamage * QDmgMod)
		local Dmg = myHero:CalcDamage(unit, DmgRaw)
		return Dmg
	elseif myHero:GetSpellData(_Q).name == "KledRiderQ" then
		local Qlvl = myHero:GetSpellData(_Q).level
		if Qlvl < 1 then return 0 end
		local QDmg = {30, 45, 60, 75, 90}
		local QDmgMod = 0.80
		local DmgRaw = QDmg[Qlvl] + (myHero.addDamage * QDmgMod)
		local Dmg = myHero:CalcDamage(unit, DmgRaw)
		return Dmg
	end
end


function CastQ(target)
	if target == nil then 
		return 
	end
	if myHero:GetSpellData(_Q).name == "KledQ" and myHero:CanUseSpell(_Q) == READY and GetDistance(Target) < 750 then
		CastPosition, HitChance, HeroPosition = UPL:Predict(_Q, myHero, target)
		if CastPosition and HitChance > 0 and myHero:CanUseSpell(_Q) == READY then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	elseif myHero:GetSpellData(_Q).name == "KledRiderQ" and myHero:CanUseSpell(_Q) == READY and GetDistance(Target) < 700 then
		CastPosition, HitChance, HeroPosition = UPL:Predict(_W, myHero, target)
		if CastPosition and HitChance > 0 and myHero:CanUseSpell(_Q) == READY then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end


function CastE(target)
	if target == nil then 
		return 
	end
	if myHero:GetSpellData(_E).name == "KledE" and myHero:CanUseSpell(_E) == READY and GetDistance(target) < 550 then
		CastPosition, HitChance, HeroPosition = UPL:Predict(_E, myHero, target)
		if CastPosition and HitChance > 0 and myHero:CanUseSpell(_E) == READY then
			CastSpell(_E, CastPosition.x, CastPosition.z)
		end
	elseif myHero:GetSpellData(_E).name == "KledE2" and myHero:CanUseSpell(_E) == READY and GetDistance(target) < 625 and TargetHaveBuff("klede2target", target) and (GetDistance(target) > 210 or target.health < GetEDamage(target)) then
		--print("Casted Fuck the Attack Dash")
		CastSpell(_E)
	end
end


function RSteal() 
	for i,enemy in pairs(GetEnemyHeroes()) do
    	if not enemy.dead and enemy.visible then
			if myHero:CanUseSpell(_Q) == READY then		
				if myHero:GetSpellData(_Q).name == "KledQ" and enemy.health < GetQDamage(enemy) and ValidTarget(enemy, 750) and Config.ks.ksQm then
					CastQ(enemy)
				end
				if myHero:GetSpellData(_Q).name == "KledRiderQ" and enemy.health < GetQDamage(enemy)+GetQDamage(enemy)*(0.2*Config.ks.ksQpellets) and ValidTarget(enemy, 700) and Config.ks.ksQ then
					CastQ(enemy)
				end
			end
			if myHero:CanUseSpell(_E) == READY then
				if myHero:GetSpellData(_E).name == "KledE" and enemy.health < GetEDamage(enemy) and ValidTarget(enemy, 550) and Config.ks.ksE1 then
					CastE(enemy)
				end
				if myHero:GetSpellData(_E).name == "KledE2" and enemy.health < GetEDamage(enemy) and ValidTarget(enemy, 625) and TargetHaveBuff("klede2target", enemy) and Config.ks.ksE2 then
					CastSpell(_E)
				end
			end
		end
	end
end


function OnUpdateBuff(Src, Buff, iStacks)
	if Src == Target then
		--print(Buff.name)
	end
end

function OnCreateObj(obj)
	if GetDistance(obj) < 1000 then
		--PrintChat(obj.name)
	end
end


function OnDeleteObj(obj)
	if GetDistance(obj) < 1000 then
		--PrintChat(obj.name)
	end
end

function OnProcessSpell(unit, spell)
	if unit == myHero then
		--print(spell.name)
	end
	--print(spell.name)
end
function OnProcessAttack(unit, attack)
	if unit == myHero then
			--print(attack.name)
	end
	if unit == myHero and (attack.name == "KledWAttack1" or attack.name == "KledWAttack2" or attack.name == "KledWAttack3" or attack.name == "KledWAttack4" or attack.name == "KledBasicAttack" or attack.name == "KledBasicAttack2" or attack.name == "KledBasicAttack3") then
		--print("Attacked")
		if Target and Config.shoot then
			if myHero:GetSpellData(_E).name == "KledE2" and myHero:CanUseSpell(_E) == READY and GetDistance(Target) < 625 and TargetHaveBuff("klede2target", Target) and Config.combo.comboE2 == true then
				--print("Casted After Attack Dash")
				CastSpell(_E)
			end
			if myHero:GetSpellData(_E).name == "KledE" and myHero:CanUseSpell(_E) == READY and GetDistance(Target) < 550 and (GetSpellData(_Q).currentCd > 0 or GetSpellData(_Q).level < 1) and Config.combo.comboE1 == true then
				CastE(Target)
			end
		end
	end
end

function OnCastSpell(iSpell, startPos, endPos, Target)
    --print(iSpell)	
end
class "ScriptUpdate"
function ScriptUpdate:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.CallbackError = CallbackError
    AddDrawCallback(function() self:OnDraw() end)
    self:CreateSocket(self.VersionPath)
    self.DownloadStatus = 'Connect to Server for VersionInfo'
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function ScriptUpdate:print(str)
    print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function ScriptUpdate:OnDraw()
    if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)'then
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
    end
end

function ScriptUpdate:CreateSocket(url)
    if not self.LuaSocket then
        self.LuaSocket = require("socket")
    else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
    end
    self.LuaSocket = require("socket")
    self.Socket = self.LuaSocket.tcp()
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.Socket:connect('sx-bol.eu', 80)
    self.Url = url
    self.Started = false
    self.LastPrint = ""
    self.File = ""
end

function ScriptUpdate:Base64Encode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function ScriptUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end

    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading VersionInfo (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</s'..'ize>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading VersionInfo ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') then
        self.DownloadStatus = 'Downloading VersionInfo (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.File:find('<scr'..'ipt>')
        local ContentEnd, _ = self.File:find('</sc'..'ript>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1,ContentEnd-1)))
            self.OnlineVersion = tonumber(self.OnlineVersion)
            if self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
                self:CreateSocket(self.ScriptPath)
                self.DownloadStatus = 'Connect to Server for ScriptDownload'
                AddTickCallback(function() self:DownloadUpdate() end)
            else
                if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                    self.CallbackNoUpdate(self.LocalVersion)
                end
            end
        end
        self.GotScriptVersion = true
    end
end

function ScriptUpdate:DownloadUpdate()
    if self.GotScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading Script (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</si'..'ze>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading Script ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') then
        self.DownloadStatus = 'Downloading Script (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.NewFile:find('<sc'..'ript>')
        local ContentEnd, _ = self.NewFile:find('</scr'..'ipt>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            local newf = self.NewFile:sub(ContentStart+1,ContentEnd-1)
            local newf = newf:gsub('\r','')
            if newf:len() ~= self.Size then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
                return
            end
            local newf = Base64Decode(newf)
            if type(load(newf)) ~= 'function' then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
            else
                local f = io.open(self.SavePath,"w+b")
                f:write(newf)
                f:close()
                if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                    self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
                end
            end
        end
        self.GotScriptUpdate = true
    end
end

