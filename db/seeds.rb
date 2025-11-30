# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Если нет школ
5.times { School.create } unless School.any?

# Если нет классов
unless StudyClass.any?
  school_ids = School.pluck(:id)
  letters = (0...32).to_a.map { |i| ('А'.ord + i).chr }

  10.times do
    StudyClass.create(
      school_id: school_ids.sample,
      number: (1..11).to_a.sample,
      letter: letters.sample
    )
  end
end
# Если нет студентов
unless Student.any?

  classes = StudyClass.all.to_a

  first_names = %w[Иван Петр Сергей Владимир Сергей]
  surnames = %w[Иванов Петров Кузнецов Сергеев Павлов Дьяков Альпов Ефимов]
  last_names = %w[Иванович Петрович Сидорович Сергеевич Артемович Кириллович]

  30.times do
    cl = classes.sample
    Student.create(
      first_name: first_names.sample,
      last_name: last_names.sample,
      surname: surnames.sample,
      study_class_id: cl.id
    )
  end

end
