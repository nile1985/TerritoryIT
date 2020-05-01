require 'spec_helper'

RSpec.describe Api::V1::ArticleRatingsController, type: :controller do

  MARKS = [5, 4, 2, 4, 3, 4].freeze

  before :each do
    setup_data
  end

  describe 'create method' do
    describe 'with errors' do

      it "Article doesn't exist" do
        post(:create, params: { article_id: Article.last.id + 1, mark: 5 })
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['errors'].include?(Api::Validator::ARTICLE_NOT_EXIST)).to be_truthy
        expect(response.status).to eq(422)
      end

      it 'Bad article id' do
        post(:create, params: { article_id: 'test', mark: 5 })
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['errors'].include?(Api::Validator::ARTICLE_NOT_EXIST)).to be_truthy
        expect(response.status).to eq(422)
      end

      it 'Mark is missed' do
        post(:create, params: { article_id: 'test' })
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['errors'].include?(Api::Validator::MARK_REQUIRED)).to be_truthy
        expect(response.status).to eq(422)
      end

      it 'Article Id is missed' do
        post(:create, params: { mark: 5 })
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['errors'].include?(Api::Validator::ARTICLE_ID_REQUIRED)).to be_truthy
        expect(response.status).to eq(422)
      end

      it 'Bad mark' do
        post(:create, params: { article_id: Article.last.id, mark: 6 })
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['errors'].include?(Api::Validator::BAD_MARK)).to be_truthy
        expect(response.status).to eq(422)
      end

      it 'Invalid mark' do
        post(:create, params: { article_id: Article.last.id, mark: 'test' })
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['errors'].include?(Api::Validator::BAD_MARK)).to be_truthy
        expect(response.status).to eq(422)
      end

    end

    describe 'with success' do

      it 'Single vote' do
        article = Article.first

        voting(article.id, 3)
        parsed_response = JSON.parse(response.body)

        expect(parsed_response).to eq(3.0)
        expect(response.status).to eq(200)
      end

      it 'Multiply voting' do
        article = Article.first

        MARKS.each do |mark|
          voting(article.id, mark)
        end

        av_value = (MARKS.inject { |sum, el| sum + el }.to_f / MARKS.size).round(2)

        article.reload

        expect(article.rate).to eq(av_value)
      end
    end

  end

  private

  def setup_data
    User.create!(user_login: 'User1')

    Article.create!(
      title: 'Test title',
      content: 'Test content',
      user_login: 'User1',
      user_ip: '127.0.0.1'
    )
  end

  def voting(article_id, mark)
    post(:create, params: { article_id: article_id, mark: mark })
  end

end