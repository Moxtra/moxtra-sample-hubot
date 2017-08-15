# Description:
#   A way to search images on giphy.com
#
# Configuration:
#   HUBOT_GIPHY_API_KEY
#
# Commands:
#   --------------------------------- Giphy ---------------------------------
#   hubot gif me <query> - Get animated gif matching the term.

giphy =
  api_key: '01474751409c4774a995ac9e37d24090'
  base_url: 'http://api.giphy.com/v1'

module.exports = (robot) ->
  robot.respond /(gif|giphy)( me)? (.*)/i, (msg) ->
    giphyMe msg, msg.match[3], (url) ->
      msg.send "[img]"+url+"[/img]"

giphyMe = (msg, query, cb) ->
  endpoint = '/gifs/search'
  url = "#{giphy.base_url}#{endpoint}"

  msg.http(url)
    .query
      q: query
      api_key: giphy.api_key
    .get() (err, res, body) ->
      response = undefined
      try
        response = JSON.parse(body)
        images = response.data
        if images.length > 0
          image = msg.random images
          cb image.images.original.url

      catch e
        response = undefined
        cb 'Error'

      return if response is undefined
