class RecordsController < ApplicationController
  include SessionsHelper

  PAGENATE = 30
  def index
    if logged_in?
      @records = Record.where(user_id: session[:user_id]).where(disabled: nil).order("created_at DESC").page(params[:page]).per(PAGENATE)
    else 
      redirect_to root_url
    end
  end

  def create
    record = Record.new(record_params_independent)
    if record.store
      flash[:success] = "記帳完了しました"
      redirect_to root_url
    else
      flash[:danger] = "記帳に失敗しました"
      redirect_to root_url
    end
  end

  def edit
    @record = Record.find_by(id: params[:id])
  end

  def update
    @original_record = Record.find_by(id: params[:record][:id])
    @original_record.disabled = Time.zone.now
    @record = Record.new(record_params_independent)
    ActiveRecord::Base.transaction do
      raise unless @original_record.store
      raise unless @record.store
    end
      flash[:success] = "帳簿を訂正しました"
      redirect_to records_path      
    rescue
      flash[:danger] = "帳簿の訂正に失敗しました"
      redirect_to root_url
  end

  def destroy
    @original_record = Record.find_by(id: params[:id])
    @original_record.disabled = Time.zone.now
    if @original_record.save
      flash[:success] = "記録を削除しました"
      redirect_to records_path      
    else 
      flash[:danger] = "記録の削除に失敗しました"
      redirect_to records_path
    end
  end

 private

  def record_params_independent # This returns hash. It lose validation status.
    permitted_params = params.require(:record).permit(
      :account, :amount, :when, :where, :where_from, :quantity, :division, :user_id)
    hash = permitted_params.to_h
    division = Division.where(name: hash[:division]).find_by(user_id: session[:user_id])
    account = Account.find_by(name: hash[:account])
    division ? hash[:division_id] = division.id : hash[:division_id] = nil
    account ? hash[:account_id] = account.id : hash[:account_id] = nil
    hash.delete(:division)
    hash.delete(:account)
    hash
  end
end
