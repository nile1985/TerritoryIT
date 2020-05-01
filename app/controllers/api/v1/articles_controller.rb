module Api
  module V1
    class ArticlesController < ApplicationController

      def create
        result = Api::Services.new(params).create_article

        result.on_failed { |errors| render json: { errors: errors }, status: 422 }
        result.on_success { |article| render json: article, status: 200 }
      end

      def index
        result = Api::Services.new(params).ips_users_list

        render json: result, status: 200
      end

    end
  end
end