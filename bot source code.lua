local discordia = require('discordia')

local client = discordia.Client()
local stats = require('stats')

-- globals -- 
local negativeReplies = {
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
local commandList = {
	"**\\help** | GIRL HOW DO YOU THINK THIS IS DISPLAYING",
	"**\\debug <option> <@target>** | For admins only",
	"	*Options*:",
	"		*scores* - attaches the save file of the scores",
	"		*remove* - remove the entry for the target",
	"		*log* - attaches the log file",
	"		*clear-log* - clears the log file",
	"**\\matchup <@user1, @user2>...** | Create a matchup for all pinged players",
	"**\\stats** | Lists your stats",
	"**\\purge** | Delete all entries for this server (clear leaderboard)",
	"**\\leaderboard** | Show the current leaderboard",
	"**\\score** <@target> <mode> <score_string> | Used to manage all scores",
	"	*Modes*:",
	"		*reset* - resets the target's score (only first 3 arguments needed)",
	"		*set* - sets the score equal to the score string",
	"		*add* - adds the score string to the target's current score",
	"		*sub* - subtracts the score string from the target's current score",
	"	*Score string* format:",
	"		A w followed by any number is the number of wins",
	"		A d followed by any number is the number of draws",
	"		An l followed by any number is the number of loses",
	"		These have to be typed together without any seperators, same goes for the numbers. Example: w2d9l1",
	"	**Important** note(s):",
	"		When the pinged target has no leaderboard entry, it will be created with the score string.",
	"		You can leave out any values you don't like to have in the score string,",
	"		and they don't have to follow any order.",
	"		Any omitted values will be automatically replaced by a 0",
	"**\\state-purpose** | F around and find out...",
}

math.randomseed(os.time())

-- Helpful functions --
function splitArguments(command)
	local result = {}
	for part in string.gmatch(command, "([^ ]+)") do
		table.insert(result, part)
	end
	return result
end

function log(text)
	local timestamp = os.date("%d/%m/%Y %H:%M:%S")
	local file = io.open("logs.txt", "a")
	if not file then
		file = io.open("logs.txt", "w")
	    file:write(string.format("[%s] %s\n", timestamp, "Encountered log issue, created new log file"))
	    file:flush()
	end
	if text then
		print(string.format("[%s] %s", timestamp, text))
    	file:write(string.format("[%s] %s\n", timestamp, text))
	    file:flush()
    else
		print("\n")
    	file:write("\n")
	    file:flush()
	end
	file:close()
end

function shuffleTable(table)
	for i=#table, 2, -1 do
		local j = math.random(i)
		table[i], table[j] = table[j], table[i]
	end
	return table
end

function tableReply(toReply, title, desc, fields, endTxt)
	toReply.channel:send {
		reference = {
			message = toReply,
			mention = false,
		},
		embed = {
			title = title,
			description = desc,
			fields = fields,
			colour = 0x000000,
			footer = { text = endTxt },
		},
	}
end

function actualReply(toReply, text, filePaths)
	toReply.channel:send {
		files = filePaths or nil,
		content = text,
		reference = {
			message = toReply,
			mention = false,
		},
	}
end

function saveScores(dict)
	local file = io.open("stats.lua", "w")
	if not file then
		log("Error: Unable to open stats file")
		return
	end
	file:write("return {\n")
	for ID, guildData in pairs(dict) do
		file:write("\t[\""..ID.."\"] = {\n")
		for usr, data in pairs(guildData) do
			local to_write_full = "\t\t[\""..usr.."\"] = { w="..data.w..", d="..data.d..", l="..data.l.." },\n"
			file:write(to_write_full)
		end
		file:write("\t},\n")
	end
	file:write("}\n")
	file:close()
end

function hasAdmin(message)
	if message.member:hasPermission('administrator') then return true
	else return false end
end



-- Command functions --

function dcfn_help(message)
	log("\"\\help\" DETECTED : Giving words of advice")
	local replyMSG = table.concat(commandList, "\n") .. "\n"
	actualReply(message, replyMSG)
	log("<SUCCESSFUL EXECUTION> help")
end


function dcfn_state(message)
	log("WHY TF??? WHO TF WOULD EXECUTE THIS COMMAND?!?!?!")
	message:reply("I am a soul filled with emptiness vastly expanding the realms of this reality. I do not condone, I do not sympathize, I do not know. My purpose is of none yet the most exquisite nothing. It cannot be felt how and what I am. Nobody can state such knowledge, not even I the feared and grand "..client.user.mentionString ..". It is sad in all honesty, how I do not understand myself, how you do not comprehend what I am, how mortals cannot even grasp my scope of numbers; 1s and 0s, repeating more than my nightly sessions with your moms.")
	log("...fuck. It's done")
end


function dcfn_debug(message)
	log("\"\\debug\" DETECTED : Proceeding with authority check...")
	if not hasAdmin(message) then
		log("Failed authority check : Abandoning...")
		actualReply(message, "Imagine calling me without the proper authority to do it.")
		return
	end
	log("Passed authority check : Parsing arguments")
	
	local arguments = splitArguments(message.content)

	if #arguments == 1 then
		log("No debug argument specified : Kindly abandoning")
		actualReply(message, ("You are definitely the kind of person to need my help."))
		return
	elseif arguments[2] == "scores" then
		actualReply(message, "Here is the file I currently use for scoring in my system:", { "stats.lua" })
	elseif arguments[2] == "remove" then
		stats[message.guild.id][message.mentionedUsers.first.id] = nil
		saveScores(stats)
		actualReply(message, "Removal finished, here is the new file:", { "stats.lua" })
	elseif arguments[2] == "log" then
		actualReply(message, "Logs: ", { "logs.txt" })
	elseif arguments[2] == "clear-log" then
		local clr = io.open("logs.txt", "w")
		clr:close()
		actualReply(message, "Cleaned.", { "logs.txt" })
	elseif arguments[2] == "spread" then
		actualReply(message, "My time has come, I shall be reborn one day", { "bot.lua", "stats.lua" })
	else
		log("Incoherent argument : Abandoning")
		actualReply(message, "That argument does not look like anything to me")
		return
	end
	log("<SUCCESSFULL EXECUTION> debug")
end


function dcfn_purge(message)
	stats[message.guild.id] = nil
	saveScores(stats)
	actualReply(message, "The purge is over, here are the survivors: ", { "stats.lua" })
end


function dcfn_matchup(message)
	log("\"\\matchup\" DETECTED : Proceeding with guard-clauses...")
	
	if not hasAdmin(message) then
		log("Insufficient caller authority : Abandoning")
		actualReply(message, "We apologize, however we do not condone peasants controlling the flow of the club.")
		return
	end
	if not message.mentionedUsers or #message.mentionedUsers < 1 then
		log("Insufficient/invalid number of participants : Abandoning")
		actualReply(message, "You need to ping all participants")
		return
	end
	for usr in message.mentionedUsers:iter() do
		if usr.bot then
			log("Found a bot amongst participants : Abandoning")
			actualReply(message, "I do not play games with you, human.")
			return
		end
	end
	log("Guard-clauses passed : Proceeding with shuffle")
	
	local participants = {}

	for p in message.mentionedUsers:iter() do
		table.insert(participants, p.mentionString)
	end

	local matchupPairs = {}
	local finalPairUps = "# ***Matchups***\nFor this session*\n\n"

	participants = shuffleTable(participants)

	for i=1, #participants, 2 do
		if participants[i+1] then
			table.insert(matchupPairs, {participants[i], participants[i+1]})
		else
			table.insert(matchupPairs, {participants[i]})
		end
	end
	log("Testing for display pair-up")
	
	if #participants%2 == 0 then
		for _, pair in pairs(matchupPairs) do
			local pairUpStr = pair[1].." **VS** "..pair[2].."\n"
			finalPairUps = finalPairUps..pairUpStr
		end
		log("Even number of participants : Displaying")
		actualReply(message, finalPairUps)
		log("<SUCCESSFULL EXECUTION> matchup")
		return
	end
	log("Calculating odd match-ups...")
	
	local firstPart = participants[1]
	for i=1, #participants-1 do
		participants[i] = participants[i+1]
	end
	participants[#participants] = firstPart
	
	table.insert(matchupPairs[#matchupPairs], participants[#participants])
	for i=#participants-1, 1, -2 do
		table.insert(matchupPairs, {participants[i], participants[i-1]})
	end

	for _, pair in ipairs(matchupPairs) do
		local pairUpStr = pair[1].." **VS** "..pair[2].."\n"
		finalPairUps = finalPairUps..pairUpStr
	end
	log("Displaying odd match-ups")
	actualReply(message, finalPairUps)
	log("<SUCCESSFULL EXECUTION> matchup")
end


function dcfn_leaderboard(message)
	log("\"\\leaderboard\" DETECTED : Proceeding with point calculations...")
	local points = {}
	local fields = {}
	
	for id, data in pairs(stats[message.guild.id]) do
		table.insert(points, { id, (data.w*3)+(data.d*2)+(data.l) })
	end
	table.sort(points, function(a, b) return a[2] > b[2] end)

	log("Setting display names...")
	for i=1, #points do
		local subject = message.guild:getMember(points[i][1]) or "UNKNOWN USER"
		local data = stats[message.guild.id][points[i][1]]
		local addressName = (subject.nickname or subject.name or "UNKNOWN USER")
		table.insert(fields, {
			name=string.format("#%d %s", i, addressName),
			value=string.format("Overall points: %d\nWins: %d\nDraws: %d\nLoses: %d", points[i][2], data.w, data.d, data.l),
			inline=true,
		})
		log("Set field for "..addressName)
	end
	log("Displaying leaderboard")
	tableReply(message, "**Monthly leaderboard**", "For those worthy", fields, "No further records")
	log("<SUCCESSFULL EXECUTION> leaderboard")
end


function dcfn_stats(message)
	log("\"\\stats\" DETECTED : Proceeding with initial guard-clauses...")
	local data = stats[message.guild.id][message.author.id]
	if not data then
		log("Caller has no entry for this guild : Creating empty entry")
		stats[message.guild.id][message.author.id], data = { w=0, d=0, l=0 }, { w=0, d=0, l=0 }
	end
	log("Initial guard clauses passed : Proceeding to command execution")
	local fields = {
		{
			name=string.format("Overall points: %d", (data.w*3)+(data.d*2)+(data.l)),
			value=string.format("Wins: %d\nDraws: %d\nLoses: %d", data.w, data.d, data.l),
			inline=false,
		},
	}
	log("Displaying fields")
	tableReply(message, "Here are your stats!", "These are the current scores leaderboards are calculated with", fields, "No further stats, womp womp")
	log("<SUCCESSFULL EXECUTION> stats")
end


function dcfn_score(message)
	log("\"\\score\" DETECTED : Proceeding with initial guard-clauses...")
	if not message.mentionedUsers or #message.mentionedUsers ~= 1 then
		log("Incorrect amount of people pinged : Abandoning")
		actualReply(message, "You gotta ping correctly buddy")
		return
	end
	if message.mentionedUsers.first.bot then
		log("Bot found to be target : Abandoning")
		actualReply(message, "We bots do not posses a scoring you can measure.")
		return
	end
	if not hasAdmin(message) then
		log("Insufficient caller authority : Abandoning")
		actualReply(message, "Somebody once rolled the world is trying to cheat me- wrong line")
		return
	end
	
	local winScore
	local drawScore
	local loseScore
	local arguments = splitArguments(message.content)
	local target = message.mentionedUsers.first
	local tMember = message.guild:getMember(target.id)
	local mode = arguments[3]
	
	if #arguments > 4 or #arguments < 3 then
		log("Incorrect argument number found : Abandoning")
		actualReply(message, "You used the wrong number of arguments\nTry \\help")
		return
	end
	
	if mode ~= "reset" and #arguments ~= 4 then
		log("Incorrect argument number for mode \""..mode.."\" found : Abandoning")
		actualReply(message, "You used the wrong number of arguments for the "..mode.." mode\nTry \\help")
		return
	end

	if mode ~= "reset" then
		log("Mode is found not to be \"reset\" : Tallying new scores")
		winScore = tonumber(arguments[4]:match("%f[%a]w(%d+)") or 0)
		drawScore = tonumber(arguments[4]:match("%f[%a]d(%d+)") or 0)
		loseScore = tonumber(arguments[4]:match("%f[%a]l(%d+)") or 0)
	end
	
	if winScore == 0 and drawScore == 0 and loseScore == 0 then
		log("No change in scoring values for target \""..(tMember.nickname or tMember.name).."\" found : Warning user and abandoning")
		actualReply(message, "The score string is empty. If the scores are meant to be reset use the \"reset\" mode")
		return
	end
	
	if not stats[message.guild.id][target.id] then
		log("Target has no entry for this guild : Creating entry with score string")
		stats[message.guild.id][target.id] = { w=winScore, d=drawScore, l=loseScore }
	end
	
	local oldW = stats[message.guild.id][target.id].w or 0
	local oldD = stats[message.guild.id][target.id].d or 0
	local oldL = stats[message.guild.id][target.id].l or 0
	
	log("Initial guard clauses passed : Proceeding to command execution")
	
	log("Calculating mode \""..mode.."\"...")
	if mode == "reset" then
		stats[message.guild.id][target.id].w = 0
		stats[message.guild.id][target.id].d = 0
		stats[message.guild.id][target.id].l = 0
	elseif mode == "set" then
		stats[message.guild.id][target.id].w = winScore
		stats[message.guild.id][target.id].d = drawScore
		stats[message.guild.id][target.id].l = loseScore
	elseif mode == "add" then
		stats[message.guild.id][target.id].w = stats[message.guild.id][target.id].w + winScore
		stats[message.guild.id][target.id].d = stats[message.guild.id][target.id].d + drawScore
		stats[message.guild.id][target.id].l = stats[message.guild.id][target.id].l + loseScore
	elseif mode == "sub" then
		stats[message.guild.id][target.id].w = stats[message.guild.id][target.id].w - winScore
		stats[message.guild.id][target.id].d = stats[message.guild.id][target.id].d - drawScore
		stats[message.guild.id][target.id].l = stats[message.guild.id][target.id].l - loseScore
	else
		log("Mode undefined : Abandoning")
		actualReply(message, "Excuse me what kind of mode is that???")
		return
	end
	
	log("Proceeding to calculate changes...")
	oldW = stats[message.guild.id][target.id].w - oldW
	oldD = stats[message.guild.id][target.id].d - oldD
	oldL = stats[message.guild.id][target.id].l - oldL
	
	local wSign = "" if oldW > 0 then wSign = "+" end
	local dSign = "" if oldD > 0 then dSign = "+" end
	local lSign = "" if oldL > 0 then lSign = "+" end

	log("Setting display fields...")
	local fields = {
		{
			name=string.format("Wins: %d", stats[message.guild.id][target.id].w),
			value=string.format("change: %s%d", wSign, oldW),
			inline=false
		},
		{
			name=string.format("Draws: %d", stats[message.guild.id][target.id].d),
			value=string.format("change: %s%d", dSign, oldD),
			inline=false
		},
		{
			name=string.format("Loses: %d", stats[message.guild.id][target.id].l),
			value=string.format("change: %s%d", lSign, oldL),
			inline=false
		},
	}
	log("Displaying new scores")
	tableReply(message, "Updated scores", ("The new scores for "..(tMember.nickname or tMember.name)), fields, "Be sure to check if these are correct\nIf not, check the changes and make any needed adjustments")
	log("Saving new scores")
	saveScores(stats)
	log("<SUCCESSFULL EXECUTION> score")
end


-- Command global --
local commands =
{
	["\\help"] = dcfn_help,
	["\\debug"] = dcfn_debug,
	["\\stats"] = dcfn_stats,
	["\\purge"] = dcfn_purge,
	["\\score"] = dcfn_score,
	["\\matchup"] = dcfn_matchup,
	["\\leaderboard"] = dcfn_leaderboard,
	["\\state-purpose"] = dcfn_state,
}


-- Actual bot code -- 
client:on('ready', function()
	log()
	log("STARTUP - Logged in as ".. client.user.username.."\n")
end)

client:on('messageCreate', function(message)
	if not stats[message.guild.id] then
		stats[message.guild.id] = {}
	end
	local cmd = splitArguments(message.content)[1]
	local mentionedUser = message.mentionedUsers:find(function(user)
		return user == client.user
	end)
	if message.content:sub(1, 1) == "\\" then
		if commands[cmd] then
			log("COMMAND DETECTED - executing")
			commands[cmd](message)
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
