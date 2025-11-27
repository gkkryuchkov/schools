class Student < ApplicationRecord
  belongs_to :school
  belongs_to :group, counter_cache: true
end
