class FlashMessage
  def initialize(session)
    @session ||= session
  end

  def message=(message)
    @session[:flash_message] = message
  end
  
  def error=(message)
    @session[:flash_error] = message
  end

  def any_message?
    @session[:flash_message] != nil
  end

  def any_error?
    @session[:flash_error] != nil
  end

  def error
    message = @session[:flash_error] #tmp get the value
    @session[:flash_error] = nil # unset the value
    message # display the value
  end

  def message
    message = @session[:flash_message] #tmp get the value
    @session[:flash_message] = nil # unset the value
    message # display the value
  end
end
