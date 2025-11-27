class GroupsController < ApplicationController
  before_action :set_school
  before_action :set_group
  def students; end

  private

  def set_school
    @school = School.find(params[:school_id])
  end

  def set_group
    @group = @school.greoups.find(paramsp: id)
  end
end
