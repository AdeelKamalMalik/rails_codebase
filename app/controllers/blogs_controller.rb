class BlogsController < ApplicationController
  before_action :set_blog, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @blogs = pagy(Blog.sort_by_params(params[:sort], sort_direction))
  end

  def show
  end

  def new
    @blog = Blog.new
  end

  def edit
  end

  def create
    @blog = Blog.new(blog_params)

    respond_to do |format|
      if @blog.save
        format.html { redirect_to @blog, notice: "Blog was successfully created." }
        format.json { render :show, status: :created, location: @blog }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @blog.update(blog_params)
        format.html { redirect_to @blog, notice: "Blog was successfully updated." }
        format.json { render :show, status: :ok, location: @blog }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @blog.destroy!
    respond_to do |format|
      format.html { redirect_to blogs_url, status: :see_other, notice: "Blog was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to blogs_path
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :user_id)
  end
end
