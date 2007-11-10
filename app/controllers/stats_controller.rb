class StatsController < ApplicationController
  def index
    if defined?(ANALYZABLE_PRODUCTION_LOG) && File.file?(ANALYZABLE_PRODUCTION_LOG)
      render :text => '<pre>' + `pl_analyze #{ANALYZABLE_PRODUCTION_LOG}` + '</pre>'
    else
      render :text => 'no analyzable production log'
    end
  end
end
