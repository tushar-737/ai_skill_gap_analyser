-- Keep only the unique main Data Science skills.
-- Hidden: Java/C++ extras, Supervised/Unsupervised leaves,
-- and composite names like Statistics & Probability / Pandas & NumPy.
USE `ai_skill_gap`;

INSERT IGNORE INTO skills_v2 (name, category, description) VALUES
('Statistics', 'Data Science', 'Statistical methods for analysis and modeling.'),
('Data Analysis', 'Data Science', 'Inspecting and interpreting data.'),
('Data Visualization', 'Data and AI', 'Presenting data visually.');

DELETE csr
FROM career_skill_requirements csr
JOIN careers_v2 c ON c.id = csr.career_id
JOIN domains d ON d.id = c.domain_id
WHERE d.name IN (
    'Data Science & Analytics',
    'Artificial Intelligence & Machine Learning'
);

INSERT IGNORE INTO career_skill_requirements (career_id, skill_id, required_level)
SELECT c.id, s.id, v.required_level
FROM careers_v2 c
JOIN domains d ON d.id = c.domain_id
JOIN (
    SELECT 'Python' AS name, 95 AS required_level UNION ALL
    SELECT 'R', 80 UNION ALL
    SELECT 'SQL', 85 UNION ALL
    SELECT 'Statistics', 90 UNION ALL
    SELECT 'Pandas', 92 UNION ALL
    SELECT 'NumPy', 88 UNION ALL
    SELECT 'Data Analysis', 85 UNION ALL
    SELECT 'Matplotlib', 80 UNION ALL
    SELECT 'Machine Learning', 95 UNION ALL
    SELECT 'Scikit-learn', 90
) v
JOIN skills_v2 s ON s.name = v.name
WHERE d.name = 'Data Science & Analytics' AND c.name = 'Data Scientist';

INSERT IGNORE INTO career_skill_requirements (career_id, skill_id, required_level)
SELECT c.id, s.id, v.required_level
FROM careers_v2 c
JOIN domains d ON d.id = c.domain_id
JOIN (
    SELECT 'Python' AS name, 90 AS required_level UNION ALL
    SELECT 'R', 80 UNION ALL
    SELECT 'SQL', 90 UNION ALL
    SELECT 'Statistics', 85 UNION ALL
    SELECT 'Pandas', 88 UNION ALL
    SELECT 'NumPy', 80 UNION ALL
    SELECT 'Data Analysis', 88 UNION ALL
    SELECT 'Matplotlib', 80
) v
JOIN skills_v2 s ON s.name = v.name
WHERE d.name = 'Data Science & Analytics'
  AND c.name IN (
      'Data Analyst',
      'Business Intelligence Analyst',
      'Data Visualization Specialist',
      'Quantitative Analyst'
  );

INSERT IGNORE INTO career_skill_requirements (career_id, skill_id, required_level)
SELECT c.id, s.id, v.required_level
FROM careers_v2 c
JOIN domains d ON d.id = c.domain_id
JOIN (
    SELECT 'Python' AS name, 95 AS required_level UNION ALL
    SELECT 'SQL', 80 UNION ALL
    SELECT 'Statistics', 85 UNION ALL
    SELECT 'Pandas', 85 UNION ALL
    SELECT 'NumPy', 88 UNION ALL
    SELECT 'Machine Learning', 95 UNION ALL
    SELECT 'Deep Learning', 90 UNION ALL
    SELECT 'Natural Language Processing', 88
) v
JOIN skills_v2 s ON s.name = v.name
WHERE d.name = 'Artificial Intelligence & Machine Learning';
