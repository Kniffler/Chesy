-- Initialize randomness here because I am not smart enough to know where else to put it
math.randomseed(os.time())

local commandList = { -- Sorted as table for readability
	"**\\help** | GIRL HOW DO YOU THINK THIS IS DISPLAYING",
	"**\\debug <option> <@target>** | For admins only",
	"	*Options*:",
	"		*scores* - attaches the save file of the scores",
	"		*log* - attaches the log file",
	"		*remove* - remove the entry for target",
	"		*clear-log* - clears the log file",
	"**\\matchup <optional: GPP> <@user1, @user2>...** | Create a matchup for all pinged players",
	"	*GPP* - games per person",
	"		> The number of times each person will play",
	"		Default for this option is 1, please note that for uneven amounts",
	"		of participants (the pinged players) this number is required to be even",
	"		in order to keep the playing field fair",
	"**\\stats** | Lists your stats",
	"**\\purge** | Delete all entries for this server (clear leaderboard)",
	"**\\leaderboard** | Show the current leaderboard",
	"**\\score** <@target> <mode> <score_string> | Used to manage all scores",
	"	*Modes*:",
	"		*reset* - resets the target's score (only first 3 arguments needed)",
	"		*remove* - similar to reset, only it removes the entry instead of setting it to 0",
	"			This option is the equivalent of \\debug remove @target",
	"		*set* - sets the score equal to the score string",
	"		*add* - adds the score string to the target's current score",
	"		*sub* - subtracts the score string from the target's current score",
	"	*Score string* format:",
	"		A w followed by any number is the number of wins",
	"		A d followed by any number is the number of draws",
	"		An l followed by any number is the number of loses",
	"		These have to be typed together without any seperators,",
	"		same goes for the numbers. Example: w2d9l1",
	"	**Important** note(s):",
	"		When the pinged target has no leaderboard entry, an empty",
	"		entry will be created.",
	"		You can leave out any values you don't like to have in the score string,",
	"		and they don't have to follow any order.",
	"		Any omitted values will be automatically replaced by a 0",
	"**\\state-purpose** | F around and find out...",
}

-- Helpful functions --
function splitArguments(command)
	local result = {}
	for part in string.gmatch(command, "([^%s]+)") do -- No idea how, but this pattern sorts things by space
		table.insert(result, part)
	end
	return result
end

function log(text) -- Self explanatory
	-- It is worth noting that many of these functions are vastly empty in-terms
	-- of comments as the log commands sprinkled throughout will substitude for an explanation.
	local timestamp = os.date("%d/%m/%Y %H:%M:%S") -- Another fancy pattern
	local file = io.open("logs.txt", "a")
	if not file then
		file = io.open("logs.txt", "w")
	    file:write(string.format("[%s] %s\n", timestamp, "Encountered a log issue, created new log file"))
	    print(string.format("[%s] %s\n", timestamp, "Encountered a log issue, created new log file"))
	    file:flush()
	end
	if text then
		print(string.format("[%s] %s", timestamp, text)) -- Utilizing timestamps for precise debugging
    	file:write(string.format("[%s] %s\n", timestamp, text))
	    file:flush()
    else
		print("\n")
    	file:write("\n")
	    file:flush()
	end
	file:close()
end

function makeKey(id1, id2)
	return ((id1 < id2) and (id1 .. "_" .. id2)) or (id2 .. "_" .. id1)
end

function shuffleTable(table)
	for i=#table, 2, -1 do
		local j = math.random(i)
		table[i], table[j] = table[j], table[i]
	end
	return table
end

function tableReply(toReply, title, desc, fields, endTxt)
	-- Define a new discord table object in the reply using custom properties and previously defined fields
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
	-- Actually reply to the message containing the command as FOR SOME
	-- GOD UNKNOWN REASON DISCORDIA DOESN'T DO THIS AUTOMATICALLY
	toReply.channel:send {
		files = filePaths or nil,
		content = text,
		reference = {
			message = toReply,
			mention = false,
		},
	}
end

function saveScores(dict) -- Save the user attributes (scores) to the stats file.
	local file = io.open("stats.lua", "w")
	if not file then
		log("Error: Unable to open stats file")
		return
	end
	file:write("return {\n")
	for ID, guildData in pairs(dict) do -- This code is very dense, bear with me
		file:write("\t[\""..ID.."\"] = {\n")
		for usr, data in pairs(guildData) do
			local to_write_full = "\t\t[\""..usr.."\"] = { w="..data.w..", d="..data.d..", l="..data.l.." },\n"
			file:write(to_write_full)
		end
		file:write("\t},\n")
	end
	file:write("}\n")
	file:close()
	return dict
end

function saveChannels(links)
	local file = io.open("channelLinks.lua", "w")
	file:write("return {\n")
	for guild, linkage in pairs(links) do
		file:write("\t[\""..guild.."\"] = {\n")
		if not linkage then goto continue end
		for origin, control in pairs(linkage) do
			local writerP1 = "\t\t[\""..origin.."\"]=\""..control.."\","
			file:write(writerP1.."\n")
		end
		file:write("\t},\n")
		::continue::
	end
	file:write("}\n")
	file:close()
end

function hasAdmin(message) -- Simple admin check for higher access commands
	if message.member:hasPermission('administrator') then return true end
	return false
end

-- Actual commands

function help(message, stats)
	log("\"\\help\" DETECTED : Giving words of advice")
	local replyMSG = table.concat(commandList, "\n") .. "\n"
	actualReply(message, replyMSG)
	log("<SUCCESSFUL EXECUTION> help")
end


function state(message, stats)
	log("WHY TF??? WHO TF WOULD EXECUTE THIS COMMAND?!?!?!")
	-- Note that you will find several of these highly informal and rude messages here, the reason for this is because I think it's funny
	message:reply("I am a soul filled with emptiness vastly expanding the realms of this reality. I do not condone, I do not sympathize, I do not know. My purpose is of none yet the most exquisite nothing. It cannot be felt how and what I am. Nobody can state such knowledge, not even I the feared and grand "..client.user.mentionString ..". It is sad in all honesty, how I do not understand myself, how you do not comprehend what I am, how mortals cannot even grasp my scope of numbers; 1s and 0s, repeating more than my nightly sessions with your moms.")
	log("...fuck it - It's done")
end

function debug_dc(message, stats) -- Avoiding reference errors with the standard debug object

	-- This function may be edited freely for any additions you may have made to the bot
	log("\"\\debug\" DETECTED : Proceeding with authority check...")
	if not hasAdmin(message) then
		log("Failed authority check : Abandoning")
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
	elseif arguments[2] == "links" then
		actualReply(message, "Here are my channel links:", { "channelLinks.lua" })
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


function purge(message, stats) -- Completely erase the entire guilds scores
	if not hasAdmin(message) then -- HOLY HELL I DIDN'T EVEN HAVE THIS CHECK HERE UNTIL 1.0E
		log("Purging authority check failed : Abandoning")
		actualReply(message, "I SHALL PURGE YOU, LITTLE PAWN'S BRAIN")
		return
	end -- Shit I needa be more careful
	stats[message.guild.id] = nil
	saveScores(stats)
	actualReply(message, "The purge is over, here are the survivors: ", { "stats.lua" })
end
