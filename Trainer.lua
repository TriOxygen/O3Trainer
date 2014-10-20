local addon, ns = ...
local O3 = O3
local UI = O3.UI

O3:module({
	name = 'O3Trainer',
	events = {
		TRAINER_SHOW = true,
		TRAINER_CLOSED = true,
	},
	getTrainerWindow = function (self)
		if (not self.trainerWindow) then
			self.trainerWindow = ns.TrainerWindow:new()
		end
		return self.trainerWindow
	end,
	TRAINER_SHOW = function (self)
		self:getTrainerWindow():show()
	end,
	TRAINER_CLOSED = function (self)
		self:getTrainerWindow():hide()
	end,
	postInit = function (self)
		ClassTrainerFrame_LoadUI = function ()
		end		
	end,	
})