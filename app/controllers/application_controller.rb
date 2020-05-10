class ApplicationController < ActionController::Base

  def hello
    render html: "Ribbit"
  end
end
