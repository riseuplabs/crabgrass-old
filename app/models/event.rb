class Event < ActiveRecord::Base

	has_many :pages, :as => :data
	format_attribute :description

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
