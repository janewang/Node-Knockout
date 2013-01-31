initialize  = _.once(TheXX.initialize)

onResize = _.throttle ->
  TheXX.trigger('xx:resize', {width: window.innerWidth, height: window.innerHeight})
, 100

onMousemove = _.throttle (e) ->
  TheXX.trigger('xx:mousemove', e)
, 10

$ ->
  TheXX.coms = io.connect("//#{location.host}/coms", {'connect timeout': 3000})
  TheXX.coms.on 'ready', initialize
  TheXX.coms.on 'chat', (data) -> TheXX.trigger('xx:chat', data)
  TheXX.coms.on 'event', (data) ->
    TheXX.trigger('xx:event', data)
    TheXX.planets.get(data.planet.id).set(data.planet) if data.planet?
  TheXX.coms.on 'planet', (data) -> TheXX.planets.add(data)

  $(window)
    .on('resize', onResize)
    .on('click', -> $('.about').fadeOut())
  $(document).on('mousemove', onMousemove)
  
  $('#explore').on 'click', (e) ->
    e.preventDefault()
    zoom = ->
      setTimeout ->
        TheXX.universe.camera.position.z += 50
        zoom() unless TheXX.universe.camera.position.z >= 5050
      , 50
    zoom()

  $("#about").on 'click', (e) ->
    e.preventDefault()
    e.stopPropagation()
    $('.about').fadeIn()

  $('.about').on 'click', (e) -> e.stopPropagation()