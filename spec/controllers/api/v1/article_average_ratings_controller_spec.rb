require 'spec_helper'

RSpec.describe Api::V1::ArticleAverageRatingsController, type: :controller do

  RATES_ROW = [4.5, 4.7, 3.5, 2.5, 5.0].freeze

  before :each do
    setup_data
  end

  describe 'create method' do
    describe 'with_errors' do

      it 'N = 0' do
        post(:index, params: { number: 0 })
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['errors'].include?(Api::Validator::BAD_NUMBER)).to be_truthy
        expect(response.status).to eq(422)
      end

      it 'string as a number' do
        post(:index, params: { number: 'test' })
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['errors'].include?(Api::Validator::BAD_NUMBER)).to be_truthy
        expect(response.status).to eq(422)
      end

    end

    describe 'with success' do
      it 'N = 5' do
        post(:index, params: { number: 5 })
        parsed_response = JSON.parse(response.body)

        ordered_ratings = RATES_ROW.sort.reverse

        expect(parsed_response.size).to eq(5)
        ordered_ratings.each_with_index do |rate, index|
          expect(parsed_response[index]['title'].include?("#{rate}")).to be_truthy
        end
        expect(response.status).to eq(200)
      end

      it 'N = 2' do
        post(:index, params: { number: 2 })
        parsed_response = JSON.parse(response.body)

        ordered_ratings = RATES_ROW.sort.reverse[0..1]

        expect(parsed_response.size).to eq(2)
        ordered_ratings.each_with_index do |rate, index|
          expect(parsed_response[index]['title'].include?("#{rate}")).to be_truthy
        end
        expect(response.status).to eq(200)
      end
    end
  end

  private

  def setup_data
    User.create!(user_login: 'User1')

    RATES_ROW.each { |rate| create_article_with_votes(rate) }
  end

  def create_article_with_votes(rate)
    Article.create!(
      title: "Test title #{rate}",
      content: 'Test content',
      user_login: 'User1',
      user_ip: '127.0.0.1',
      rate: rate,
      votes: 10
    )
  end

end