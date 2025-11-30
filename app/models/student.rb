class Student < ApplicationRecord
  belongs_to :group, counter_cache: true

  validates :first_name, :last_name, :surname, presence: true

  # Генериует токен из id пользователя с прмиешиванием соли, в качестве соли использует secret_key_base
  # @return [String] токен для аутентификации
  def generate_auth_token
    secret_salt = Rails.application.secret_key_base
    Digest::SHA256.hexdigest("#{id}#{secret_salt}")
  end
end
