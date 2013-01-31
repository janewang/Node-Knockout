class global.Planet extends Model
  collection: app.mongo.planets

  environments: ['frigid', 'lush', 'volcanic', 'water']

  name:   -> @model.name
  type:   -> @model.type
  oxygen: -> @model.oxygen
  water:  -> @model.water
  land:   -> @model.land
  loc:    -> @model.loc

  seed: ->
    planet =
      type: utils.randomArray(@environments)
      loc: { x: Math.round(Math.random() * 50), y: Math.round(Math.random() * 50) }

    switch planet.type
      when 'frigid'
        planet.oxygen = Math.ceil(Math.random() * 20)
        planet.water  = Math.ceil(Math.random() * 10)
      when 'lush'
        planet.oxygen = Math.ceil(Math.random() * 50) + 50
        planet.water  = Math.ceil(Math.random() * 50) + 50
      when 'volcanic'
        planet.oxygen = Math.ceil(Math.random() * 30)
        planet.water  = Math.ceil(Math.random() * 10)
      when 'water'
        planet.oxygen = Math.ceil(Math.random() * 70) + 30
        planet.water  = Math.ceil(Math.random() * 50) + 50
    planet.land = 100 - planet.water
    @set(planet)

  create_name: (fn) ->
    opts =
      url: ' http://donjon.bin.sh/name/rpc.cgi'
      qs:
        type: 'Inuit Town'
        n: 10
    request opts, (e, r, body) ->
      return fn(body) unless r.statusCode is 200
      names = body.match(/\w+/g)
      name  = utils.randomArray(names)
      name  += " - #{utils.randomString(4)}"
      fn(null, name)

  create: (fn) ->
    @create_name (err, name) =>
      @set(name: name).save(fn)

  findOrCreate: (user, fn) ->
    @collection.findOne _user: user._id(), (err, model) =>
      return fn(err) if err?
      return fn(null, @set(model)) if model?
      @set(_user: user._id()).create(fn)

  findByUser: (id, fn) ->
    @collection.findOne _user: @strToID(id), (err, model) =>
      return fn(err) if err?
      return fn(new Error('Not Found')) unless model?
      fn(null, @set(model))

  toJSON: ->
    id:     @id()
    name:   @name()
    type:   @type()
    oxygen: @oxygen()
    water:  @water()
    land:   @land()
    posX:   @loc().x
    posY:   @loc().y
