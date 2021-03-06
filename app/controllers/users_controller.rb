class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy]


  def index
    @users = User.all.order "LOWER(name)"
  end

  def show
    @dances = @user.dances.readable_by(current_user).alphabetical
    @programs = @user.programs
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email,:name)
  end
end

