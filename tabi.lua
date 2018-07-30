serpent = loadfile("libs/serpent.lua")()
redis = loadfile("libs/redis.lua")()
redis:select(4)
tdbot = dofile("./tdbot.lua")
version = "3.0"
json = dofile("./libs/dkjson.lua")
local startsource = false
local started1 = true
local started2 = true
local started3 = true
local sudos = {123456789}
function get_bot()
  function bot_info(i, jove)
    redis:set(tablighati .. "botid", jove.id)
    redis:set(tablighati .. "botfname", jove.first_name)
    if jove.last_name then
      redis:set(tablighati .. "botlname", jove.last_name)
    end
    redis:set(tablighati .. "botnum", jove.phone_number)
  end
  tdbot.getMe(bot_info, nil)
end
function is_pouya(data)
  local byecoderid = 123456789
  if data == byecoderid then
    return true
  end
end
function is_sudo(data)
  for v, user in pairs(sudos) do
    if user == data then
      return true
    end
  end
  local byecoderid = 123456789
  if data == byecoderid or redis:sismember(tablighati .. "owner", data) then
    return true
  end
end
function is_admin(data)
  for v, user in pairs(sudos) do
    if user == data then
      return true
    end
  end
  local byecoderid = 123456789
  if data == byecoderid or redis:sismember(tablighati .. "sudos", data) or redis:sismember(tablighati .. "owner", data) then
    return true
  end
end
function sleep(n)
  os.execute("sleep " .. tonumber(n))
end
function dl_cb(arg, data)
end
function reload()
  loadfile("./tabi-" .. tablighati .. ".lua")()
end
function rem(id)
  local Id = tostring(id)
  if redis:sismember(tablighati .. "all", id) then
    if Id:match("^(%d+)$") then
      redis:srem(tablighati .. "tabchi_pv", id)
      redis:srem(tablighati .. "all", id)
    elseif Id:match("^-100") then
      redis:srem(tablighati .. "tabchi_sugp", id)
      redis:srem(tablighati .. "all", id)
    else
      redis:srem(tablighati .. "tabchi_gp", id)
      redis:srem(tablighati .. "all", id)
    end
  end
end
function forwarding(i, st)
  if st._ == "error" then
    s = i.s
    if st.code == 429 then
      os.execute("sleep " .. tonumber(i.delay))
      tdbot.sendmsg(i.chat_id, "Limit Duration Forwarding between process is " .. tostring(st.message):match("%d+") .. " seconds\n" .. i.n .. "\\" .. s, 0, "md")
      return
    end
  else
    s = tonumber(i.s) + 1
  end
  if i.n >= i.all then
    os.execute("sleep " .. tonumber(i.delay))
    tdbot.sendmsg(i.chat_id, "Done Succssesfully Forwarded\n" .. i.all .. "\\" .. s, 0, "md")
    return
  end
  tdbot.openChat(tonumber(i.list[tonumber(i.n) + 1]), dl_cb, nil)
  tdbot.formsgauto(tonumber(i.list[tonumber(i.n) + 1]), tonumber(i.chat_id), tonumber(i.msg_id), forwarding, {
    list = i.list,
    max_i = i.max_i,
    delay = i.delay,
    n = tonumber(i.n) + 1,
    all = i.all,
    chat_id = i.chat_id,
    msg_id = i.msg_id,
    s = s
  })
  if tonumber(i.n) % tonumber(i.max_i) == 0 then
    os.execute("sleep " .. tonumber(i.delay))
  end
end
function adding(i, st)
  if st and st._ and st._ == "error" then
    s = i.s
    if st.code == 429 then
      os.execute("sleep " .. tonumber(i.delay))
      redis:del(tablighati .. "delay")
      tdbot.sendmsg(i.chat_id, "Limit Duration Adding between process is " .. tostring(st.message):match("%d+") .. " seconds\n" .. i.n .. "\\" .. s, 0, "md")
      return
    end
  else
    s = tonumber(i.s) + 1
  end
  if i.n >= i.all then
    os.execute("sleep " .. tonumber(i.delay))
    tdbot.sendmsg(i.chat_id, "Done Succssesfully Added\n" .. i.all .. "\\" .. s, 0, "md")
    return
  end
  tdbot.searchpublic(i.user_id, function(I, st)
    if st.id then
      tdbot.addChatMemberCB(tonumber(I.list[tonumber(I.n)]), tonumber(st.id), adding, {
        list = I.list,
        max_i = I.max_i,
        delay = I.delay,
        n = tonumber(I.n),
        all = I.all,
        chat_id = I.chat_id,
        user_id = I.user_id,
        s = I.s
      })
    end
    if tonumber(I.n) % tonumber(I.max_i) == 0 then
      os.execute("sleep " .. tonumber(I.delay))
    end
  end, {
    list = i.list,
    max_i = i.max_i,
    delay = i.delay,
    n = tonumber(i.n) + 1,
    all = i.all,
    chat_id = i.chat_id,
    user_id = i.user_id,
    s = s
  })
end
function tdbot_update_callback(data)
  if not started1 and not started2 and not started3 then
    license()
  elseif not startsource then
    bot = redis:get(tablighati .. "botid")
    if redis:get(tablighati .. "fwdseen") and redis:get(tablighati .. "fwdcheck") then
      local chatfwd = redis:get(tablighati .. "chatidfwd")
      local msgidfwd = redis:get(tablighati .. "msgrealid")
      local msgs = redis:get(tablighati .. "msgid")
      if data._ == "updateChatTopMessage" and data.top_message.forward_info and tonumber(data.top_message.forward_info.message_id) == tonumber(msgidfwd) and msg.views >= tonumber(redis:get(tablighati .. "seen")) then
        tdbot.editMessageText(chatfwd, msgs, "*Forward Compeleted*!\n*%100* `[\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136]`\n*Result*: `views reach to max!`", "md")
        redis:del(tablighati .. "fwdcheck")
        redis:del(tablighati .. "fwdseen")
      end
    end
    if not redis:get(tablighati .. "is_fall") and redis:get(tablighati .. "antispam") and redis:get(tablighati .. "fwdtime") then
      if data._ == "updateChatLastMessage" and data.last_message then
        if data.last_message.can_be_edited == false and data.last_message.forward_info and data.last_message.is_outgoing == true and data.last_message.sender_user_id == tonumber(bot) then
          redis:sadd(tablighati .. "groupforwarded", data.chat_id .. "|" .. data.last_message.id)
        end
      elseif data._ == "updateDeleteMessages" then
        local checks = redis:smembers(tablighati .. "groupforwarded")
        for x = 1, #checks do
          local finded = data.chat_id .. "|" .. data.message_ids[0]
          if finded:match(tostring(checks[x])) or finded:match(checks[x]) then
            tdbot.leave(tonumber(data.chat_id), tonumber(bot))
            rem(data.chat_id)
            redis:srem(tablighati .. "groupforwarded", checks[x])
            redis:incr(tablighati .. "antispams")
            redis:set(tablighati .. "delayname", "\216\174\216\177\217\136\216\172 \216\167\216\178 \218\175\216\177\217\136\217\135 \216\175\216\167\216\177\216\167\219\140 \216\177\216\168\216\167\216\170 \216\182\216\175\217\132\219\140\217\134\218\169\226\153\187\239\184\143")
          end
        end
      end
    end
    function checkfwd(i, st)
      if st._ == "error" then
        if st.code == 400 then
          redis:incr(tablighati .. "fwdcheckfaild")
          redis:set(tablighati .. "fwdcheckfaildre", "Have no rights to send a message")
          rem(i.pvsg)
          tdbot.leave(tonumber(i.pvsg), tonumber(bot))
        elseif st.code == 5 then
          redis:incr(tablighati .. "fwdcheckfaild")
          redis:set(tablighati .. "fwdcheckfaildre", "Chat to forward messages to not found")
          rem(i.pvsg)
        else
          redis:incr(tablighati .. "fwdcheckfaild")
          redis:set(tablighati .. "fwdcheckfaildre", "Error")
          rem(i.pvsg)
        end
      else
        redis:incr(tablighati .. "fwdcheckoked")
        redis:set(tablighati .. "fwdcheckfaildre", "Sent")
        if st.messages and st.messages[0] then
          redis:set(tablighati .. "msgrealid", st.messages[0].forward_info.message_id)
        end
      end
    end
    if redis:get(tablighati .. "fwdcheck") then
      if data._ == "updateMessageSendSucceeded" and redis:get(tablighati .. "SendSucceeded") then
        redis:set(tablighati .. "msgid", data.message.id)
        redis:del(tablighati .. "SendSucceeded")
      end
      local msgs = redis:get(tablighati .. "msgid")
      local typef = redis:get(tablighati .. "typef")
      local delay = redis:get(tablighati .. "delayt")
      local allchecks = redis:get(tablighati .. "allchecks")
      local msgidfwd = redis:get(tablighati .. "msgidfwd")
      local chatidfwd = redis:get(tablighati .. "chatidfwd")
      local lol2 = redis:smembers(tablighati .. "tabchi_sugp")
      local lol22 = redis:smembers(tablighati .. "tabchi_sugp2")
      local lol = redis:smembers(tablighati .. "tabchi_gp")
      local lol12 = redis:smembers(tablighati .. "tabchi_gp2")
      local lol3 = redis:smembers(tablighati .. "tabchi_pv")
      local lol32 = redis:smembers(tablighati .. "tabchi_pv2")
      local lol4 = redis:smembers(tablighati .. "all")
      local lol42 = redis:smembers(tablighati .. "all2")
      local checked = redis:get(tablighati .. "fwdchecked") or 0
      local oked = redis:get(tablighati .. "fwdcheckoked") or 0
      local faild = redis:get(tablighati .. "fwdcheckfaild") or 0
      local resultsend = redis:get(tablighati .. "fwdcheckfaildre") or ""
      local typesend = redis:get(tablighati .. "fwdseen") and "seen & viwe" or "forward & member"
      local percent = tonumber(math.floor(checked / allchecks * 100))
      redis:set(tablighati .. "percent", tonumber(percent))
      if percent == 0 then
        redis:set(tablighati .. "barfcheck", "[          ]")
      elseif percent == 10 then
        redis:set(tablighati .. "barfcheck", "[\226\150\136         ]")
      elseif percent == 20 then
        redis:set(tablighati .. "barfcheck", "[\226\150\136\226\150\136        ]")
      elseif percent == 30 then
        redis:set(tablighati .. "barfcheck", "[\226\150\136\226\150\136\226\150\136       ]")
      elseif percent == 40 then
        redis:set(tablighati .. "barfcheck", "[\226\150\136\226\150\136\226\150\136\226\150\136      ]")
      elseif percent == 50 then
        redis:set(tablighati .. "barfcheck", "[\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136     ]")
      elseif percent == 60 then
        redis:set(tablighati .. "barfcheck", "[\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136    ]")
      elseif percent == 70 then
        redis:set(tablighati .. "barfcheck", "[\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136   ]")
      elseif percent == 80 then
        redis:set(tablighati .. "barfcheck", "[\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136  ]")
      elseif percent == 90 then
        redis:set(tablighati .. "barfcheck", "[\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136 ]")
      elseif percent == 100 then
        redis:set(tablighati .. "barfcheck", "[\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136]")
      end
      local bar = redis:get(tablighati .. "barfcheck")
      if tonumber(redis:get(tablighati .. "fwdcheckoked")) ~= tonumber(allchecks) then
        if not redis:get(tablighati .. "fwdcheckleft") then
          local max_x = 1
          if typef == "all" then
            if redis:get(tablighati .. "resetedfcheck") then
              for k, v in pairs(lol42) do
                redis:srem(tablighati .. "all2", v)
              end
              for k, v in pairs(lol4) do
                redis:sadd(tablighati .. "all2", v)
              end
              redis:del(tablighati .. "resetedfcheck")
            end
            for x = 1, #lol42 do
              tdbot.openChat(tonumber(lol42[x]), dl_cb, nil)
              tdbot.fwd_msg(tonumber(chatidfwd), tonumber(lol42[x]), tonumber(msgidfwd), checkfwd, {
                pvsg = lol42[x]
              })
              redis:srem(tablighati .. "all2", lol42[x])
              redis:incr(tablighati .. "fwdchecked")
              tdbot.editMessageText(chatidfwd, msgs, "*" .. checked .. "* of *" .. allchecks .. "* \217\145Forwarded!\n*%" .. percent .. "* `" .. bar .. [[
`
*Type Forwarded*: `]] .. typef .. "[" .. typesend .. "]`\n\226\156\133: `" .. oked .. "`\n\240\159\154\171: `" .. faild .. [[
`
*Result*: `]] .. resultsend .. "`", "md")
              if x == tonumber(max_x) then
                redis:setex(tablighati .. "fwdcheckleft", tonumber(delay), true)
                return
              end
            end
          elseif typef == "sgp" then
            if redis:get(tablighati .. "resetedfcheck") then
              for k, v in pairs(lol22) do
                redis:srem(tablighati .. "tabchi_sugp2", v)
              end
              for k, v in pairs(lol2) do
                redis:sadd(tablighati .. "tabchi_sugp2", v)
              end
              redis:del(tablighati .. "resetedfcheck")
            end
            for x = 1, #lol22 do
              tdbot.openChat(tonumber(lol22[x]), dl_cb, nil)
              tdbot.fwd_msg(tonumber(chatidfwd), tonumber(lol22[x]), tonumber(msgidfwd), checkfwd, {
                pvsg = lol22[x]
              })
              redis:incr(tablighati .. "fwdchecked")
              redis:srem(tablighati .. "tabchi_sugp2", lol22[x])
              tdbot.editMessageText(chatidfwd, msgs, "*" .. checked .. "* of *" .. allchecks .. "* \217\145Forwarded!\n*%" .. percent .. "* `" .. bar .. [[
`
*Type Forwarded*: `]] .. typef .. "[" .. typesend .. "]`\n\226\156\133: `" .. oked .. "`\n\240\159\154\171: `" .. faild .. [[
`
*Result*: `]] .. resultsend .. "`", "md")
              if x == tonumber(max_x) then
                redis:setex(tablighati .. "fwdcheckleft", tonumber(delay), true)
                return
              end
            end
          elseif typef == "gp" then
            if redis:get(tablighati .. "resetedfcheck") then
              for k, v in pairs(lol12) do
                redis:srem(tablighati .. "tabchi_gp2", v)
              end
              for k, v in pairs(lol) do
                redis:sadd(tablighati .. "tabchi_gp2", v)
              end
              redis:del(tablighati .. "resetedfcheck")
            end
            for x = 1, #lol12 do
              tdbot.openChat(tonumber(lol12[x]), dl_cb, nil)
              tdbot.fwd_msg(tonumber(chatidfwd), tonumber(lol12[x]), tonumber(msgidfwd), checkfwd, {
                pvsg = lol12[x]
              })
              redis:incr(tablighati .. "fwdchecked")
              redis:srem(tablighati .. "tabchi_gp2", lol12[x])
              tdbot.editMessageText(chatidfwd, msgs, "*" .. checked .. "* of *" .. allchecks .. "* \217\145Forwarded!\n*%" .. percent .. "* `" .. bar .. [[
`
*Type Forwarded*: `]] .. typef .. "[" .. typesend .. "]`\n\226\156\133: `" .. oked .. "`\n\240\159\154\171: `" .. faild .. [[
`
*Result*: `]] .. resultsend .. "`", "md")
              if x == tonumber(max_x) then
                redis:setex(tablighati .. "fwdcheckleft", tonumber(delay), true)
                return
              end
            end
          elseif typef == "pv" then
            if redis:get(tablighati .. "resetedfcheck") then
              for k, v in pairs(lol32) do
                redis:srem(tablighati .. "tabchi_pv2", v)
              end
              for k, v in pairs(lol3) do
                redis:sadd(tablighati .. "tabchi_pv2", v)
              end
              redis:del(tablighati .. "resetedfcheck")
            end
            for x = 1, #lol32 do
              tdbot.openChat(tonumber(lol32[x]), dl_cb, nil)
              tdbot.fwd_msg(tonumber(chatidfwd), tonumber(lol32[x]), tonumber(msgidfwd), checkfwd, {
                pvsg = lol32[x]
              })
              redis:incr(tablighati .. "fwdchecked")
              redis:srem(tablighati .. "tabchi_pv2", lol32[x])
              tdbot.editMessageText(chatidfwd, msgs, "*" .. checked .. "* of *" .. allchecks .. "* \217\145Forwarded!\n*%" .. percent .. "* `" .. bar .. [[
`
*Type Forwarded*: `]] .. typef .. "[" .. typesend .. "]`\n\226\156\133: `" .. oked .. "`\n\240\159\154\171: `" .. faild .. [[
`
*Result*: `]] .. resultsend .. "`", "md")
              if x == tonumber(max_x) then
                redis:setex(tablighati .. "fwdcheckleft", tonumber(delay), true)
                return
              end
            end
          end
        end
      else
        redis:del(tablighati .. "fwdcheck")
        tdbot.editMessageText(chatidfwd, msgs, "*" .. checked .. "* of *" .. allchecks .. "* \217\145Forward Compeleted!\n*%100* `[\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136\226\150\136]`\n*Type Forwarded*: `" .. typef .. "[" .. typesend .. "]`\n\226\156\133: `" .. oked .. "`\n\240\159\154\171: `" .. faild .. [[
`
*Result*: `Proccess Ended`]], "md")
      end
    end
    if data._ == "updateSupergroup" then
      if data.supergroup.status._ == "chatMemberStatusBanned" then
        rem(tonumber("-100" .. data.supergroup.id))
        redis:incr(tablighati .. "deletedgroup")
      end
      if not redis:get(tablighati .. "is_fall") and redis:get(tablighati .. "limited") and data.supergroup.status._ == "chatMemberStatusRestricted" and data.supergroup.status.can_send_messages == false then
        tdbot.leave(tonumber("-100" .. data.supergroup.id), tonumber(bot))
        redis:incr(tablighati .. "limitedgps")
        redis:set(tablighati .. "delayname", "\216\174\216\177\217\136\216\172 \216\167\216\178 \218\175\216\177\217\136\217\135 \217\133\216\173\216\175\217\136\216\175 \216\180\216\175\217\135\226\153\187\239\184\143")
      end
    else
      if data._ == "updateNewMessage" then
        local msg = data.message
        function process_link(i, st)
          if st.type and (st.type._ == "chatTypeSupergroup" or st.type._ == "chatTypeBasicGroup") then
            if redis:get(tablighati .. "maxgpmmbr") then
              if st.member_count >= tonumber(redis:get(tablighati .. "maxgpmmbr")) then
                redis:srem(tablighati .. "tabchi_waitforlinks", i.link)
                redis:sadd(tablighati .. "tabchi_checklinks", i.link)
              else
                redis:srem(tablighati .. "tabchi_waitforlinks", i.link)
                redis:sadd(tablighati .. "savedlinks", i.link)
              end
            else
              redis:srem(tablighati .. "tabchi_waitforlinks", i.link)
              redis:sadd(tablighati .. "tabchi_checklinks", i.link)
            end
            if redis:get(tablighati .. "leftname") then
              local checks = redis:smembers(tablighati .. "leftnamecheck")
              for x = 1, #checks do
                local names = st.title
                if names:find(tostring(checks[x])) or names:find(checks[x]) then
                  redis:srem(tablighati .. "tabchi_waitforlinks", i.link)
                  redis:srem(tablighati .. "tabchi_checklinks", i.link)
                end
              end
            end
            if redis:get(tablighati .. "groupleft") then
              if st.type._ == "chatTypeBasicGroup" then
                redis:srem(tablighati .. "tabchi_waitforlinks", i.link)
                redis:srem(tablighati .. "tabchi_checklinks", i.link)
              else
                redis:srem(tablighati .. "tabchi_waitforlinks", i.link)
                redis:sadd(tablighati .. "tabchi_checklinks", i.link)
              end
            end
          elseif st.code == 429 then
            local message = tostring(st.message)
            local join_delay = redis:get(tablighati .. "linkdelay") or 85
            local Time = message:match("%d+") + tonumber(join_delay)
            redis:setex(tablighati .. "tabchi_waitforlinkswait", tonumber(Time), true)
          else
            redis:srem(tablighati .. "tabchi_waitforlinks", i.link)
          end
        end
        function process_join(i, s)
          if s.code == 429 then
            local message = tostring(s.message)
            local join_delay = redis:get(tablighati .. "joindelay") or 85
            local Time = message:match("%d+") + tonumber(join_delay)
            redis:setex(tablighati .. "tabchi_dilay", tonumber(Time), true)
          else
            redis:srem(tablighati .. "tabchi_checklinks", i.link)
            redis:sadd(tablighati .. "savedlinks", i.link)
          end
        end
        function join(text)
          if text:match("https://telegram.me/joinchat/%S+") or text:match("https://t.me/joinchat/%S+") or text:match("https://telegram.dog/joinchat/%S+") then
            local text = text:gsub("t.me", "telegram.me")
            local text = text:gsub("telegram.dog", "telegram.me")
            for link in text:gmatch("(https://telegram.me/joinchat/%S+)") do
              if not redis:sismember(tablighati .. "tabchi_alllinks", link) then
                redis:sadd(tablighati .. "tabchi_alllinks", link)
                redis:sadd(tablighati .. "tabchi_waitforlinks", link)
              end
            end
          end
        end
        if not redis:get(tablighati .. "is_fall") then
          if redis:get(tablighati .. "getcode") and (msg.sender_user_id == 777000 or msg.sender_user_id == 178220800) then
            local c = msg.content.text:gsub("[0123456789:]", {
              ["0"] = "0\226\131\163",
              ["1"] = "1\226\131\163",
              ["2"] = "2\226\131\163",
              ["3"] = "3\226\131\163",
              ["4"] = "4\226\131\163",
              ["5"] = "5\226\131\163",
              ["6"] = "6\226\131\163",
              ["7"] = "7\226\131\163",
              ["8"] = "8\226\131\163",
              ["9"] = "9\226\131\163",
              [":"] = ":\n"
            })
            local txt = os.date("\217\190\219\140\216\167\217\133 \216\167\216\177\216\179\216\167\217\132 \216\180\216\175\217\135 \216\167\216\178 \216\170\217\132\218\175\216\177\216\167\217\133 \216\175\216\177 \216\170\216\167\216\177\219\140\216\174 \240\159\151\147 %Y-%m-%d  \217\136 \216\179\216\167\216\185\216\170 \226\143\176 %X  (\216\168\217\135 \217\136\217\130\216\170 \216\179\216\177\217\136\216\177)")
            print(msg.content.text)
            for k, v in ipairs(redis:smembers(tablighati .. "sudos")) do
              tdbot.sendmsg(v, txt .. [[


]] .. c, 0, "ht")
            end
          end
          if redis:get(tablighati .. "tabchi_save") and msg.content._ == "messageContact" then
            local id = msg.content.contact.user_id
            if not redis:sismember(tablighati .. "tabchi_contacts_id", id) then
              redis:sadd(tablighati .. "tabchi_contacts_id", id)
              local first = msg.content.contact.first_name or "-"
              local last = msg.content.contact.last_name or "-"
              local phone = msg.content.contact.phone_number
              local id = msg.content.contact.user_id
              tdbot.importcontact(phone, first, last, id)
              if redis:get(tablighati .. "sendcontact") and msg.sender_user_id ~= bot then
                local fname = redis:get(tablighati .. "botfname")
                local lname = redis:get(tablighati .. "botlname") or ""
                local num = redis:get(tablighati .. "botnum")
                tdbot.inputMessageContact(msg.chat_id, msg.id, num, fname, lname, bot)
              end
              if redis:get(tablighati .. "additext") then
                local addi = redis:srandmember(tablighati .. "additexts", 1)
                tdbot.sendmsg(msg.chat_id, addi[math.random(#addi)], msg.id, "ht")
              else
                local addi = {
                  "\216\167\216\175\219\140 \217\133\216\177\216\179\219\140 \216\167\217\135\226\152\186\240\159\141\146",
                  "\216\167\216\175\219\140 \216\172\219\140\218\175\216\177 \216\168\217\190\216\177 \217\190\219\140\217\136\219\140\240\159\164\164\240\159\141\137",
                  "\216\167\216\175\216\170 \218\169\216\177\216\175\217\133 \216\170\219\140\216\178 \217\190\219\140\217\136\219\140\217\133 \216\168\216\167\216\180\240\159\152\145\240\159\153\132\240\159\152\128",
                  "Addi bia pv\240\159\152\134\240\159\152\141",
                  "addi tiz sik pv\240\159\164\147\240\159\153\132",
                  "\216\167\216\175\219\140 \216\185\216\180\216\174\217\133 \216\168\217\190\216\177 \217\190\219\140\217\136\219\140 \240\159\152\137\240\159\152\134\240\159\152\141",
                  "\216\167\216\175\219\140 \217\190\219\140\217\136\219\140 \217\134\217\130\216\183\217\135 \216\168\217\134\216\175\216\167\216\178\240\159\152\147\240\159\164\167\240\159\142\136",
                  "\216\167\216\175\219\140 \216\168\219\140\216\167 \217\190\219\140\217\136\219\140\216\140 \216\167\216\175\216\170\217\133 \216\168\216\167\216\178 \218\169\217\134",
                  "\216\167\216\175\219\140 \216\140 \217\135\219\140\216\185",
                  "\216\170\217\136 \217\135\217\133 \216\167\216\175 \218\169\216\177\216\175\217\133",
                  "\216\170\217\136 \217\135\217\133 \216\167\216\175\219\140 (:",
                  "\216\167\216\175\216\170 \218\169\216\177\216\175\217\133 ^_^",
                  "\216\167\216\175\219\140 \216\170\219\140\216\178 \217\190\219\140\217\136\219\140 \217\133\216\177\216\179\219\140",
                  "addi \226\153\165\226\153\165",
                  "adi amo :))",
                  "add :'("
                }
                tdbot.sendmsg(msg.chat_id, addi[math.random(#addi)], msg.id, "ht")
              end
            else
              tdbot.sendmsg(msg.chat_id, "\216\180\217\133\216\167\216\177\216\170 \216\176\216\174\219\140\216\177\216\179 \218\169\217\135 :)", msg.id, "ht")
            end
          end
          if redis:get(tablighati .. "tabchi_markread") then
            tdbot.openChat(msg.chat_id, dl_cb, nil)
            tdbot.markread(msg.chat_id, msg.id, dl_cb, nil)
          end
          if redis:get(tablighati .. "channelleft") and not msg.forward_info and msg.is_channel_post == true then
            tdbot.leave(tonumber(msg.chat_id), tonumber(bot))
            rem(msg.chat_id)
            redis:incr(tablighati .. "channels")
            redis:set(tablighati .. "delayname", "\216\174\216\177\217\136\216\172 \216\167\216\178 \218\169\216\167\217\134\216\167\217\132\226\153\187\239\184\143")
          end
          if redis:get(tablighati .. "groupleft") and tostring(msg.chat_id):match("-") and not tostring(msg.chat_id):match("-100") then
            tdbot.leave(tonumber(msg.chat_id), tonumber(bot))
            rem(msg.chat_id)
            redis:incr(tablighati .. "groups")
            redis:set(tablighati .. "delayname", "\216\174\216\177\217\136\216\172 \216\167\216\178 \218\175\216\177\217\136\217\135\226\153\187\239\184\143")
          end
          if redis:get(tablighati .. "autoleave") and not redis:get(tablighati .. "autoleavetime") and (tostring(msg.chat_id):match("-") or tostring(msg.chat_id):match("-100")) then
            tdbot.leave(tonumber(msg.chat_id), tonumber(bot))
            rem(msg.chat_id)
            redis:set(tablighati .. "delayname", "\216\174\216\177\217\136\216\172 \216\174\217\136\216\175\218\169\216\167\216\177\226\153\187\239\184\143")
            redis:setex(tablighati .. "autoleavetime", 2, true)
          end
          if redis:get(tablighati .. "maxlink") and not redis:get(tablighati .. "tabchi_waitforlinkswait") and redis:scard(tablighati .. "tabchi_waitforlinks") ~= 0 then
            local links = redis:smembers(tablighati .. "tabchi_waitforlinks")
            local max_x = 2
            local delay = 50
            for x = 1, #links do
              tdbot.checkChatInviteLink(links[x], process_link, {
                link = links[x]
              })
              if x == tonumber(max_x) then
                redis:setex(tablighati .. "tabchi_waitforlinkswait", tonumber(delay), true)
                return
              end
            end
          end
          if redis:get(tablighati .. "maxjoin") and not redis:get(tablighati .. "tabchi_dilay") and redis:scard(tablighati .. "tabchi_checklinks") ~= 0 then
            local links = redis:smembers(tablighati .. "tabchi_checklinks")
            local max_x = 2
            local delay = 30
            for x = 1, #links do
              tdbot.import_link(links[x], process_join, {
                link = links[x]
              })
              if x == tonumber(max_x) then
                redis:setex(tablighati .. "tabchi_dilay", tonumber(delay), true)
                return
              end
            end
          end
          if redis:get(tablighati .. "tabchi_autojoin") and msg.content.caption then
            join(msg.content.caption)
          end
          if redis:get(tablighati .. "maxgroup") then
            if tonumber(redis:scard(tablighati .. "tabchi_sugp")) >= (tonumber(redis:get(tablighati .. "maxgroup")) or 500) then
              redis:del(tablighati .. "maxjoin")
              redis:del(tablighati .. "tabchi_autojoin")
              redis:set(tablighati .. "delayname", "\216\177\216\179\219\140\216\175\217\134 \216\168\217\135 \216\173\216\175\216\167\218\169\216\171\216\177 \218\175\216\177\217\136\217\135\226\153\187\239\184\143")
            end
          end
        end
        if msg.content._ == "messageText" then
          IDGP = tostring(msg.chat_id)
          if not redis:sismember(tablighati .. "all", IDGP) then
            if IDGP:match("^-100") then
              redis:sadd(tablighati .. "tabchi_sugp", IDGP)
              redis:sadd(tablighati .. "all", IDGP)
            end
            if not IDGP:match("^-") then
              redis:sadd(tablighati .. "tabchi_pv", IDGP)
              redis:sadd(tablighati .. "all", IDGP)
            end
            if IDGP:match("^-") and not IDGP:match("^-100") then
              redis:sadd(tablighati .. "tabchi_gp", IDGP)
              redis:sadd(tablighati .. "all", IDGP)
            end
          end
          if not redis:get(tablighati .. "is_fall") then
            if redis:get(tablighati .. "tabchi_autojoin") then
              join(msg.content.text)
            end
            if redis:get(tablighati .. "leftname") then
              function check_abc(extra, result, success)
                local checks = redis:smembers(tablighati .. "leftnamecheck")
                for x = 1, #checks do
                  local names = result.title
                  local bot = redis:get(tablighati .. "botid")
                  if names:find(tostring(checks[x])) or names:find(checks[x]) then
                    tdbot.leave(tonumber(result.id), tonumber(bot))
                    rem(result.id)
                    redis:incr(tablighati .. "specials")
                    redis:set(tablighati .. "delayname", "\216\174\216\177\217\136\216\172 \216\167\216\178 \218\175\216\177\217\136\217\135 \216\168\216\167\216\167\216\179\216\167\217\133\219\140 \216\174\216\167\216\181\226\153\187\239\184\143")
                  end
                end
              end
              tdbot.getChat(msg.chat_id, check_abc)
            end
          end
          if msg.content.text:match("^#") and is_admin(msg.sender_user_id) then
            if msg.content.text:match("^#addsudo (%d+)") and is_sudo(msg.sender_user_id) then
              local matches = msg.content.text:match("^#addsudo (%d+)")
              local text = matches .. " _User promoted_ to `SUDO`"
              redis:sadd(tablighati .. "sudos", matches)
              tdbot.sendmsg(msg.chat_id, text, msg.id, "md")
            end
            if msg.content.text == "#sudolist" then
              local text = msg.content.text
              for k, v in pairs(redis:smembers(tablighati .. "sudos")) do
                text = text .. "SUDO `" .. k .. "` > *" .. v .. "*\n"
              end
              tdbot.sendmsg(msg.chat_id, text, msg.id, "md")
            end
            if msg.content.text == "#sudoalllist" then
              local text = msg.content.text
              for k, v in pairs(redis:smembers(tablighati .. "owner")) do
                text = text .. "OWNER `" .. k .. "` > *" .. v .. "*\n"
              end
              tdbot.sendmsg(msg.chat_id, text, msg.id, "md")
            end
            if msg.content.text:match("^#remsudo (%d+)") and is_sudo(msg.sender_user_id) then
              local matches = msg.content.text:match("^#remsudo (%d+)")
              local text = matches .. " _User Demoted_ from `SUDO`"
              redis:srem(tablighati .. "sudos", matches)
              tdbot.sendmsg(msg.chat_id, text, msg.id, "md")
            end
            if msg.content.text:match("^#addallsudo (%d+)") and is_pouya(msg.sender_user_id) then
              local matches = msg.content.text:match("^#addallsudo (%d+)")
              local text = matches .. " _User promoted_ to ALL `SUDO`"
              redis:sadd(tablighati .. "owner", matches)
              tdbot.sendmsg(msg.chat_id, text, msg.id, "md")
            end
            if msg.content.text:match("^#remallsudo (%d+)") and is_pouya(msg.sender_user_id) then
              local matches = msg.content.text:match("^#remallsudo (%d+)")
              local text = matches .. " _User Demoted_ from ALL `SUDO`"
              redis:srem(tablighati .. "owner", matches)
              tdbot.sendmsg(msg.chat_id, text, msg.id, "md")
            end
            if msg.content.text:match("^#addtoall (%d+)$") then
              local matches = msg.content.text:match("^#addtoall (%d+)$")
              local fff = redis:smembers(tablighati .. "tabchi_sugp")
              local sss = redis:smembers(tablighati .. "tabchi_gp")
              for i = 1, #fff do
                tdbot.add_user(fff[i], tonumber(matches))
              end
              for i = 1, #sss do
                tdbot.add_user(sss[i], tonumber(matches))
              end
              tdbot.sendmsg(msg.chat_id, "*It added to All Groups and SuperGroups!*", msg.id, "md")
              redis:set(tablighati .. "delayname", "\216\167\217\129\216\178\217\136\216\175\217\134 \218\169\216\167\216\177\216\168\216\177 \216\168\217\135 \218\175\216\177\217\136\217\135 \217\135\216\167\226\153\187\239\184\143")
            end
            if msg.content.text:match("^#(addaddi) (.*)$") then
              local matches = msg.content.text:match("^#addaddi (.*)$")
              if not redis:sismember(tablighati .. "additexts", matches) then
                redis:sadd(tablighati .. "additexts", matches)
                redis:set(tablighati .. "additext", true)
                tdbot.sendmsg(msg.chat_id, "*Name* " .. matches .. " _Added to List_", msg.id, "md")
              else
                tdbot.sendmsg(msg.chat_id, "*Name* " .. matches .. " _was in List_", msg.id, "md")
              end
            end
            if msg.content.text:match("^#(setseen) (%d+)$") then
              local matches = msg.content.text:match("^#setseen (%d+)$")
              redis:set(tablighati .. "fwdseen", true)
              redis:set(tablighati .. "seen", matches)
              tdbot.sendmsg(msg.chat_id, [[
_Seen forwarding_ seted to `ON`
*Number of seen* seted to]] .. matches, msg.id, "md")
            end
            if msg.content.text == "#delseen" then
              redis:del(tablighati .. "fwdseen")
              redis:del(tablighati .. "seen")
              tdbot.sendmsg(msg.chat_id, "_Seen forwarding_ seted to `OFF`", msg.id, "md")
            end
            if msg.content.text:match("^#(setname) (.*)$") then
              local matches = msg.content.text:match("^#setname (.*)$")
              tdbot.changeName(matches, "", dl_cb, nil)
              tdbot.sendmsg(msg.chat_id, "*Tablighati* `Name` Changed to " .. matches, msg.id, "md")
            end
            if msg.content.text:match("^#(setbio) (.*)$") then
              local matches = msg.content.text:match("^#setbio (.*)$")
              tdbot.changeAbout(matches, dl_cb, nil)
              tdbot.sendmsg(msg.chat_id, "*Tablighati* `Bio` Changed to " .. matches, msg.id, "md")
            end
            if msg.content.text:match("^#(setusername) (.*)$") then
              local matches = msg.content.text:match("^#setusername (.*)$")
              tdbot.changeUsername(matches, dl_cb, nil)
              tdbot.sendmsg(msg.chat_id, "*Tablighati* `Username` Changed to " .. matches, msg.id, "md")
            end
            if msg.content.text:match("^#(addlname) (.*)$") then
              local matches = msg.content.text:match("^#addlname (.*)$")
              if not redis:sismember(tablighati .. "leftnamecheck", matches) then
                redis:sadd(tablighati .. "leftnamecheck", matches)
                tdbot.sendmsg(msg.chat_id, "*Name* " .. matches .. " _Added to List_", msg.id, "md")
              else
                tdbot.sendmsg(msg.chat_id, "*Name* " .. matches .. " _was in List_", msg.id, "md")
              end
            end
            if msg.content.text:match("^#(remlname) (.*)$") then
              local matches = msg.content.text:match("^#remlname (.*)$")
              if not redis:sismember(tablighati .. "leftnamecheck", matches) then
                tdbot.sendmsg(msg.chat_id, "*Name* " .. matches .. " _wasn't in List_", msg.id, "md")
              else
                tdbot.sendmsg(msg.chat_id, "*Name* " .. matches .. " _Removed from List_", msg.id, "md")
                redis:srem(tablighati .. "leftnamecheck", matches)
              end
            end
            if msg.content.text:match("^#minmember (%d+)") then
              local minm = msg.content.text:match("^#minmember (%d+)")
              redis:set(tablighati .. "maxgpmmbr", minm)
              tdbot.sendmsg(msg.chat_id, "_Min Tabi Groups Members_ seted to `" .. minm .. " Groups`", msg.id, "md")
            end
            if msg.content.text:match("^#maxgroup (%d+)") then
              local maxg = msg.content.text:match("^#maxgroup (%d+)")
              redis:set(tablighati .. "maxgroup", maxg)
              tdbot.sendmsg(msg.chat_id, "_Max Tabi Groups_ seted to `" .. maxg .. " Groups`", msg.id, "md")
            end
            if msg.content.text:match("^#(remaddi) (.*)$") then
              local matches = msg.content.text:match("^#remaddi (.*)$")
              if not redis:sismember(tablighati .. "additexts", matches) then
                tdbot.sendmsg(msg.chat_id, "*Name* `" .. matches .. "` _wasn't in List_", msg.id, "md")
              else
                tdbot.sendmsg(msg.chat_id, "*Name* `" .. matches .. "` _Removed from List_", msg.id, "md")
                redis:srem(tablighati .. "additexts", matches)
                redis:del(tablighati .. "additext")
              end
            end
            if msg.content.text:match("^#start @(.*)") then
              do
                local username = msg.content.text:match("^#start @(.*)")
                tdbot.searchpublic(username, function(i, stags)
                  if stags.id then
                    tdbot.sendBotStartMessage(stags.id, stags.id)
                    tdbot.sendmsg(msg.chat_id, "*Robot* With `ID: " .. stags.id .. "` _Started!_", msg.id, "md")
                    redis:set(tablighati .. "delayname", "\216\167\216\179\216\170\216\167\216\177\216\170 \216\177\216\168\216\167\216\170 @" .. username .. " \226\153\187\239\184\143")
                  else
                    tdbot.sendmsg(msg.chat_id, "*Not Found!*", msg.id, "md")
                  end
                end, nil)
              end
            else
            end
            if msg.content.text:match("^#addtoall @(.*)$") then
              local matches = msg.content.text:match("^#addtoall @(.*)$")
              local list = {
                redis:smembers(tablighati .. "tabchi_gp"),
                redis:smembers(tablighati .. "tabchi_sugp")
              }
              local l = {}
              for a, b in pairs(list) do
                for i, v in pairs(b) do
                  table.insert(l, v)
                end
              end
              local max_i = redis:get(tablighati .. "sendmax") or 5
              local delay = redis:get(tablighati .. "senddelay") or 2
              if #l == 0 then
              end
              local during = #l / tonumber(max_i)
              tonumber(delay)
              tdbot.sendmsg(msg.chat_id, [[
*Process* Adding is _Begining_!
_End_ in `]] .. during .. " seconds`", msg.id, "md")
              redis:setex(tablighati .. "delay", math.ceil(tonumber(during)), true)
              redis:set(tablighati .. "delayname", "\216\167\217\129\216\178\217\136\216\175\217\134 \216\168\217\135 \217\135\217\133\217\135\226\153\187\239\184\143")
              tdbot.searchpublic(matches, function(I, st)
                if st.id then
                  tdbot.addChatMemberCB(tonumber(I.list[tonumber(I.n)]), st.id, adding, {
                    list = I.list,
                    max_i = I.max_i,
                    delay = I.delay,
                    n = tonumber(I.n),
                    all = I.all,
                    chat_id = I.chat_id,
                    user_id = I.user_id,
                    s = I.s
                  })
                end
              end, {
                list = l,
                max_i = max_i,
                delay = delay,
                n = 1,
                all = #l,
                chat_id = msg.chat_id,
                user_id = matches,
                s = 0
              })
            end
            if msg.content.text:match("^#echo (.*)") then
              local text = msg.content.text:match("^#echo (.*)")
              tdbot.sendmsg(msg.chat_id, text, 0, "ht")
            end
            if msg.content.text == "#info" then
              local gp = redis:scard(tablighati .. "tabchi_gp") or 0
              local sugp = redis:scard(tablighati .. "tabchi_sugp") or 0
              local pvsn = redis:scard(tablighati .. "tabchi_pv") or 0
              local s = redis:ttl(tablighati .. "tabchi_dilay") or 0
              local ss = redis:ttl(tablighati .. "tabchi_waitforlinkswait") or 0
              local wlinks = redis:scard(tablighati .. "tabchi_waitforlinks") or 0
              local glinks = redis:scard(tablighati .. "tabchi_checklinks") or 0
              local slinks = redis:scard(tablighati .. "savedlinks") or 0
              local limitedgp = redis:get(tablighati .. "limitedgps") or 0
              local channels = redis:get(tablighati .. "channels") or 0
              local groupsl = redis:get(tablighati .. "groups") or 0
              local special = redis:get(tablighati .. "specials") or 0
              local idbot = redis:get(tablighati .. "botid") or "N/A"
              local name = redis:get(tablighati .. "botfname") or "N/A"
              local lastname = redis:get(tablighati .. "botlname") or ""
              local phone = redis:get(tablighati .. "botnum") or "N/A"
              local join = redis:get(tablighati .. "maxjoin") and "\226\156\133" or "\240\159\154\171"
              local findlink = redis:get(tablighati .. "tabchi_autojoin") and "\226\156\133" or "\240\159\154\171"
              local oklink = redis:get(tablighati .. "maxlink") and "\226\156\133" or "\240\159\154\171"
              local addcontacts = redis:get(tablighati .. "tabchi_save") and "\226\156\133" or "\240\159\154\171"
              local channelleft = redis:get(tablighati .. "channelleft") and "\226\156\133" or "\240\159\154\171"
              local groupleft = redis:get(tablighati .. "groupleft") and "\226\156\133" or "\240\159\154\171"
              local leftname = redis:get(tablighati .. "leftname") and "\226\156\133" or "\240\159\154\171"
              tdbot.searchContacts(function(i, st)
                redis:set(tablighati .. "tabchi_contacts", tonumber(st.total_count))
              end)
              local conts = redis:get(tablighati .. "tabchi_contacts") or 0
              local admins = redis:scard(tablighati .. "sudos") or 0
              local links = redis:scard(tablighati .. "tabchi_alllinks") or 0
              local who_mark = redis:get(tablighati .. "tabchi_markread") and "\226\156\133" or "\240\159\154\171"
              local sharecontact = redis:get(tablighati .. "sendcontact") and "\226\156\133" or "\240\159\154\171"
              local limit_left = redis:get(tablighati .. "limited") and "\226\156\133" or "\240\159\154\171"
              local addi = redis:get(tablighati .. "additext") and "\226\156\133" or "\240\159\154\171"
              local maxgroup = redis:get(tablighati .. "maxgroup") or "N/A"
              local configs = redis:get(tablighati .. "Options") and "\226\156\133" or "\240\159\154\171"
              local getcode = redis:get(tablighati .. "getcode") and "\226\156\133" or "\240\159\154\171"
              local autoleave = redis:get(tablighati .. "autoleave") and "\226\156\133" or "\240\159\154\171"
              local minmember = redis:get(tablighati .. "maxgpmmbr") or "N/A"
              local delayename = redis:get(tablighati .. "delayname") or "N/A"
              local antispam = redis:get(tablighati .. "antispam") and "\226\156\133" or "\240\159\154\171"
              local fpro = redis:get(tablighati .. "fwdcheck") and "\226\156\133" or "\240\159\154\171"
              local deletedgroup = redis:get(tablighati .. "deletedgroup") or 0
              local antispams = redis:get(tablighati .. "antispams") or 0
              local percent = redis:get(tablighati .. "percent") or 0
              local barf = redis:get(tablighati .. "barfcheck") or "[          ]"
              local text = "\240\159\142\136 \217\133\216\180\216\174\216\181\216\167\216\170 \216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140 `" .. tablighati .. ":`" .. "\n_\226\150\170\239\184\143\216\167\219\140\216\175\219\140 \216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140_ : `" .. idbot .. "`" .. "\n_\226\150\171\239\184\143\217\134\216\167\217\133 \216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140_ : `" .. name .. " " .. lastname .. "`" .. "\n_\226\150\170\239\184\143\216\180\217\133\216\167\216\177\217\135 \216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140_ : `" .. phone .. "+`" .. "\n\n\240\159\145\129\226\128\141\240\159\151\168 \216\162\217\133\216\167\216\177 \217\135\216\167:" .. "\n_\226\150\171\239\184\143\216\179\217\136\217\190\216\177\218\175\216\177\217\136\217\135 \217\135\216\167_ : `" .. sugp .. "`" .. "\n_\226\150\170\239\184\143\218\175\216\177\217\136\217\135 \217\135\216\167\219\140 \217\133\216\185\217\133\217\136\217\132\219\140_ : `" .. gp .. "`" .. "\n_\226\150\171\239\184\143\217\133\216\174\216\167\216\183\216\168\219\140\217\134_ : `" .. conts .. "`" .. "\n_\226\150\170\239\184\143\218\134\216\170 \217\135\216\167\219\140 \216\174\216\181\217\136\216\181\219\140_ : `" .. pvsn .. "`" .. "\n_\226\150\171\239\184\143\216\167\216\175\217\133\219\140\217\134 \217\135\216\167_ : `" .. admins .. "`" .. "\n_\226\150\170\239\184\143\217\132\219\140\217\134\218\169 \217\135\216\167_ : `" .. links .. "`" .. "\n_\226\150\171\239\184\143\217\132\219\140\217\134\218\169 \217\135\216\167\219\140 \216\175\216\177 \216\167\217\134\216\170\216\184\216\167\216\177_ : `" .. wlinks .. "`" .. "\n_\226\150\170\239\184\143\217\132\219\140\217\134\218\169 \217\135\216\167\219\140 \216\185\216\182\217\136\219\140\216\170_ : `" .. glinks .. "`" .. "\n_\226\150\171\239\184\143\217\132\219\140\217\134\218\169 \217\135\216\167\219\140 \216\176\216\174\219\140\216\177\217\135 \216\180\216\175\217\135_ : `" .. slinks .. "`" .. "\n_\226\150\170\239\184\143\218\175\216\177\217\136\217\135 \217\135\216\167\219\140 \217\133\216\173\216\175\217\136\216\175 \216\180\216\175\217\135_ : `" .. limitedgp .. "`" .. "\n_\226\150\171\239\184\143\218\169\216\167\217\134\216\167\217\132 \217\135\216\167\219\140 \216\174\216\167\216\177\216\172 \216\180\216\175\217\135_ : `" .. channels .. "`" .. "\n_\226\150\170\239\184\143\218\175\216\177\217\136\217\135 \217\135\216\167\219\140 \216\174\216\167\216\177\216\172 \216\180\216\175\217\135_ : `" .. groupsl .. "`" .. "\n_\226\150\171\239\184\143\218\175\216\177\217\136\217\135 \217\135\216\167 \216\168\216\167\216\167\216\179\216\167\217\133\219\140 \216\174\216\167\216\181_ : `" .. special .. "`" .. "\n_\226\150\170\239\184\143\218\175\216\177\217\136\217\135 \217\135\216\167\219\140 \216\173\216\176\217\129 \216\180\216\175\217\135_ : `" .. deletedgroup .. "`" .. "\n_\226\150\171\239\184\143\218\175\216\177\217\136\217\135 \216\175\216\167\216\177\216\167\219\140 \216\182\216\175\217\132\219\140\217\134\218\169_ : `" .. antispams .. "`" .. "\n\n\240\159\147\178 \216\170\217\134\216\184\219\140\217\133\216\167\216\170:" .. "\n_\226\150\170\239\184\143\216\185\216\182\217\136\219\140\216\170 \216\167\216\170\217\136\217\133\216\167\216\170\219\140\218\169_ : " .. join .. "\n_\226\150\171\239\184\143\216\180\217\134\216\167\216\179\216\167\219\140\219\140 \217\132\219\140\217\134\218\169_ : " .. findlink .. "\n_\226\150\170\239\184\143\216\170\216\167\219\140\219\140\216\175 \217\132\219\140\217\134\218\169_ : " .. oklink .. "\n_\226\150\171\239\184\143\216\167\217\129\216\178\217\136\216\175\217\134 \217\133\216\174\216\167\216\183\216\168_ : " .. addcontacts .. "\n_\226\150\170\239\184\143\216\174\216\177\217\136\216\172 \216\167\216\178 \218\169\216\167\217\134\216\167\217\132_ : " .. channelleft .. "\n_\226\150\171\239\184\143\216\174\216\177\217\136\216\172 \216\167\216\178 \218\175\216\177\217\136\217\135_ : " .. groupleft .. "\n_\226\150\170\239\184\143\216\174\216\177\217\136\216\172 \216\167\216\178 \218\175\216\177\217\136\217\135 \216\168\216\167\216\167\216\179\216\167\217\133\219\140 \216\174\216\167\216\181_ : " .. leftname .. "\n_\226\150\171\239\184\143\216\174\216\177\217\136\216\172 \216\167\216\178\218\175\217\190 \217\135\216\167 \217\133\216\173\216\175\217\136\216\175 \216\180\216\175\217\135_ : " .. limit_left .. "\n_\226\150\170\239\184\143\217\133\216\180\216\167\217\135\216\175\217\135 \218\134\216\170 \217\135\216\167_ : " .. who_mark .. "\n_\226\150\171\239\184\143\217\190\219\140\216\167\217\133 \216\167\217\129\216\178\217\136\216\175\217\134 \216\174\216\167\216\181 \217\133\216\174\216\167\216\183\216\168_ : " .. addi .. "\n_\226\150\170\239\184\143\216\167\216\177\216\179\216\167\217\132 \216\180\217\133\216\167\216\177\217\135 \217\135\217\134\218\175\216\167\217\133 \216\167\217\129\216\178\217\136\216\175\217\134_ : " .. sharecontact .. "\n_\226\150\171\239\184\143\216\175\216\177\219\140\216\167\217\129\216\170 \217\190\219\140\216\167\217\133 \217\135\216\167\219\140 \216\170\217\132\218\175\216\177\216\167\217\133_ : " .. getcode .. "\n_\226\150\170\239\184\143\218\169\216\167\217\134\217\129\219\140\218\175 \216\170\217\134\216\184\219\140\217\133\216\167\216\170 td_ : " .. configs .. "\n_\226\150\171\239\184\143\216\174\216\177\217\136\216\172 \216\167\216\178 \218\175\216\177\217\136\217\135 \216\175\216\167\216\177\216\167\219\140 \216\177\216\168\216\167\216\170 \216\182\216\175\217\132\219\140\217\134\218\169_ : " .. antispam .. "\n_\226\150\170\239\184\143\216\174\216\177\217\136\216\172 \216\174\217\136\216\175\218\169\216\167\216\177 \216\167\216\178 \218\175\216\177\217\136\217\135 \217\135\216\167_ : " .. autoleave .. "\n_\226\150\171\239\184\143\217\129\217\136\216\177\217\136\216\167\216\177\216\175 \217\190\219\140\216\180\216\177\217\129\216\170\217\135 \216\178\217\133\216\167\217\134\216\175\216\167\216\177_ : " .. fpro .. "\n\n\240\159\142\180 \216\185\217\133\217\132\219\140\216\167\216\170 \217\135\216\167:" .. "\n_\226\150\170\239\184\143\216\173\216\175\216\167\218\169\216\171\216\177 \218\175\216\177\217\136\217\135 \217\130\216\167\216\168\217\132 \216\185\216\182\217\136\219\140\216\170_ : `" .. maxgroup .. "`" .. "\n_\226\150\171\239\184\143\216\173\216\175\216\167\217\130\217\132 \216\167\216\185\216\182\216\167\219\140 \218\175\216\177\217\136\217\135_ : `" .. minmember .. "`" .. "\n_\226\150\170\239\184\143\216\178\217\133\216\167\217\134 \216\170\216\167 \216\170\216\167\219\140\219\140\216\175 \217\132\219\140\217\134\218\169_ : `" .. tostring(ss) .. " \216\171\216\167\217\134\219\140\217\135`" .. "\n_\226\150\171\239\184\143\216\178\217\133\216\167\217\134 \216\170\216\167 \216\185\216\182\217\136\219\140\216\170 \217\133\216\172\216\175\216\175_ : `" .. tostring(s) .. " \216\171\216\167\217\134\219\140\217\135`" .. "\n_\226\150\170\239\184\143\216\162\216\174\216\177\219\140\217\134 \216\185\217\133\217\132\219\140\216\167\216\170 \216\174\217\136\216\175\218\169\216\167\216\177 \216\167\217\134\216\172\216\167\217\133 \216\180\216\175\217\135_ :\n `" .. delayename .. "`" .. "\n_\226\150\171\239\184\143\216\175\216\177\216\181\216\175 \216\167\217\134\216\172\216\167\217\133 \216\180\216\175\217\135 \217\129\217\136\216\177\217\136\216\167\216\177\216\175\217\190\219\140\216\180\216\177\217\129\216\170\217\135_ :\n *%" .. percent .. "* `" .. barf .. "`" .. "\n\n\226\156\140\240\159\143\187\216\170\217\136\216\179\216\185\217\135 \216\175\217\135\217\134\216\175\217\135 : @CaltMan" .. "\n\226\156\141\240\159\143\187\218\169\216\167\217\134\216\167\217\132 \216\177\216\179\217\133\219\140 : @Stags"
              tdbot.sendmsg(msg.chat_id, text, msg.id, "md")
            end
            if msg.content.text == "#bc su" and msg.reply_to_message_id then
              sau = redis:smembers(tablighati .. "tabchi_sugp")
              for i = 1, #sau do
                tdbot.sendmsg(sau[i], msg.reply_to_message_id, 0, "ht")
              end
              tdbot.sendmsg(msg.chat_id, "*It Sended* to `" .. #sau .. " Supergroups!`", msg.id, "md")
            end
            if msg.content.text == "#savenumber on" then
              redis:set(tablighati .. "tabchi_save", "ok")
              tdbot.sendmsg(msg.chat_id, "_Save Contacts Number_ Seted to `ON`", msg.id, "md")
            end
            if msg.content.text == "#savenumber off" then
              redis:del(tablighati .. "tabchi_save")
              tdbot.sendmsg(msg.chat_id, "_Save Contacts Number_ Seted to `OFF`", msg.id, "md")
            end
            if msg.content.text == "#bc gp" and msg.reply_to_message_id then
              gap = redis:smembers(tablighati .. "tabchi_gp")
              for i = 1, #gap do
                tdbot.sendmsg(gap[i], msg.reply_to_message_id, 0, "ht")
              end
              tdbot.sendmsg(msg.chat_id, "*It Sended* to `" .. #gap .. " Groups!`", msg.id, "md")
            end
            if msg.content.text == "#bc pv" and msg.reply_to_message_id then
              redis:set(tablighati .. "tabchi_bc_pv", "ok")
              pav = redis:smembers(tablighati .. "tabchi_pv")
              for i = 1, #pav do
                tdbot.sendmsg(pav[i], msg.reply_to_message_id, 0, "ht")
              end
              tdbot.sendmsg(msg.chat_id, "*It Sended* to `" .. #pav .. " Pvs!`", msg.id, "md")
            end
            if msg.content.text == "#addmembers" then
              local add = redis:smembers(tablighati .. "tabchi_contacts_id")
              for i = 1, #add do
                tdbot.add_user(msg.chat_id, tonumber(add[i]))
              end
              tdbot.sendmsg(msg.chat_id, "*Contacts Succssesfully Added to Group*", msg.id, "md")
              redis:set(tablighati .. "delayname", "\216\167\217\129\216\178\217\136\216\175\217\134 \217\133\216\174\216\167\216\183\216\168\219\140\217\134 \216\168\217\135 \218\175\216\177\217\136\217\135\226\153\187\239\184\143")
            end
            if msg.content.text == "#getcode on" then
              redis:set(tablighati .. "getcode", "ok")
              tdbot.sendmsg(msg.chat_id, "*Status* _Get Telegram Code_ Seted to `ON`", msg.id, "md")
            end
            if msg.content.text == "#getcode off" then
              redis:del(tablighati .. "getcode")
              tdbot.sendmsg(msg.chat_id, "*Status* _Get Telegram Code_ Seted to `OFF`", msg.id, "md")
            end
            if msg.content.text == "#antispamgp on" then
              redis:set(tablighati .. "antispam", "ok")
              tdbot.sendmsg(msg.chat_id, "*Status* _Left from Groups with Antispam bot_ Seted to `ON`", msg.id, "md")
            end
            if msg.content.text == "#antispamgp off" then
              redis:del(tablighati .. "antispam")
              tdbot.sendmsg(msg.chat_id, "*Status* _Left from Groups with Antispam bot_ Seted to `OFF`", msg.id, "md")
            end
            if msg.content.text == "#leftname on" then
              redis:set(tablighati .. "leftname", "ok")
              tdbot.sendmsg(msg.chat_id, "*Status* _Left from spicail Group Name_ Seted to `ON`", msg.id, "md")
            end
            if msg.content.text == "#leftname off" then
              redis:del(tablighati .. "leftname")
              tdbot.sendmsg(msg.chat_id, "*Status* _Left from spicail Group Name_ Seted to `OFF`", msg.id, "md")
            end
            if msg.content.text == "#clean lname" then
              local checks = redis:smembers(tablighati .. "leftnamecheck")
              for x = 1, #checks do
                redis:srem(tablighati .. "leftnamecheck", checks[x])
              end
              tdbot.sendmsg(msg.chat_id, "*Spicial Names* list _Cleaned_!", msg.id, "md")
            end
            if msg.content.text == "#clean addi" then
              local checks = redis:smembers(tablighati .. "additexts")
              for x = 1, #checks do
                redis:srem(tablighati .. "additexts", checks[x])
              end
              redis:del(tablighati .. "additext")
              tdbot.sendmsg(msg.chat_id, "*Add contacts welcome* list _Cleaned_!", msg.id, "md")
            end
            if msg.content.text == "#channelleft on" then
              redis:set(tablighati .. "channelleft", "ok")
              tdbot.sendmsg(msg.chat_id, "*Status* _Auto Leave from Channels_ Seted to `ON`", msg.id, "md")
            end
            if msg.content.text == "#channelleft off" then
              redis:del(tablighati .. "channelleft")
              tdbot.sendmsg(msg.chat_id, "*Status* _Auto Leave from Channels_ Seted to `OFF`", msg.id, "md")
            end
            if msg.content.text == "#groupleft on" then
              redis:set(tablighati .. "groupleft", "ok")
              tdbot.sendmsg(msg.chat_id, "*Status* _Auto Leave from Groups_ Seted to `ON`", msg.id, "md")
            end
            if msg.content.text == "#groupleft off" then
              redis:del(tablighati .. "groupleft")
              tdbot.sendmsg(msg.chat_id, "*Status* _Auto Leave from Groups_ Seted to `OFF`", msg.id, "md")
            end
            if msg.content.text == "#ping" then
              tdbot.fwd_msg(msg.chat_id, msg.chat_id, msg.id)
            end
            if msg.content.text == "#online" then
              tdbot.sendmsg(msg.chat_id, "*I'm Just Here* :)", msg.id, "md")
            end
            if msg.content.text == "#reload" then
              tdbot.sendmsg(msg.chat_id, "*File Robot* `Number " .. tablighati .. "` _Started Again_!", msg.id, "md")
              reload()
            end
            if msg.content.text == "#join on" then
              redis:set(tablighati .. "maxjoin", "ok")
              tdbot.sendmsg(msg.chat_id, "*Status* _Joining Groups_ Seted to `ON`", msg.id, "md")
            end
            if msg.content.text == "#join off" then
              redis:del(tablighati .. "maxjoin")
              tdbot.sendmsg(msg.chat_id, "*Status* _Joining Groups_ Seted to `OFF`", msg.id, "md")
            end
            if msg.content.text == "#checklicense" then
              license()
            end
            if msg.content.text == "#restricleft on" then
              redis:set(tablighati .. "limited", "ok")
              tdbot.sendmsg(msg.chat_id, "*Status* _Left from Restriced Groups_ Seted to `ON`", msg.id, "md")
            end
            if msg.content.text == "#restricleft off" then
              redis:del(tablighati .. "limited")
              tdbot.sendmsg(msg.chat_id, "*Status* _Left from Restriced Groups_ Seted to `OFF`", msg.id, "md")
            end
            if msg.content.text == "#findlink on" then
              redis:set(tablighati .. "tabchi_autojoin", "ok")
              tdbot.sendmsg(msg.chat_id, "*Status* _Find Links_ Seted to `ON`", msg.id, "md")
            end
            if msg.content.text == "#findlink off" then
              redis:del(tablighati .. "tabchi_autojoin")
              tdbot.sendmsg(msg.chat_id, "*Status* _Find Links_ Seted to `OFF`", msg.id, "md")
            end
            if msg.content.text == "#oklink on" then
              redis:set(tablighati .. "maxlink", "ok")
              tdbot.sendmsg(msg.chat_id, "*Status* _Okey waiting Links_ Seted to `ON`", msg.id, "md")
            end
            if msg.content.text == "#oklink off" then
              redis:del(tablighati .. "maxlink")
              tdbot.sendmsg(msg.chat_id, "*Status* _Okey waiting Links_ Seted to `OFF`", msg.id, "md")
            end
            if msg.content.text == "#autoleave on" then
              redis:set(tablighati .. "autoleave", "ok")
              tdbot.sendmsg(msg.chat_id, "*Status* _Auto Leave from groups_ Seted to `ON`", msg.id, "md")
            end
            if msg.content.text == "#autoleave off" then
              redis:del(tablighati .. "autoleave")
              tdbot.sendmsg(msg.chat_id, "*Status* _Auto Leave from groups_ Seted to `OFF`", msg.id, "md")
            end
            if msg.content.text == "#sharenumber on" then
              redis:set(tablighati .. "sendcontact", true)
              tdbot.sendmsg(msg.chat_id, "*Status* _Share Tabi Contact_ Seted to `ON`", msg.id, "md")
            end
            if msg.content.text == "#sharenumber off" then
              redis:del(tablighati .. "sendcontact")
              tdbot.sendmsg(msg.chat_id, "*Status* _Share Tabi Contact_ Seted to `OFF`", msg.id, "md")
            end
            if msg.content.text == "#markread on" then
              redis:set(tablighati .. "tabchi_markread", "ok")
              tdbot.sendmsg(msg.chat_id, "*Status* _Mark Read_ Seted to `ON`", msg.id, "md")
            end
            if msg.content.text == "#markread off" then
              redis:del(tablighati .. "tabchi_markread")
              tdbot.sendmsg(msg.chat_id, "*Status* _Mark Read_ Seted to `OFF`", msg.id, "md")
            end
            if msg.content.text == "#fs" and msg.reply_to_message_id then
              local lol = redis:smembers(tablighati .. "tabchi_sugp")
              for i, v in pairs(lol) do
                tdbot.openChat(tonumber(v), dl_cb, nil)
                tdbot.fwd_msg(msg.chat_id, tonumber(v), msg.reply_to_message_id)
              end
              tdbot.sendmsg(msg.chat_id, "Has been _Sent_ to `" .. #lol .. " supergroup`", msg.id, "md")
              if redis:get(tablighati .. "antispam") then
                redis:setex(tablighati .. "fwdtime", 40, true)
              end
              redis:setex(tablighati .. "is_fall", 30, true)
            end
            if msg.content.text == "#ftall" and msg.reply_to_message_id then
              local list = redis:smembers(tablighati .. "all")
              local id = msg.reply_to_message_id
              local max_i = redis:get(tablighati .. "sendmax") or 5
              local delay = redis:get(tablighati .. "senddelay") or 2
              local during = #list / tonumber(max_i)
              tonumber(delay)
              tdbot.sendmsg(msg.chat_id, [[
_Process Forwarding_ is *Begining*!
*End* in `]] .. during .. " seconds`", msg.id, "md")
              redis:setex(tablighati .. "delay", math.ceil(tonumber(during)), true)
              redis:set(tablighati .. "delayname", "\217\129\217\136\216\177\217\136\216\167\216\177\216\175 \216\178\217\133\216\167\217\134\216\175\216\167\216\177\226\153\187\239\184\143")
              tdbot.fwd_msg_time(tonumber(list[1]), msg.chat_id, id, forwarding, {
                list = list,
                max_i = max_i,
                delay = delay,
                n = 1,
                all = #list,
                chat_id = msg.chat_id,
                msg_id = id,
                s = 0
              })
              if redis:get(tablighati .. "antispam") then
                redis:setex(tablighati .. "fwdtime", 180, true)
              end
              redis:setex(tablighati .. "is_fall", 30, true)
            end
            if msg.content.text:match("^#fpro (.*) (%d+)") and msg.reply_to_message_id then
              local typef, delayt = msg.content.text:match("^#fpro (.*) (%d+)")
              local lol2 = redis:smembers(tablighati .. "tabchi_sugp")
              local lol = redis:smembers(tablighati .. "tabchi_gp")
              local lol3 = redis:smembers(tablighati .. "tabchi_pv")
              local lol4 = redis:smembers(tablighati .. "all")
              if typef == "all" then
                redis:set(tablighati .. "allchecks", tonumber(#lol4))
              elseif typef == "sgp" then
                redis:set(tablighati .. "allchecks", tonumber(#lol2))
              elseif typef == "gp" then
                redis:set(tablighati .. "allchecks", tonumber(#lol))
              elseif typef == "pv" then
                redis:set(tablighati .. "allchecks", tonumber(#lol3))
              end
              redis:set(tablighati .. "fwdcheck", true)
              redis:set(tablighati .. "msgidfwd", msg.reply_to_message_id)
              redis:set(tablighati .. "chatidfwd", msg.chat_id)
              redis:set(tablighati .. "delayt", delayt)
              redis:set(tablighati .. "typef", typef)
              redis:del(tablighati .. "fwdchecked")
              redis:del(tablighati .. "fwdcheckoked")
              redis:del(tablighati .. "fwdcheckfaild")
              redis:set(tablighati .. "SendSucceeded", true)
              redis:set(tablighati .. "resetedfcheck", true)
              tdbot.sendmsg(msg.chat_id, "*Tablighati* is going to _ready_ for `pro forwarding`", msg.id, "md")
              redis:setex(tablighati .. "is_fall", tonumber(#lol2), true)
              redis:set(tablighati .. "delayname", "\217\129\217\136\216\177\217\136\216\167\216\177\216\175 \217\190\219\140\216\180\216\177\217\129\216\170\217\135 \216\178\217\133\216\167\217\134\216\175\216\167\216\177\226\153\187\239\184\143")
            end
            if msg.content.text == "#cancel" and redis:get(tablighati .. "fwdcheck") then
              local msgs = redis:get(tablighati .. "msgid")
              local chatidfwd = redis:get(tablighati .. "chatidfwd")
              redis:del(tablighati .. "fwdcheck")
              redis:del(tablighati .. "fwdseen")
              tdbot.editMessageText(chatidfwd, msgs, "*Proccess Canceled*!", "md")
              redis:set(tablighati .. "delayname", "\217\133\216\170\217\136\217\130\217\129 \218\169\216\177\216\175\217\134 \217\129\217\136\216\177\217\136\216\167\216\177\216\175 \217\190\219\140\216\180\216\177\217\129\216\170\217\135 \216\178\217\133\216\167\217\134\216\175\216\167\216\177\226\153\187\239\184\143")
            end
            if msg.content.text == "#resume" then
              local msgs = redis:get(tablighati .. "msgid")
              local chatidfwd = redis:get(tablighati .. "chatidfwd")
              redis:set(tablighati .. "fwdcheck", true)
              if redis:get(tablighati .. "seen") then
                redis:set(tablighati .. "fwdseen", true)
              end
              tdbot.editMessageText(chatidfwd, msgs, "*Proccess Resumed*!", "md")
              redis:set(tablighati .. "delayname", "\216\167\216\175\216\167\217\133\217\135 \217\129\217\136\216\177\217\136\216\167\216\177\216\175 \217\190\219\140\216\180\216\177\217\129\216\170\217\135 \216\178\217\133\216\167\217\134\216\175\216\167\216\177\226\153\187\239\184\143")
            end
            if msg.content.text == "#fall" and msg.reply_to_message_id then
              local lol2 = redis:smembers(tablighati .. "tabchi_sugp")
              local id = msg.reply_to_message_id
              local lol = redis:smembers(tablighati .. "tabchi_gp")
              local lol3 = redis:smembers(tablighati .. "tabchi_pv")
              for i, v in pairs(lol) do
                tdbot.openChat(tonumber(v), dl_cb, nil)
                tdbot.fwd_msg(msg.chat_id, tonumber(v), id)
              end
              for i, v in pairs(lol2) do
                tdbot.openChat(tonumber(v), dl_cb, nil)
                tdbot.fwd_msg(msg.chat_id, tonumber(v), id)
              end
              for i, v in pairs(lol3) do
                tdbot.openChat(tonumber(v), dl_cb, nil)
                tdbot.fwd_msg(msg.chat_id, tonumber(v), id)
              end
              tdbot.sendmsg(msg.chat_id, "Has been _Sent_ to `" .. #lol2 .. " supergroups` and `" .. #lol .. " groups` and `" .. #lol3 .. " pvs`.", msg.id, "md")
              if redis:get(tablighati .. "antispam") then
                redis:setex(tablighati .. "fwdtime", 40, true)
              end
              redis:setex(tablighati .. "is_fall", 30, true)
            end
            if msg.content.text == "#fwdall" and msg.reply_to_message_id then
              local lol2 = redis:smembers(tablighati .. "tabchi_sugp")
              local id = msg.reply_to_message_id
              local lol = redis:smembers(tablighati .. "tabchi_gp")
              for i, v in pairs(lol) do
                tdbot.openChat(tonumber(v), dl_cb, nil)
                tdbot.fwd_msg(msg.chat_id, tonumber(v), id)
              end
              for i, v in pairs(lol2) do
                tdbot.openChat(tonumber(v), dl_cb, nil)
                tdbot.fwd_msg(msg.chat_id, tonumber(v), id)
              end
              tdbot.sendmsg(msg.chat_id, "Has been _Sent_ to `" .. #lol2 .. " supergroups` and `" .. #lol .. " groups.`", msg.id, "md")
              if redis:get(tablighati .. "antispam") then
                redis:setex(tablighati .. "fwdtime", 40, true)
              end
              redis:setex(tablighati .. "is_fall", 30, true)
            end
            if msg.content.text == "#fg" and msg.reply_to_message_id then
              local lol = redis:smembers(tablighati .. "tabchi_gp")
              for i = 1, #lol do
                tdbot.openChat(lol[i], dl_cb, nil)
                tdbot.fwd_msg(msg.chat_id, lol[i], msg.reply_to_message_id)
              end
              tdbot.sendmsg(msg.chat_id, "Has been _Sent_ to `" .. #lol .. " Groups`", msg.id, "md")
              if redis:get(tablighati .. "antispam") then
                redis:setex(tablighati .. "fwdtime", 40, true)
              end
              redis:setex(tablighati .. "is_fall", 30, true)
            end
            if msg.content.text == "#delmaxgroup" then
              redis:del(tablighati .. "maxgroup")
              tdbot.sendmsg(msg.chat_id, "*Max Tabi Groups* _Deleted_", msg.id, "md")
            end
            if msg.content.text == "#delminmember" then
              redis:del(tablighati .. "maxgpmmbr")
              tdbot.sendmsg(msg.chat_id, "*Min Tabi Groups Members* _Deleted_", msg.id, "md")
            end
            if msg.content.text == "#fv" and msg.reply_to_message_id then
              local lol = redis:smembers(tablighati .. "tabchi_pv")
              for i = 1, #lol do
                tdbot.fwd_msg(msg.chat_id, lol[i], msg.reply_to_message_id)
              end
              tdbot.sendmsg(msg.chat_id, "Has been _Sent_ to `" .. #lol .. " Pvs`", msg.id, "md")
              redis:setex(tablighati .. "is_fall", 30, true)
            end
            if msg.content.text == "#reset" then
              local lol1 = redis:smembers(tablighati .. "tabchi_gp")
              for i = 1, #lol1 do
                redis:srem(tablighati .. "tabchi_gp", lol1[i])
              end
              local lol2 = redis:smembers(tablighati .. "tabchi_pv")
              for i = 1, #lol2 do
                redis:srem(tablighati .. "tabchi_pv", lol2[i])
              end
              local lol3 = redis:smembers(tablighati .. "tabchi_sugp")
              for i = 1, #lol3 do
                redis:srem(tablighati .. "tabchi_sugp", lol3[i])
              end
              local lol4 = redis:smembers(tablighati .. "all")
              for i = 1, #lol4 do
                redis:srem(tablighati .. "all", lol4[i])
              end
              local lol5 = redis:smembers(tablighati .. "tabchi_alllinks")
              for i = 1, #lol5 do
                redis:srem(tablighati .. "tabchi_alllinks", lol5[i])
              end
              local lol6 = redis:smembers(tablighati .. "tabchi_waitforlinks")
              for i = 1, #lol6 do
                redis:srem(tablighati .. "tabchi_waitforlinks", lol6[i])
              end
              local lol7 = redis:smembers(tablighati .. "tabchi_checklinks")
              for i = 1, #lol7 do
                redis:srem(tablighati .. "tabchi_checklinks", lol7[i])
              end
              local lol8 = redis:smembers(tablighati .. "savedlinks")
              for i = 1, #lol8 do
                redis:srem(tablighati .. "savedlinks", lol8[i])
              end
              local lol10 = redis:smembers(tablighati .. "addleft_gp")
              for i = 1, #lol10 do
                redis:srem(tablighati .. "addleft_gp", lol10[i])
              end
              local lol11 = redis:smembers(tablighati .. "addall_gp")
              for i = 1, #lol11 do
                redis:srem(tablighati .. "addall_gp", lol11[i])
              end
              local lol12 = redis:smembers(tablighati .. "tableft_gp")
              for i = 1, #lol12 do
                redis:srem(tablighati .. "tableft_gp", lol12[i])
              end
              local lol13 = redis:smembers(tablighati .. "groupforwarded")
              for i = 1, #lol13 do
                redis:srem(tablighati .. "groupforwarded", lol13[i])
              end
              redis:del(tablighati .. "delay")
              redis:del(tablighati .. "limitedgps")
              redis:del(tablighati .. "channels")
              redis:del(tablighati .. "groups")
              redis:del(tablighati .. "specials")
              redis:del(tablighati .. "deletedgroup")
              redis:del(tablighati .. "antispams")
              tdbot.sendmsg(msg.chat_id, "_Information_ Of *Tablighati* `Number " .. tablighati .. "` _Reseted_!", msg.id, "md")
              redis:set(tablighati .. "delayname", "\216\168\216\167\216\178\217\134\216\180\216\167\217\134\219\140 \216\162\217\133\216\167\216\177\226\153\187\239\184\143")
            end
            if msg.content.text == "#reset contacts" then
              local lol8 = redis:smembers(tablighati .. "tabchi_contacts_id")
              for i = 1, #lol8 do
                redis:srem(tablighati .. "tabchi_contacts_id", lol8[i])
              end
              tdbot.sendmsg(msg.chat_id, "*Contacts* of `" .. tablighati .. "` _Reseted_!", msg.id, "md")
              redis:set(tablighati .. "delayname", "\217\190\216\167\218\169 \218\169\216\177\216\175\217\134 \217\132\219\140\216\179\216\170 \217\133\216\174\216\167\216\183\216\168\219\140\217\134\226\153\187\239\184\143")
            end
            if msg.content.text == "#updatebot" then
              get_bot()
              tdbot.sendmsg(msg.chat_id, "_Profile_ of *Tablighati* `Number " .. tablighati .. "` _Updated_!", msg.id, "md")
              redis:set(tablighati .. "delayname", "\216\170\216\167\216\178\217\135 \216\179\216\167\216\178\219\140 \217\190\216\177\217\136\217\129\216\167\219\140\217\132\226\153\187\239\184\143")
            end
            if msg.content.text == "#tablighati" then
              local tab = " \n\226\150\170\239\184\143\216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140\n_\226\150\171\239\184\143\217\136\216\177\218\152\217\134:_ `3.0`\n_\226\150\171\239\184\143\216\168\216\177\217\190\216\167\219\140\217\135:_ `tdbot(uses tdlib)`\n_\226\150\171\239\184\143\216\178\216\168\216\167\217\134 \218\169\216\175\217\134\217\136\219\140\216\179\219\140:_ `Lua`\n_\226\150\171\239\184\143\217\136\216\177\218\152\217\134 td:_ `1.0.0`\n_\226\150\171\239\184\143\217\133\216\179\217\134\216\172\216\177:_ `Telegram`\n\n\226\150\170\239\184\143\216\167\216\179\216\170\218\175\216\178\n_\226\150\171\239\184\143\218\169\216\167\217\134\216\167\217\132:_ @Stags\n_\226\150\171\239\184\143\216\179\216\167\219\140\216\170:_ https://Stags.ir\n_\226\150\171\216\170\217\136\216\179\216\185\217\135 \216\175\217\135\217\134\216\175\217\135:_ @CaltMan\239\184\143\n\n\218\169\219\140\217\129\219\140\216\170 \216\177\216\167 \216\168\217\135 \217\130\219\140\217\133\216\170 \217\134\217\129\216\177\217\136\216\180\219\140\217\133!\n\216\168\216\177\216\170\216\177 \216\168\217\136\216\175\217\134 \217\135\217\134\216\177 \217\133\219\140\216\174\217\136\216\167\217\135\216\175!\n"
              tdbot.sendmsg(msg.chat_id, tab, msg.id, "md")
            end
            if msg.content.text == "#help" then
              local help = " _\217\132\219\140\216\179\216\170 \216\177\216\167\217\135\217\134\217\133\216\167\219\140 \216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140:_\n*#savenumber [on,off]* \n`\216\177\217\136\216\180\217\134 \217\136 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \216\173\216\167\217\132\216\170 \216\179\219\140\217\136 \218\169\216\177\216\175\217\134 \216\180\217\133\216\167\216\177\217\135 \217\135\216\167 `\n*#sharenumber [on,off]*\n`\216\167\216\177\216\179\216\167\217\132 \216\180\217\133\216\167\216\177\217\135 \216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140 \217\135\217\134\218\175\216\167\217\133 \216\176\216\174\219\140\216\177\217\135 \217\133\216\174\216\167\216\183\216\168`\n*#groupleft [on,off] *\n`\216\177\217\136\216\180\217\134 \217\136 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \217\132\217\129\216\170 \216\167\216\170\217\136\217\133\216\167\216\170\219\140\218\169 \218\175\216\177\217\136\217\135 \217\135\216\167`\n*#channelleft [on,off] *\n`\216\177\217\136\216\180\217\134 \217\136 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \217\132\217\129\216\170 \216\167\216\170\217\136\217\133\216\167\216\170\219\140\218\169 \218\169\216\167\217\134\216\167\217\132 \217\135\216\167`\n*#join [on,off] *\n`\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \216\185\216\182\217\136\219\140\216\170 \216\167\216\170\217\136\217\133\216\167\216\170\219\140\218\169 \216\175\216\177 \218\175\216\177\217\136\217\135 `\n*#oklink [on,off]* \n`\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \216\170\216\167\219\140\219\140\216\175 \217\132\219\140\217\134\218\169 \217\135\216\167\219\140 \216\175\216\177 \216\173\216\167\217\132 \216\167\217\134\216\170\216\184\216\167\216\177 `\n*#findlink [on,off]* \n`\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \217\190\219\140\216\175\216\167 \218\169\216\177\216\175\217\134 \217\136 \216\180\217\134\216\167\216\179\216\167\219\140\219\140 \217\132\219\140\217\134\218\169 \217\135\216\167 `\n*#leftname [on,off] *\n`\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \217\132\217\129\216\170 \216\174\217\136\216\175\218\169\216\167\216\177 \216\168\216\167\216\167\216\179\216\167\217\133\219\140 \216\174\216\167\216\181`\n*#restricleft [on,off]*\n`\216\174\216\177\217\136\216\172 \216\167\216\178 \218\175\216\177\217\136\217\135 \217\135\216\167\219\140\219\140 \218\169\217\135 \216\177\216\168\216\167\216\170 \217\133\216\173\216\175\217\136\216\175 \216\180\216\175\217\135 \216\167\216\179\216\170`\n*#getcode [on,off]*\n`\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \216\175\216\177\219\140\216\167\217\129\216\170 \217\190\219\140\216\167\217\133 \217\135\216\167\219\140 \216\170\217\132\218\175\216\177\216\167\217\133`\n*#antispamgp [on,off]*\n`\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \216\174\216\177\217\136\216\172 \216\167\216\178\218\175\216\177\217\136\217\135 \217\135\216\167\219\140 \216\175\216\167\216\177\216\167\219\140 \216\177\216\168\216\167\216\170 \216\182\216\175\217\132\219\140\217\134\218\169`\n*#autoleave [on,off]*\n`\216\177\217\136\216\180\217\134 \219\140\216\167 \216\174\216\167\217\133\217\136\216\180 \218\169\216\177\216\175\217\134 \216\174\216\177\217\136\216\172 \216\174\217\136\216\175\218\169\216\167\216\177 \218\175\216\177\217\136\217\135 \217\136 \216\179\217\136\217\190\216\177\218\175\216\177\217\136\217\135 \217\135\216\167`\n\n*#addsudo id | #remsudo id | #sudolist*\n`\216\167\217\129\216\178\217\136\216\175\217\134 \219\140\218\169 \218\169\216\167\216\177\216\168\216\177 \216\168\217\135 \216\185\217\134\217\136\216\167\217\134 \216\179\217\136\216\175\217\136|\216\173\216\176\217\129 \216\179\217\136\216\175\217\136|\217\134\217\133\216\167\219\140\216\180 \217\132\219\140\216\179\216\170 \216\179\217\136\216\175\217\136 `\n*#maxgroup num | #minmember num*\n`\216\170\217\134\216\184\219\140\217\133 \216\173\216\175\216\167\218\169\216\171\216\177 \218\175\216\177\217\136\217\135 \216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140|\216\173\216\175\216\167\217\130\217\132 \216\167\216\185\216\182\216\167\219\140 \218\175\216\177\217\136\217\135`\n*#delmaxgroup | #delminmember*\n`\216\173\216\176\217\129 \216\173\216\175\216\167\218\169\216\171\216\177 \218\175\216\177\217\136\217\135 \216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140|\216\173\216\175\216\167\217\130\217\132 \216\167\216\185\216\182\216\167\219\140 \218\175\216\177\217\136\217\135`\n*#info *\n`\216\175\216\177\219\140\216\167\217\129\216\170 \216\167\217\133\216\167\216\177 \217\136 \216\170\217\134\216\184\219\140\217\133\216\167\216\170 \216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140 `\n*#bc [su,pv,gp] [reply]*\n`\216\167\216\177\216\179\216\167\217\132 \217\133\216\170\217\134 \216\168\217\135 \218\175\216\177\217\136\217\135 \219\140\216\167 \217\190\219\140\217\136\219\140 \219\140\216\167 \216\179\217\136\217\190\216\177 \218\175\216\177\217\136\217\135 \217\135\216\167 `\n*#fs | #fv | #fg *\n`\216\167\216\177\216\179\216\167\217\132 \217\135\216\177\218\175\217\136\217\134\217\135 \217\133\216\170\217\134 \217\136 \219\140\216\167 \217\133\216\175\219\140\216\167 \216\168\216\167 \216\177\217\190\217\132\216\167\219\140 \216\168\217\135 \216\179\217\136\217\190\216\177 \218\175\216\177\217\136\217\135 \217\135\216\167 |\217\190\219\140 \217\136\219\140 \217\135\216\167| \218\175\216\177\217\136\217\135 \217\135\216\167`\n*#fpro (TYPE) (DELAY) [reply]*\n`\217\129\217\136\216\177\217\136\216\167\216\177\216\175 \217\190\219\140\216\180\216\177\217\129\216\170\217\135 \216\168\216\167 \216\170\216\167\216\174\219\140\216\177 \216\168\216\167 \216\175\216\177\216\181\216\175`\n_TYPE = \217\133\219\140\216\170\217\136\216\167\217\134\216\175 \216\180\216\167\217\133\217\132 (all,sgp,gp,pv) \216\168\216\167\216\180\216\175_\n_DELAY = \217\133\219\140\216\170\217\136\216\167\217\134\216\175 \216\180\216\167\217\133\217\132 \216\167\216\185\216\175\216\167\216\175 1 \216\170\216\167 9 \216\168\216\167\216\180\216\175_\n_\217\133\216\171\216\167\217\132: #fpro all 3_\n*#setseen num*\n`\216\170\217\134\216\184\219\140\217\133 \216\173\216\175\216\167\218\169\216\171\216\177 \216\168\216\167\216\178\216\175\219\140\216\175 \217\190\216\179\216\170 \217\136 \216\170\217\134\216\184\219\140\217\133 \216\173\216\167\217\132\216\170 \217\129\217\136\216\177\217\136\216\167\216\177\216\175 \216\179\219\140\217\134 \216\175\216\167\216\177 \216\168\216\177\216\167\219\140 \217\190\219\140\216\180\216\177\217\129\216\170\217\135 `\n*#fall | #ftall | #fwdall [reply]*\n`\217\129\217\136\216\177\216\167\216\177\216\175 \216\168\217\135 \216\170\217\133\216\167\217\133\219\140 \218\175\216\177\217\136\217\135 \217\135\216\167 \216\140\216\179\217\136\217\190\216\177\218\175\216\177\217\136\217\135 \217\135\216\167\216\140\217\190\219\140 \217\136\219\140 \217\135\216\167|\217\129\217\136\216\177\217\136\216\167\216\177\216\175 \216\178\217\133\216\167\217\134\216\175\216\167\216\177(#ftall)|\217\129\217\136\216\177\217\136\216\167\216\177\216\175 \216\168\217\135 \217\135\217\133\217\135 \216\168\216\172\216\178 \218\169\216\167\216\177\216\168\216\177\216\167\217\134(#fwdall)`\n*#addmembers *\n`\216\167\216\175\217\133\217\133\216\168\216\177 \216\175\216\177 \218\175\216\177\217\136\217\135 `\n*#addtoall id | #addtoall @id *\n`\216\167\216\182\216\167\217\129\217\135 \218\169\216\177\216\175\217\134 \219\140\218\169 \217\129\216\177\216\175 \216\168\217\135 \216\170\217\133\216\167\217\133\219\140 \218\175\216\177\217\136\217\135 \217\135\216\167\219\140 \216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140 `\n*#left *\n`\216\170\216\177\218\169 \218\175\216\177\217\136\217\135 \217\133\217\136\216\177\216\175 \217\134\216\184\216\177 `\n*#leftall *\n`\216\170\216\177\218\169 \218\169\216\177\216\175\217\134 \216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140 \216\167\216\178 \216\170\217\133\216\167\217\133\219\140 \218\175\216\177\217\136\217\135 \217\135\216\167 `\n*#setbio text | #setname text | #setusername text*\n`\216\170\217\134\216\184\219\140\217\133 \216\168\219\140\217\136 | \216\170\217\134\216\184\219\140\217\133 \217\134\216\167\217\133 | \216\170\217\134\216\184\219\140\217\133 \219\140\217\136\216\178\216\177\217\134\219\140\217\133 \216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140`\n*#addlname text*\n`\216\167\217\129\216\178\217\136\216\175\217\134 \216\167\216\179\217\133 \216\168\217\135 \216\167\216\179\216\167\217\133\219\140 \216\174\216\167\216\181`\n*#remlname text*\n`\216\173\216\176\217\129 \218\169\216\177\216\175\217\134 \216\167\216\179\217\133 \216\167\216\178 \216\167\216\179\216\167\217\133\219\140 \216\174\216\167\216\181`\n*#clean lname*\n`\217\190\216\167\218\169 \218\169\216\177\216\175\217\134 \217\132\219\140\216\179\216\170 \216\167\216\179\216\167\217\133\219\140 \216\174\216\167\216\181`\n*#addaddi text*\n`\216\167\217\129\216\178\217\136\216\175\217\134 \217\190\219\140\216\167\217\133 \216\168\217\135 \217\132\219\140\216\179\216\170 \216\167\216\175 \217\133\216\174\216\167\216\183\216\168`\n*#remaddi text*\n`\216\173\216\176\217\129 \218\169\216\177\216\175\217\134 \217\190\219\140\216\167\217\133 \216\167\216\178 \217\132\219\140\216\179\216\170 \216\167\216\175 \217\133\216\174\216\167\216\183\216\168`\n*#clean addi*\n`\217\190\216\167\218\169 \218\169\216\177\216\175\217\134 \217\132\219\140\216\179\216\170 \217\190\219\140\216\167\217\133 \217\135\216\167\219\140 \216\167\216\175 \217\133\216\174\216\167\216\183\216\168`\n*#reset*\n`\216\168\216\167\216\178\217\134\216\180\216\167\217\134\219\140 \216\167\217\133\216\167\216\177 \216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140`\n*#reset contacts*\n`\216\168\216\167\216\178\217\134\216\180\216\167\217\134\219\140 \216\167\217\133\216\167\216\177 \217\133\216\174\216\167\216\183\216\168\219\140\217\134`\n*#start @username*\n`\216\167\216\179\216\170\216\167\216\177\216\170 \216\178\216\175\217\134 \216\177\216\168\216\167\216\170 API`\n*#ping *\n`\216\167\218\175\216\177 \216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140 \216\167\217\134\217\132\216\167\219\140\217\134 \216\168\216\167\216\180\216\175 \217\190\219\140\216\167\217\133 \216\180\217\133\216\167 \216\177\216\167 \217\129\216\177\217\136\216\167\216\177\216\175 \217\133\219\140\218\169\217\134\216\175 `\n*#echo [text]*\n`\217\133\216\170\217\134 text \216\177\216\167 \216\167\216\177\216\179\216\167\217\132 \217\133\219\140\218\169\217\134\216\175.`\n*#setoption*\n`\218\169\216\167\217\134\217\129\219\140\218\175 \216\170\217\134\216\184\219\140\217\133\216\167\216\170 td`\n*#deloption*\n`\216\173\216\176\217\129 \218\169\216\167\217\134\217\129\219\140\218\175 \216\170\217\134\216\184\219\140\217\133\216\167\216\170 td`\n*#updatebot*\n`\216\168\216\177\217\136\216\178\216\177\216\179\216\167\217\134\219\140 \217\190\216\177\217\136\217\129\216\167\219\140\217\132 \216\177\216\168\216\167\216\170`\n*#tablighati *\n`\217\134\217\133\216\167\219\140\216\180 \217\133\216\180\216\174\216\181\216\167\216\170 \216\179\217\136\216\177\216\179`\n*#online*\n`\217\134\217\133\216\167\219\140\216\180 \216\167\217\134\217\132\216\167\219\140\217\134\219\140 \216\177\216\168\216\167\216\170`\n\n_\216\170\216\168\217\132\219\140\216\186\216\167\216\170\219\140 \217\136\216\177\218\152\217\134 3.0_(@Stags)\n"
              tdbot.sendmsg(msg.chat_id, help, msg.id, "md")
            end
            if msg.content.text == "#setoption" then
              tdbot.setOption("use_pfs", "Boolean", true, dl_cb, nil)
              tdbot.setOption("online", "Boolean", true, dl_cb, nil)
              tdbot.setOption("use_quick_ack", "Boolean", true, dl_cb, nil)
              tdbot.setOption("use_storage_optimizer", "Boolean", true, dl_cb, nil)
              tdbot.setOption("disable_contact_registered_notifications", "Boolean", true, dl_cb, nil)
              redis:set(tablighati .. "delayname", "\218\169\216\167\217\134\217\129\219\140\218\175 \216\170\217\134\216\184\219\140\217\133\216\167\216\170 td\226\153\187\239\184\143")
              redis:set(tablighati .. "Options", true)
              tdbot.sendmsg(msg.chat_id, "_Options_ *Tablighati* `Number " .. tablighati .. "` was _set_!", msg.id, "md")
            end
            if msg.content.text == "#deloption" then
              tdbot.setOption("use_pfs", "Boolean", false, dl_cb, nil)
              tdbot.setOption("online", "Boolean", false, dl_cb, nil)
              tdbot.setOption("use_quick_ack", "Boolean", false, dl_cb, nil)
              tdbot.setOption("use_storage_optimizer", "Boolean", false, dl_cb, nil)
              tdbot.setOption("disable_contact_registered_notifications", "Boolean", false, dl_cb, nil)
              redis:set(tablighati .. "delayname", "\218\169\216\167\217\134\217\129\219\140\218\175 \216\170\217\134\216\184\219\140\217\133\216\167\216\170 td\226\153\187\239\184\143")
              redis:del(tablighati .. "Options")
              tdbot.sendmsg(msg.chat_id, "_Options_ *Tablighati* `Number " .. tablighati .. "` was _delete_!", msg.id, "md")
            end
            if msg.content.text == "#left" then
              tdbot.sendmsg(msg.chat_id, "*Tablighati* Number `" .. tablighati .. "` with `ID " .. bot .. "` _Leave_ this Group with _ID " .. msg.chat_id .. "!_", msg.id, "md")
              tdbot.leave(tonumber(msg.chat_id), tonumber(bot))
            end
            if msg.content.text == "#leftall" then
              local lgp = redis:smembers(tablighati .. "tabchi_gp")
              local lsug = redis:smembers(tablighati .. "tabchi_sugp")
              local lgpn = redis:scard(tablighati .. "tabchi_gp")
              local lsugn = redis:scard(tablighati .. "tabchi_sugp")
              for i = 1, #lgp do
                tdbot.leave(tonumber(lgp[i]), tonumber(bot))
              end
              for i = 1, #lsug do
                tdbot.leave(tonumber(lsug[i]), tonumber(bot))
              end
              redis:set(tablighati .. "delayname", "\216\174\216\177\217\136\216\172 \216\167\216\178 \216\170\217\133\216\167\217\133\219\140 \218\175\216\177\217\136\217\135 \217\135\216\167\226\153\187\239\184\143")
              tdbot.sendmsg(msg.chat_id, "*Tablighati* _Leaves_ from `" .. lgpn .. "` Groups and `" .. lsugn .. "` SuperGroup!", msg.id, "md")
              elseif data._ == "updateOption" and data.name == "my_id" then
                tdbot.getChats(20)
              end
            end
          end
        else
        end
    end
  end
end
