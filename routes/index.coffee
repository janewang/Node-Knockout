site      = require('./site')
sessions  = require('./sessions')
oauth     = require('./oauth')

get_user = (req, res, next) ->
  new User().findOrCreate req.session.user, (err, user) ->
    return next(err) if err?
    req.user = user
    req.session.user = user.toJSON()
    next()

get_planet = (req, res, next) ->
  new Planet().findOrCreate req.user, (err, planet) ->
    return next(err) if err?
    req.planet = planet
    req.session.planet = planet.toJSON()
    next()

app.param ':source', (req, res, next, source) ->
  model     = global[fleck.inflect(source, 'singularize', 'capitalize')]
  req.oauth = new model(req.session[source])
  next()

app.get '*', (req, res, next) ->
  res.locals.current_user = req.session.user
  next()

app.get '/', get_user, get_planet, (req, res, next) ->
  next()

app.get '/logout', sessions.destroy

app.get '/oauth/:source', oauth.redirect
app.get '/oauth/:source/callback', get_user, oauth.callback

app.use site.index
