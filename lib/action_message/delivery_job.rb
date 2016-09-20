require 'active_job'

module ActionMessage
  class DeliveryJob < ActiveJob::Base
    queue_as { ActionMessage::Base.deliver_later_queue_name }

    def perform(messager, message_method, delivery_method, *args)
      messager.constantize.public_send(message_method, *args).send(delivery_method)
    end
  end
end
