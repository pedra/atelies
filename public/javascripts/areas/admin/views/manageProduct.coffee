define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'underscore'
  'text!./templates/manageProduct.html'
  'text!./templates/validationErrors.html'
  '../models/product'
  '../models/products'
  'backboneValidation'
], ($, Backbone, Handlebars, _, manageProductTemplate, validationErrorsTemplate, Product, Products, Validation) ->
  class ManageProductView extends Backbone.Open.View
    events:
      'click #updateProduct':'_updateProduct'
      'click #confirmDeleteProduct':'_deleteProduct'
    @justCreated: false
    template: manageProductTemplate
    initialize: (opt) =>
      @model = opt.product
      @store = opt.store
      @$el.html @template
      @bindings = @initializeBindings
        "#_id": "html:_id"
        "#slug": "html:slug"
        "#_id_holder": "toggle:_id"
        "#slug_holder": "toggle:slug"
        "#height": "value:integerOr(height)"
        "#width": "value:integerOr(width)"
        "#depth": "value:integerOr(depth)"
        "#weight": "value:decimalOr(weight)"
        "#shippingHeight": "value:integerOr(shippingHeight)"
        "#shippingWidth": "value:integerOr(shippingWidth)"
        "#shippingDepth": "value:integerOr(shippingDepth)"
        "#shippingWeight": "value:decimalOr(shippingWeight)"
        "#inventory": "value:integerOr(inventory)"
        "#price": "value:decimalOr(price)"
        "#hasInventory": "checked:hasInventory"
        "#showPicture": "attr:{src:picture}"
      @_setValidation()
    _setValidation: ->
      val = @model.validation
      unless @store.get 'autoCalculateShipping'
        vals = [ val.shippingHeight, val.shippingWidth, val.shippingDepth, val.shippingWeight ]
        for v in vals
          digits = v.pop()
          required = v.pop()
          required.required = false
          v.push digits, required
      Validation.bind @
      validationErrorsEl = $('#validationErrors', @$el)
      valContext = Handlebars.compile validationErrorsTemplate
      @model.bind 'validated', (isValid, model, errors) =>
        if isValid
          validationErrorsEl.empty()
          validationErrorsEl.hide()
        else
          validationErrorsEl.html valContext errors:errors
          validationErrorsEl.show()
    _updateProduct: =>
      if @model.isValid true
        $("#updateProduct").prop "disabled", on
        pictureVal = $('#picture').val()
        if typeof pictureVal isnt 'undefined' and pictureVal isnt ''
          @model.hasFiles = true
          @model.form = $('#editProduct')
        else
          @model.hasFiles = false
        @model.save @model.attributes,
          success: @_productUpdated
          error: (model, xhr, options) =>
            @logXhrError 'admin', xhr
            $("#updateProduct").prop "disabled", off
            if xhr.status is 422
              $('#sizeIsIncorrect .errorMsg', @$el).text JSON.parse(xhr.responseText).smallerThan
              return $('#sizeIsIncorrect').modal()
            @showDialogError "Não foi possível salvar o produto. Tente novamente mais tarde."
    _deleteProduct: =>
      @model.destroy
        wait:true
        success: @_productDeleted
        error: (model, xhr, options) =>
          @showDialogError "Não foi possível excluir o produto. Tente novamente mais tarde."
          @logXhrError 'admin', xhr
    _productUpdated: =>
      Backbone.history.navigate "store/#{@store.get('slug')}", trigger: true
    _productDeleted: =>
      $('#confirmDeleteModal').modal 'hide'
      Backbone.history.navigate "store/#{@store.get('slug')}", trigger: true
