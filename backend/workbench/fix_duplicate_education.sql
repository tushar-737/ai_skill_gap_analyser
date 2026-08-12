-- Remove repeated education programs (BCA / B.C.A., B.Com / BCom, etc.).
-- Keeps the lowest id for each normalized name. Safe to re-run.
USE `ai_skill_gap`;

DELETE ep
FROM education_programs ep
JOIN education_programs keeper
  ON keeper.id < ep.id
 AND LOWER(REPLACE(REPLACE(REPLACE(TRIM(ep.name), '.', ''), '(', ''), ')', ''))
   = LOWER(REPLACE(REPLACE(REPLACE(TRIM(keeper.name), '.', ''), '(', ''), ')', ''));
