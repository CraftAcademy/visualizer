class PagesController < ApplicationController
  include ReportGenerator

  before_action :get_service, only: [:analytics, :get_data]

  def index
  end

  def redirect
    client = Signet::OAuth2::Client.new({
                                            client_id: ENV.fetch('GOOGLE_API_CLIENT_ID'),
                                            client_secret: ENV.fetch('GOOGLE_API_CLIENT_SECRET'),
                                            authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
                                            scope: Google::Apis::AnalyticsV3::AUTH_ANALYTICS_READONLY,
                                            redirect_uri: url_for(action: :callback)
                                        })
    redirect_to client.authorization_uri.to_s
  end

  def callback
    client = Signet::OAuth2::Client.new({
                                            client_id: ENV.fetch('GOOGLE_API_CLIENT_ID'),
                                            client_secret: ENV.fetch('GOOGLE_API_CLIENT_SECRET'),
                                            token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
                                            redirect_uri: url_for(action: :callback),
                                            code: params[:code]
                                        })
    response = client.fetch_access_token!
    session[:access_token] = response['access_token']
    redirect_to url_for(action: :analytics)
  end

  def analytics
    @account_summaries = @service.list_account_summaries
  end

  def get_data
    @property = @service.get_web_property(params[:account_id],
                                   params[:web_property_id])

    @image = ReportGenerator.generate(@service, params, @property)
    render :analytics
  end


  private
  def get_service
    @service = Google::Apis::AnalyticsV3::AnalyticsService.new
    @service.authorization = session[:access_token]
  end
end
