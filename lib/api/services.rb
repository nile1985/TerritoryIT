module Api
  class Services

    def initialize(params)
      @params = params
    end

    def create_article
      Api::Articles.new(@params).create
    end

    def vote
      Api::ArticleRatings.new(@params).vote
    end

    def ips_users_list
      Api::Helper.ips_users_list
    end

    def top_articles
      Api::ArticleAverageRatings.new(@params[:number]).get_list
    end

  end
end