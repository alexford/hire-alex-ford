require 'json'
require 'twilio-ruby'
require 'stripe'
require 'sinatra'

## Stripe setup
Stripe.api_key = ENV['STRIPE_KEY']
Stripe.api_version = "2014-01-31"

## landing page
get '/' do
  haml :index
end

## form submit
post '/reserve' do
  content_type :json
  @reservation = params[:reservation]
  unless @reservation
    # TODO better validation
    error(422, 'No reservation data')
  end

  # attempt to create stripe customer
  begin
    customer = Stripe::Customer.create(
      :description => "hirealexford.com consulting customer",
      :email => @reservation[:email],
      :card => @reservation[:token],
      :metadata => {
        'name' => @reservation[:name],
        'message' => @reservation[:message]
      }
    )
  rescue Stripe::StripeError
    # TODO make this error logging better
    error(500, 'StripeError')
  end

  # notify me!
  sendsms('New hirealexford.com customer: #{@reservation[:name]} (#{@reservation[:email]}). #{@reservation[:message]}')

  # return Stripe customer data to frontend  
  customer.to_json
end


#### Sandbox/testing

get '/testmessage' do
  # send a test SMS message
  unless ENV['ALLOW_TEST_ENDPOINTS'] == 1
    error(401, 'No test endpoints in this environment')
  end
  sendsms('Test message')
end

#### SMS Helper
def sendsms(message, to = ENV['TWILIO_TO_NUMBER'], from = ENV['TWILIO_FROM_NUMBER'])
  begin
    @twilio_client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    @twilio_client.account.messages.create(
      :from => from,
      :to => to,
      :body => message
    )
  rescue Twilio::REST::RequestError => e
    error(500, "TwilioError #{e.message}")
  rescue
    puts "Another error"
  end
end