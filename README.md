# Chesy (v1.1C)

This is a discord bot made in lua to manage small scale chess tournaments and clubs. 

**You will need to run this bot on your own and provide the server/hardware for it.**
# Installation and setup
First, you need to set up a new application on [discord's developer page](https://discord.com/developers/).
Once done, set the permissions for the bot and make sure to enable "SERVER MEMBERS" and "MESSAGE CONTENT" intents as the bot will not work without.

On the **bot** page (where you enabled the intents) you need to press "reset token" and copy the new token.

Now, [download](https://github.com/Kniffler/Chesy/releases) the source code and extract it, make sure  ```stats.lua```, ```bot.lua```, ```channelLinks.lua```, and ```modules``` are in the same directory (folder).
You will now need to edit **the last line** in the ```bot.lua``` and replace YOUR_TOKEN_HERE with the token you have just copied from discord's website.

After that you will need to install lit, luvi, and luvit - which all can be obtained from following the installation on [this](https://github.com/luvit/lit) page.
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
(./)luvit bot.lua
```
If you renamed the source code file, replace ```bot.lua``` with the new filename.
# Running and tuning the bot
If you want to use different algorithms for match-ups or would like add/remove/mod any command hop onto the [discordia wiki](https://github.com/SinisterRectus/Discordia/wiki) to find out what tools are available for doing so.
> [!WARNING]
Make sure that when you change the system used for scoring players, that the saveScore function is tuned accordingly as the current file format may not support your changes.
## Structure and outline
The code has been revised in patch v1.0E, all functions are defined as their custom module in the ```modules``` folder. If you wish to add one, make a new ```yourFunction.lua``` file there and import it in ```bot.lua``` then add it to the _commands_ table along with it's respective call name (e.g. \help, \yourFunction etc.)
> [!NOTE]
In the code you will find that it says "\\\\help" instead of "\\help" as "\\" is an escape character and can cause errors if not used twice. Make sure to put "\\\\yourFunction" into the table

There are further functions to assist you when you make a command, these can be found in ```modules/util_commands.lua``` along with commentry to help you.
# Quick note
This documentation is by no means thorough or exhaustive (fancy word) if you don't know how to do something go on to the [discordia wiki](https://github.com/SinisterRectus/Discordia/wiki). But be mindful that this is merely a project I have made for fun, I am not responsible for any issues you might have or misusages of this project.

# Changelogs
- Removed all those uneeded functions from util_commands.lua
- Removed all those log commands
- Remade matching algorithm.
    It can now handle uneven as well as even amounts of players without resorting to multiples of 2.
- Donuts
