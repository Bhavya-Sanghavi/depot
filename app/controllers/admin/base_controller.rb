module Admin
  class BaseController < ApplicationController
    before_action :authorize_admin

    private

    def authorize_admin
      unless current_user&.role == 'admin'
        redirect_to store_index_path, notice: t('flash.no_privilege')
      end
    end
  end
end
