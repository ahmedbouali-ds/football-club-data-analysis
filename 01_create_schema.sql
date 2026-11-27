-- ============================================================
-- Football Club Database – Schema (PostgreSQL)
-- File : 01_create_schema.sql
-- ============================================================

-- Drop tables in reverse dependency order (idempotent re-run)
DROP TABLE IF EXISTS player_stat   CASCADE;
DROP TABLE IF EXISTS team_stat     CASCADE;
DROP TABLE IF EXISTS contract      CASCADE;
DROP TABLE IF EXISTS match         CASCADE;
DROP TABLE IF EXISTS season        CASCADE;
DROP TABLE IF EXISTS competition   CASCADE;
DROP TABLE IF EXISTS stadium       CASCADE;
DROP TABLE IF EXISTS staff         CASCADE;
DROP TABLE IF EXISTS coach         CASCADE;
DROP TABLE IF EXISTS player        CASCADE;
DROP TABLE IF EXISTS position      CASCADE;
DROP TABLE IF EXISTS team          CASCADE;
DROP TABLE IF EXISTS club          CASCADE;

-- ============================================================
-- 1. CLUB
-- ============================================================
CREATE TABLE club (
    club_id      SERIAL        PRIMARY KEY,
    name         VARCHAR(100)  NOT NULL UNIQUE,
    country      VARCHAR(60)   NOT NULL,
    founded_year SMALLINT      NOT NULL CHECK (founded_year BETWEEN 1800 AND 2100),
    budget_eur   NUMERIC(15,2) NOT NULL DEFAULT 0 CHECK (budget_eur >= 0),
    website      VARCHAR(200)
);

-- ============================================================
-- 2. STADIUM
-- ============================================================
CREATE TABLE stadium (
    stadium_id SERIAL       PRIMARY KEY,
    name       VARCHAR(100) NOT NULL UNIQUE,
    city       VARCHAR(80)  NOT NULL,
    country    VARCHAR(60)  NOT NULL,
    capacity   INT          NOT NULL CHECK (capacity > 0),
    surface    VARCHAR(30)  NOT NULL DEFAULT 'Grass'
                            CHECK (surface IN ('Grass','Artificial','Hybrid'))
);

-- ============================================================
-- 3. TEAM  (a club can run multiple teams, e.g. first XI, U23)
-- ============================================================
CREATE TABLE team (
    team_id    SERIAL       PRIMARY KEY,
    club_id    INT          NOT NULL REFERENCES club(club_id) ON DELETE CASCADE,
    stadium_id INT          REFERENCES stadium(stadium_id) ON DELETE SET NULL,
    name       VARCHAR(100) NOT NULL,
    type       VARCHAR(20)  NOT NULL DEFAULT 'First Team'
                            CHECK (type IN ('First Team','Reserve','U23','U18','Women')),
    UNIQUE (club_id, name)
);

-- ============================================================
-- 4. POSITION
-- ============================================================
CREATE TABLE position (
    position_id   SERIAL      PRIMARY KEY,
    name          VARCHAR(50) NOT NULL UNIQUE,
    abbreviation  CHAR(3)     NOT NULL UNIQUE,
    category      VARCHAR(20) NOT NULL
                  CHECK (category IN ('Goalkeeper','Defender','Midfielder','Forward'))
);

-- ============================================================
-- 5. PLAYER
-- ============================================================
CREATE TABLE player (
    player_id    SERIAL       PRIMARY KEY,
    team_id      INT          REFERENCES team(team_id) ON DELETE SET NULL,
    position_id  INT          NOT NULL REFERENCES position(position_id),
    first_name   VARCHAR(60)  NOT NULL,
    last_name    VARCHAR(60)  NOT NULL,
    date_of_birth DATE        NOT NULL,
    nationality  VARCHAR(60)  NOT NULL,
    jersey_number SMALLINT    CHECK (jersey_number BETWEEN 1 AND 99),
    market_value_eur NUMERIC(12,2) DEFAULT 0 CHECK (market_value_eur >= 0),
    is_active    BOOLEAN      NOT NULL DEFAULT TRUE,
    UNIQUE (team_id, jersey_number)
);

-- ============================================================
-- 6. COACH
-- ============================================================
CREATE TABLE coach (
    coach_id    SERIAL      PRIMARY KEY,
    team_id     INT         REFERENCES team(team_id) ON DELETE SET NULL,
    first_name  VARCHAR(60) NOT NULL,
    last_name   VARCHAR(60) NOT NULL,
    nationality VARCHAR(60) NOT NULL,
    role        VARCHAR(40) NOT NULL DEFAULT 'Head Coach'
                CHECK (role IN ('Head Coach','Assistant Coach','Goalkeeper Coach',
                                'Fitness Coach','Analyst')),
    hired_date  DATE        NOT NULL
);

-- ============================================================
-- 7. STAFF  (non-coaching personnel)
-- ============================================================
CREATE TABLE staff (
    staff_id   SERIAL      PRIMARY KEY,
    club_id    INT         NOT NULL REFERENCES club(club_id) ON DELETE CASCADE,
    first_name VARCHAR(60) NOT NULL,
    last_name  VARCHAR(60) NOT NULL,
    role       VARCHAR(60) NOT NULL,
    department VARCHAR(60) NOT NULL DEFAULT 'General'
);

-- ============================================================
-- 8. COMPETITION
-- ============================================================
CREATE TABLE competition (
    competition_id SERIAL      PRIMARY KEY,
    name           VARCHAR(100) NOT NULL UNIQUE,
    type           VARCHAR(30)  NOT NULL
                   CHECK (type IN ('League','Cup','International','Friendly')),
    country        VARCHAR(60),          -- NULL for international competitions
    tier           SMALLINT    NOT NULL DEFAULT 1 CHECK (tier >= 1)
);

-- ============================================================
-- 9. SEASON
-- ============================================================
CREATE TABLE season (
    season_id      SERIAL      PRIMARY KEY,
    competition_id INT         NOT NULL REFERENCES competition(competition_id),
    label          VARCHAR(20) NOT NULL,   -- e.g. '2023/2024'
    start_date     DATE        NOT NULL,
    end_date       DATE        NOT NULL,
    CHECK (end_date > start_date),
    UNIQUE (competition_id, label)
);

-- ============================================================
-- 10. MATCH
-- ============================================================
CREATE TABLE match (
    match_id      SERIAL      PRIMARY KEY,
    season_id     INT         NOT NULL REFERENCES season(season_id),
    stadium_id    INT         REFERENCES stadium(stadium_id) ON DELETE SET NULL,
    home_team_id  INT         NOT NULL REFERENCES team(team_id),
    away_team_id  INT         NOT NULL REFERENCES team(team_id),
    match_date    TIMESTAMPTZ NOT NULL,
    home_goals    SMALLINT    DEFAULT NULL CHECK (home_goals >= 0),
    away_goals    SMALLINT    DEFAULT NULL CHECK (away_goals >= 0),
    status        VARCHAR(20) NOT NULL DEFAULT 'Scheduled'
                  CHECK (status IN ('Scheduled','In Progress','Completed','Postponed','Cancelled')),
    CHECK (home_team_id <> away_team_id)
);

-- ============================================================
-- 11. CONTRACT
-- ============================================================
CREATE TABLE contract (
    contract_id    SERIAL        PRIMARY KEY,
    player_id      INT           NOT NULL REFERENCES player(player_id) ON DELETE CASCADE,
    club_id        INT           NOT NULL REFERENCES club(club_id),
    start_date     DATE          NOT NULL,
    end_date       DATE          NOT NULL,
    salary_eur_pm  NUMERIC(10,2) NOT NULL CHECK (salary_eur_pm > 0),
    release_clause NUMERIC(12,2) DEFAULT NULL CHECK (release_clause > 0),
    CHECK (end_date > start_date)
);

-- ============================================================
-- 12. PLAYER_STAT  (per player per match)
-- ============================================================
CREATE TABLE player_stat (
    stat_id      SERIAL    PRIMARY KEY,
    match_id     INT       NOT NULL REFERENCES match(match_id) ON DELETE CASCADE,
    player_id    INT       NOT NULL REFERENCES player(player_id) ON DELETE CASCADE,
    goals        SMALLINT  NOT NULL DEFAULT 0 CHECK (goals >= 0),
    assists      SMALLINT  NOT NULL DEFAULT 0 CHECK (assists >= 0),
    yellow_cards SMALLINT  NOT NULL DEFAULT 0 CHECK (yellow_cards BETWEEN 0 AND 2),
    red_cards    SMALLINT  NOT NULL DEFAULT 0 CHECK (red_cards BETWEEN 0 AND 1),
    minutes_played SMALLINT NOT NULL DEFAULT 0 CHECK (minutes_played BETWEEN 0 AND 120),
    rating       NUMERIC(3,1)       CHECK (rating BETWEEN 1.0 AND 10.0),
    UNIQUE (match_id, player_id)
);

-- ============================================================
-- 13. TEAM_STAT  (aggregated per team per match)
-- ============================================================
CREATE TABLE team_stat (
    team_stat_id  SERIAL    PRIMARY KEY,
    match_id      INT       NOT NULL REFERENCES match(match_id) ON DELETE CASCADE,
    team_id       INT       NOT NULL REFERENCES team(team_id),
    possession_pct NUMERIC(4,1) CHECK (possession_pct BETWEEN 0 AND 100),
    shots_total   SMALLINT  DEFAULT 0 CHECK (shots_total >= 0),
    shots_on_target SMALLINT DEFAULT 0 CHECK (shots_on_target >= 0),
    corners       SMALLINT  DEFAULT 0 CHECK (corners >= 0),
    fouls         SMALLINT  DEFAULT 0 CHECK (fouls >= 0),
    offsides      SMALLINT  DEFAULT 0 CHECK (offsides >= 0),
    UNIQUE (match_id, team_id)
);

-- ============================================================
-- Comments on tables for documentation
-- ============================================================
COMMENT ON TABLE club         IS 'Football clubs owning one or more teams.';
COMMENT ON TABLE stadium      IS 'Venues where matches take place.';
COMMENT ON TABLE team         IS 'Competitive teams owned by a club.';
COMMENT ON TABLE position     IS 'Playing positions (GK, CB, CM, ST, …).';
COMMENT ON TABLE player       IS 'Registered players assigned to a team.';
COMMENT ON TABLE coach        IS 'Coaching staff attached to a team.';
COMMENT ON TABLE staff        IS 'Non-coaching club employees.';
COMMENT ON TABLE competition  IS 'Leagues, cups and other competitions.';
COMMENT ON TABLE season       IS 'Edition of a competition (e.g. 2023/2024).';
COMMENT ON TABLE match        IS 'Scheduled or completed fixtures.';
COMMENT ON TABLE contract     IS 'Player contracts with salary and dates.';
COMMENT ON TABLE player_stat  IS 'Individual player statistics per match.';
COMMENT ON TABLE team_stat    IS 'Team-level statistics per match.';
