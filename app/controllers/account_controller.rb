class AccountController < ApplicationController

  stylesheet 'login'

  def index
    if logged_in?
      redirect_to me_url
    end
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/me', :action => 'index')
    else
      flash[:error] = "Username or password is incorrect"
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user
    send_welcome_message(current_user)
    redirect_back_or_default(:controller => '/account', :action => 'welcome')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end

  def welcome
    render :text => GreenCloth.new(WELCOME_TEXT_MARKUP).to_html, :layout => 'me'
  end
  
  protected
  def send_welcome_message(user)
    page = Page.make :private_message, :to => user, :from => user, :title => 'Welcome to crabgrass!', :body => WELCOME_TEXT_MARKUP
    page.save
  end

  # TODO: make this configurable
  
  WELCOME_TEXT_MARKUP = <<MARKUP
*Welcome*

Hi. This is a quick intro for new users. Next time you log in you will land at [your dashboard -> /me/dashboard] which will be a cold and lonely place until you join groups and make contacts.

So, the best thing to do as a new user is to create a group or join a group. To do so go to the [group directory -> /groups] and either click "create a new group" or click on the group you want to join and find the "join group" link. 

Once your request is accepted you can upload assets, create task lists, discussions, wikis, polls, and messages to communicate, collaborate, and get things done within the group. Like any new platform you will need to familiarize yourself with the work flow. To help answer question such as whats the difference between the inbox and the dashboard check out the [help pages -> /crabgrass/table-of-contents].

Development is driven by user feedback, so please [join -> /users] the user feed back group and get involved by clicking the [Get involved building Crabgrass! -> /users/get-involved] link at the bottom over every page.
MARKUP
end
