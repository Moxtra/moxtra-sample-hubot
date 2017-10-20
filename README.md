# moxtra-sample-hubot

This is a sample of a [Hubot][hubot-link] using [Moxtra's Adapter][MoxAdapter].

moxtra-sample-hubot is a chat bot built on the [Hubot][hubot] framework.
It also uses [Moxtra's adapter][MoxAdapter] to connect your Hubot to your 
[Moxtra's account][moxtra].

[hubot-link]: https://hubot.github.com/
[MoxAdapter]: https://github.com/Moxtra/hubot-moxtra
[heroku]: http://www.heroku.com
[hubot]: http://hubot.github.com
[generator-hubot]: https://github.com/github/generator-hubot
[moxtra]: http://www.moxtra.com

## Running your moxtra-sample-hubot

Please take a look at the documentation provided on [hubot-moxtra github repository][MoxAdapter].
Once you understand how Hubot and the [Moxtra's Adapter][MoxAdapter] works you will master this example.

    % bin/hubot -a moxtra

## What I will find

This is a complete Moxtra Hubot code, here you will find all the necessary code to run your Moxtra Hubot Bot. 

In this code you will find examples on how to handle Moxtra's Events:

    - "bot_installed"
    - "bot_uninstalled"
    - Sending text, rich messages and buttons
    - Handling Buttons Postback
    - Sending Files
    - Linking 3rd party accounts using OAuth2

All the Moxtra example code are located in the file [Scripts/moxtra-example.coffee][file].

[file]: https://github.com/Moxtra/moxtra-sample-hubot/blob/master/scripts/moxtra-example.coffee

## How to use the examples

After you have your bot running in a public server, using HTTPS protocol, [connected to Moxtra][createbot] and installed in a Moxtra Binder then you can run the following commands in your Binder:

    @Moxie Hi
    files
    meet
    link my account
    GOOG quote
    AAPL summary
    DIS chart


[createbot]: https://developer.moxtra.com/nextbots



