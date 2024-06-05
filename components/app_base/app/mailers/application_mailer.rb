# frozen_string_literal: true

# Base class for all Mailer classes
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
