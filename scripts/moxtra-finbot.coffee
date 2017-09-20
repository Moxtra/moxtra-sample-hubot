# Description:
#   Get stocks' quote and charts
#
# Dependencies:
#   X2JS: Converting XML to JSON
#   request: making api calls
#
# Configuration:
#   None
#
# Commands:
#   -------------------------------- Finance --------------------------------
#   hubot <ticker> quote - Get the actual quote for the stock
#   hubot <ticker> summary - Get the Summary for the stock
#   hubot <ticker> [graph|chart] - Get the chart for the stock
#   hubot [currency|convert|how much] <currency symbol> to <currency symbol> - Converts one currency into another
#
# Author:
#   Moxtra Inc

X2JS = require 'x2js'
request = require 'request'
fs = require 'fs'


chartURL = "https://www.google.com/finance/getchart?q="
miniChartURL = "https://www.google.com/finance/chart?q="
quoteYahooURL = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%3D%22"
quoteYahooURLcont = "%22&env=store://datatables.org/alltableswithkeys"
currencyURL = "http://download.finance.yahoo.com/d/quotes.csv?s="
currencyURLcont = "=X&f=l1"


module.exports = (robot) -> 

    # Get the actual quote of the stock
    robot.respond /(.*) quote/i, (msg) ->
        stock = msg.match[1]
        if !stock 
            msg.send "Sorry, I didn't get the stock name."
        
        msg.http(quoteYahooURL + stock + quoteYahooURLcont)
        .get() (err, res, body) ->

            x2js = new X2JS()
            result = x2js.xml2js(body)
            
            # result = JSON.parse(body.replace(/\/\/ /, ''))
            # for resul in result
            if result.query.results.quote.Symbol == stock
                color = "#FF0000" #red 
                if result.query.results.quote.Change > 0
                    color = "#008000" #green
                msg.send "[size=13]Quote for: [b]#{result.query.results.quote.Name} (#{result.query.results.quote.Symbol})[/b][/size][table]"+
                        "[tr][td][size=28]USD #{result.query.results.quote.Ask}[/size][/td][td][color=#{color}]#{result.query.results.quote.Change}[/color][/td]"+
                        "[td][color=#{color}](#{result.query.results.quote.PercentChange})[/color][/td][td][img]"+ miniChartURL + "#{stock}&cht=s[/img][/td][/tr]" +
                        "[tr][td][size=10]Last trade time: #{result.query.results.quote.LastTradeTime}[/size][/td][/tr]" +
                        "[/table]"
    
    # Get the Summary of the stock
    robot.respond /(.*) summary/i, (msg) ->
        stock = msg.match[1]
        if !stock   
            msg.send "Sorry, I didn't get the stock name."
        
        msg.http(quoteYahooURL + stock + quoteYahooURLcont)
        .get() (err, res, body) ->
            x2js = new X2JS()
            result = x2js.xml2js(body)
            if result.query.results.quote.Symbol == stock
                color = "#FF0000" #red 
                if result.query.results.quote.Change > 0
                    color = "#008000" #green
                msg.send "[size=14]Summary for: [b]#{result.query.results.quote.Name} (#{result.query.results.quote.Symbol})[/b][/size][table]" +
                            "[tr][td][size=28]USD #{result.query.results.quote.Ask}[/size] [color=#{color}]#{result.query.results.quote.Change}[/color] [color=#{color}](#{result.query.results.quote.PercentChange})[/color][/td][/tr]"+
                            "[tr][td][size=11]Last trade time: #{result.query.results.quote.LastTradeTime}[/size][/td][/tr][/table]" +
                            "[img=400x250]#{chartURL}#{stock}&p=7d[/img]" +
                            "[table width='100%'][tr][td][size=12]Day's Lower: #{result.query.results.quote.DaysLow}[/size][/td][/tr]" +
                            "[tr][td][size=12]Day's Higher: #{result.query.results.quote.DaysHigh}[/size][/td][/tr]" +
                            "[tr][td][size=12]Open: #{result.query.results.quote.Open}[/size][/td][td][/td][/tr]" +
                            "[tr][td][size=12]Previous close price: #{result.query.results.quote.PreviousClose}[/size][/td][/tr]" +
                            "[tr][td][size=12]Range: #{result.query.results.quote.DaysRange}[/size][/td][td][/td][/tr]" +
                            "[tr][td][size=12]Volume: #{result.query.results.quote.Volume}[/size][/td][/tr]" +
                            "[tr][td][size=12]Market Cap.: #{result.query.results.quote.MarketCapitalization}[/size][/td][td][/td][/tr]" +
                            "[tr][td][size=12]EBITDA: #{result.query.results.quote.EBITDA}[/size][/td][/tr]" +
                            "[/table]"               

    # Currency converter
    robot.respond /(currency|convert|how much) (.*) to (.*)/i, (msg) ->
        currencyFrom = msg.match[2]
        currencyTO = msg.match[3]
        if !currencyFrom or !currencyTO
            msg.send "[table][tr][td]Sorry, I didn't find the currencies.[/td][/tr][tr][td]Please use this format: [color=red]@Finbot USD to EUR[/color][/td][/tr][/table]"
        
        msg.http(currencyURL+currencyFrom+currencyTO+currencyURLcont)
        .get() (err, res, body) ->
            if res.statusCode isnt 200 or !body
                msg.send "Sorry, I couldn't get the currencies for: "+currencyFrom+ " and "+currencyTO            
            value = body.replace "\n",""
            msg.send "[size=14]Currency Converter:[/size][table]" +
                    "[tr][td] 1 #{currencyFrom}[/td][/tr]" +
                    "[tr][td][size=28]#{value} #{currencyTO}[/size][/td][/tr]" +
                    "[tr][td][img]#{miniChartURL}CURRENCY:#{currencyFrom}#{currencyTO}&tkr=1&p=2Y&chst=vkc&chs=300x160[/img][/td][/tr]" +
                    "[/table]"

    # Get Stock Charts
    robot.respond /(.*) (graph|chart)/i, (msg) ->
        stock = msg.match[1].toUpperCase()
        if !stock   
            msg.send "Sorry, I didn't get the stock name."
        
        buttons = [{ type: 'postback', text: '30 days', payload: 'chartfor&'+stock+'&p=1M'}, { type: 'postback', text: '90 days', payload: 'chartfor&'+stock+'&p=3M'}, { type: 'postback', text: '1 year', payload: 'chartfor&'+stock+'&p=1Y'}]
        msg.message.buttons = buttons
        msg.send "Please, select chart period:"

    # Handling Buttons Postback
    robot.listen(
        (message) -> # Match function
            message.message_type is "bot_postback"
        (response) -> # Standard listener callback
            payload = response.message.event.postback.payload
            text = response.message.event.postback.text
            segments = payload.split("&")
            stockName = segments[1]
            period  = segments[2]

            if !payload
                response.send "Sorry, I couldn't get your response."

            if segments[0] == "chartfor"
                # Download the image
                today = new Date
                filename = stockName + "_stock_" + today.getDate() + ".png"
                request(chartURL+stockName+"&"+period).pipe(fs.createWriteStream(__dirname+'/images/'+filename)).on('close',()->
                    options = {}
                    options.file_path = __dirname+'/images/'+filename
                    response.message.options = options
                    response.send "Here is the requested chart:"
                )
    )