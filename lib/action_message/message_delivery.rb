module ActionMessage
  class MessageDelivery
    attr_reader :message_class, :action, :args

    def initialize(message_class, action, *args)
      @message_class, @action, @args = message_class, action, args

      @processed_sms = nil
    end

    def processed?
      @processed_sms
    end

    def deliver_now
      processed_sms.send(action, *args).deliver
    end

    def deliver_later(options={})
      enqueue_delivery :deliver_now, options
    end

    protected
      def processed_sms
        @processed_sms ||= @message_class.new.tap do |message|
          message.template_name = action.to_s
        end
      end

      def enqueue_delivery(delivery_method, options={})
        if processed?
          ::Kernel.raise "You've accessed the message before asking to " \
            "deliver it later, so you may have made local changes that would " \
            "be silently lost if we enqueued a job to deliver it."
        else
          args = @message_class.name, @action.to_s, delivery_method.to_s, *@args
          ::ActionMessage::DeliveryJob.set(options).perform_later(*args)
        end
      end
  end
end
