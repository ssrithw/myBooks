class RecommendationsController < ApplicationController
  before_action :authenticate_user!

  # GET /recommendations
  # define variables to be used in the recommendations service
  def index
    recommender   = BookRecommender.new(current_user, limit: 24)
    @picks        = recommender.call
    @personalised = recommender.personalised?
  end
end
