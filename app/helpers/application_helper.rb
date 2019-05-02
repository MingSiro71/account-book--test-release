module ApplicationHelper
  def full_title(page_title = '')
    base_title = "Account Book : 個人事業主のための簡易帳簿システム"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def copy_right
    message = "Created by : HENTECH"
    message
  end

end
