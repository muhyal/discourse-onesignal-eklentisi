module ::Jobs
  class OnesignalPushNotification < Jobs::Base

    ONE_SIGNAL_API = "https://onesignal.com/api/v1/notifications".freeze

    def execute(args)

      # {
      #     "notification_type"=>6,
      #     "post_number"=>4,
      #     "topic_title"=>"Topic title",
      #     "topic_id"=>18,
      #     "excerpt"=>"excerpt",
      #     "username"=>"admin",
      #     "post_url"=>"/t/topic-title"
      # }
      #

      payload = args["payload"]
      receiver = args[:username]
      sender = payload[:username]
      topic_title = payload[:topic_title]
      excerpt = payload[:excerpt]
      notification_type = payload[:notification_type]
      post_url = payload[:post_url]

      case notification_type
      when Notification.types[:mentioned]
        heading = "#{sender} sizden bahsetti - #{topic_title}"
        contents = excerpt
      when Notification.types[:replied]
        heading = "#{sender} yanıtladı - #{topic_title}"
        contents = excerpt
      when Notification.types[:private_message]
        heading = "#{sender} mesaj gönderdi - #{topic_title}"
        contents = excerpt
      when Notification.types[:posted]
        heading = "#{sender} yazdı #{topic_title}"
        contents = excerpt
      when Notification.types[:linked]
        heading = "#{sender} bağlantıladı - #{topic_title}"
        contents = excerpt
      else
        heading = topic_title
        contents = "#{sender}: #{excerpt}"
      end

      filters = [
          {"field": "tag", "key": "username", "relation": "=", "value": args["username"]}
      ]

      params = {
          "app_id" => SiteSetting.onesignal_app_id,
          "contents" => {"en" => contents},
          "headings" => {"en" => heading},
          "data" => {"discourse_url" => post_url},
          "ios_badgeType" => "Increase",
          "ios_badgeCount" => "1",
          "filters" => filters
      }

      uri = URI.parse(ONE_SIGNAL_API)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == "https"

      request = Net::HTTP::Post.new(uri.path,
                                    "Content-Type"  => "application/json;charset=utf-8",
                                    "Authorization" => "Basic #{SiteSetting.onesignal_rest_api_key}")
      request.body = params.as_json.to_json
      response = http.request(request)

      case response
      when Net::HTTPSuccess then
        Rails.logger.info("Push notification sent via OneSignal to #{receiver}.")
      else
        Rails.logger.error("OneSignal error")
        Rails.logger.error("#{request.to_yaml}")
        Rails.logger.error("#{response.to_yaml}")
      end

    end
  end
end
