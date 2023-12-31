class('Score').extends(playdate.graphics.sprite)

-- Score
--
-- A score sprite containing a line of text and a score value.
function Score:init(text, index)

	Score.super.init(self)
	self.previousValue = 0
	self.value = 0
	self.text = string.lower(text)
	self.index = index
	self:setSize((160 - (3 * 8)) / 2, 50)
	self:setZIndex(11)
	self:drawImage()
	self:setCollisionsEnabled(false)
	self:moveTo(8 + (8 + self.width) * (self.index - 1) + (self.width / 2), 8 + (self.height / 2))
	self:add()
	return self

end

-- update()
--
function Score:update()

	if self.value ~= self.previousValue then
		self:drawImage()
		self.previousValue = self.value
	end

end

-- load()
--
-- Loads score from data save.
function Score:load()

	local data = playdate.datastore.read(self.text)
	if data ~= nil then
		self.value = data[1]
		self:checkMaxValue()
	end

end

-- save()
--
function Score:save()

	playdate.datastore.write({self.value, "I didn't bother to make this any obfuscated, but that's not a reason for you to cheat here. Enjoy the game at your own pace."}, self.text)

end

-- getValue()
--
function Score:getValue()

	return self.value

end

-- setValue()
--
function Score:setValue(value)

	self.value = value
	self:checkMaxValue()

end

-- addToValue()
--
function Score:addToValue(value)

	self.value = self.value + value
	self:checkMaxValue()

end

-- checkMaxValue()
--
-- To prevent text overflow bugs, we cap the maximum value of any score.
function Score:checkMaxValue()

	if self.value > 999999 then
		self.value = 999999
	end

end

-- drawImage()
--
function Score:drawImage()

	local img = playdate.graphics.image.new(self.width, self.height)
	playdate.graphics.pushContext(img)
		-- Background
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(0, 0, self.width, self.height, 4)
		-- Text
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
		playdate.graphics.setFont(gFontFullCircle)
		playdate.graphics.drawTextInRect(string.upper(self.text), 8, 10, self.width - 16, self.height, nil, nil, kTextAlignment.left)
		playdate.graphics.drawTextInRect("" .. self.value, 8, 24, self.width - 8, self.height, nil, nil, kTextAlignment.left)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
	playdate.graphics.popContext()
	self:setImage(img)

end