local rcount = 0
local rollTable = {}
local auctionList = {}
local lowestWins = math.huge
local lowestWinsPlayer = ""
local highestRoll = 0
local highestRollPlayer = ""
local frame = CreateFrame("Frame")
local f = CreateFrame ("Frame")
local numRaidMembers = GetNumRaidMembers()
local AceGUI = LibStub("AceGUI-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local currentAuction = nil

print("~~~~~~~~~~~~~~~~~~~~~~~~")
print("~~~~~~~~~~~~~~~~~~~~~~~~")
print("~~~~~~~~~PlusOne~~~~~~~~~")
print("/p1 help - PlusOne slash commands")
print("Make sure to Reset the DB for new raids!")
print("~~~~~~~~~~~~~~~~~~~~~~~~")
print("~~~~~~~~~~~~~~~~~~~~~~~~")

frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("LOOT_Opened")
frame:SetScript("OnEvent", function(self, event, ...)
      if (event == "VARIABLES_LOADED") or (event == "PLAYER_LOGIN") then
         if PlusOneDB then
            if PlusOneDB == nil then
               PlusOneDB = {}
               PlusOneDB.wins = {}
               PlusOneDB.slider = 15
               PlusOneDB.textbox = "Trial"
               PlusOneDB.history = {}
               PlusOneDB.autoloot = false
               popDB()
            end
            f:UnregisterEvent("VARIABLES_LOADED")
            f:UnregisterEvent("PLAYER_LOGIN")
         else
            PlusOneDB = {}
            PlusOneDB.wins = {}
            PlusOneDB.slider = 15
            PlusOneDB.textbox = "Trial"
            PlusOneDB.history = {}
            PlusOneDB.autoloot = false
            popDB()
            f:UnregisterEvent("VARIABLES_LOADED")
            f:UnregisterEvent("PLAYER_LOGIN")
         end
      end
      if (event == "CHAT_MSG_SYSTEM") then
         if (not currentAuction) then return end
         local message = ...
         if string.find(message, "rolls") then
            local player, roll = string.match(message, "(%w+) rolls (%d+) %(1%-100%)")
            print(player  .. " rolled " .. roll) 
            if roll and player then
               roll = tonumber(roll)
               if not rollTable[player] then
                  rollTable[player] = roll
               end
            end
         end
      end
      if (event == "LOOT_OPENED") then 
         lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod()
         if PlusOneDB.autoloot then
            if masterlooterPartyID == 0 then
               local playerName = (UnitName("player"))
               local candidateIndex = 1
               local candidateName = GetMasterLootCandidate(candidateIndex)
               while candidateName do
                  if candidateName == playerName then
                     mlPosition = candidateIndex
                     break
                  end
                  candidateIndex = candidateIndex + 1
                  candidateName = GetMasterLootCandidate(candidateIndex)
               end
               for numLoot=1, GetNumLootItems() do
                  if LootSlotIsItem(numLoot) then
                     local tex, item, quantity, quality, isLocked = GetLootSlotInfo(numLoot)
                     local itemName, itemLink = GetItemInfo(GetLootSlotLink(numLoot))
                     local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name = string.find(itemLink,"|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
                     local nonLootListName = {'Intact Vial of Kael\'thas Sunstrider', 'Intact Vial of Lady Vashj', 'Ashes of Al\'ar', 'Splinter of Atiesh', 'Worldforged Key Fragment', 'Nether Vortex'}
                     for k,v in pairs(nonLootListName) do
                        if v == itemName or itemName:match("(Worldforged Scroll:)") then
                           skipAutoLoot=true
                        else
                           skipAutoLoot=false
                        end
                     end
                     if skipAutoLoot == false then
                        GiveMasterLoot(numLoot, mlPosition)
                     end
                  end
               end
            end
         end
      end
end)

frame:SetScript("OnUpdate", function(self, elapsed)
      if (not currentAuction) then return end
      timeRemains = timeRemains - elapsed
      timeOnes = tonumber(string.sub(math.floor(timeRemains),2,2))
      onesec = onesec - elapsed
      if timeRemains <= 0 then
         FinishAuction(currentAuction)
      elseif onesec <= 0 then
         if timeOnes == 0 then
            SendChatMessage("Rolling for "..(currentAuction).." "..(math.floor(timeRemains)).." seconds remaining!", "RAID_WARNING")
         elseif (timeRemains < 5) and (timeRemains > 0) then
            SendChatMessage("Rolling for "..(currentAuction).." "..(math.ceil(timeRemains)).." seconds remaining!", "RAID_WARNING")
         end
         onesec = 1
      end    
end)

frame:RegisterEvent("CHAT_MSG_SYSTEM")

function FinishAuction(currentAuction)
   highestRollPlayer = nil
   highestRoll = 0
   lowestWins = math.huge
   for player, rolls in pairs(rollTable) do
      if PlusOneDB.wins[player] <= lowestWins then
         lowestWins = PlusOneDB.wins[player]
      end
   end
   for player, rolls in pairs(rollTable) do
      if PlusOneDB.wins[player] == lowestWins then
         if highestRollPlayer == nil or player ~= highestRollPlayer then
            if rollTable[player] and rollTable[player] > highestRoll then
               highestRoll = rollTable[player]
               highestRollPlayer = player
            end
         end
      end
   end
   if highestRollPlayer == nil then
      SendChatMessage("No Rolls Detected for "..currentAuction, "RAID_WARNING")
   elseif highestRollPlayer ~= nil then
      rollCount()
      if rcount > 1 then
         PlusOneDB.wins[highestRollPlayer] = PlusOneDB.wins[highestRollPlayer] + 1
         SendChatMessage("Winner: " .. highestRollPlayer .. " with a roll of " .. highestRoll, "RAID_WARNING")
         tab:SelectTab("tab1")
      else
         SendChatMessage("Winner: " .. highestRollPlayer .. ", Uncontested", "RAID_WARNING")
      end
      if not PlusOneDB.history[highestRollPlayer] then
         PlusOneDB.history[highestRollPlayer] = {}
      end
      tinsert(PlusOneDB.history[highestRollPlayer],currentAuction)
   end
   QueueWait()
end

function QueueWait()
   currentAuction = nil
   Timer.After(2,function()
         if auctionList[1] then
            print("Waiting between rolls")
            SendChatMessage("~~~~~~~~~NEXT ROLL~~~~~~~~~~", "RAID_WARNING")
            AuctionOffItem(unpack(auctionList[1]))
            tremove(auctionList,1)
			auctionQueue()
         else
            print("Queue is empty")
         end      
   end)
end

function QueueAuction(item)
   if not currentAuction then
      AuctionOffItem(item)
   else 
      tinsert(auctionList,{item})
	  auctionQueue()
   end
end

function removeQueue(jk)
   tremove(auctionList,jk)
   auctionQueue()
end

function purgeQueue()
	auctionList = {}
	auctionQueue()
end

function cancelAuction()
   SendChatMessage("Auction Cancelled","RAID_WARNING")
   QueueWait()
end

function AuctionOffItem(item)
   if (currentAuction) then return end
   rollTable = {}
   timeRemains = PlusOneDB.slider
   SendChatMessage(("Rolling now for %s. Ends in "..timeRemains.." seconds!"):format(item),"RAID_WARNING")
   currentAuction = item
   onesec = 1
end

function printPlusOneDB()
   table.sort(PlusOneDB.wins, function(k, v) return k < v end)
   SendChatMessage("~~~~~~~ Current +1s ~~~~~~~", "RAID")
   for k, v in pairs(PlusOneDB.wins) do
      SendChatMessage(k .. ": " .. v, "RAID")
   end
   SendChatMessage("~~~~~~~~~~~~~~~~~~~~~~~~", "RAID")
end

function dbwipe()
   PlusOneDB.wins = {}
   SendChatMessage("~~~~~~~~~~~~~~~~~~~~~~~~", "RAID")
   SendChatMessage("~~ +1 Table has been RESET ~~", "RAID")
   SendChatMessage("~~~~~~~~~~~~~~~~~~~~~~~~", "RAID")
   print("~~ +1 Table has been RESET ~~")
   popDB()
end

function wipeItems()
   PlusOneDB.history = {}
   SendChatMessage("~~~~~~~~~~~~~~~~~~~~~~~~", "RAID")
   SendChatMessage("~~ Won Items Table has been RESET ~~", "RAID")
   SendChatMessage("~~~~~~~~~~~~~~~~~~~~~~~~", "RAID")
end

function popDB()
   for i = 1, GetNumGroupMembers() do
      local name, _ = GetRaidRosterInfo(i)
      if PlusOneDB.wins == nil then
         PlusOneDB.wins = {}
      end
      if not PlusOneDB.wins[name] then
         PlusOneDB.wins[name] = 0
      end      
   end
   tab:SelectTab("tab1")
end

function show()
   aframe:Show()
   bframe:Show()
   tab:SelectTab("tab1")
   auctionQueue()
end

function add1(msg)
   SendChatMessage("~~~ Adding +1 to " .. msg .. " ~~~", "RAID")
   if not PlusOneDB.wins[msg] then
      PlusOneDB.wins[msg] = 1
   else
      PlusOneDB.wins[msg] = PlusOneDB.wins[msg] + 1
   end
   tab:SelectTab("tab1")
   SendChatMessage("~~~ Current +1 for " .. msg .. " ~~~", "RAID")
   SendChatMessage(msg .. ": " .. PlusOneDB.wins[msg], "RAID")
end

function sub1(msg)
   SendChatMessage("~~~ Subtracting -1 from " .. msg .. " ~~~", "RAID")
   if not PlusOneDB.wins[msg] then
      PlusOneDB.wins[msg] = 0
   else
      PlusOneDB.wins[msg] = PlusOneDB.wins[msg] - 1
   end
   tab:SelectTab("tab1")
   SendChatMessage("~~~ Current +1 for " .. msg .. " ~~~", "RAID")
   
   SendChatMessage(msg .. ": " .. PlusOneDB.wins[msg], "RAID")
   SendChatMessage("~~~~~~~~~~~~~~~~~~~~~~~~", "RAID")
end

function del1(n,t)
   if PlusOneDB.history[n] then
      for i, v in ipairs(PlusOneDB.history[n]) do
         if (v == t) then
            tremove(PlusOneDB.history[n],i)
         end
      end
   end
   tab:SelectTab("tab2")
end

function rollCount()
   rcount = 0
   for k,v in pairs(rollTable) do
      rcount = rcount + 1
   end
end

function PlayerIsML(playerName, invert)
   for raidID = (invert and GetNumRaidMembers() or 1), (invert and 1 or GetNumRaidMembers()), (invert and -1 or 1) do
      local name, _, isML = GetRaidRosterInfo(raidID)
      if (name == playerName) then
         return isML
      end
   end
end

f:RegisterEvent("RAID_ROSTER_UPDATE")
f:SetScript("OnEvent", function(self, event, ...)
      if event == "RAID_ROSTER_UPDATE" then
         lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod()
         local numRaidMembers = GetNumRaidMembers()
         for i = 1, numRaidMembers do
            local name, _ = GetRaidRosterInfo(i)
            if not PlusOneDB.wins[name] then
               PlusOneDB.wins[name] = 0
            end  
         end
      end
end)

local function DrawGroup1(container)
   local scroll = AceGUI:Create("ScrollFrame")
   scroll:SetLayout("List")
   scroll:SetFullHeight(true)
   scroll:SetFullWidth(true)
   a = {}
   for n in pairs(PlusOneDB.wins) do table.insert(a, n) end
   table.sort(a)
   for i,n in ipairs(a) do
      local row = AceGUI:Create("SimpleGroup")
      row:SetLayout("Flow")
      local label = AceGUI:Create("Label")
      label:SetText(n .. ": " .. PlusOneDB.wins[n])
      local upbtn = AceGUI:Create("Button")
      upbtn:SetWidth(40)
      upbtn:SetText("+")
      upbtn:SetCallback("OnClick", function() add1(n) end)
      local dnbtn = AceGUI:Create("Button")
      dnbtn:SetWidth(40)
      dnbtn:SetText("-")
      dnbtn:SetCallback("OnClick", function() sub1(n) end)
      row:AddChild(label)
      row:AddChild(upbtn)
      row:AddChild(dnbtn)
      scroll:AddChild(row)
   end
   container:AddChild(scroll)
end

-- function that draws the widgets for the second tab
local function DrawGroup2(container)
   local scroll = AceGUI:Create("ScrollFrame")
   scroll:SetLayout("List")
   scroll:SetFullHeight(true)
   scroll:SetFullWidth(true)
   b = {}
   for n in pairs(PlusOneDB.history) do table.insert(b, n) end
   table.sort(b)
   for i,n in ipairs(b) do
      for i,t in pairs(PlusOneDB.history[n]) do
         local row = AceGUI:Create("SimpleGroup")
         row:SetLayout("Flow")
         local label = AceGUI:Create("Label")
         label:SetText(n .. ": " .. t)
         local dnbtn = AceGUI:Create("Button")
         dnbtn:SetWidth(35)
         dnbtn:SetText("-")
         dnbtn:SetCallback("OnClick", function() del1(n,t) end)
         row:AddChild(label)
         row:AddChild(dnbtn)
         scroll:AddChild(row)
      end
   end
   container:AddChild(scroll)
end

local function DrawGroup3(container)
   local desc = AceGUI:Create("Heading")
   desc:SetText("Make Sure to Reset +1 Table and Won Items Table between raids")
   desc:SetFullWidth(true)
   container:SetLayout("Flow")
   container:AddChild(desc)
   
   local button = AceGUI:Create("Button")
   button:SetText("Reset +1 Table")
   button:SetWidth(200)
   button:SetCallback("OnClick", function() StaticPopup_Show("CONFIRM_RESET") end)
   container:AddChild(button)
   
   local button = AceGUI:Create("Button")
   button:SetText("Populate +1 Table")
   button:SetWidth(200)
   button:SetCallback("OnClick", function() popDB() end)
   container:AddChild(button)
   
   local button = AceGUI:Create("Button")
   button:SetText("Reset Won Items Table")
   button:SetWidth(200)
   button:SetCallback("OnClick", function() wipeItems() end)
   container:AddChild(button)
   
   local checkbox = AceGUI:Create("CheckBox")
   checkbox:SetLabel("Autoloot to Masterlooter")
   checkbox:SetType("checkbox")
   checkbox:SetValue(PlusOneDB.autoloot)
   checkbox:SetCallback("OnValueChanged",(function(info,value) PlusOneDB.autoloot = checkbox:GetValue() end))
   container:AddChild(checkbox)
   
   local desc2 = AceGUI:Create("Heading")
   desc2:SetText("Auction Functions")
   desc2:SetFullWidth(true)
   container:SetLayout("Flow")
   container:AddChild(desc2)
   
   local slider = AceGUI:Create("Slider")
   slider:SetLabel("Auction Countdown Timer")
   slider:SetSliderValues(5,60,1)
   slider:SetValue(PlusOneDB.slider)
   slider:SetCallback("OnValueChanged",(function(info,value) PlusOneDB.slider = slider:GetValue() end))
   container:AddChild(slider)
   
   local button3 = AceGUI:Create("Button")
   button3:SetText("Show Queued Auctions")
   button3:SetWidth(200)
   button3:SetCallback("OnClick", function() bframe:Show() end)
   container:AddChild(button3)
   
   local button4 = AceGUI:Create("Button")
   button4:SetText("Purge Queued Auctions")
   button4:SetWidth(200)
   button4:SetCallback("OnClick", function() purgeQueue() end)
   container:AddChild(button4)
   
   local button5 = AceGUI:Create("Button")
   button5:SetText("Cancel Current Auction")
   button5:SetWidth(200)
   button5:SetCallback("OnClick", function() cancelAuction() end)
   container:AddChild(button5)
   
   --local textbox1 = AceGUI:Create("EditBox")
   --textbox1:SetLabel("Limited Rank")
   --textbox1:SetText(PlusOneDB.textbox)
   --textbox1:SetCallback("OnEnterPressed",(function(info,text) PlusOneDB.textbox = textbox1:GetText() end))
   --container:AddChild(textbox1)
   
end


-- Callback function for OnGroupSelected
local function SelectGroup(container, event, group)
   container:ReleaseChildren()
   if group == "tab1" then
      DrawGroup1(container)
   elseif group == "tab2" then
      DrawGroup2(container)
   elseif group == "tab3" then
      DrawGroup3(container)
   end
end

-- Create the frame container
aframe = AceGUI:Create("Frame")
aframe:SetTitle("PlusOneDB")
aframe:SetCallback("OnClose", function(widget) aframe:Hide() end)
aframe:SetLayout("Fill")
aframe:Hide()

-- Create the TabGroup
tab =  AceGUI:Create("TabGroup")
tab:SetLayout("Flow")
tab:SetTabs({{text="+1 Table", value="tab1"}, {text="Won Items", value="tab2"}, {text="Options", value="tab3"}})
tab:SetCallback("OnGroupSelected", SelectGroup)
tab:SelectTab("tab1")
aframe:AddChild(tab)

StaticPopupDialogs["CONFIRM_RESET"] = {
   text = "Are you sure you want to reset the +1 table? THIS CANNOT BE UNDONE!!!",
   button1 = "Yes",
   button2 = "No",
   OnAccept = function()
      dbwipe()
   end,
   timeout = 0,
   whileDead = true,
   hideOnEscape = true,
   preferredIndex = 3, 
}

bframe = AceGUI:Create("Frame")
bframe:SetTitle("Queued Auctions")
bframe:SetCallback("OnClose", function(widget) bframe:Hide() end)
bframe:SetLayout("Fill")
bframe:SetWidth(400)
bframe:SetPoint("LEFT", content, 1000,100)
bframe:Hide()

function auctionQueue()
	bframe:ReleaseChildren()
	scrollcontainer = AceGUI:Create("SimpleGroup")
	scrollcontainer:SetFullWidth(true)
	scrollcontainer:SetFullHeight(true)
	scrollcontainer:SetLayout("Fill")
	bframe:AddChild(scrollcontainer)
	scroll = AceGUI:Create("ScrollFrame")
	scroll:SetLayout("List")
	scrollcontainer:AddChild(scroll)
	if auctionList[1] then
		for k,v in pairs(auctionList) do
			local row = AceGUI:Create("SimpleGroup")
			row:SetLayout("Flow")
			local label = AceGUI:Create("Label")
			label:SetText(unpack(auctionList[k]))
			local btn = AceGUI:Create("Button")
			btn:SetWidth(40)
			btn:SetText("-")
			btn:SetCallback("OnClick", function() removeQueue(k) end)
			row:AddChild(label)
			row:AddChild(btn)
			scroll:AddChild(row)
		end
	end
end

local button = LDB:NewDataObject("PlusOne", {
      type = "data source",
      icon = "Interface\\Icons\\inv_misc_book_11", -- specify an icon for the button
      OnClick = function(_, msg)
         if msg == "LeftButton" then
            show()
         end
      end,
      OnTooltipShow = function(tooltip)
         tooltip:AddLine("|CFFFFFFFFPlusOne")
         tooltip:AddLine("Left-click to show the PlusOne GUI.")
      end,
})

frame:RegisterEvent("CHAT_MSG_RAID_LEADER")
frame:RegisterEvent("CHAT_MSG_RAID_WARNING")
frame:RegisterEvent("CHAT_MSG_RAID")

-- Register the minimap button
LibStub("LibDBIcon-1.0"):Register("PlusOne", button)
SLASH_P11 = "/p1"
SlashCmdList["P1"] = function(input)
   local cmd, link = input:match("(%S+)%s+(|c........|Hitem:.+|r)")
   if (cmd and cmd == "roll") and link then
      if PlayerIsML((UnitName("player")),true) then
         for itemLink in string.gmatch(link, "|c........|Hitem:.-|r") do
            QueueAuction(itemLink)
         end
      else
         print(L["Cannot start roll without Master Looter privileges."])
      end
   elseif input:lower() == "rt" then
      for k, v in pairs(rollTable) do
         print(k,v)
      end
   elseif input:lower() == "wt" then
      printPlusOneDB()
   elseif input:lower() == "dbwipe" then
      dbwipe()
   elseif input:lower() == "popdb" then
      popDB()
   elseif input:lower() == "add1" then
      add1(msg)
   elseif input:lower() == "sub1" then
      sub1(msg)
   elseif input:lower() == "show" then
      show()
   else
      print("~~~~~~~~~~~~~~~~~~~~~~~~")
      print("/p1 roll (Link Item) - Starts/adds to auction queue")
      print("/p1 show - Display GUI")
      print("/p1 rt - View Current Roll Table")
      print("/p1 wt - View Plus One Table")
      print("/p1 add1 playername - To Manually add +1 to someone")
      print("/p1 sub1 playername - To Manually subtract +1 from someone")
      print("~~~~~~~~~~~~~~~~~~~~~~~~")
      print("/p1 dbwipe - To Wipe Plus One Table -- CAREFUL!! NO RECOVERY!!")
      print("/p1 popdb - After Wiping Table, Populate Table -- CAREFUL!! NO RECOVERY!!")
      print("~~~~~~~~~~~~~~~~~~~~~~~~")
   end
end