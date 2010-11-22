module ApplicationHelper
  include AddOrNil
  
  def redirect_from_session_or(*args)
    if session.has_key?( :redirect_to )
      redirect = session[:redirect_to]
      session[:redirect_to] = nil
      redirect_to redirect
    else
      redirect_to(*args) unless session.has_key?( :redirect)
    end
  end
end
