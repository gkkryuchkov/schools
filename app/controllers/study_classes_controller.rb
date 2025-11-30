class StudyClassesController < ApplicationController
  before_action :set_school
  before_action :set_study_class
  def students
    @students = @study_class.students
  end

  private

  def set_school
    @school = School.find(params[:school_id])
  end

  def set_study_class
    @study_class = @school.classes.find(params[:id])
  end
end
