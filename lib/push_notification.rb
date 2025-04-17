# frozen_string_literal: true

require_relative '../workers/push/sending_worker'
require 'sidekiq'

class PushNotification
  def initialize(contact)
    @contact = contact
    @message = nil
    @image_url = nil
    @consultant = nil
  end

  def add_message(message)
    @message = message.truncate(180)
    self
  end

  def add_consultant(consultant)
    @consultant = consultant
    self
  end

  def add_image(image_url)
    @image_url = image_url
    self
  end

  def send
    @contact.devices.find_each { |device| send_notification_to_device(device) }
  end

  def send_notification_to_device(device)
    return nil if device.notification_token.nil?

    send_notification_via_api(device.platform, device.notification_token)
  end

  private

  def send_notification_via_api(platform, device_token)
    Push::SendingWorker.perform_async('send', platform, device_token, @message, @image_url, @consultant&.id)
  end
end
