class CodesController < ActionController::Base

  helper PageHelper

  # jump to the location of the code.
  def jump
    code = Code.find_by_code(params[:id])
    if code.nil?
      render :template => 'codes/not_found'
    elsif code.page
      redirect_to self.class.helpers.page_url(code.page)
    else
      render :template => 'codes/not_found'
    end
  end

end

