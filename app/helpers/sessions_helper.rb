module SessionsHelper

  # logs in given user
  def log_in(user)
    session[:user_id] = user.id
  end

  # remember user in persistent session
  def remember(user)
    user.remember
    #cookies.permanent.encrypted[:user_id] = user.id
    #cookies.permanent[:remember_token] = user.remember_token
    expiration_date = 1.year.from_now.utc
    cookies.encrypted[:user_id] = { value: user.id,
                                    expires: expiration_date }
    cookies[:remember_token] = { value: user.remember_token,
                                 expires: expiration_date }
  end

  # returns current logged-in user
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # returns true if given user is current user
  def current_user?(user)
    user && user == current_user
  end

  # is user logged in
  def logged_in?
    !current_user.nil?
  end

  # forget persistent session
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # logs out current user
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # redirect to stored location (or to default)
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # stores URL accessed
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
