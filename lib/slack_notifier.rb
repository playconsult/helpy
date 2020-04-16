require 'net/http'
class SlackNotifier

  def self.notify_topic(topic_id)
    @topic = Topic.find(topic_id)
    body = build_notification(@topic, @topic.posts.first, "created")
    send_notification(@topic.slack_webhook, body)
  end

  def self.notify_reply(post_id)
    @post = Post.find(post_id)
    body = build_notification(@post.topic, @post, "updated")
    send_notification(@post.topic.slack_webhook, body)
  end


  private

  def self.build_notification(topic, post, action)
    return {
      "username": AppSettings["settings.site_name"],
      "text": "#{AppSettings["settings.site_name"]}: Ticket #{action}",
      "blocks": [
      		{
      			"type": "section",
      			"text": {
      				"type": "mrkdwn",
      				"text": "Ticket has been #{action}:"
      			}
      		},
      		{
      			"type": "section",
      			"block_id": "section567",
      			"text": {
      				"type": "mrkdwn",
      				"text": "<#{AppSettings['settings.site_url']}/admin/topics/#{topic.id}|\##{topic.id}: #{topic.name}>"
      			}
      		},
      		{
      			"type": "section",
      			"block_id": "section789",
      			"fields": [
      				{
      					"type": "mrkdwn",
      					"text": "#{if post.nil? then topic.user_name else "#{post.user.name}: #{post.body}" end}"
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
