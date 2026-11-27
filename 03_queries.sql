-- ============================================================
-- Football Club Database – Queries
-- File : 03_queries.sql
-- ============================================================

-- ------------------------------------------------------------
-- Q1. Basic SELECT + JOIN
--     List all players with their club name, team name and position.
-- ------------------------------------------------------------
SELECT
    p.player_id,
    p.first_name || ' ' || p.last_name   AS player_name,
    p.nationality,
    p.jersey_number,
    pos.name                              AS position,
    pos.category,
    t.name                                AS team,
    c.name                                AS club,
    p.market_value_eur
FROM   player      p
JOIN   position    pos ON pos.position_id  = p.position_id
JOIN   team        t   ON t.team_id        = p.team_id
JOIN   club        c   ON c.club_id        = t.club_id
WHERE  p.is_active = TRUE
ORDER  BY c.name, pos.category, p.last_name;

-- ------------------------------------------------------------
-- Q2. Multi-table JOIN
--     Show completed matches with scoreline, venue and competition.
-- ------------------------------------------------------------
SELECT
    co.name                               AS competition,
    s.label                               AS season,
    m.match_date::DATE                    AS match_date,
    ht.name                               AS home_team,
    m.home_goals,
    m.away_goals,
    at.name                               AS away_team,
    st.name                               AS stadium
FROM   match       m
JOIN   season      s   ON s.season_id       = m.season_id
JOIN   competition co  ON co.competition_id = s.competition_id
JOIN   team        ht  ON ht.team_id        = m.home_team_id
JOIN   team        at  ON at.team_id        = m.away_team_id
LEFT   JOIN stadium st ON st.stadium_id     = m.stadium_id
WHERE  m.status = 'Completed'
ORDER  BY m.match_date;

-- ------------------------------------------------------------
-- Q3. GROUP BY + HAVING
--     Clubs whose total squad market value exceeds 40 million EUR.
-- ------------------------------------------------------------
SELECT
    c.name                                AS club,
    COUNT(p.player_id)                    AS squad_size,
    SUM(p.market_value_eur)               AS total_market_value_eur
FROM   club   c
JOIN   team   t ON t.club_id  = c.club_id
JOIN   player p ON p.team_id  = t.team_id
WHERE  p.is_active = TRUE
GROUP  BY c.club_id, c.name
HAVING SUM(p.market_value_eur) > 40000000
ORDER  BY total_market_value_eur DESC;

-- ------------------------------------------------------------
-- Q4. Subquery – players earning above their own club's average salary
-- ------------------------------------------------------------
SELECT
    p.first_name || ' ' || p.last_name   AS player_name,
    c.name                                AS club,
    con.salary_eur_pm,
    (
        SELECT ROUND(AVG(con2.salary_eur_pm), 2)
        FROM   contract con2
        JOIN   player   p2 ON p2.player_id = con2.player_id
        JOIN   team     t2 ON t2.team_id   = p2.team_id
        WHERE  t2.club_id = t.club_id
    )                                     AS avg_club_salary_eur_pm
FROM   contract con
JOIN   player   p  ON p.player_id = con.player_id
JOIN   team     t  ON t.team_id   = p.team_id
JOIN   club     c  ON c.club_id   = t.club_id
WHERE  con.salary_eur_pm > (
    SELECT AVG(con2.salary_eur_pm)
    FROM   contract con2
    JOIN   player   p2 ON p2.player_id = con2.player_id
    JOIN   team     t2 ON t2.team_id   = p2.team_id
    WHERE  t2.club_id = t.club_id
)
ORDER  BY con.salary_eur_pm DESC;

-- ------------------------------------------------------------
-- Q5. CTE 1 – Top scorers across all completed matches
-- ------------------------------------------------------------
WITH scorer_totals AS (
    SELECT
        ps.player_id,
        p.first_name || ' ' || p.last_name  AS player_name,
        c.name                               AS club,
        SUM(ps.goals)                        AS total_goals,
        SUM(ps.assists)                      AS total_assists,
        COUNT(ps.match_id)                   AS matches_played,
        ROUND(AVG(ps.rating), 2)             AS avg_rating
    FROM   player_stat ps
    JOIN   player      p  ON p.player_id = ps.player_id
    JOIN   team        t  ON t.team_id   = p.team_id
    JOIN   club        c  ON c.club_id   = t.club_id
    GROUP  BY ps.player_id, player_name, c.name
)
SELECT *
FROM   scorer_totals
ORDER  BY total_goals DESC, total_assists DESC
LIMIT  10;

-- ------------------------------------------------------------
-- Q6. CTE 2 – Head-to-head record between FC Olympia and Sporting Riviera
-- ------------------------------------------------------------
WITH h2h AS (
    SELECT
        CASE
            WHEN m.home_goals > m.away_goals THEN m.home_team_id
            WHEN m.away_goals > m.home_goals THEN m.away_team_id
            ELSE NULL
        END                 AS winner_team_id,
        m.home_team_id,
        m.away_team_id
    FROM  match m
    WHERE m.status = 'Completed'
      AND (
            (m.home_team_id = 1 AND m.away_team_id = 3)
            OR
            (m.home_team_id = 3 AND m.away_team_id = 1)
          )
)
SELECT
    t.name                                                            AS team,
    COUNT(*)                                                          AS played,
    SUM(CASE WHEN h.winner_team_id = t.team_id THEN 1 ELSE 0 END)   AS wins,
    SUM(CASE WHEN h.winner_team_id IS NULL      THEN 1 ELSE 0 END)   AS draws,
    SUM(CASE WHEN h.winner_team_id IS NOT NULL
                  AND h.winner_team_id <> t.team_id THEN 1 ELSE 0 END) AS losses
FROM  h2h h
JOIN  team t ON t.team_id IN (h.home_team_id, h.away_team_id)
GROUP BY t.team_id, t.name
ORDER BY wins DESC;

-- ------------------------------------------------------------
-- Q7. Window function 1 – Player market-value ranking within each position category
-- ------------------------------------------------------------
SELECT
    p.first_name || ' ' || p.last_name              AS player_name,
    pos.category,
    pos.name                                         AS position,
    p.market_value_eur,
    RANK() OVER (
        PARTITION BY pos.category
        ORDER BY     p.market_value_eur DESC
    )                                                AS rank_in_category
FROM   player p
JOIN   position pos ON pos.position_id = p.position_id
WHERE  p.is_active = TRUE
ORDER  BY pos.category, rank_in_category;

-- ------------------------------------------------------------
-- Q8. Window function 2 – Running total of goals per match date
-- ------------------------------------------------------------
SELECT
    m.match_date::DATE                                              AS match_date,
    ht.name || ' vs ' || at.name                                   AS fixture,
    COALESCE(m.home_goals, 0) + COALESCE(m.away_goals, 0)         AS match_goals,
    SUM(COALESCE(m.home_goals, 0) + COALESCE(m.away_goals, 0))
        OVER (ORDER BY m.match_date
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)    AS running_total_goals
FROM   match m
JOIN   team ht ON ht.team_id = m.home_team_id
JOIN   team at ON at.team_id = m.away_team_id
WHERE  m.status = 'Completed'
ORDER  BY m.match_date;
