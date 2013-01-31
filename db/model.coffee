class global.Model
  constructor: (@model={}) ->
    @seed?() unless @_id()?
    @

  _id:    -> @model._id
  _user:  -> @model._user
  id:     -> @model._id?.toHexString()

  strToID: (id) ->
    return id if id instanceof app.mongo.ObjectID
    try
      new app.mongo.ObjectID(id)
    catch err
      id

  findByID: (id, fn) ->
    @collection.findOne _id: @strToID(id), (err, model) =>
      return fn(err) if err?
      return fn(new Error("Cannot find #{@constructor.name} with id #{id}")) unless model?
      @model = model
      fn(null, @)

  set: (values) ->
    @model[key] = val for key, val of values
    @

  update: (query, fn) ->
    @collection.findAndModify {_id: @_id()}, [], query, {new: true}, (err, model) =>
      return fn?(err) if err?
      @model = model
      fn?(null, @)

  save: (fn) ->
    @collection.save @model, {safe: true}, (err, model) =>
      return fn?(err) if err?
      fn?(null, @)

  destroy: (fn) ->
    @collection.remove _id: @_id(), (err, model) =>
      return fn?(err) if err?
      fn(null, @)
