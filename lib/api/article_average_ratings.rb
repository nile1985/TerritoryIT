module Api
  class ArticleAverageRatings

    attr_reader :errors, :number

    def initialize(number)
      @number = number
      @errors = []
    end

    def get_list
      log_errors do
        Api::Validator.validate_number(number, errors)

        return self if errors.any?

        query = ActiveRecord::Base.sanitize_sql(['SELECT title, content FROM Articles order by rate DESC limit ?', number])
        @articles = ActiveRecord::Base.connection.exec_query(query)

        # can be used this code but it is a little slower on my system
        # also using method below we can avoid from id:null values for each record
        #
        # @articles = Article.select('title, content').order('rate DESC').limit(number)
      end

      self
    end

    def on_success
      yield @articles if errors.empty? && block_given?
    end

    def on_failed
      yield errors if errors.present? && block_given?
    end

    private

    def log_errors
      yield

    rescue => e
      errors << "System error during search of top articles. Exception Class: #{e.class.name}.
                Exception Message: #{e.message}."
    end

  end
end