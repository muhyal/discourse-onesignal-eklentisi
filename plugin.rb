# name: discourse-onesignal-eklentisi
# about: OneSignal API ile bildirim gonderimi
# version: 1.0
# authors: muhyal
# url: https://github.com/muhyal/discourse-onesignal-eklentisi

after_initialize do
  if SiteSetting.onesignal_push_enabled

    load File.expand_path("jobs/onesignal_push_notification.rb", __dir__)

    DiscourseEvent.on(:post_notification_alert) do |user, payload|

      if SiteSetting.onesignal_app_id.nil? || SiteSetting.onesignal_app_id.empty?
          Rails.logger.warn("OneSignal App ID belirtilmemis")
          return
      end
      if SiteSetting.onesignal_rest_api_key.nil? || SiteSetting.onesignal_rest_api_key.empty?
          Rails.logger.warn("OneSignal REST API anahtari belirtilmemis")
          return
      end

      Jobs.enqueue(:onesignal_push_notification, payload: payload, username: user.username)

    end

  end
end
