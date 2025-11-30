class Student < ApplicationRecord
  belongs_to :study_class, counter_cache: true

  validates :first_name, :last_name, :surname, presence: true

  # Генерирует токен из id пользователя с примешиванием соли, в качестве соли использует secret_key_base
  # @return [String] токен для аутентификации
  def generate_auth_token
    secret_salt = Rails.application.secret_key_base
    Digest::SHA256.hexdigest("#{id}#{secret_salt}")
  end

  # Проверяет, принадлежит ли данный токен конкретному ученику
  # @param [Sting] token Авторизационный токен
  # @return [Boolean] принадлежит ли токен данному ученику
  def check_auth(token)
    token == generate_auth_token
  end
end
