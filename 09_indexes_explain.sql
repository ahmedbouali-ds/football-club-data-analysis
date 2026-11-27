-- ============================================================
-- Football Club Database – Indexes & Query Plans
-- File : 09_indexes_explain.sql
-- ============================================================

-- ============================================================
-- 1. INDEXES
-- ============================================================

-- Index 1 – Speed up lookups of players by team
--   Queries joining player → team (very frequent) benefit from
--   avoiding a sequential scan on a large player table.
CREATE INDEX IF NOT EXISTS idx_player_team_id
    ON player (team_id);

-- Index 2 – Speed up filtering players by nationality
--   Commonly used in scouting and reporting queries.
CREATE INDEX IF NOT EXISTS idx_player_nationality
    ON player (nationality);

-- Index 3 – Speed up match lookups by season and status
--   Composite index serves queries that filter completed/scheduled
--   matches within a season (the most common app query pattern).
CREATE INDEX IF NOT EXISTS idx_match_season_status
    ON match (season_id, status);

-- Index 4 – Speed up match lookups by date range
--   Calendar and fixture-list queries always filter by date.
CREATE INDEX IF NOT EXISTS idx_match_date
    ON match (match_date DESC);

-- Index 5 – Speed up player_stat aggregations per match
CREATE INDEX IF NOT EXISTS idx_player_stat_match_id
    ON player_stat (match_id);

-- Index 6 – Speed up player_stat aggregations per player
--   Used heavily by get_player_match_stats() and scorer CTEs.
CREATE INDEX IF NOT EXISTS idx_player_stat_player_id
    ON player_stat (player_id);

-- Index 7 – Speed up contract lookups per player
CREATE INDEX IF NOT EXISTS idx_contract_player_id
    ON contract (player_id);

-- Index 8 – Partial index: only active players
--   Most player queries filter is_active = TRUE; this partial
--   index is smaller and faster than a full index.
CREATE INDEX IF NOT EXISTS idx_player_active
    ON player (team_id, position_id)
    WHERE is_active = TRUE;

-- ============================================================
-- 2. EXPLAIN ANALYZE examples
--    (Run after schema + data + indexes are loaded.)
-- ============================================================

-- -------------------------------------------------------
-- Plan A – Player list with club: benefits from idx_player_team_id
-- -------------------------------------------------------
EXPLAIN ANALYZE
SELECT
    p.first_name || ' ' || p.last_name AS player_name,
    p.nationality,
    pos.name  AS position,
    c.name    AS club
FROM   player   p
JOIN   position pos ON pos.position_id = p.position_id
JOIN   team     t   ON t.team_id       = p.team_id
JOIN   club     c   ON c.club_id       = t.club_id
WHERE  p.is_active = TRUE
ORDER  BY c.name, p.last_name;

-- -------------------------------------------------------
-- Plan B – Completed matches in a season: uses idx_match_season_status
-- -------------------------------------------------------
EXPLAIN ANALYZE
SELECT
    m.match_id,
    m.match_date,
    m.home_goals,
    m.away_goals
FROM   match m
WHERE  m.season_id = 1
  AND  m.status    = 'Completed'
ORDER  BY m.match_date;

-- -------------------------------------------------------
-- Plan C – Top-scorer aggregation: uses idx_player_stat_player_id
-- -------------------------------------------------------
EXPLAIN ANALYZE
SELECT
    p.first_name || ' ' || p.last_name AS player_name,
    SUM(ps.goals)   AS total_goals,
    SUM(ps.assists) AS total_assists
FROM   player_stat ps
JOIN   player      p ON p.player_id = ps.player_id
GROUP  BY p.player_id, player_name
ORDER  BY total_goals DESC;

-- -------------------------------------------------------
-- Plan D – Contract lookup per player: uses idx_contract_player_id
-- -------------------------------------------------------
EXPLAIN ANALYZE
SELECT *
FROM   contract
WHERE  player_id = 10
  AND  end_date  > CURRENT_DATE;

-- ============================================================
-- 3. Viewing existing indexes
-- ============================================================

-- List all indexes on our tables:
-- SELECT
--     schemaname,
--     tablename,
--     indexname,
--     indexdef
-- FROM   pg_indexes
-- WHERE  schemaname = 'public'
-- ORDER  BY tablename, indexname;
