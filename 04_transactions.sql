-- ============================================================
-- Football Club Database – Transactions
-- File : 04_transactions.sql
-- ============================================================

-- ============================================================
-- TRANSACTION 1 – Player Transfer (COMMIT)
--   Transfer Gonçalo Neves (player_id = 10) from FC Olympia (club 1)
--   to City United (club 5) mid-season.
--   Steps:
--     a) End the existing contract early
--     b) Insert a new contract with the destination club
--     c) Move the player to the new team
-- ============================================================

BEGIN;

-- a) Mark existing contract as ended (today's date = transfer date)
UPDATE contract
SET    end_date = CURRENT_DATE
WHERE  player_id = 10
  AND  club_id   = 1
  AND  end_date  > CURRENT_DATE;

-- b) Create new contract at City United
INSERT INTO contract (player_id, club_id, start_date, end_date, salary_eur_pm, release_clause)
VALUES (10, 5, CURRENT_DATE, CURRENT_DATE + INTERVAL '4 years', 90000, 30000000);

-- c) Reassign player to City United's First Team (team_id = 6)
--    (clear jersey first to avoid unique conflict, then assign)
UPDATE player
SET    team_id       = 6,
       jersey_number = NULL
WHERE  player_id = 10;

-- Assign a free jersey number (e.g., 19) on the new team
UPDATE player
SET    jersey_number = 19
WHERE  player_id = 10;

COMMIT;

-- Verify the transfer
SELECT
    p.first_name || ' ' || p.last_name   AS player,
    t.name                                AS current_team,
    c.name                                AS current_club,
    p.jersey_number,
    con.salary_eur_pm,
    con.start_date,
    con.end_date
FROM   player    p
JOIN   team      t   ON t.team_id    = p.team_id
JOIN   club      c   ON c.club_id    = t.club_id
JOIN   contract  con ON con.player_id = p.player_id
WHERE  p.player_id = 10
  AND  con.end_date > CURRENT_DATE;


-- ============================================================
-- TRANSACTION 2 – Match Registration with Rollback example
--   Attempt to register a match where the two teams are the same
--   (violates the CHECK constraint).  The transaction is rolled back.
-- ============================================================

BEGIN;

-- This INSERT should FAIL because home_team_id = away_team_id
-- which violates CHECK (home_team_id <> away_team_id)
DO $$
BEGIN
    INSERT INTO match (season_id, home_team_id, away_team_id, match_date, status)
    VALUES (1, 1, 1, NOW(), 'Scheduled');   -- same team on both sides!

    RAISE NOTICE 'INSERT succeeded (unexpected)';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'CHECK constraint caught: a team cannot play itself. Rolling back.';
    ROLLBACK;
END
$$;

ROLLBACK;   -- explicit rollback to be safe


-- ============================================================
-- TRANSACTION 3 – Budget deduction after transfer fee (COMMIT)
--   When a club buys a player, deduct the transfer fee from budget.
-- ============================================================

BEGIN;

-- Declare transfer fee
DO $$
DECLARE
    v_fee           NUMERIC := 15000000;  -- 15 M EUR
    v_buying_club   INT     := 5;         -- City United
    v_current_budget NUMERIC;
BEGIN
    -- Lock the row for update
    SELECT budget_eur
    INTO   v_current_budget
    FROM   club
    WHERE  club_id = v_buying_club
    FOR UPDATE;

    IF v_current_budget < v_fee THEN
        RAISE EXCEPTION 'Insufficient budget: % EUR available, % EUR required',
                         v_current_budget, v_fee;
    END IF;

    UPDATE club
    SET    budget_eur = budget_eur - v_fee
    WHERE  club_id = v_buying_club;

    RAISE NOTICE 'Transfer fee of % EUR deducted. New budget: % EUR',
                  v_fee, v_current_budget - v_fee;
END
$$;

COMMIT;

-- Confirm new budget
SELECT name, budget_eur FROM club WHERE club_id = 5;
