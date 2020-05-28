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
  name.downcase! unless rand(3) == 0
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