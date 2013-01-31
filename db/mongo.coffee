fs          = require('fs')
mongodb     = require('mongodb')
config      = app.get('mongo_config')
Db          = mongodb.Db
Server      = mongodb.Server
ObjectID    = mongodb.ObjectID
Collection  = mongodb.Collection
server      = new Server(config.host, config.port, {auto_reconnect: true})
client      = new Db(config.db, server, {safe: false})

app.mongo =
  client:   client
  ObjectID: ObjectID
  users:    new Collection(client, 'users')
  planets:  new Collection(client, 'planets')

client.open (err, db) ->
  console.log(err) if err?

  app.mongo.users.ensureIndex 'username_idx', {unique: true}
  app.mongo.users.ensureIndex 'email', {unique: true}
  app.mongo.planets.ensureIndex 'name', {unique: true}
  app.mongo.planets.ensureIndex {loc: "2d"}, {min: 0, max: 10000}

require('./model')
for file in fs.readdirSync("#{__dirname}/models")
  require("./models/#{file}")
