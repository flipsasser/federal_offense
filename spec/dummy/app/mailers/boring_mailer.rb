# frozen_string_literal: true

class BoringMailer < ApplicationMailer
  FROM = "boring@mailer.mailer"
  TO = "user@user.user"

  def html_only
    mail(subject: "HTML only plz") do |format|
      format.html { render }
    end
  end

  def no_subject
    mail(subject: "")
  end

  def plaintext
    mail(subject: "I am Texty") do |format|
      format.text { render }
    end
  end

  def user_update
    mail(subject: "This is a test subject innit")
  end

  private

  def mail(options, *args, &block)
    options[:from] ||= FROM
    options[:to] ||= TO
    super options, *args, &block
  end
end
