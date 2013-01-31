window.TheXX =
  models:       {}
  collections:  {}
  views:        {}
  current:      []

  initialize: (user) ->
    @user     = new TheXX.models.User(user)
    @planets  = new TheXX.collections.Planets
    @trigger('xx:init')
    @off('xx:init')
    TheXX.coms.emit 'planets'
    @

  remove_view: (view) ->
    @current = _(@current).reject (v) -> v.cid is view.cid
    @

  login: ->
    TheXX.coms.emit 'login', (data) =>
      @user.clear(silent: true).set(data.user)
      @planets.add(data.planet)

_(TheXX).extend(Backbone.Events)
_(TheXX).bindAll()
