express     = require('express')
RedisStore  = require('connect-redis')(express)

global._        = require('lodash')
global.utils    = require('./utilities')
global.async    = require('async')
global.fleck    = require('fleck')
global.request  = require('request').defaults(_json: true)
global.app      = express()

require('./configs')

app.sessionStore  = new RedisStore(app.get('redis_config'))

app.configure ->
  app.set 'port', process.env.PORT or 8000
  app.set 'version', require('./package').version
  app.set 'description', require('./package').description
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'
  app.use express.bodyParser(uploadDir: '/tmp')
  app.use express.cookieParser('HisCK6A8h9nkn49')
  app.use express.session(cookie: { maxAge: 604800000 }, store: app.sessionStore)
  app.use express.methodOverride()
  app.use app.router

app.configure 'development', ->
  app.use express.logger('dev')
  app.use express.static("#{__dirname}/public")
  app.use express.errorHandler(dumpExceptions: true, showStack: true)
  app.use require('connect-assets')()
  app.use express.compress()

app.configure 'test', 'production', ->
  app.use express.static("#{__dirname}/public", maxAge: 86400000)
  app.use express.errorHandler()
  app.use require('connect-assets')(build: true)
  app.use express.compress()

require('./locals')
require('./db')
require('./routes')

server = require('http').createServer(app)
server.listen app.get("port"), ->
  console.log("%s) %s v%s (%s) port %d", new Date().toLocaleTimeString(), app.get('description'), app.get('version'), app.get('env'), app.get('port'))
  require('./socket')(server)
