class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  before_action do
    headers['X-SYSTEM-PROCESS-ID'] = Process.pid.to_s
  end
end
