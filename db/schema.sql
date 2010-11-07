-- 
-- the uniqe name of a gem.
DROP TABLE IF EXISTS gems CASCADE;
CREATE TABLE  gems (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(128) NOT NULL UNIQUE
);

--
-- most of the metadata from a rubygems specification
--
DROP TABLE IF EXISTS gem_versions CASCADE;
CREATE TABLE  gem_versions ( 
    id                              SERIAL PRIMARY KEY,
    gem_id                          INTEGER REFERENCES gems(id) NOT NULL,
    full_name                       TEXT NOT NULL UNIQUE,
    md5                             VARCHAR(32) NOT NULL, -- of the .gem file
    sha1                            VARCHAR(40) NOT NULL, -- of the .gem file
    version                         VARCHAR(128) NOT NULL,
    platform                        VARCHAR(128) NOT NULL,
    is_prerelease                   BOOLEAN NOT NULL,
    release_date                    DATE NOT NULL,
    required_rubygems_version       TEXT NOT NULL,
    required_ruby_version           TEXT NOT NULL,
    packaged_specification_version  TEXT NOT NULL,
    packaged_rubygems_version       TEXT NOT NULL,
    summary                         TEXT,
    homepage                        TEXT,
    rubyforge_project               TEXT,
    description                     TEXT,
    autorequire                     TEXT,
    has_signing_key                 BOOLEAN NOT NULL,
    has_cert_chain                  BOOLEAN NOT NULL,
    has_extension                   BOOLEAN NOT NULL,
    post_install_message            TEXT
);
CREATE UNIQUE INDEX  gem_versions_platform_uidx ON gem_versions( gem_id, version, platform );
CREATE INDEX  gem_versions_full_name_idx ON gem_versions( full_name );

--
-- The raw ruby specification
--
DROP TABLE IF EXISTS gem_version_raw_specifications;
CREATE TABLE  gem_version_raw_specifications( 
    id              SERIAL PRIMARY KEY,
    gem_version_id  INTEGER REFERENCES gem_versions( id ) UNIQUE NOT NULL,
    ruby            TEXT NOT NULL
);

--
-- The Gem dependencies
--
DROP TYPE IF EXISTS gem_dependency_type CASCADE;
CREATE TYPE gem_dependency_type AS enum ('runtime', 'development');
DROP TABLE IF EXISTS dependencies CASCADE;
CREATE TABLE dependencies(
    id              SERIAL PRIMARY KEY,
    operator        VARCHAR(3) NOT NULL,
    gem_name        VARCHAR(128) NOT NULL,
    version         VARCHAR(128) NOT NULL,
    is_prerelease   BOOLEAN NOT NULL,
    dependency_type gem_dependency_type NOT NULL
);
CREATE UNIQUE INDEX dependencies_name_operator_version_prerelease_uidx ON dependencies( gem_name, operator, version, is_prerelease, dependency_type );

DROP TABLE IF EXISTS gem_version_dependencies CASCADE;
CREATE TABLE  gem_version_dependencies( 
    id              SERIAL PRIMARY KEY,
    gem_version_id  INTEGER REFERENCES gem_versions( id ) NOT NULL,
    dependency_id   INTEGER REFERENCES dependencies( id ) NOT NULL
);
CREATE INDEX  gem_version_dependencies_gem_version_id_idx ON gem_version_dependencies( gem_version_id );

--
-- Licenses listed in gems, both in the gem spec and files that exist in the gem
-- meta licencses are those from the spec, file licenses are from files
--
DROP TABLE IF EXISTS licenses CASCADE;
CREATE TABLE licenses (
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL,
    content     TEXT NOT NULL,
    sha1        VARCHAR(40) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS gem_version_licenses CASCADE;
CREATE TABLE gem_version_licenses (
    id              SERIAL PRIMARY KEY,
    gem_version_id  INTEGER REFERENCES gem_versions(id) NOT NULL,
    license_id      INTEGER REFERENCES licenses(id) NOT NULL
);

--
-- authors listed in gems
-- 
DROP TABLE IF EXISTS authors CASCADE;
CREATE TABLE  authors (
    id          SERIAL PRIMARY KEY,
    name        TEXT UNIQUE NOT NULL
);

DROP TABLE IF EXISTS gem_version_authors CASCADE;
CREATE TABLE  gem_version_authors (
    id              SERIAL PRIMARY KEY,
    gem_version_id  INTEGER REFERENCES gem_versions(id) NOT NULL,
    author_id       INTEGER REFERENCES authors(id) NOT NULL,
    listed_order    INTEGER NOT NULL
);
CREATE UNIQUE INDEX  gem_version_authors_uidx ON gem_version_authors( gem_version_id, author_id );

--
-- emails listed in gems
-- 
DROP TABLE IF EXISTS emails CASCADE;
CREATE TABLE  emails (
    id      SERIAL PRIMARY KEY,
    email   TEXT UNIQUE NOT NULL
);
DROP TABLE IF EXISTS gem_version_emails CASCADE;
CREATE TABLE  gem_version_emails (
    id              SERIAL PRIMARY KEY,
    gem_version_id  INTEGER REFERENCES gem_versions(id) NOT NULL,
    email_id        INTEGER REFERENCES emails(id) NOT NULL,
    listed_order    INTEGER NOT NULL
);
CREATE UNIQUE INDEX  gem_version_emails_uidx ON gem_version_emails( gem_version_id, email_id );

-- 
-- 
--
DROP TABLE IF EXISTS requirements CASCADE;
CREATE TABLE requirements(
    id                  SERIAL PRIMARY KEY,
    requirement         TEXT NOT NULL UNIQUE
);
DROP TABLE IF EXISTS gem_version_requirements CASCADE;
CREATE TABLE  gem_version_requirements (
    id                  SERIAL PRIMARY KEY,
    gem_version_id      INTEGER REFERENCES gem_versions( id ) NOT NULL,
    requirement_id      INTEGER REFERENCES requirements( id ) NOT NULL
);
CREATE UNIQUE INDEX  gem_version_requirementss_uidx ON gem_version_requirements( gem_version_id, requirement_id);

--
-- Each file in the gem has a listing here
--
DROP TABLE IF EXISTS gem_version_files CASCADE;
CREATE TABLE  gem_version_files( 
    id                  SERIAL PRIMARY KEY,
    gem_version_id      INTEGER REFERENCES gem_versions(id) NOT NULL,
    filename            TEXT NOT NULL,
    sha1                VARCHAR( 40 ) NOT NULL,
    size                INTEGER NOT NULL,
    mode                INTEGER NOT NULL,
    is_test_file        BOOLEAN NOT NULL,
    is_extra_rdoc_file  BOOLEAN NOT NULL,
    is_executable_file  BOOLEAN NOT NULL,
    is_extension_file   BOOLEAN NOT NULL,
    is_license_file     BOOLEAN NOT NULL
);

CREATE INDEX  gem_version_files_filename_idx ON gem_version_files( filename );
CREATE INDEX  gem_version_files_sha1_idx ON gem_version_files( sha1 );
