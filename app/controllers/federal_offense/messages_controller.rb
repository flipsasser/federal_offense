# frozen_string_literal: true

module FederalOffense
  class MessagesController < FederalOffense::ApplicationController
    before_action :require_message, only: %i[destroy show]
    after_action :mark_as_read, only: %i[show]

    def destroy
      message.destroy
      redirect_to messages_path
    end

    def destroy_all
      FederalOffense::Message.destroy_all
      redirect_to messages_path
    end

    def index
    end

    def show
      if params[:raw]
        case params[:type]
        when "html"
          render html: message.html_body
        when "text"
          render plain: message.text_body
        else
          render message.html? ? {html: message.html_body} : {plain: message.text_body}
        end
      end
    end

    private

    def mark_as_read
      message.update(read_at: Time.zone.now.to_i)
    end

    def message
      return @message if defined? @message
      @message = messages.find { |message| message.id == params[:id] }
    end
    helper_method :message

    def messages
      @messages ||= FederalOffense::Message.all
    end
    helper_method :messages

    def require_message
      redirect_to messages_path if message.blank?
    end
  end
end
