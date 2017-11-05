class ApplicationController < ActionController::Base
	include SessionHelper
	protect_from_forgery with: :null_session
end
