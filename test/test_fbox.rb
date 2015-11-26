require 'minitest_helper'

class TestFbox < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Fbox::VERSION
  end

  def test_getting_currencies
    api_key = '4VdBEIAQKPpZ4SWOhQLUMn7mMNVql' # FBox example API key
    fbox = Fbox::Client.new({:api_key => api_key})
    currencies = fbox.currencies()
    assert !currencies.nil?
    assert !currencies.empty?
    assert currencies["status"] == 200, "FaucetBox API returned an error: #{currencies['status']}: #{currencies['message']}"
    assert !currencies["currencies"].empty?
    assert currencies["currencies"].length > 1 # At least it should have BTC
  end

  def test_getting_balance
    api_key = '4VdBEIAQKPpZ4SWOhQLUMn7mMNVql' # FBox example API key, put your API key here
    fbox = Fbox::Client.new({:api_key => api_key})
    balance = fbox.balance('BTC')
    assert !balance.nil?
    assert !balance.empty?
    if api_key != '4VdBEIAQKPpZ4SWOhQLUMn7mMNVql'
      assert balance["status"] == 200, "FaucetBox API returned an error: #{balance['status']}: #{balance['message']}"
      assert !balance["balance"].nil?
      assert !balance["balance_bitcoin"].nil?
    else
      # Unfortunately at this moment API key used in examples on FaucetBox site
      # gives 403 status, so you have tou use your own
      assert balance["status"] == 403
    end
  end

  ##
  ## This test is commented becouse there are timeouts when calling this API method
  ##
  # def test_getting_payouts
  #   api_key = '4VdBEIAQKPpZ4SWOhQLUMn7mMNVql' # FBox example API key
  #   fbox = Fbox::Client.new({:api_key => api_key})
  #   payouts = fbox.payouts(5, 'BTC')
  #   assert !payouts.nil?
  #   assert !payouts.empty?
  #   assert payouts["status"] == 200, "FaucetBox API returned an error: #{payouts['status']}: #{payouts['message']}"
  # end
  
  # def test_sending_payment
  #   api_key = '' # Put here your API key
  #   fbox = Fbox::Client.new({:api_key => api_key})
  #   payment = fbox.payment('... put here your bitcoin address ...', 10, false)
  #   assert !payment.nil?
  #   assert !payment.empty?
  #   assert payment["status"] == 200, "FaucetBox API returned an error: #{payment['status']}: #{payment['message']}"
  #   assert !payment["balance"].nil?
  #   assert !payment["balance_bitcoin"].nil?
  # end
end
