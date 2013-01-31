config = app.get('github_config')

class global.Github

  uid:    -> @model.uid
  source: -> @model.source
  token:  -> @model.token

  redirect: ->
    query = "?client_id=#{config.app_id}"
    "https://github.com/login/oauth/authorize#{query}"

  access_token: (code, fn) ->
    opts =
      url: 'https://github.com/login/oauth/access_token'
      method: 'POST'
      json: true
      form:
        client_id: config.app_id
        client_secret: config.app_secret
        code: code
    request opts, (e, r, body) =>
      return fn(body) unless r?.statusCode is 200
      @fetch(body, fn)

  fetch: (token, fn) ->
    opts =
      url: 'https://api.github.com/user'
      qs: { access_token: token.access_token }
    request opts, (e, r, body) =>
      return fn(body) unless r?.statusCode is 200
      @model = { uid: body.id, source: 'github', token: token.access_token }
      @user =
        username: body.login
        name:     body.name
        email:    body.email
        site:     body.html_url
        avatar:   body.avatar_url
      fn(null, @)
