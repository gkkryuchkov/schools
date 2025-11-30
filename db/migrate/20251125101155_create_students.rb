class CreateStudents < ActiveRecord::Migration[7.1]
  def change
    create_table :students do |t|
      t.references :study_class, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :surname, null: false

      t.timestamps
    end
  end
end
