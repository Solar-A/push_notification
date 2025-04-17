# frozen_string_literal: true

require_relative '../../lib/push_notification/builder'
require 'sidekiq'

class Push
  class SendingWorker
    include Sidekiq::Worker

    sidekiq_options retry: false

    def perform(action, platform, device_token, message, image_url, consultant_id)
      uri = URI.parse("#{ENV['PUSH_NOTIFICATION_API_URL']}/#{action}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      data = PushNotification::Builder.data(platform, device_token, message, image_url, consultant_id)
      request = Net::HTTP::Post.new("#{uri.request_uri}?#{data.to_query}")
      http.request(request)
    end
  end
end
