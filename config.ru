# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

# for Application Insights
require 'application_insights'
use ApplicationInsights::Rack::TrackRequest, ENV['INSTRUMENTATION_KEY'], 5

run Rails.application
