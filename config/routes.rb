Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace 'api' do
    namespace 'v1' do
      resources :articles, only: %i[index create]
      resources :article_ratings, only: :create
      resources :article_average_ratings, only: :index
    end
  end

end
