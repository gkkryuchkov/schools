class SchoolsController < ApplicationController
  before_action :set_school, only: %i[classes]

  def classes
    @classes = @school.classes
  end

  private

  def set_school
    @school = School.find(params[:id])
  end
end
