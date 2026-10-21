# Sign up and account settings pages from Devise
module Users
  class RegistrationsController < Devise::RegistrationsController
    protected

    def after_update_path_for(resource)
      user_path(resource)
    end
  end
end
