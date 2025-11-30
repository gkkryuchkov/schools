class StudentsController < ApplicationController
  before_action :set_student, only: %i[destroy]

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
  def destroy
    auth_token = request.headers['X-Auth-Token']
    # если токена нет - запрос не разрешен
    head :not_authorized and return unless auth_token

    # Если ученик не найден
    head :bad_request and return unless @student

    if @student.check_auth(auth_token)
      # Если авторизационный токен корректен
      @student.destroy
    else
      head :not_authorized and return
    end
  end

  private

  def set_student
    @student = Student.where(id: params[:id]).first
  end

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
    p[:study_class_id] = p.delete(:class_id)
    p
  end
end
