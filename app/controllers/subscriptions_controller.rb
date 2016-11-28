class SubscriptionsController < ApplicationController
  def subscribe
    email = params[:email]
    mailchimp = Mailchimp::API.new(ENV.fetch('MAILCHIMP_API_KEY'))

    begin
      mailchimp.lists.subscribe(ENV.fetch('MAILCHIMP_LIST_ID'),
                                {email: email})
      render json: {message: "Alright, we signed up: #{email} Thank you! We'll be in touch"}, status: 200
    rescue Mailchimp::ListAlreadySubscribedError
      render json: {message: "#{email} is already subscribed to the list"}, status: 400
    rescue Mailchimp::ListDoesNotExistError
      render json: {message: 'The list could not be found'}, status: 400
      return
    rescue Mailchimp::Error => ex
      if ex.message
        render json: {message: ex.message}, status: 400
      else
        render json: {message: 'An unknown error occurred'}, status: 400
      end
    end
  end
end
