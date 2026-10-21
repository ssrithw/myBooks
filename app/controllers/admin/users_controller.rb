module Admin
  class UsersController < BaseController
    before_action :set_user
    before_action :forbid_self # block permissions

    # PATCH /admin/users/1 
    # This is used to either grant admin permissions or take them away.
    def update
      @user.update!(is_admin: !@user.is_admin?)
      redirect_to admin_root_path, notice: "#{@user.username} is now #{@user.admin? ? 'an admin' : 'a standard user'}.", status: :see_other
    end

    # DELETE /admin/users/1
    def destroy
      @user.destroy!
      redirect_to admin_root_path, notice: "#{@user.username} was deleted.", status: :see_other
    end

    private

    def set_user
      @user = User.find_by!(username: params.expect(:id))
    end

    # Method to stop admins from accidentally breaking their own access
    def forbid_self
      redirect_to admin_root_path, alert: "You can't change your own account here.", status: :see_other if @user == current_user
    end
  end
end
