# frozen_string_literal: true

require "spec_helper"

RSpec.describe FederalOffense::Message do
  # Class methods
  describe ".all" do
    before { generate_messages(3) }

    it "returns all outbound ActionMailer messages" do
      expect(messages.size).to eq(3)
    end

    it "sorts messages by date (ascending)" do
      first = messages[0]
      middle = messages[1]
      last = messages[2]
      expect(first.date).to be < middle.date
      expect(middle.date).to be < last.date
    end
  end

  describe ".destroy_all" do
    it "destroys all messages" do
      generate_messages(3)
      expect {
        described_class.destroy_all
      }.to change {
        described_class.all.size
      }.from(3).to(0)
    end

    it "removes the entire file cache" do
      generate_messages(3)
      expect {
        described_class.destroy_all
      }.to change {
        File.directory?(described_class::ROOT)
      }.from(true).to(false)
    end
  end

  # Instance methods
  describe "#destroy" do
    before { generate_message }

    it "deletes the message on the filesystem" do
      expect {
        message.destroy
      }.to change {
        Dir[described_class::ROOT.join("*.json")].size
      }.from(1).to(0)
    end

    it "deletes the message from the `all` array" do
      expect {
        message.destroy
      }.to change {
        described_class.all.size
      }.from(1).to(0)
    end
  end

  describe "#html?" do
    it "returns `true` if the message has an HTML body" do
      generate_message(:html_only)
      expect(message).to be_html
    end

    it "returns `false` if the message has no HTML body" do
      generate_message(:plaintext)
      expect(message).not_to be_html
    end
  end

  describe "#html_body" do
    it "returns the HTML body of the message" do
      generate_message
      expect(message.html_body).to match(/User update zomg!/)
    end

    it "returns the default message if there is no body" do
      generate_message(:plaintext)
      expect(message.html_body).to eq(described_class::EMPTY_HTML_BODY)
    end
  end

  describe "#read?" do
    before { generate_message }

    it "returns `false` if the message has not been marked as read" do
      expect {
        message.update(read_at: Time.zone.now)
      }.to change(message, :read?).from(false).to(true)
    end
  end

  describe "#subject" do
    it "returns the subject of the message" do
      generate_message
      expect(message.subject).to eq("This is a test subject innit")
    end

    it "returns a default subject if none is provided" do
      generate_message(:no_subject)
      expect(message.subject).to eq(described_class::EMPTY_SUBJECT)
    end
  end

  describe "#text?" do
    it "returns `true` if the message has a plaintext body" do
      generate_message(:plaintext)
      expect(message).to be_text
    end

    it "returns `false` if the message has no plaintext body" do
      generate_message(:html_only)
      expect(message).not_to be_text
    end
  end

  describe "#text_body" do
    it "returns the text body of the message" do
      generate_message
      expect(message.text_body).to match(/Text user update zomg!/)
    end

    it "returns the default message if there is no body" do
      generate_message(:html_only)
      expect(message.text_body).to eq(described_class::EMPTY_TEXT_BODY)
    end
  end

  describe "#unread?" do
    before { generate_message }

    it "returns `true` if the message has not been marked as read" do
      expect {
        message.update(read_at: Time.zone.now)
      }.to change(message, :unread?).from(true).to(false)
    end
  end
end
