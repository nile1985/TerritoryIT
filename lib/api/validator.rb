require 'resolv'

module Api
  class Validator

    TITLE_REQUIRED = 'Title is required.'.freeze
    CONTENT_REQUIRED = 'Content is required.'.freeze
    USER_LOGIN_REQUIRED = 'User Login is required.'.freeze
    INVALID_IP = 'Invalid IP address.'.freeze

    ARTICLE_NOT_EXIST = 'Article does not exist.'.freeze
    BAD_MARK = 'Mark must be a number from 1 to 5.'.freeze
    MARK_REQUIRED = 'Mark is required.'.freeze
    ARTICLE_ID_REQUIRED = 'Article ID is required.'.freeze
    VOTES_ALLOWED = Array(1..5)

    BAD_NUMBER = 'Invalid number.'.freeze

    class << self

      def validate_article(params, errors)
        errors << TITLE_REQUIRED unless params[:title].present?
        errors << CONTENT_REQUIRED unless params[:content].present?
        errors << USER_LOGIN_REQUIRED unless params[:login].present?
        errors << INVALID_IP unless valid_ip_address?(params[:user_ip])
      end

      def validate_voting(params, errors)
        unless params[:mark].present?
          errors << MARK_REQUIRED
          return
        end

        errors << BAD_MARK if !a_positive_number?(params[:mark]) || !VOTES_ALLOWED.include?(params[:mark].to_i)
        # avoid an additional request to DB
        return errors if errors.any?

        unless params[:article_id].present?
          errors << ARTICLE_ID_REQUIRED
          return
        end

        errors << ARTICLE_NOT_EXIST unless article_exist?(params[:article_id])
      end

      def validate_number(value, errors)
        errors << BAD_NUMBER unless a_positive_number?(value)
      end

      private

      def valid_ip_address?(ip)
        !!(ip =~ Regexp.union([Resolv::IPv4::Regex, Resolv::IPv6::Regex]))
      end

      def article_exist?(id)
        Article.find_by(id: id)
      end

      def a_positive_number?(value)
        value.match?(/^\d+$/) && value.to_i.positive?
      end

    end
  end
end