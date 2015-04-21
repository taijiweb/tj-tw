#http://stackoverflow.com/questions/313893/how-to-measure-time-taken-by-a-function-to-execute

exports.xxxtime = (fn) ->
  console.time('delay')
  fn()
  console.timeEnd('delay')
  # will print delay: xxx ms


exports.time = (fn) ->
  start = new Date().getTime()
  fn()
  new Date().getTime() - start

exports.nTime = (n, fn) ->
  start = new Date().getTime()
  while n-- then fn()
  new Date().getTime() - start