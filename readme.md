## Usage Requirements
 ❗ The addon will only work if you are set to lootmaster and have raid  assist in order to do Raid Warnings.  
 ℹ️ Raid members do not need the addon installed they will just /roll as normal
## Descriptions
#### General:
+1 loot tracking addon for raids. The addon Automatically tracks rolls, and follows normal +1 loot rules. When a winner is determined the win will be recorded on the "Won Items" tab for loot distribution and a +1 will be add to them on the "+1 Table" tab. If the loot roll was uncontested, ie only one person rolled, then there is no +1 applied. The window can be resized by dragging from the bottom right corner.
#### Exclusions:
Currently the following items are excluded from being looted by the Addon to prevent potential untradeable issues:
- 'Intact Vial of Kael'thas Sunstrider'
- 'Intact Vial of Lady Vashj'
- 'Ashes of Al'ar'
- 'Splinter of Atiesh'
- 'Worldforged Key Fragment'
- 'Nether Vortex'
- 'Worldforged Scroll'
#### +1 Table:
The table will be automatically added to if anyone joins the raid group. Users who leave are not removed unless the table is reset. By clicking the "+" or "-" next to a name you can add to their +1 score. These changes will be printed in Raid for transparency. It is possible to print the +1 Table to raid using "/p1 wt" however you will probably be chat limited for spam as each entry is printed as a line in raid chat.
#### Roll Table:
It is possible to see the current Roll Table with "/p1 rt" this will just print it locally. This table is reset for every auction.
#### Won Items:
This tab shows who won what items. Can be useful for logs and loot distribution. Once an item has been distributed click the "-" next to the item to remove it from the table. This table needs to be manually reset for every raid.
#### Options:
- Reset +1 Table
    - Only the +1 Table and Won Items table will need to be reset between raids.
- Populate +1 Table
    - Incase the addon doesn't add someone to the table. When the table is reset it will automatically try to populate based of current raid members.
- Reset Won Items Table
    - Clears the Won Items tab
- Autoloot to Masterlooter
    - Enables the addon to auto loot drops
- Countdown Timer
    - Adjusts the length of the roll timer. Raid Warnings are given at the start of the auction and every multiple of 10 seconds then from 5-1.
- Show Queued Auctions
    - Displays the Queued Auctions window
- Purge Queued Auctions
    - Clears the current queued auctions
- Cancel Current Auction
    - Skips the current auction and continues with the queue
## Slash Commands:
- /p1 roll (Link Item) - Starts/adds to auction queue
- /p1 show - Display GUI
- /p1 rt - View Current Roll Table
- /p1 wt - View Plus One Table
- /p1 add1 playername - To Manually add +1 to someone
- /p1 sub1 playername - To Manually subtract +1 from someone
- /p1 dbwipe - To Wipe Plus One Table -- CAREFUL!! NO RECOVERY!!
- /p1 popdb - After Wiping Table, Populate Table -- CAREFUL!! NO RECOVERY!!
## Macro Utilization:
This Macro can be added to your hotbar. Simply hover your mouse over the item and press the hotkey for it to be added to the auction:

```/run DEFAULT_CHAT_FRAME.editBox:SetText("/p1 roll " .. select(2, GameTooltip:GetItem()));ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)```

## Addon Requirements
### Required Libraries
ℹ️ These are included with the addon package
- AceAddon-3.0
- AceBucket-3.0
- AceComm-3.0
- AceConfig-3.0
- AceConsole-3.0
- AceDB-3.0
- AceDBOptions-3.0
- AceEvent-3.0
- AceGUI-3.0
- AceHook-3.0
- AceLocale-3.0
- AceSerializer-3.0
- AceTab-3.0
- AceTimer-3.0
- CallbackHandler-1.0
- LibDataBroker-1.1
- LibDBIcon-1.0
- LibStub
