Football Club Database – PostgreSQL Project
==========================================

Execution Order:
  1. sql/01_create_schema.sql        – Creates all 13 tables with PK/FK/CHECK/UNIQUE constraints
  2. sql/02_insert_test_data.sql     – Inserts realistic test data (50 players, 10 matches, etc.)
  3. sql/03_queries.sql              – 8 queries: JOINs, GROUP BY, subquery, 2 CTEs, 2 window functions
  4. sql/04_transactions.sql         – 3 transactions: transfer (COMMIT), rollback, budget lock
  5. sql/05_functions.sql            – 3 PL/pgSQL functions (incl. RETURNS TABLE)
  6. sql/06_procedure.sql            – Stored procedure: register_match_result
  7. sql/07_triggers.sql             – 2 triggers: contract validation + match status automation
  8. sql/08_roles_permissions.sql    – 3 roles (fc_admin, fc_app_user, fc_readonly) + GRANT/REVOKE
  9. sql/09_indexes_explain.sql      – 8 indexes + 4 EXPLAIN ANALYZE plans

Report:
  report/Technical_Report.docx      – Full technical report
  report/ER_Diagram.png             – Entity-Relationship Diagram (13 entities)

Quick start (psql):
  psql -U postgres -d your_db -f sql/01_create_schema.sql
  psql -U postgres -d your_db -f sql/02_insert_test_data.sql
  ... (run remaining files in order)
