cpus        = require('os').cpus().length
cluster     = require 'cluster'

if cluster.isMaster
  cluster.on 'exit', (worker) ->
    console.log "The XX #{worker.id} died. restart..."
    cluster.fork()

  cluster.fork() for i in [1..cpus]
else
  require './server'
