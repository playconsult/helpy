require 'net/http'
require 'pp'
class SlackNotifier

  def initialize()
    self.default_webhook = AppSettings["slack.notify_webhook"]
  end

  def self.notify_topic(topic)
    body = build_notification(topic, topic.posts.first, "created")
    send_notification(topic.slack_webhook, body)
  end

  def self.notify_reply(post)
    body = build_notification(post.topic, post, "updated")
    send_notification(topic.slack_webhook, body)
  end


  private

  def self.build_notification(topic, post, action)
    return {
      "username": AppSettings["settings.site_name"],
      "attachments":[
          {
             "fallback":"Ticket has been #{action}: (#{topic.id}) #{topic.name}",
             "pretext":"Ticket has been #{action}",
             "color":"#{AppSettings["css.main_color"]}",
             "fields":[
                {
                   "title":"\##{topic.id}: #{topic.name}",
                   "title_link": "#{AppSettings["settings.site_url"]}/admin/topics/#{topic.id}",
                   "value": "#{if post.nil? then topic.user_name else post.body end}",
                   "short": false
                }
             ]
          }
       ]
    }
  end

  def self.send_notification(webhook, body)
      response = request(webhook, body)

      case response.code
      when 400..599
        raise response.to_s
      end
  end

  def self.request(url, payload)
    uri = URI.parse(url.strip())

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    http.request(request)
  end

end
