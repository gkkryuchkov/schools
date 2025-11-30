require 'swagger_helper'

RSpec.describe 'Students API', type: :request do
  path '/students' do
    post 'Создает ученика' do
      tags 'students'
      consumes 'application/json'
      produces 'application/json'
      description 'Создает ученика в конкретном классе конкретной школы. Возвращает токен в хэдере X-Auth-Token.'

      parameter name: :student_data, in: :body, schema: {
        type: :object,
        properties: {
          school_id: { type: :integer, description: 'ID школы' },
          class_id: { type: :integer, description: 'ID класса' },
          first_name: { type: :string, description: 'Имя' },
          last_name: { type: :string, description: 'Отчество' },
          surname: { type: :string, description: 'Фамилия' }
        },
        required: %w[school_id class_id first_name last_name surname]
      }

      response '201', 'ученик успешно создан' do
        schema type: :object,
               properties: {
                 id: { type: :integer, description: 'ID ученика' },
                 first_name: { type: :string, description: 'Имя' },
                 last_name: { type: :string, description: 'Отчество' },
                 surname: { type: :string, description: 'Фамилия' },
                 class_id: { type: :integer, description: 'ID класса' }
               },
               required: %w[id first_name last_name surname class_id]

        header 'X-Auth-Token', schema: { type: :string }, description: 'Аутентификационный токен ученика'

        let!(:school) { School.create! }
        let!(:study_class) do
          StudyClass.create!(
            school: school,
            number: 1,
            letter: 'А',
            students_count: 0
          )
        end
        let(:student_data) do
          {
            school_id: school.id,
            class_id: study_class.id,
            first_name: 'Вячеслав',
            last_name: 'Абдурахмангаджиевич',
            surname: 'Мухобойников-Сыркин'
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['id']).to be_present
          expect(json['first_name']).to eq('Вячеслав')
          expect(json['last_name']).to eq('Абдурахмангаджиевич')
          expect(json['surname']).to eq('Мухобойников-Сыркин')
          expect(json['class_id']).to eq(study_class.id)

          # Проверяем, что токен присутствует в хедере
          auth_token = response.headers['X-Auth-Token']
          expect(auth_token).to be_present
          expect(auth_token.length).to eq(64) # SHA256 hash

          # Проверяем, что токен корректный
          student = Student.find(json['id'])
          expect(student.check_auth(auth_token)).to be true

          # Проверяем, что counter_cache корректно обновился
          study_class.reload
          expect(study_class.students_count).to eq(1)
        end
      end

      response '405', 'школа не найдена' do
        let(:student_data) do
          {
            school_id: 99_999,
            class_id: 1,
            first_name: 'Иван',
            last_name: 'Иванович',
            surname: 'Иванов'
          }
        end

        run_test!
      end

      response '405', 'данного класса нет в указанной школе' do
        let!(:school) { School.create! }
        let!(:other_school) { School.create! }
        let!(:study_class) do
          StudyClass.create!(
            school: other_school,
            number: 1,
            letter: 'А',
            students_count: 0
          )
        end
        let(:student_data) do
          {
            school_id: school.id,
            class_id: study_class.id, # класс принадлежит другой школе
            first_name: 'Иван',
            last_name: 'Иванович',
            surname: 'Иванов'
          }
        end

        run_test!
      end

      response '405', 'не заполнены обязательные поля' do
        let!(:school) { School.create! }
        let!(:study_class) do
          StudyClass.create!(
            school: school,
            number: 1,
            letter: 'А',
            students_count: 0
          )
        end
        let(:student_data) do
          {
            school_id: school.id,
            class_id: study_class.id,
            first_name: '', # пустое имя вызовет ошибку валидации
            last_name: 'Иванович',
            surname: 'Иванов'
          }
        end

        run_test!
      end
    end
  end

  path '/students/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID ученика'

    delete 'Удаляет ученика' do
      tags 'students'
      description 'Удаляет ученика. Необходимо передать токен ученика в хэдере X-Auth-Token.'

      parameter name: 'X-Auth-Token', in: :header, type: :string, description: 'Аутентификационный токен ученика',
                required: true

      response '204', 'ученик создан' do
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
          Student.create!(
            study_class: study_class,
            first_name: 'Вячеслав',
            last_name: 'Абдурахмангаджиевич',
            surname: 'Мухобойников-Сыркин'
          )
        end
        let(:id) { student.id }
        let(:'X-Auth-Token') { student.generate_auth_token }

        run_test! do |_response|
          expect(Student.where(id: student.id)).not_to exist

          # Проверяем, что counter_cache корректно уменьшился
          study_class.reload
          expect(study_class.students_count).to eq(0)
        end
      end

      response '401', 'токен не указан' do
        let!(:school) { School.create! }
        let!(:study_class) do
          StudyClass.create!(
            school: school,
            number: 1,
            letter: 'А',
            students_count: 1
          )
        end
        let!(:student) do
          Student.create!(
            study_class: study_class,
            first_name: 'Вячеслав',
            last_name: 'Абдурахмангаджиевич',
            surname: 'Мухобойников-Сыркин'
          )
        end
        let(:id) { student.id }
        let(:'X-Auth-Token') { nil }

        run_test!
      end

      response '401', 'неверный токен' do
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
          Student.create!(
            study_class: study_class,
            first_name: 'Вячеслав',
            last_name: 'Абдурахмангаджиевич',
            surname: 'Мухобойников-Сыркин'
          )
        end
        let(:id) { student.id }
        let(:'X-Auth-Token') { 'invalid_token_string' }

        run_test! do |_response|
          # Студент не должен быть удален
          expect(Student.where(id: student.id)).to exist

          # Проверяем, что counter_cache не изменился
          study_class.reload
          expect(study_class.students_count).to eq(1)
        end
      end

      response '401', 'токен принадлежит другому ученику' do
        let!(:school) { School.create! }
        let!(:study_class) do
          StudyClass.create!(
            school: school,
            number: 1,
            letter: 'А',
            students_count: 2
          )
        end
        let!(:student1) do
          Student.create!(
            study_class: study_class,
            first_name: 'Вячеслав',
            last_name: 'Абдурахмангаджиевич',
            surname: 'Мухобойников-Сыркин'
          )
        end
        let!(:student2) do
          Student.create!(
            study_class: study_class,
            first_name: 'Иван',
            last_name: 'Иванович',
            surname: 'Иванов'
          )
        end
        let(:id) { student1.id }
        let(:'X-Auth-Token') { student2.generate_auth_token } # токен другого студента

        run_test! do |_response|
          # student1 не должен быть удален
          expect(Student.where(id: student1.id)).to exist
        end
      end

      response '400', 'студент не найден' do
        let(:id) { 99_999 }
        let(:'X-Auth-Token') { 'some_token' }

        run_test!
      end
    end
  end
end
