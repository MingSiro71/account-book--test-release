class DivisionsController < ApplicationController
  before_action :get_division, only: [:edit, :update]
  before_action :validate_owner, only: [:edit, :update]
  def index
    if current_user
      @divisions = @current_user.divisions.order("name")
    else
      flash[:danger] = "ログイン時のみ有効なulrです"
      redirect_to root_url
    end
  end

  def new
  end

  def edit
  end

  def update
    if @division.update_attributes(division_params)
      flash[:succsess] = "変更を反映しました"
      redirect_to divisions_path
    else
      render 'edit'
    end
  end

 private

  def division_params
    params.require(:division).permit(:name)
  end

  def get_division
    @division = Division.find_by(id: params[:id])
  end

  def validate_owner
    unless logged_in_as_owner?(@division)
      redirect_to root_url 
    end
  end

end
