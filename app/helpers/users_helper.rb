module UsersHelper
	def pretty_role(role)
		case role
			when "manager"
				"Manager"
			when "rm"
				"Regional Manager"
			when "admin"
				"Ops Admin"
			else
				role.to_s.capitalize
			end
		end
end