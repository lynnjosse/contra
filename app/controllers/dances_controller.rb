class DancesController < ApplicationController
  before_action :set_dance, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy]
  before_action :authenticate_dance_writable!, only: [:edit, :update, :destroy]
  before_action :authenticate_dance_readable!, only: [:show]

  def index
    @dances = Dance.readable_by(current_user).alphabetical
    respond_to do |format|
      format.html
      format.json do
        render(json: DanceDatatable.new(view_context, user: current_user, figure_query: figure_query_param))
      end
    end
  end

  def show
  end

  def new
    @dance = Dance.new
    @dance.title ||= "New Dance" 
    @admin_email = Rails.application.secrets.admin_gmail_username
  end

  def edit
    @admin_email = Rails.application.secrets.admin_gmail_username
  end


  def create
    @dance = Dance.new(dance_params_with_real_choreographer intern_choreographer)
    @dance.user_id = current_user.id
    respond_to do |format|
      if @dance.save
        format.html { redirect_to @dance, notice: 'Dance was successfully created.' }
        format.json { render :show, status: :created, location: @dance }
      else
        format.html { render :new }
        format.json { render json: @dance.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @dance.update(dance_params_with_real_choreographer intern_choreographer)
        format.html { redirect_to @dance, notice: 'Dance was successfully updated.' }
        format.json { render :show, status: :ok, location: @dance }
      else
        format.html { render :edit }
        format.json { render json: @dance.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    user = @dance.user
    @dance.destroy
    respond_to do |format|
      format.json { head :no_content }
      format.html do
        coming_from_dance_view = /.*\/dances\/.+/ =~ request.referrer
        url = coming_from_dance_view ? user : request.referrer
        redirect_to url, notice: 'Dance was successfully destroyed.'
      end
    end
  end

  private
    def set_dance
      @dance = Dance.find(params[:id])
    end
    
    def authenticate_dance_writable!
      current_user&.admin? || authenticate_ownership!(@dance.user_id)
    end

    def authenticate_dance_readable!
      unless @dance.readable?(current_user)
        flash[:notice] = "this dance has not been published"
        redirect_back(fallback_location: '/dances')
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dance_params
      dirty_json = params.require(:dance).permit(:title,
                                                 :choreographer,
                                                 :choreographer_name,
                                                 :start_type,
                                                 :figures_json,
                                                 :notes,
                                                 :copy_dance_id,
                                                 :publish)
      cleaned_json = JSLibFigure.sanitize_json dirty_json[:figures_json]
      dirty_json.merge(figures_json: cleaned_json)
    end

    def figure_query_param
      # params.permit(:draw, :columns, :order, :start, :length, :search, :format, excludeMoves: [], figureQuery: [])
      params.permit!['figureQuery']
    end

    def dance_params_with_real_choreographer(c)
      dance_params.except("choreographer_name").merge("choreographer" => c)
    end

    def intern_choreographer
      Choreographer.find_or_create_by( name: dance_params["choreographer_name"] )
    end
end
