ErrorPage = require 'error-page'
merge = require 'deepmerge'
fs = require 'fs'
plates = require 'plates'
util = require 'util'
errs = require 'errs'


# An `error-page` handler, because `templar` wasn't working.
errorTemplate = (req, res, data) ->
  template = if 400 <= data.code < 500 then "4xx" else "5xx"
  template = data.options.platesDir + data.options.templates[template]

  # Note that eventually all error pages will be html. Prefer HTTP requests.
  # If we get them with `request` then have them configured through URLs.
  fs.readFile template, (err, plate) ->
    if err
      # Error page not found.
      data.furtherError = err
      res.writeHead 500, "Content-Type": "text/html"
      res.end JSON.stringify data
    else
      # Using plates to serve the html.
      # So that the pages can say more about what went wrong.
      res.writeHead data.code, "Content-Type": "text/html"
      map = plates.Map()
      for item in data.options.debugLess.classes
        map.class(item).remove()
      debugClass = data.options.debugClass
      start = data.options.debugBlock.start
      close = data.options.debugBlock.close
      if data.options.debug
        debugHTML = start + data.stack + close + '<br/>'
        delete data.stack
        delete data.options unless data.show
        debugHTML += start + (JSON.stringify data, null, '  ') + close
        map.where('class').is(debugClass).partial debugHTML
      res.end (plates.bind plate.toString(), data, map)


# The options: defaults and how they can be overridden.
options = (input = {}) ->
  defaults =
    show: false # these options when debug is true
    debug: if process.env.NODE_ENV is 'development' then true else false
    debugLess:
      classes: []
    debugBlock:
      start: '<p><pre class="prettyprint"><code class="language-js">'
      close: '</code></pre></p>'
    "*": errorTemplate

  opts = merge defaults, input
  unless opts.debug
    opts.debugLess.classes = [ opts.debugClass ]
  opts


# What cannot continue further.
forbidden = (req, opts) ->
  if opts.forbidden?
    for path in opts.forbidden
      if req.path.match path
        return true
  false


# Use this middleware before any errors happen - becomes `options`' `input`.
module.exports.connect = (opts) ->
  (req, res, next) ->
    res.heckOptions = opts
    if forbidden req, opts
      # TODO: a nice error page
      res.error = new ErrorPage req, res
      res.error 403, "Not Allowed"
    else next()


# Pass to `vfs-http-handler` or call directly.
module.exports.handler = handle = (req, res, err, code) ->
  # Can pass err as a `String`, make it a real `Error`.
  err = errs.create err unless util.isError err
  console.error err.stack || err

  # The configurable error-page options.
  opts = options res.heckOptions

  # Set the status code & error message.
  if forbidden req, opts
    # NOTE: this does not ever get used, because it's just for things that fail.
    # Forbidden stuff has to be pre-checked in the connect middleware (200 too).
    status = 403
    message = "Not Allowed"
  else
    message = err.stack.message || err.message || err
    if code then status = code
    else switch err.code
      when "EBADREQUEST"
        status = 400
      when "EACCESS"
        status = 403
      when "ENOENT"
        status = 404
      when "ENOTREADY"
        status = 503
      when "EISDIR"
        # Directories must end with a '/'.
        return res.redirect req.url + '/'
      else status = 500

  # Handle the error.
  res.error = new ErrorPage req, res, opts
  res.error status, message

