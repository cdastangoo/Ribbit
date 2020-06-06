require 'test_helper'

class PostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:testuser)
  end

  test "post interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    # invalid title and content
    assert_no_difference 'Post.count' do
      post posts_path, params: { post: { title: "", content: "" } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'
    # valid title, invalid content
    title = "Lebowski reference"
    assert_no_difference 'Post.count' do
      post posts_path, params: { post: { title: title, content: "" } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'
    # valid content, invalid title
    content = "This post really ties the room together"
    assert_no_difference 'Post.count' do
      post posts_path, params: { post: { title: "", content: content } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'
    # valid submission
    assert_difference 'Post.count', 1 do
      post posts_path, params: { post: { title: title, content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match title, response.body
    assert_match content, response.body
    # delete post
    assert_select 'a', text: 'delete post'
    first_post = @user.posts.paginate(page: 1).first
    assert_difference 'Post.count', -1 do
      delete post_path(first_post)
    end
    # visit different user, no delete links
    get user_path(users(:altuser))
    assert_select 'a', text: 'delete post', count: 0
  end

  test "post sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "36 posts", response.body.downcase
    # user with no posts
    other_user = users(:noposts)
    log_in_as(other_user)
    get root_path
    assert_match "0 posts", response.body.downcase
    other_user.posts.create!(title: "A post", content: "Some text")
    get root_path
    assert_match "A post", response.body
    assert_match "Some text", response.body
    assert_match "1 post", response.body.downcase
  end
end
