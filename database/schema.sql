-- database/schema.sql

-- Создание базы данных для бота знакомств ВКонтакте
CREATE DATABASE vkinder_bot;

-- Переключение на созданную базу данных для последующих операций
--\c vkinder_bot;

-- Создание таблицы пользователей - основная таблица для хранения информации о пользователях
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,          -- Автоинкрементируемый первичный ключ
    vk_id INTEGER UNIQUE NOT NULL,       -- ID пользователя ВКонтакте (уникальный)
    first_name VARCHAR(100),             -- Имя пользователя
    last_name VARCHAR(100),              -- Фамилия пользователя
    age INTEGER,                         -- Возраст пользователя
    city VARCHAR(100),                   -- Город пользователя
    sex INTEGER,                         -- Пол пользователя (1 - женский, 2 - мужской)
    interests TEXT,                      -- Интересы пользователя (текстовое поле)
    profile_link VARCHAR(200),           -- Ссылка на профиль ВКонтакте
    photos TEXT[],                       -- Массив ссылок на фотографии пользователя
    last_search TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Время последнего поиска
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP    -- Время создания записи
);

-- Создание таблицы предпочтений пользователей для поиска
CREATE TABLE user_preferences (
    preference_id SERIAL PRIMARY KEY,    -- Автоинкрементируемый первичный ключ
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,  -- Внешний ключ к users
    min_age INTEGER DEFAULT 18,          -- Минимальный возраст для поиска
    max_age INTEGER DEFAULT 35,          -- Максимальный возраст для поиска
    preferred_city VARCHAR(100),         -- Предпочтительный город для поиска
    preferred_sex INTEGER,               -- Предпочтительный пол для поиска
    search_interests TEXT,               -- Интересы для поиска
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- Время создания записи
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP     -- Время последнего обновления
);

-- Создание таблицы совпадений (matches) между пользователями
CREATE TABLE matches (
    match_id SERIAL PRIMARY KEY,         -- Автоинкрементируемый первичный ключ
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,  -- Внешний ключ (кто ищет)
    matched_user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,  -- Внешний ключ (кого нашли)
    match_score FLOAT,                   -- Оценка совпадения (0-1 или 0-100)
    status VARCHAR(20) DEFAULT 'pending',-- Статус совпадения (pending, approved, rejected)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- Время создания записи
    UNIQUE(user_id, matched_user_id)     -- Уникальная пара пользователей
);

-- Создание таблицы взаимодействий между пользователями
CREATE TABLE interactions (
    interaction_id SERIAL PRIMARY KEY,   -- Автоинкрементируемый первичный ключ
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,  -- Внешний ключ (кто взаимодействует)
    target_user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,  -- Внешний ключ (с кем взаимодействуют)
    action_type VARCHAR(20),             -- Тип действия (like, dislike, view, message)
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP      -- Время взаимодействия
);

-- Создание индексов для оптимизации запросов

-- Индекс для быстрого поиска по VK ID
CREATE INDEX idx_users_vk_id ON users(vk_id);

-- Индекс для быстрого поиска по городу
CREATE INDEX idx_users_city ON users(city);

-- Индекс для быстрого поиска по возрасту
CREATE INDEX idx_users_age ON users(age);

-- Индекс для быстрого поиска совпадений по пользователю
CREATE INDEX idx_matches_user ON matches(user_id);

-- Индекс для быстрого фильтрации совпадений по статусу
CREATE INDEX idx_matches_status ON matches(status);