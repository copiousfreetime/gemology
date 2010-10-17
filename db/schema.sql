-- 
CREATE TABLE IF NOT EXISTS gems (
    id      INTEGER PRIMARY KEY,
    name    VARCHAR(128) UNIQUE
);

CREATE TABLE IF NOT EXISTS gem_versions ( 
    id                              INTEGER PRIMARY KEY,
    gem_id                          INTEGER REFERENCES gems(id),
    full_name                       TEXT NOT NULL UNIQUE,
    md5                             VARCHAR(32) NOT NULL, -- of the .gem file
    sha1                            VARCHAR(40) NOT NULL, -- of the .gem file
    version                         VARCHAR(16) NOT NULL,
    platform                        VARCHAR(16) NOT NULL,
    is_prerelease                   BOOLEAN NOT NULL,
    release_date                    DATE NOT NULL,
    required_rubygems_version       NOT NULL,
    required_ruby_version           NOT NULL,
    packaged_specification_version  NOT NULL,
    packaged_rubygems_version       NOT NULL,
    summary                         TEXT,
    homepage                        TEXT,
    rubyforge_project               TEXT,
    description                     TEXT,
    autorequire                     TEXT,
    has_signing_key                 BOOLEAN NOT NULL,
    has_cert_chain                  BOOLEAN NOT NULL,
    post_install_message            TEXT
);
CREATE UNIQUE INDEX IF NOT EXISTS gem_versions_platform_uidx ON gem_versions( gem_id, version, platform );
CREATE INDEX IF NOT EXISTS gem_versions_full_name_idx ON gem_versions( full_name );

CREATE TABLE IF NOT EXISTS gem_version_raw_specifications( 
    id              INTEGER PRIMARY KEY,
    gem_version_id  INTEGER REFERENCES gem_versions( id ),
    ruby            TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS gem_version_raw_specifications_gem_version_id_idx ON gem_version_raw_specifications( gem_version_id );

CREATE TABLE IF NOT EXISTS gem_version_dependencies( 
    id              INTEGER PRIMARY KEY,
    gem_version_id  INTEGER REFERENCES gem_versions( id ),
    dependency      TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS gem_version_dependencies_gem_version_id_idx ON gem_version_dependencies( gem_version_id );

CREATE TABLE IF NOT EXISTS licenses (
    id          INTEGER PRIMARY KEY,
    name        VARCHAR(64) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS gem_version_licenses (
    id                  INTEGER PRIMARY KEY,
    gem_version_id      INTEGER REFERENCES gem_versions( id ) NOT NULL,
    license_id          INTEGER REFERENCES licenses( id ) NOT NULL
);
CREATE INDEX IF NOT EXISTS gem_version_licenses_gem_version_id_idx ON gem_version_licenses( gem_version_id );


CREATE TABLE IF NOT EXISTS authors (
    id          INTEGER PRIMARY KEY,
    name        TEXT UNIQUE NOT NULL
);
CREATE TABLE IF NOT EXISTS gem_version_authors (
    id              INTEGER PRIMARY KEY,
    gem_version_id  INTEGER REFERENCES gem_versions(id),
    author_id       INTEGER REFERENCES authors(id),
    listed_order    INTEGER NOT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS gem_version_authors_uidx ON gem_version_authors( gem_version_id, author_id );

-- if using postgres these could be an array type 
CREATE TABLE IF NOT EXISTS emails (
    id      INTEGER PRIMARY KEY,
    email   TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS gem_version_emails (
    id              INTEGER PRIMARY KEY,
    gem_version_id  INTEGER REFERENCES gem_versions(id),
    email_id        INTEGER REFERENCES emails(id),
    listed_order    INTEGER NOT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS gem_version_emails_uidx ON gem_version_emails( gem_version_id, email_id );

CREATE TABLE IF NOT EXISTS requirements(
    id                  INTEGER PRIMARY KEY,
    requirement         TEXT NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS gem_version_requirements (
    id                  INTEGER PRIMARY KEY,
    gem_version_id      INTEGER REFERENCES gem_versions( id ),
    requirement_id      INTEGER REFERENCES requrements( id )
);
CREATE UNIQUE INDEX IF NOT EXISTS gem_version_requirementss_uidx ON gem_version_requirements( gem_version_id, requirement_id);
  
CREATE TABLE IF NOT EXISTS gem_version_files( 
    id                  INTEGER PRIMARY KEY,
    gem_version_id      INTEGER REFERENCES gem_versions(id) NOT NULL,
    filename            TEXT NOT NULL,
    sha1                VARCHAR( 40 ) NOT NULL,
    is_test_file        BOOLEAN NOT NULL,
    is_extra_rdoc_file  BOOLEAN NOT NULL,
    is_executable       BOOLEAN NOT NULL
);

CREATE INDEX IF NOT EXISTS gem_version_files_filename_idx ON gem_version_files( filename );
CREATE INDEX IF NOT EXISTS gem_version_files_sha1_idx ON gem_version_files( sha1 );





