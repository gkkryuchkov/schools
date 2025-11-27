require 'swagger_helper'

RSpec.describe 'Groups API', type: :request do
  path '/schools/{school_id}/classes/{class_id}/students' do
    parameter name: :school_id, in: :path, type: :integer, description: 'School ID'
    parameter name: :class_id, in: :path, type: :integer, description: 'Class ID'

    get 'Retrieves students for a class' do
      tags 'Classes'
      produces 'application/json'

      response '200', 'successful - returns all students for the class' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, description: 'Student ID' },
                       first_name: { type: :string, description: 'First name' },
                       last_name: { type: :string, description: 'Last name' },
                       surname: { type: :string, description: 'Surname' },
                       class_id: { type: :integer, description: 'Class ID' },
                       school_id: { type: :integer, description: 'School ID' }
                     },
                     required: %w[id first_name last_name surname class_id school_id]
                   }
                 }
               },
               required: ['data']

        let!(:school) { School.create! }
        let!(:group) do
          Group.create!(
            school: school,
            number: 1,
            letter: '',
            students_count: 2
          )
        end
        let!(:student1) do
          Student.create!(
            school: school,
            group: group,
            first_name: 'OG5A;02',
            last_name: '14C@0E<0=30468528G',
            surname: 'CE>1>9=8:>2-!K@:8='
          )
        end
        let!(:student2) do
          Student.create!(
            school: school,
            group: group,
            first_name: '20=',
            last_name: '20=>28G',
            surname: '20=>2'
          )
        end
        let!(:other_group) do
          Group.create!(
            school: school,
            number: 2,
            letter: '',
            students_count: 1
          )
        end
        let!(:other_student) do
          Student.create!(
            school: school,
            group: other_group,
            first_name: '5B@',
            last_name: '5B@>28G',
            surname: '5B@>2'
          )
        end
        let(:school_id) { school.id }
        let(:class_id) { group.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(2)

          student_ids = json['data'].map { |s| s['id'] }
          expect(student_ids).to contain_exactly(student1.id, student2.id)
          expect(student_ids).not_to include(other_student.id)

          student1_data = json['data'].find { |s| s['id'] == student1.id }
          expect(student1_data['first_name']).to eq('OG5A;02')
          expect(student1_data['last_name']).to eq('14C@0E<0=30468528G')
          expect(student1_data['surname']).to eq('CE>1>9=8:>2-!K@:8=')
          expect(student1_data['class_id']).to eq(group.id)
          expect(student1_data['school_id']).to eq(school.id)
        end
      end

      response '200', 'successful - returns empty array when class has no students' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {}
                 }
               },
               required: ['data']

        let!(:school) { School.create! }
        let!(:empty_group) do
          Group.create!(
            school: school,
            number: 3,
            letter: '',
            students_count: 0
          )
        end
        let(:school_id) { school.id }
        let(:class_id) { empty_group.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']).to eq([])
        end
      end
    end
  end
end
