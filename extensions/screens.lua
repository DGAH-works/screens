--[[
	太阳神三国杀武将扩展包·八扇屏
	适用版本：V2 - 愚人版（版本号：20150401）清明补丁（版本号：20150405）
	武将总数：8
	武将一览：
		1、苗训（卖卦、军师）
		2、项羽（末路、误信）
		3、曹操（逢故、追悔）
		4、鲁肃（激语、借荆）
		5、姜尚（垂钓、扶保）
		6、王佐（断臂、说降）
		7、张飞（虚实、暴喝）
		8、曹真（阅函、气绝）
	所需标记：
		1、@scrFuBaoMark（“保”标记，来自技能“扶保”）
]]--
module("extensions.screens", package.seeall)
extension = sgs.Package("screens")
--技能暗将
AnJiang = sgs.General(extension, "scrAnJiang", "god", 5, true, true, true)
--翻译信息
sgs.LoadTranslationTable{
	["screens"] = "八扇屏",
}
--[[****************************************************************
	编号：SCR - 001
	武将：苗训
	称号：江湖人
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
MiaoXun = sgs.General(extension, "scrMiaoXun", "qun", 4)
--翻译信息
sgs.LoadTranslationTable{
	["scrMiaoXun"] = "苗训",
	["&scrMiaoXun"] = "苗训",
	["#scrMiaoXun"] = "江湖人",
	["designer:scrMiaoXun"] = "DGAH",
	["cv:scrMiaoXun"] = "无",
	["illustrator:scrMiaoXun"] = "《刘海戏金蟾》吴功（邓捷饰）",
	["~scrMiaoXun"] = "苗训 的阵亡台词",
}
--[[
	技能：卖卦
	描述：一名其他角色的出牌阶段开始时，其可以展示并交给你一张牌。然后你须选择一个花色并进行一次判定。若判定结果与你所选花色相同，该角色获得技能“帝途”直到当前回合结束。
]]--
MaiGua = sgs.CreateTriggerSkill{
	name = "scrMaiGua",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase == sgs.Player_Play then
			if player:isNude() then
				return 
			end
			local others = room:getOtherPlayers(player)
			for _,source in sgs.qlist(others) do
				if source:hasSkill("scrMaiGua") then
					local prompt = string.format("@scrMaiGua:%s:", source:objectName())
					local card = room:askForCard(player, "..", prompt, data, sgs.Card_MethodNone, source, false, "scrMaiGua")
					if card then
						room:notifySkillInvoked(player, "scrMaiGua") --显示技能发动
						room:broadcastSkillInvoke("scrMaiGua", 1) --播放配音
						local msg = sgs.LogMessage()
						msg.type = "#scrMaiGuaStart"
						msg.from = player
						msg.to:append(source)
						room:sendLog(msg) --发送提示信息
						local id = card:getEffectiveId()
						room:showCard(player, id)
						room:obtainCard(source, id, true)
						local suit = room:askForSuit(source, "scrMaiGua")
						suit = sgs.Card_Suit2String(suit)
						msg = sgs.LogMessage()
						msg.type = "#scrMaiGuaSuit"
						msg.from = source
						msg.arg = suit
						room:sendLog(msg) --发送提示信息
						local judge = sgs.JudgeStruct()
						judge.reason = "scrMaiGua"
						judge.who = source
						judge.pattern = string.format(".|%s", suit)
						judge.good = true
						room:judge(judge)
						if judge:isGood() then
							room:broadcastSkillInvoke("scrMaiGua", 2) --播放配音
							msg = sgs.LogMessage()
							msg.type = "#scrMaiGuaGood"
							msg.from = player
							room:sendLog(msg) --发送提示信息
							room:setPlayerMark(player, "scrMaiGuaInvoked", 1)
							room:setPlayerProperty(player, "scrMaiGuaSuit", sgs.QVariant(suit))
							room:handleAcquireDetachSkills(player, "scrDiTu")
							return false
						else
							msg = sgs.LogMessage()
							msg.type = "#scrMaiGuaBad"
							msg.from = player
							room:sendLog(msg) --发送提示信息
						end
						if player:isNude() then
							return false
						end
					end
				end
			end
		elseif phase == sgs.Player_NotActive then
			if player:getMark("scrMaiGuaInvoked") > 0 then
				room:setPlayerMark(player, "scrMaiGuaInvoked", 0)
				room:setPlayerProperty(player, "scrMaiGuaSuit", sgs.QVariant(""))
				room:handleAcquireDetachSkills(player, "-scrDiTu")
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
MiaoXun:addSkill(MaiGua)
--翻译信息
sgs.LoadTranslationTable{
	["scrMaiGua"] = "卖卦",
	[":scrMaiGua"] = "一名其他角色的出牌阶段开始时，其可以展示并交给你一张牌。然后你须选择一个花色并进行一次判定。若判定结果与你所选花色相同，该角色获得技能“帝途”直到当前回合结束。\
\
★<b>帝途</b>：<font color=\"blue\"><b>锁定技</b></font>，你计算的与其他角色的距离为1；你使用一张与“卖卦”判定牌相同花色的牌时，你摸一张牌。",
	["$scrMaiGua1"] = "技能 卖卦 发动技能时 的台词",
	["$scrMaiGua2"] = "技能 卖卦 获得技能时 的台词",
	["@scrMaiGua"] = "您可以展示并交给 %src 一张牌，令其发动技能“卖卦”进行一次判定",
	["#scrMaiGuaStart"] = "出牌阶段开始了，%from 先到 %to 处占了一卦，希望讨一个好彩头",
	["#scrMaiGuaSuit"] = "%from 想了想，选择了 %arg 花色",
	["#scrMaiGuaGood"] = "大吉大利！%from 果然有帝王之相！",
	["#scrMaiGuaBad"] = "占卜的结果不太理想，%from 还是自己努力吧！",
}
--[[
	技能：军师
	描述：一名角色的判定牌生效前，你可以打出一张牌代替之。然后若该角色同意，你摸一张牌。
]]--
JunShi = sgs.CreateTriggerSkill{
	name = "scrJunShi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.AskForRetrial},
	on_trigger = function(self, event, player, data)
		local judge = data:toJudge()
		local source = judge.who
		local prompt = string.format("@scrJunShi:%s::%s:", source:objectName(), judge.reason)
		local room = player:getRoom()
		local card = room:askForCard(player, "..", prompt, data, sgs.Card_MethodResponse, source, true, "scrMaiGua")
		if card then
			room:broadcastSkillInvoke("scrJunShi", 1) --播放配音
			room:notifySkillInvoked(player, "scrJunShi") --显示技能发动
			room:retrial(card, player, judge, "scrJunShi", false)
			if source:isAlive() then
				local ai_data = sgs.QVariant()
				ai_data:setValue(player)
				if source:askForSkillInvoke("scrJunShiDraw", ai_data) then
					room:broadcastSkillInvoke("scrJunShi", 2) --播放配音
					room:drawCards(player, 1, "scrJunShiDraw")
				end
			end
		end
		return false
	end
}
--添加技能
MiaoXun:addSkill(JunShi)
--翻译信息
sgs.LoadTranslationTable{
	["scrJunShi"] = "军师",
	[":scrJunShi"] = "一名角色的判定牌生效前，你可以打出一张牌代替之。然后若该角色同意，你摸一张牌。",
	["$scrJunShi1"] = "技能 军师 改判时 的台词",
	["$scrJunShi2"] = "技能 军师 摸牌时 的台词",
	["@scrJunShi"] = "您可以发动“军师”打出一张牌修改 %src 的“%arg”判定",
	["scrJunShiDraw"] = "军师·同意摸牌",
}
--[[
	技能：帝途（锁定技）
	描述：你计算的与其他角色的距离为1；你使用一张与“卖卦”判定牌相同花色的牌时，你摸一张牌。
]]--
DiTu = sgs.CreateTriggerSkill{
	name = "scrDiTu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		if player:getMark("scrMaiGuaInvoked") > 0 then
			local use = data:toCardUse()
			if player:property("scrMaiGuaSuit"):toString() == use.card:getSuitString() then
				local room = player:getRoom()
				room:broadcastSkillInvoke("scrDiTu") --播放配音
				room:notifySkillInvoked(player, "scrDiTu") --显示技能发动
				room:drawCards(player, 1, "scrDiTu")
			end
		end
		return false
	end,
}
DiTuDist = sgs.CreateDistanceSkill{
	name = "#scrDiTuDist",
	correct_func = function(self, from, to)
		if from:hasSkill("scrDiTu") then
			return -1000
		end
		return 0
	end,
}
extension:insertRelatedSkills("scrDiTu", "#scrDiTuDist")
--添加技能
AnJiang:addSkill(DiTu)
AnJiang:addSkill(DiTuDist)
MiaoXun:addRelateSkill("scrDiTu")
--翻译信息
sgs.LoadTranslationTable{
	["scrDiTu"] = "帝途",
	[":scrDiTu"] = "<font color=\"blue\"><b>锁定技</b></font>，你计算的与其他角色的距离为1；你使用一张与“卖卦”判定牌相同花色的牌时，你摸一张牌。",
	["$scrDiTu"] = "技能 帝途 的台词",
}
--[[****************************************************************
	编号：SCR - 002
	武将：项羽
	称号：浑人
	势力：吴
	性别：男
	体力上限：6勾玉
]]--****************************************************************
XiangYu = sgs.General(extension, "scrXiangYu", "wu", 6)
--翻译信息
sgs.LoadTranslationTable{
	["scrXiangYu"] = "项羽",
	["&scrXiangYu"] = "项羽",
	["#scrXiangYu"] = "浑人",
	["designer:scrXiangYu"] = "DGAH",
	["cv:scrXiangYu"] = "无",
	["illustrator:scrXiangYu"] = "网络资源",
	["~scrXiangYu"] = "项羽 的阵亡台词",
}
--[[
	技能：末路（锁定技）
	描述：若你未受伤，你计算的与其他角色的距离-2；若你已受伤，其他角色计算的与你的距离-1。
]]--
MoLu = sgs.CreateDistanceSkill{
	name = "scrMoLu",
	correct_func = function(self, from, to)
		local fix = 0
		if from:hasSkill("scrMoLu") and not from:isWounded() then
			fix = fix - 2
		end
		if to:hasSkill("scrMoLu") and to:isWounded() then
			fix = fix - 1
		end
		return fix
	end
}
--添加技能
XiangYu:addSkill(MoLu)
--翻译信息
sgs.LoadTranslationTable{
	["scrMoLu"] = "末路",
	[":scrMoLu"] = "<font color=\"blue\"><b>锁定技</b></font>，若你未受伤，你计算的与其他角色的距离-2；若你已受伤，其他角色计算的与你的距离-1。",
}
--[[
	技能：误信
	描述：你成为一名其他角色使用的锦囊牌的目标时，你可以交给其一张装备牌，然后该角色选择一项：弃置你的一张牌，或者令你回复1点体力。
]]--
WuXin = sgs.CreateTriggerSkill{
	name = "scrWuXin",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirming},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		if use.card:isKindOf("TrickCard") then
			local source = use.from
			if source and source:objectName() ~= player:objectName() then
				if player:isNude() then
					return false
				end
				local room = player:getRoom()
				local prompt = string.format("@scrWuXin:%s:", source:objectName())
				local equip = room:askForCard(
					player, "EquipCard|.|.|hand,equipped", prompt, data, 
					sgs.Card_MethodNone, source, false, "scrWuXin", false
				)
				if equip then
					room:broadcastSkillInvoke("scrWuXin") --播放配音
					room:notifySkillInvoked(player, "scrWuXin") --显示技能发动
					room:obtainCard(source, equip, true)
					local choices = {}
					if not player:isNude() then
						table.insert(choices, "discard")
					end
					if player:getLostHp() > 0 then
						table.insert(choices, "recover")
					end
					if #choices == 0 then
						return 
					end
					choices = table.concat(choices, "+")
					local ai_data = sgs.QVariant()
					ai_data:setValue(player)
					local choice = room:askForChoice(source, "scrWuXin", choices, ai_data)
					if choice == "discard" then
						local id = room:askForCardChosen(source, player, "he", "scrWuXin")
						if id > 0 then
							room:throwCard(id, player, source)
						end
					elseif choice == "recover" then
						local recover = sgs.RecoverStruct()
						recover.who = source
						recover.recover = 1
						room:recover(player, recover)
					end
				end
			end
		end
	end,
}
--添加技能
XiangYu:addSkill(WuXin)
--翻译信息
sgs.LoadTranslationTable{
	["scrWuXin"] = "误信",
	[":scrWuXin"] = "你成为一名其他角色使用的锦囊牌的目标时，你可以交给其一张装备牌，然后该角色选择一项：弃置你的一张牌，或者令你回复1点体力。",
	["$scrWuXin"] = "技能 误信 的台词",
	["@scrWuXin"] = "您可以发动“误信”交给 %src 一张装备牌",
}
--[[****************************************************************
	编号：SCR - 003
	武将：曹操
	称号：不是人
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
CaoCao = sgs.General(extension, "scrCaoCao", "wei", 4)
--翻译信息
sgs.LoadTranslationTable{
	["scrCaoCao"] = "曹操",
	["&scrCaoCao"] = "曹操",
	["#scrCaoCao"] = "不是人",
	["designer:scrCaoCao"] = "DGAH",
	["cv:scrCaoCao"] = "无",
	["illustrator:scrCaoCao"] = "网络资源",
	["~scrCaoCao"] = "曹操 的阵亡台词",
}
--[[
	技能：逢故
	描述：你成为一名其他角色使用的【决斗】或红色【杀】的目标时，你可以令其获得你的一张牌，然后此【决斗】或【杀】对你无效。
]]--
FengGu = sgs.CreateTriggerSkill{
	name = "scrFengGu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirming, sgs.SlashEffected, sgs.CardEffected},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirming then
			local use = data:toCardUse()
			local card = use.card
			if card:isKindOf("Duel") then
			elseif card:isKindOf("Slash") and card:isRed() then
			else
				return false
			end
			local source = use.from
			if source and source:objectName() ~= player:objectName() and not player:isNude() then
				for _,target in sgs.qlist(use.to) do
					if target:objectName() == player:objectName() then
						if player:askForSkillInvoke("scrFengGu", data) then
							room:broadcastSkillInvoke("scrFengGu") --播放配音
							room:notifySkillInvoked(player, "scrFengGu") --显示技能发动
							local id = room:askForCardChosen(source, target, "he", "scrFengGu")
							room:obtainCard(source, id, false)
							local flag = string.format("scrFengGuAvoid_%s", target:objectName())
							room:setCardFlag(card, flag)
						end
						return false
					end
				end
			end
		elseif event == sgs.SlashEffected then
			local effect = data:toSlashEffect()
			local slash = effect.slash
			if slash:isRed() then
				local flag = string.format("scrFengGuAvoid_%s", player:objectName())
				if slash:hasFlag(flag) then
					local msg = sgs.LogMessage()
					msg.type = "#scrFengGuAvoid"
					msg.from = player
					msg.card_str = slash:toString()
					msg.arg = "scrFengGu"
					room:sendLog(msg) --发送提示信息
					return true
				end
			end
		elseif event == sgs.CardEffected then
			local effect = data:toCardEffect()
			local duel = effect.card
			if duel:isKindOf("Duel") then
				local flag = string.format("scrFengGuAvoid_%s", player:objectName())
				if duel:hasFlag(flag) then
					local msg = sgs.LogMessage()
					msg.type = "#scrFengGuAvoid"
					msg.from = player
					msg.card_str = duel:toString()
					msg.arg = "scrFengGu"
					room:sendLog(msg) --发送提示信息
					return true
				end
			end
		end
		return false
	end,
}
--添加技能
CaoCao:addSkill(FengGu)
--翻译信息
sgs.LoadTranslationTable{
	["scrFengGu"] = "逢故",
	[":scrFengGu"] = "你成为一名其他角色使用的【决斗】或红色【杀】的目标时，你可以令其获得你的一张牌，然后此【决斗】或【杀】对你无效。",
	["$scrFengGu"] = "技能 逢故 的台词",
	["#scrFengGuAvoid"] = "受技能“%arg”影响，此【%card】对 %from 无效",
}
--[[
	技能：追悔
	描述：你于回合外失去牌时，若你的武将牌正面朝上，你可以摸X张牌并翻面（X为你已损失的体力值且至少为1）；你翻面至武将牌正面朝上时，你可以令一名角色回复1点体力。
]]--
ZhuiHui = sgs.CreateTriggerSkill{
	name = "scrZhuiHui",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime, sgs.TurnedOver},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			if player:getPhase() == sgs.Player_NotActive and player:faceUp() then
				local move = data:toMoveOneTime()
				local source = move.from
				if source and source:objectName() == player:objectName() then
					local from = move.from_places
					if from:contains(sgs.Player_PlaceHand) or from:contains(sgs.Player_PlaceEquip) then
						if player:askForSkillInvoke("scrZhuiHui", data) then
							room:broadcastSkillInvoke("scrZhuiHui") --播放配音
							room:notifySkillInvoked(player, "scrZhuiHui") --显示技能发动
							local x = player:getLostHp()
							x = math.max(1, x)
							room:drawCards(player, x, "scrZhuiHui")
							player:turnOver()
						end
					end
				end
			end
		elseif event == sgs.TurnedOver then
			if player:faceUp() then
				local alives = room:getAlivePlayers()
				local targets = sgs.SPlayerList()
				for _,p in sgs.qlist(alives) do
					if p:getLostHp() > 0 then
						targets:append(p)
					end
				end
				if targets:isEmpty() then
					return false
				end
				local target = room:askForPlayerChosen(player, targets, "scrZhuiHui", "@scrZhuiHui", true)
				if target then
					local recover = sgs.RecoverStruct()
					recover.who = player
					recover.recover = 1
					room:recover(target, recover)
				end
			end
		end
		return false
	end,
}
--添加技能
CaoCao:addSkill(ZhuiHui)
--翻译信息
sgs.LoadTranslationTable{
	["scrZhuiHui"] = "追悔",
	[":scrZhuiHui"] = "你于回合外失去牌时，若你的武将牌正面朝上，你可以摸X张牌并翻面（X为你已损失的体力值且至少为1）；你翻面至武将牌正面朝上时，你可以令一名角色回复1点体力。",
	["@scrZhuiHui"] = "追悔：您可以令一名角色回复1点体力",
}
--[[****************************************************************
	编号：SCR - 004
	武将：鲁肃
	称号：忠厚人
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
LuSu = sgs.General(extension, "scrLuSu", "wu", 3)
--翻译信息
sgs.LoadTranslationTable{
	["scrLuSu"] = "鲁肃",
	["&scrLuSu"] = "鲁肃",
	["#scrLuSu"] = "忠厚人",
	["designer:scrLuSu"] = "DGAH",
	["cv:scrLuSu"] = "无",
	["illustrator:scrLuSu"] = "网络资源",
	["~scrLuSu"] = "鲁肃 的阵亡台词",
}
--[[
	技能：激语（阶段技）
	描述：你可以依次指定两名角色，令第一名角色获得第二名角色的一张手牌并展示之。然后若此牌不为草花，其受到第二名角色造成的1点伤害。
]]--
JiYuCard = sgs.CreateSkillCard{
	name = "scrJiYuCard",
	skill_name = "scrJiYu",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return true
		elseif #targets == 1 then
			return not to_select:isKongcheng()
		end
		return false
	end,
	feasible = function(self, targets)
		return #targets == 2
	end,
	about_to_use = function(self, room, use)
		room:setPlayerFlag(use.to:first(), "scrJiYuVictim")
		self:cardOnUse(room, use)
	end,
	on_use = function(self, room, source, targets)
		local victim, target = targets[1], targets[2]
		if victim:hasFlag("scrJiYuVictim") then
			room:setPlayerFlag(victim, "-scrJiYuVictim")
		else
			victim, target = target, victim
		end
		local id = room:askForCardChosen(victim, target, "h", "scrJiYu")
		room:obtainCard(victim, id, false)
		room:showCard(victim, id)
		room:getThread():delay()
		local card = sgs.Sanguosha:getCard(id)
		if card:getSuit() ~= sgs.Card_Club then
			local damage = sgs.DamageStruct()
			damage.from = target
			damage.to = victim
			damage.damage = 1
			damage.reason = "scrJiYu"
			room:setPlayerFlag(target, "scrJiYuTarget") --For AI
			room:damage(damage)
			room:setPlayerFlag(target, "-scrJiYuTarget") --For AI
		end
	end,
}
JiYu = sgs.CreateViewAsSkill{
	name = "scrJiYu",
	n = 0,
	view_as = function(self, cards)
		return JiYuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#scrJiYuCard")
	end,
}
--添加技能
LuSu:addSkill(JiYu)
--翻译信息
sgs.LoadTranslationTable{
	["scrJiYu"] = "激语",
	[":scrJiYu"] = "<font color=\"green\"><b>阶段技</b></font>，你可以依次指定两名角色，令第一名角色获得第二名角色的一张手牌并展示之。然后若此牌不为草花，其受到第二名角色造成的1点伤害。",
}
--[[
	技能：借荆
	描述：一名角色的准备阶段开始时，若其同意，你可以弃置两张牌，然后该角色选择一项：摸两张牌，或者回复1点体力。
]]--
JieJingCard = sgs.CreateSkillCard{
	name = "scrJieJingCard",
	skill_name = "scrJieJing",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
	end,
}
JieJingVS = sgs.CreateViewAsSkill{
	name = "scrJieJing",
	n = 2,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards == 2 then
			local card = JieJingCard:clone()
			card:addSubcard(cards[1])
			card:addSubcard(cards[2])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@scrJieJing"
	end,
}
JieJing = sgs.CreateTriggerSkill{
	name = "scrJieJing",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = JieJingVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local alives = room:getAlivePlayers()
		for _,source in sgs.qlist(alives) do
			if source:hasSkill("scrJieJing") and source:getCardCount(true) >= 2 then
				local prompt = string.format("invoke:%s:", source:objectName())
				if player:askForSkillInvoke("scrJieJing", sgs.QVariant(prompt)) then
					prompt = string.format("@scrJieJing:%s:", player:objectName())
					if room:askForUseCard(source, "@@scrJieJing", prompt) then
						local choices = {"draw"}
						if player:getLostHp() > 0 then
							table.insert(choices, "recover")
						end
						choices = table.concat(choices, "+")
						local choice = room:askForChoice(player, "scrJieJing", choices, data)
						if choice == "draw" then
							room:drawCards(player, 2, "scrJieJing")
						elseif choice == "recover" then
							local recover = sgs.RecoverStruct()
							recover.who = source
							recover.recover = 1
							room:recover(player, recover)
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:getPhase() == sgs.Player_Start
	end,
}
--添加技能
LuSu:addSkill(JieJing)
--翻译信息
sgs.LoadTranslationTable{
	["scrJieJing"] = "借荆",
	[":scrJieJing"] = "一名角色的准备阶段开始时，若其同意，你可以弃置两张牌，然后该角色选择一项：摸两张牌，或者回复1点体力。",
	["$scrJieJing"] = "技能 借荆 的台词",
	["scrJieJing:invoke"] = "您想发动 %src 的技能“借荆”吗？",
	["@scrJieJing"] = "%src 希望您发动“借荆”，您可以弃置两张牌令其摸两张牌或回复1点体力",
	["~scrJieJing"] = "选择两张牌（包括装备）->点击“确定”",
	["scrJieJing:draw"] = "摸两张牌",
	["scrJieJing:recover"] = "回复1点体力",
}
--[[****************************************************************
	编号：SCR - 005
	武将：姜尚
	称号：渔人
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
JiangShang = sgs.General(extension, "scrJiangShang", "qun", 3)
--翻译信息
sgs.LoadTranslationTable{
	["scrJiangShang"] = "姜尚",
	["&scrJiangShang"] = "姜尚",
	["#scrJiangShang"] = "渔人",
	["designer:scrJiangShang"] = "DGAH",
	["cv:scrJiangShang"] = "无",
	["illustrator:scrJiangShang"] = "网络资源",
	["~scrJiangShang"] = "姜尚 的阵亡台词",
}
--[[
	技能：垂钓
	描述：一名角色的出牌阶段开始时，其可以交给你一张牌，观看你的所有手牌。若如此做，你的手牌视为对其可见直至该阶段结束。
]]--
ChuiDiao = sgs.CreateTriggerSkill{
	name = "scrChuiDiao",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase == sgs.Player_Play then
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:hasSkill("scrChuiDiao") then
					local prompt = string.format("@scrChuiDiao:%s:", source:objectName())
					local card = room:askForCard(player, "..", prompt, data, sgs.Card_MethodNone, source, false, "scrChuiDiao")
					if card then
						room:broadcastSkillInvoke("scrChuiDiao") --播放配音
						room:notifySkillInvoked(source, "scrChuiDiao") --显示技能发动
						room:obtainCard(source, card, false)
						room:showAllCards(source, player)
						room:setPlayerMark(player, "scrChuiDiaoInvoked", 1)
						room:setPlayerFlag(source, "dongchaee")
						room:setTag("Dongchaee", sgs.QVariant(source:objectName()))
						room:setTag("Dongchaer", sgs.QVariant(player:objectName()))
						room:getThread():trigger(sgs.NonTrigger, room, source, sgs.QVariant("scrChuiDiao"))
						return false
					end
				end
			end
		elseif phase == sgs.Player_NotActive then
			if player:getMark("scrChuiDiaoInvoked") > 0 then
				local alives = room:getAlivePlayers()
				for _,source in sgs.qlist(alives) do
					if source:hasFlag("dongchaee") then
						room:setPlayerFlag(source, "-dongchaee")
						room:removeTag("Dongchaee")
						room:removeTag("Dongchaer")
						return false
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:getPhase() == sgs.Player_Play and not target:isNude()
	end,
}
--添加技能
JiangShang:addSkill(ChuiDiao)
--翻译信息
sgs.LoadTranslationTable{
	["scrChuiDiao"] = "垂钓",
	[":scrChuiDiao"] = "一名角色的出牌阶段开始时，其可以交给你一张牌，观看你的所有手牌。若如此做，你的手牌视为对其可见直至该阶段结束。",
	["$scrChuiDiao"] = "技能 垂钓 的台词",
	["@scrChuiDiao"] = "垂钓：您可以交给 %src 一张牌，观看其所有手牌",
}
--[[
	技能：扶保
	描述：你对一名角色发动“垂钓”后，你可以令其进行一次判定。其获得此判定牌且手牌上限+X直至当前回合结束（X为此判定牌的点数）。
]]--
FuBao = sgs.CreateTriggerSkill{
	name = "scrFuBao",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.NonTrigger},
	on_trigger = function(self, event, player, data)
		if data:toString() == "scrChuiDiao" then
			local room = player:getRoom()
			local current = room:getCurrent()
			if current then
				local prompt = string.format("invoke:%s:", current:objectName())
				if player:askForSkillInvoke("scrFuBao", sgs.QVariant(prompt)) then
					room:broadcastSkillInvoke("scrFuBao") --播放配音
					room:notifySkillInvoked(player, "scrFuBao") --显示技能发动
					local judge = sgs.JudgeStruct()
					judge.reason = "scrFuBao"
					judge.who = current
					judge.pattern = "."
					judge.good = true
					room:judge(judge)
					local card = judge.card
					local x = card:getNumber()
					room:obtainCard(current, card, true)
					current:gainMark("@scrFuBaoMark", x)
				end
			end
		end
		return false
	end,
}
FuBaoKeep = sgs.CreateMaxCardsSkill{
	name = "#scrFuBaoKeep",
	extra_func = function(self, player)
		return player:getMark("@scrFuBaoMark")
	end,
}
FuBaoClear = sgs.CreateTriggerSkill{
	name = "#scrFuBaoClear",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		player:loseAllMarks("@scrFuBaoMark")
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:getPhase() == sgs.Player_NotActive 
	end,
}
extension:insertRelatedSkills("scrFuBao", "#scrFuBaoKeep")
extension:insertRelatedSkills("scrFuBao", "#scrFuBaoClear")
--添加技能
JiangShang:addSkill(FuBao)
JiangShang:addSkill(FuBaoKeep)
JiangShang:addSkill(FuBaoClear)
--翻译信息
sgs.LoadTranslationTable{
	["scrFuBao"] = "扶保",
	[":scrFuBao"] = "你对一名角色发动“垂钓”后，你可以令其进行一次判定。其获得此判定牌且手牌上限+X直至当前回合结束（X为此判定牌的点数）。",
	["$scrFuBao"] = "技能 扶保 的台词",
	["scrFuBao:invoke"] = "您可以对 %src 发动技能“扶保”",
	["@scrFuBaoMark"] = "保",
}
--[[****************************************************************
	编号：SCR - 006
	武将：王佐
	称号：苦人
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
WangZuo = sgs.General(extension, "scrWangZuo", "shu", 3)
--翻译信息
sgs.LoadTranslationTable{
	["scrWangZuo"] = "王佐",
	["&scrWangZuo"] = "王佐",
	["#scrWangZuo"] = "苦人",
	["designer:scrWangZuo"] = "DGAH",
	["cv:scrWangZuo"] = "无",
	["illustrator:scrWangZuo"] = "网络资源",
	["~scrWangZuo"] = "王佐 的阵亡台词",
}
--[[
	技能：断臂（阶段技）
	描述：你可以对自己造成1点伤害，然后交给一名其他角色一张牌。
]]--
DuanBiActCard = sgs.CreateSkillCard{
	name = "scrDuanBiActCard",
	skill_name = "scrDuanBi",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:objectName() ~= sgs.Self:objectName()
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		room:setPlayerFlag(source, "-scrDuanBiAct")
		room:obtainCard(targets[1], self, false)
	end,
}
DuanBiCard = sgs.CreateSkillCard{
	name = "scrDuanBiCard",
	skill_name = "scrDuanBi",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local damage = sgs.DamageStruct()
		damage.from = source
		damage.to = source
		damage.damage = 1
		room:damage(damage)
		if source:isAlive() then
			room:setPlayerFlag(source, "scrDuanBiAct")
			if not room:askForUseCard(source, "@@scrDuanBi", "@scrDuanBi") then
				room:setPlayerFlag(source, "-scrDuanBiAct")
			end
		end
	end,
}
DuanBi = sgs.CreateViewAsSkill{
	name = "scrDuanBi",
	n = 1,
	view_filter = function(self, selected, to_select)
		return sgs.Self:hasFlag("scrDuanBiAct")
	end,
	view_as = function(self, cards)
		if sgs.Self:hasFlag("scrDuanBiAct") then
			if #cards == 1 then
				local card = DuanBiActCard:clone()
				card:addSubcard(cards[1])
				return card
			end
		else
			return DuanBiCard:clone()
		end
	end,
	enabled_at_play = function(self, player)
		if player:hasFlag("scrDuanBiAct") then
			return false
		elseif player:hasUsed("#scrDuanBiCard") then
			return false
		end
		return true
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@scrDuanBi"
	end,
}
--添加技能
WangZuo:addSkill(DuanBi)
--翻译信息
sgs.LoadTranslationTable{
	["scrDuanBi"] = "断臂",
	[":scrDuanBi"] = "<font color=\"green\"><b>阶段技</b></font>，你可以对自己造成1点伤害，然后交给一名其他角色一张牌。",
	["$scrDuanBi"] = "技能 断臂 的台词",
	["@scrDuanBi"] = "断臂：您可以交给一名其他角色一张牌",
	["~scrDuanBi"] = "选择一张牌（包括装备）->选择一名其他角色->点击“确定”",
}
--[[
	技能：说降
	描述：一名其他角色于你处获得牌时，你可以令其选择一项：1、视为对你指定的另一名角色使用一张【决斗】，且此【决斗】造成的伤害+1；2、弃置2X张牌；3、失去1点体力。然后若此时为你的回合内，你摸1+X张牌。（X为你已损失的体力值且至少为1）
]]--
ShuiXiang = sgs.CreateTriggerSkill{
	name = "scrShuiXiang",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		local source = move.from
		if source and source:objectName() == player:objectName() then
			local target = move.to
			if target and target:objectName() ~= player:objectName() then
				local to = move.to_place
				if to == sgs.Player_PlaceHand or to == sgs.Player_PlaceEquip then
					local from = move.from_places
					if from:contains(sgs.Player_PlaceHand) or from:contains(sgs.Player_PlaceEquip) then
						local prompt = string.format("invoke:%s:", target:objectName())
						if player:askForSkillInvoke("scrShuiXiang", sgs.QVariant(prompt)) then
							local room = player:getRoom()
							room:broadcastSkillInvoke("scrShuiXiang") --播放配音
							room:notifySkillInvoked(player, "scrShuiXiang") --显示技能发动
							local choices = {}
							local others = room:getOtherPlayers(player)
							local victims = sgs.SPlayerList()
							local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
							duel:setSkillName("scrShuiXiang")
							local sp_target = nil
							for _,p in sgs.qlist(others) do
								if p:objectName() == target:objectName() then
									sp_target = p
								elseif target:isProhibited(p, duel) then
								else
									victims:append(p)
								end
							end
							assert(sp_target)
							if not victims:isEmpty() then
								table.insert(choices, "duel")
							end
							if not target:isNude() then
								table.insert(choices, "discard")
							end
							table.insert(choices, "losehp")
							choices = table.concat(choices, "+")
							local ai_data = sgs.QVariant()
							ai_data:setValue(player)
							local choice = room:askForChoice(sp_target, "scrShuiXiang", choices, ai_data)
							if choice == "duel" then
								prompt = string.format("@scrShuiXiang:%s:", sp_target:objectName())
								sp_target:setFlags("scrShuiXiangTarget")
								local victim = room:askForPlayerChosen(player, victims, "scrShuiXiang", prompt, true)
								sp_target:setFlags("-scrShuiXiangTarget")
								if victim then
									local use = sgs.CardUseStruct()
									use.from = sp_target
									use.to:append(victim)
									use.card = duel
									room:useCard(use, false)
								end
							else
								duel:deleteLater()
								if choice == "discard" then
									local x = player:getLostHp()
									local num = math.max(1, x) * 2
									if sp_target:getCardCount(true) <= num then
										sp_target:throwAllHandCardsAndEquips()
									else
										room:askForDiscard(sp_target, "scrShuiXiang", num, num, false, true)
									end
								elseif choice == "losehp" then
									room:loseHp(sp_target, 1)
								end
							end
							if player:isAlive() and player:getPhase() ~= sgs.Player_NotActive then
								local x = player:getLostHp()
								local num = 1 + math.max(1, x)
								room:drawCards(player, num, "scrShuiXiang")
							end
						end
					end
				end
			end
		end
		return false
	end,
}
ShuiXiangEffect = sgs.CreateTriggerSkill{
	name = "#scrShuiXiangEffect",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageForseen},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local duel = damage.card
		if duel and duel:getSkillName() == "scrShuiXiang" then
			local room = player:getRoom()
			local msg = sgs.LogMessage()
			msg.type = "#scrShuiXiang"
			local count = damage.damage
			msg.arg = count
			count = count + 1
			msg.arg2 = count
			room:sendLog(msg) --发送提示信息
			damage.damage = count
			data:setValue(damage)
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
extension:insertRelatedSkills("scrShuiXiang", "#scrShuiXiangEffect")
--添加技能
WangZuo:addSkill(ShuiXiang)
WangZuo:addSkill(ShuiXiangEffect)
--翻译信息
sgs.LoadTranslationTable{
	["scrShuiXiang"] = "说降",
	[":scrShuiXiang"] = "一名其他角色于你处获得牌时，你可以令其选择一项：1、视为对你指定的另一名角色使用一张【决斗】，且此【决斗】造成的伤害+1；2、弃置2X张牌；3、失去1点体力。然后若此时为你的回合内，你摸1+X张牌。（X为你已损失的体力值且至少为1）",
	["$scrShuiXiang"] = "技能 说降 的台词",
	["scrShuiXiang:invoke"] = "您想对 %src 发动技能“说降”吗？",
	["scrShuiXiang:duel"] = "视为使用决斗",
	["scrShuiXiang:discard"] = "弃牌",
	["scrShuiXiang:losehp"] = "失去体力",
	["@scrShuiXiang"] = "说降：请为 %src 指定决斗的目标",
	["#scrShuiXiang"] = "受技能“说降”的影响，仇人相见分外眼红，此【决斗】造成的伤害+1，从 %arg 点上升至 %arg2 点",
}
--[[****************************************************************
	编号：SCR - 007
	武将：张飞
	称号：莽撞人
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
ZhangFei = sgs.General(extension, "scrZhangFei", "shu", 4)
--翻译信息
sgs.LoadTranslationTable{
	["scrZhangFei"] = "张飞",
	["&scrZhangFei"] = "张飞",
	["#scrZhangFei"] = "莽撞人",
	["designer:scrZhangFei"] = "DGAH",
	["cv:scrZhangFei"] = "无",
	["illustrator:scrZhangFei"] = "影视资源（来自网络）",
	["~scrZhangFei"] = "张飞 的阵亡台词",
}
--[[
	技能：虚实
	描述：你成为一名其他角色使用的【杀】的目标时，你可以视为使用一张【无中生有】。若如此做，此【杀】造成的伤害+1。
]]--
XuShi = sgs.CreateTriggerSkill{
	name = "scrXuShi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirming},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local slash = use.card
		if slash:isKindOf("Slash") then
			local source = use.from
			if source and source:objectName() ~= player:objectName() then
				if player:askForSkillInvoke("scrXuShi", data) then
					local room = player:getRoom()
					local ex_nihilo = sgs.Sanguosha:cloneCard("ex_nihilo", sgs.Card_NoSuit, 0)
					ex_nihilo:setSkillName("scrXuShi")
					local use = sgs.CardUseStruct()
					use.from = player
					use.card = ex_nihilo
					room:useCard(use, false)
					room:setCardFlag(slash, "scrXuShiInvoked")
				end
			end
		end
		return false
	end,
}
XuShiEffect = sgs.CreateTriggerSkill{
	name = "#scrXuShiEffect",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageForseen},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local slash = damage.card
		if slash and slash:hasFlag("scrXuShiInvoked") then
			local room = player:getRoom()
			local count = damage.damage
			local msg = sgs.LogMessage()
			msg.type = "#scrXuShi"
			msg.from = player
			msg.arg = count
			count = count + 1
			msg.arg2 = count
			room:sendLog(msg) --发送提示信息
			damage.damage = count
			data:setValue(damage)
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
extension:insertRelatedSkills("scrXuShi", "#scrXuShiEffect")
--添加技能
ZhangFei:addSkill(XuShi)
ZhangFei:addSkill(XuShiEffect)
--翻译信息
sgs.LoadTranslationTable{
	["scrXuShi"] = "虚实",
	[":scrXuShi"] = "你成为一名其他角色使用的【杀】的目标时，你可以视为使用一张【无中生有】。若如此做，此【杀】造成的伤害+1。",
	["$scrXuShi"] = "技能 虚实 的台词",
	["#scrXuShi"] = "受技能“虚实”影响，%from 受到的伤害+1，由 %arg 点上升至 %arg2 点",
}
--[[
	技能：暴喝
	描述：出牌阶段限X次，你可以弃一张黑色手牌，对你攻击范围内的一名角色造成1点伤害。（X为你已损失的体力值）
]]--
BaoHeCard = sgs.CreateSkillCard{
	name = "scrBaoHeCard",
	skill_name = "scrBaoHe",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return sgs.Self:inMyAttackRange(to_select)
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local damage = sgs.DamageStruct()
		damage.from = source
		damage.to = target
		damage.damage = 1
		room:damage(damage)
	end,
}
BaoHe = sgs.CreateViewAsSkill{
	name = "scrBaoHe",
	n = 1,
	view_filter = function(self, selected, to_select)
		if to_select:isBlack() then
			return not to_select:isEquipped()
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = BaoHeCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return player:usedTimes("#scrBaoHeCard") < player:getLostHp()
	end,
}
--添加技能
ZhangFei:addSkill(BaoHe)
--翻译信息
sgs.LoadTranslationTable{
	["scrBaoHe"] = "暴喝",
	[":scrBaoHe"] = "出牌阶段限X次，你可以弃一张黑色手牌，对你攻击范围内的一名角色造成1点伤害。（X为你已损失的体力值）",
	["$scrBaoHe"] = "技能 暴喝 的台词",
}
--[[****************************************************************
	编号：SCR - 008
	武将：曹真
	称号：气死人
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
CaoZhen = sgs.General(extension, "scrCaoZhen", "wei", 4)
--翻译信息
sgs.LoadTranslationTable{
	["scrCaoZhen"] = "曹真",
	["&scrCaoZhen"] = "曹真",
	["#scrCaoZhen"] = "气死人",
	["designer:scrCaoZhen"] = "DGAH",
	["cv:scrCaoZhen"] = "无",
	["illustrator:scrCaoZhen"] = "影视资源（来自网络）",
	["~scrCaoZhen"] = "曹真 的阵亡台词",
}
--[[
	技能：阅函
	描述：一名角色的弃牌阶段开始时，其可以将一张牌置于你的武将牌上，称为“函”。你需要使用或打出一张牌时，若“函”中存在此牌，你可以使用或打出之，然后你摸一张牌。
]]--
function doYueHan(skillcard, source)
	local room = source:getRoom()
	local pattern = skillcard:getUserString()
	local pile = source:getPile("scrYueHanPile")
	local card_ids = sgs.IntList()
	local disabled_ids = sgs.IntList()
	if pattern == "" then
		local alives = room:getAlivePlayers()
		local dummy_selected = sgs.PlayerList()
		for _,id in sgs.qlist(pile) do
			local card = sgs.Sanguosha:getCard(id)
			local disabled = true
			if card:isAvailable(source) then
				if card:targetFixed() then
					if card:isKindOf("EquipCard") then
						disabled = false
					elseif card:isKindOf("GlobalEffect") then
						for _,p in sgs.qlist(alives) do
							if not source:isProhibited(p, card) then
								disabled = false
								break
							end
						end
					elseif card:isKindOf("AOE") then
						for _,p in sgs.qlist(alives) do
							if p:objectName() == source:objectName() then
							elseif not source:isProhibited(p, card) then
								disabled = false
								break
							end
						end
					elseif card:isKindOf("ExNihilo") or card:isKindOf("DelayedTrick") or card:isKindOf("Analeptic") then
						if not source:isProhibited(source, card) then
							disabled = false
						end
					elseif card:isKindOf("Peach") then
						if not source:isProhibited(source, card) then
							if source:getLostHp() > 0 then
								disabled = false
							end
						end
					end
				else
					for _,p in sgs.qlist(alives) do
						if card:targetFilter(dummy_selected, p, source) then
							if card:isKindOf("Collateral") then
								local selected = sgs.PlayerList()
								selected:append(p)
								for _,p2 in sgs.qlist(alives) do
									if card:targetFilter(selected, p, source) then
										disabled = false
										break
									end
								end
								if not disabled then
									break
								end
							else
								disabled = false
								break
							end
						end
					end
				end
			end
			if disabled then
				disabled_ids:append(id)
			else
				card_ids:append(id)
			end
		end
	else
		for _,id in sgs.qlist(pile) do
			local card = sgs.Sanguosha:getCard(id)
			if card:match(pattern) then
				card_ids:append(id)
			else
				disabled_ids:append(id)
			end
		end
	end
	if card_ids:isEmpty() then
		room:setPlayerFlag(source, "scrYueHanFailed")
		return nil
	end
	room:fillAG(pile, source, disabled_ids)
	local card_id = room:askForAG(source, card_ids, true, "scrYueHan")
	room:clearAG(source)
	if card_id == -1 then
		room:setPlayerFlag(source, "scrYueHanFailed")
		return nil
	end
	local card = sgs.Sanguosha:getCard(card_id)
	room:setCardFlag(card, "scrYueHanCard")
	if card:targetFixed() then
		return card
	elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
		return card
	end
	room:setPlayerFlag(source, "scrYueHanSelect")
	room:setPlayerMark(source, "scrYueHanID", card_id)
	local prompt = string.format("@scrYueHan:::%s:", card:objectName())
	source:setProperty("scrYueHanPattern", sgs.QVariant(pattern)) --For AI
	local success = room:askForUseCard(source, "@@scrYueHan", prompt)
	if success then
		return skillcard
	end
	source:setProperty("scrYueHanPattern", sgs.QVariant("")) --For AI
	room:setPlayerFlag(source, "-scrYueHanSelect")
	room:setPlayerMark(source, "scrYueHanID", 0)
	room:setPlayerFlag(source, "scrYueHanFailed")
	return nil
end
YueHanCard = sgs.CreateSkillCard{
	name = "scrYueHanCard",
	skill_name = "scrYueHan",
	target_fixed = true,
	will_throw = true,
	on_validate = function(self, use)
		local user = use.from
		return doYueHan(self, user)
	end,
	on_validate_in_response = function(self, user)
		return doYueHan(self, user)
	end,
}
YueHanSelectCard = sgs.CreateSkillCard{
	name = "scrYueHanSelectCard",
	skill_name = "scrYueHan",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		local id = sgs.Self:getMark("scrYueHanID")
		local card = sgs.Sanguosha:getCard(id)
		local selected = sgs.PlayerList()
		for _,p in ipairs(targets) do
			selected:append(p)
		end
		return card:targetFilter(selected, to_select, sgs.Self)
	end,
	feasible = function(self, targets)
		local id = sgs.Self:getMark("scrYueHanID")
		local card = sgs.Sanguosha:getCard(id)
		local selected = sgs.PlayerList()
		for _,p in ipairs(targets) do
			selected:append(p)
		end
		return card:targetsFeasible(selected, sgs.Self)
	end,
	on_validate = function(self, use)
		local user = use.from
		local room = user:getRoom()
		local id = user:getMark("scrYueHanID")
		room:setPlayerFlag(user, "-scrYueHanSelect")
		room:setPlayerMark(user, "scrYueHanID", 0)
		local card = sgs.Sanguosha:getCard(id)
		room:setCardFlag(card, "scrYueHanCard")
		return card
	end,
}
YueHanVS = sgs.CreateViewAsSkill{
	name = "scrYueHan",
	n = 0,
	view_as = function(self, cards)
		if sgs.Self:hasFlag("scrYueHanSelect") then
			return YueHanSelectCard:clone()
		else
			local card = YueHanCard:clone()
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			card:setUserString(pattern)
			return card
		end
	end,
	enabled_at_play = function(self, player)
		if player:hasFlag("scrYueHanFailed") then
			return false
		end
		local pile = player:getPile("scrYueHanPile")
		if pile:isEmpty() then
			return false
		end
		local others = player:getSiblings()
		local dummy_selected = sgs.PlayerList()
		for _,id in sgs.qlist(pile) do
			local card = sgs.Sanguosha:getCard(id)
			if card:isKindOf("EquipCard") then
				return true
			elseif card:isKindOf("Peach") and player:getLostHp() > 0 then
				return true
			elseif card:isAvailable(player) then
				if card:targetFixed() then
					if card:isKindOf("GlobalEffect") then
						if not player:isProhibited(player, card) then
							return true
						end
						for _,p in sgs.qlist(others) do
							if not player:isProhibited(p, card) then
								return true
							end
						end
					elseif card:isKindOf("AOE") then
						for _,p in sgs.qlist(others) do
							if not player:isProhibited(p, card) then
								return true
							end
						end
					elseif card:isKindOf("ExNihilo") or card:isKindOf("DelayedTrick") or card:isKindOf("Analeptic") then
						if not player:isProhibited(player, card) then
							return true
						end
					end
				elseif card:targetFilter(dummy_selected, player, player) then
					return true
				else
					for _,p in sgs.qlist(others) do
						if card:targetFilter(dummy_selected, p, player) then
							if card:isKindOf("Collateral") then
								local selected = sgs.PlayerList()
								selected:append(p)
								for _,p2 in sgs.qlist(others) do
									if card:targetFilter(selected, p2, player) then
										return true
									end
								end
								if card:targetFilter(selected, player, player) then
									return true
								end
							else
								return true
							end
						end
					end
				end
			end
		end
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		if player:hasFlag("scrYueHanSelect") then
			return pattern == "@@scrYueHan"
		else
			if player:hasFlag("scrYueHanFailed") then
				return false
			end
			local pile = player:getPile("scrYueHanPile")
			if pile:isEmpty() then
				return false
			end
			for _,id in sgs.qlist(pile) do
				local card = sgs.Sanguosha:getCard(id)
				if card:match(pattern) then
					return true
				end
			end
		end
		return false
	end,
	enabled_at_nullification = function(self, player)
		if player:hasFlag("scrYueHanFailed") then
			return false
		end
		local pile = player:getPile("scrYueHanPile")
		if pile:isEmpty() then
			return false
		end
		for _,id in sgs.qlist(pile) do
			local null = sgs.Sanguosha:getCard(id)
			if null:isKindOf("Nullification") then
				return true
			end
		end
		return false
	end,
}
YueHan = sgs.CreateTriggerSkill{
	name = "scrYueHan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = YueHanVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local alives = room:getAlivePlayers()
		for _,source in sgs.qlist(alives) do
			if player:isNude() then
				return false
			elseif source:hasSkill("scrYueHan") then
				local prompt = string.format("@scrYueHan-send:%s:", source:objectName())
				local card = room:askForCard(player, "..", prompt, data, sgs.Card_MethodNone, source, false, "scrYueHan")
				if card then
					room:broadcastSkillInvoke("scrYueHan") --播放配音
					room:notifySkillInvoked(source, "scrYueHan") --显示技能发动
					source:addToPile("scrYueHanPile", card, true)
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:getPhase() == sgs.Player_Discard
	end,
}
YueHanEffect = sgs.CreateTriggerSkill{
	name = "#scrYueHanEffect",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local card = nil
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			card = use.card
		elseif event == sgs.CardResponded then
			local response = data:toCardResponse()
			card = response.m_card
		end
		if card and card:hasFlag("scrYueHanCard") then
			local room = player:getRoom()
			room:setCardFlag(card, "-scrYueHanCard")
			room:drawCards(player, 1, "scrYueHan")
		end
		return false
	end,
}
extension:insertRelatedSkills("scrYueHan", "#scrYueHanEffect")
--添加技能
CaoZhen:addSkill(YueHan)
CaoZhen:addSkill(YueHanEffect)
--翻译信息
sgs.LoadTranslationTable{
	["scrYueHan"] = "阅函",
	[":scrYueHan"] = "一名角色的弃牌阶段开始时，其可以将一张牌置于你的武将牌上，称为“函”。你需要使用或打出一张牌时，若“函”中存在此牌，你可以使用或打出之，然后你摸一张牌。",
	["$scrYueHan"] = "技能 阅函 的台词",
	["@scrYueHan-send"] = "您可以发动 %src 的技能“阅函”，将一张牌作为“函”置于其武将牌上",
	["@scrYueHan"] = "阅函：请为此【%arg】指定必要的目标",
	["~scrYueHan"] = "选择一些目标角色->点击“确定”",
	["scrYueHanPile"] = "函",
}
--[[
	技能：气绝（锁定技）
	描述：出牌阶段结束时，你弃置所有的“函”并失去X点体力（X为你弃置“函”的数量）。
]]--
QiJue = sgs.CreateTriggerSkill{
	name = "scrQiJue",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Play then
			local pile = player:getPile("scrYueHanPile")
			if pile:isEmpty() then
				return false
			end
			local room = player:getRoom()
			room:broadcastSkillInvoke("scrQiJue") --播放配音
			room:notifySkillInvoked(player, "scrQiJue") --显示技能发动
			room:sendCompulsoryTriggerLog(player, "scrQiJue", false) --提示锁定技触发
			local x = pile:length()
			player:clearOnePrivatePile("scrYueHanPile")
			room:loseHp(player, x)
		end
		return false
	end,
}
--添加技能
CaoZhen:addSkill(QiJue)
--翻译信息
sgs.LoadTranslationTable{
	["scrQiJue"] = "气绝",
	[":scrQiJue"] = "<font color=\"blue\"><b>锁定技</b></font>，出牌阶段结束时，你弃置所有的“函”并失去X点体力（X为你弃置“函”的数量）。",
	["$scrQiJue"] = "技能 气绝 的台词",
}