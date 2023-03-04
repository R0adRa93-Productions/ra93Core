ra93Core.Players = {}
ra93Core.Player = {}

-- On player login get their data or set defaults
-- Don't touch any of this unless you know what you are doing
-- Will cause major issues!

function ra93Core.Player.Login(source, citizenid, newData)
 if source and source ~= '' then
  if citizenid then
   local license = ra93Core.functions.GetIdentifier(source, 'license')
   local PlayerData = MySQL.prepare.await('SELECT * FROM players where citizenid = ?', { citizenid })
   if PlayerData and license == PlayerData.license then
    PlayerData.money = json.decode(PlayerData.money)
    PlayerData.job = json.decode(PlayerData.job)
    PlayerData.position = json.decode(PlayerData.position)
    PlayerData.metadata = json.decode(PlayerData.metadata)
    PlayerData.charinfo = json.decode(PlayerData.charinfo)
    if PlayerData.gang then
     PlayerData.gang = json.decode(PlayerData.gang)
    else
     PlayerData.gang = {}
    end
    ra93Core.Player.CheckPlayerData(source, PlayerData)
   else
    DropPlayer(source, Lang:t("info.exploit_dropped"))
    TriggerEvent('qb-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white', GetPlayerName(source) .. ' Has Been Dropped For Character Joining Exploit', false)
   end
  else
   ra93Core.Player.CheckPlayerData(source, newData)
  end
  return true
 else
  ra93Core.ShowError(GetCurrentResourceName(), 'ERROR ra93Core.PLAYER.LOGIN - NO SOURCE GIVEN!')
  return false
 end
end

function ra93Core.Player.GetOfflinePlayer(citizenid)
 if citizenid then
  local PlayerData = MySQL.Sync.prepare('SELECT * FROM players where citizenid = ?', {citizenid})
  if PlayerData then
   PlayerData.money = json.decode(PlayerData.money)
   PlayerData.job = json.decode(PlayerData.job)
   PlayerData.position = json.decode(PlayerData.position)
   PlayerData.metadata = json.decode(PlayerData.metadata)
   PlayerData.charinfo = json.decode(PlayerData.charinfo)
   if PlayerData.gang then
    PlayerData.gang = json.decode(PlayerData.gang)
   else
    PlayerData.gang = {}
   end

   return ra93Core.Player.CheckPlayerData(nil, PlayerData)
  end
 end
 return nil
end

function ra93Core.Player.CheckPlayerData(source, PlayerData)
 PlayerData = PlayerData or {}
 local Offline = true
 if source then
  PlayerData.source = source
  PlayerData.license = PlayerData.license or ra93Core.functions.GetIdentifier(source, 'license')
  PlayerData.name = GetPlayerName(source)
  Offline = false
 end

 PlayerData.citizenid = PlayerData.citizenid or ra93Core.Player.CreateCitizenId()
 PlayerData.cid = PlayerData.cid or 1
 PlayerData.money = PlayerData.money or {}
 PlayerData.optin = PlayerData.optin or true
 for moneytype, startamount in pairs(ra93Core.config.Money.MoneyTypes) do
  PlayerData.money[moneytype] = PlayerData.money[moneytype] or startamount
 end

 -- Charinfo
 PlayerData.charinfo = PlayerData.charinfo or {}
 PlayerData.charinfo.firstname = PlayerData.charinfo.firstname or 'Firstname'
 PlayerData.charinfo.lastname = PlayerData.charinfo.lastname or 'Lastname'
 PlayerData.charinfo.birthdate = PlayerData.charinfo.birthdate or '00-00-0000'
 PlayerData.charinfo.gender = PlayerData.charinfo.gender or 0
 PlayerData.charinfo.backstory = PlayerData.charinfo.backstory or 'placeholder backstory'
 PlayerData.charinfo.nationality = PlayerData.charinfo.nationality or 'USA'
 PlayerData.charinfo.phone = PlayerData.charinfo.phone or ra93Core.functions.CreatePhoneNumber()
 PlayerData.charinfo.account = PlayerData.charinfo.account or ra93Core.functions.CreateAccountNumber()
 -- Metadata
 PlayerData.metadata = PlayerData.metadata or {}
 PlayerData.metadata['hunger'] = PlayerData.metadata['hunger'] or 100
 PlayerData.metadata['thirst'] = PlayerData.metadata['thirst'] or 100
 PlayerData.metadata['stress'] = PlayerData.metadata['stress'] or 0
 PlayerData.metadata['isdead'] = PlayerData.metadata['isdead'] or false
 PlayerData.metadata['inlaststand'] = PlayerData.metadata['inlaststand'] or false
 PlayerData.metadata['armor'] = PlayerData.metadata['armor'] or 0
 PlayerData.metadata['ishandcuffed'] = PlayerData.metadata['ishandcuffed'] or false
 PlayerData.metadata['tracker'] = PlayerData.metadata['tracker'] or false
 PlayerData.metadata['injail'] = PlayerData.metadata['injail'] or 0
 PlayerData.metadata['jailitems'] = PlayerData.metadata['jailitems'] or {}
 PlayerData.metadata['status'] = PlayerData.metadata['status'] or {}
 PlayerData.metadata['phone'] = PlayerData.metadata['phone'] or {}
 PlayerData.metadata['fitbit'] = PlayerData.metadata['fitbit'] or {}
 PlayerData.metadata['commandbinds'] = PlayerData.metadata['commandbinds'] or {}
 PlayerData.metadata['bloodtype'] = PlayerData.metadata['bloodtype'] or ra93Core.config.Player.Bloodtypes[math.random(1, #ra93Core.config.Player.Bloodtypes)]
 PlayerData.metadata['dealerrep'] = PlayerData.metadata['dealerrep'] or 0
 PlayerData.metadata['craftingrep'] = PlayerData.metadata['craftingrep'] or 0
 PlayerData.metadata['attachmentcraftingrep'] = PlayerData.metadata['attachmentcraftingrep'] or 0
 PlayerData.metadata['currentapartment'] = PlayerData.metadata['currentapartment'] or nil
 PlayerData.metadata['jobhistory'] = PlayerData.metadata['jobhistory'] or {}
 PlayerData.metadata['ganghistory'] = PlayerData.metadata['ganghistory'] or {}
 PlayerData.metadata['jobs'] = PlayerData.metadata['jobs'] or {}
 PlayerData.metadata['gangs'] = PlayerData.metadata['gangs'] or {}
 PlayerData.metadata['jobrep'] = PlayerData.metadata['jobrep'] or {}
 PlayerData.metadata['gangrep'] = PlayerData.metadata['gangrep'] or {}
 PlayerData.metadata['callsign'] = PlayerData.metadata['callsign'] or 'NO CALLSIGN'
 PlayerData.metadata['fingerprint'] = PlayerData.metadata['fingerprint'] or ra93Core.Player.CreateFingerId()
 PlayerData.metadata['walletid'] = PlayerData.metadata['walletid'] or ra93Core.Player.CreateWalletId()
 PlayerData.metadata['criminalrecord'] = PlayerData.metadata['criminalrecord'] or {
  ['hasRecord'] = false,
  ['date'] = nil
 }
 PlayerData.metadata['rapsheet'] = PlayerData.metadata['rapsheet'] or {}
 PlayerData.metadata['licences'] = PlayerData.metadata['licences'] or {
  ['driver'] = ra93Config.NewPlayerLicenses.driver,
  ['business'] = ra93Config.NewPlayerLicenses.business,
  ['weapon'] = ra93Config.NewPlayerLicenses.weapon
 }
 PlayerData.metadata['inside'] = PlayerData.metadata['inside'] or {
  house = nil,
  apartment = {
   apartmentType = nil,
   apartmentId = nil,
  }
 }
 PlayerData.metadata['phonedata'] = PlayerData.metadata['phonedata'] or {
  SerialNumber = ra93Core.Player.CreateSerialNumber(),
  InstalledApps = {},
 }
 PlayerData.metadata['deathinfo'] = PlayerData.metadata['deathinfo'] or {}
 -- Job
 if PlayerData.job and PlayerData.job.name and not ra93Core.shared.Jobs[PlayerData.job.name] then PlayerData.job = nil end
 PlayerData.job = PlayerData.job or {}
 PlayerData.job.name = PlayerData.job.name or 'unemployed'
 PlayerData.job.label = PlayerData.job.label or 'Civilian'
 PlayerData.job.payment = PlayerData.job.payment or ra93Core.shared.Jobs["unemployed"]["grades"]['0'].payment
 PlayerData.job.type = PlayerData.job.type or 'none'
 PlayerData.job.status = PlayerData.job.status or "available"
 if ra93Core.shared.ForceJobDefaultDutyAtLogin or PlayerData.job.onduty == nil then
  PlayerData.job.onduty = ra93Core.shared.Jobs[PlayerData.job.name].defaultDuty
 end
 PlayerData.job.isboss = PlayerData.job.isboss or false
 PlayerData.job.grade = PlayerData.job.grade or {}
 PlayerData.job.grade.name = PlayerData.job.grade.name or 'Freelancer'
 PlayerData.job.grade.level = PlayerData.job.grade.level or '0'
 -- Gang
 if PlayerData.gang and PlayerData.gang.name and not ra93Core.shared.Gangs[PlayerData.gang.name] then PlayerData.gang = nil end
 PlayerData.gang = PlayerData.gang or {}
 PlayerData.gang.name = PlayerData.gang.name or 'none'
 PlayerData.gang.label = PlayerData.gang.label or 'No Gang Affiliaton'
 PlayerData.gang.status = PlayerData.gang.status or "available"
 PlayerData.gang.isboss = PlayerData.gang.isboss or false
 PlayerData.gang.grade = PlayerData.gang.grade or {}
 PlayerData.gang.grade.name = PlayerData.gang.grade.name or 'none'
 PlayerData.gang.grade.level = PlayerData.gang.grade.level or '0'
 -- Other
 PlayerData.position = PlayerData.position or ra93Config.defaultSpawn
 PlayerData.items = GetResourceState('qb-inventory') ~= 'missing' and exports['qb-inventory']:LoadInventory(PlayerData.source, PlayerData.citizenid) or {}
 return ra93Core.Player.CreatePlayer(PlayerData, Offline)
end

-- On player logout

function ra93Core.Player.Logout(source)
 TriggerClientEvent('ra93Core:Client:OnPlayerUnload', source)
 TriggerEvent('ra93Core:Server:OnPlayerUnload', source)
 TriggerClientEvent('ra93Core:Player:UpdatePlayerData', source)
 Wait(200)
 ra93Core.Players[source] = nil
end

-- Create a new character
-- Don't touch any of this unless you know what you are doing
-- Will cause major issues!

function ra93Core.Player.CreatePlayer(PlayerData, Offline, prevJob)
 local self = {}
 self.Functions = {}
 self.PlayerData = PlayerData
 self.Offline = Offline

 function self.Functions.UpdatePlayerData()
  if self.Offline then return end -- Unsupported for Offline Players
  TriggerEvent('ra93Core:Player:SetPlayerData', self.PlayerData)
  TriggerClientEvent('ra93Core:Player:SetPlayerData', self.PlayerData.source, self.PlayerData)
 end

 function self.Functions.SetJob(job, grade)
  job = job:lower()
  grade = tostring(grade) or 0
  if ra93Core.shared.QBJobsStatus then grade = tostring(grade) or "0" end
  if not ra93Core.shared.Jobs[job] then return false end
  self.PlayerData.job.name = job
  self.PlayerData.job.label = ra93Core.shared.Jobs[job].label
  self.PlayerData.job.onduty = ra93Core.shared.Jobs[job].defaultDuty
  self.PlayerData.job.type = ra93Core.shared.Jobs[job].type or 'none'
  self.PlayerData.job.status = "hired"
  if ra93Core.shared.Jobs[job].grades[grade] then
   local jobgrade = ra93Core.shared.Jobs[job].grades[grade]
   self.PlayerData.job.grade = {}
   self.PlayerData.job.grade.name = jobgrade.name
   self.PlayerData.job.grade.level = tostring(grade)
   self.PlayerData.job.payment = jobgrade.payment or 30
   self.PlayerData.job.isboss = jobgrade.isboss or false
  else
   self.PlayerData.job.grade = {}
   self.PlayerData.job.grade.name = 'No Grades'
   self.PlayerData.job.grade.level = 0
   self.PlayerData.job.payment = 30
   self.PlayerData.job.isboss = false
  end

  self.Functions.UpdatePlayerData()
  TriggerEvent('ra93Core:Server:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
  TriggerClientEvent('ra93Core:Client:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)

  return true
 end

 function self.Functions.SetGang(gang, grade)
  gang = gang:lower()
  grade = tostring(grade) or "0"
  if not ra93Core.shared.Gangs[gang] then return false end
  self.PlayerData.gang.name = gang
  self.PlayerData.gang.label = ra93Core.shared.Gangs[gang].label
  self.PlayerData.gang.status = "hired"
  if ra93Core.shared.Gangs[gang].grades[grade] then
   local gangGrade = ra93Core.shared.Gangs[gang].grades[grade]
   self.PlayerData.gang.grade = {}
   self.PlayerData.gang.grade.name = gangGrade.name
   self.PlayerData.gang.grade.level = tostring(grade)
   self.PlayerData.gang.isboss = gangGrade.isboss or false
  else
   self.PlayerData.gang.grade = {}
   self.PlayerData.gang.grade.name = "No Grades"
   self.PlayerData.gang.grade.level = "0"
   self.PlayerData.gang.isboss = false
  end

  if not self.Offline then
   self.Functions.UpdatePlayerData()
   TriggerEvent('ra93Core:Server:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
   TriggerClientEvent('ra93Core:Client:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
  end

  return true
 end

 function self.Functions.SetActiveJob(job)
  self.PlayerData.job = nil
  self.PlayerData.job = job
  self.Functions.UpdatePlayerData()
 end

 function self.Functions.SetActiveGang(gang)
  self.PlayerData.gang = nil
  self.PlayerData.gang = gang
  self.Functions.UpdatePlayerData()
 end

 function self.Functions.SetJobDuty(onDuty)
  self.PlayerData.job.onduty = not not onDuty -- Make sure the value is a boolean if nil is sent
  self.Functions.UpdatePlayerData()
 end

 function self.Functions.SetPlayerData(key, val)
  if not key or type(key) ~= 'string' then return end
  self.PlayerData[key] = val
  self.Functions.UpdatePlayerData()
 end

 function self.Functions.SetMetaData(meta, val)
  if not meta or type(meta) ~= 'string' then return end
  if meta == 'hunger' or meta == 'thirst' then
   val = val > 100 and 100 or val
  end
  self.PlayerData.metadata[meta] = val
  self.Functions.UpdatePlayerData()
 end

 function self.Functions.GetMetaData(meta)
  if not meta or type(meta) ~= 'string' then return end
  return self.PlayerData.metadata[meta]
 end

 function self.Functions.AddJobReputation(amount)
  if not amount then return end
  amount = tonumber(amount)
  local job = self.PlayerData.job.name
  if not self.PlayerData.metadata.jobrep[job] then self.PlayerData.metadata.jobrep[job] = "0" end
  self.PlayerData.metadata.jobrep[job] += amount or amount
  self.Functions.UpdatePlayerData()
 end

 function self.Functions.SubtractJobReputation(amount)
  if not amount then return end
  amount = tonumber(amount)
  local job = self.PlayerData.job.name
  if not self.PlayerData.metadata.jobrep[job] then self.PlayerData.metadata.jobrep[job] = "0" end
  self.PlayerData.metadata.jobrep[job] += amount or amount
  self.Functions.UpdatePlayerData()
 end

 function self.Functions.AddToJobHistory(job,jobHistoryData)
  local status = {
   ["error"] = {},
   ["success"] = {}
  }
  local ercnt = 0
  if not job or not jobHistoryData then
   status.error[ercnt] = {
    ["subject"] = "AddToJobHistory Args Empty",
    ["msg"] = "arguments empty: core >server > player.lua AddToJobHistory",
    ["jsMsg"] = "Failure!",
    ["color"] = "error",
    ["logName"] = "ra93Core",
    ["src"] = src,
    ["log"] = true,
    ["console"] = true
   }
   return status
  end
  self.PlayerData.metadata.jobhistory[job] = jobHistoryData
  self.Functions.UpdatePlayerData()
  status.success[ercnt] = {
   ["subject"] = "AddToJobHistory Success",
   ["msg"] = "AddToJobHistory Successful!",
   ["jsMsg"] = "Success!",
   ["color"] = "success",
   ["logName"] = "ra93Core",
   ["src"] = src,
   ["log"] = true
  }
  return status
 end

 function self.Functions.AddToJobs(job,data)
  local status = {
   ["error"] = {},
   ["success"] = {}
  }
  if not job or not data then
   status.error[0] = {
    ["subject"] = "AddToJobs Args Empty",
    ["msg"] = "arguments empty: core >server > player.lua AddToJobs",
    ["jsMsg"] = "Failure!",
    ["color"] = "error",
    ["logName"] = "ra93Core",
    ["src"] = src,
    ["log"] = true,
    ["console"] = true
   }
   return status
  end
  job = job:lower()
  self.PlayerData.metadata.jobs[job] = data
  self.Functions.UpdatePlayerData()
  status.success[0] = {
   ["subject"] = "AddToJobs Success",
   ["msg"] = "AddToJobs Successful!",
   ["jsMsg"] = "Success!",
   ["color"] = "success",
   ["logName"] = "ra93Core",
   ["src"] = src,
   ["log"] = true
  }
  return status
 end

 function self.Functions.UpdateJob(data)
  local status = {
   ["error"] = {},
   ["success"] = {}
  }
  local ercnt = 0
  if not data then
   status.error[ercnt] = {
    ["subject"] = "UpdateJob Args Empty",
    ["msg"] = "arguments empty: core >server > player.lua UpdateJob",
    ["jsMsg"] = "Failure!",
    ["color"] = "error",
    ["logName"] = "ra93Core",
    ["src"] = src,
    ["log"] = true,
    ["console"] = true
   }
   return status
  end
  self.PlayerData.job = data
  self.Functions.UpdatePlayerData()
  status.success[ercnt] = {
   ["subject"] = "UpdateJob Success",
   ["msg"] = "UpdateJob Successful!",
   ["jsMsg"] = "Success!",
   ["color"] = "success",
   ["logName"] = "ra93Core",
   ["src"] = src,
   ["log"] = true
  }
  return status
 end

 function self.Functions.RemoveFromJobs(job)
  if not job then return end
  job = job:lower()
  self.PlayerData.metadata.jobs[job] = nil
  self.Functions.UpdatePlayerData()
 end

 function self.Functions.AddGangReputation(amount)
  if not amount then return end
  amount = tonumber(amount)
  local gang = self.PlayerData.gang.name
  if not self.PlayerData.metadata.gangrep[gang] then self.PlayerData.metadata.gangrep[gang] = "0" end
  self.PlayerData.metadata.gangrep[gang] += amount or amount
  self.Functions.UpdatePlayerData()
 end

 function self.Functions.SubtractGangReputation(amount)
  if not amount then return end
  amount = tonumber(amount)
  local gang = self.PlayerData.gang.name
  if not self.PlayerData.metadata.gangrep[gang] then self.PlayerData.metadata.gangrep[gang] = "0" end
  self.PlayerData.metadata.gangrep[gang] += amount or amount
  self.Functions.UpdatePlayerData()
 end

 function self.Functions.AddToGangHistory(gang,gangHistoryData)
  local status = {
   ["error"] = {},
   ["success"] = {}
  }
  if not gang or not gangHistoryData then
   status.error[0] = {
    ["subject"] = "AddToGangHistory Args Empty",
    ["msg"] = "arguments empty: core >server > player.lua AddToGangHistory",
    ["jsMsg"] = "Failure!",
    ["color"] = "error",
    ["logName"] = "ra93Core",
    ["src"] = src,
    ["log"] = true,
    ["console"] = true
   }
   return status
  end
  self.PlayerData.metadata.ganghistory[gang] = gangHistoryData
  self.Functions.UpdatePlayerData()
  status.success[0] = {
   ["subject"] = "AddToGangHistory Success",
   ["msg"] = "AddToGangHistory Successful!",
   ["jsMsg"] = "Success!",
   ["color"] = "success",
   ["logName"] = "ra93Core",
   ["src"] = src,
   ["log"] = true
  }
  return status
 end

 function self.Functions.AddToGangs(gang,data)
  local status = {
   ["error"] = {},
   ["success"] = {}
  }
  local ercnt = 0
  if not gang or not data then
   status.error[ercnt] = {
    ["subject"] = "AddToGangs Args Empty",
    ["msg"] = "arguments empty: core >server > player.lua AddToGangs",
    ["jsMsg"] = "Failure!",
    ["color"] = "error",
    ["logName"] = "ra93Core",
    ["src"] = src,
    ["log"] = true,
    ["console"] = true
   }
   return status
  end
  gang = gang:lower()
  self.PlayerData.metadata.gangs[gang] = data
  if self.PlayerData.metadata.gangs["none"] then self.PlayerData.metadata.gangs["none"] = nil end
  self.Functions.UpdatePlayerData()
  status.success[ercnt] = {
   ["subject"] = "AddToGangs Success",
   ["msg"] = "AddToGangs Successful!",
   ["jsMsg"] = "Success!",
   ["color"] = "success",
   ["logName"] = "ra93Core",
   ["src"] = src,
   ["log"] = true
  }
  return status
 end

 function self.Functions.UpdateGang(data)
  local status = {
   ["error"] = {},
   ["success"] = {}
  }
  local ercnt = 0
  if not data then
   status.error[ercnt] = {
    ["subject"] = "UpdateGang Args Empty",
    ["msg"] = "arguments empty: core >server > player.lua UpdateGang",
    ["jsMsg"] = "Failure!",
    ["color"] = "error",
    ["logName"] = "ra93Core",
    ["src"] = src,
    ["log"] = true,
    ["console"] = true
   }
   return status
  end
  self.PlayerData.gang = data
  self.Functions.UpdatePlayerData()
  status.success[ercnt] = {
   ["subject"] = "UpdateGang Success",
   ["msg"] = "UpdateGang Successful!",
   ["jsMsg"] = "Success!",
   ["color"] = "success",
   ["logName"] = "ra93Core",
   ["src"] = src,
   ["log"] = true
  }
  return status
 end

 function self.Functions.RemoveFromGangs(gang)
  if not gang then return end
  gang = gang:lower()
  self.PlayerData.metadata.gangs[gang] = nil
  self.Functions.UpdatePlayerData()
 end

 function self.Functions.AddMoney(moneytype, amount, reason)
  reason = reason or 'unknown'
  moneytype = moneytype:lower()
  amount = tonumber(amount)
  if amount < 0 then return end
  if not self.PlayerData.money[moneytype] then return false end
  self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] + amount

  if not self.Offline then
   self.Functions.UpdatePlayerData()
   if amount > 100000 then
    TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
   else
    TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
   end
   TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, false)
   TriggerClientEvent('ra93Core:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, "add", reason)
   TriggerEvent('ra93Core:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, "add", reason)
  end

  return true
 end

 function self.Functions.RemoveMoney(moneytype, amount, reason)
  reason = reason or 'unknown'
  moneytype = moneytype:lower()
  amount = tonumber(amount)
  if amount < 0 then return end
  if not self.PlayerData.money[moneytype] then return false end
  for _, mtype in pairs(ra93Core.config.Money.DontAllowMinus) do
   if mtype == moneytype then
    if (self.PlayerData.money[moneytype] - amount) < 0 then
     return false
    end
   end
  end
  self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount

  if not self.Offline then
   self.Functions.UpdatePlayerData()
   TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
   TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, true)
   if moneytype == 'bank' then
    TriggerClientEvent('qb-phone:client:RemoveBankMoney', self.PlayerData.source, amount)
   end
   TriggerClientEvent('ra93Core:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, "remove", reason)
   TriggerEvent('ra93Core:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, "remove", reason)
  end

  return true
 end

 function self.Functions.SetMoney(moneytype, amount, reason)
  reason = reason or 'unknown'
  moneytype = moneytype:lower()
  amount = tonumber(amount)
  if amount < 0 then return false end
  if not self.PlayerData.money[moneytype] then return false end
  local difference = amount - self.PlayerData.money[moneytype]
  self.PlayerData.money[moneytype] = amount

  if not self.Offline then
   self.Functions.UpdatePlayerData()
   TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'SetMoney', 'green', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') set, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
   TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, math.abs(difference), difference < 0)
   TriggerClientEvent('ra93Core:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, "set", reason)
   TriggerEvent('ra93Core:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, "set", reason)
  end

  return true
 end

 function self.Functions.GetMoney(moneytype)
  if not moneytype then return false end
  moneytype = moneytype:lower()
  return self.PlayerData.money[moneytype]
 end

 function self.Functions.SetCreditCard(cardNumber)
  self.PlayerData.charinfo.card = cardNumber
  self.Functions.UpdatePlayerData()
 end

 function self.Functions.GetCardSlot(cardNumber, cardType)
  local item = tostring(cardType):lower()
  local slots = exports['qb-inventory']:GetSlotsByItem(self.PlayerData.items, item)
  for _, slot in pairs(slots) do
   if slot then
    if self.PlayerData.items[slot].info.cardNumber == cardNumber then
     return slot
    end
   end
  end
  return nil
 end

 function self.Functions.Save()
  if self.Offline then
   ra93Core.Player.SaveOffline(self.PlayerData)
  else
   ra93Core.Player.Save(self.PlayerData.source)
  end
 end

 function self.Functions.Logout()
  if self.Offline then return end -- Unsupported for Offline Players
  ra93Core.Player.Logout(self.PlayerData.source)
 end

 function self.Functions.AddMethod(methodName, handler)
  self.Functions[methodName] = handler
 end

 function self.Functions.AddField(fieldName, data)
  self[fieldName] = data
 end

 if self.Offline then
  return self
 else
  ra93Core.Players[self.PlayerData.source] = self
  ra93Core.Player.Save(self.PlayerData.source)

  -- At this point we are safe to emit new instance to third party resource for load handling
  TriggerEvent('ra93Core:Server:PlayerLoaded', self)
  self.Functions.UpdatePlayerData()
 end
end

-- Add a new function to the Functions table of the player class
-- Use-case:
--[[
 AddEventHandler('ra93Core:Server:PlayerLoaded', function(Player)
  ra93Core.functions.AddPlayerMethod(Player.PlayerData.source, "functionName", function(oneArg, orMore)
   -- do something here
  end)
 end)
]]

function ra93Core.functions.AddPlayerMethod(ids, methodName, handler)
 local idType = type(ids)
 if idType == "number" then
  if ids == -1 then
   for _, v in pairs(ra93Core.Players) do
    v.Functions.AddMethod(methodName, handler)
   end
  else
   if not ra93Core.Players[ids] then return end

   ra93Core.Players[ids].Functions.AddMethod(methodName, handler)
  end
 elseif idType == "table" and type(ids) == "array" then
  for i = 1, #ids do
   ra93Core.functions.AddPlayerMethod(ids[i], methodName, handler)
  end
 end
end

-- Add a new field table of the player class
-- Use-case:
--[[
 AddEventHandler('ra93Core:Server:PlayerLoaded', function(Player)
  ra93Core.functions.AddPlayerField(Player.PlayerData.source, "fieldName", "fieldData")
 end)
]]

function ra93Core.functions.AddPlayerField(ids, fieldName, data)
 local idType = type(ids)
 if idType == "number" then
  if ids == -1 then
   for _, v in pairs(ra93Core.Players) do
    v.Functions.AddField(fieldName, data)
   end
  else
   if not ra93Core.Players[ids] then return end

   ra93Core.Players[ids].Functions.AddField(fieldName, data)
  end
 elseif idType == "table" and type(ids) == "array" then
  for i = 1, #ids do
   ra93Core.functions.AddPlayerField(ids[i], fieldName, data)
  end
 end
end

-- Save player info to database (make sure citizenid is the primary key in your database)

function ra93Core.Player.Save(source)
 local ped = GetPlayerPed(source)
 local pcoords = GetEntityCoords(ped)
 local PlayerData = ra93Core.Players[source].PlayerData
 if PlayerData then
  MySQL.insert('INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata) VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata) ON DUPLICATE KEY UPDATE cid = :cid, name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata', {
   citizenid = PlayerData.citizenid,
   cid = tonumber(PlayerData.cid),
   license = PlayerData.license,
   name = PlayerData.name,
   money = json.encode(PlayerData.money),
   charinfo = json.encode(PlayerData.charinfo),
   job = json.encode(PlayerData.job),
   gang = json.encode(PlayerData.gang),
   position = json.encode(pcoords),
   metadata = json.encode(PlayerData.metadata)
  })
  if GetResourceState('qb-inventory') ~= 'missing' then exports['qb-inventory']:SaveInventory(source) end
  ra93Core.ShowSuccess(GetCurrentResourceName(), PlayerData.name .. ' PLAYER SAVED!')
 else
  ra93Core.ShowError(GetCurrentResourceName(), 'ERROR ra93Core.PLAYER.SAVE - PLAYERDATA IS EMPTY!')
 end
end

function ra93Core.Player.SaveOffline(PlayerData)
 if PlayerData then
  MySQL.Async.insert('INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata) VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata) ON DUPLICATE KEY UPDATE cid = :cid, name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata', {
   citizenid = PlayerData.citizenid,
   cid = tonumber(PlayerData.cid),
   license = PlayerData.license,
   name = PlayerData.name,
   money = json.encode(PlayerData.money),
   charinfo = json.encode(PlayerData.charinfo),
   job = json.encode(PlayerData.job),
   gang = json.encode(PlayerData.gang),
   position = json.encode(PlayerData.position),
   metadata = json.encode(PlayerData.metadata)
  })
  if GetResourceState('qb-inventory') ~= 'missing' then exports['qb-inventory']:SaveInventory(PlayerData, true) end
  ra93Core.ShowSuccess(GetCurrentResourceName(), PlayerData.name .. ' OFFLINE PLAYER SAVED!')
 else
  ra93Core.ShowError(GetCurrentResourceName(), 'ERROR ra93Core.PLAYER.SAVEOFFLINE - PLAYERDATA IS EMPTY!')
 end
end

-- Delete character

local playertables = { -- Add tables as needed
 { table = 'players' },
 { table = 'apartments' },
 { table = 'bank_accounts' },
 { table = 'crypto_transactions' },
 { table = 'phone_invoices' },
 { table = 'phone_messages' },
 { table = 'playerskins' },
 { table = 'player_contacts' },
 { table = 'player_houses' },
 { table = 'player_mails' },
 { table = 'player_outfits' },
 { table = 'player_vehicles' }
}

function ra93Core.Player.DeleteCharacter(source, citizenid)
 local license = ra93Core.functions.GetIdentifier(source, 'license')
 local result = MySQL.scalar.await('SELECT license FROM players where citizenid = ?', { citizenid })
 if license == result then
  local query = "DELETE FROM %s WHERE citizenid = ?"
  local tableCount = #playertables
  local queries = table.create(tableCount, 0)

  for i = 1, tableCount do
   local v = playertables[i]
   queries[i] = {query = query:format(v.table), values = { citizenid }}
  end

  MySQL.transaction(queries, function(result2)
   if result2 then
    TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Character Deleted', 'red', '**' .. GetPlayerName(source) .. '** ' .. license .. ' deleted **' .. citizenid .. '**..')
   end
  end)
 else
  DropPlayer(source, Lang:t("info.exploit_dropped"))
  TriggerEvent('qb-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white', GetPlayerName(source) .. ' Has Been Dropped For Character Deletion Exploit', true)
 end
end

function ra93Core.Player.ForceDeleteCharacter(citizenid)
 local result = MySQL.scalar.await('SELECT license FROM players where citizenid = ?', { citizenid })
 if result then
  local query = "DELETE FROM %s WHERE citizenid = ?"
  local tableCount = #playertables
  local queries = table.create(tableCount, 0)
  local Player = ra93Core.functions.GetPlayerByCitizenId(citizenid)

  if Player then
   DropPlayer(Player.PlayerData.source, "An admin deleted the character which you are currently using")
  end
  for i = 1, tableCount do
   local v = playertables[i]
   queries[i] = {query = query:format(v.table), values = { citizenid }}
  end

  MySQL.transaction(queries, function(result2)
   if result2 then
    TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Character Force Deleted', 'red', 'Character **' .. citizenid .. '** got deleted')
   end
  end)
 end
end

-- Inventory Backwards Compatibility

function ra93Core.Player.SaveInventory(source)
 if GetResourceState('qb-inventory') == 'missing' then return end
 exports['qb-inventory']:SaveInventory(source, false)
end

function ra93Core.Player.SaveOfflineInventory(PlayerData)
 if GetResourceState('qb-inventory') == 'missing' then return end
 exports['qb-inventory']:SaveInventory(PlayerData, true)
end

function ra93Core.Player.GetTotalWeight(items)
 if GetResourceState('qb-inventory') == 'missing' then return end
 return exports['qb-inventory']:GetTotalWeight(items)
end

function ra93Core.Player.GetSlotsByItem(items, itemName)
 if GetResourceState('qb-inventory') == 'missing' then return end
 return exports['qb-inventory']:GetSlotsByItem(items, itemName)
end

function ra93Core.Player.GetFirstSlotByItem(items, itemName)
 if GetResourceState('qb-inventory') == 'missing' then return end
 return exports['qb-inventory']:GetFirstSlotByItem(items, itemName)
end

-- Util Functions

function ra93Core.Player.CreateCitizenId()
 local UniqueFound = false
 local CitizenId = nil
 while not UniqueFound do
  CitizenId = tostring(ra93Core.shared.RandomStr(3) .. ra93Core.shared.RandomInt(5)):upper()
  local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM players WHERE citizenid = ?', { CitizenId })
  if result == 0 then
   UniqueFound = true
  end
 end
 return CitizenId
end

function ra93Core.functions.CreateAccountNumber()
 local UniqueFound = false
 local AccountNumber = nil
 while not UniqueFound do
  AccountNumber = 'US0' .. math.random(1, 9) .. 'ra93Core' .. math.random(1111, 9999) .. math.random(1111, 9999) .. math.random(11, 99)
  local query = '%' .. AccountNumber .. '%'
  local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM players WHERE charinfo LIKE ?', { query })
  if result == 0 then
   UniqueFound = true
  end
 end
 return AccountNumber
end

function ra93Core.functions.CreatePhoneNumber()
 local UniqueFound = false
 local PhoneNumber = nil
 while not UniqueFound do
  PhoneNumber = math.random(100,999) .. math.random(1000000,9999999)
  local query = '%' .. PhoneNumber .. '%'
  local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM players WHERE charinfo LIKE ?', { query })
  if result == 0 then
   UniqueFound = true
  end
 end
 return PhoneNumber
end

function ra93Core.Player.CreateFingerId()
 local UniqueFound = false
 local FingerId = nil
 while not UniqueFound do
  FingerId = tostring(ra93Core.shared.RandomStr(2) .. ra93Core.shared.RandomInt(3) .. ra93Core.shared.RandomStr(1) .. ra93Core.shared.RandomInt(2) .. ra93Core.shared.RandomStr(3) .. ra93Core.shared.RandomInt(4))
  local query = '%' .. FingerId .. '%'
  local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM `players` WHERE `metadata` LIKE ?', { query })
  if result == 0 then
   UniqueFound = true
  end
 end
 return FingerId
end

function ra93Core.Player.CreateWalletId()
 local UniqueFound = false
 local WalletId = nil
 while not UniqueFound do
  WalletId = 'QB-' .. math.random(11111111, 99999999)
  local query = '%' .. WalletId .. '%'
  local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM players WHERE metadata LIKE ?', { query })
  if result == 0 then
   UniqueFound = true
  end
 end
 return WalletId
end

function ra93Core.Player.CreateSerialNumber()
 local UniqueFound = false
 local SerialNumber = nil
 while not UniqueFound do
  SerialNumber = math.random(11111111, 99999999)
  local query = '%' .. SerialNumber .. '%'
  local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM players WHERE metadata LIKE ?', { query })
  if result == 0 then
   UniqueFound = true
  end
 end
 return SerialNumber
end

PaycheckInterval() -- This starts the paycheck system