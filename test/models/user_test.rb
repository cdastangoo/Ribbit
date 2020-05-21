require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobarbaz", password_confirmation: "foobarbaz")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = " "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = " "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.name = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp foo+bar@baz.foobarbaz]
    addresses.each do |addr|
      @user.email = addr
      assert @user.valid?, "#{addresses.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    addresses = %w[user@example,com user_at_foo.org user.name@example.foo@bar_baz.com foo@bar+baz.com, user@exampl.e, foo@bar..com]
    addresses.each do |addr|
      @user.email = addr
      assert_not @user.valid?, "#{addresses.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    dup = @user.dup
    @user.save
    assert_not dup.valid?
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 8
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 7
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end
end
