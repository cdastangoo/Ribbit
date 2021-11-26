# add punctuation or replace if ending in period
def punctuate(str)
  return str if %w(! ?).include? str[-1]
  str = str[0..-2] if str[-1] == '.'
  str + %w(. ! . ? . ?! . !?)[rand(8)]
end

# make a fake post title
def generate_title(n)
  case n
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
  title = title.downcase if rand(4) == 1
  title = punctuate(title) if n.between?(2, 4) && rand(4) == 1
  title
end

# make fake post content
def generate_content(n)
  case n
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
    content = punctuate(Faker::Movies::Ghostbusters.quote) + "\n"
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
    content = Faker::TvShows::MichaelScott.quote
  end
  content
end

# create admin user
User.create!(name: "AdminUser",
             email: "example@email.com",
             password: "blue420sky69",
             password_confirmation: "blue420sky69",
             activated: true,
             activated_at: Time.zone.now)

# create main users
names = %w(first ribbit-user batman123 john-cena DarthVader therealkanyewest boonk42 Zoltar xXx_progamer_xXx)
idx = 1
names.each do |name|
  User.create!(name: name,
               email: "example#{idx}@email.com",
               password: "password",
               password_confirmation: "password",
               activated: true,
               activated_at: Time.zone.now)
  idx += 1
end

# generate many additional users
90.times do |n|
  name = n % 2 == 0 ? Faker::FunnyName.name : Faker::Name.name
  name.downcase! unless rand(3) == 1
  name = name.tr('.\'', '').tr(' ', %W(#{''} _ -)[n % 3])
  User.create!(name: name,
               email: "example#{n+10}@email.com",
               password: "password",
               password_confirmation: "password",
               activated: true,
               activated_at: Time.zone.now)
end

# generate posts for admin user
user = User.first
64.times do |n|
  title = generate_title(n % 8)
  content = generate_content(n % 8)
  user.posts.create!(title: title, content: content)
end

# generate posts for main users
users = User.first(10).drop(1)
16.times do |n|
  users.shuffle.each do |user|
    title = generate_title(n % 8)
    content = generate_content(n % 8)
    user.posts.create!(title: title, content: content)
  end
end

# generate posts for all users
users = User.first(10).drop(1) + User.last(90).take(6)
16.times do |n|
  users.shuffle.each do |user|
    title = generate_title(n % 8)
    content = generate_content(n % 8)
    user.posts.create!(title: title, content: content)
  end
end

# users.each do |user|
#   num = rand(3) == 2 ? 16 : 8
#   num.times do |n|
#     title = generate_title(n % 8)
#     content = generate_content(n % 8)
#     user.posts.create!(title: title, content: content)
#   end
# end


# users = User.first(10)
# users.each do |user|
#   32.times do |n|
#     title = generate_title(n % 8)
#     content = generate_content(n % 8)
#     user.posts.create!(title: title, content: content)
#   end
# end

# create follow relationships for main users
users = User.first(10)
users.each do |follower|
  (users - [follower]).each do |followed|
    follower.follow(followed)
  end
end

# create follow relationships for rest of users
users = User.last(90)
user = User.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }