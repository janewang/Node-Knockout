exports.destroy = (req, res) ->
  req.session.destroy ->
    res.redirect '/'
