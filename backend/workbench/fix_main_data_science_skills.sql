-- Keep only the main skills for Data Science / Analytics / ML careers.
-- Safe to re-run. Does not delete careers, domains, or resume history.
--
-- Why: expanded_career_data.sql and repair_career_skill_data.sql attach
-- filler languages (Java, C, C++, C#) and overlapping libraries
-- (Pandas + pandas-like extras) to every data role.

USE `ai_skill_gap`;

INSERT IGNORE INTO skills_v2 (name, category, description) VALUES
('Statistics', 'Statistics & Mathematics', 'Statistical methods used for analysis, modeling and data-driven decision making.'),
('Data Analysis', 'Data Analysis', 'Methods for inspecting, transforming and interpreting structured and unstructured data.');

-- Remove every extra / duplicate mapping on these careers.
DELETE csr
FROM career_skill_requirements csr
JOIN careers_v2 c ON c.id = csr.career_id
JOIN domains d ON d.id = c.domain_id
WHERE (d.name, c.name) IN (
    ('Data Science & Analytics', 'Data Analyst'),
    ('Data Science & Analytics', 'Data Scientist'),
    ('Data Science & Analytics', 'Business Intelligence Analyst'),
    ('Data Science & Analytics', 'Data Visualization Specialist'),
    ('Data Science & Analytics', 'Quantitative Analyst'),
    ('Artificial Intelligence & Machine Learning', 'Machine Learning Engineer'),
    ('Artificial Intelligence & Machine Learning', 'AI Engineer'),
    ('Artificial Intelligence & Machine Learning', 'NLP Engineer'),
    ('Artificial Intelligence & Machine Learning', 'Computer Vision Engineer'),
    ('Artificial Intelligence & Machine Learning', 'Deep Learning Engineer'),
    ('Database & Data Engineering', 'Data Engineer')
);

-- Helper pattern: insert one (career, skill, level) if the skill exists.
-- Data Analyst
INSERT IGNORE INTO career_skill_requirements (career_id, skill_id, required_level)
SELECT c.id, s.id, v.required_level
FROM careers_v2 c
JOIN domains d ON d.id = c.domain_id
JOIN (
    SELECT 'Python' AS name, 90 AS required_level UNION ALL
    SELECT 'SQL', 90 UNION ALL
    SELECT 'Pandas', 88 UNION ALL
    SELECT 'Excel', 85 UNION ALL
    SELECT 'Data Cleaning', 85 UNION ALL
    SELECT 'Exploratory Data Analysis', 80 UNION ALL
    SELECT 'Power BI', 85 UNION ALL
    SELECT 'Statistics', 80
) v
JOIN skills_v2 s ON s.name = v.name
WHERE d.name = 'Data Science & Analytics' AND c.name = 'Data Analyst';

-- Data Scientist
INSERT IGNORE INTO career_skill_requirements (career_id, skill_id, required_level)
SELECT c.id, s.id, v.required_level
FROM careers_v2 c
JOIN domains d ON d.id = c.domain_id
JOIN (
    SELECT 'Python' AS name, 95 AS required_level UNION ALL
    SELECT 'SQL', 85 UNION ALL
    SELECT 'Pandas', 92 UNION ALL
    SELECT 'NumPy', 90 UNION ALL
    SELECT 'Machine Learning', 95 UNION ALL
    SELECT 'Statistics', 90 UNION ALL
    SELECT 'Scikit-learn', 90 UNION ALL
    SELECT 'Model Evaluation', 88 UNION ALL
    SELECT 'Feature Engineering', 85 UNION ALL
    SELECT 'Matplotlib', 80
) v
JOIN skills_v2 s ON s.name = v.name
WHERE d.name = 'Data Science & Analytics' AND c.name = 'Data Scientist';

-- Business Intelligence Analyst
INSERT IGNORE INTO career_skill_requirements (career_id, skill_id, required_level)
SELECT c.id, s.id, v.required_level
FROM careers_v2 c
JOIN domains d ON d.id = c.domain_id
JOIN (
    SELECT 'SQL' AS name, 90 AS required_level UNION ALL
    SELECT 'Excel', 90 UNION ALL
    SELECT 'Power BI', 90 UNION ALL
    SELECT 'Tableau', 85 UNION ALL
    SELECT 'Data Analysis', 85 UNION ALL
    SELECT 'Dashboard Design', 85 UNION ALL
    SELECT 'Data Storytelling', 85 UNION ALL
    SELECT 'Python', 75
) v
JOIN skills_v2 s ON s.name = v.name
WHERE d.name = 'Data Science & Analytics' AND c.name = 'Business Intelligence Analyst';

-- Data Visualization Specialist
INSERT IGNORE INTO career_skill_requirements (career_id, skill_id, required_level)
SELECT c.id, s.id, v.required_level
FROM careers_v2 c
JOIN domains d ON d.id = c.domain_id
JOIN (
    SELECT 'Tableau' AS name, 90 AS required_level UNION ALL
    SELECT 'Power BI', 90 UNION ALL
    SELECT 'Python', 85 UNION ALL
    SELECT 'Matplotlib', 88 UNION ALL
    SELECT 'Seaborn', 85 UNION ALL
    SELECT 'Dashboard Design', 90 UNION ALL
    SELECT 'Data Storytelling', 88 UNION ALL
    SELECT 'Plotly', 85
) v
JOIN skills_v2 s ON s.name = v.name
WHERE d.name = 'Data Science & Analytics' AND c.name = 'Data Visualization Specialist';

-- Quantitative Analyst
INSERT IGNORE INTO career_skill_requirements (career_id, skill_id, required_level)
SELECT c.id, s.id, v.required_level
FROM careers_v2 c
JOIN domains d ON d.id = c.domain_id
JOIN (
    SELECT 'Python' AS name, 90 AS required_level UNION ALL
    SELECT 'R', 85 UNION ALL
    SELECT 'SQL', 85 UNION ALL
    SELECT 'Statistics', 90 UNION ALL
    SELECT 'Probability', 90 UNION ALL
    SELECT 'Regression Analysis', 88 UNION ALL
    SELECT 'Linear Algebra', 85 UNION ALL
    SELECT 'Time Series Analysis', 85
) v
JOIN skills_v2 s ON s.name = v.name
WHERE d.name = 'Data Science & Analytics' AND c.name = 'Quantitative Analyst';

-- Machine Learning Engineer
INSERT IGNORE INTO career_skill_requirements (career_id, skill_id, required_level)
SELECT c.id, s.id, v.required_level
FROM careers_v2 c
JOIN domains d ON d.id = c.domain_id
JOIN (
    SELECT 'Python' AS name, 95 AS required_level UNION ALL
    SELECT 'Machine Learning', 95 UNION ALL
    SELECT 'Scikit-learn', 90 UNION ALL
    SELECT 'NumPy', 88 UNION ALL
    SELECT 'Pandas', 85 UNION ALL
    SELECT 'Feature Engineering', 90 UNION ALL
    SELECT 'Model Evaluation', 88 UNION ALL
    SELECT 'SQL', 80
) v
JOIN skills_v2 s ON s.name = v.name
WHERE d.name = 'Artificial Intelligence & Machine Learning' AND c.name = 'Machine Learning Engineer';

-- AI Engineer
INSERT IGNORE INTO career_skill_requirements (career_id, skill_id, required_level)
SELECT c.id, s.id, v.required_level
FROM careers_v2 c
JOIN domains d ON d.id = c.domain_id
JOIN (
    SELECT 'Python' AS name, 90 AS required_level UNION ALL
    SELECT 'Artificial Intelligence', 90 UNION ALL
    SELECT 'Machine Learning', 88 UNION ALL
    SELECT 'Deep Learning', 85 UNION ALL
    SELECT 'PyTorch', 85 UNION ALL
    SELECT 'TensorFlow', 80 UNION ALL
    SELECT 'Generative AI', 85 UNION ALL
    SELECT 'Prompt Engineering', 80
) v
JOIN skills_v2 s ON s.name = v.name
WHERE d.name = 'Artificial Intelligence & Machine Learning' AND c.name = 'AI Engineer';

-- NLP Engineer
INSERT IGNORE INTO career_skill_requirements (career_id, skill_id, required_level)
SELECT c.id, s.id, v.required_level
FROM careers_v2 c
JOIN domains d ON d.id = c.domain_id
JOIN (
    SELECT 'Python' AS name, 90 AS required_level UNION ALL
    SELECT 'Natural Language Processing', 95 UNION ALL
    SELECT 'Transformers', 90 UNION ALL
    SELECT 'Large Language Models', 88 UNION ALL
    SELECT 'Deep Learning', 85 UNION ALL
    SELECT 'PyTorch', 85 UNION ALL
    SELECT 'Machine Learning', 85 UNION ALL
    SELECT 'NumPy', 80
) v
JOIN skills_v2 s ON s.name = v.name
WHERE d.name = 'Artificial Intelligence & Machine Learning' AND c.name = 'NLP Engineer';

-- Computer Vision Engineer
INSERT IGNORE INTO career_skill_requirements (career_id, skill_id, required_level)
SELECT c.id, s.id, v.required_level
FROM careers_v2 c
JOIN domains d ON d.id = c.domain_id
JOIN (
    SELECT 'Python' AS name, 90 AS required_level UNION ALL
    SELECT 'Computer Vision', 95 UNION ALL
    SELECT 'Deep Learning', 90 UNION ALL
    SELECT 'PyTorch', 88 UNION ALL
    SELECT 'OpenCV', 88 UNION ALL
    SELECT 'TensorFlow', 85 UNION ALL
    SELECT 'Machine Learning', 80 UNION ALL
    SELECT 'NumPy', 85
) v
JOIN skills_v2 s ON s.name = v.name
WHERE d.name = 'Artificial Intelligence & Machine Learning' AND c.name = 'Computer Vision Engineer';

-- Deep Learning Engineer
INSERT IGNORE INTO career_skill_requirements (career_id, skill_id, required_level)
SELECT c.id, s.id, v.required_level
FROM careers_v2 c
JOIN domains d ON d.id = c.domain_id
JOIN (
    SELECT 'Python' AS name, 90 AS required_level UNION ALL
    SELECT 'Deep Learning', 95 UNION ALL
    SELECT 'Neural Networks', 92 UNION ALL
    SELECT 'PyTorch', 90 UNION ALL
    SELECT 'TensorFlow', 88 UNION ALL
    SELECT 'Linear Algebra', 85 UNION ALL
    SELECT 'NumPy', 88 UNION ALL
    SELECT 'Machine Learning', 80
) v
JOIN skills_v2 s ON s.name = v.name
WHERE d.name = 'Artificial Intelligence & Machine Learning' AND c.name = 'Deep Learning Engineer';

-- Data Engineer
INSERT IGNORE INTO career_skill_requirements (career_id, skill_id, required_level)
SELECT c.id, s.id, v.required_level
FROM careers_v2 c
JOIN domains d ON d.id = c.domain_id
JOIN (
    SELECT 'Python' AS name, 90 AS required_level UNION ALL
    SELECT 'SQL', 95 UNION ALL
    SELECT 'ETL', 90 UNION ALL
    SELECT 'PostgreSQL', 80 UNION ALL
    SELECT 'Docker', 75 UNION ALL
    SELECT 'AWS', 75 UNION ALL
    SELECT 'Data Cleaning', 75 UNION ALL
    SELECT 'Linux', 70
) v
JOIN skills_v2 s ON s.name = v.name
WHERE d.name = 'Database & Data Engineering' AND c.name = 'Data Engineer';

-- Verify Data Scientist now has only the main set.
SELECT c.name AS career, s.name AS skill, csr.required_level
FROM careers_v2 c
JOIN career_skill_requirements csr ON csr.career_id = c.id
JOIN skills_v2 s ON s.id = csr.skill_id
WHERE c.name = 'Data Scientist'
ORDER BY csr.required_level DESC, s.name;
