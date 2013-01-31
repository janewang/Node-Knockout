class TheXX.views.Universe extends TheXX.View
  className:  'universe'
  template:   'universe'
  
  views: {}

  initialize: (opts={}) ->
    _(@).bindAll 'frames'
    TheXX.on 'xx:init', @init, @
    TheXX.on 'xx:resize', @resize, @
    TheXX.on 'xx:mousemove', @mousemove, @

  events:
    'mousewheel': 'zoom'
    'dragstart':  'dragstart'
    'mouseup':    'dragend'

  init: ->
    @collection = TheXX.planets
    @collection.on 'reset', @reset, @
    @collection.on 'add', @add, @

  resize: (size) ->
    width   = @$el.width()
    height  = @$el.height()
    @camera.aspect = width / height
    @camera.updateProjectionMatrix()
    @renderer.setSize(width, height)

  frames: ->
    @renderer.render @scene, @camera
    if @mouse?
      vector      = new THREE.Vector3(@mouse.x, @mouse.y, 1)
      @projector.unprojectVector(vector, @camera)
      ray         = new THREE.Ray(@camera.position, vector.subSelf(@camera.position).normalize())
      intersects  = ray.intersectObjects(@scene.children)
      if intersects.length
        console.log intersects
    requestAnimationFrame @frames

  zoom: (e) ->
    delta = e.originalEvent.wheelDelta
    switch true
      when delta > 0 and @camera.position.z > 500 then @camera.position.z -= 175
      when delta < 0 and @camera.position.z < 5000 then @camera.position.z += 175

  dragstart: (e) ->
    e.preventDefault()
    @draggable = true

  dragend: (e) ->
    delete @draggable
    delete @mousePos

  mousemove: (e) ->
    @scene.updateMatrixWorld()
    mouse =
      x: ( e.clientX / @$el.width() ) * 2 - 1;
      y: - ( e.clientY / @$el.height() ) * 2 + 1;
        
    projector = new THREE.Projector()
    vector = new THREE.Vector3(mouse.x, mouse.y, 0)
    projector.unprojectVector(vector, TheXX.universe.camera)
    ray = new THREE.Ray( @camera.position, vector.subSelf( @camera.position ).normalize() )
    for child in @scene.children
      hovered = if Math.abs(child.position.x - ray.origin.x) < 200 and Math.abs(child.position.y - ray.origin.y < 200) then true else false
      @views[child.name].$el.trigger('planetHover', hovered)
    
    @mouse =
      x: (e.clientX / window.innerWidth) * 2 - 1
      y: - (e.clientY / window.innerHeight) * 2 + 1

    return unless @draggable?
    return @mousePos = {x: e.pageX, y: e.pageY} unless @mousePos?
    multiplier = @camera.position.z * 0.0025
    @camera.position.x += (@mousePos.x - e.pageX) * multiplier
    @camera.position.y -= (@mousePos.y - e.pageY) * multiplier
    @mousePos = {x: e.pageX, y: e.pageY}

  reset: (planets) ->
    p.remove() for p in TheXX.current when p instanceof TheXX.views.Planet
    planets.each @add

  add: (planet) ->
    view = new TheXX.views.Planet(model: planet, append: @$el).render()
    @scene.add view.group
    @views[planet.name()] = view
    @renderer.render @scene, @camera
    unless @centered?
      @centered = true
      @camera.position.x = view.group.position.x
      @camera.position.y = view.group.position.y

  rendered: ->
    @$el.attr('draggable', true)
    @scene      = new THREE.Scene()
    @projector  = new THREE.Projector()
    @camera     = new THREE.PerspectiveCamera(60, @$el.width() / @$el.height(), 1, 10000)
    @renderer   = new THREE.WebGLRenderer()
    @$el.append @renderer.domElement

    @camera.position.z = 500
    @renderer.setSize @$el.width(), @$el.height()
    requestAnimationFrame @frames

TheXX.universe = new TheXX.views.Universe().render()
