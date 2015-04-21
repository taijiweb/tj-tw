exports.extend = (target) ->
  i = 1;
  argumentsLength = arguments.length
  while i < argumentsLength
    source = arguments[i++]
    for key of source
      if source.hasOwnProperty(key) then target[key] = source[key]
  target

baseName = (str) ->
  base = new String(str).substring(str.lastIndexOf('/') + 1)
  if base.lastIndexOf(".") != -1 then base = base.substring(0, base.lastIndexOf("."))
  base

stackReg = /at\s+(.*)\s+\((.*):(\d*):(\d*)\)/gi
stackReg2 = /at\s+()(.*):(\d*):(\d*)/gi

window.ts = ''

_trace = (stackIndex, args) ->
  argsStr = ''
  for arg in args
    try
      if typeof arg=='function'
        s = arg.toString()
      else s = JSON.stringify(arg)
    catch e then s = arg
    if argsStr=='' or argsStr[argsStr.length-2...]==': ' or argsStr[argsStr.length-1]==':'
      argsStr = argsStr + s
    else argsStr = argsStr + ', '+ s
  stacklist = (new Error()).stack.split('\n').slice(3)
  s = stacklist[stackIndex]
  sp = stackReg.exec(s) || stackReg2.exec(s)
  if sp && sp.length == 5
    method = sp[1]
    file = baseName(sp[2])
    line = sp[3]
    pos = sp[4]
    s =  file+': '+method+': '+line+':'+pos+': '+argsStr+'\r\n'
  else s =  'noname:  noname: xx: yy: '+argsStr+'\r\n'
  console.log s
  debugLog = document.getElementById('debug-log')
  if debugLog
    p = document.createElement('p')
    p.appendChild document.createTextNode(s)
    debugLog.appendChild(p)
  window.ts = ts + s

exports.clearTrace = ->
  ts = ""
  document.getElementById('debug-log').innerHTML = ""

exports._log = window._log =  _log = (level, args...) -> _trace(level, args); console.log(args...)
exports.trace = window.trace = trace = (args...) ->  _trace(0, args)
exports.trace0 = window.trace = trace = (args...) -> _trace(0, args)
exports.trace1 = window.trace1 = trace1 = (args...) -> _trace(1, args)
exports.trace2 = window.trace2 = trace2 = (args...) -> _trace(2, args)
exports.trace3 = window.trace3 = trace3 = (args...) -> _trace(3, args)
exports.log = window.log = log = (args...) ->  _log(0, args)
exports.log0 = window.log0 = log0 = (args...) -> _trace(0, args)
exports.log1 = window.log1 = log1 = (args...) -> _trace(1, args)
exports.log2 = window.log2 = log2 = (args...) -> _trace(2, args)
exports.log3 = window.log3 = log3 = (args...) -> _trace(3, args)

exports.assert = window.assert = assert = (value, message) ->
  if not value
    trace2('assert:', message or 'assert failed')
    throw new Error message or 'assert failed'

exports.isArray = isArray = (exp) -> Object::toString.call(exp) == '[object Array]'
exports.isObject = isObject = (exp) -> exp instanceof Object