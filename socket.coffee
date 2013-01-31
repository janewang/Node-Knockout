redis         = require('redis')
cookie        = require('cookie')
socketio      = require('socket.io')
redis_config  = app.get('redis_config')

fetch_session = (sid, fn) ->
  app.sessionStore.get sid, (err, session) ->
    return fn(err) if err?
    fn(null, session)

module.exports = (server) ->
  io    = socketio.listen(server)
  pub   = redis.createClient(redis_config.port, redis_config.host)
  sub   = redis.createClient(redis_config.port, redis_config.host)
  store = redis.createClient(redis_config.port, redis_config.host)

  io.configure ->
    io.set('store', new socketio.RedisStore({redisPub: pub, redisSub: sub, redisClient: store}))
    io.set('match origin protocol', true)
    io.enable('browser client minification')
    io.enable('browser client etag')
    io.enable('browser client gzip')
    io.set('log level', 0)
    io.set('polling duration', 10)
    io.set('transports', ['websocket', 'flashsocket', 'htmlfile', 'xhr-polling', 'jsonp-polling'])

  io.configure 'development', ->
    io.set('log level', 1)

  io.of('/coms')
    .authorization((data, fn) ->
      return fn(null, true) unless data.headers.cookie?
      sessionID = cookie.parse(data.headers.cookie)['connect.sid']
      data.sid  = sessionID.match(/.?:(.*)\./)[1]
      fetch_session data.sid, (err, session) ->
        data.user = session.user
        fn(null, true)
    ).on('connection', (socket) ->
      sid     = socket.handshake.sid
      now     = new Date().toISOString()
      session_user  = socket.handshake.user
      console.log("#{session_user.username} Connected to API #{socket.id}") if  app.get('env') is 'development'
      socket.emit 'ready', session_user
      socket.broadcast.emit('event', {ts: now, event: "#{session_user.username} Joined"})

      rand_event = ->
        app.mongo.planets.find().count (err, count) ->
          rand = Math.round(Math.random() * count)
          app.mongo.planets.find().skip(rand).limit(1).toArray (err, planets) ->
            if planets.length
              status = utils.randomArray(['toAttack', 'noAttack', 'underAttack', 'terraform'])
              planet = new Planet(planets[0]).toJSON()
              planet.status = status
              socket.emit('event', {ts: now, event: "Planet #{planet.name} #{status}", planet: planet})
            setTimeout rand_event, 15000
      setTimeout rand_event, 15000

      new Planet().findByUser session_user.id, (err, planet) ->
        socket.broadcast.emit('planet', planet.toJSON())

      send = (method, data, done) ->
        fetch_session sid, (err, session) ->
          done(null, session.planet)

      socket.on 'login', (done) ->
        fetch_session sid, (err, session) ->
          session_user = session.user
          done(user: session.user, planet: session.planet)

      socket.on 'chat', (msg) ->
        now = new Date().toISOString()
        socket.emit('chat', {ts: now, username: session_user.username, message: msg})
        socket.broadcast.emit('chat', {ts: now, username: session_user.username, message: msg})

      socket.on 'planets', ->
        stream = app.mongo.planets.find().stream()
        stream.on 'data', (item) -> socket.emit('planet', new Planet(item).toJSON())
    )
