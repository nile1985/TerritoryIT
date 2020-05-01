# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'faker'
require 'net/http'
require 'uri'

ips = []

50.times do
  ips << Faker::Internet.ip_v4_address
end

user_ids = []

100.times do
  user_ids << "#{Faker::Movies::LordOfTheRings.character} #{rand(1..10)}".gsub(/\s+/, "")
end

200_000.times do
  Api::Articles.new({
    title: 'Test Title',
    content: 'Test Content',
    login: user_ids.sample,
    user_ip: ips.sample
  }).create
end

20_000.times do
  offset = rand(Article.count)
  5.times do
    Api::ArticleRatings.new({ article_id: Article.offset(offset).first.id,
                              mark: rand(1..5)
                            }).vote
  end
end



