module Admin
  class ReportsController < BaseController
    def index
      def index
        if params[:from].present? && params[:to].present?
          @orders = Order.by_date(Date.parse(params[:from]), Date.parse(params[:to]))
        else
          @orders = Order.by_date(5.days.ago.to_date, Date.current)
        end
      end
    end
  end
end
