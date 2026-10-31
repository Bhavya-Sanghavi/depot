require "test_helper"

class SupportRequestMailerTest < ActionMailer::TestCase
  test "respond" do
    support_request = SupportRequest.new(
      email: "customer@example.com",
      subject: "Help with my order",
      body: "I need help with my order."
    )
    support_request.response = "Here is our response."

    mail = SupportRequestMailer.respond(support_request)

    assert_equal "Re: Help with my order", mail.subject
    assert_equal ["customer@example.com"], mail.to
    assert_equal ["support@example.com"], mail.from
    assert_match "Here is our response.", mail.body.encoded
    assert_match "I need help with my order.", mail.body.encoded
  end
end