# Description:
#   This is just a demonstration script of how to handle the main events and methods for Moxtra Adapter.
#   Here you can find examples on how to handle some Moxtra's Events like:
#   - "bot_installed"
#   - "bot_uninstalled"
#   - Sending text, rich messages and buttons
#   - Handling buttons postback
#   - Sending files
#   - Linking 3rd party accounts
#
# Dependencies:
#   none
#
# Author:
#   Moxtra Inc

_accountLinkedToken = {}

module.exports = (robot) ->

  # Send message to the Binder starting from the Bot side (Spontaneously).
  obj = {}
  obj.message = {}
  obj.message.id = "BxTOgQQ5SGiK2lXiwoPxgEK" #binder_id
  obj.message.org_id = "Pg3dAcMahyYFJDE4HyfFZw6" 
  robot.send obj, "Spontaneous message from Bot!"

  #bot_installed
  robot.listen(
    (message) -> # Match function
      message.message_type is "bot_installed"
    (response) -> # Standard listener callback
      response.send "Hi, I'm #{robot.name}, your personal assistant. Type \"@#{robot.name} help\" to see what I can do for you!"
  )
  #bot_uninstalled
  robot.listen(
    (message) -> # Match function
      message.message_type is "bot_uninstalled"
    (response) -> # Standard listener callback
      response.send "Goodbye!"
  )

  # Sending Files
  robot.hear /files/i, (res) ->
    options = {}
    options.file_path = __dirname+'/files/start.png'
    options.audio_path = __dirname+'/files/test_comment.3gpp'
    res.message.options = options
    res.send "Here are the files you requested:"

  # Sending Buttons
  robot.hear /meet/i, (res) ->
    buttons = [{ type: 'postback', text: 'Sure!', payload: 'BUTTON_SURE'}, { type: 'postback', text: 'Not Sure!', payload: 'BUTTON_NOTSURE'}]
    res.message.buttons = buttons
    res.send "Do you want to schedule a meeting?"

 # Handling Buttons Postback
  robot.listen(
    (message) -> # Match function
      message.message_type is "bot_postback"
    (response) -> # Standard listener callback
      payload = response.message.event.postback.payload
      text = response.message.event.postback.text
      if payload is "BUTTON_SURE"
        response.send "Got it! #{text} So, I'll schedule the meeting for you!"
      if payload is "BUTTON_NOTSURE"
        response.send "Ok #{text}. Let me know later."
  )

  #account_link
  robot.hear /link my account/i, (res) ->
    # check if there is a revious token for this user
    # you might also need to check the expiration time
    token = _accountLinkedToken[ res.message.event.user.id ]
    if token
      res.send "Your account is already linked! Please, say a command to use it."
      # res.send "Token:"+token.access_token
    else
      buttons = [{ type: 'account_link', text: 'Log in'}]
      res.message.buttons = buttons
      res.send "Please login:"

  #account_link_success callback
  robot.listen(
    (message) -> # Match function
      message.message_type is "account_link_success"
    (response) -> # Standard listener callback
      #store the token for future use
      _accountLinkedToken[ response.message.event.user.id ] = response.message.event.user.token
      response.send response.message.text # + " TOKEN:"+ response.message.event.user.token.access_token
  )
  
  #account_link_error callback
  robot.listen(
    (message) -> # Match function
      message.message_type is "account_link_error"
    (response) -> # Standard listener callback
      response.send "Sorry there was an error in the Account Link process: "+response.message.text
  )

  robot.hear /badgers/i, (res) ->
    res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"

  robot.hear /Google chart/i, (res) ->
    res.reply "I'll show you the Google's Stock chart later!"

  robot.respond /Hi/i, (res) ->
    res.reply "Hello Moxtra! We are together now!"

  # User Enter Event is not current supported by Moxtra Bot
  # Respond with Emote (res.emote) is not current supported by Moxtra Bot
  # Respond with Topic (res.topic) is not current supported by Moxtra Bot
  # robot.enter (res) ->
  #   res.send "SOMEONE ENTERED IN THE BINDER"

  robot.hear /change bot name to (.*)/i, (res) ->
    name = res.match[1]
    robot.name = name
    res.send "Ok. My name is #{robot.name}"

  robot.hear /this is (.*)/i, (res) ->
    person = res.match[1]
    res.send "[table][tr][td]Hello [b]#{person}[/b]![/td][/tr][tr][td]How are you doing today?[/td][/tr][/table]"
  
  robot.respond /open the (.*) doors/i, (res) ->
    doorType = res.match[1]
    if doorType is "pod bay"
      res.send "I'm afraid I can't let you do that."
    else
      res.send "Opening #{doorType} doors"
  
  robot.hear /I like pie/i, (res) ->
    res.emote "makes a freshly baked pie"
  
  lulz = ['lol', 'rofl', 'lmao']
  
  robot.respond /lulz/i, (res) ->
    res.send res.random lulz
  
  robot.topic (res) ->
    res.send "#{res.message.text}? That's a Paddlin'"
  
  
  enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  
  robot.enter (res) ->
    res.send res.random enterReplies
  robot.leave (res) ->
    res.send res.random leaveReplies
  
  answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  
  robot.respond /what is the answer to the ultimate question of life/, (res) ->
    unless answer?
      res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
      return
    res.send "#{answer}, but what is the question?"
  
  robot.respond /you are a little slow/, (res) ->
    setTimeout () ->
      res.send "Who you calling 'slow'?"
    , 60 * 1000
  
  annoyIntervalId = null
  
  robot.respond /annoy me/, (res) ->
    if annoyIntervalId
      res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
      return
  
    res.send "Hey, want to hear the most annoying sound in the world?"
    annoyIntervalId = setInterval () ->
      res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
    , 1000
  
  robot.respond /unannoy me/, (res) ->
    if annoyIntervalId
      res.send "GUYS, GUYS, GUYS!"
      clearInterval(annoyIntervalId)
      annoyIntervalId = null
    else
      res.send "Not annoying you right now, am I?"
  
  
  robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
    room   = req.params.room
    data   = JSON.parse req.body.payload
    secret = data.secret
  
    robot.messageRoom room, "I have a secret: #{secret}"
  
    res.send 'OK'
  
  robot.error (err, res) ->
    robot.logger.error "DOES NOT COMPUTE"
  
    if res?
      res.reply "DOES NOT COMPUTE"
  
  robot.respond /have a soda/i, (res) ->
    # Get number of sodas had (coerced to a number).
    sodasHad = robot.brain.get('totalSodas') * 1 or 0
  
    if sodasHad > 4
      res.reply "I'm too fizzy.."
  
    else
      res.reply 'Sure!'
  
      robot.brain.set 'totalSodas', sodasHad+1
  
  robot.respond /sleep it off/i, (res) ->
    robot.brain.set 'totalSodas', 0
    res.reply 'zzzzz'
