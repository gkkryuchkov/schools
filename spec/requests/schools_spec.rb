require 'swagger_helper'

RSpec.describe 'Schools API', type: :request do
  path '/schools/{id}/classes' do
    parameter name: :id, in: :path, type: :integer, description: 'School ID'

    get 'Вывести список классов школы' do
      tags 'classes'
      produces 'application/json'

      response '200', 'возвращает все классы школы' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, description: 'ID класса' },
                       number: { type: :integer, description: 'Номер класса' },
                       letter: { type: :string, description: 'Буква класса' },
                       students_count: { type: :integer, description: 'Количество учеников в классе' }
                     },
                     required: %w[id number letter students_count]
                   }
                 }
               },
               required: ['data']

        let!(:school) { School.create! }
        let!(:class1) do
          StudyClass.create!(
            school: school,
            number: 1,
            letter: 'А',
            students_count: 25
          )
        end
        let!(:class2) do
          StudyClass.create!(
            school: school,
            number: 1,
            letter: 'Б',
            students_count: 32
          )
        end
        let!(:class3) do
          StudyClass.create!(
            school: school,
            number: 2,
            letter: 'В',
            students_count: 28
          )
        end
        let!(:other_school) { School.create! }
        let!(:other_class) do
          StudyClass.create!(
            school: other_school,
            number: 3,
            letter: 'Г',
            students_count: 20
          )
        end
        let(:id) { school.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(3)

          class_ids = json['data'].map { |c| c['id'] }
          expect(class_ids).to contain_exactly(class1.id, class2.id, class3.id)
          expect(class_ids).not_to include(other_class.id)

          class1_data = json['data'].find { |c| c['id'] == class1.id }
          expect(class1_data['number']).to eq(1)
          expect(class1_data['letter']).to eq('А')
          expect(class1_data['students_count']).to eq(25)
        end
      end
    end
  end
end
