module Api
  module V1
    class ArticleRatingsController < ApplicationController

      def create
        result = Api::Services.new(params).vote

        result.on_failed { |errors| render json: { errors: errors }, status: 422 }
        result.on_success { |rate| render json: rate, status: 200 }
      end

    end
  end
end