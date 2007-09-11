class Event < ActiveRecord::Base

	has_many :pages, :as => :data
	format_attribute :description
	
	validates_presence_of :location
#	validates_presence_of :starts_at
#	validates_presence_of :ends_at

	def page
	    pages.first || parent_page
	end

	def page=(p)
	    @page = p
	end

	protected

	def default_group_name
		if page and page.group_name
			page.group_name
		else
			'page'
		end
	end
end
