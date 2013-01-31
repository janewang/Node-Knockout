class global.User extends Model
  collection: app.mongo.users

  username:         -> @model.username
  name:             -> @model.name
  email:            -> @model.email
  site:             -> @model.site
  avatar:           -> @model.avatar
  authentications:  -> @model.authentications or []

  seed: ->
    username  = "guest_#{utils.randomString(5)}"
    email     = "#{username}@the-xx.nko"
    @set(email: email, username: username, username_idx: username.toLowerCase())

  findOrCreate: (data, fn) ->
    return @save(fn) unless data?.id?
    @findByID data.id, fn

  add_auth: (oauth, fn) ->
    @collection.findOne {'authentications.source': oauth.source(), 'authentications.uid': oauth.uid()}, (err, model) =>
      return fn(err) if err?
      if model?
        @model = model
        return @update_auth(oauth, fn)
      updates = oauth.user
      updates.username_idx = updates.username.toLowerCase()
      updates.authentications = [oauth.model]
      @set(updates).save(fn)

  update_auth: (oauth, fn) ->
    query = {_id: @_id(), authentications: {$elemMatch: {source: oauth.source()}}}
    update = $set: {'authentications.$': oauth.model}
    @collection.update query, update, (err, model) => fn(err, @)

  toJSON: ->
    id:       @id()
    username: @username()
    name:     @name()
    email:    @email()
    site:     @site()
    avatar:   @avatar()
