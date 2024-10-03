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
