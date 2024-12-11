CREATE TABLE IF NOT EXISTS birthday (
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

CREATE TABLE IF NOT EXISTS pto (
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

CREATE TABLE IF NOT EXISTS support_emails (
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

CREATE TABLE IF NOT EXISTS wip_limits (
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

CREATE TABLE IF NOT EXISTS review_images (
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

CREATE TABLE IF NOT EXISTS review_text (
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

CREATE TABLE IF NOT EXISTS do_billing (
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

CREATE TABLE IF NOT EXISTS web_availability (
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

CREATE TABLE IF NOT EXISTS github_issues (
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

CREATE TABLE IF NOT EXISTS observed_websites (
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

CREATE TABLE IF NOT EXISTS conversations (
    id SERIAL NOT NULL,
    conversation_id varchar(255) NOT NULL UNIQUE,
    inserted_at timestamp
    with
        time zone DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamp
    with
        time zone DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS observed_websites_conversations (
    observed_website_id INT REFERENCES observed_websites(id) ON DELETE CASCADE,
    conversation_id INT REFERENCES conversations(id) ON DELETE CASCADE,
    PRIMARY KEY (observed_website_id, conversation_id)
);

CREATE TABLE IF NOT EXISTS observed_websites_availability (
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

CREATE TABLE IF NOT EXISTS backups (
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
