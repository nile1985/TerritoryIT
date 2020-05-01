require 'spec_helper'

RSpec.describe Api::V1::ArticlesController, type: :controller do

  describe 'create method' do
    describe 'with errors' do
      it 'Empty title, content and login' do
        parsed_response = create_article(ip: '127.0.0.1')

        expect(parsed_response['errors'].include?(Api::Validator::TITLE_REQUIRED)).to be_truthy
        expect(parsed_response['errors'].include?(Api::Validator::CONTENT_REQUIRED)).to be_truthy
        expect(parsed_response['errors'].include?(Api::Validator::USER_LOGIN_REQUIRED)).to be_truthy
        expect(response.status).to eq(422)
      end

      it 'Empty IP' do
        parsed_response = create_article(
          title: 'Test title',
          content: 'Test content',
          login: 'Test User',
          ip: ''
        )

        expect(parsed_response['errors'].include?(Api::Validator::INVALID_IP)).to be_truthy
        expect(response.status).to eq(422)
      end

      it 'Invalid IP' do
        parsed_response = create_article(
          title: 'Test title',
          content: 'Test content',
          login: 'Test User',
          ip: '127.0.0'
        )

        expect(parsed_response['errors'].include?(Api::Validator::INVALID_IP)).to be_truthy
        expect(response.status).to eq(422)
      end
    end

    describe 'with success' do
      it 'Create new User and new Article' do
        title = 'Test title'
        content = 'Test content'
        login = 'Test User'
        ip = '127.0.0.1'

        parsed_response = create_article(title: title, content: content, login: login, ip: ip)

        expect(parsed_response['errors'].nil?).to be_truthy
        expect(parsed_response['title']).to eq(title)
        expect(parsed_response['content']).to eq(content)
        expect(parsed_response['user_login']).to eq(login)
        expect(parsed_response['user_ip']).to eq(ip)
        expect(response.status).to eq(200)

        expect(User.count).to eq(1)
        expect(Article.count).to eq(1)
      end

      it 'Create several Articles from one User' do
        title = 'Test title'
        content = 'Test content'
        login = 'Test User 2'
        ip = '127.0.0.1'

        create_article(title: title, content: content, login: login, ip: ip)
        parsed_response = create_article(title: title, content: content, login: login, ip: ip)

        expect(parsed_response['errors'].nil?).to be_truthy
        expect(parsed_response['title']).to eq(title)
        expect(parsed_response['content']).to eq(content)
        expect(parsed_response['user_login']).to eq(login)
        expect(parsed_response['user_ip']).to eq(ip)
        expect(response.status).to eq(200)

        expect(User.count).to eq(1)
        expect(Article.count).to eq(2)
      end
    end
  end

  describe 'index method' do

    it 'test' do
      create_article(title: 'Test title', content: 'Test content', login: 'User1', ip: '127.0.0.1')
      create_article(title: 'Test title', content: 'Test content', login: 'User2', ip: '127.0.0.1')
      create_article(title: 'Test title', content: 'Test content', login: 'User3', ip: '127.0.0.1')
      create_article(title: 'Test title', content: 'Test content', login: 'User1', ip: '127.0.0.2')
      create_article(title: 'Test title', content: 'Test content', login: 'User4', ip: '127.0.0.2')
      create_article(title: 'Test title', content: 'Test content', login: 'User5', ip: '127.0.0.3')

      post(:index)
      parsed_response = JSON.parse(response.body)

      expect(parsed_response.size).to eq(2)
      expect(parsed_response[0]['ip']).to eq('127.0.0.1')
      expect(parsed_response[0]['users'].size).to eq(3)
      expect(parsed_response[0]['users'].include?('User1')).to be_truthy
      expect(parsed_response[0]['users'].include?('User2')).to be_truthy
      expect(parsed_response[0]['users'].include?('User3')).to be_truthy

      expect(parsed_response[1]['ip']).to eq('127.0.0.2')
      expect(parsed_response[1]['users'].size).to eq(2)
      expect(parsed_response[1]['users'].include?('User1')).to be_truthy
      expect(parsed_response[1]['users'].include?('User4')).to be_truthy
    end
  end

  private

  def create_article(title: '', content: '', login: '', ip: '')
    params = {
      title: title,
      content: content,
      login: login,
      user_ip: ip
    }

    post(:create, params: params)
    JSON.parse(response.body)
  end

end