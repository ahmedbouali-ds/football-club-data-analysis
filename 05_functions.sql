-- ============================================================
-- Football Club Database – Functions
-- File : 05_functions.sql
-- ============================================================

-- ============================================================
-- FUNCTION 1 – get_player_age(player_id)
--   Returns the current age of a player in years.
--   Demonstrates: parameters, variables, SELECT INTO, IF/ELSE,
--                 RAISE EXCEPTION.
-- ============================================================
CREATE OR REPLACE FUNCTION get_player_age(p_player_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_dob  DATE;
    v_age  INT;
BEGIN
    -- Retrieve date of birth
    SELECT date_of_birth
    INTO   v_dob
    FROM   player
    WHERE  player_id = p_player_id;

    -- Guard: player not found
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Player with id % does not exist.', p_player_id;
    END IF;

    -- Calculate age
    v_age := DATE_PART('year', AGE(CURRENT_DATE, v_dob))::INT;

    IF v_age < 0 THEN
        RAISE EXCEPTION 'Calculated age is negative – check date_of_birth for player %.', p_player_id;
    END IF;

    RETURN v_age;
END;
$$;

-- Usage example:
-- SELECT get_player_age(1);
-- SELECT player_id, first_name || ' ' || last_name AS name, get_player_age(player_id) AS age
-- FROM   player WHERE is_active = TRUE ORDER BY age;


-- ============================================================
-- FUNCTION 2 – get_club_squad_summary(p_club_id)
--   RETURNS TABLE with one row per position category showing
--   headcount and average market value.
--   Demonstrates: RETURNS TABLE, parameters, variables,
--                 SELECT INTO, IF/ELSE, RETURN QUERY.
-- ============================================================
CREATE OR REPLACE FUNCTION get_club_squad_summary(p_club_id INT)
RETURNS TABLE (
    category          TEXT,
    player_count      BIGINT,
    avg_market_value  NUMERIC,
    total_value       NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_club_name  VARCHAR(100);
    v_count      INT;
BEGIN
    -- Check club exists
    SELECT name, COUNT(p.player_id)
    INTO   v_club_name, v_count
    FROM   club c
    LEFT   JOIN team   t ON t.club_id   = c.club_id
    LEFT   JOIN player p ON p.team_id   = t.team_id AND p.is_active = TRUE
    WHERE  c.club_id = p_club_id
    GROUP  BY c.name;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Club with id % not found.', p_club_id;
    END IF;

    IF v_count = 0 THEN
        RAISE NOTICE 'Club "%" (id=%) has no active players registered.', v_club_name, p_club_id;
    END IF;

    -- Return summary rows grouped by position category
    RETURN QUERY
    SELECT
        pos.category::TEXT,
        COUNT(p.player_id)                       AS player_count,
        ROUND(AVG(p.market_value_eur), 2)        AS avg_market_value,
        COALESCE(SUM(p.market_value_eur), 0)     AS total_value
    FROM   club     c
    JOIN   team     t   ON t.club_id    = c.club_id
    JOIN   player   p   ON p.team_id    = t.team_id AND p.is_active = TRUE
    JOIN   position pos ON pos.position_id = p.position_id
    WHERE  c.club_id = p_club_id
    GROUP  BY pos.category
    ORDER  BY pos.category;
END;
$$;

-- Usage example:
-- SELECT * FROM get_club_squad_summary(1);
-- SELECT * FROM get_club_squad_summary(5);


-- ============================================================
-- FUNCTION 3 – get_player_match_stats(p_player_id, p_season_id)
--   Returns per-match performance rows for a given player
--   within a given season.
--   Demonstrates: RETURNS TABLE, multiple parameters, variables,
--                 SELECT INTO for existence check, IF/ELSE,
--                 RETURN QUERY with JOINs.
-- ============================================================
CREATE OR REPLACE FUNCTION get_player_match_stats(
    p_player_id  INT,
    p_season_id  INT DEFAULT NULL   -- NULL = all seasons
)
RETURNS TABLE (
    match_date        DATE,
    home_team         TEXT,
    away_team         TEXT,
    score             TEXT,
    goals             SMALLINT,
    assists           SMALLINT,
    yellow_cards      SMALLINT,
    red_cards         SMALLINT,
    minutes_played    SMALLINT,
    rating            NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_player_name  TEXT;
    v_season_label TEXT;
BEGIN
    -- Verify player exists
    SELECT first_name || ' ' || last_name
    INTO   v_player_name
    FROM   player
    WHERE  player_id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Player id % does not exist.', p_player_id;
    END IF;

    -- Verify season if supplied
    IF p_season_id IS NOT NULL THEN
        SELECT label
        INTO   v_season_label
        FROM   season
        WHERE  season_id = p_season_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Season id % does not exist.', p_season_id;
        END IF;

        RAISE NOTICE 'Returning stats for player "%" in season "%".',
                      v_player_name, v_season_label;
    ELSE
        RAISE NOTICE 'Returning all-season stats for player "%".', v_player_name;
    END IF;

    -- Return match-by-match rows
    RETURN QUERY
    SELECT
        m.match_date::DATE,
        ht.name::TEXT                                        AS home_team,
        at.name::TEXT                                        AS away_team,
        (COALESCE(m.home_goals::TEXT,'?') || ' - ' ||
         COALESCE(m.away_goals::TEXT,'?'))                   AS score,
        ps.goals,
        ps.assists,
        ps.yellow_cards,
        ps.red_cards,
        ps.minutes_played,
        ps.rating
    FROM   player_stat ps
    JOIN   match  m  ON m.match_id  = ps.match_id
    JOIN   team   ht ON ht.team_id  = m.home_team_id
    JOIN   team   at ON at.team_id  = m.away_team_id
    WHERE  ps.player_id = p_player_id
      AND  (p_season_id IS NULL OR m.season_id = p_season_id)
    ORDER  BY m.match_date;
END;
$$;

-- Usage examples:
-- SELECT * FROM get_player_match_stats(10);
-- SELECT * FROM get_player_match_stats(39, 3);
