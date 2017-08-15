# Description:
#   Get stocks' quote and charts
#
# Dependencies:
#   None
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

chartURL = "https://www.google.com/finance/getchart?q="
quoteURL = "http://finance.google.com/finance/info?q="
miniChartURL = "https://www.google.com/finance/chart?q="
currencyURL = "http://finance.google.com/finance/info?q=CURRENCY:"


module.exports = (robot) -> 

    # Get the actual quote of the stock
    robot.respond /(.*) quote/i, (msg) ->
        stock = msg.match[1]
        if !stock 
            msg.send "Sorry, I didn't get the stock name."
        
        msg.http(quoteURL + stock)
        .get() (err, res, body) ->
            result = JSON.parse(body.replace(/\/\/ /, ''))
            for resul in result
                color = "#FF0000" #red 
                if resul.c > 0
                    color = "#008000" #green
                msg.send "[size=12]Quote for #{resul.e}: [b]#{resul.t}[/b][/size][table]" +
                     "[tr][td][size=28]USD #{resul.l}[/size][/td][td][color=#{color}]#{resul.c}[/color][/td]"+
                     "[td][color=#{color}](#{resul.cp}%)[/color][/td][td][img]"+ miniChartURL + "#{resul.t}&cht=s[/img][/td][/tr]" +
                     "[tr][td][size=10]#{resul.lt}[/size][/td][/tr]" +
                     "[/table]"
    
    # Get the Summary of the stock
    robot.respond /(.*) summary/i, (msg) ->
        stock = msg.match[1]
        if !stock   
            msg.send "Sorry, I didn't get the stock name."
        
        msg.http(quoteURL + stock)
        .get() (err, res, body) ->
            symbs = JSON.parse(body.replace(/\/\/ /, ''))
            result = ""
            for symb in symbs
                # quote
                result += "[size=12]Summary for #{symb.e}: [b]#{symb.t}[/b][/size][table]" +
                            "[tr][td][size=28]USD #{symb.l}[/size] [color=#{color}]#{symb.c}[/color] [color=#{color}](#{symb.cp}%)[/color][/td][/tr]"
                # after hours
                if symb.ec_fix
                    color = "#FF0000" #red
                    if symb.getEc_fix > 0
                        color = "#008000" #green
                    result += "[tr][td][size=12]After Hours: USD #{symb.el} [color=#{color}]#{symb.ec} (#{symb.ecp}%)[/color][/size][/td][/tr]"

                # last closing 
                result += "[tr][td][size=12]Previous close price: USD #{symb.pcls_fix}[/size][/td][/tr]"
                # date last 
                result += "[tr][td][size=10]#{symb.lt}[/size][/td][/tr][/table]"
                # chart 60 days
                result += "[img=400x250]#{chartURL}#{symb.t}&p=7d[/img]"

            msg.send result

    # Currency converter
    robot.respond /(currency|convert|how much) (.*) to (.*)/i, (msg) ->
        currencyFrom = msg.match[2]
        currencyTO = msg.match[3]
        if !currencyFrom or !currencyTO
            msg.send "[table][tr][td]Sorry, I didn't find the currencies.[/td][/tr][tr][td]Please use this format: [color=red]@Finbot USD to EUR[/color][/td][/tr][/table]"
        
        msg.http(currencyURL+currencyFrom+currencyTO)
        .get() (err, res, body) ->
            if res.statusCode isnt 200
                msg.send "Sorry, I couldn't get the currencies for: "+currencyFrom+ " and "+currencyTO

            symbs = JSON.parse(body.replace(/\/\/ /, ''))
            result = ""
            for symb in symbs
                if !symb.l
                    msg.send "Sorry, I couldn't get the currencies for: "+currencyFrom+ " and "+currencyTO

                result += "[size=14]Currency Converter:[/size][table]" +
                            "[tr][td] 1 #{symb.t.substring(0,3)}[/td][/tr]" +
                            "[tr][td][size=28]#{symb.l} #{symb.t.substring(3,6)}[/size][/td][/tr]" +
                            "[tr][td][size=10]#{symb.lt}[/size][/td][/tr]" +
                            "[tr][td][img]#{miniChartURL}CURRENCY:#{symb.t}&tkr=1&p=2Y&chst=vkc&chs=300x160[/img][/td][/tr]" +
                            "[/table]"

            msg.send result

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
                console.log "[img=400x250]#{chartURL}#{stockName}&#{period}[/img]"
                response.send "[img=400x250]#{chartURL}#{stockName}&#{period}[/img]"
                # options = {}
                # options.file_path = chartURL+stockName+period
                # response.message.options = options
    )