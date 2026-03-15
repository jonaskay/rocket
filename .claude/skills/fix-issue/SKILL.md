---
name: fix-issue
description: Implements a fix for an issue
---

Fix issue.

Example controller:

```ruby
class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  def index
    @products = Product.all
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to @product
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to @product
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.expect(product: [ :name ])
    end
end
```

Every system test is expensive. Generate a system test case only for the described system test cases (`test/system`). Example system test case:

```ruby
require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "should create Article" do
    visit articles_path

    click_on "New Article"

    fill_in "Title", with: "Creating an Article"
    fill_in "Body", with: "Created this article successfully!"

    click_on "Create Article"

    assert_text "Creating an Article"
  end
end
```

Generate integration tests for the described integration test cases (`test/integration`). Example integration test case:

```ruby
require "test_helper"

class ArticleFlowsTest < ActionDispatch::IntegrationTest
  test "can create an article" do
    get "/articles/new"
    assert_response :success

    post "/articles",
      params: { article: { title: "can create", body: "article successfully." } }
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_dom "p", "Title:\n  can create"
  end
end
```
