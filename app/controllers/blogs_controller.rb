# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]
  before_action :can_not_control_other_people_blogs, only: %i[edit update destroy]
  before_action :no_access_other_people_secret_blogs, only: %i[show]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end

  def can_not_control_other_people_blogs
    not_found_record if blog_author_not_current_user?
  end

  def no_access_other_people_secret_blogs
    not_found_record if secret_blog_author_not_current_user?
  end

  def not_found_record
    raise ActiveRecord::RecordNotFound 
  end

  def blog_author_not_current_user?
    @blog.user != current_user
  end

  def secret_blog_author_not_current_user?
    blog_author_not_current_user? && @blog.secret
  end
end
