-- ============================================================
-- Football Club Database – Roles & Permissions
-- File : 08_roles_permissions.sql
-- ============================================================
-- Three roles are defined:
--   fc_admin        – full control (DDL + DML + role management)
--   fc_app_user     – application backend (DML only, no DDL)
--   fc_readonly     – read-only analysts / reporting tools
-- ============================================================

-- ============================================================
-- 1. Create roles (idempotent: DROP IF EXISTS first)
-- ============================================================

DROP ROLE IF EXISTS fc_readonly;
DROP ROLE IF EXISTS fc_app_user;
DROP ROLE IF EXISTS fc_admin;

CREATE ROLE fc_admin    WITH LOGIN PASSWORD 'Admin$ecure123'  CREATEDB CREATEROLE;
CREATE ROLE fc_app_user WITH LOGIN PASSWORD 'App$ecure456';
CREATE ROLE fc_readonly WITH LOGIN PASSWORD 'Read$ecure789';

COMMENT ON ROLE fc_admin    IS 'Full administrative access to the football club database.';
COMMENT ON ROLE fc_app_user IS 'Application backend: can read and write data, cannot alter schema.';
COMMENT ON ROLE fc_readonly IS 'Read-only access for reporting and analytics.';

-- ============================================================
-- 2. Schema-level usage
-- ============================================================

GRANT USAGE ON SCHEMA public TO fc_app_user, fc_readonly;

-- ============================================================
-- 3. fc_admin – superuser-style access on all objects
-- ============================================================

GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA public TO fc_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO fc_admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO fc_admin;
GRANT ALL PRIVILEGES ON ALL PROCEDURES IN SCHEMA public TO fc_admin;

-- Ensure future objects are also covered
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON TABLES    TO fc_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON SEQUENCES TO fc_admin;

-- ============================================================
-- 4. fc_app_user – SELECT, INSERT, UPDATE, DELETE; no DROP/ALTER
-- ============================================================

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
    club, stadium, team, position, player,
    coach, staff, competition, season,
    match, contract, player_stat, team_stat
TO fc_app_user;

-- Allow sequences for SERIAL columns (needed for INSERT)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO fc_app_user;

-- Allow execution of functions and the procedure
GRANT EXECUTE ON FUNCTION  get_player_age(INT)                  TO fc_app_user;
GRANT EXECUTE ON FUNCTION  get_club_squad_summary(INT)          TO fc_app_user;
GRANT EXECUTE ON FUNCTION  get_player_match_stats(INT, INT)     TO fc_app_user;
GRANT EXECUTE ON PROCEDURE register_match_result(INT, SMALLINT, SMALLINT,
    NUMERIC, NUMERIC, SMALLINT, SMALLINT, SMALLINT, SMALLINT)   TO fc_app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO fc_app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO fc_app_user;

-- ============================================================
-- 5. fc_readonly – SELECT only on all tables; no write access
-- ============================================================

GRANT SELECT ON TABLE
    club, stadium, team, position, player,
    coach, staff, competition, season,
    match, contract, player_stat, team_stat
TO fc_readonly;

-- Read-only access to functions (useful for analytics queries)
GRANT EXECUTE ON FUNCTION  get_player_age(INT)              TO fc_readonly;
GRANT EXECUTE ON FUNCTION  get_club_squad_summary(INT)      TO fc_readonly;
GRANT EXECUTE ON FUNCTION  get_player_match_stats(INT, INT) TO fc_readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO fc_readonly;

-- ============================================================
-- 6. Explicit REVOKE examples
-- ============================================================

-- Revoke DELETE on sensitive financial tables from app user
REVOKE DELETE ON TABLE contract FROM fc_app_user;

-- Revoke access to the contract table from the readonly role
-- (salary data is restricted to admin and app only)
REVOKE SELECT ON TABLE contract FROM fc_readonly;

-- ============================================================
-- 7. Verification queries
-- ============================================================

-- List all roles and their attributes:
-- SELECT rolname, rolcanlogin, rolcreatedb, rolcreaterole
-- FROM   pg_roles
-- WHERE  rolname LIKE 'fc_%'
-- ORDER  BY rolname;

-- Show table-level privileges for the app user:
-- SELECT grantee, table_name, privilege_type
-- FROM   information_schema.role_table_grants
-- WHERE  grantee = 'fc_app_user'
-- ORDER  BY table_name, privilege_type;

-- Show table-level privileges for the readonly role:
-- SELECT grantee, table_name, privilege_type
-- FROM   information_schema.role_table_grants
-- WHERE  grantee = 'fc_readonly'
-- ORDER  BY table_name, privilege_type;
