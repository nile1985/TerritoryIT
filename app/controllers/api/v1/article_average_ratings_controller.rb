module Api
  module V1
    class ArticleAverageRatingsController < ApplicationController

      def index
        result = Api::Services.new(params).top_articles

        result.on_failed { |errors| render json: { errors: errors }, status: 422 }
        result.on_success { |articles| render json: articles, status: 200 }
      end

    end
  end
end