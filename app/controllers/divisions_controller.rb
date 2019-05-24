class DivisionsController < ApplicationController
  before_action :get_division, only: [:edit, :update]
  before_action :validate_owner, only: [:edit, :update]
  def index
    if session[:user_id]
      @divisions = Division.where(user_id: session[:user_id]).order("name")
      @user_id = session[:user_id]
    else
      flash[:danger] = "ログイン時のみ有効なulrです"
      redirect_to root_url
    end
  end

  def create
    division = Division.new(division_params_independent)
    if division.save
      flash[:success] = "新しい事業を登録しました"
      redirect_to divisions_path
    else
      flash[:danger] = "登録に失敗しました"
      redirect_to divisions_path
    end
  end

  def show
    @date_a = params[:date_a] if params[:date_a]
    @date_a ||= Time.current.beginning_of_month
    @date_z = params[:date_z] if params[:date_z] 
    @division = Division.find_by(id: params[:id])
    #@stats = BackRecord.stats(@division.id, date_a, date_z)
    # hard code
    @stats = {}
    @stats[:debits] = {}
    @stats[:credits] = {}
    @stats[:results] = {}
    @stats[:factors] = {}
    @stats[:debits][:transportation] = {title: "交通費", value: 34490}
    @stats[:credits][:sales] = {title: "売上", value: 320120}
    @stats[:results][:pl] = {title: "利益収支", value: 70000}
    @stats[:results][:cache] = {title: "キャッシュ収支", value: -20400}
    @stats[:factors][:receivable] = {title: "未回収債権", value: -90400}
    if @data_z
      @back_records = BackRecord.where(division_id: params[:id]).where(when: @date_a..@date_z)
    else
      @back_records = BackRecord.where(division_id: params[:id]).where(when: @date_a..@date_a.end_of_month)
# @back_records = BackRecord.where(division_id: params[:id])
    end
  end

  def edit
  end

  def update
    if @division.update_attributes(division_params_independent)
      flash[:success] = "変更を反映しました"
      redirect_to divisions_path
    else
      render 'edit'
    end
  end

 private

  def division_params_relational
    params.require(:division).permit(:name)
  end

  def division_params_independent
    params.require(:division).permit(:user_id, :name)
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
