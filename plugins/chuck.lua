--[[
    Copyright 2017 Matthew Hesketh <wrxck0@gmail.com>
    This code is licensed under the MIT. See LICENSE for details.
]]

local chuck = {}
local mattata = require('mattata')
local http = require('socket.http')
local json = require('dkjson')

function chuck:init()
    chuck.commands = mattata.commands(self.info.username):command('chuck').table
    chuck.help = '/chuck - Sends a random Chuck Norris joke.'
end

function chuck:on_inline_query(inline_query, configuration, language)
    local jstr, res = http.request('http://api.icndb.com/jokes/random')
    if res ~= 200
    then
        return
    end
    local jdat = json.decode(jstr)
    local results = json.encode(
        {
            {
                ['type'] = 'article',
                ['id'] = '1',
                ['title'] = jdat.value.joke,
                ['description'] = language['chuck']['1'],
                ['input_message_content'] = {
                    ['message_text'] = jdat.value.joke
                }
            }
        }
    )
    return mattata.answer_inline_query(
        inline_query.id,
        results
    )
end

function chuck:on_message(message, configuration, language)
    local jstr, res = http.request('http://api.icndb.com/jokes/random')
    if res ~= 200
    then
        return mattata.send_reply(
            message,
            language['errors']['connection']
        )
    end
    local jdat = json.decode(jstr)
    return mattata.send_message(
        message.chat.id,
        jdat.value.joke
    )
end

return chuck