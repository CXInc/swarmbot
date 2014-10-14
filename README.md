swarmbot
========

This may be useful if you:

* Use [Trello](https://trello.com)
* Use [Kanban WIP](https://chrome.google.com/webstore/detail/kanban-wip-for-trello/oekefjibcnongmmmmkdiofgeppfkmdii?hl=en-US) on your Trello board
* Use [Slack](https://slack.com/)

It watches your Trello board for lists that exceed their limits, and post to Slack when you need to swarm.

Deploying an instance on Heroku
-------------------------------

Prerequisites:

* [Heroku Toolbelt](https://toolbelt.heroku.com/)
* Slack credentials:
  * Slack team name. If you use slack at yourcompany.slack.com it would be "yourcompany".
  * Slack channel, for example "#general"
  * A Slack token. Get one by [setting up an incoming Webhook](https://my.slack.com/services/new/incoming-webhook)
* Trello credentials:
  * Trello public key from [the developer key page](https://trello.com/1/appKey/generate)
  * Trello member OAuth token. Substitute your public key into this URL and use it to get a token: https://trello.com/1/authorize?key=YOUR-KEY-HERE&name=swarmbot&expiration=never&response_type=token
  * Trello board ID. This is the full, 24-character ID, which you can get by opening the link at the bottom of [the developer key page](https://trello.com/1/appKey/generate).

Launching an instance:
```bash
git clone git@github.com:CXInc/swarmbot.git
cd swarmbot
heroku apps:create my-swarmbot-app-name-here
heroku addons:add rediscloud
heroku config:set SLACK_TEAM=YOUR_SLACK_TEAM \
    SLACK_TOKEN=YOUR_SLACK_TOKEN \
    SLACK_CHANNEL=YOUR_SLACK_CHANNEL \
    TRELLO_DEVELOPER_PUBLIC_KEY=YOUR_TRELLO_KEY \
    TRELLO_MEMBER_TOKEN=YOUR_TRELLO_TOKEN \
    TRELLO_BOARD_ID=YOUR_TRELLO_BOARD_OD \
    WEBHOOK_URL=http://my-swarmbot-app-name-here.herokuapp.com/webhook
```

Local development
-----------------

Prerequisites:

* Deployment prerequisites listed above
* Redis
* Ruby 2+
* Foreman (`gem install foreman`)
* (Optional) ngrok (`gem install ngrok`)

Get the code:
```bash
git clone git@github.com:CXInc/swarmbot.git
cd swarmbot
cp .env.example .env
```

Ngrok provides a convenient way to make your local development instance accessible by Trello webhooks. You can either use it or any other method of making your local instance reachable by Trello. For ngrok, run:

```bash
ngrok 5000
```

Add your credentials in .env, then run:

```bash
foreman run
```

If all is working, the app should boot up, and then show a HEAD request come in when Trello establishes a webhook.
