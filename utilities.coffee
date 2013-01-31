exports.randomString = (len=10) ->
  chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
  (chars[Math.round(Math.random() * (chars.length - 1))] for i in [1..len]).join('')

exports.randomArray = (arr) ->
  arr[Math.floor(Math.random() * arr.length)]
