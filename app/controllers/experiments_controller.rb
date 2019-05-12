class ExperimentsController < ApplicationController
  def new
    @attributes = {name: "testname", option: 1}
    render :file => "foo/new.html.erb"
  end
end
