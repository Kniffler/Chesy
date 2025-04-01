-- Function table to return
local fs = {}

function fs.execute(message, stats)
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

return fs
