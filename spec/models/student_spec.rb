require 'rails_helper'

RSpec.describe Student, type: :model do
  let!(:school) { School.create! }
  let!(:study_class) do
    StudyClass.create!(
      school: school,
      number: 1,
      letter: 'А',
      students_count: 0
    )
  end
  let!(:student) do
    Student.create(
      {
        first_name: 'Вячеслав',
        last_name: 'Абдурахмангаджиевич',
        surname: 'Мухобойников-Сыркин',
        study_class_id: study_class.id
      }
    )
  end
  context 'attributes' do
    it 'is valid with all filled attributes' do
      expect(student).to be_valid
    end

    it 'is not valid without one or more parts of the name' do
      expect(student).to be_valid
      # Проверяем что без одной части ФИО пользователь невалиден
      %i[first_name last_name surname].each do |name_part|
        original = student.send(name_part)
        student.send("#{name_part}=", nil)
        expect(student).to_not be_valid
        student.send("#{name_part}=", original)
      end

      student.last_name = ''

      expect(student).to_not be_valid
    end
  end

  context 'counter_cache' do
    it 'increments study_class students_count on create' do
      # перезагружаем данные о классе (так как один ученик был создан перед тестом)
      study_class.reload
      initial_count = study_class.students_count

      Student.create!(
        first_name: 'Иван',
        last_name: 'Иванович',
        surname: 'Иванов',
        study_class_id: study_class.id
      )

      study_class.reload
      expect(study_class.students_count).to eq(initial_count + 1)
    end

    it 'decrements study_class students_count on destroy' do
      new_student = Student.create!(
        first_name: 'Иван',
        last_name: 'Иванович',
        surname: 'Иванов',
        study_class_id: study_class.id
      )

      study_class.reload
      count_before_destroy = study_class.students_count

      new_student.destroy

      study_class.reload
      expect(study_class.students_count).to eq(count_before_destroy - 1)
    end
  end

  context 'auth' do
    it 'generates correct auth token' do
      token = student.generate_auth_token
      secret_salt = Rails.application.secret_key_base
      expected_token = Digest::SHA256.hexdigest("#{student.id}#{secret_salt}")

      expect(token).to eq(expected_token)
      expect(token).to be_a(String)
      expect(token.length).to eq(64) # SHA256 хеш в hex формате имеет длину 64 символа
    end

    it 'confirms correct auth token' do
      correct_token = student.generate_auth_token

      expect(student.check_auth(correct_token)).to be true
    end

    it 'rejects incorrect token' do
      incorrect_token = 'invalid_token_string'

      expect(student.check_auth(incorrect_token)).to be false

      # Также проверяем токен другого студента
      another_student = Student.create(
        first_name: 'Иван',
        last_name: 'Иванович',
        surname: 'Иванов',
        study_class_id: study_class.id
      )
      another_token = another_student.generate_auth_token

      expect(student.check_auth(another_token)).to be false
    end
  end
end
