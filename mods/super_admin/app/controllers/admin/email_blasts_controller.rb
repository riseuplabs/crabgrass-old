class Admin::EmailBlastsController < Admin::BaseController
  verify :method => :post, :only => [:blast]
  
  def index  
  end
  
  def blast
    email_options = mailer_options.merge({:subject => params[:subject], :body => params[:body]})
    build_recipient_list(params[:to]).each do |user|
      AdminMailer.deliver_blast(user,email_options)    
    end
    redirect_to :action => 'index'
  end
  
  protected
  
  before_filter :set_active
  
  def set_active
    @active = 'email_blasts'
  end
  
  def build_recipient_list(receipients)
    recipient_list = [ ]
    tokens = receipients.split(/[,;\s]+/)
    
    tokens.each do |unformatted_token|            
      token = unformatted_token.strip                                  
      # Check if we have a special word e.g. Everyone    
      if (check_token_category(token,"<") == 0)                
        if (token.downcase == '<everyone>') then
          User.find(:all) .each do |user|
              recipient_list << user
          end    
        end    
      else         
        # Check if we have a group token            
        group = Group.find_by_name(token.sub(/@/,''))
        if(!group.nil?) then
          group.users.each do |user|
            recipient_list << user
          end                
        else
          user = User.find_by_login(token)
          if(!user.nil?) then
            recipient_list << user
          end
        end        
      end
    end
    return recipient_list;
  end    

  def check_token_category(token_string, special)
    token_string =~ /#{special}/
  end    
end

