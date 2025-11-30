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
    Student.new(
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
  end
end
