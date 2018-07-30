--[[
tdbot.lua wrote for Tablighati v2.3
written by : @CaltMan is @Stags
]]--

local tdbot = {}

function dl_cb(arg, data)
end
local function getParseMode(parse_mode)
  local P = {}
  if parse_mode then
    local mode = parse_mode:lower()

    if mode == 'markdown' or mode == 'md' then
      P._ = 'textParseModeMarkdown'
    elseif mode == 'html' or mode == 'ht' then
      P._ = 'textParseModeHTML'
    end
  end

  return P
end
function tdbot.getMe(callback, data)
  assert (tdbot_function ({
    _ = 'getMe'
  }, callback or dl_cb, data))
end
function tdbot.leave(chat_id, user_id) 
assert (tdbot_function ({ 
     _ = "setChatMemberStatus",  
	 chat_id = chat_id,   
	 user_id = user_id,  
	 status = {    
     _ = "chatMemberStatusLeft"  
	 }, }, dl_cb, nil) )
end 
function tdbot.openChat(chatid, callback, data)
  assert (tdbot_function ({
    _ = 'openChat',
    chat_id = chatid
  }, callback or dl_cb, data))
end

function tdbot.checkChatInviteLink(invitelink, callback, data)
  assert (tdbot_function ({
    _ = 'checkChatInviteLink',
    invite_link = tostring(invitelink)
  }, callback or dl_cb, data))
end

function tdbot.import_link(invite_link, cb, cmd)
assert (tdbot_function ({ 
_ = "joinChatByInviteLink" , 
invite_link = tostring(invite_link) 
}, cb, cmd)) 
end

function tdbot.add_user(chat_id, user_id)   
 assert (tdbot_function 
({ _ = "addChatMember", 
chat_id = tonumber(chat_id), 
user_id = tonumber(user_id), 
forward_limit = 0    }, 
dl_cb, extra) )
end 
function tdbot.markread(chatid, messageids, callback, data) 
assert (tdbot_function ({ _ = 'viewMessages', 
chat_id = chatid, 
message_ids = {[0]= messageids} }, 
callback or dl_cb, data))
end
function tdbot.getChat(chat_id,cb)
   assert (tdbot_function ({
    _ = "getChat",
    chat_id = chat_id
}, cb or dl_cb, nil))
end
function tdbot.fwd_msg(az_koja,be_koja_,msg_id, cb, cmd) 
assert (tdbot_function ({ 
    _ = "forwardMessages", 
    chat_id =  be_koja_, 
    from_chat_id = az_koja, 
    message_ids = {[0]= msg_id}, 
    disable_notification = 0, 
    from_background = 1 
  },cb or dl_cb, cmd) )
  end 
function tdbot.fwd_msg_time(chat_id,from_chat_id,message_ids,cb,cmd)
assert ( tdbot_function({
								_ = "forwardMessages",
								chat_id = chat_id,
								from_chat_id = from_chat_id,
								message_ids = {[0] = message_ids},
								disable_notification = 1,
								from_background = 1
							}, cb or dl_cb, cmd))
  end 
  function tdbot.getChats(limit)
  		assert(tdbot_function ({_="getChats", offset_order="9223372036854775807", offset_chat_id=0, limit=limit}, dl_cb, nil))  
end		
function tdbot.changeName(firstname, lastname, callback, data)
  assert (tdbot_function ({
    _ = 'setName',
    first_name = tostring(firstname),
    last_name = tostring(lastname)
  }, callback or dl_cb, data))
end
function tdbot.changeAbout(abo, callback, data)
  assert (tdbot_function ({
    _ = 'setBio',
    bio = tostring(abo)
  }, callback or dl_cb, data))
end
function tdbot.sendmsg(chat_id, text, msg_id, textparsemode)
  assert (tdbot_function ({
  _="sendMessage", 
  chat_id=chat_id,
  reply_to_message_id=msg_id,
  disable_notification=false,
  from_background=true,
  reply_markup=nil,
  input_message_content={
  _="inputMessageText",
  text=text,
  disable_web_page_preview=true,
  clear_draft=false,
  entities={},
  parse_mode=getParseMode(textparsemode)
  }}, dl_cb, nil)) 
end
function tdbot.editMessageText(chatid, messageid, teks, textparsemode)
  assert (tdbot_function ({
    _ = 'editMessageText',
    chat_id = chatid,
    message_id = messageid,
    reply_markup = nil,
    input_message_content = {
      _ = 'inputMessageText',
      text = tostring(teks),
      disable_web_page_preview = true,
      clear_draft = false,
      entities = {},
      parse_mode = getParseMode(textparsemode)
    },
  }, dl_cb, nil))
end
function tdbot.changeUsername(uname, callback, data)
  assert (tdbot_function ({
    _ = 'setUsername',
    username = tostring(uname)
  }, callback or dl_cb, data))
end
local function getInputFile(file, conversion_str, expectedsize)
  local input = tostring(file)
  local infile = {}

  if (conversion_str and expectedsize) then
    infile = {
      _ = 'inputFileGenerated',
      original_path = tostring(file),
      conversion = tostring(conversion_str),
      expected_size = expectedsize
    }
  else
    if input:match('/') then
      infile = {_ = 'inputFileLocal', path = file}
    elseif input:match('^%d+$') then
      infile = {_ = 'inputFileId', id = file}
    else
      infile = {_ = 'inputFilePersistentId', persistent_id = file}
    end
  end

  return infile
end
function tdbot.setProfilePhoto(photo_path, callback, data)
  assert (tdbot_function ({
    _ = 'setProfilePhoto',
    photo = getInputFile(photo_path)
  }, callback or dl_cb, data))
end
function tdbot.getMessage(chatid, messageid, callback, data)
  assert (tdbot_function ({
    _ = 'getMessage',
    chat_id = chatid,
    message_id = messageid
  }, callback or dl_cb, data))
end
function tdbot.formsgauto(chat_id,from_chat_id,message_ids,cb,cmd) 
assert (tdbot_function({
		_ = "forwardMessages",
		chat_id = chat_id,
		from_chat_id = from_chat_id,
		message_ids = {[0] = message_ids},
		disable_notification = 1,
		from_background = 1
	}, cb or dl_cb, cmd))
	end
	function tdbot.searchpublic(username,cb,cmd)
assert (tdbot_function ({
	_ = "searchPublicChat",
	username = username
	}, cb or dl_cb, cmd))
	end
function tdbot.sendBotStartMessage(bot_user_id,chat_id) 
	assert ( tdbot_function ({
										_ = "sendBotStartMessage",
										bot_user_id = bot_user_id,
										chat_id = chat_id,
										parameter = 'start'
									}, dl_cb, nil))
	end
function tdbot.searchContacts(cb)
 assert (tdbot_function({
						_ = "searchContacts",
						query = nil,
						limit = 999999999
						}, cb or dl_cb, nil))
end
function tdbot.addChatMemberCB(chat_id,user_id,cb,cmd)
tdbot_function ({
				_ = "addChatMember",
				chat_id = chat_id,
				user_id = user_id,
				forward_limit =  0
			},cb or dl_cb, cmd)
end
function tdbot.importcontact(phone_number,first_name,last_name,user_id)	
assert (tdbot_function ({
					_ = "importContacts",
					contacts = {[0] = {
							phone_number = tostring(phone_number),
							first_name = tostring(first_name),
							last_name = tostring(last_name),
							user_id = user_id
						},
					},
				}, dl_cb, nil))
				end
function tdbot.inputMessageContact(chat_id,reply_to_message_id,phone_number,first_name,last_name,user_id)
assert (tdbot_function ({
						_ = "sendMessage",
						chat_id = chat_id,
						reply_to_message_id = reply_to_message_id,
						disable_notification = 1,
						from_background = 1,
						reply_markup = nil,
						input_message_content = {
							_ = "inputMessageContact",
							contact = {
								_ = "contact",
								phone_number = phone_number,
								first_name = first_name,
								last_name = last_name,
								user_id = user_id
							},
						},
					}, dl_cb, nil))
				end
function tdbot.setOption(optionname, option, optionvalue, callback, data)
  assert (tdbot_function ({
    _ = 'setOption',
    name = tostring(optionname),
    value = {
      _ = 'optionValue' .. option,
      value = optionvalue
    },
  }, callback or dl_cb, data))
end

return tdbot
