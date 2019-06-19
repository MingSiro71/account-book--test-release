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
    if params[:id].include?("division")
      division_ids = Rack::Utils.parse_nested_query(params[:id]).map{|k,v|v}.flatten!
      division_ids.delete("")
    else
      division_ids = [params[:id]]
    end
    if division_ids.size == 0
      flash[:danger] = "集計を行う事業が選択されていません"
      redirect_to divisions_path 
    end
    @divisions=[]
    division_ids.each do |id|
      division = Division.find_by(id: id)
      @divisions << division if division
    end
    @division = Division.new
    @division.name = @divisions.size==1 ? @divisions[0].name : "マルチ集計：#{@divisions.map{|d| d.name}.join(", ")}"
    @date_a = params[:date_a] ? params[:date_a] : Time.current.beginning_of_month
    @date_z = params[:date_z] ? params[:date_z] : nil 
    @back_records = BackRecord.period(division_ids, @date_a, @date_z)
    @stats = @back_records.stats
  end

  def marge
    redirect_to(controller: 'divisions', action: 'show',
      id: params[:post][:division_ids].to_query('division'))
  end

  def edit
  end

  def update
    if @division.update_attributes(division_params_independent)
      flash[:success] = "変更を反映しました"
      redirect_to divisions_path
    else
      flash[:danger] = "変更に失敗しました"
      redirect_to edit_divisions_path
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
