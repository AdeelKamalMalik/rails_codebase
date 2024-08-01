require "application_system_test_case"

class BlogsTest < ApplicationSystemTestCase
  setup do
    @blog = blogs(:one)
  end

  test "visiting the index" do
    visit blogs_url
    assert_selector "h1", text: "Blogs"
  end

  test "creating a Blog" do
    visit blogs_url
    click_on "New Blog"

    fill_in "Content", with: @blog.content
    fill_in "Title", with: @blog.title
    fill_in "User", with: @blog.user_id
    click_on "Create Blog"

    assert_text "Blog was successfully created"
    assert_selector "h1", text: "Blogs"
  end

  test "updating a Blog" do
    visit blog_url(@blog)
    click_on "Edit", match: :first

    fill_in "Content", with: @blog.content
    fill_in "Title", with: @blog.title
    fill_in "User", with: @blog.user_id
    click_on "Update Blog"

    assert_text "Blog was successfully updated"
    assert_selector "h1", text: "Blogs"
  end

  test "destroying a Blog" do
    visit edit_blog_url(@blog)
    click_on "Delete", match: :first
    click_on "Confirm"

    assert_text "Blog was successfully destroyed"
  end
end
