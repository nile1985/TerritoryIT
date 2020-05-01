module Api
  class Articles

    attr_reader :errors, :params

    def initialize(params)
      @params = params
      @errors = []
    end

    def create
      log_errors do
        Api::Validator.validate_article(params, errors)

        return self if errors.any?

        user = find_or_create(@params[:login])

        # can be used this code but it 2 times slower on my system
        # also using method below we can transform user_ip using host()
        #
        # @article = Article.new(
        #   title: @params[:title],
        #   content: @params[:content],
        #   user_login: user.user_login,
        #   user_ip: @params[:user_ip]
        # )
        # @article.save!

        query = ActiveRecord::Base.sanitize_sql(['INSERT into Articles(user_login, title, content, user_ip) VALUES
          (?, ?, ?, ?) RETURNING id, user_login, title, content, host(user_ip) as user_ip',
          user.user_login, @params[:title], @params[:content], @params[:user_ip]])

        @article = ActiveRecord::Base.connection.exec_query(query)[0]
      end

      self
    end

    def on_success
      yield @article if errors.empty? && block_given?
    end

    def on_failed
      yield errors if errors.present? && block_given?
    end

    private

    def find_or_create(login)
      User.where(user_login: login).first || User.create(user_login: login)
    end

    def log_errors
      yield

    rescue => e
      errors << "System error during creating article. Exception Class: #{e.class.name}.
                Exception Message: #{e.message}."
    end

  end
end