-- ============================================================
-- Football Club Database – Triggers
-- File : 07_triggers.sql
-- ============================================================

-- ============================================================
-- TRIGGER 1 – trg_validate_contract_dates
--   BEFORE INSERT OR UPDATE on contract.
--   Ensures:
--     a) end_date > start_date  (also enforced by CHECK, but
--        this trigger provides a descriptive error message).
--     b) The player is not already under contract for an
--        overlapping period with the same club.
-- ============================================================

CREATE OR REPLACE FUNCTION fn_validate_contract_dates()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_overlap_count INT;
BEGIN
    -- (a) Basic date sanity
    IF NEW.end_date <= NEW.start_date THEN
        RAISE EXCEPTION
            'Contract end_date (%) must be after start_date (%) for player id %.',
            NEW.end_date, NEW.start_date, NEW.player_id;
    END IF;

    -- (b) Overlapping contract guard (same player, same club)
    SELECT COUNT(*)
    INTO   v_overlap_count
    FROM   contract
    WHERE  player_id   = NEW.player_id
      AND  club_id     = NEW.club_id
      AND  contract_id <> COALESCE(NEW.contract_id, -1)   -- exclude self on UPDATE
      AND  daterange(start_date, end_date, '[]')
           && daterange(NEW.start_date, NEW.end_date, '[]');

    IF v_overlap_count > 0 THEN
        RAISE EXCEPTION
            'Player id % already has an overlapping contract with club id % in the period % to %.',
            NEW.player_id, NEW.club_id, NEW.start_date, NEW.end_date;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_validate_contract_dates ON contract;

CREATE TRIGGER trg_validate_contract_dates
BEFORE INSERT OR UPDATE ON contract
FOR EACH ROW
EXECUTE FUNCTION fn_validate_contract_dates();

-- ============================================================
-- TRIGGER 2 – trg_update_match_status_on_stat_insert
--   AFTER INSERT on player_stat.
--   When a player stat row is added for a match that is still
--   'Scheduled', automatically set the match status to
--   'In Progress'.  This simulates a live-data pipeline
--   updating match state as events are logged.
--   Also validates that the player belongs to one of the two
--   competing teams before allowing the insert.
-- ============================================================

CREATE OR REPLACE FUNCTION fn_update_match_status_on_stat_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_home_team_id  INT;
    v_away_team_id  INT;
    v_player_team   INT;
    v_match_status  VARCHAR(20);
BEGIN
    -- Fetch match details
    SELECT home_team_id, away_team_id, status
    INTO   v_home_team_id, v_away_team_id, v_match_status
    FROM   match
    WHERE  match_id = NEW.match_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'match_id % does not exist.', NEW.match_id;
    END IF;

    -- Validate player belongs to one of the two teams
    SELECT team_id
    INTO   v_player_team
    FROM   player
    WHERE  player_id = NEW.player_id;

    IF v_player_team IS NULL OR
       v_player_team NOT IN (v_home_team_id, v_away_team_id) THEN
        RAISE EXCEPTION
            'Player id % (team %) is not part of match % (home team %, away team %).',
            NEW.player_id, v_player_team,
            NEW.match_id, v_home_team_id, v_away_team_id;
    END IF;

    -- Advance match status from Scheduled → In Progress
    IF v_match_status = 'Scheduled' THEN
        UPDATE match
        SET    status = 'In Progress'
        WHERE  match_id = NEW.match_id;

        RAISE NOTICE 'Match % status changed from Scheduled to In Progress.', NEW.match_id;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_update_match_status_on_stat_insert ON player_stat;

CREATE TRIGGER trg_update_match_status_on_stat_insert
AFTER INSERT ON player_stat
FOR EACH ROW
EXECUTE FUNCTION fn_update_match_status_on_stat_insert();

-- ============================================================
-- Trigger validation examples
-- ============================================================

-- Test trigger 1 – overlapping contract (should RAISE EXCEPTION):
-- INSERT INTO contract (player_id, club_id, start_date, end_date, salary_eur_pm)
-- VALUES (10, 1, '2022-01-01', '2024-12-31', 50000);
-- Expected: ERROR – player 10 already has an overlapping contract with club 1.

-- Test trigger 2 – inserting a stat for a scheduled match
-- (match_id 9 is 'Scheduled'); player 1 is on team 1 (home):
-- INSERT INTO player_stat (match_id, player_id, goals, assists, minutes_played)
-- VALUES (9, 1, 0, 0, 45);
-- Expected: NOTICE – Match 9 status changed from Scheduled to In Progress.
-- SELECT status FROM match WHERE match_id = 9;  -- should return 'In Progress'
