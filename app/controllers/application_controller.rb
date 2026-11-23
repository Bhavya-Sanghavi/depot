class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  before_action :authorize
  before_action :set_i18n_locale_from_params
  before_action :count_page_hit
  around_action :measure_execution_time
  before_action :set_user_ip
  before_action :check_inactivity
  around_action :switch_locale

  private

  def current_user
    User.find_by(id: session[:user_id]) if session[:user_id]
  end

  protected

  def authorize
    unless User.find_by(id: session[:user_id])
      redirect_to login_url, notice: t('flash.please_log_in')
    end
  end

  def set_i18n_locale_from_params
    if params[:locale]
      if I18n.available_locales.map(&:to_s).include?(params[:locale])
        session[:locale] = params[:locale]
      else
        flash.now[:notice] = t('flash.translation_not_available', locale: params[:locale])
        logger.error flash.now[:notice]
      end
    end
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def count_page_hit
    @hit_count = Rails.cache.increment('page_hits', 1, expires_in: 1.year)

    unless @hit_count
      Rails.cache.write('page_hits', 1, expires_in: 1.year)
      @hit_count = 1
    end
  end

  def measure_execution_time
    start_time = Time.now

    yield

    end_time = Time.now

    duration = ((end_time - start_time) * 1000).round(2)

    response.set_header('x-responded-in', "#{duration}ms")
  end

  def set_user_ip
     @user_ip = request.remote_ip
  end

  def check_inactivity
    if session[:last_activity_at] && 5.minutes.ago > session[:last_activity_at]
      reset_session
      redirect_to login_url, notice: t('flash.logged_out_inactivity')
    else
      session[:last_activity_at] = Time.current
    end
  end

  def switch_locale(&action)
    I18n.with_locale(current_user&.language || 'en', &action)
  end
end
