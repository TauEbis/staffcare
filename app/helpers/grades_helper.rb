module GradesHelper

	def people_td_tag(content)
		warning_cutoff = 1
		danger_cutoff = 2
		if content > danger_cutoff
			notice_class = "bg-danger"
		elsif content > warning_cutoff
			notice_class = "bg-warning"
		else
			notice_class = ""
		end

		content_tag("td", "#{content}", class: notice_class)
	end

	def dollar_td_tag(content)
		warning_cutoff = 40
		danger_cutoff = 80
		if content > danger_cutoff
			notice_class = "bg-danger"
		elsif content > warning_cutoff
			notice_class = "bg-warning"
		else
			notice_class = ""
		end

		content_tag("td", "$#{content}", class: notice_class)
	end

end