github = app.get('github_config')

exports.redirect = (req, res) ->
  res.redirect req.oauth.redirect()

exports.callback = (req, res) ->
  req.oauth.access_token req.query.code, (err, oauth) ->
    return res.json(500, err) if err?
    req.user.add_auth oauth, (err, user) ->
      req.session.user = user.toJSON()
      new Planet().findOrCreate req.user, (err, planet) ->
        req.session.planet = planet.toJSON()
        res.send '<script>window.close()</script>'
