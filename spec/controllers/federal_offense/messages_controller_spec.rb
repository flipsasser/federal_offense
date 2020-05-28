# frozen_string_literal: true

require "spec_helper"

RSpec.describe FederalOffense::MessagesController do
  routes { FederalOffense::Engine.routes }

  describe "#destroy" do
    it "allows us to destroy a message" do
      generate_message
      expect {
        post :destroy, params: {id: message.id}
      }.to change {
        FederalOffense::Message.all.size
      }.from(1).to(0)
    end

    it "doesn't explode when it can't find a message" do
      post :destroy, params: {id: "nonexistant"}
      expect(response).to redirect_to(messages_path)
    end
  end

  describe "#destroy_all" do
    before { generate_messages(3) }

    it "removes all messages" do
      expect {
        post :destroy_all
      }.to change {
        FederalOffense::Message.all.size
      }.from(3).to(0)
    end

    it "returns a user to the inbox" do
      post :destroy_all
      expect(response).to redirect_to(messages_path)
    end
  end

  describe "#index" do
    it "shows an empty screen when there are no messages" do
      get :index
      expect(response.body).to have_css("aside .empty .empty-title", text: t("federal_offense.empty.title"))
      expect(response.body).to have_css("aside .empty .empty-subtitle", text: t("federal_offense.empty.subtitle"))
    end

    describe "with some messages" do
      before do
        generate_message
        generate_message(:no_subject)
        generate_message(:plaintext)
      end

      it "shows a list of messages" do
        get :index
        messages.each do |message|
          expect(response.body).to have_css("aside .list .list-item-title", text: message.subject)
        end
      end

      it "shows an empty detail view" do
        get :index
        expect(response.body).to have_css("section .empty .empty-title", text: t("federal_offense.unselected.title"))
        expect(response.body).to have_css("section .empty .empty-subtitle", text: t("federal_offense.unselected.subtitle"))
      end
    end
  end

  describe "#show" do
    describe "within the message detail view" do
      before do
        generate_message
        get :show, params: {id: message.id}
      end

      it "includes the message date" do
        expect(response.body).to have_css("section header th", text: t("federal_offense.attributes.date"))
        expect(response.body).to have_css("section header th + td", text: message.date)
      end

      it "includes the message subject" do
        expect(response.body).to have_css("section header th", text: t("federal_offense.attributes.subject"))
        expect(response.body).to have_css("section header th + td", text: message.subject)
      end

      it "includes the message sender" do
        expect(response.body).to have_css("section header th", text: t("federal_offense.attributes.from"))
        expect(response.body).to have_css("section header th + td", text: message.from.first)
      end

      it "includes the message recipient" do
        expect(response.body).to have_css("section header th", text: t("federal_offense.attributes.to"))
        expect(response.body).to have_css("section header th + td", text: message.to.first)
      end

      it "includes the message body in an iframe" do
        expect(response.body).to have_css("section iframe.message-body[src='#{message_path(message.id, raw: true)}']")
      end
    end

    describe "with a `raw` flag" do
      it "renders the raw message HTML" do
        generate_message(:html_only)
        get :show, params: {id: message.id, raw: true}
        expect(response.body).to eq(message.html_body)
      end

      it "renders the raw message plaintext if no HTML is available" do
        generate_message(:plaintext)
        get :show, params: {id: message.id, raw: true}
        expect(response.body).to eq(message.text_body)
      end

      it "accepts a `type` param that overrides the response type (if available)" do
        generate_message
        get :show, params: {id: message.id, raw: true, type: "html"}
        expect(response.body).to eq(message.html_body)

        get :show, params: {id: message.id, raw: true, type: "text"}
        expect(response.body).to eq(message.text_body)
      end
    end

    describe "with an unread message" do
      before { generate_message }

      it "updates the message's 'read_at' value" do
        expect {
          get :show, params: {id: message.id}
        }.to change {
          FederalOffense::Message.all.first.read?
        }.from(false).to(true)
      end

      it "still shows the message as 'new' in the interface the first time it's viewed" do
        get :show, params: {id: message.id}
        expect(response.body).to have_css("aside .list .list-item.list-item--unread")

        get :show, params: {id: message.id}
        expect(response.body).not_to have_css("aside .list .list-item.list-item--unread")
      end
    end
  end
end
