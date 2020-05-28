# frozen_string_literal: true

module FederalOffense
  class Message < OpenStruct
    ROOT = Rails.root.join("tmp", "federal_offense").freeze

    EMPTY_TEXT_BODY = "No message content"
    EMPTY_HTML_BODY = "<html><body><em>#{EMPTY_TEXT_BODY}</em></body></html>"
    EMPTY_SUBJECT = "(no subject)"

    class << self
      def all
        Dir[ROOT.join("*.json")].map { |message|
          read(message)
        }.sort_by(&:date)
      end

      def create(message)
        # Create a unique ID for the message
        timestamp = Time.zone.now.to_i
        components = [timestamp] + Array(message.from) + Array(message.to) + [message.subject, SecureRandom.hex(3)]
        id = components.join(" ")
        id = Digest::SHA1.hexdigest(id)

        # Prepare the filesystem for the JSON record
        FileUtils.mkdir_p(ROOT)
        path = ROOT.join("#{id}.json")

        html, text = if message.parts.any?
          [message.html_part&.body, message.text_part&.body]
        else
          is_html = message.content_type.match?(/html/i)
          [
            is_html ? message.body : nil,
            is_html ? nil : message.body,
          ]
        end

        # Set up some default attributes
        attributes = {
          bcc: message.bcc,
          cc: message.cc,
          date: timestamp,
          from: message.from,
          html: html,
          id: id,
          path: path,
          subject: message.subject,
          text: text,
          to: message.to,
        }

        new(attributes).tap do |new_message|
          new_message.write
          new_message.save_attachments(message)
        end
      end

      def destroy_all
        FileUtils.rm_rf(ROOT)
      end

      private

      def read(path)
        attributes = File.exist?(path) ? JSON.parse(File.read(path)) : {}
        new(attributes.merge(path: path))
      end
    end

    delegate :to_json, to: :as_json

    def as_json(*args)
      @table.as_json(*args)
    end

    def date
      @date ||= Time.zone.at(super)
    end

    def destroy
      FileUtils.rm_rf(ROOT.join(id))
      File.unlink(path)
    end

    def html?
      html.present?
    end

    def html_body
      (html || {}).fetch("raw_source", EMPTY_HTML_BODY).html_safe # rubocop:disable Rails/OutputSafety
    end

    def read?
      read_at.present?
    end

    def save_attachments(message)
      # return unless message.attachments.any?
      # FileUtils.mkdir_p(ROOT.join(id))

      # message.attachments.each do |attachment|
      #   # TODO: Save the attachments if need be, but this is complex and we don't need to sweat it
      #   # for now
      # end
    end

    def subject
      super.presence || EMPTY_SUBJECT
    end

    def text?
      text.present?
    end

    def text_body
      (text || {}).fetch("raw_source", EMPTY_TEXT_BODY)
    end

    def unread?
      !read?
    end

    def update(attributes)
      write_attributes(attributes)
      write
    end

    def write
      File.open(path, "w+") do |file|
        file.puts to_json
      end
    end

    def write_attributes(attributes)
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end
  end
end
