# Schools API

Rails API приложение для управления школами, классами и учениками.

## Ruby version

Ruby 3.3.0
Rails 7.1

## Запуск

```bash
docker compose up -d
```

## API Documentation

Swagger документация доступна по адресу `/api-docs` после запуска приложения.

## Модели

- `School` - Школа
- `StudyClass` - Класс
- `Student` - Студент

## Тесты
### Запуск тестов в Docker

```bash
./bin/docker-test
```

### Запуск тестов локально (без Docker)

```bash
# Настройка базы данных
rails db:create db:migrate

# Запуск всех тестов
bundle exec rspec
```