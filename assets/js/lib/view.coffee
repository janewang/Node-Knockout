class TheXX.View extends Backbone.View

  append: ->
    @$el.hide().appendTo(@options.append or $('#main')).fadeIn()
    @rendered()

  rendered: ->
    @

  render: ->
    TheXX.current.push @
    return @append() unless @template?
    data = (@model or @collection)?.toJSON()
    dust.render @template, data or {}, (err, out) =>
      @$el.html(out)
      @append()
    @

  remove: ->
    @unbind()
    @model?.off(null, null, @)
    @collection?.off(null, null, @)
    TheXX.off(null, null, @)
    TheXX.remove_view(@)
    @onClose?()
    super()
