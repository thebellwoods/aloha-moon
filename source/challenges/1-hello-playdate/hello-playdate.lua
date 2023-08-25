-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

--- common practice to create a class for each module so that you can use this code base from you main.lua
HelloPlaydate = {
	isRunning = false,
	images = "challenges/1-hello-playdate/assets/images/", -- relative path seems to be difficult so that you create the path from the source 
	fonts = "challenges/1-hello-playdate/assets/fonts/",
	audio = "challenges/1-hello-playdate/assets/audio/",
	A = playdate.kButtonA,
	B = playdate.kButtonB,
	UP = playdate.kButtonUp,
	DOWN = playdate.kButtonDown,
	LEFT = playdate.kButtonLeft,
	RIGHT = playdate.kButtonRight
}



-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local gfx <const> = playdate.graphics

-- Here's our arrow sprite declaration. We'll scope it to this file because
-- several functions need to access it.
local menuOptionHeight = 40
local menuOptions = {
	{
		y = 80,
		option = "cut the red wire",
		height=  menuOptionHeight
	},
	{
	   y = 80 + menuOptionHeight,
	   option =  "cut the blue wire",
	   height = menuOptionHeight
	},
	{
	   y = 80 + menuOptionHeight * 2,
	   option = "cut the yellow wire",
	   height = menuOptionHeight
	},
}


local arrowSprite = nil
local screenHeight = 240
local screenCentre = screenHeight / 2
local arrowSpriteStartX = 40
local arrowSpriteStartY = 80
local totalMenuOptions = #menuOptions -- gets the length
local arrowSpriteY = arrowSpriteStartY -- the arrow sprite starts on the same y position as the first menu item 

local arrowSpriteMaxY = arrowSpriteStartY + (menuOptionHeight * (totalMenuOptions - 1)) -- hardcode to 3 options for now 

-- AUDIO
-- see readme for audio credit
local selectionSound = playdate.sound.sampleplayer.new(HelloPlaydate.audio .. "selection.wav")
local selectionRevSound = playdate.sound.sampleplayer.new(HelloPlaydate.audio .. "selection-reverse.wav")
local denialSound = playdate.sound.sampleplayer.new(HelloPlaydate.audio .. "audio/denial.wav")
local confirmSound = playdate.sound.sampleplayer.new(HelloPlaydate.audio .. "confirm.wav")

local hideSound = playdate.sound.sampleplayer.new(HelloPlaydate.audio .. "swish-out.wav")
local showSound = playdate.sound.sampleplayer.new(HelloPlaydate.audio .. "audio/swish-in.wav")

local headerFont = gfx.getSystemFont("bold")
-- local listFont = Panels.Font.get(Panels.Settings.path .. "assets/fonts/Asheville-Narrow-14-Bold")--gfx.getSystemFont()

local listFont = gfx.getSystemFont()



-- A function to set up our game environment.

function HelloPlaydate.myGameSetUp()

	local arrowImage = gfx.image.new(HelloPlaydate.images .. "arrow")
	assert( arrowImage ) -- make sure the image was where we thought

	arrowSprite = gfx.sprite.new( arrowImage )
	arrowSprite:moveTo( arrowSpriteStartX, arrowSpriteStartY ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
	arrowSprite:add() -- This is critical!

	-- We want an environment displayed behind our sprite.
	-- There are generally two ways to do this:
	-- 1) Use setBackgroundDrawingCallback() to draw a background image. (This is what we're doing below.)
	-- 2) Use a tilemap, assign it to a sprite with sprite:setTilemap(tilemap),
	--       and call :setZIndex() with some low number so the background stays behind
	--       your other sprites.

	local backgroundImage = gfx.image.new(HelloPlaydate.images .. "background")
	assert( backgroundImage )

	gfx.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			-- x,y,width,height is the updated area in sprite-local coordinates
			-- The clip rect is already set to this area, so we don't need to set it ourselves
			backgroundImage:draw( 0, 0 )
		end
	)

end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.


-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.
	
 	
local function onUpdateListenToSpritePostion()
	
	for i, obj in ipairs(menuOptions) do
		-- which menu item is the arrow beside?
		local menuOptionYMin = obj.y
		local menuOptionYMax = menuOptionYMin + menuOptionHeight
		
		if arrowSpriteY >= menuOptionYMin and arrowSpriteY <  menuOptionYMax then 
			print('listing to sprite update y', obj.option)
		end
	end
	
	print('listing to sprite update y', "" .. arrowSpriteY)

end

local function resetArrowSprite()
	arrowSpriteY = arrowSpriteStartY
	arrowSprite:moveTo( arrowSpriteStartX, arrowSpriteStartY )
end 	

local function reset()
	resetArrowSprite()
end	

-- arrowSprite:moveBy( 0, -menuOptionHeight ) <--- explore moveBy is another challenge - for this challenge stick with moveTo

-- note careful with playdate.buttonIsPressed which means it held down so it might get more events than once

local function helloPlaydateUpate()
	-- Poll the d-pad and move our arrow accordingly.
	-- (There are multiple ways to read the d-pad; this is the simplest.)
	-- Note that it is possible for more than one of these directions
	-- to be pressed at once, if the user is pressing diagonally.
	
	-- we only need up and down for this challenge
	
	-- UP
	if playdate.buttonJustReleased( HelloPlaydate.UP ) then
		
		if arrowSpriteY > arrowSpriteStartY then
			arrowSpriteY = arrowSpriteY - menuOptionHeight
			arrowSprite:moveTo( arrowSpriteStartX, arrowSpriteY )
			
		else 
			arrowSpriteY = arrowSpriteStartY
		end	
		
		if arrowSpriteY < 0 then
			resetArrowSprite()
		end
		
	end
	
	-- RIGHT
	--[[
	if playdate.buttonIsPressed( playdate.kButtonRight ) then
		arrowSprite:moveBy( 2, 0 )
	end]]
	
	-- DOWN
	if playdate.buttonJustReleased(HelloPlaydate.DOWN ) then
		
		if arrowSpriteY < arrowSpriteMaxY then
			arrowSpriteY = arrowSpriteY + menuOptionHeight
			print("DOWN updated spring y", "" .. arrowSpriteY )
			print("DOWN updated spring x", "" .. arrowSpriteStartX )
			arrowSprite:moveTo( arrowSpriteStartX, arrowSpriteY )
		else
			resetArrowSprite()
		end
			 
	end
	
	-- LEFT
	--[[
	if playdate.buttonIsPressed( playdate.kButtonLeft ) then
		arrowSprite:moveBy( -2, 0 )
	end]]
	
	-- Call the functions below in playdate.update() to draw sprites and keep
	-- timers updated. (We aren't using timers in this example, but in most
	-- average-complexity games, you will.)
	
	-- we can use B to reset 
	if playdate.buttonJustReleased( HelloPlaydate.B ) then
		reset()
	end	
	
	gfx.sprite.update()
	playdate.timer.updateTimers()
	
	-- onUpdateListenToSpritePostion()
	
end


function playdate.update()
	if HelloPlaydate.isRunning then
		helloPlaydateUpate()
	end 
end