# frozen_string_literal: true

class PushNotification
  class Builder
    class << self
      def data(platform, device_token, message, image_url, consultant_id)
        data = {
          source: ENV['PUSH_NOTIFICATION_APP'],
          platform: platform,
          device_token: device_token,
          push_data: { message: message, image_url: image_url }
        }
        return data unless (consultant = Consultant.find_by(id: consultant_id))

        data[:push_data].merge!(sender_data(consultant))
        data
      end

      private

      def sender_data(consultant)
        {
          sender: {
            id: consultant.id.to_s,
            avatar: consultant.avatar[:square_200].url(public: true), # rubocop:disable Naming/VariableNumber
            name: consultant.name
          }
        }
      end
    end
  end
end
