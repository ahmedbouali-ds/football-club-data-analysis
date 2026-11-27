-- ============================================================
-- Football Club Database – Test Data
-- File : 02_insert_test_data.sql
-- ============================================================

-- ============================================================
-- CLUBS  (6)
-- ============================================================
INSERT INTO club (name, country, founded_year, budget_eur, website) VALUES
  ('FC Olympia',        'Portugal',  1905, 85000000,  'https://fcolympia.pt'),
  ('Sporting Riviera',  'Portugal',  1921, 62000000,  'https://sportingriviera.pt'),
  ('Atletico Norteño',  'Spain',     1932, 110000000, 'https://atleticonorteno.es'),
  ('Dynamo Brücke',     'Germany',   1948, 78000000,  'https://dynamobrucke.de'),
  ('City United',       'England',   1899, 200000000, 'https://cityunited.co.uk'),
  ('AS Meridionale',    'Italy',     1911, 95000000,  'https://asmeridionale.it');

-- ============================================================
-- STADIUMS  (6)
-- ============================================================
INSERT INTO stadium (name, city, country, capacity, surface) VALUES
  ('Estádio do Olimpo',     'Lisbon',     'Portugal', 52000, 'Grass'),
  ('Riviera Arena',         'Porto',      'Portugal', 34500, 'Hybrid'),
  ('Estadio Norte',         'Bilbao',     'Spain',    48000, 'Grass'),
  ('Brücke Stadion',        'Munich',     'Germany',  57000, 'Artificial'),
  ('United Park',           'Manchester', 'England',  76000, 'Grass'),
  ('Stadio del Sud',        'Naples',     'Italy',    41000, 'Grass');

-- ============================================================
-- TEAMS  (one First Team per club + 1 reserve)
-- ============================================================
INSERT INTO team (club_id, stadium_id, name, type) VALUES
  (1, 1, 'FC Olympia First Team',       'First Team'),
  (1, 1, 'FC Olympia Reserve',          'Reserve'),
  (2, 2, 'Sporting Riviera First Team', 'First Team'),
  (3, 3, 'Atletico Norteño First Team', 'First Team'),
  (4, 4, 'Dynamo Brücke First Team',    'First Team'),
  (5, 5, 'City United First Team',      'First Team'),
  (6, 6, 'AS Meridionale First Team',   'First Team');

-- ============================================================
-- POSITIONS  (11 standard positions)
-- ============================================================
INSERT INTO position (name, abbreviation, category) VALUES
  ('Goalkeeper',          'GK',  'Goalkeeper'),
  ('Centre-Back',         'CB',  'Defender'),
  ('Left-Back',           'LB',  'Defender'),
  ('Right-Back',          'RB',  'Defender'),
  ('Defensive Midfielder','DM',  'Midfielder'),
  ('Central Midfielder',  'CM',  'Midfielder'),
  ('Attacking Midfielder','AM',  'Midfielder'),
  ('Left Winger',         'LW',  'Forward'),
  ('Right Winger',        'RW',  'Forward'),
  ('Centre-Forward',      'CF',  'Forward'),
  ('Second Striker',      'SS',  'Forward');

-- ============================================================
-- PLAYERS  (50 players spread across teams)
-- ============================================================
INSERT INTO player (team_id, position_id, first_name, last_name, date_of_birth, nationality, jersey_number, market_value_eur, is_active) VALUES
-- FC Olympia (team 1) – 10 players
  (1,  1, 'Diogo',    'Ferreira',   '1995-03-14', 'Portuguese', 1,  3500000, TRUE),
  (1,  2, 'Ricardo',  'Mendes',     '1997-08-22', 'Portuguese', 4,  4200000, TRUE),
  (1,  3, 'Tiago',    'Sousa',      '1999-01-05', 'Portuguese', 3,  2800000, TRUE),
  (1,  4, 'Bruno',    'Carvalho',   '1998-11-17', 'Portuguese', 2,  3100000, TRUE),
  (1,  5, 'André',    'Pinto',      '1996-06-30', 'Portuguese', 6,  5000000, TRUE),
  (1,  6, 'Miguel',   'Lopes',      '1993-09-12', 'Portuguese', 8,  4700000, TRUE),
  (1,  7, 'Fábio',    'Rodrigues',  '2001-04-18', 'Portuguese', 10, 8500000, TRUE),
  (1,  8, 'Renato',   'Almeida',    '2000-02-27', 'Portuguese', 11, 7200000, TRUE),
  (1,  9, 'Rúben',    'Gomes',      '1998-07-03', 'Portuguese', 7,  6800000, TRUE),
  (1, 10, 'Gonçalo',  'Neves',      '1997-12-01', 'Portuguese', 9, 15000000, TRUE),
-- Sporting Riviera (team 3) – 8 players
  (3,  1, 'Pedro',    'Costa',      '1994-05-19', 'Portuguese', 1,  2500000, TRUE),
  (3,  2, 'João',     'Martins',    '1999-10-08', 'Portuguese', 5,  3300000, TRUE),
  (3,  6, 'Luís',     'Barbosa',    '2000-03-25', 'Portuguese', 8,  4100000, TRUE),
  (3, 10, 'Dário',    'Magalhães',  '1996-07-14', 'Portuguese', 9, 11000000, TRUE),
  (3,  9, 'Carlos',   'Figueiredo', '2002-01-09', 'Portuguese', 7,  5500000, TRUE),
  (3,  8, 'Mário',    'Teixeira',   '1998-04-30', 'Portuguese', 11, 4800000, TRUE),
  (3,  5, 'Hélder',   'Cunha',      '1997-09-21', 'Portuguese', 6,  3900000, TRUE),
  (3,  4, 'Sérgio',   'Vieira',     '2001-06-17', 'Portuguese', 2,  2700000, TRUE),
-- Atletico Norteño (team 4) – 8 players
  (4,  1, 'Alejandro','García',     '1993-02-11', 'Spanish',    1,  4000000, TRUE),
  (4,  2, 'Javier',   'Ruiz',       '1998-08-05', 'Spanish',    4,  5500000, TRUE),
  (4,  6, 'Pablo',    'Molina',     '1997-03-20', 'Spanish',    8,  6200000, TRUE),
  (4, 10, 'Diego',    'Santos',     '1994-11-28', 'Spanish',    9, 22000000, TRUE),
  (4,  8, 'Sergio',   'López',      '2001-05-13', 'Spanish',    11, 9500000, TRUE),
  (4,  7, 'Raúl',     'Fernández',  '2000-09-07', 'Spanish',    10,12000000, TRUE),
  (4,  3, 'Iñaki',    'Zubieta',    '1999-01-24', 'Spanish',    3,  3800000, TRUE),
  (4,  5, 'Marcos',   'Herrera',    '1996-06-16', 'Spanish',    6,  4500000, TRUE),
-- Dynamo Brücke (team 5) – 7 players
  (5,  1, 'Klaus',    'Bauer',      '1992-04-03', 'German',     1,  3200000, TRUE),
  (5,  2, 'Franz',    'Müller',     '1998-12-19', 'German',     4,  4800000, TRUE),
  (5,  6, 'Stefan',   'Schneider',  '1997-07-08', 'German',     8,  5300000, TRUE),
  (5, 10, 'Lukas',    'Wagner',     '1995-02-22', 'German',     9, 18000000, TRUE),
  (5,  9, 'Tobias',   'Fischer',    '2000-10-11', 'German',     7,  7800000, TRUE),
  (5,  7, 'Maximilian','Weber',     '2001-03-30', 'German',     10, 9200000, TRUE),
  (5,  5, 'Heinrich', 'Schmidt',    '1999-08-14', 'German',     6,  4100000, TRUE),
-- City United (team 6) – 10 players
  (6,  1, 'Jack',     'Thompson',   '1991-06-25', 'English',    1,  5000000, TRUE),
  (6,  2, 'Oliver',   'Harris',     '1998-01-14', 'English',    5,  7500000, TRUE),
  (6,  3, 'Harry',    'Wilson',     '1999-04-09', 'English',    3,  6200000, TRUE),
  (6,  4, 'George',   'Clarke',     '1997-11-02', 'English',    2,  5800000, TRUE),
  (6,  6, 'Liam',     'Robinson',   '1996-08-18', 'English',    8, 11000000, TRUE),
  (6,  7, 'Noah',     'Davies',     '2000-03-07', 'English',    10,16000000, TRUE),
  (6,  8, 'Ethan',    'Evans',      '2001-07-23', 'English',    11,12500000, TRUE),
  (6,  9, 'James',    'Turner',     '1998-09-30', 'English',    7,  9800000, TRUE),
  (6, 10, 'William',  'Brooks',     '1994-05-15', 'English',    9, 30000000, TRUE),
  (6,  5, 'Thomas',   'Foster',     '1999-12-04', 'English',    6,  8200000, TRUE),
-- AS Meridionale (team 7) – 7 players
  (7,  1, 'Lorenzo',  'Rossi',      '1993-03-17', 'Italian',    1,  4500000, TRUE),
  (7,  2, 'Marco',    'Ferrari',    '1999-06-28', 'Italian',    4,  6000000, TRUE),
  (7,  6, 'Matteo',   'Esposito',   '1998-01-13', 'Italian',    8,  7200000, TRUE),
  (7, 10, 'Luca',     'Romano',     '1996-09-05', 'Italian',    9, 20000000, TRUE),
  (7,  8, 'Alessandro','Conti',     '2001-04-21', 'Italian',    11,10000000, TRUE),
  (7,  7, 'Davide',   'Ricci',      '2000-11-10', 'Italian',    10,13500000, TRUE),
  (7,  5, 'Gabriele', 'Marino',     '1997-07-19', 'Italian',    6,  5500000, TRUE);

-- ============================================================
-- COACHES  (7)
-- ============================================================
INSERT INTO coach (team_id, first_name, last_name, nationality, role, hired_date) VALUES
  (1, 'Paulo',    'Saraiva',   'Portuguese', 'Head Coach',      '2022-06-01'),
  (1, 'Nuno',     'Esteves',   'Portuguese', 'Assistant Coach', '2022-06-01'),
  (3, 'Vitor',    'Azevedo',   'Portuguese', 'Head Coach',      '2021-05-15'),
  (4, 'Roberto',  'Castillo',  'Spanish',    'Head Coach',      '2023-01-10'),
  (5, 'Dirk',     'Hoffmann',  'German',     'Head Coach',      '2020-07-01'),
  (6, 'Michael',  'Lawson',    'English',    'Head Coach',      '2019-09-01'),
  (7, 'Antonio',  'De Luca',   'Italian',    'Head Coach',      '2022-11-20');

-- ============================================================
-- STAFF  (6)
-- ============================================================
INSERT INTO staff (club_id, first_name, last_name, role, department) VALUES
  (1, 'Ana',     'Pereira',   'Club Director',       'Management'),
  (1, 'Carlos',  'Batista',   'Team Doctor',         'Medical'),
  (2, 'Sofia',   'Monteiro',  'Physiotherapist',     'Medical'),
  (5, 'Emma',    'White',     'Head of Scouting',    'Scouting'),
  (5, 'James',   'Murray',    'Financial Controller','Finance'),
  (6, 'Giulia',  'Bianchi',   'Marketing Director',  'Marketing');

-- ============================================================
-- COMPETITIONS  (4)
-- ============================================================
INSERT INTO competition (name, type, country, tier) VALUES
  ('Primeira Liga',          'League',        'Portugal',     1),
  ('La Liga',                'League',        'Spain',        1),
  ('UEFA Champions League',  'International', NULL,           1),
  ('Taça de Portugal',       'Cup',           'Portugal',     1);

-- ============================================================
-- SEASONS  (3)
-- ============================================================
INSERT INTO season (competition_id, label, start_date, end_date) VALUES
  (1, '2023/2024', '2023-08-05', '2024-05-19'),
  (2, '2023/2024', '2023-08-11', '2024-05-26'),
  (3, '2023/2024', '2023-09-19', '2024-06-01');

-- ============================================================
-- MATCHES  (10)
-- ============================================================
INSERT INTO match (season_id, stadium_id, home_team_id, away_team_id, match_date, home_goals, away_goals, status) VALUES
  (1, 1, 1, 3, '2023-09-02 19:00:00+00', 2, 1, 'Completed'),
  (1, 2, 3, 1, '2023-10-21 20:15:00+00', 0, 0, 'Completed'),
  (1, 1, 1, 3, '2024-02-17 18:00:00+00', 3, 2, 'Completed'),
  (1, 2, 3, 1, '2024-04-06 19:30:00+00', 1, 1, 'Completed'),
  (2, 3, 4, 5, '2023-09-16 21:00:00+00', 4, 1, 'Completed'),
  (2, 4, 5, 4, '2024-01-20 18:30:00+00', 2, 2, 'Completed'),
  (3, 5, 6, 7, '2023-10-04 20:00:00+00', 1, 0, 'Completed'),
  (3, 6, 7, 6, '2023-10-25 20:00:00+00', 2, 3, 'Completed'),
  (1, 1, 1, 3, '2024-08-10 20:00:00+00', NULL, NULL, 'Scheduled'),
  (3, 5, 6, 4, '2024-04-15 20:00:00+00', 2, 0, 'Completed');

-- ============================================================
-- CONTRACTS  (10)
-- ============================================================
INSERT INTO contract (player_id, club_id, start_date, end_date, salary_eur_pm, release_clause) VALUES
  (10, 1, '2021-07-01', '2025-06-30', 55000,  18000000),
  (21, 3, '2022-01-01', '2026-06-30', 42000,  13000000),
  (24, 4, '2020-07-01', '2024-06-30', 80000,  25000000),
  (32, 5, '2023-07-01', '2027-06-30', 68000,  20000000),
  (39, 6, '2019-07-01', '2025-06-30', 160000, 40000000),
  (45, 7, '2021-07-01', '2025-06-30', 90000,  25000000),
  ( 7, 1, '2022-06-01', '2026-05-31', 32000,  10000000),
  (18, 3, '2023-01-01', '2027-12-31', 35000,   9000000),
  (31, 5, '2022-07-01', '2026-06-30', 85000,  22000000),
  (48, 7, '2023-07-01', '2027-06-30', 60000,  16000000);

-- ============================================================
-- PLAYER STATS  (sample for completed matches)
-- ============================================================
INSERT INTO player_stat (match_id, player_id, goals, assists, yellow_cards, red_cards, minutes_played, rating) VALUES
-- Match 1: FC Olympia 2-1 Sporting Riviera
  (1, 10, 2, 0, 0, 0, 90, 8.5),
  (1,  7, 0, 2, 1, 0, 90, 7.2),
  (1, 14, 1, 0, 0, 0, 82, 6.8),
-- Match 3: FC Olympia 3-2 Sporting Riviera
  (3, 10, 1, 1, 0, 0, 90, 8.0),
  (3,  8, 2, 0, 0, 0, 90, 7.8),
  (3, 14, 2, 0, 1, 0, 75, 6.5),
-- Match 5: Atletico Norteño 4-1 Dynamo Brücke
  (5, 24, 2, 1, 0, 0, 90, 9.0),
  (5, 26, 1, 0, 0, 0, 88, 7.5),
  (5, 32, 1, 0, 1, 0, 90, 6.9),
-- Match 7: City United 1-0 AS Meridionale
  (7, 39, 1, 0, 0, 0, 90, 8.2),
  (7, 37, 0, 1, 0, 0, 90, 7.1),
  (7, 45, 0, 0, 0, 0, 90, 6.4),
-- Match 8: AS Meridionale 2-3 City United
  (8, 45, 1, 0, 0, 0, 90, 7.0),
  (8, 48, 1, 1, 0, 0, 90, 7.3),
  (8, 39, 2, 0, 0, 0, 90, 8.8),
-- Match 10: City United 2-0 Atletico Norteño
  (10, 39, 1, 1, 0, 0, 90, 8.4),
  (10, 36, 1, 0, 0, 0, 78, 7.2),
  (10, 24, 0, 0, 1, 0, 90, 6.1);

-- ============================================================
-- TEAM STATS
-- ============================================================
INSERT INTO team_stat (match_id, team_id, possession_pct, shots_total, shots_on_target, corners, fouls, offsides) VALUES
  (1, 1, 56.0, 14, 7, 6, 10, 2),
  (1, 3, 44.0, 10, 5, 3, 12, 3),
  (3, 1, 61.0, 18, 9, 8,  9, 1),
  (3, 3, 39.0, 12, 6, 4, 11, 4),
  (5, 4, 64.0, 22,12, 9,  7, 0),
  (5, 5, 36.0,  8, 4, 2, 15, 5),
  (7, 6, 55.0, 13, 5, 5,  8, 2),
  (7, 7, 45.0,  9, 4, 3, 13, 1),
  (8, 7, 48.0, 16, 8, 6, 10, 3),
  (8, 6, 52.0, 14, 7, 4,  9, 2),
  (10,6, 59.0, 17, 8, 7,  8, 1),
  (10,4, 41.0,  9, 3, 2, 14, 4);
