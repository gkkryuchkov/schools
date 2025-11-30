require 'swagger_helper'

RSpec.describe 'Study Classes API', type: :request do
  path '/schools/{school_id}/classes/{id}/students' do
    parameter name: :school_id, in: :path, type: :integer, description: 'ID школы'
    parameter name: :id, in: :path, type: :integer, description: 'ID класса'

    get 'Вывести список учеников класса' do
      tags 'classes', 'students'
      produces 'application/json'

      response '200', 'возвращает список всех учеников класса' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, description: 'ID ученика' },
                       first_name: { type: :string, description: 'Имя' },
                       last_name: { type: :string, description: 'Отчество' },
                       surname: { type: :string, description: 'Фамилия' },
                       class_id: { type: :integer, description: 'ID класса' },
                       school_id: { type: :integer, description: 'ID школы' }
                     },
                     required: %w[id first_name last_name surname class_id school_id]
                   }
                 }
               },
               required: ['data']

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
        let!(:other_study_class) do
          StudyClass.create!(
            school: school,
            number: 2,
            letter: 'Б',
            students_count: 1
          )
        end
        let!(:other_student) do
          Student.create!(
            study_class: other_study_class,
            first_name: 'Петр',
            last_name: 'Петрович',
            surname: 'Петров'
          )
        end
        let(:school_id) { school.id }
        let(:id) { study_class.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(2)

          student_ids = json['data'].map { |s| s['id'] }
          expect(student_ids).to contain_exactly(student1.id, student2.id)
          expect(student_ids).not_to include(other_student.id)

          student1_data = json['data'].find { |s| s['id'] == student1.id }
          expect(student1_data['first_name']).to eq('Вячеслав')
          expect(student1_data['last_name']).to eq('Абдурахмангаджиевич')
          expect(student1_data['surname']).to eq('Мухобойников-Сыркин')
          expect(student1_data['class_id']).to eq(study_class.id)
          expect(student1_data['school_id']).to eq(school.id)
        end
      end
    end
  end
end
