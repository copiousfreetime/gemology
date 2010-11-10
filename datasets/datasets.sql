
-- 
-- Prefix directory all files will be stored in, this must be writable by 
-- the postgres server
--
\set prefix /tmp/datasets

--
-- Count of gem releases by day
--
\set output :prefix/release-counts-by-day.csv
\echo Writing :output
COPY (
    SELECT release_date
          ,count( * )   AS count
      FROM gem_versions 
  GROUP BY release_date
  ORDER BY release_date
) TO :'output'
WITH CSV HEADER
;

\set output :prefix/release-counts-by-month.csv
\echo Writing :output
COPY (
    SELECT date_trunc('month', release_date ) AS release_month
          ,count( * )   AS count
      FROM gem_versions 
  GROUP BY release_month
  ORDER BY release_month
) TO :'output'
WITH CSV HEADER
;


\set output :prefix/release-counts-by-day-of-month.csv
\echo Writing :output
COPY (
    SELECT extract('day' from release_date ) AS release_day_of_month
          ,count( * )   AS count
      FROM gem_versions 
  GROUP BY release_day_of_month
  ORDER BY release_day_of_montn
) TO :'output'
WITH CSV HEADER
;


-- 
-- Count of gem releases by platform by day
--
\set output :prefix/platform-counts-by-day.csv
\echo Writing :output

COPY (
    SELECT release_date
          ,split_part(platform, '-', 1) || split_part(platform, '-', 2) AS platform
          ,count( * )   AS count
      FROM gem_versions 
  GROUP BY release_date, platform
  ORDER BY release_date, platform
) TO :'output'
WITH CSV HEADER
;


-- 
-- Count of gem releases by platform by month
--
\set output :prefix/platform-counts-by-month.csv
\echo Writing :output
COPY (
    SELECT date_trunc('month', release_date ) AS release_month
          ,split_part(platform, '-', 1) || split_part(platform, '-', 2) AS platform
          ,count( * )   AS count
      FROM gem_versions 
  GROUP BY release_month, platform
  ORDER BY release_month, platform
) TO :'output'
WITH CSV HEADER
;



--
-- Count of new gems by day
--
\set output :prefix/new-gems-by-day.csv
\echo Writing :output

COPY (
    WITH first_release_dates AS (
         SELECT g.name                 AS name
               ,min( gv.release_date ) AS first_release_date
           FROM gems AS g
           JOIN gem_versions AS gv
             ON g.id = gv.gem_id
       GROUP BY g.name 
    )
    SELECT first_release_date AS release_date
          ,count(name) AS count
      FROM first_release_dates
  GROUP BY release_date
  ORDER BY release_date
) TO :'output'
WITH CSV HEADER
;


--
-- count by day of week
--
\set output :prefix/day-of-week-cunts.csv
\echo Writing :output
COPY (
    SELECT extract( isodow from release_date) AS day_of_week
          ,count(*)                           AS count
      FROM gem_versions
  GROUP BY day_of_week
) TO :'output'
WITH CSV HEADER
;

--
-- Count of gems by platform
--
\set output :prefix/platform-counts.csv
\echo Writing :output
COPY ( 
    SELECT split_part(platform, '-', 1) || split_part(platform, '-', 2) AS platform
          ,count( * )   AS count
      FROM gem_versions
  GROUP BY platform
) TO :'output'
WITH CSV HEADER
;
   
-- 
-- Count of new authors by day
--
\set output :prefix/new-authors-by-day.csv
\echo Writing :output

COPY (
    WITH first_release_dates AS (
         SELECT a.name                 AS name
               ,min( gv.release_date ) AS first_release_date
           FROM authors             AS a
           JOIN gem_version_authors AS gva
             ON a.id = gva.author_id
           JOIN gem_versions        AS gv
             ON gva.gem_version_id = gv.id
       GROUP BY name
    )
    SELECT first_release_date AS release_date
          ,count(name) AS count
      FROM first_release_dates
  GROUP BY release_date
  ORDER BY release_date
) TO :'output'
WITH CSV HEADER
;

--
-- gems using various different options
--
\set output :prefix/boolean-counts-by-month.csv
\echo Writing :output
COPY (
    SELECT date_trunc('month', release_date ) AS release_month
          ,SUM( CASE is_prerelease   WHEN true THEN 1 ELSE 0 END ) AS prerelease_count
          ,SUM( CASE has_signing_key WHEN true THEN 1 ELSE 0 END ) AS signing_key_count
          ,SUM( CASE WHEN post_install_message IS NOT NULL THEN 1 ELSE 0 END ) AS post_install_count
          ,SUM( CASE has_extension   WHEN true THEN 1 ELSE 0 END ) AS extension_count
      FROM gem_versions
  GROUP BY release_month
  ORDER BY release_month
) TO :'output'
WITH CSV HEADER
;

