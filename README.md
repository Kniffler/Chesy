# Chesy
This is a discord bot made in lua to manage small scale chess tournaments and clubs. 

**You will need to run this bot on your own and provide the server/hardware for it.**
# Installation
Download the source code and extract it, make sure the stats.lua file is in the same directory (folder) as the source code file.
After that you will need to install lit, luvi, and luvit. Which all can be found on [this](https://github.com/luvit) page along with installation guides.
> [!IMPORTANT]
Make sure to install lit, luvi, and luvit to the same folder that you put the source code into.

Finally, you will need to install [discordia](https://github.com/SinisterRectus/Discordia) to the same directory, this can be done using the lit executable:
```
lit install SinisterRectus/discordia
```
> [!NOTE]
Be sure to prepend ```lit``` with a ```./``` when using linux

To run the bot, simply type
```
(./)luvit source_code.lua
```
If you renamed the source code file, replace ```source_code.lua``` with the new filename.
# Running and tuning the bot
If you want to use different algorithms for match-ups or would like add/remove/mod any command hop onto the [discordia wiki](https://github.com/SinisterRectus/Discordia/wiki) to find out what tools are available for doing so.
> [!WARNING]
Make sure that when you change the system used for scoring players, that the saveScore function is tuned accordingly as the current file format may not support your changes.
