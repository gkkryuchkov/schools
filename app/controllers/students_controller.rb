class StudentsController < ApplicationController
  # POST /students
  # создание пользователя
  # в ответе в хэдере X-Auth-Token отдает токен для аутентификации
  def create
    # Ищем школу по id, если не находиим - возвращаем ошибку
    @school = School.where(id: params[:school_id]).first
    render_error and return if @school.nil?

    # Если школа была найдена, ищем среди ее классов подходящий
    # Если класса с указанным id нет в данной школе - возвращаем ошибку
    @group = @school.classes.where(id: params[:class_id]).first
    render_error and return if @group.nil?

    @student = Student.new(student_params)
    if @student.save
      response.headers['X-Auth-Token'] = @student.generate_auth_token
      render :create, status: 201
    else
      render_error
    end
  end

  # DELETE /students/{user_id}
  # Удаление пользователя, проверяет токен
  def destroy; end

  private

  def render_error
    head :method_not_allowed
  end

  def student_params
    p = params.permit(
      :first_name,
      :last_name,
      :surname,
      :class_id
    )
    # Переименовываем параметр
    p[:group_id] = p.delete(:class_id)
    p
  end
end
