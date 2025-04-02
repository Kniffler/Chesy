-- Modules and global objects
local discordia = require('discordia')

local client = discordia.Client()
local stats = require('stats')
local channelLinks = require('channelLinks')

require('modules/util_commands') -- Define the utils globally FIRST so to avoid conflictions, DO NOT CHANGE THIS PLACEMENT
local score = require('modules/score') -- The order of this and the following modules may be changed
local leaderboard = require('modules/leaderboard')
local matchup = require('modules/matchup')
local attributes = require('modules/attributes')
local q = require('modules/q')


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
	--["\\q"] = q.execute, -- At the top to minimize risk of discovery
	["\\help"] = help,
	["\\purge"] = purge,
	["\\debug"] = debug_dc, -- Had to rename to debug_discord (abbreviated) in order to avoid name conflict with the debug object
	["\\state-purpose"] = state,
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
client:on('reactionAddAny', function(channel, messageID, hash, userID)
	if channelLinks and channelLinks[channel:getLastMessage().guild.id] and channelLinks[channel:getMessage(messageID).guild.id][channel.id.."c"] then
		local actualID = splitArguments(channel:getMessage(messageID).content)[1]
		client:getGuild(channel:getMessage(messageID).guild.id):getChannel(channelLinks[channel:getMessage(messageID).guild.id][channel.id.."c"]):getMessage(actualID):addReaction(hash)
		log("ReactionAdd impersonation finished")
	end
end)
client:on('reactionRemoveAny', function(channel, messageID, hash, userID)
	if channelLinks and channelLinks[channel:getLastMessage().guild.id] and channelLinks[channel:getMessage(messageID).guild.id][channel.id.."c"] then
		local actualID = splitArguments(channel:getMessage(messageID).content)[1]
		client:getGuild(channel:getMessage(messageID).guild.id):getChannel(channelLinks[channel:getMessage(messageID).guild.id][channel.id.."c"]):getMessage(actualID):removeReaction(hash)
		log("ReactionRemove impersonation finished")
	end
end)
client:on('messageCreate', function(message)
	if message.author.bot then return end
	
	local cmd = splitArguments(message.content)[1]
	local mentionedUser = message.mentionedUsers:find(function(user)
		return user == client.user
	end)
	local replyAuthor = false
	if message.referencedMessage and message.referencedMessage.author.id == client.user.id then
		replyAuthor = true
	end
	if message.content:sub(1, 1) == "\\" then
		if commands[cmd] then
			log("COMMAND DETECTED - executing")
			stats = commands[cmd](message, stats) or stats
		elseif cmd == "\\q" then
			channelLinks = q.execute(message)
		else
			log("IMPROPER COMMAND DETECTED - returning banter message")
			actualReply(message, ("That is not a proper command you absolute pawn\n\n(Use \\help you fool)"))
		end
		log()
	elseif not (channelLinks and channelLinks[message.guild.id] and channelLinks[message.guild.id][message.channel.id.."c"]) and mentionedUser and not replyAuthor then
		log("PING DETECTED - returning randomized banter message")
		actualReply(message, negativeReplies[math.random(#negativeReplies)])
		log()
	end
	if channelLinks and channelLinks[message.guild.id] and channelLinks[message.guild.id][message.channel.id.."o"] then
		local newContent = message.id.."\n``"..(message.member.nickname or message.member.name).." | Reply: \""..(message.referencedMessage and message.referencedMessage.content or "<NOT A REPLY>").."\"``\n"..message.content.."\n*** ***"
		
		message.guild:getChannel(channelLinks[message.guild.id][message.channel.id.."o"]):send {
			content = newContent,
		}
	elseif channelLinks and channelLinks[message.guild.id] and channelLinks[message.guild.id][message.channel.id.."c"] then
		local refer = nil
		if message.referencedMessage then
			refer = { message = splitArguments(message.referencedMessage.content)[1], mention = false }
		end
		message.guild:getChannel(channelLinks[message.guild.id][message.channel.id.."c"]):send {
			content = message.content,
			reference = refer,
		}
		log("Impersonated as Chesy: "..message.content)
	end
end)
log("--- RUNNING BOT ---")
client:run('Bot YOUR_TOKEN_HERE')
