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
  case n % 6
  when 1
    title = Faker::Commerce.product_name
  when 2
    title = Faker::Company.catch_phrase
  when 3
    title = Faker::Book.title
  when 4
    title = Faker::Music.album
  else
    title = Faker::Hipster.sentence(word_count: 3, supplemental: false, random_words_to_add: 2)
    title = title.tr('.', %W(#{''} . ? !)[rand(4)])
  end
  case n % 16
  when 1..6
    content = Faker::Hipster.paragraph(sentence_count: 2, supplemental: false, random_sentences_to_add: 4)
  when 7..10
    content = Faker::Hipster.sentence(word_count: 5, supplemental: false, random_words_to_add: 4)
  when 11
    content = Faker::Hacker.say_something_smart
  when 12..14
    content = Faker::TvShows::BojackHorseman.quote + "\n"
    content += Faker::TvShows::Seinfeld.quote + "\n"
    content += Faker::TvShows::HowIMetYourMother.quote + "\n"
    content += Faker::TvShows::MichaelScott.quote + "\n"
    content += Faker::TvShows::Simpsons.quote + "\n"
    content += Faker::TvShows::RickAndMorty.quote
  else
    content = Faker::ChuckNorris.fact + "\n"
    content += Faker::GreekPhilosophers.quote + "\n"
    content += Faker::Quote.yoda
  end
  users.each { |user| user.posts.create!(title: title, content: content) }
end