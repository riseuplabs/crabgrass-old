class AddJobListener < Crabgrass::Hook::ViewListener
  include Singleton

  def home_sidebar(context)
    render :partial=>'/root/job_opportunity_link'
  end

end
