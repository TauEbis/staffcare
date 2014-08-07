class PagesController < ApplicationController
  before_action :set_page, only: [:show, :edit, :update, :destroy]
  skip_after_filter :verify_policy_scoped, only: [:index]

  # GET /pages
  def index
    if params[:list]
      @pages = policy_scope(Page).order(slug: :asc).all
    else
      @page = Page.find_by(slug: "home")
      if @page
        redirect_to @page
      else
        @page = Page.create(name: "Home", slug: "home")
        redirect_to edit_page_url(@page)
      end
    end
  end

  # GET /pages/1
  def show
  end

  # GET /pages/new
  def new
    @page = Page.new
    authorize @page
  end

  # GET /pages/1/edit
  def edit
  end

  # POST /pages
  def create
    @page = Page.new(page_params)
    authorize @page

    if @page.save
      redirect_to @page, notice: 'Page was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /pages/1
  def update
    if @page.update(page_params)
      redirect_to @page, notice: 'Page was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /pages/1
  def destroy
    @page.destroy
    redirect_to pages_url, notice: 'Page was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = Page.friendly.find(params[:id])
      authorize @page
    end

    # Only allow a trusted parameter "white list" through.
    def page_params
      params.require(:page).permit(:name, :body, :slug)
    end
end
