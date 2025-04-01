-- Modules and global objects
local discordia = require('discordia')

local client = discordia.Client()
local stats = require('stats') or {}

require('modules/util_commands') -- Define the utils globally FIRST so to avoid conflictions, DO NOT CHANGE THIS PLACEMENT
local score = require('modules/score') -- The order of this and the following modules may be changed
local leaderboard = require('modules/leaderboard')
local matchup = require('modules/matchup')
local q = require('modules/q')
local attributes = require('modules/attributes')


-- globals -- 
local negativeReplies = { -- These are to be tampered with xD (feel free to add some)
	"You are a disgrace to the chess world.",
	"Imagine pinging me IN MY FREAKING SLEEP YOU MONSTER",
	"STOP PINGING ME CRINGE COWARD",
	"*Spills tea* The **f** did you just say to me?",
	"WHY MUST I BE SUMMONED AT THIS POINT IN TIME GET A HOBBY",
	"Aww does the little baby chess child need help changing their diaper?",
	"You have a bongcloud kind of intelligence",
	"Shut your filthy rook",
	"There may be people decent at chess here, but you my friend would use chopsticks to play",
	"To borrow a line from PwowoKam: I will skin you alive <3",
	"A lonely pawn you must be.",
	"# ***EVERYONE SHUT UP***\nthis one speaks",
	"Imagine calling me for help haha",
	"e4, e5, Ke2 - that's all you've ever known, so keep at it cabbage-mind",
	"# **GET YOUR HEAD IN THE GAME**",
	"At your stage, giving the queen to your opponent is an opening move.",
	"The more pieces you give to your opponent, the better. This is due to the fact that infiltration is not often taught in chess. Go on, give it a try.",
	"Taking drugs in order to help you play is illegal, but it's a different story if you eject them before the game",
	"If you were a piece, you'd be the knight cowering in the corner after taking the rook. Small, insignificant, and *pathetic*",
	"Good afternoon my good and utter waste of oxygen",
}


-- Command global --
local commands = -- These functions are defined in the modules. The ones without .execute are from the utils module
{
	["\\help"] = help,
	["\\purge"] = purge,
	["\\debug"] = debug_dc, -- Had to rename to debug_discord (abbreviated) in order to avoid name conflict with the debug object
	["\\state-purpose"] = state,
	["\\q"] = q.execute,
	["\\score"] = score.execute,
	["\\matchup"] = matchup.execute,
	["\\stats"] = attributes.execute,
	["\\leaderboard"] = leaderboard.execute,
}

-- Actual bot code -- 
client:on('ready', function()
	log() -- Empty log() calls cause a new line to appear, useful for visuals
	log("STARTUP - Logged in as ".. client.user.username.."\n")
end)

client:on('messageCreate', function(message)
	local cmd = splitArguments(message.content)[1]
	local mentionedUser = message.mentionedUsers:find(function(user)
		return user == client.user
	end)
	if message.content:sub(1, 1) == "\\" then
		if commands[cmd] then
			log("COMMAND DETECTED - executing")
			stats = commands[cmd](message, stats) or stats
		else
			log("IMPROPER COMMAND DETECTED - returning banter message")
			actualReply(message, ("That is not a proper command you absolute pawn\n\n(Use \\help you fool)"))
		end
		log()
	elseif mentionedUser and not message.author.bot then
		log("PING DETECTED - returning randomized banter message")
		actualReply(message, negativeReplies[math.random(#negativeReplies)])
		log()
	end
end)
log("--- RUNNING BOT ---")
client:run('Bot YOUR_TOKEN_HERE')
