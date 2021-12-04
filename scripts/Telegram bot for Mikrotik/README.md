# Telegram bot for Mikrotik

Scripts to work with Telegram.

## To use scripts:

1. Unpack .rsc file and import it to router, you should see next scripts in **System->Scripts**:
**func_fetch** – wrapper for **/tool fetch**</br>
**tg_config** – config</br>
**tg_getUpdates** – check Telegram for updates and run command scripts</br>
**tg_sendMessage** – send message to Telegram</br>
**tg_cmd_hi** – example of **/hi** command</br>
**tg_cmd_health** – example of **/health** command</br>

2. Fill **tg_config** script with your data. If you don't know how create bot in Telegram or how get id of bot, your own Telegram id or HTTP API token - I will prepare short instruction in English.

3. Send test commands to your bot (**/hi** or **/health**) and check if script works running in terminal few times command:

```
/system script run tg_getUpdates
```
</br>

If you got replies in Telegram - just enable correspondent Telegram task in System->Scheduler.</br>
To send messages to Telegram just call **tg_sendMessage** function, for example:</br>
```
:local send [:parse [/system script get tg_sendMessage source]]
...
$send text=(“Hi!”)
$send text=(“How are you?”)
```
</br>
In the case if none destination chat set messages will be sent into the default chat (set in the tg_config).</br>
To add your own commands to bot just add new command to bot (/setcommands in @BotFather ) and create script named
tg_cmd_*command*.
</br>
As example see /hi and /health bot commands (scripts tg_cmd_hi and tg_cmd_health).</br>
</br>
More information can be read here:</br>
https://www.coders.in.ua/2017/12/05/telegram-bot-mikrotik/</br>
https://forum.mikrotik.com/viewtopic.php?f=9&t=128394</br>
</br>
PS: but one thing should be kept in mind - annoying logging of /tool fetch command to Log which can't be switched off ^(</br>
It is not problem if you call fetch few times in the day but problem if every minute (checking updates from Telegram) - log is filled by dummy and useless information ^(</br>
It is the reason why Telegram task in Scheduler disabled by default.</br>
But even in this case tg_sendMessage command can be very useful - to send notification to Telegram when something happens on router (new pptp session established, new Wi-Fi user connected or somebody logged to router).</br>

