# create main sample user
User.create!(name: "AdminUser",
             email: "example@email.com",
             password: "password",
             password_confirmation: "password",
             activated: true,
             activated_at: Time.zone.now)

# generate many additional users
99.times do |n|
  name = n % 2 == 0 ? Faker::FunnyName.name : Faker::Name.name
  name.downcase! unless rand(3) == 1
  name = name.tr('.\'', '').tr(' ', %W(#{''} _ -)[n % 3])
  email = "example#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end

# generate posts for a subset of users
users = User.order(:created_at).take(6)
64.times do |n|
  idx = n % 8
  # generate title
  case idx
  when 1,4
    title = Faker::Commerce.product_name
  when 2,5
    title = Faker::Company.catch_phrase
  when 3
    title = Faker::Book.title
  when 6
    title = Faker::Music.album
  else
    title = Faker::Hipster.sentence(word_count: 3, supplemental: false, random_words_to_add: 2)
    title = title.tr('&\'', '').tr('.', %W(#{''} . ? ! ?! !?)[rand(6)])
    title = title.tr('-', '') if rand(2) == 1
  end
  title.downcase! if rand(4) == 1
  title = punctuate(title) if idx.between?(2, 4) && rand(4) == 1
  # generate content
  case idx
  when 1
    content = punctuate(Faker::TvShows::BojackHorseman.quote) + "\n"
    content += punctuate(Faker::TvShows::FamilyGuy.quote) + "\n"
    content += punctuate(Faker::TvShows::SouthPark.quote) + "\n"
    content += punctuate(Faker::TvShows::RickAndMorty.quote)
  when 2
    content = Faker::ChuckNorris.fact
    content += Faker::Hacker.say_something_smart
  when 3
    content = punctuate(Faker::Movies::HarryPotter.quote) + "\n"
    content += punctuate(Faker::TvShows::GameOfThrones.quote) + "\n"
    content += punctuate(Faker::Movies::LordOfTheRings.quote) + "\n"
    content += punctuate(Faker::Movies::Hobbit.quote)
  when 4
    content = Faker::GreekPhilosophers.quote
  when 5
    content += punctuate(Faker::Movies::Ghostbusters.quote) + "\n"
    content += punctuate(Faker::Movies::BackToTheFuture.quote) + "\n"
    content += punctuate(Faker::Movies::Lebowski.quote)
  when 6
    content = punctuate(Faker::Quote.yoda) + "\n"
    content += punctuate(Faker::Movies::StarWars.quote)
  when 7
    content = punctuate(Faker::TvShows::Friends.quote) + "\n"
    content += punctuate(Faker::TvShows::HowIMetYourMother.quote) + "\n"
    content += punctuate(Faker::TvShows::Community.quotes)
  else
    content += Faker::TvShows::MichaelScott.quote
  end
  users.each { |user| user.posts.create!(title: title, content: content) }
end

# add punctuation or replace if ending in period
def punctuate(str)
  return str if %w(! ?).include? str[-1]
  str = str[0..-2] if str[-1] == '.'
  str + %w(. ! . ? . ?! . !?)[rand(8)]
end