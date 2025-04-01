-- Function table to return
local fs = {}

function fs.execute(message, stats)
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

return fs
