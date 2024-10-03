CREATE TABLE IF NOT EXISTS websites (
    id SERIAL NOT NULL,
    url varchar(255) NOT NULL UNIQUE,
    inserted_at timestamp
    with
        time zone DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamp
    with
        time zone DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS telegram_chats (
    id SERIAL NOT NULL,
    chat_id varchar(255) NOT NULL UNIQUE,
    inserted_at timestamp
    with
        time zone DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamp
    with
        time zone DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS websites_telegram_chats (
    website_id INT REFERENCES websites(id) ON DELETE CASCADE,
    telegram_chat_id INT REFERENCES telegram_chats(id) ON DELETE CASCADE,
    PRIMARY KEY (website_id, telegram_chat_id)
);

CREATE TABLE IF NOT EXISTS telegram_web_availability (
    id SERIAL NOT NULL,
    "data" jsonb,
    tag varchar(255),
    archived boolean,
    stage varchar(255),
    status varchar(255),
    error_message jsonb,
    version varchar(255),
    inserted_at timestamp
    with
        time zone DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamp
    with
        time zone DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id)
);
