-- Function table to return
local fs = {}

function fs.execute(message, stats)
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

	-- Note that the order of these guard clauses is highly sensitive, please be mindful of nils
	if #arguments > 4 or #arguments < 3 then
		log("Incorrect argument number found : Abandoning")
		actualReply(message, "You used the wrong number of arguments\nTry \\help")
		return
	end
	
	if mode ~= "reset" and mode ~= "remove" and #arguments ~= 4 then
		log("Incorrect argument number for mode \""..mode.."\" found : Abandoning")
		actualReply(message, "Your \""..mode.."\" mode failed to work on me\nTry \\help")
		return
	end

	if mode ~= "reset" and mode ~= "remove" then
		log("Mode is found not to be \"reset\" or \"remove\" : Tallying new scores")
		winScore = tonumber(arguments[4]:match("%f[%a]w(%d+)") or 0)
		drawScore = tonumber(arguments[4]:match("%f[%a]d(%d+)") or 0)
		loseScore = tonumber(arguments[4]:match("%f[%a]l(%d+)") or 0)
	end
	
	if winScore == 0 and drawScore == 0 and loseScore == 0 then
		log("No change in scoring values for target \""..(tMember.nickname or tMember.name).."\" found : Warning user and abandoning")
		actualReply(message, "The score string is empty. If the scores are meant to be reset use the \"reset\" mode")
		return
	end
	
	if not stats[message.guild.id] then
		log("No entry found for this guild : Creating empty entry")
		stats[message.guild.id] = {}
	end
	if not stats[message.guild.id][target.id] then
		log("Target has no entry for this guild : Creating entry with score string")
		stats[message.guild.id][target.id] = { w=winScore, d=drawScore, l=loseScore }
	end
	
	local oldW = stats[message.guild.id][target.id].w or 0
	local oldD = stats[message.guild.id][target.id].d or 0
	local oldL = stats[message.guild.id][target.id].l or 0
	
	log("Initial guard clauses passed : Proceeding to command execution")
	
	log("Calculating mode: \""..mode.."\"")
	if mode == "reset" then
		stats[message.guild.id][target.id].w = 0
		stats[message.guild.id][target.id].d = 0
		stats[message.guild.id][target.id].l = 0
	elseif mode == "remove" then
		log("Removal of entry requested : Granting")
		stats[message.guild.id][target.id] = nil
		actualReply(message, "User removed from leaderboard")
		log("<SUCCESSFULL EXECUTION> score")
		return
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
	
	local wSign = ""
	if oldW > 0 then wSign = "+" end
	local dSign = ""
	if oldD > 0 then dSign = "+" end
	local lSign = ""
	if oldL > 0 then lSign = "+" end

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
	tableReply(message, "Updated scores",
	("The new scores for "..(tMember.nickname or tMember.name)), fields,
	"Be sure to check if these are correct\nIf not, check the changes and make any needed adjustments")
	
	log("<SUCCESSFULL EXECUTION> score")
	return saveScores(stats)
end

return fs
