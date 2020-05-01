module Api
  class ArticleRatings

    attr_reader :params, :errors

    def initialize(params)
      @params = params
      @errors = []
    end

    def vote
      log_errors do
        Api::Validator.validate_voting(params, errors)

        return self if errors.any?

        ArticleRating.create(article_id: params[:article_id], mark: params[:mark])
        @av_rate = calc_average_rating(params[:article_id], params[:mark].to_i)
      end

      self
    end

    def on_success
      yield @av_rate if errors.empty? && block_given?
    end

    def on_failed
      yield errors if errors.present? && block_given?
    end

    private

    def log_errors
      yield

    rescue => e
      errors << "System error during voting. Exception Class: #{e.class.name}.
                Exception Message: #{e.message}."
    end

    def calc_average_rating(article_id, mark)
      query = ActiveRecord::Base.sanitize_sql(['update articles set rate = (rate * votes + ?) / (votes + 1), votes = votes + 1 where id = ? returning rate',
                                               mark, article_id])
      ActiveRecord::Base.connection.exec_query(query)[0]['rate']
    end

  end
end