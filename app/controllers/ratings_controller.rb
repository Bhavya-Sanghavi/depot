class RatingsController < ApplicationController
  def create
    @rating = current_user.ratings.find_or_initialize_by(product_id: params[:product_id])

    @rating.score = rating_params[:score]

    if @rating.save
      average = @rating.product.ratings.average(:score)

      render json: {
        success: true,
        message: 'Rating submitted successfully',
        rating: @rating.score,
        average_rating: average&.to_f.round(1)
      }
    else
      render json: {
        success: false,
        errors: @rating.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:score)
  end
end
