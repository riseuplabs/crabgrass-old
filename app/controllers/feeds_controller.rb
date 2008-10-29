class FeedsController < ApplicationController
  session :off
  layout false

  # this is a slightly unidiomatic way of doing some initialization at class-load time
  TYPE_MAPPINGS = {
    "assets" => Asset
  }
  
  begin
    TYPE_MAPPINGS["ext_videos"] = ExternalVideo
  rescue NameError
  end
  
  TYPE_MAPPINGS.freeze
  
  def index
    @type = TYPE_MAPPINGS[params[:type]]
    unless @type
      raise ErrorMessage.new("Invalid type #{params[:type]} specified")
    end
    
    if params[:group]
      @group = Group.get_by_name(params[:group])
      # treat invisible and nonexistent groups the same
      unless @group && @group.publicly_visible_group
        raise ErrorMessage.new("Invalid group #{params[:group]} specified")
      end
    end
    
    scope = @group ? @type.visible_to(@group, :public) : @type.visible_to(:public)

    case @type.to_s
    when "Asset"
      @mediatype = params[:media].to_sym if params[:media]
      @mediatype = :all unless [:image,:audio,:video,:document].include?(@mediatype)
      @type_text = "media_#{@mediatype}s"
      scope = scope.media_type(@mediatype) unless @mediatype == :all
    when "ExternalVideo"
      @type_text = :media_videos
    end

    @objects = scope.most_recent.find(:all, :limit => 20)
    
    respond_to do |format|
      format.rss
    end
  end
end
