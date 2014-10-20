local addon, ns = ...
local O3 = O3
local UI = O3.UI


local TrainerItem = O3.UI.Panel:extend({
	height = 24,
	type = 'Button',
	offset = {2, 2, nil, nil},
	colors = {
		trivial = {0.5, 0.5, 0.5, 1},
		easy = {0.1, 0.5, 0.1, 1},
		medium = {0.8, 0.8, 0.1, 1},
		optimal = {1, 0.5, 0.1, 1},
		header = {1, 1, 1, 1},
		subheader = {1, 1, 1, 1},
	},
	expandClick = function (self)
	end,
	createRegions = function (self)
		self.button = O3.UI.IconButton:instance({
			parent = self,
			icon = nil,
			parentFrame = self.frame,
			height = self.height,
			width = self.height,
			offset = {1, nil, 0, nil},
			onClick = function (iconButton)
				if (iconButton.parent.onIconClick) then
					iconButton.parent:onIconClick()
				end
			end,
			createRegions = function (iconButton)
				iconButton.count = iconButton:createFontString({
					offset = {2, nil, 2, nil},
					fontFlags = 'OUTLINE',
					text = nil,
					-- shadowOffset = {1, -1},
					fontSize = 12,
				})
			end,
		})	
		self.panel = self:createPanel({
			offset = {25, 0, 0, 0},
			createRegions = function (panel)
				panel.name = panel:createFontString({
					offset = {1, 1, 2, nil},
					height = 12,
					color = {0.9, 0.9, 0.9, 1},
					justifyV = 'TOP',
					justifyH = 'LEFT',
					fontSize = 10,
				})
				panel.cost = panel:createFontString({
					offset = {1, 1, nil, 2},
					height = 12,
					color = {0.6, 0.6, 0.6, 1},
					justifyV = 'BOTTOM',
					justifyH = 'RIGHT',
					fontSize = 10,
				})
				panel.requires = panel:createFontString({
					offset = {1, 1, nil, 0},
					height = 12,
					color = {0.5, 0.5, 0.5, 1},
					justifyV = 'BOTTOM',
					justifyH = 'LEFT',
					fontSize = 10,
				})
				panel.highlight = panel:createTexture({
					layer = 'ARTWORK',
					gradient = 'VERTICAL',
					color = {0,1,1,0.10},
					colorEnd = {0,0.5,0.5,0.20},
					offset = {1,1,1,1},
				})
				panel.highlight:Hide()
			end,
			style = function (panel)
				panel.bg = panel:createTexture({
					layer = 'BACKGROUND',
					subLayer = -7,
					color = {0.1, 0.1, 0.1, 0.95},
					-- offset = {0, 0, 0, nil},
					-- height = 1,
				})
				panel:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.03 },
					colorEnd = {1, 1, 1, 0.05 },
					offset = {0, 0, 0, 0},
					-- width = 2,
					-- height = 2,
				})	

			end,

		})
		self.name = self.panel.name
		self.cost = self.panel.cost
		self.requires = self.panel.requires
	end,
	update = function (self, i)
		self.id = i
		local serviceName, serviceSubText, serviceType, iconTexture, reqLevel, isExpanded = GetTrainerServiceInfo(i)
		local icon = GetTrainerServiceIcon(i)
		local skill, rank, hasReq = GetTrainerServiceSkillReq(i)
		local moneyCost, talentCost, skillCost = GetTrainerServiceCost(i)
		local color = '|cff00ff00'
		if (not hasReq) then
			color = '|cffff0000'
		end
		self.button:setTexture(icon)
		self.name:SetText(serviceName)
		if skill then
			self.requires:SetText('Requires : '.. skill..' ('..color..rank..'|r)')
		else
			self.requires:SetText('')
		end
		self.cost:SetText(O3:formatMoney(moneyCost))
	end,
	check = function (self, checked)
		if checked then
			self.panel.checkedLayer:Show()
		else
			self.panel.checkedLayer:Hide()
		end
	end,
	hook = function (self)
		self.frame:SetScript('OnEnter', function (frame)
			self.panel.highlight:Show()
			GameTooltip:SetOwner(self.frame, "ANCHOR_RIGHT", 12)
			GameTooltip:SetTrainerService(self.id)
			CursorUpdate(self.frame)
			GameTooltip:Show()

		
			if (self.onEnter) then
				self:onEnter()
			end
		end)
		self.frame:SetScript('OnLeave', function (frame)
			GameTooltip:Hide()
			ResetCursor()

			self.panel.highlight:Hide()
			if (self.onLeave) then
				self:onLeave()
			end
		end)
		self.frame:SetScript('OnClick', function (frame)
			if (self.onClick) then
				self:onClick()
			end
		end)
	end,	
})


ns.TrainerWindow = UI.ItemListWindow:extend({
	_weight = 99,
	settings = {
		itemHeight = 26,
	},
	name = 'Trainer',
	title = 'O3 Trainer',	
	managed = true,
	getNumItems = function (self)
		self.numItems = GetNumTrainerServices()
	end,
	createItem = function (self)
		local itemHeight = self.settings.itemHeight
		return TrainerItem:instance({
			parentFrame = self.content.frame,
			height = itemHeight,
			onClick = function (item)
				BuyTrainerService(item.id)
				self:scrollTo()
			end,
		})
	end,	
	onHide = function (self)
		if IsTradeskillTrainer() then
			CloseTrainer()
		end
	end,
})
