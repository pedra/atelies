define ['underscore'], (_) ->
  class Cart
    @_carts: null
    @get: (storeSlug) ->
      unless @_carts?
        @_carts = []
        @_carts.clear = -> cart.clear() for cart in @
      switch storeSlug
        when '' then throw message:'Cart needs a string'
        when undefined then return @_carts
      cart = _.findWhere @_carts, storeSlug: storeSlug
      unless cart?
        cart = new Cart storeSlug
        @_carts.push cart
      cart
    constructor: (@storeSlug) ->
      @_load()
    _items: []
    _load: ->
      @_items = []
      previousSessionItems = localStorage.getItem "cartItems#{@storeSlug}"
      if previousSessionItems? then @_items = JSON.parse previousSessionItems
    save: =>
      localStorage.setItem "cartItems#{@storeSlug}", JSON.stringify @_items
    addItem: (item) =>
      if existingItem = _.findWhere @_items, { _id: item._id }
        existingItem.quantity++
      else
        item.quantity = 1
        @_items.push item
      @save()
    clear: =>
      @_items = []
      localStorage.removeItem "cartItems#{@storeSlug}"
    items: -> @_items
    removeById: (id) =>
      @_items = _.reject @_items, (item) -> item._id is id
      @save()
