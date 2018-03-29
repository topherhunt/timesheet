class ActionController::TestCase
  include Devise::Test::ControllerHelpers

  def create_signed_in_user(attrs = {})
    user = create :user, attrs
    sign_in user
    user
  end

  def assert_content(text_or_html)
    if response.body.include?(text_or_html)
      assert true
    else
      assert false, "Expected response to include text, but it wasn't found.\n" +
        _response_comparison(text_or_html)
    end
  end

  def assert_no_content(text_or_html)
    if response.body.include?(text_or_html)
      assert false, "Expected response NOT to include text, but it was found.\n" +
        _response_comparison(text_or_html)
    else
      assert true
    end
  end

  private

  def _response_comparison(text_or_html)
    "The expected text:\n"\
    "  \"#{text_or_html}\"\n"\
    "The full response body:\n"\
    "  #{response.body.gsub("\n", "")}"
  end
end
