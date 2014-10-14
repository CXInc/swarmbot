require "sinatra"
require "sinatra/json"
require "redis"
require "trello"
require "slack-notifier"
require "newrelic_rpm"

set :protection, :except => [:json_csrf]

def gif
  "http://imgur.com/qrLEV.gif"
end

configure do
  uri = URI.parse(ENV["REDISCLOUD_URL"] || "redis://localhost:6379")
  $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

  Trello.configure do |config|
    config.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
    config.member_token = ENV['TRELLO_MEMBER_TOKEN']
  end

  webhook_id = $redis.get("webhook-id")

  # Get a fresh webhook set up, just in case old one has died
  webhook = begin
    Trello::Webhook.find(webhook_id) if webhook_id
  rescue Trello::Error
    nil
  end

  webhook.delete if webhook

  # Need this to run after the app is able to serve requests
  Thread.new do
    sleep 0.1
    webhook = Trello::Webhook.create(
      description: "Swarmbot",
      id_model: ENV['TRELLO_BOARD_ID'],
      callback_url: ENV['WEBHOOK_URL']
    )

    $redis.set "webhook-id", webhook.id
  end

  $notifier = Slack::Notifier.new ENV['SLACK_TEAM'], ENV['SLACK_TOKEN'],
    channel: ENV['SLACK_CHANNEL'], username: 'swarmbot'
end

head '/webhook' do
  status 200
end

post '/webhook' do
  board = Trello::Board.find(ENV['TRELLO_BOARD_ID'])

  board.lists.each do |list|
    begin
      retries = 3

      matches = list.name.match(/(.*)\[.*?(\d+)\]/)
      next unless matches

      list_name = matches[1]

      if list.cards.size > matches[2].to_i
        next if $redis.get(list_name) == "over_limit"

        logger.info "Limit exceeded, sending notification..."
        $notifier.ping "Swarm time: #{list_name} #{gif}", icon_emoji: ":honeybee:"

        $redis.set list_name, "over_limit"
      else
        $redis.set list_name, "within_limit"
      end
    rescue Trello::Error
      retries -= 1
      retry if retries > 0
    end
  end

  status 200
end
