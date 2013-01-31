class TheXX.views.Chat extends TheXX.View
  className:  'chat'
  template:   'chat'

  initialize: (opts={}) ->
    TheXX.on 'xx:chat', @chat, @
    TheXX.on 'xx:event', @chat_event, @

  events:
    'keyup textarea':       'keyup'
    'click [data-social]':  'social'

  keyup: (e) ->
    el = $(e.currentTarget)
    return unless /.{1,}/.test(el.val())
    return unless e.which is 13 and not e.shiftKey
    TheXX.coms.emit 'chat', el.val()
    el.val('').blur().focus()

  timestamp: (ts) ->
    ts = new Date(ts)
    hh = ts.getHours()
    mm = ts.getMinutes()
    ss = ts.getSeconds()
    hh = "0#{hh}" if hh < 10
    mm = "0#{mm}" if mm < 10
    ss = "0#{ss}" if ss < 10
    $('<time />', datetime: ts, html: "(#{hh}:#{mm}:#{ss})")

  chat: (data) ->
    message = $('<li />')
    message.append @timestamp(data.ts)
    message.append $('<span />', class: 'user', html: "#{data.username}:")
    message.append $('<span />', class: 'message', html: data.message)
    @add_message(message)

  chat_event: (data) ->
    message = $('<li />')
    message.append @timestamp(data.ts)
    message.append $('<span />', class: 'event', html: data.event)
    @add_message(message)

  add_message: (message) ->
    messages = @$('.messages')
    messages.append message
    height = messages[0].scrollHeight
    messages.animate {scrollTop: height}, 0

  popup: (network) ->
    params    = 'location=0,status=0,width=800,height=400'
    popup     = window.open "/oauth/#{network}", 'oauthWindow', params
    interval  = window.setInterval =>
      if popup.closed
        TheXX.login()
        window.clearInterval(interval)
    , 300

  social: (e) ->
    el = $(e.currentTarget)
    @popup(el.data('social'))

new TheXX.views.Chat().render()
