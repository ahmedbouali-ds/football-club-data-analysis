-- ============================================================
-- Football Club Database – Stored Procedure
-- File : 06_procedure.sql
-- ============================================================

-- ============================================================
-- PROCEDURE – register_match_result
--   Registers (or updates) the final result of a match:
--     1. Validates that the match exists and is not cancelled.
--     2. Checks both teams exist in the match.
--     3. Updates match goals and sets status to 'Completed'.
--     4. Upserts team_stat rows for home and away teams.
--     5. Raises informational notices throughout.
--
--   Parameters:
--     p_match_id       – ID of the match to update
--     p_home_goals     – Final goals scored by the home team
--     p_away_goals     – Final goals scored by the away team
--     p_home_possession– Home team possession % (0–100)
--     p_away_possession– Away team possession % (0–100)
--     p_home_shots     – Home team total shots
--     p_away_shots     – Away team total shots
--     p_home_shots_ot  – Home team shots on target
--     p_away_shots_ot  – Away team shots on target
-- ============================================================

CREATE OR REPLACE PROCEDURE register_match_result(
    p_match_id        INT,
    p_home_goals      SMALLINT,
    p_away_goals      SMALLINT,
    p_home_possession NUMERIC  DEFAULT 50.0,
    p_away_possession NUMERIC  DEFAULT 50.0,
    p_home_shots      SMALLINT DEFAULT 0,
    p_away_shots      SMALLINT DEFAULT 0,
    p_home_shots_ot   SMALLINT DEFAULT 0,
    p_away_shots_ot   SMALLINT DEFAULT 0
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_home_team_id  INT;
    v_away_team_id  INT;
    v_status        VARCHAR(20);
    v_result_label  TEXT;
BEGIN
    -- --------------------------------------------------------
    -- 1. Validate match exists and is registrable
    -- --------------------------------------------------------
    SELECT home_team_id, away_team_id, status
    INTO   v_home_team_id, v_away_team_id, v_status
    FROM   match
    WHERE  match_id = p_match_id
    FOR UPDATE;   -- lock the row during the transaction

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Match id % does not exist.', p_match_id;
    END IF;

    IF v_status = 'Cancelled' THEN
        RAISE EXCEPTION 'Match id % is cancelled and cannot be updated.', p_match_id;
    END IF;

    -- --------------------------------------------------------
    -- 2. Validate goal values
    -- --------------------------------------------------------
    IF p_home_goals < 0 OR p_away_goals < 0 THEN
        RAISE EXCEPTION 'Goal counts cannot be negative (home=%, away=%).',
                         p_home_goals, p_away_goals;
    END IF;

    IF p_home_possession + p_away_possession <> 100 THEN
        RAISE WARNING 'Possession values do not add up to 100 (%% + %% = %%).',
                       p_home_possession, p_away_possession,
                       p_home_possession + p_away_possession;
    END IF;

    -- --------------------------------------------------------
    -- 3. Determine result label
    -- --------------------------------------------------------
    IF p_home_goals > p_away_goals THEN
        v_result_label := 'Home win';
    ELSIF p_away_goals > p_home_goals THEN
        v_result_label := 'Away win';
    ELSE
        v_result_label := 'Draw';
    END IF;

    RAISE NOTICE 'Registering result for match %: % - % (%)',
                  p_match_id, p_home_goals, p_away_goals, v_result_label;

    -- --------------------------------------------------------
    -- 4. Update match record
    -- --------------------------------------------------------
    UPDATE match
    SET    home_goals = p_home_goals,
           away_goals = p_away_goals,
           status     = 'Completed'
    WHERE  match_id   = p_match_id;

    -- --------------------------------------------------------
    -- 5. Upsert team_stat for home team
    -- --------------------------------------------------------
    INSERT INTO team_stat
        (match_id, team_id, possession_pct, shots_total, shots_on_target)
    VALUES
        (p_match_id, v_home_team_id, p_home_possession, p_home_shots, p_home_shots_ot)
    ON CONFLICT (match_id, team_id)
    DO UPDATE SET
        possession_pct  = EXCLUDED.possession_pct,
        shots_total     = EXCLUDED.shots_total,
        shots_on_target = EXCLUDED.shots_on_target;

    -- --------------------------------------------------------
    -- 6. Upsert team_stat for away team
    -- --------------------------------------------------------
    INSERT INTO team_stat
        (match_id, team_id, possession_pct, shots_total, shots_on_target)
    VALUES
        (p_match_id, v_away_team_id, p_away_possession, p_away_shots, p_away_shots_ot)
    ON CONFLICT (match_id, team_id)
    DO UPDATE SET
        possession_pct  = EXCLUDED.possession_pct,
        shots_total     = EXCLUDED.shots_total,
        shots_on_target = EXCLUDED.shots_on_target;

    RAISE NOTICE 'Match % successfully registered as Completed.', p_match_id;
END;
$$;

-- ============================================================
-- Usage examples:
-- ============================================================

-- Register the scheduled match (match_id = 9) as a 2-0 home win:
-- CALL register_match_result(
--     9,           -- match_id
--     2::SMALLINT, -- home_goals
--     0::SMALLINT, -- away_goals
--     58.5,        -- home possession %
--     41.5,        -- away possession %
--     15::SMALLINT,-- home shots
--     8::SMALLINT, -- away shots
--     6::SMALLINT, -- home shots on target
--     3::SMALLINT  -- away shots on target
-- );

-- Verify the result:
-- SELECT match_id, home_goals, away_goals, status FROM match WHERE match_id = 9;
-- SELECT * FROM team_stat WHERE match_id = 9;
