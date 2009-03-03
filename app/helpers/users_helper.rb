module UsersHelper
  def show_not_active_users(user)
      render :partial => "/users/not_active_users", :object => user
  end
end
