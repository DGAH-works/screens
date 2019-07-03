--[[
	太阳神三国杀武将扩展包·八扇屏（AI部分）
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
--[[****************************************************************
	编号：SCR - 001
	武将：苗训
	称号：江湖人
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：卖卦
	描述：一名其他角色的出牌阶段开始时，其可以展示并交给你一张牌。然后你须选择一个花色并进行一次判定。若判定结果与你所选花色相同，该角色获得技能“帝途”直到当前回合结束。
]]--
--room:askForCard(player, "..", prompt, data, sgs.Card_MethodNone, source, false, "scrMaiGua")
sgs.ai_skill_cardask["@scrMaiGua"] = function(self, data, pattern, target, target2, arg, arg2)
	if self:isFriend(target) then
		local armor = self.player:getArmor()
		if armor and self:needToThrowArmor() then
			return "$"..armor:getEffectiveId()
		end
		local overflow = self:getOverflow()
		if hasManjuanEffect(target) and overflow <= 0 then
			return "."
		end
		local wont_use = {}
		local handcards = self.player:getHandcards()
		for _,c in sgs.qlist(handcards) do
			local dummy_use = {
				isDummy = true,
			}
			if c:isKindOf("BasicCard") then
				self:useBasicCard(c, dummy_use)
			elseif c:isKindOf("EquipCard") then
				self:useEquipCard(c, dummy_use)
			elseif c:isKindOf("TrickCard") then
				self:useTrickCard(c, dummy_use)
			end
			if dummy_use.card then
				if c:isKindOf("EquipCard") then
					local equip = self:getSameEquip(c, self.player)
					if equip then
						table.insert(wont_use, equip)
					end
				end
			else
				table.insert(wont_use, c)
			end
		end
		if #wont_use == 0 then
			if overflow <= 0 then
				return "."
			end
		else
			self:sortByKeepValue(wont_use)
			return "$"..wont_use[1]:getEffectiveId()
		end
		if self.player:hasEquip() and self:hasSkills(sgs.lose_equip_skill) then
			local equips = self.player:getEquips()
			equips = sgs.QList2Table(equips)
			self:sortByKeepValue(equips)
			return "$"..equips[1]:getEffectiveId()
		end
		if overflow > 0 then
			handcards = sgs.QList2Table(handcards)
			self:sortByUseValue(handcards, true)
			return "$"..handcards[1]:getEffectiveId()
		end
	end
	return "."
end
--room:askForSuit(source, "scrMaiGua")
sgs.ai_skill_suit["scrMaiGua"] = function(self)
	if self.player:hasSkill("scrJunShi") and not self.player:isNude() then
		local cards = self.player:getCards("he")
		cards = sgs.QList2Table(cards)
		self:sortByKeepValue(cards)
		return cards[1]:getSuit()
	end
	return math.random(0, 3)
end
--[[
	技能：军师
	描述：一名角色的判定牌生效前，你可以打出一张牌代替之。然后若该角色同意，你摸一张牌。
]]--
--room:askForCard(player, "..", prompt, data, sgs.Card_MethodResponse, source, true, "scrMaiGua")
sgs.ai_skill_cardask["@scrJunShi"] = function(self, data, pattern, target, target2, arg, arg2)
	local judge = data:toJudge()
	if self:needRetrial(judge) then
		local cards = self.player:getCards("he")
		cards = sgs.QList2Table(cards)
		local card_id = self:getRetrialCardId(cards, judge, true)
		if card_id ~= -1 then
			return "$"..card_id
		end
	end
	return "."
end
--source:askForSkillInvoke("scrJunShiDraw", ai_data)
sgs.ai_skill_invoke["scrJunShiDraw"] = function(self, data)
	local target = data:toPlayer()
	if target and self:isFriend(target) then
		if target:isKongcheng() and self:needKongcheng(target) then
			return false
		end
		return true
	end
	return false
end
--[[
	技能：帝途（锁定技）
	描述：你计算的与其他角色的距离为1；你使用一张与“卖卦”判定牌相同花色的牌时，你摸一张牌。
]]--
--[[****************************************************************
	编号：SCR - 002
	武将：项羽
	称号：浑人
	势力：吴
	性别：男
	体力上限：6勾玉
]]--****************************************************************
--[[
	技能：末路（锁定技）
	描述：若你未受伤，你计算的与其他角色的距离-2；若你已受伤，其他角色计算的与你的距离-1。
]]--
--[[
	技能：误信
	描述：你成为一名其他角色使用的锦囊牌的目标时，你可以交给其一张装备牌，然后该角色选择一项：弃置你的一张牌，或者令你回复1点体力。
]]--
--room:askForCard(player, "EquipCard|.|.|hand,equipped", prompt, data, sgs.Card_MethodNone, source, false, "scrWuXin", false)
sgs.ai_skill_cardask["@scrWuXin"] = function(self, data, pattern, target, target2, arg, arg2)
	local equips = self.player:getEquips()
	local handcards = self.player:getHandcards()
	local hand_equips = {}
	for _,equip in sgs.qlist(handcards) do
		if equip:isKindOf("EquipCard") then
			table.insert(hand_equips, equip)
		end
	end
	if equips:isEmpty() and #hand_equips == 0 then
		return "."
	end
	local needRecover = false
	local hp = self.player:getHp()
	local lost = self.player:getLostHp()
	local n_enemy = self:getEnemyNumBySeat(target, self.player)
	if lost == 0 then
	elseif self:needToLoseHp() then
	elseif hp >= 2 and self:hasSkills("kuanggu|zaiqi|rende|nosrende") and n_enemy <= hp then
	elseif self.player:hasSkill("hunzi") and self.player:getMark("hunzi") == 0 and n_enemy <= (hp >= 2 and 1 or 0) then
	elseif self.player:isLord() and sgs.isLordHealthy() then
	else
		needRecover = true
	end
	equips = sgs.QList2Table(equips)
	local only_equip = nil
	if self.player:getCardCount(true) == 1 then
		if #equips > 0 then
			only_equip = equips[1]
		elseif #hand_equips > 0 then
			only_equip = hand_equips[1]
		end
	end
	if needRecover then
		local isFriend = self:isFriend(target)
		if only_equip then
			if lost > 1 then
				return "$"..only_equip:getEffectiveId()
			elseif only_equip:isKindOf("SilverLion") and #equips > 0 then
				if isFriend then
					return "$"..only_equip:getEffectiveId()
				end
			end
		end
		self:sortByKeepValue(equips)
		self:sortByUseValue(hand_equips)
		if isFriend then
			if lost == 1 then
				if #equips == 1 and #hand_equips == 0 and equips[1]:isKindOf("SilverLion") then
					if not self:hasSkills(sgs.lose_equip_skill) then
						return "."
					end
				end
			end
			if #equips > 0 and self:hasSkills(sgs.lose_equip_skill) then
				return "$"..equips[1]:getEffectiveId()
			end
			if #hand_equips > 0 then
				return "$"..hand_equips[1]:getEffectiveId()
			end
			if #equips > 0 then
				return "$"..equips[1]:getEffectiveId()
			end
		end
	end
	return "."
end
--room:askForChoice(source, "scrWuXin", choices, ai_data)
sgs.ai_skill_choice["scrWuXin"] = function(self, choices, data)
	local target = data:toPlayer()
	local withDiscard = string.find(choices, "discard")
	local withRecover = string.find(choices, "recover")
	if self:isFriend(target) then
		if withRecover then
			return "recover"
		elseif withDiscard then
			return "discard"
		end
	end
	if withDiscard then
		return "discard"
	elseif withRecover then
		return "recover"
	end
end
--[[****************************************************************
	编号：SCR - 003
	武将：曹操
	称号：不是人
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：逢故
	描述：你成为一名其他角色使用的【决斗】或红色【杀】的目标时，你可以令其获得你的一张牌，然后此【决斗】或【杀】对你无效。
]]--
--player:askForSkillInvoke("scrFengGu", data)
sgs.ai_skill_invoke["scrFengGu"] = function(self, data)
	local use = data:toCardUse()
	local source = use.from
	local card = use.card
	local damage = 0
	if card:isKindOf("Duel") and self:hasTrickEffective(card, self.player, source) then
		if getCardsNum("Slash", source, self.player) >= self:getCardsNum("Slash") then
			damage = 1
			if not source:hasSkill("jueqing") then
				if self.player:isKongcheng() and self.player:hasSkill("chouhai") then
					damage = damage + 1
				end
			end
		end
	elseif card:isKindOf("Slash") and self:slashIsEffective(card, self.player, source) then
		if self:canHit(self.player, source) then
			damage = self:hasHeavySlashDamage(source, card, self.player, true)
		end
	end
	if damage > 1 and self.player:hasArmorEffect("silver_lion") and not source:hasSkill("jueqing") then
		damage = 1
	end
	if damage > 0 then
		local hp = self.player:getHp()
		if hp <= damage then
			if hp + self:getAllPeachNum() <= damage then
				return true
			end
		end
		if damage > 1 and self:isWeak() then
			return true
		end
		if self:isFriend(source) then
			return true
		end
	end
	return false
end
--room:askForCardChosen(source, target, "he", "scrFengGu")
--[[
	技能：追悔
	描述：你于回合外失去牌时，若你的武将牌正面朝上，你可以摸X张牌并翻面（X为你已损失的体力值且至少为1）；你翻面至武将牌正面朝上时，你可以令一名角色回复1点体力。
]]--
--player:askForSkillInvoke("scrZhuiHui", data)
sgs.ai_skill_invoke["scrZhuiHui"] = function(self, data)
	local x = self.player:getLostHp() 
	x = math.max(1, x)
	if self:toTurnOver(self.player, x, "scrZhuiHui") then
		if x > 1 and self.player:hasSkill("jiewei") then
			return true
		end
		local need_recover, weak_friends = false, false
		local needHelp, notNeedHelp = self:getWoundedFriend(false, true)
		if #needHelp > 0 then
			need_recover = true
			for _,friend in ipairs(needHelp) do
				if self:isWeak(friend) then
					weak_friends = true
					break
				end
			end
		end
		if weak_friends then
			return true
		elseif need_recover then
			if self.player:hasSkill("jiushi") and self.player:getHp() > 1 then
				return true
			end
			for _,friend in ipairs(self.friends_noself) do
				if friend:hasSkill("junxing") and not friend:isKongcheng() then
					return true
				elseif friend:hasSkill("fangzhu") and friend:getHp() > 1 then
					return true
				elseif friend:hasSkill("jilve") and friend:getHp() > 1 then
					return true
				end
			end
			return x > 1
		end
		if #needHelp > 0 or #notNeedHelp > 0 then
			if self.player:hasSkill("cangni") and not self.player:isNude() then
				return true
			elseif x > 2 then
				return true
			end
		end
		return false
	end
	return true
end
--room:askForPlayerChosen(player, targets, "scrZhuiHui", "@scrZhuiHui", true)
sgs.ai_skill_playerchosen["scrZhuiHui"] = function(self, targets)
	local needHelp, notNeedHelp = self:getWoundedFriend(false, true)
	if #needHelp > 0 then
		for _,friend in ipairs(needHelp) do
			for _,p in sgs.qlist(targets) do
				if p:objectName() == friend:objectName() then
					return friend
				end
			end
		end
	end
	if #notNeedHelp > 0 then
		for _,friend in ipairs(notNeedHelp) do
			for _,p in sgs.qlist(targets) do
				if p:objectName() == friend:objectName() then
					return friend
				end
			end
		end
	end
end
--[[****************************************************************
	编号：SCR - 004
	武将：鲁肃
	称号：忠厚人
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：激语（阶段技）
	描述：你可以依次指定两名角色，令第一名角色获得第二名角色的一张手牌并展示之。然后若此牌不为草花，其受到第二名角色造成的1点伤害。
]]--
--room:askForCardChosen(victim, target, "h", "scrJiYu")
--JiYuCard:Play
local jiyu_skill = {
	name = "scrJiYu",
	getTurnUseCard = function(self, inclusive)
		if self.player:hasUsed("#scrJiYuCard") then
			return nil
		end
		return sgs.Card_Parse("#scrJiYuCard:.:")
	end,
}
table.insert(sgs.ai_skills, jiyu_skill)
sgs.ai_skill_use_func["#scrJiYuCard"] = function(card, use, self)
	local victim, target = nil, nil
	if #self.enemies > 0 then
		self:sort(self.enemies, "defense")
	end
	if #self.enemies >= 2 then
		for _,enemy2 in ipairs(self.enemies) do
			if not enemy2:isKongcheng() then
				for _,enemy in ipairs(self.enemies) do
					if enemy:objectName() == enemy2:objectName() then
					elseif self:damageIsEffective(enemy, sgs.DamageStruct_Normal, enemy2) then
						victim, target = enemy, enemy2
						break
					end
				end
				if victim and target then
					break
				end
			end
		end
	end
	if not victim and #self.enemies > 0 then
		local unknowns = {}
		local others = self.room:getOtherPlayers(self.player)
		for _,p in sgs.qlist(others) do
			if self:isFriend(p) then
			elseif self:isEnemy(p) then
			else
				table.insert(unknowns, p)
			end
		end
		if #unknowns > 0 then
			self:sort(unknowns, "defense")
			for _,unknown in ipairs(unknowns) do
				if not unknown:isKongcheng() then
					for _,enemy in ipairs(self.enemies) do
						if enemy:objectName() == unknown:objectName() then
						elseif self:damageIsEffective(enemy, sgs.DamageStruct_Normal, unknown) then
							victim, target = enemy, unknown
							break
						end
					end
					if victim and target then
						break
					end
				end
			end
			if not victim then
				for _,enemy in ipairs(self.enemies) do
					if not enemy:isKongcheng() then
						for _,unknown in ipairs(unknowns) do
							if enemy:objectName() == unknown:objectName() then
							elseif self:damageIsEffective(unknown, sgs.DamageStruct_Normal, enemy) then
								if self:getDamagedEffects(unknown, enemy, false) then
									victim, target = unknown, enemy
									break
								end
							end
						end
						if victim and target then
							break
						end
					end
				end
			end
		end
	end
	if not victim and #self.enemies > 0 then
		self:sort(self.friends, "threat")
		for _,friend in ipairs(self.friends) do
			if friend:isKongcheng() then
			elseif self:getSuitNum("club", false, friend) == 0 then
				for _,enemy in ipairs(self.enemies) do
					if enemy:objectName() == friend:objectName() then
					elseif self:damageIsEffective(enemy, sgs.DamageStruct_Normal, friend) then
						victim, target = enemy, friend
						break
					end
				end
				if victim and target then
					break
				end
			end
		end
		if not victim then
			for _,enemy in ipairs(self.enemies) do
				if enemy:isKongcheng() then
				elseif self:getSuitNum("club", false, enemy) == enemy:getHandcardNum() then
					for _,friend in ipairs(self.friends) do
						if enemy:objectName() == friend:objectName() then
						elseif not hasManjuanEffect(friend) then
							victim, target = friend, enemy
							break
						end
					end
					if victim and target then
						break
					end
				end
			end
		end
		if not victim then
			for _,enemy in ipairs(self.enemies) do
				if not enemy:isKongcheng() then
					for _,friend in ipairs(self.friends) do
						if enemy:objectName() == friend:objectName() then
						elseif hasManjuanEffect(friend) then
						elseif self:damageIsEffective(friend, sgs.DamageStruct_Normal, enemy) then
							if self:getDamagedEffects(friend, enemy, false) and not self:isWeak(friend) then
								victim, target = friend, enemy
								break
							end
						else
							victm, target = friend, enemy
							break
						end
					end
					if victim and target then
						break
					end
				end
			end
		end
	end
	if victim and target then
		use.card = card
		if use.to then
			use.to:append(victim)
			use.to:append(target)
		end
	end
end
--相关信息
local system_card_intention = sgs.ai_card_intention.general
sgs.ai_card_intention.general = function(from, to, level)
	if from and from:hasFlag("scrJiYuTarget") then
		from:setFlags("-scrJiYuTarget")
		level = 0
	end
	system_card_intention(from, to, level)
end
--[[
	技能：借荆
	描述：一名角色的准备阶段开始时，若其同意，你可以弃置两张牌，然后该角色选择一项：摸两张牌，或者回复1点体力。
]]--
--player:askForSkillInvoke("scrJieJing", sgs.QVariant(prompt))
sgs.ai_skill_invoke["scrJieJing"] = function(self, data)
	local prompt = data:toString():split(":")
	local name = prompt[2]
	local alives = self.room:getAlivePlayers()
	local source = nil
	for _,p in sgs.qlist(alives) do
		if p:objectName() == name then
			source = p
			break
		end
	end
	if source and self:isFriend(source) then
		return true
	end
	return false
end
--room:askForUseCard(player, "@@scrJieJing", prompt)
sgs.ai_skill_use["@@scrJieJing"] = function(self, prompt, method)
	local current = self.room:getCurrent()
	if current and self:isFriend(current) then
		local to_discard = self:askForDiscard("dummy", 2, 2, false, true)
		if #to_discard == 2 then
			local card_str = "#scrJieJingCard:"..table.concat(to_discard, "+")..":->."
			return card_str
		end
	end
	return "."
end
--room:askForChoice(player, "scrJieJing", choices, data)
sgs.ai_skill_choice["scrJieJing"] = function(self, choices, data)
	local withRecover = string.find(choices, "recover")
	if withRecover then
		if self:willSkipPlayPhase() and self:getOverflow() >= -1 then
			return "recover"
		end
	end
	local peach = self:getCardsNum("Peach")
	if peach >= self.player:getLostHp() then
		return "draw"
	end
	if withRecover then
		if self:isWeak() then
			return "recover"
		end
	end
	return "draw"
end
--相关信息
sgs.ai_card_intention["scrJieJingCard"] = function(self, card, from, tos)
	local current = self.room:getCurrent()
	if current and current:objectName() ~= from:objectName() then
		sgs.updateIntention(from, current, -50)
	end
end
--[[****************************************************************
	编号：SCR - 005
	武将：姜尚
	称号：渔人
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：垂钓
	描述：一名角色的出牌阶段开始时，其可以交给你一张牌，观看你的所有手牌。若如此做，你的手牌视为对其可见直至该阶段结束。
]]--
--room:askForCard(player, "..", prompt, data, sgs.Card_MethodNone, source, false, "scrChuiDiao")
sgs.ai_skill_cardask["@scrChuiDiao"] = function(self, data, pattern, target, target2, arg, arg2)
	if self:isFriend(target) then
		if hasManjuanEffect(target) and self:getOverflow() <= 0 then
			return "."
		end
		self.player:setFlags("Global_AIDiscardExchanging")
		local to_give = self:askForDiscard("dummy", 1, 1, false, true)
		self.player:setFlags("-Global_AIDiscardExchanging")
		if #to_give == 1 then
			return "$"..to_give[1]
		end
	end
	return "."
end
--[[
	技能：扶保
	描述：你对一名角色发动“垂钓”后，你可以令其进行一次判定。其获得此判定牌且手牌上限+X直至当前回合结束（X为此判定牌的点数）。
]]--
--player:askForSkillInvoke("scrFuBao", sgs.QVariant(prompt))
sgs.ai_skill_invoke["scrFuBao"] = function(self, data)
	local current = self.room:getCurrent()
	return current and self:isFriend(current)
end
--相关信息
sgs.ai_choicemade_filter["skillInvoke"].scrFuBao = function(self, player, promptlist)
	if promptlist[2] == "scrFuBao" and promptlist[3] == "yes" then
		local current = self.room:getCurrent()
		if current and current:objectName() ~= player:objectName() then
			sgs.updateIntention(player, current, -40)
		end
	end
end
--[[****************************************************************
	编号：SCR - 006
	武将：王佐
	称号：苦人
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：断臂（阶段技）
	描述：你可以对自己造成1点伤害，然后交给一名其他角色一张牌。
]]--
--room:askForUseCard(source, "@@scrDuanBi", "@scrDuanBi")
sgs.ai_skill_use["@@scrDuanBi"] = function(self, prompt, method)
	local target, card = nil, nil
	target = sgs.duanbi_target
	if target then
		sgs.duanbi_target = nil
		self.player:setFlags("Global_AIDiscardExchanging")
		local to_give = self:askForDiscard("dummy", 1, 1, false, true)
		self.player:setFlags("-Global_AIDiscardExchanging")
		if #to_give > 0 then
			card = sgs.Sanguosha:getCard(to_give[1])
		end
	end
	local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
	duel:deleteLater()
	if not target and #self.friends_noself > 0 then
		local cards = self.player:getCards("he")
		cards = sgs.QList2Table(cards)
		card, target = self:getCardNeedPlayer(cards, false)
		local can_duel = false
		local others = self.room:getOtherPlayers(self.player)
		for _,victim in sgs.qlist(others) do
			if victim:objectName() == target:objectName() then
			elseif self:isFriend(victim) then
			elseif self:hasTrickEffective(duel, victim, target) then
				if not self:cantbeHurt(victim, target, 2) then
					can_duel = true
					break
				end
			end
		end
		if not can_duel then
			target = nil
		end
	end
	if not target and #self.enemies > 0 then
		local x = self.player:getLostHp()
		local n = 2 * math.max(1, x)
		discard_targets = self:findPlayerToDiscard("he", false, true, self.enemies, true)
		local compare_func = function(a, b)
			local countA = a:getCardCount(true)
			local countB = b:getCardCount(true)
			local deltA = countA - n
			local deltB = countB - n
			if deltA > 0 and deltB > 0 then
				return deltA < deltB
			elseif deltA < 0 and deltB < 0 then
				return deltA > deltB
			end
			local numA = math.min(countA, n)
			local numB = math.min(countB, n)
			return numA > numB
		end
		table.sort(discard_targets, compare_func)
		target = discard_targets[1]
		local can_duel, safe = false, false
		local others = self.room:getOtherPlayers(self.player)
		for _,victim in sgs.qlist(others) do
			if victim:objectName() == target:objectName() then
			elseif target:isProhibited(victim, duel) then
			else
				can_duel = true
				if self:isFriend(victim) then
					safe = false
				else
					safe = true
					break
				end
			end
		end
		if can_duel and not safe then
			target = nil
		end
	end
	if target and card then
		local card_str = "#scrDuanBiActCard:"..card:getEffectiveId()..":->"..target:objectName()
		return card_str
	end
	return "."
end
--DuanBiCard:Play
local duanbi_skill = {
	name = "scrDuanBi",
	getTurnUseCard = function(self, inclusive)
		if self.player:hasUsed("#scrDuanBiCard") then
			return nil
		end
		return sgs.Card_Parse("#scrDuanBiCard:.:")
	end,
}
table.insert(sgs.ai_skills, duanbi_skill)
sgs.ai_skill_use_func["#scrDuanBiCard"] = function(card, use, self)
	local hp = self.player:getHp()
	local damage = 0
	if self:damageIsEffective(self.player, sgs.DamageStruct_Normal, self.player) then
		damage = 1
		if self.player:hasSkill("jueqing") then
		elseif self.player:hasSkill("chouhai") and self.player:isKongcheng() then
			damage = damage + 1
		end
		if damage > 1 and self.player:hasArmorEffect("silver_lion") then
			damage = 1
		end
	end
	local will_die = false
	if hp <= damage and hp + self:getAllPeachNum() <= damage then
		will_die = true
	end
	if will_die then
		return 
	end
	local slash_num = {}
	if #self.enemies > 0 then
		self:sort(self.enemies, "defense")
	end
	local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
	duel:deleteLater()
	local target, victim = nil, nil
	if #self.friends_noself > 0 then
		self:sort(self.friends_noself, "defense")
		self.friends_noself = sgs.reverse(self.friends_noself)
	end
	if #self.enemies > 0 and #self.friends_noself > 0 then
		for _,enemy in ipairs(self.enemies) do
			local e_slash = getCardsNum("Slash", enemy, self.player)
			slash_num[enemy:objectName()] = e_slash
			for _,friend in ipairs(self.friends_noself) do
				if self:hasTrickEffective(duel, enemy, friend) then
					if getCardsNum("Slash", friend, self.player) >= e_slash then
						if not self:cantbeHurt(enemy, friend, 2) then
							target, victim = friend, enemy
							break
						end
					end
				end
			end
			if target then
				break
			end
		end
	end
	if not target and #self.enemies > 1 then
		for _,enemy in ipairs(self.enemies) do
			for _,enemy2 in ipairs(self.enemies) do
				if enemy:objectName() == enemy2:objectName() then
				elseif self:hasTrickEffective(duel, enemy2, enemy) then
					target, victim = enemy, enemy2
					break
				end
			end
		end
	end
	if not target and #self.enemies > 0 then
		self:sort(self.enemies, "threat")
		local others = self.room:getOtherPlayers(self.player)
		local friends, enemies = {}, {}
		for _,p in sgs.qlist(others) do
			if self:isFriend(p) then
				table.insert(friends, p)
			else
				table.insert(enemies, p)
			end
		end
		if #friends == 0 then
			if #self.enemies > 0 then
				for _,enemy in ipairs(self.enemies) do
					if enemy:getCardCount(true) >= 2 or hasManjuanEffect(enemy) then
						target = enemy
						break
					end
				end
			end
		else
			for _,enemy in ipairs(self.enemies) do
				local danger = false
				for _,friend in ipairs(friends) do
					if not enemy:isProhibited(friend, duel) then
						danger = true
						break
					end
				end
				if not danger then
					target = enemy
					break
				end
			end
		end
	end
	if target then
		use.card = card
		if not use.isDummy then
			sgs.duanbi_target = target
		end
	else
		if self:isWeak() then
		elseif self:getDamagedEffects(self.player, self.player, false) then
			use.card = card
		elseif self:needToLoseHp() then
			use.card = card
		end
	end
end
--相关信息
sgs.ai_use_value["scrDuanBiCard"] = 2
sgs.ai_use_priority["scrDuanBiCard"] = 4.3
--[[
	技能：说降
	描述：一名其他角色于你处获得牌时，你可以令其选择一项：1、视为对你指定的另一名角色使用一张【决斗】，且此【决斗】造成的伤害+1；2、弃置2X张牌；3、失去1点体力。然后若此时为你的回合内，你摸1+X张牌。（X为你已损失的体力值且至少为1）
]]--
--player:askForSkillInvoke("scrShuiXiang", sgs.QVariant(prompt))
sgs.ai_skill_invoke["scrShuiXiang"] = function(self, data)
	local prompt = data:toString():split(":")
	local name = prompt[2]
	local others = self.room:getOtherPlayers(self.player)
	local target = nil
	for _,p in sgs.qlist(others) do
		if p:objectName() == name then
			target = p
			break
		end
	end
	if target then
		if self.player:getPhase() == sgs.Player_Play then
			if self.player:hasUsed("#scrDuanBiCard") then
				return true
			end
		end
		if self:isFriend(target) then
			if self:needToLoseHp(target) then
				return true
			elseif target:getCardCount(true) == 1 then
				if target:getArmor() and self:needToThrowArmor(target) then
					return true
				end
			end
			local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
			duel:deleteLater()
			for _,enemy in ipairs(self.enemies) do
				if enemy:objectName() == name then
				elseif self:hasTrickEffective(duel, enemy, target) then
					if not self:cantbeHurt(enemy, target, 2) then
						return true
					end
				end
			end
		else
			local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
			duel:deleteLater()
			local has_duel_target = false
			for _,victim in sgs.qlist(others) do
				if victim:objectName() == name then
				elseif self:isFriend(victim) then
				elseif self:hasTrickEffective(duel, victim, target) then
					return true
				else
					has_duel_target = true
				end
			end
			if not has_duel_target then
				local no_fear_friend = false
				local slash_num = getCardsNum("Slash", target, self.player)
				for _,friend in ipairs(self.friends_noself) do
					if friend:objectName() == name then
					elseif self:hasTrickEffective(duel, friend, target) then
						if getCardsNum("Slash", friend, self.player) > slash_num then
							no_fear_friend = true
							break
						end
					else
						no_fear_friend = true
						break
					end
				end
				if not no_fear_friend then
					return false
				end
			end
			return true
		end
	end
	return false
end
--room:askForChoice(sp_target, "scrShuiXiang", choices, ai_data)
sgs.ai_skill_choice["scrShuiXiang"] = function(self, choices, data)
	local source = data:toPlayer()
	local withDuel = string.find(choices, "duel")
	local withDiscard = string.find(choices, "discard")
	local withLoseHp = string.find(choices, "losehp")
	local x = source:getLostHp()
	local n = math.max(1, x) * 2
	local count = self.player:getCardCount(true)
	local throw = math.min(count, n)
	if self:isFriend(source) then
		if withDuel then
			return "duel"
		end
		if withDiscard and throw == 1 then
			if self.player:getArmor() and self:needToThrowArmor() then
				return "discard" 
			elseif self.player:getHandcardNum() == 1 and self:needKongcheng() then
				return "discard"
			elseif self.player:hasEquips() and self:hasSkills(sgs.lose_equip_skill) then
				return "discard"
			end
		end
		if withLoseHp and self:needToLoseHp() then
			return "losehp"
		end
	end
	if withDuel then
		local safe = true
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		duel:deleteLater()
		for _,friend in ipairs(self.friends_noself) do
			if self:hasTrickEffective(duel, friend, self.player) then
				local damage = 2
				if self.player:hasSkill("jueqing") or friend:hasArmorEffect("silver_lion") then
					damage = 1
				elseif friend:hasSkill("chouhai") and friend:isKongcheng() then
					damage = 3
				end
				if friend:getHp() <= damage and friend:getHp() + self:getAllPeachNum(friend) <= damage then
					safe = false
					break
				elseif self.player:hasSkill("jueqing") or friend:hasSkill("sizhan") then
				elseif self:cantbeHurt(friend, self.player, damage) then
					safe = false
					break
				end
			end
		end
		if safe then
			return "duel"
		end
	end
	if withDiscard then
		if throw <= 2 then
			return "discard"
		end
	end
	if withLoseHp then
		if self:needToLoseHp() then
			return "losehp"
		end
	end
	if withDiscard then
		return "discard"
	end
	return "losehp"
end
--room:askForPlayerChosen(player, victims, "scrShuiXiang", prompt, true)
sgs.ai_skill_playerchosen["scrShuiXiang"] = function(self, targets)
	local alives = self.room:getAlivePlayers()
	local source = nil
	for _,p in sgs.qlist(alives) do
		if p:hasFlag("scrShuiXiangTarget") then
			source = p
			break
		end
	end
	if source then
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		local values = {}
		local victims = {}
		local flag = ( self.role == "renegade" and self.room:alivePlayerCount() > 2 )
		local slash_num = getCardsNum("Slash", source, self.player)
		local friend_source = self:isFriend(source)
		local enemy_source = self:isEnemy(source)
		local function getValue(victim)
			local v = 0
			local n_slash = getCardsNum("Slash", victim, self.player)
			if slash_num >= n_slash and self:hasTrickEffective(duel, victim, source) then
				local damage = 1
				local jueqing = source:hasSkill("jueqing")
				if not jueqing then
					if victim:hasSkill("chouhai") and victim:isKongcheng() then
						damage = damage + 1
					end
					if damage > 1 and victim:hasArmorEffect("silver_lion") then
						damage = 1
					end
				end
				v = v + 20 * damage
				local death = false
				local hp = victim:getHp()
				if hp <= damage then
					if hp + self:getAllPeachNum(victim) <= damage then
						death = true
					end
				end
				if death then
					v = v + 100
				elseif self:needToLoseHp(victim, source, false, true) then
					v = v - damage * 0.3
				end
				if jueqing then
				elseif self:cantbeHurt(victim, source, damage) then
					if friend_source then
						v = v - 100
					else
						v = v + 100
					end
				end
				if jueqing or death then
				elseif self:getDamagedEffects(victim, source, false) then
					v = v - damage * 0.5
				end
				if self:isFriend(victim) then
					v = - v
				elseif not self:isEnemy(victim) then
					v = v * 0.6
				end
				if death and flag and victim:isLord() then
					v = v - 1000
				end
			elseif slash_num < n_slash and self:hasTrickEffective(duel, source, victim) then
				local damage = 1
				local jueqing = victim:hasSkill("jueqing")
				if not jueqing then
					if source:hasSkill("chouhai") and source:isKongcheng() then
						damage = damage + 1
					end
					if damage > 1 and source:hasArmorEffect("silver_lion") then
						damage = 1
					end
				end
				v = v + damage * 20
				local death = false
				local hp = source:getHp()
				if hp <= damage then
					if hp + self:getAllPeachNum(source) <= damage then
						death = true
					end
				end
				if death then
					v = v + 100
				elseif self:needToLoseHp(source, victim, false, true) then
					v = v - damage * 0.3
				end
				if jueqing then
				elseif self:cantbeHurt(source, victim, damage) then
					if self:isFriend(victim) then
						v = v - 100
					else
						v = v + 100
					end
				end
				if jueqing or death then
				elseif self:getDamagedEffects(source, victim, false) then
					v = v - damage * 0.5
				end
				if friend_source then
					v = - v
				elseif not enemy_source then
					v = v * 0.6
				end
				if death and flag and source:isLord() then
					v = v - 1000
				end
			end
			return v
		end
		for _,p in sgs.qlist(targets) do
			values[p:objectName()] = getValue(p)
			table.insert(victims, p)
		end
		local compare_func = function(a, b)
			local valueA = values[a:objectName()] or 0
			local valueB = values[b:objectName()] or 0
			return valueA > valueB
		end
		table.sort(victims, compare_func)
		local victim = victims[1]
		local value = values[victim:objectName()] or 0
		if value > 0 then
			return victim
		end
	end
end
--room:askForDiscard(sp_target, "scrShuiXiang", num, num, false, true)
--相关信息
local system_duel = sgs.ai_card_intention.Duel
sgs.ai_card_intention.Duel = function(self, card, from, tos)
	if card:getSkillName() == "scrShuiXiang" then
		return 
	end
	system_duel(self, card, from, tos)
end
--[[****************************************************************
	编号：SCR - 007
	武将：张飞
	称号：莽撞人
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：虚实
	描述：你成为一名其他角色使用的【杀】的目标时，你可以视为使用一张【无中生有】。若如此做，此【杀】造成的伤害+1。
]]--
--player:askForSkillInvoke("scrXuShi", data)
sgs.ai_skill_invoke["scrXuShi"] = function(self, data)
	local use = data:toCardUse()
	local source = use.from
	local slash = use.card
	if self:slashIsEffective(slash, self.player, source, false) then
		if self.player:hasArmorEffect("silver_lion") then
			return true
		elseif self:canHit(self.player, source) then
			return false
		end
	end
	return true
end
--[[
	技能：暴喝
	描述：出牌阶段限X次，你可以弃一张黑色手牌，对你攻击范围内的一名角色造成1点伤害。（X为你已损失的体力值）
]]--
--BaoHeCard:Play
local baohe_skill = {
	name = "scrBaoHe",
	getTurnUseCard = function(self, inclusive)
		if self.player:isKongcheng() then
			return nil
		elseif self.player:usedTimes("#scrBaoHeCard") >= self.player:getLostHp() then
			return nil
		end
		return sgs.Card_Parse("#scrBaoHeCard:.:")
	end,
}
table.insert(sgs.ai_skills, baohe_skill)
sgs.ai_skill_use_func["#scrBaoHeCard"] = function(card, use, self)
	local handcards = self.player:getHandcards()
	local blacks = {}
	for _,c in sgs.qlist(handcards) do
		if c:isBlack() then
			table.insert(blacks, c)
		end
	end
	if #blacks == 0 then
		return 
	end
	local alives = self.room:getAlivePlayers()
	local victims = {}
	for _,p in sgs.qlist(alives) do
		if self.player:inMyAttackRange(p) then
			table.insert(victims, p)
		end
	end
	if #victims == 0 then
		return 
	end
	local flag = ( self.role == "renegade" and self.room:alivePlayerCount() > 2 )
	local getValue = function(victim)
		local v = 0
		local damage, lose, prevent = 0, 0, 0
		if self.player:hasSkill("jueqing") then
			lose = 1
		elseif victim:hasSkill("sizhan") then
			prevent = 1
		elseif self:damageIsEffective(victim, sgs.DamageStruct_Normal, self.player) then
			damage = 1
			if victim:isKongcheng() and victim:hasSkill("chouhai") then
				damage = damage + 1
			end
			if damage > 1 and victim:hasArmorEffect("silver_lion") then
				damage = 1
			end
		end
		local minus = damage + lose
		v = v + minus * 20
		if lose > 0 then
			if victim:hasSkill("zhaxiang") then
				v = v - lose * 30
			end
		end
		local hp = victim:getHp()
		local to_death = false
		if minus >= hp then
			if minus - hp >= self:getAllPeachNum(victim) then
				to_death = true
			end
		end
		if to_death then
			v = v + 100
		else
			if getBestHp(victim) >= hp + minus then
				v = v - minus * 3
			end
			if self:needToLoseHp(victim) then
				v = v - 10
			end
		end
		if self:isFriend(victim) then
			v = - v
		elseif not self:isEnemy(victim) then
			v = v * 0.35
		end
		if damage > 0 then
			if self:cantbeHurt(victim, self.player, damage) then
				v = v - 100
			end
			if not to_death then
				if self:getDamagedEffects(victim, self.player, false) then
					v = v - minus * 4
				end
			end
		end
		if to_death then
			if victim:isLord() and flag then
				v = v - 1000
			end
		end
		return v
	end
	local values = {}
	for _,victim in ipairs(victims) do
		values[victim:objectName()] = getValue(victim)
	end
	local compare_func = function(a, b)
		local valueA = values[a:objectName()] or 0
		local valueB = values[b:objectName()] or 0
		return valueA > valueB
	end
	table.sort(victims, compare_func)
	local target = victims[1]
	local value = values[target:objectName()] or 0
	local need = 10
	if self:getOverflow() > 0 then
		need = 0
	end
	if value > need then
		self:sortByUseValue(blacks, true)
		local card_str = "#scrBaoHeCard:"..blacks[1]:getEffectiveId()..":"
		local acard = sgs.Card_Parse(card_str)
		use.card = acard
		if use.to then
			use.to:append(target)
		end
	end
end
--相关信息
sgs.ai_use_value["scrBaoHeCard"] = 4
sgs.ai_use_priority["scrBaoHeCard"] = 1
--[[****************************************************************
	编号：SCR - 008
	武将：曹真
	称号：气死人
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：阅函
	描述：一名角色的弃牌阶段开始时，其可以将一张牌置于你的武将牌上，称为“函”。你需要使用或打出一张牌时，若“函”中存在此牌，你可以使用或打出之，然后你摸一张牌。
]]--
--room:askForAG(source, card_ids, true, "scrYueHan")
sgs.ai_skill_askforag["scrYueHan"] = function(self, card_ids)
	local cards = {}
	for _,id in ipairs(card_ids) do
		local card = sgs.Sanguosha:getCard(id)
		table.insert(cards, card)
	end
	self:sortByUsePriority(cards, self.player)
	return cards[1]:getEffectiveId()
end
--room:askForUseCard(source, "@@scrYueHan", prompt)
sgs.ai_skill_use["@@scrYueHan"] = function(self, prompt, method)
	local id = self.player:getMark("scrYueHanID")
	local pattern = self.player:property("scrYueHanPattern"):toString()
	local card = sgs.Sanguosha:getCard(id)
	local dummy_use = {
		isDummy = true,
		to = sgs.SPlayerList(),
	}
	if card:isKindOf("BasicCard") then
		local fixed_targets = {}
		if card:isKindOf("Slash") and pattern ~= "" then
			local selected = sgs.PlayerList()
			local alives = self.room:getAlivePlayers()
			for _,p in sgs.qlist(alives) do
				if card:targetFilter(selected, p, self.player) then
					table.insert(fixed_targets, p)
				end
			end
		end
		self:useBasicCard(card, dummy_use)
		if #fixed_targets > 0 then
			local ok = false
			for _,target in ipairs(fixed_targets) do
				for _,victim in sgs.qlist(dummy_use.to) do
					if victim:objectName() == target:objectName() then
						ok = true
						break
					end
				end
				if ok then
					break
				end
			end
			if not ok then
				return "."
			end
		end
	elseif card:isKindOf("TrickCard") then
		self:useTrickCard(card, dummy_use)
	elseif card:isKindOf("EquipCard") then
		self:useEquipCard(card, dummy_use)
	end
	local targets = {}
	if dummy_use.to then
		for _,target in sgs.qlist(dummy_use.to) do
			table.insert(targets, target:objectName())
		end
	end
	if #targets > 0 then
		local card_str = "#scrYueHanSelectCard:.:->"..table.concat(targets, "+")
		return card_str
	end
	return "."
end
--YueHanCard:Play
local yuehan_skill = {
	name = "scrYueHan",
	getTurnUseCard = function(self, inclusive)
		if self.player:hasFlag("scrYueHanFailed") then
			return nil
		elseif self.player:getPile("scrYueHanPile"):isEmpty() then
			return nil
		end
		return sgs.Card_Parse("#scrYueHanCard:.:")
	end,
}
table.insert(sgs.ai_skills, yuehan_skill)
sgs.ai_skill_use_func["#scrYueHanCard"] = function(card, use, self)
	local pile = self.player:getPile("scrYueHanPile")
	local can_use = {}
	for _,id in sgs.qlist(pile) do
		local c = sgs.Sanguosha:getCard(id)
		if c:isKindOf("Jink") or c:isKindOf("Nullification") then
		elseif c:isKindOf("Peach") and self.player:getLostHp() == 0 then
		elseif c:isKindOf("Analeptic") and not c:isAvailable(self.player) then
		elseif c:isKindOf("Slash") and not c:isAvailable(self.player) then
		elseif c:isKindOf("Disaster") and self.player:containsTrick(c:objectName()) then
		else
			table.insert(can_use, c)
		end
	end
	if #can_use > 0 then
		use.card = card
	end
end
--YueHanCard:Response
sgs.ai_cardsview_valuable["scrYueHan"] = function(self, class_name, player)
	local pile = player:getPile("scrYueHanPile")
	if pile:isEmpty() then
		return 
	end
	local to_use, pattern = nil, nil
	for _,id in sgs.qlist(pile) do
		local card = sgs.Sanguosha:getCard(id)
		if card:getClassName() == class_name then
			to_use, pattern = card, card:objectName()
			break
		elseif class_name == "Slash" and card:isKindOf("Slash") then
			to_use, pattern = card, "slash"
			break
		end
	end
	if to_use and pattern then
		local card_str = "#scrYueHanCard:.:"..pattern
		return card_str
	end
end
--room:askForCard(player, "..", prompt, data, sgs.Card_MethodNone, source, false, "scrYueHan")
sgs.ai_skill_cardask["@scrYueHan-send"] = function(self, data, pattern, target, target2, arg, arg2)
	local handcards = self.player:getHandcards()
	local isFriend = self:isFriend(target)
	local isEnemy = self:isEnemy(target)
	local overflow = self:getOverflow()
	if overflow <= 0 and not isFriend and not isEnemy then
		return "."
	end
	local can_use, cannot_use = {}, {}
	local may_response = {}
	local others = self.room:getOtherPlayers(target)
	for _,card in sgs.qlist(handcards) do
		if card:isKindOf("EquipCard") then
			table.insert(can_use, card)
		elseif card:isKindOf("BasicCard") then
			if card:isKindOf("Slash") then
				local victims = self:exclude(others, card, target)
				if #victims == 0 then
					table.insert(cannot_use, card)
				else
					table.insert(can_use, card)
				end
				table.insert(may_response, card)
			elseif card:isKindOf("Analeptic") then
				table.insert(can_use, card)
				if target:getHp() <= 1 then
					table.insert(may_response, card)
				end
			elseif card:isKindOf("Peach") then
				if target:getLostHp() == 0 then
					table.insert(cannot_use, card)
				else
					table.insert(can_use, card)
				end
				table.insert(may_response, card)
			elseif card:isKindOf("Jink") then
				table.insert(cannot_use, card)
				table.insert(may_response, card)
			end
		elseif card:isKindOf("TrickCard") then
			if card:isKindOf("DelayedTrick") then
				if card:isKindOf("Disaster") then
					if target:isProhibited(target, card) then
						table.insert(cannot_use, card)
					else
						table.insert(can_use, card)
					end
				elseif card:isKindOf("Indulgence") then
					table.insert(can_use, card)
				elseif card:isKindOf("SupplyShortage") then
					local victims = self:exclude(others, card, target)
					if #victims == 0 then
						table.insert(cannot_use, card)
					else
						table.insert(can_use, card)
					end
				end
			elseif card:isKindOf("Nullification") then
				table.insert(cannot_use, card)
				table.insert(may_response, card)
			elseif card:isKindOf("GlobalEffect") then
				local alives = self.room:getAlivePlayers()
				local can_use_flag = false
				for _,p in sgs.qlist(alives) do
					if not target:isProhibited(p, card) then
						can_use_flag = true
						break
					end
				end
				if can_use_flag then
					table.insert(can_use, card)
				else
					table.insert(cannot_use, card)
				end
			elseif card:isKindOf("ExNihilo") or card:isKindOf("IronChain") then
				table.insert(can_use, card)
			elseif card:isKindOf("Snatch") then
				local victims = self:exclude(others, card, target)
				if #victims == 0 then
					table.insert(cannot_use, card)
				else
					table.insert(can_use, card)
				end
			else
				local can_use_flag = false
				for _,p in sgs.qlist(others) do
					if not target:isProhibited(p, card) then
						can_use_flag = true
						break
					end
				end
				if can_use_flag then
					table.insert(can_use, card)
				else
					table.insert(cannot_use, card)
				end
			end
		end
	end
	local pile = target:getPile("scrYueHanPile")
	local slash_num, jink_num, peach_num, anal_num, null_num = 0, 0, 0, 0, 0
	for _,id in sgs.qlist(pile) do
		local card = sgs.Sanguosha:getCard(id)
		if card:isKindOf("Slash") then
			slash_num = slash_num + 1
		elseif card:isKindOf("Jink") then
			jink_num = jink_num + 1
		elseif card:isKindOf("Peach") then
			peach_num = peach_num + 1
		elseif card:isKindOf("Analeptic") then
			anal_num = anal_num + 1
		elseif card:isKindOf("Nullification") then
			null_num = null_num + 1
		end
	end
	local enemy_num = self:getEnemyNumBySeat(self.player, target, target, true)
	local to_give = nil
	if isFriend then
		if enemy_num > 0 then
			if #may_response > 0 then
				self:sortByKeepValue(may_response, true)
				for _,card in ipairs(may_response) do
					if card:isKindOf("Slash") and slash_num < enemy_num * 0.5 then
						to_give = card
						break
					elseif card:isKindOf("Jink") and jink_num < enemy_num then
						to_give = card
						break
					elseif card:isKindOf("Analeptic") and anal_num < enemy_num * 0.8 then
						if target:getHp() <= 1 then
							to_give = card
							break
						end
					elseif card:isKindOf("Peach") and overflow > 0 then
						if peach_num + 1 <= target:getLostHp() then
							to_give = card
							break
						end
					elseif card:isKindOf("Nullification") and overflow > 0 then
						if null_num == 0 then
							to_give = card
							break
						end
					end
				end
			end
		end
		if not to_give then
			if #can_use > 0 and overflow > 0 then
				self:sortByUseValue(can_use)
				for _,card in ipairs(can_use) do
					if card:isKindOf("Slash") and slash_num > 0 and not self:hasCrossbowEffect(target) then
					elseif card:isKindOf("Peach") and peach_num + 1 > target:getLostHp() then
					elseif card:isKindOf("Analeptic") and anal_num > 0 then
					else
						to_give = card
						break
					end
				end
			end
		end
	elseif isEnemy then
		if #cannot_use > 0 then
			self:sortByKeepValue(cannot_use)
			if enemy_num == 0 then
				to_give = cannot_use[1]
			else
				for _,card in ipairs(cannot_use) do
					local response = false
					for _,c in ipairs(may_response) do
						if card:objectName() == c:objectName() then
							response = true
							break
						end
					end
					if not response then
						to_give = card
						break
					end
				end
				if not to_give then
					if overflow > 0 then
						to_give = cannot_use[1]
					end
				end
			end
		end
	else
		if #cannot_use > 0 then
			for _,c in ipairs(cannot_use) do
				if not c:isKindOf("Peach") then
					to_give = c
				end
			end
		end
	end
	if to_give then
		return "$"..to_give:getEffectiveId()
	end
	return "."
end
--相关信息
sgs.ai_use_priority["scrYueHanCard"] = 10
sgs.ai_use_value["scrYueHanCard"] = 3
--[[
	技能：气绝（锁定技）
	描述：出牌阶段结束时，你弃置所有的“函”并失去X点体力（X为你弃置“函”的数量）。
]]--