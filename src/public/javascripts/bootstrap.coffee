require.config
  paths:
    jquery: 'lib/jquery.min'
    underscore: 'lib/underscore-min'
    backbone: 'lib/backbone-min'
    handlebars: 'lib/handlebars.min'
    text: 'lib/text'
    twitterBootstrap: 'lib/bootstrap.min'
    jqueryVal: 'lib/jquery.validate.min'
    backboneModelBinder: 'lib/Backbone.ModelBinder'

  shim:
    'jQueryUI':
      deps: ['jquery']
    'handlebars':
      deps: ['jquery']
      exports: 'Handlebars'
    'underscore':
      exports: '_'
    'backbone':
      deps: ['underscore', 'jquery', 'handlebars']
      exports: 'Backbone'
    'twitterBootstrap':
      deps: ['jquery']
      exports: '$.fn.popover'
    'jqueryVal':
      deps: ['jquery']
      exports: '$.validator'
require [
  'handlebars'
  'app'
  'twitterBootstrap'
], (Handlebars, App) ->
  Handlebars.registerHelper 'formataData', (valor) ->
    return "" if not valor
    try
      data = new Date(valor)
      (data.getUTCMonth() + 1) + "/" + data.getUTCDate() + "/" + data.getUTCFullYear()
    catch error
      valor
  App.start()
