-- =====================================================
-- AI Skill Gap Analyzer — MySQL Workbench init script
-- =====================================================
-- How to use in MySQL Workbench:
-- 1) Open Workbench → Connect to your MySQL server (localhost:3306)
-- 2) File → Open SQL Script → select this file
-- 3) Execute (⚡) — creates `ai_skill_gap` DB and all tables if not exists
-- 4) Verify: Schemas → ai_skill_gap → Tables
--
-- This matches models.py exactly, so SQLAlchemy can use it without
-- calling Base.metadata.create_all(). Engine=InnoDB, utf8mb4.
-- =====================================================

CREATE DATABASE IF NOT EXISTS `ai_skill_gap`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `ai_skill_gap`;

-- -----------------------------------------------------
-- education_categories
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `education_categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL UNIQUE,
  `description` TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- education_programs
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `education_programs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `category_id` INT NULL,
  `name` VARCHAR(150) NOT NULL,
  `level` VARCHAR(50) NULL,
  `description` TEXT NULL,
  INDEX `idx_education_programs_category` (`category_id`),
  CONSTRAINT `fk_education_programs_category`
    FOREIGN KEY (`category_id`) REFERENCES `education_categories` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- domains
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `domains` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(150) NOT NULL UNIQUE,
  `description` TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- careers_v2
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `careers_v2` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `domain_id` INT NULL,
  `name` VARCHAR(150) NOT NULL,
  `description` TEXT NULL,
  `average_level` VARCHAR(50) NULL,
  INDEX `idx_careers_v2_domain` (`domain_id`),
  CONSTRAINT `fk_careers_v2_domain`
    FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- skills_v2
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `skills_v2` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(150) NOT NULL UNIQUE,
  `category` VARCHAR(100) NULL,
  `description` TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- career_skill_requirements
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `career_skill_requirements` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `career_id` INT NOT NULL,
  `skill_id` INT NOT NULL,
  `required_level` INT NOT NULL DEFAULT 50,
  INDEX `idx_csr_career` (`career_id`),
  INDEX `idx_csr_skill` (`skill_id`),
  UNIQUE KEY `uq_career_skill` (`career_id`, `skill_id`),
  CONSTRAINT `fk_csr_career`
    FOREIGN KEY (`career_id`) REFERENCES `careers_v2` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_csr_skill`
    FOREIGN KEY (`skill_id`) REFERENCES `skills_v2` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- resume_analyses — stores resume uploads for Workbench
-- Workbench JSON type requires MySQL 5.7.8+, else use TEXT.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `resume_analyses` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `file_name` VARCHAR(255) NOT NULL,
  `file_size` INT NULL,
  -- Opaque browser session identifier; used to isolate resume history.
  `owner_token` VARCHAR(64) NULL,
  `raw_text` TEXT NULL,
  `extracted_skills` JSON NULL,
  `target_career_id` INT NULL,
  `extraction_source` VARCHAR(20) NOT NULL DEFAULT 'keyword',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_resume_career` (`target_career_id`),
  INDEX `idx_resume_owner_token` (`owner_token`),
  CONSTRAINT `fk_resume_career`
    FOREIGN KEY (`target_career_id`) REFERENCES `careers_v2` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Existing installations: run these once if `resume_analyses` was
-- created by an earlier version of this script.
-- ALTER TABLE `resume_analyses` ADD COLUMN `owner_token` VARCHAR(64) NULL;
-- CREATE INDEX `idx_resume_owner_token` ON `resume_analyses` (`owner_token`);

USE `ai_skill_gap`;

-- =====================================================
-- 1) EDUCATION CATEGORIES
-- =====================================================

INSERT IGNORE INTO `education_categories` (`name`, `description`) VALUES
('Computer Science & IT',   'Degrees focused on computing, software and information technology'),
('Engineering (Core)',      'Mechanical, civil, electrical and electronics engineering degrees'),
('Business & Management',   'Management and business administration programs'),
('Commerce & Finance',      'Accounting, banking, taxation and finance programs'),
('Science',                 'Pure and applied science degrees'),
('Arts, Design & Media',    'Humanities, design, fine arts, journalism and media programs'),
('Health & Life Sciences',  'Medical, pharmacy, nursing and life science programs');

-- =====================================================
-- 2) EDUCATION PROGRAMS  (guarded: inserted only if name not present)
-- =====================================================

INSERT INTO `education_programs` (`category_id`, `name`, `level`, `description`)
SELECT c.id, t.name, t.level, t.description
FROM (
    SELECT 'Computer Science & IT'  AS category_name, 'B.Tech Computer Science'      AS name, 'Undergraduate' AS level, 'Four year engineering degree in computer science' AS description
    UNION ALL SELECT 'Computer Science & IT',  'BCA',                       'Undergraduate', 'Bachelor of Computer Applications'
    UNION ALL SELECT 'Computer Science & IT',  'B.Sc Information Technology','Undergraduate', 'Three year IT degree covering software and systems'
    UNION ALL SELECT 'Computer Science & IT',  'MCA',                       'Postgraduate',  'Master of Computer Applications'
    UNION ALL SELECT 'Computer Science & IT',  'M.Sc Computer Science',     'Postgraduate',  'Two year masters in computer science'
    UNION ALL SELECT 'Engineering (Core)',     'B.Tech Mechanical Engineering',    'Undergraduate', 'Design, manufacturing and thermal sciences'
    UNION ALL SELECT 'Engineering (Core)',     'B.Tech Civil Engineering',         'Undergraduate', 'Structures, construction and infrastructure'
    UNION ALL SELECT 'Engineering (Core)',     'B.Tech Electrical Engineering',    'Undergraduate', 'Power, circuits and electrical machines'
    UNION ALL SELECT 'Engineering (Core)',     'B.Tech Electronics & Communication', 'Undergraduate', 'Embedded systems, signals and communication'
    UNION ALL SELECT 'Engineering (Core)',     'M.Tech',                            'Postgraduate',  'Masters in an engineering specialization'
    UNION ALL SELECT 'Business & Management',  'BBA',     'Undergraduate', 'Bachelor of Business Administration'
    UNION ALL SELECT 'Business & Management',  'MBA',     'Postgraduate',  'Master of Business Administration'
    UNION ALL SELECT 'Business & Management',  'PGDM',    'Postgraduate',  'Post Graduate Diploma in Management'
    UNION ALL SELECT 'Commerce & Finance',     'B.Com',        'Undergraduate', 'Accounting, taxation and business law'
    UNION ALL SELECT 'Commerce & Finance',     'B.Com (Hons)', 'Undergraduate', 'Honours degree with deeper finance and accounting focus'
    UNION ALL SELECT 'Commerce & Finance',     'M.Com',        'Postgraduate',  'Advanced commerce, finance and research methods'
    UNION ALL SELECT 'Science',                'B.Sc Physics',      'Undergraduate', 'Mechanics, electromagnetism and quantum basics'
    UNION ALL SELECT 'Science',                'B.Sc Mathematics',  'Undergraduate', 'Algebra, calculus and applied mathematics'
    UNION ALL SELECT 'Science',                'B.Sc Biotechnology','Undergraduate', 'Genetics, microbiology and lab techniques'
    UNION ALL SELECT 'Science',                'M.Sc Data Science', 'Postgraduate',  'Statistics, machine learning and data engineering'
    UNION ALL SELECT 'Arts, Design & Media',   'BA (General)',                'Undergraduate', 'Humanities and social sciences'
    UNION ALL SELECT 'Arts, Design & Media',   'B.Des',                       'Undergraduate', 'Bachelor of Design - product, graphic or UX'
    UNION ALL SELECT 'Arts, Design & Media',   'BFA',                         'Undergraduate', 'Bachelor of Fine Arts'
    UNION ALL SELECT 'Arts, Design & Media',   'BA Journalism & Mass Communication', 'Undergraduate', 'Reporting, media production and communication'
    UNION ALL SELECT 'Health & Life Sciences', 'MBBS',        'Professional',  'Bachelor of Medicine and Bachelor of Surgery'
    UNION ALL SELECT 'Health & Life Sciences', 'B.Pharm',     'Undergraduate', 'Pharmaceutics, pharmacology and drug regulation'
    UNION ALL SELECT 'Health & Life Sciences', 'B.Sc Nursing','Undergraduate', 'Patient care, anatomy and clinical practice'
) t
JOIN `education_categories` c ON c.name = t.category_name
LEFT JOIN `education_programs` p ON p.name = t.name
WHERE p.id IS NULL;

-- =====================================================
-- 3) DOMAINS
-- =====================================================

INSERT IGNORE INTO `domains` (`name`, `description`) VALUES
('Artificial Intelligence & Data Science', 'Turning data into decisions with analytics, ML and AI'),
('Software Development',                   'Building web, mobile and backend applications'),
('Cloud & DevOps',                         'Running reliable infrastructure and delivery pipelines'),
('Cybersecurity',                          'Protecting systems, networks and data from attacks'),
('UI/UX & Product Design',                 'Designing usable, accessible and delightful products'),
('Digital Marketing',                      'Growing brands through search, social and paid channels'),
('Finance & Accounting',                   'Managing money, reporting and investment decisions'),
('Mechanical & Core Engineering',          'Designing and manufacturing physical products'),
('Healthcare & Life Sciences',             'Care, clinical data and pharmaceutical operations'),
('Content & Media',                        'Writing, video and storytelling for digital audiences');

-- =====================================================
-- 4) CAREERS  (guarded: inserted only if name not present)
-- =====================================================

INSERT INTO `careers_v2` (`domain_id`, `name`, `description`, `average_level`)
SELECT d.id, t.name, t.description, t.avg_level
FROM (
    SELECT 'Artificial Intelligence & Data Science' AS domain_name, 'Data Analyst'              AS name, 'Analyse business data and build reports and dashboards' AS description, 'Beginner'     AS avg_level
    UNION ALL SELECT 'Artificial Intelligence & Data Science', 'Data Scientist',          'Build predictive models and run statistical experiments', 'Advanced'
    UNION ALL SELECT 'Artificial Intelligence & Data Science', 'Machine Learning Engineer','Ship ML models to production at scale', 'Advanced'
    UNION ALL SELECT 'Artificial Intelligence & Data Science', 'Business Intelligence Analyst', 'Own BI dashboards and data modelling for decision makers', 'Intermediate'
    UNION ALL SELECT 'Software Development', 'Frontend Developer',   'Build fast, accessible user interfaces', 'Intermediate'
    UNION ALL SELECT 'Software Development', 'Backend Developer',    'Design APIs, services and databases', 'Intermediate'
    UNION ALL SELECT 'Software Development', 'Full Stack Developer', 'Own features end to end across the stack', 'Advanced'
    UNION ALL SELECT 'Software Development', 'Mobile App Developer', 'Build cross platform and native mobile apps', 'Intermediate'
    UNION ALL SELECT 'Cloud & DevOps', 'DevOps Engineer',           'Automate builds, deployments and infrastructure', 'Advanced'
    UNION ALL SELECT 'Cloud & DevOps', 'Cloud Engineer',            'Design and operate cloud infrastructure', 'Intermediate'
    UNION ALL SELECT 'Cloud & DevOps', 'Site Reliability Engineer', 'Keep production systems fast and reliable', 'Advanced'
    UNION ALL SELECT 'Cybersecurity', 'Security Analyst',     'Monitor and harden systems against threats', 'Intermediate'
    UNION ALL SELECT 'Cybersecurity', 'Penetration Tester',   'Find and exploit vulnerabilities before attackers do', 'Advanced'
    UNION ALL SELECT 'Cybersecurity', 'SOC Analyst',          'Triage alerts and respond to security incidents', 'Intermediate'
    UNION ALL SELECT 'UI/UX & Product Design', 'UX Designer',      'Research users and design flows that work', 'Intermediate'
    UNION ALL SELECT 'UI/UX & Product Design', 'UI Designer',      'Craft visual interfaces and design systems', 'Intermediate'
    UNION ALL SELECT 'UI/UX & Product Design', 'Product Designer', 'Own end to end product experience', 'Advanced'
    UNION ALL SELECT 'Digital Marketing', 'Digital Marketing Executive', 'Run multi channel marketing campaigns', 'Beginner'
    UNION ALL SELECT 'Digital Marketing', 'SEO Specialist',              'Grow organic traffic with technical and content SEO', 'Intermediate'
    UNION ALL SELECT 'Digital Marketing', 'Performance Marketer',        'Optimise paid acquisition for ROI', 'Intermediate'
    UNION ALL SELECT 'Digital Marketing', 'Social Media Manager',        'Build and engage communities on social platforms', 'Beginner'
    UNION ALL SELECT 'Finance & Accounting', 'Financial Analyst',           'Model, forecast and analyse company finances', 'Intermediate'
    UNION ALL SELECT 'Finance & Accounting', 'Accountant',                  'Maintain books, compliance and reporting', 'Beginner'
    UNION ALL SELECT 'Finance & Accounting', 'Investment Banking Analyst',  'Value companies and support deals', 'Advanced'
    UNION ALL SELECT 'Mechanical & Core Engineering', 'Mechanical Design Engineer', 'Design mechanical parts and assemblies', 'Intermediate'
    UNION ALL SELECT 'Mechanical & Core Engineering', 'CAD Engineer',               'Produce detailed 2D and 3D engineering drawings', 'Beginner'
    UNION ALL SELECT 'Mechanical & Core Engineering', 'Quality Engineer',           'Assure product and process quality in manufacturing', 'Intermediate'
    UNION ALL SELECT 'Healthcare & Life Sciences', 'Healthcare Data Analyst',       'Analyse clinical and operational healthcare data', 'Intermediate'
    UNION ALL SELECT 'Healthcare & Life Sciences', 'Medical Coder',                 'Code diagnoses and procedures for billing and records', 'Beginner'
    UNION ALL SELECT 'Healthcare & Life Sciences', 'Pharmacovigilance Associate',   'Monitor and report drug safety data', 'Intermediate'
    UNION ALL SELECT 'Content & Media', 'Content Writer', 'Write articles, scripts and marketing copy', 'Beginner'
    UNION ALL SELECT 'Content & Media', 'Video Editor',   'Edit engaging video for digital platforms', 'Intermediate'
    UNION ALL SELECT 'Content & Media', 'Journalist',     'Research and report stories across media', 'Intermediate'
) t
JOIN `domains` d ON d.name = t.domain_name
LEFT JOIN `careers_v2` c ON c.name = t.name
WHERE c.id IS NULL;

-- =====================================================
-- 5) SKILLS
-- =====================================================

INSERT IGNORE INTO `skills_v2` (`name`, `category`, `description`) VALUES
-- Programming & Languages
('Python',                'Programming', 'General purpose programming and scripting'),
('R',                     'Programming', 'Statistical computing and data analysis'),
('Java',                  'Programming', 'Object oriented language for enterprise systems'),
('JavaScript',            'Programming', 'Language of the web browser and Node.js'),
('TypeScript',            'Programming', 'Typed superset of JavaScript for large codebases'),
('Kotlin',                'Programming', 'Modern language for Android development'),
('SQL',                   'Databases',   'Querying and managing relational databases'),
('HTML & CSS',            'Web',         'Structure and styling of web pages'),
-- Data & AI
('Statistics & Probability', 'Data & AI', 'Statistical inference, distributions and hypothesis testing'),
('Machine Learning',         'Data & AI', 'Supervised and unsupervised learning algorithms'),
('Deep Learning',            'Data & AI', 'Neural networks for vision, language and more'),
('Natural Language Processing', 'Data & AI', 'Text processing and language models'),
('Pandas & NumPy',           'Data & AI', 'Data wrangling and numerical computing in Python'),
('Data Visualization',       'Data & AI', 'Charts and visual storytelling with data'),
('TensorFlow',               'Data & AI', 'Deep learning framework by Google'),
('PyTorch',                  'Data & AI', 'Deep learning framework by Meta'),
('MLOps',                    'Data & AI', 'Deploying and monitoring ML models in production'),
-- BI & Office Tools
('Excel',    'Analytics Tools', 'Spreadsheets, formulas, pivot tables and analysis'),
('Power BI', 'Analytics Tools', 'Microsoft BI dashboards and reporting'),
('Tableau',  'Analytics Tools', 'Visual analytics and dashboarding'),
-- Web & Software Engineering
('React',           'Web', 'Component based UI library'),
('Node.js',         'Web', 'JavaScript runtime for backend services'),
('Spring Boot',     'Web', 'Java framework for production APIs'),
('REST API Design', 'Web', 'Designing clean, versioned HTTP APIs'),
('Git & GitHub',    'Tools', 'Version control and collaboration'),
('MongoDB',         'Databases', 'Document oriented NoSQL database'),
('PostgreSQL',      'Databases', 'Advanced open source relational database'),
('Flutter',         'Mobile', 'Cross platform mobile UI toolkit'),
-- Cloud & DevOps
('AWS',                        'Cloud', 'Amazon Web Services cloud platform'),
('Microsoft Azure',            'Cloud', 'Microsoft cloud platform'),
('Google Cloud Platform',      'Cloud', 'Google cloud platform'),
('Docker',                     'DevOps', 'Containerising applications'),
('Kubernetes',                 'DevOps', 'Container orchestration at scale'),
('Terraform',                  'DevOps', 'Infrastructure as code'),
('CI/CD Pipelines',            'DevOps', 'Automated build, test and deploy pipelines'),
('Linux Administration',       'DevOps', 'Managing Linux servers and shell'),
('Networking Fundamentals',    'DevOps', 'TCP/IP, DNS, load balancing and HTTP'),
('Monitoring & Observability', 'DevOps', 'Metrics, logs, traces and alerting'),
-- Security
('Network Security',    'Security', 'Firewalls, segmentation and secure network design'),
('Ethical Hacking',     'Security', 'Authorised offensive security testing'),
('SIEM Tools',          'Security', 'Security information and event monitoring'),
('Cryptography',        'Security', 'Encryption, hashing and secure protocols'),
('OWASP Top 10',        'Security', 'Top web application security risks'),
('Incident Response',   'Security', 'Detecting, containing and recovering from incidents'),
-- Design
('Figma',            'Design', 'Collaborative interface design tool'),
('User Research',    'Design', 'Interviews, surveys and usability insights'),
('Wireframing',      'Design', 'Low fidelity layout sketches'),
('Prototyping',      'Design', 'Interactive high fidelity prototypes'),
('Design Systems',   'Design', 'Reusable component libraries and tokens'),
('Usability Testing','Design', 'Validating designs with real users'),
('Adobe XD',         'Design', 'UI design and prototyping tool'),
-- Marketing
('SEO',                   'Marketing', 'Search engine optimisation'),
('Google Ads',            'Marketing', 'Paid search and display advertising'),
('Meta Ads',              'Marketing', 'Advertising on Facebook and Instagram'),
('Content Marketing',     'Marketing', 'Content strategy, blogs and funnels'),
('Email Marketing',       'Marketing', 'Campaigns, automation and deliverability'),
('Google Analytics',      'Marketing', 'Web analytics and conversion tracking'),
('Social Media Strategy', 'Marketing', 'Planning and growing social channels'),
('Copywriting',           'Marketing', 'Persuasive writing for ads and web'),
-- Finance
('Financial Modeling',    'Finance', 'Forecasting and scenario models in spreadsheets'),
('Tally ERP',             'Finance', 'Bookkeeping and GST accounting software'),
('Accounting Standards',  'Finance', 'Ind AS and IFRS reporting rules'),
('Company Valuation',     'Finance', 'DCF, comparables and transaction analysis'),
('Risk Analysis',         'Finance', 'Identifying and quantifying financial risk'),
-- Core Engineering
('AutoCAD',                'Engineering', '2D drafting and detailing'),
('SolidWorks',             'Engineering', '3D CAD modelling and assemblies'),
('CATIA',                  'Engineering', 'Advanced surface and product design'),
('GD&T',                   'Engineering', 'Geometric dimensioning and tolerancing'),
('ANSYS',                  'Engineering', 'FEA and simulation'),
('Six Sigma',              'Engineering', 'Process improvement and quality methodology'),
('Manufacturing Processes','Engineering', 'Machining, casting, forming and assembly'),
-- Healthcare
('Medical Terminology',      'Healthcare', 'Clinical vocabulary and abbreviations'),
('ICD-10 Coding',            'Healthcare', 'Diagnosis and procedure coding standard'),
('Clinical Data Management', 'Healthcare', 'Collecting and validating trial and patient data'),
('SAS Programming',          'Healthcare', 'Statistical analysis used in clinical research'),
('Regulatory Compliance',    'Healthcare', 'Meeting healthcare and pharma regulations'),
-- Media & Content
('Scriptwriting',      'Media', 'Writing scripts for video and audio'),
('Adobe Premiere Pro', 'Media', 'Professional video editing'),
('Storytelling',       'Media', 'Narrative structure and audience engagement'),
('SEO Writing',        'Media', 'Writing content that ranks on search engines');

-- =====================================================
-- 6) CAREER → SKILL REQUIREMENTS (required_level 0-100)
-- =====================================================

INSERT IGNORE INTO `career_skill_requirements` (`career_id`, `skill_id`, `required_level`)
SELECT c.id, s.id, t.required_level
FROM (
    -- AI & Data Science
    SELECT 'Data Analyst'              AS career_name, 'SQL'                        AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Data Analyst', 'Excel', 80
    UNION ALL SELECT 'Data Analyst', 'Python', 75
    UNION ALL SELECT 'Data Analyst', 'Statistics & Probability', 70
    UNION ALL SELECT 'Data Analyst', 'Data Visualization', 80
    UNION ALL SELECT 'Data Analyst', 'Power BI', 75
    UNION ALL SELECT 'Data Analyst', 'Pandas & NumPy', 70
    UNION ALL SELECT 'Data Scientist', 'Python', 90
    UNION ALL SELECT 'Data Scientist', 'Statistics & Probability', 85
    UNION ALL SELECT 'Data Scientist', 'Machine Learning', 85
    UNION ALL SELECT 'Data Scientist', 'SQL', 80
    UNION ALL SELECT 'Data Scientist', 'Pandas & NumPy', 85
    UNION ALL SELECT 'Data Scientist', 'Deep Learning', 70
    UNION ALL SELECT 'Data Scientist', 'Natural Language Processing', 65
    UNION ALL SELECT 'Data Scientist', 'R', 60
    UNION ALL SELECT 'Data Scientist', 'Data Visualization', 70
    UNION ALL SELECT 'Machine Learning Engineer', 'Python', 90
    UNION ALL SELECT 'Machine Learning Engineer', 'Machine Learning', 90
    UNION ALL SELECT 'Machine Learning Engineer', 'Deep Learning', 85
    UNION ALL SELECT 'Machine Learning Engineer', 'TensorFlow', 80
    UNION ALL SELECT 'Machine Learning Engineer', 'PyTorch', 80
    UNION ALL SELECT 'Machine Learning Engineer', 'MLOps', 75
    UNION ALL SELECT 'Machine Learning Engineer', 'Docker', 65
    UNION ALL SELECT 'Machine Learning Engineer', 'SQL', 70
    UNION ALL SELECT 'Business Intelligence Analyst', 'SQL', 85
    UNION ALL SELECT 'Business Intelligence Analyst', 'Power BI', 85
    UNION ALL SELECT 'Business Intelligence Analyst', 'Tableau', 80
    UNION ALL SELECT 'Business Intelligence Analyst', 'Excel', 80
    UNION ALL SELECT 'Business Intelligence Analyst', 'Data Visualization', 85
    UNION ALL SELECT 'Business Intelligence Analyst', 'Statistics & Probability', 60
    -- Software Development
    UNION ALL SELECT 'Frontend Developer', 'HTML & CSS', 90
    UNION ALL SELECT 'Frontend Developer', 'JavaScript', 85
    UNION ALL SELECT 'Frontend Developer', 'React', 85
    UNION ALL SELECT 'Frontend Developer', 'TypeScript', 70
    UNION ALL SELECT 'Frontend Developer', 'Git & GitHub', 75
    UNION ALL SELECT 'Frontend Developer', 'REST API Design', 60
    UNION ALL SELECT 'Frontend Developer', 'Figma', 50
    UNION ALL SELECT 'Backend Developer', 'Node.js', 85
    UNION ALL SELECT 'Backend Developer', 'Java', 75
    UNION ALL SELECT 'Backend Developer', 'Spring Boot', 75
    UNION ALL SELECT 'Backend Developer', 'REST API Design', 85
    UNION ALL SELECT 'Backend Developer', 'PostgreSQL', 80
    UNION ALL SELECT 'Backend Developer', 'MongoDB', 70
    UNION ALL SELECT 'Backend Developer', 'Docker', 65
    UNION ALL SELECT 'Backend Developer', 'Git & GitHub', 75
    UNION ALL SELECT 'Full Stack Developer', 'JavaScript', 85
    UNION ALL SELECT 'Full Stack Developer', 'React', 80
    UNION ALL SELECT 'Full Stack Developer', 'Node.js', 80
    UNION ALL SELECT 'Full Stack Developer', 'REST API Design', 85
    UNION ALL SELECT 'Full Stack Developer', 'PostgreSQL', 75
    UNION ALL SELECT 'Full Stack Developer', 'MongoDB', 70
    UNION ALL SELECT 'Full Stack Developer', 'Docker', 70
    UNION ALL SELECT 'Full Stack Developer', 'Git & GitHub', 80
    UNION ALL SELECT 'Mobile App Developer', 'Flutter', 85
    UNION ALL SELECT 'Mobile App Developer', 'Kotlin', 75
    UNION ALL SELECT 'Mobile App Developer', 'REST API Design', 70
    UNION ALL SELECT 'Mobile App Developer', 'Git & GitHub', 70
    -- Cloud & DevOps
    UNION ALL SELECT 'DevOps Engineer', 'Linux Administration', 85
    UNION ALL SELECT 'DevOps Engineer', 'Docker', 85
    UNION ALL SELECT 'DevOps Engineer', 'Kubernetes', 80
    UNION ALL SELECT 'DevOps Engineer', 'CI/CD Pipelines', 85
    UNION ALL SELECT 'DevOps Engineer', 'Terraform', 75
    UNION ALL SELECT 'DevOps Engineer', 'AWS', 75
    UNION ALL SELECT 'DevOps Engineer', 'Monitoring & Observability', 70
    UNION ALL SELECT 'DevOps Engineer', 'Networking Fundamentals', 70
    UNION ALL SELECT 'Cloud Engineer', 'AWS', 85
    UNION ALL SELECT 'Cloud Engineer', 'Microsoft Azure', 75
    UNION ALL SELECT 'Cloud Engineer', 'Google Cloud Platform', 60
    UNION ALL SELECT 'Cloud Engineer', 'Networking Fundamentals', 75
    UNION ALL SELECT 'Cloud Engineer', 'Linux Administration', 75
    UNION ALL SELECT 'Cloud Engineer', 'Terraform', 70
    UNION ALL SELECT 'Cloud Engineer', 'Docker', 70
    UNION ALL SELECT 'Site Reliability Engineer', 'Linux Administration', 85
    UNION ALL SELECT 'Site Reliability Engineer', 'Monitoring & Observability', 85
    UNION ALL SELECT 'Site Reliability Engineer', 'Kubernetes', 80
    UNION ALL SELECT 'Site Reliability Engineer', 'CI/CD Pipelines', 75
    UNION ALL SELECT 'Site Reliability Engineer', 'Python', 70
    UNION ALL SELECT 'Site Reliability Engineer', 'Networking Fundamentals', 75
    UNION ALL SELECT 'Site Reliability Engineer', 'Incident Response', 70
    -- Cybersecurity
    UNION ALL SELECT 'Security Analyst', 'Network Security', 85
    UNION ALL SELECT 'Security Analyst', 'SIEM Tools', 75
    UNION ALL SELECT 'Security Analyst', 'Incident Response', 75
    UNION ALL SELECT 'Security Analyst', 'Linux Administration', 70
    UNION ALL SELECT 'Security Analyst', 'Cryptography', 65
    UNION ALL SELECT 'Security Analyst', 'Networking Fundamentals', 80
    UNION ALL SELECT 'Security Analyst', 'Python', 55
    UNION ALL SELECT 'Penetration Tester', 'Ethical Hacking', 90
    UNION ALL SELECT 'Penetration Tester', 'OWASP Top 10', 85
    UNION ALL SELECT 'Penetration Tester', 'Network Security', 80
    UNION ALL SELECT 'Penetration Tester', 'Linux Administration', 75
    UNION ALL SELECT 'Penetration Tester', 'Python', 70
    UNION ALL SELECT 'Penetration Tester', 'Cryptography', 60
    UNION ALL SELECT 'SOC Analyst', 'SIEM Tools', 85
    UNION ALL SELECT 'SOC Analyst', 'Incident Response', 85
    UNION ALL SELECT 'SOC Analyst', 'Network Security', 75
    UNION ALL SELECT 'SOC Analyst', 'Networking Fundamentals', 70
    -- UI/UX & Product Design
    UNION ALL SELECT 'UX Designer', 'User Research', 85
    UNION ALL SELECT 'UX Designer', 'Wireframing', 85
    UNION ALL SELECT 'UX Designer', 'Prototyping', 80
    UNION ALL SELECT 'UX Designer', 'Figma', 80
    UNION ALL SELECT 'UX Designer', 'Usability Testing', 80
    UNION ALL SELECT 'UX Designer', 'Design Systems', 65
    UNION ALL SELECT 'UI Designer', 'Figma', 90
    UNION ALL SELECT 'UI Designer', 'Design Systems', 80
    UNION ALL SELECT 'UI Designer', 'Prototyping', 75
    UNION ALL SELECT 'UI Designer', 'Adobe XD', 70
    UNION ALL SELECT 'UI Designer', 'Wireframing', 65
    UNION ALL SELECT 'UI Designer', 'HTML & CSS', 60
    UNION ALL SELECT 'Product Designer', 'User Research', 80
    UNION ALL SELECT 'Product Designer', 'Prototyping', 85
    UNION ALL SELECT 'Product Designer', 'Design Systems', 85
    UNION ALL SELECT 'Product Designer', 'Figma', 85
    UNION ALL SELECT 'Product Designer', 'Usability Testing', 80
    UNION ALL SELECT 'Product Designer', 'Wireframing', 75
    -- Digital Marketing
    UNION ALL SELECT 'Digital Marketing Executive', 'Google Ads', 75
    UNION ALL SELECT 'Digital Marketing Executive', 'Meta Ads', 75
    UNION ALL SELECT 'Digital Marketing Executive', 'Content Marketing', 70
    UNION ALL SELECT 'Digital Marketing Executive', 'Email Marketing', 65
    UNION ALL SELECT 'Digital Marketing Executive', 'Google Analytics', 75
    UNION ALL SELECT 'Digital Marketing Executive', 'Social Media Strategy', 70
    UNION ALL SELECT 'Digital Marketing Executive', 'SEO', 60
    UNION ALL SELECT 'Digital Marketing Executive', 'Copywriting', 60
    UNION ALL SELECT 'SEO Specialist', 'SEO', 90
    UNION ALL SELECT 'SEO Specialist', 'Google Analytics', 85
    UNION ALL SELECT 'SEO Specialist', 'Content Marketing', 75
    UNION ALL SELECT 'SEO Specialist', 'Copywriting', 65
    UNION ALL SELECT 'SEO Specialist', 'HTML & CSS', 50
    UNION ALL SELECT 'Performance Marketer', 'Google Ads', 85
    UNION ALL SELECT 'Performance Marketer', 'Meta Ads', 85
    UNION ALL SELECT 'Performance Marketer', 'Google Analytics', 80
    UNION ALL SELECT 'Performance Marketer', 'Copywriting', 65
    UNION ALL SELECT 'Performance Marketer', 'Excel', 65
    UNION ALL SELECT 'Performance Marketer', 'Email Marketing', 60
    UNION ALL SELECT 'Social Media Manager', 'Social Media Strategy', 85
    UNION ALL SELECT 'Social Media Manager', 'Content Marketing', 75
    UNION ALL SELECT 'Social Media Manager', 'Copywriting', 75
    UNION ALL SELECT 'Social Media Manager', 'Meta Ads', 70
    UNION ALL SELECT 'Social Media Manager', 'Storytelling', 70
    UNION ALL SELECT 'Social Media Manager', 'Google Analytics', 60
    -- Finance & Accounting
    UNION ALL SELECT 'Financial Analyst', 'Financial Modeling', 85
    UNION ALL SELECT 'Financial Analyst', 'Excel', 85
    UNION ALL SELECT 'Financial Analyst', 'Company Valuation', 80
    UNION ALL SELECT 'Financial Analyst', 'SQL', 60
    UNION ALL SELECT 'Financial Analyst', 'Power BI', 65
    UNION ALL SELECT 'Financial Analyst', 'Risk Analysis', 70
    UNION ALL SELECT 'Financial Analyst', 'Accounting Standards', 65
    UNION ALL SELECT 'Accountant', 'Accounting Standards', 85
    UNION ALL SELECT 'Accountant', 'Tally ERP', 85
    UNION ALL SELECT 'Accountant', 'Excel', 80
    UNION ALL SELECT 'Accountant', 'Financial Modeling', 55
    UNION ALL SELECT 'Accountant', 'Regulatory Compliance', 60
    UNION ALL SELECT 'Investment Banking Analyst', 'Financial Modeling', 90
    UNION ALL SELECT 'Investment Banking Analyst', 'Company Valuation', 90
    UNION ALL SELECT 'Investment Banking Analyst', 'Excel', 85
    UNION ALL SELECT 'Investment Banking Analyst', 'Risk Analysis', 75
    UNION ALL SELECT 'Investment Banking Analyst', 'Accounting Standards', 70
    UNION ALL SELECT 'Investment Banking Analyst', 'Statistics & Probability', 60
    -- Mechanical & Core Engineering
    UNION ALL SELECT 'Mechanical Design Engineer', 'SolidWorks', 85
    UNION ALL SELECT 'Mechanical Design Engineer', 'AutoCAD', 80
    UNION ALL SELECT 'Mechanical Design Engineer', 'GD&T', 80
    UNION ALL SELECT 'Mechanical Design Engineer', 'ANSYS', 70
    UNION ALL SELECT 'Mechanical Design Engineer', 'Manufacturing Processes', 75
    UNION ALL SELECT 'Mechanical Design Engineer', 'CATIA', 65
    UNION ALL SELECT 'CAD Engineer', 'AutoCAD', 90
    UNION ALL SELECT 'CAD Engineer', 'SolidWorks', 80
    UNION ALL SELECT 'CAD Engineer', 'CATIA', 75
    UNION ALL SELECT 'CAD Engineer', 'GD&T', 70
    UNION ALL SELECT 'Quality Engineer', 'Six Sigma', 80
    UNION ALL SELECT 'Quality Engineer', 'Manufacturing Processes', 75
    UNION ALL SELECT 'Quality Engineer', 'GD&T', 65
    UNION ALL SELECT 'Quality Engineer', 'Excel', 70
    UNION ALL SELECT 'Quality Engineer', 'Statistics & Probability', 60
    -- Healthcare & Life Sciences
    UNION ALL SELECT 'Healthcare Data Analyst', 'SQL', 75
    UNION ALL SELECT 'Healthcare Data Analyst', 'Excel', 80
    UNION ALL SELECT 'Healthcare Data Analyst', 'Clinical Data Management', 75
    UNION ALL SELECT 'Healthcare Data Analyst', 'SAS Programming', 65
    UNION ALL SELECT 'Healthcare Data Analyst', 'Medical Terminology', 70
    UNION ALL SELECT 'Healthcare Data Analyst', 'Power BI', 65
    UNION ALL SELECT 'Healthcare Data Analyst', 'Statistics & Probability', 65
    UNION ALL SELECT 'Medical Coder', 'ICD-10 Coding', 90
    UNION ALL SELECT 'Medical Coder', 'Medical Terminology', 85
    UNION ALL SELECT 'Medical Coder', 'Regulatory Compliance', 65
    UNION ALL SELECT 'Medical Coder', 'Excel', 60
    UNION ALL SELECT 'Pharmacovigilance Associate', 'Regulatory Compliance', 85
    UNION ALL SELECT 'Pharmacovigilance Associate', 'Medical Terminology', 75
    UNION ALL SELECT 'Pharmacovigilance Associate', 'Clinical Data Management', 70
    UNION ALL SELECT 'Pharmacovigilance Associate', 'Excel', 65
    -- Content & Media
    UNION ALL SELECT 'Content Writer', 'Copywriting', 85
    UNION ALL SELECT 'Content Writer', 'Storytelling', 85
    UNION ALL SELECT 'Content Writer', 'SEO Writing', 80
    UNION ALL SELECT 'Content Writer', 'Content Marketing', 70
    UNION ALL SELECT 'Content Writer', 'Social Media Strategy', 55
    UNION ALL SELECT 'Video Editor', 'Adobe Premiere Pro', 90
    UNION ALL SELECT 'Video Editor', 'Storytelling', 75
    UNION ALL SELECT 'Video Editor', 'Scriptwriting', 70
    UNION ALL SELECT 'Video Editor', 'Social Media Strategy', 55
    UNION ALL SELECT 'Journalist', 'Storytelling', 85
    UNION ALL SELECT 'Journalist', 'Scriptwriting', 75
    UNION ALL SELECT 'Journalist', 'Copywriting', 70
    UNION ALL SELECT 'Journalist', 'Social Media Strategy', 65
    UNION ALL SELECT 'Journalist', 'SEO Writing', 60
) t
JOIN `careers_v2` c ON c.name = t.career_name
JOIN `skills_v2` s ON s.name = t.skill_name;

-- =====================================================
-- 8) EXPANDED SEED DATA - ALL DOMAINS (generated)
-- =====================================================
-- >>> MEGA SEED BEGIN >>>
-- 27 domains / 81 careers / ~260 skills / 54 programs.
-- Generated by generate_seed.py - edit data there, then re-run it.

-- extra education categories
INSERT IGNORE INTO `education_categories` (`name`, `description`) VALUES
('Law', 'Legal studies and bar-track programs'),
('Vocational & Diploma', 'Polytechnic, ITI and certificate programs'),
('Education & Teaching', 'Teacher training and education degrees');

-- extra education programs (guarded by name)
INSERT INTO `education_programs` (`category_id`, `name`, `level`, `description`)
SELECT c.id, t.name, t.level, t.description
FROM (
    SELECT 'Computer Science & IT' AS category_name, 'B.Sc Computer Science' AS name, 'Undergraduate' AS level, 'Foundations of computing and programming' AS description
    UNION ALL SELECT 'Computer Science & IT' AS category_name, 'B.Tech Artificial Intelligence & Data Science' AS name, 'Undergraduate' AS level, 'Engineering degree focused on AI and data' AS description
    UNION ALL SELECT 'Computer Science & IT' AS category_name, 'M.Sc Information Technology' AS name, 'Postgraduate' AS level, 'Advanced IT systems and software' AS description
    UNION ALL SELECT 'Computer Science & IT' AS category_name, 'PG Diploma in Data Science' AS name, 'Postgraduate' AS level, 'One year applied data science diploma' AS description
    UNION ALL SELECT 'Engineering (Core)' AS category_name, 'B.Tech Automobile Engineering' AS name, 'Undergraduate' AS level, 'Vehicle design, engines and manufacturing' AS description
    UNION ALL SELECT 'Engineering (Core)' AS category_name, 'B.Tech Chemical Engineering' AS name, 'Undergraduate' AS level, 'Process design and chemical technology' AS description
    UNION ALL SELECT 'Engineering (Core)' AS category_name, 'M.Tech Structural Engineering' AS name, 'Postgraduate' AS level, 'Advanced structural analysis and design' AS description
    UNION ALL SELECT 'Engineering (Core)' AS category_name, 'M.Tech VLSI Design' AS name, 'Postgraduate' AS level, 'Chip design and semiconductor systems' AS description
    UNION ALL SELECT 'Business & Management' AS category_name, 'MBA Marketing' AS name, 'Postgraduate' AS level, 'Marketing strategy and brand management' AS description
    UNION ALL SELECT 'Business & Management' AS category_name, 'MBA Finance' AS name, 'Postgraduate' AS level, 'Corporate finance and investment management' AS description
    UNION ALL SELECT 'Business & Management' AS category_name, 'MBA Human Resources' AS name, 'Postgraduate' AS level, 'People management and organizational behaviour' AS description
    UNION ALL SELECT 'Business & Management' AS category_name, 'MBA Operations' AS name, 'Postgraduate' AS level, 'Supply chain and operations management' AS description
    UNION ALL SELECT 'Business & Management' AS category_name, 'BMS' AS name, 'Undergraduate' AS level, 'Bachelor of Management Studies' AS description
    UNION ALL SELECT 'Business & Management' AS category_name, 'Executive MBA' AS name, 'Postgraduate' AS level, 'MBA for working professionals' AS description
    UNION ALL SELECT 'Commerce & Finance' AS category_name, 'CA (Chartered Accountancy)' AS name, 'Professional' AS level, 'Accounting, audit and taxation qualification' AS description
    UNION ALL SELECT 'Commerce & Finance' AS category_name, 'CS (Company Secretary)' AS name, 'Professional' AS level, 'Corporate law and governance qualification' AS description
    UNION ALL SELECT 'Commerce & Finance' AS category_name, 'CMA (Cost & Management Accountancy)' AS name, 'Professional' AS level, 'Cost accounting and management' AS description
    UNION ALL SELECT 'Commerce & Finance' AS category_name, 'B.Com Accounting & Finance' AS name, 'Undergraduate' AS level, 'Specialized accounting and finance degree' AS description
    UNION ALL SELECT 'Commerce & Finance' AS category_name, 'B.Com Banking & Insurance' AS name, 'Undergraduate' AS level, 'Banking and insurance focused commerce degree' AS description
    UNION ALL SELECT 'Science' AS category_name, 'M.Sc Physics' AS name, 'Postgraduate' AS level, 'Advanced physics and research methods' AS description
    UNION ALL SELECT 'Science' AS category_name, 'M.Sc Mathematics' AS name, 'Postgraduate' AS level, 'Advanced pure and applied mathematics' AS description
    UNION ALL SELECT 'Science' AS category_name, 'M.Sc Chemistry' AS name, 'Postgraduate' AS level, 'Advanced chemistry and lab research' AS description
    UNION ALL SELECT 'Science' AS category_name, 'M.Sc Biotechnology' AS name, 'Postgraduate' AS level, 'Advanced biotech research and industry skills' AS description
    UNION ALL SELECT 'Science' AS category_name, 'B.Sc Microbiology' AS name, 'Undergraduate' AS level, 'Microbes, immunology and lab techniques' AS description
    UNION ALL SELECT 'Science' AS category_name, 'B.Sc Psychology' AS name, 'Undergraduate' AS level, 'Human behaviour and mental processes' AS description
    UNION ALL SELECT 'Science' AS category_name, 'M.Sc Psychology' AS name, 'Postgraduate' AS level, 'Advanced psychology and counselling basics' AS description
    UNION ALL SELECT 'Science' AS category_name, 'B.Sc Agriculture' AS name, 'Undergraduate' AS level, 'Crop science, soil and agri technology' AS description
    UNION ALL SELECT 'Arts, Design & Media' AS category_name, 'MA English' AS name, 'Postgraduate' AS level, 'Literature, language and academic writing' AS description
    UNION ALL SELECT 'Arts, Design & Media' AS category_name, 'B.Des Interior Design' AS name, 'Undergraduate' AS level, 'Space, materials and interior styling' AS description
    UNION ALL SELECT 'Arts, Design & Media' AS category_name, 'B.Des Fashion Design' AS name, 'Undergraduate' AS level, 'Apparel and textile design' AS description
    UNION ALL SELECT 'Arts, Design & Media' AS category_name, 'B.Sc Animation & VFX' AS name, 'Undergraduate' AS level, '2D/3D animation and visual effects' AS description
    UNION ALL SELECT 'Arts, Design & Media' AS category_name, 'MA Journalism' AS name, 'Postgraduate' AS level, 'Advanced reporting and media studies' AS description
    UNION ALL SELECT 'Arts, Design & Media' AS category_name, 'BMM' AS name, 'Undergraduate' AS level, 'Bachelor of Mass Media' AS description
    UNION ALL SELECT 'Health & Life Sciences' AS category_name, 'BDS' AS name, 'Professional' AS level, 'Bachelor of Dental Surgery' AS description
    UNION ALL SELECT 'Health & Life Sciences' AS category_name, 'BAMS' AS name, 'Professional' AS level, 'Ayurvedic medicine and surgery' AS description
    UNION ALL SELECT 'Health & Life Sciences' AS category_name, 'BHMS' AS name, 'Professional' AS level, 'Homeopathic medicine and surgery' AS description
    UNION ALL SELECT 'Health & Life Sciences' AS category_name, 'BPT (Physiotherapy)' AS name, 'Professional' AS level, 'Physical therapy and rehabilitation' AS description
    UNION ALL SELECT 'Health & Life Sciences' AS category_name, 'M.Pharm' AS name, 'Postgraduate' AS level, 'Advanced pharmacy and research' AS description
    UNION ALL SELECT 'Health & Life Sciences' AS category_name, 'GNM Nursing' AS name, 'Diploma' AS level, 'General Nursing and Midwifery diploma' AS description
    UNION ALL SELECT 'Law' AS category_name, 'LLB' AS name, 'Professional' AS level, 'Three year law degree for graduates' AS description
    UNION ALL SELECT 'Law' AS category_name, 'BA LLB' AS name, 'Professional' AS level, 'Five year integrated law degree' AS description
    UNION ALL SELECT 'Law' AS category_name, 'LLM' AS name, 'Postgraduate' AS level, 'Masters in a legal specialization' AS description
    UNION ALL SELECT 'Vocational & Diploma' AS category_name, 'Polytechnic Diploma (Engineering)' AS name, 'Diploma' AS level, 'Three year technical diploma after 10th' AS description
    UNION ALL SELECT 'Vocational & Diploma' AS category_name, 'ITI Electrician' AS name, 'Certificate' AS level, 'Trade certificate in electrical work' AS description
    UNION ALL SELECT 'Vocational & Diploma' AS category_name, 'ITI Fitter' AS name, 'Certificate' AS level, 'Trade certificate in fitting and assembly' AS description
    UNION ALL SELECT 'Vocational & Diploma' AS category_name, 'Diploma in Hotel Management' AS name, 'Diploma' AS level, 'Hospitality operations and service' AS description
    UNION ALL SELECT 'Vocational & Diploma' AS category_name, 'Certificate in Digital Marketing' AS name, 'Certificate' AS level, 'Short course on online marketing' AS description
    UNION ALL SELECT 'Vocational & Diploma' AS category_name, 'Diploma in Graphic Design' AS name, 'Diploma' AS level, 'Visual design and print media' AS description
    UNION ALL SELECT 'Vocational & Diploma' AS category_name, 'Diploma in Medical Lab Technology' AS name, 'Diploma' AS level, 'Clinical lab testing and diagnostics' AS description
    UNION ALL SELECT 'Education & Teaching' AS category_name, 'B.Ed' AS name, 'Professional' AS level, 'Bachelor of Education - required for school teaching' AS description
    UNION ALL SELECT 'Education & Teaching' AS category_name, 'M.Ed' AS name, 'Postgraduate' AS level, 'Master of Education' AS description
    UNION ALL SELECT 'Science' AS category_name, 'B.Tech Agricultural Engineering' AS name, 'Undergraduate' AS level, 'Farm machinery, irrigation and agri tech' AS description
) t
JOIN `education_categories` c ON c.name = t.category_name
LEFT JOIN `education_programs` p ON p.name = t.name
WHERE p.id IS NULL;

-- extra domains
INSERT IGNORE INTO `domains` (`name`, `description`) VALUES
('Data Engineering', 'Build the pipelines and platforms behind data products'),
('Game Development', 'Design and build games for PC, console and mobile'),
('Blockchain & Web3', 'Decentralized apps, smart contracts and crypto systems'),
('IoT & Embedded Systems', 'Software and hardware for connected devices'),
('Robotics & Automation', 'Robots, control systems and industrial automation'),
('Civil & Construction', 'Designing and building infrastructure'),
('Electrical & Power', 'Power systems, panels and industrial electricity'),
('Manufacturing & Industrial', 'Production planning, CNC and process optimization'),
('Automobile Engineering', 'Vehicle design, EVs and automotive testing'),
('Chemical & Process', 'Process plants, simulation and chemical operations'),
('Biotechnology & Pharma Research', 'Lab research, clinical trials and bioinformatics'),
('Nursing & Patient Care', 'Frontline clinical care and community health'),
('Teaching & Education', 'Teaching, academic research and course design'),
('Law & Legal Services', 'Corporate law, litigation and legal analysis'),
('Human Resources', 'Hiring, people operations and workplace culture'),
('Sales & Business Development', 'Revenue growth, clients and partnerships'),
('Banking & Insurance', 'Banking operations, credit and risk products'),
('Supply Chain & Logistics', 'Moving goods efficiently from source to customer'),
('Hospitality & Tourism', 'Hotels, food service and travel experiences'),
('Animation & VFX', 'Visual effects, 3D animation and motion design'),
('Graphic Design & Branding', 'Visual identities, print and brand systems'),
('Architecture & Interior Design', 'Buildings, spaces and urban environments'),
('Agriculture & AgriTech', 'Farming science and agri business'),
('Psychology & Counselling', 'Mental health, assessment and human behaviour'),
('Government & Public Administration', 'Civil services, policy and public sector careers'),
('QA & Software Testing', 'Manual, automation and performance testing'),
('E-commerce Operations', 'Online marketplaces, catalogs and D2C operations');

-- extra skills
INSERT IGNORE INTO `skills_v2` (`name`, `category`, `description`) VALUES
('3D Mathematics', 'Game Development', 'Core skill for game development roles'),
('3D Modeling', 'Animation & VFX', 'Core skill for animation & vfx roles'),
('3D Visualization', 'Architecture', 'Core skill for architecture & interior design roles'),
('API Testing', 'Quality Assurance', 'Core skill for qa & software testing roles'),
('Academic Writing', 'Education', 'Core skill for teaching & education roles'),
('Active Listening', 'Psychology', 'Core skill for psychology & counselling roles'),
('Adobe Illustrator', 'Design', 'Core skill for graphic design & branding roles'),
('Adobe Photoshop', 'Design', 'Core skill for graphic design & branding roles'),
('After Effects', 'Animation & VFX', 'Core skill for animation & vfx roles'),
('Agri Supply Chain', 'Agriculture', 'Core skill for agriculture & agritech roles'),
('Agronomy', 'Agriculture', 'Core skill for agriculture & agritech roles'),
('Amazon Seller Central', 'E-commerce', 'Core skill for e-commerce operations roles'),
('Analytical Chemistry', 'Chemical Engineering', 'Core skill for chemical & process roles'),
('Answer Writing Practice', 'Public Administration', 'Core skill for government & public administration roles'),
('Apache Airflow', 'Data Engineering', 'Core skill for data engineering roles'),
('Apache Kafka', 'Data Engineering', 'Core skill for data engineering roles'),
('Apache Spark', 'Data Engineering', 'Core skill for data engineering roles'),
('Arduino Programming', 'Embedded Systems', 'Core skill for iot & embedded systems roles'),
('Aspen HYSYS', 'Chemical Engineering', 'Core skill for chemical & process roles'),
('Assessment Design', 'Education', 'Core skill for teaching & education roles'),
('AutoCAD Electrical', 'Electrical Engineering', 'Core skill for electrical & power roles'),
('B2B Sales', 'Sales', 'Core skill for sales & business development roles'),
('Banking Operations', 'Banking & Insurance', 'Core skill for banking & insurance roles'),
('Battery Management Systems', 'Automobile', 'Core skill for automobile engineering roles'),
('Billing Engineering', 'Civil Engineering', 'Core skill for civil & construction roles'),
('Bioinformatics Tools', 'Biotechnology', 'Core skill for biotechnology & pharma research roles'),
('Blender', 'Game Development', 'Core skill for game development roles'),
('Branding', 'Design', 'Core skill for graphic design & branding roles'),
('Bug Tracking', 'Quality Assurance', 'Core skill for qa & software testing roles'),
('Building Codes', 'Architecture', 'Core skill for architecture & interior design roles'),
('C Programming', 'Embedded Systems', 'Core skill for iot & embedded systems roles'),
('C#', 'Game Development', 'Core skill for game development roles'),
('CAN Bus', 'Automobile', 'Core skill for automobile engineering roles'),
('CBT Basics', 'Psychology', 'Core skill for psychology & counselling roles'),
('CNC Programming', 'Manufacturing', 'Core skill for manufacturing & industrial roles'),
('CRM Tools', 'Sales', 'Core skill for sales & business development roles'),
('Cable Sizing', 'Electrical Engineering', 'Core skill for electrical & power roles'),
('Case Documentation', 'Psychology', 'Core skill for psychology & counselling roles'),
('Case Management', 'Law', 'Core skill for law & legal services roles'),
('Cell Culture', 'Biotechnology', 'Core skill for biotechnology & pharma research roles'),
('Character Animation', 'Animation & VFX', 'Core skill for animation & vfx roles'),
('Chemical Reaction Engineering', 'Chemical Engineering', 'Core skill for chemical & process roles'),
('Circuit Debugging', 'Embedded Systems', 'Core skill for iot & embedded systems roles'),
('Classroom Management', 'Education', 'Core skill for teaching & education roles'),
('Client Relationship Management', 'Sales', 'Core skill for sales & business development roles'),
('Clinical Diagnosis', 'Psychology', 'Core skill for psychology & counselling roles'),
('Clinical Trials', 'Biotechnology', 'Core skill for biotechnology & pharma research roles'),
('Cold Calling', 'Sales', 'Core skill for sales & business development roles'),
('Color Grading', 'Animation & VFX', 'Core skill for animation & vfx roles'),
('Color Theory', 'Design', 'Core skill for graphic design & branding roles'),
('Communication', 'Soft Skills', 'Clear written and verbal communication'),
('Community Health', 'Nursing', 'Core skill for nursing & patient care roles'),
('Compliance', 'Law', 'Core skill for law & legal services roles'),
('Compositing', 'Animation & VFX', 'Core skill for animation & vfx roles'),
('Concrete Technology', 'Civil Engineering', 'Core skill for civil & construction roles'),
('Construction Management', 'Civil Engineering', 'Core skill for civil & construction roles'),
('Content Quality Review', 'E-commerce', 'Core skill for e-commerce operations roles'),
('Contract Drafting', 'Law', 'Core skill for law & legal services roles'),
('Contract Management', 'Civil Engineering', 'Core skill for civil & construction roles'),
('Control Systems', 'Robotics', 'Core skill for robotics & automation roles'),
('Corporate Law', 'Law', 'Core skill for law & legal services roles'),
('Cost Analysis', 'Supply Chain', 'Core skill for supply chain & logistics roles'),
('Counselling Techniques', 'Psychology', 'Core skill for psychology & counselling roles'),
('Court Procedures', 'Law', 'Core skill for law & legal services roles'),
('Credit Analysis', 'Banking & Insurance', 'Core skill for banking & insurance roles'),
('Critical Care Nursing', 'Nursing', 'Core skill for nursing & patient care roles'),
('Crop Management', 'Agriculture', 'Core skill for agriculture & agritech roles'),
('Culinary Arts', 'Hospitality', 'Core skill for hospitality & tourism roles'),
('Current Affairs', 'Public Administration', 'Core skill for government & public administration roles'),
('Curriculum Design', 'Education', 'Core skill for teaching & education roles'),
('Customer Service', 'Banking & Insurance', 'Core skill for banking & insurance roles'),
('Data Acquisition', 'Automobile', 'Core skill for automobile engineering roles'),
('Data Modeling', 'Data Engineering', 'Core skill for data engineering roles'),
('Data Warehousing', 'Data Engineering', 'Core skill for data engineering roles'),
('Demand Forecasting', 'Supply Chain', 'Core skill for supply chain & logistics roles'),
('Destination Knowledge', 'Hospitality', 'Core skill for hospitality & tourism roles'),
('Device Drivers', 'Embedded Systems', 'Core skill for iot & embedded systems roles'),
('Digital Cataloging', 'E-commerce', 'Core skill for e-commerce operations roles'),
('Drafting & Pleadings', 'Law', 'Core skill for law & legal services roles'),
('E-commerce Platforms', 'E-commerce', 'Core skill for e-commerce operations roles'),
('E-commerce SEO', 'E-commerce', 'Core skill for e-commerce operations roles'),
('E-learning Tools', 'Education', 'Core skill for teaching & education roles'),
('ETABS', 'Civil Engineering', 'Core skill for civil & construction roles'),
('ETAP', 'Electrical Engineering', 'Core skill for electrical & power roles'),
('ETL Design', 'Data Engineering', 'Core skill for data engineering roles'),
('Economics Basics', 'Public Administration', 'Core skill for government & public administration roles'),
('Educational Technology', 'Education', 'Core skill for teaching & education roles'),
('Electric Vehicle Architecture', 'Automobile', 'Core skill for automobile engineering roles'),
('Electrical Design', 'Electrical Engineering', 'Core skill for electrical & power roles'),
('Embedded C', 'Embedded Systems', 'Core skill for iot & embedded systems roles'),
('Employee Engagement', 'Human Resources', 'Core skill for human resources roles'),
('English Language', 'Public Administration', 'Core skill for government & public administration roles'),
('Essay Writing', 'Public Administration', 'Core skill for government & public administration roles'),
('Estimation & Costing', 'Civil Engineering', 'Core skill for civil & construction roles'),
('Ethereum', 'Blockchain', 'Core skill for blockchain & web3 roles'),
('Ethics in Psychology', 'Psychology', 'Core skill for psychology & counselling roles'),
('Field Research', 'Agriculture', 'Core skill for agriculture & agritech roles'),
('Financial Products', 'Banking & Insurance', 'Core skill for banking & insurance roles'),
('Financial Statement Analysis', 'Banking & Insurance', 'Core skill for banking & insurance roles'),
('First Aid & BLS', 'Nursing', 'Core skill for nursing & patient care roles'),
('Food Safety & Hygiene', 'Hospitality', 'Core skill for hospitality & tourism roles'),
('Foundation Design', 'Civil Engineering', 'Core skill for civil & construction roles'),
('Front Office Operations', 'Hospitality', 'Core skill for hospitality & tourism roles'),
('GCP Guidelines', 'Biotechnology', 'Core skill for biotechnology & pharma research roles'),
('GDS Systems', 'Hospitality', 'Core skill for hospitality & tourism roles'),
('GIS Tools', 'Architecture', 'Core skill for architecture & interior design roles'),
('Game Design Fundamentals', 'Game Development', 'Core skill for game development roles'),
('Game Physics', 'Game Development', 'Core skill for game development roles'),
('General Awareness', 'Public Administration', 'Core skill for government & public administration roles'),
('General Studies', 'Public Administration', 'Core skill for government & public administration roles'),
('Genomics', 'Biotechnology', 'Core skill for biotechnology & pharma research roles'),
('Guest Relations', 'Hospitality', 'Core skill for hospitality & tourism roles'),
('HAZOP Basics', 'Chemical Engineering', 'Core skill for chemical & process roles'),
('HMI Development', 'Robotics', 'Core skill for robotics & automation roles'),
('HR Analytics', 'Human Resources', 'Core skill for human resources roles'),
('HRMS Tools', 'Human Resources', 'Core skill for human resources roles'),
('Hadoop', 'Data Engineering', 'Core skill for data engineering roles'),
('Health Education', 'Nursing', 'Core skill for nursing & patient care roles'),
('Heat & Mass Transfer', 'Chemical Engineering', 'Core skill for chemical & process roles'),
('Homologation', 'Automobile', 'Core skill for automobile engineering roles'),
('InDesign', 'Design', 'Core skill for graphic design & branding roles'),
('Indian Electricity Rules', 'Electrical Engineering', 'Core skill for electrical & power roles'),
('Indian History & Geography', 'Public Administration', 'Core skill for government & public administration roles'),
('Indian Polity', 'Public Administration', 'Core skill for government & public administration roles'),
('Industrial Wiring', 'Robotics', 'Core skill for robotics & automation roles'),
('Infection Control', 'Nursing', 'Core skill for nursing & patient care roles'),
('Instrumentation', 'Electrical Engineering', 'Core skill for electrical & power roles'),
('Insurance Products', 'Banking & Insurance', 'Core skill for banking & insurance roles'),
('Intellectual Property', 'Law', 'Core skill for law & legal services roles'),
('Interviewing', 'Human Resources', 'Core skill for human resources roles'),
('Inventory Management', 'Supply Chain', 'Core skill for supply chain & logistics roles'),
('JIRA', 'Quality Assurance', 'Core skill for qa & software testing roles'),
('JMeter', 'Quality Assurance', 'Core skill for qa & software testing roles'),
('KYC & AML', 'Banking & Insurance', 'Core skill for banking & insurance roles'),
('Kaizen', 'Manufacturing', 'Core skill for manufacturing & industrial roles'),
('Kinematics', 'Robotics', 'Core skill for robotics & automation roles'),
('Kitchen Management', 'Hospitality', 'Core skill for hospitality & tourism roles'),
('Lab Techniques', 'Chemical Engineering', 'Core skill for chemical & process roles'),
('Labour Laws', 'Human Resources', 'Core skill for human resources roles'),
('Ladder Logic', 'Electrical Engineering', 'Core skill for electrical & power roles'),
('Layout Design', 'Design', 'Core skill for graphic design & branding roles'),
('Lead Generation', 'Sales', 'Core skill for sales & business development roles'),
('Leadership', 'Soft Skills', 'Leading people and initiatives'),
('Lean Manufacturing', 'Manufacturing', 'Core skill for manufacturing & industrial roles'),
('Learning Management Systems', 'Education', 'Core skill for teaching & education roles'),
('Legal Research', 'Law', 'Core skill for law & legal services roles'),
('Lesson Planning', 'Education', 'Core skill for teaching & education roles'),
('Level Design', 'Game Development', 'Core skill for game development roles'),
('Litigation', 'Law', 'Core skill for law & legal services roles'),
('LoadRunner', 'Quality Assurance', 'Core skill for qa & software testing roles'),
('Logical Reasoning', 'Public Administration', 'Core skill for government & public administration roles'),
('Logistics Planning', 'Supply Chain', 'Core skill for supply chain & logistics roles'),
('M&A Basics', 'Law', 'Core skill for law & legal services roles'),
('MATLAB', 'Robotics', 'Core skill for robotics & automation roles'),
('MQTT', 'Embedded Systems', 'Core skill for iot & embedded systems roles'),
('Machine Tools', 'Manufacturing', 'Core skill for manufacturing & industrial roles'),
('Manual Testing', 'Quality Assurance', 'Core skill for qa & software testing roles'),
('Market Research', 'Sales', 'Core skill for sales & business development roles'),
('Mastercam', 'Manufacturing', 'Core skill for manufacturing & industrial roles'),
('Material Selection', 'Architecture', 'Core skill for architecture & interior design roles'),
('Maya', 'Animation & VFX', 'Core skill for animation & vfx roles'),
('Medical Documentation', 'Nursing', 'Core skill for nursing & patient care roles'),
('Medication Administration', 'Nursing', 'Core skill for nursing & patient care roles'),
('Menu Planning', 'Hospitality', 'Core skill for hospitality & tourism roles'),
('Microcontrollers', 'Embedded Systems', 'Core skill for iot & embedded systems roles'),
('Molecular Biology', 'Biotechnology', 'Core skill for biotechnology & pharma research roles'),
('Motion Graphics', 'Animation & VFX', 'Core skill for animation & vfx roles'),
('Negotiation', 'Law', 'Core skill for law & legal services roles'),
('Nuke', 'Animation & VFX', 'Core skill for animation & vfx roles'),
('Onboarding', 'Human Resources', 'Core skill for human resources roles'),
('Operations Research', 'Manufacturing', 'Core skill for manufacturing & industrial roles'),
('Order Management', 'E-commerce', 'Core skill for e-commerce operations roles'),
('P&ID Reading', 'Chemical Engineering', 'Core skill for chemical & process roles'),
('PCR Techniques', 'Biotechnology', 'Core skill for biotechnology & pharma research roles'),
('PLC Programming', 'Robotics', 'Core skill for robotics & automation roles'),
('Panel Design', 'Electrical Engineering', 'Core skill for electrical & power roles'),
('Patient Care', 'Nursing', 'Core skill for nursing & patient care roles'),
('Payroll Processing', 'Human Resources', 'Core skill for human resources roles'),
('Performance Management', 'Human Resources', 'Core skill for human resources roles'),
('Performance Optimization', 'Game Development', 'Core skill for game development roles'),
('Performance Testing', 'Quality Assurance', 'Core skill for qa & software testing roles'),
('Pest & Disease Management', 'Agriculture', 'Core skill for agriculture & agritech roles'),
('Pipeline Management', 'Sales', 'Core skill for sales & business development roles'),
('Plant Operations', 'Chemical Engineering', 'Core skill for chemical & process roles'),
('Policy Analysis', 'Architecture', 'Core skill for architecture & interior design roles'),
('Power System Analysis', 'Electrical Engineering', 'Core skill for electrical & power roles'),
('Powertrain Systems', 'Automobile', 'Core skill for automobile engineering roles'),
('Precision Farming', 'Agriculture', 'Core skill for agriculture & agritech roles'),
('Print Production', 'Design', 'Core skill for graphic design & branding roles'),
('Problem Solving', 'Soft Skills', 'Structured thinking and troubleshooting'),
('Process Control', 'Chemical Engineering', 'Core skill for chemical & process roles'),
('Process Simulation', 'Chemical Engineering', 'Core skill for chemical & process roles'),
('Procurement', 'Supply Chain', 'Core skill for supply chain & logistics roles'),
('Product Knowledge', 'Sales', 'Core skill for sales & business development roles'),
('Product Listing', 'E-commerce', 'Core skill for e-commerce operations roles'),
('Production Planning', 'Manufacturing', 'Core skill for manufacturing & industrial roles'),
('Protection Systems', 'Electrical Engineering', 'Core skill for electrical & power roles'),
('Psychological Assessment', 'Psychology', 'Core skill for psychology & counselling roles'),
('Quantitative Aptitude', 'Banking & Insurance', 'Core skill for banking & insurance roles'),
('RCC Design', 'Civil Engineering', 'Core skill for civil & construction roles'),
('ROS', 'Robotics', 'Core skill for robotics & automation roles'),
('RTOS', 'Embedded Systems', 'Core skill for iot & embedded systems roles'),
('Raspberry Pi', 'Embedded Systems', 'Core skill for iot & embedded systems roles'),
('Rate Analysis', 'Civil Engineering', 'Core skill for civil & construction roles'),
('Recruitment', 'Human Resources', 'Core skill for human resources roles'),
('Renewable Energy Systems', 'Electrical Engineering', 'Core skill for electrical & power roles'),
('Report Writing', 'Soft Skills', 'Structured professional documentation'),
('Research Methods', 'Education', 'Core skill for teaching & education roles'),
('Reservation Systems', 'Hospitality', 'Core skill for hospitality & tourism roles'),
('Revit', 'Architecture', 'Core skill for architecture & interior design roles'),
('Risk Assessment', 'Banking & Insurance', 'Core skill for banking & insurance roles'),
('Route Optimization', 'Supply Chain', 'Core skill for supply chain & logistics roles'),
('SAP MM', 'Supply Chain', 'Core skill for supply chain & logistics roles'),
('SCADA', 'Robotics', 'Core skill for robotics & automation roles'),
('SDLC & STLC', 'Quality Assurance', 'Core skill for qa & software testing roles'),
('SEO Writing', 'E-commerce', 'Core skill for e-commerce operations roles'),
('STAAD Pro', 'Civil Engineering', 'Core skill for civil & construction roles'),
('Safety Procedures', 'Chemical Engineering', 'Core skill for chemical & process roles'),
('Sales Techniques', 'Sales', 'Prospecting, pitching and closing'),
('Scala', 'Data Engineering', 'Core skill for data engineering roles'),
('Selenium', 'Quality Assurance', 'Core skill for qa & software testing roles'),
('Sensor Fusion', 'Robotics', 'Core skill for robotics & automation roles'),
('Sensor Integration', 'Embedded Systems', 'Core skill for iot & embedded systems roles'),
('Shader Programming', 'Game Development', 'Core skill for game development roles'),
('Simulink', 'Automobile', 'Core skill for automobile engineering roles'),
('Site Planning', 'Architecture', 'Core skill for architecture & interior design roles'),
('SketchUp', 'Architecture', 'Core skill for architecture & interior design roles'),
('Smart Contracts', 'Blockchain', 'Core skill for blockchain & web3 roles'),
('Soil Chemistry', 'Agriculture', 'Core skill for agriculture & agritech roles'),
('Soil Testing', 'Agriculture', 'Core skill for agriculture & agritech roles'),
('Solidity', 'Blockchain', 'Core skill for blockchain & web3 roles'),
('Sourcing Strategies', 'Human Resources', 'Core skill for human resources roles'),
('Space Planning', 'Architecture', 'Core skill for architecture & interior design roles'),
('Spectroscopy', 'Chemical Engineering', 'Core skill for chemical & process roles'),
('Storyboarding', 'Education', 'Core skill for teaching & education roles'),
('Structural Analysis', 'Civil Engineering', 'Core skill for civil & construction roles'),
('Subject Expertise', 'Education', 'Core skill for teaching & education roles'),
('Supply Chain Basics', 'E-commerce', 'Core skill for e-commerce operations roles'),
('Surveying', 'Civil Engineering', 'Core skill for civil & construction roles'),
('Sustainable Design', 'Architecture', 'Core skill for architecture & interior design roles'),
('Teamwork & Collaboration', 'Soft Skills', 'Working effectively in teams'),
('Test Automation', 'Quality Assurance', 'Core skill for qa & software testing roles'),
('Test Case Design', 'Quality Assurance', 'Core skill for qa & software testing roles'),
('Texturing & Lighting', 'Animation & VFX', 'Core skill for animation & vfx roles'),
('Thermal Management', 'Automobile', 'Core skill for automobile engineering roles'),
('Time Management', 'Soft Skills', 'Prioritizing work and meeting deadlines'),
('Time Study', 'Manufacturing', 'Core skill for manufacturing & industrial roles'),
('Travel Planning', 'Hospitality', 'Core skill for hospitality & tourism roles'),
('Triage', 'Nursing', 'Core skill for nursing & patient care roles'),
('Typography', 'Animation & VFX', 'Core skill for animation & vfx roles'),
('Underwriting Guidelines', 'Banking & Insurance', 'Core skill for banking & insurance roles'),
('Unity', 'Game Development', 'Core skill for game development roles'),
('Unreal Engine', 'Game Development', 'Core skill for game development roles'),
('Upselling & Cross-selling', 'Sales', 'Core skill for sales & business development roles'),
('Urban Planning', 'Architecture', 'Core skill for architecture & interior design roles'),
('Vehicle Dynamics', 'Automobile', 'Core skill for automobile engineering roles'),
('Vendor Management', 'Supply Chain', 'Core skill for supply chain & logistics roles'),
('Ventilator Management', 'Nursing', 'Core skill for nursing & patient care roles'),
('Visual Identity Design', 'Design', 'Core skill for graphic design & branding roles'),
('Web3 Security', 'Blockchain', 'Core skill for blockchain & web3 roles'),
('Web3.js', 'Blockchain', 'Core skill for blockchain & web3 roles'),
('dbt', 'Data Engineering', 'Core skill for data engineering roles');

-- extra careers (guarded by name)
INSERT INTO `careers_v2` (`domain_id`, `name`, `description`, `average_level`)
SELECT d.id, t.name, t.description, t.avg_level
FROM (
    SELECT 'Data Engineering' AS domain_name, 'Data Engineer' AS name, 'Build reliable data pipelines and platforms' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Data Engineering' AS domain_name, 'Analytics Engineer' AS name, 'Model clean data marts for analytics teams' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Data Engineering' AS domain_name, 'Big Data Engineer' AS name, 'Process massive datasets on distributed systems' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Game Development' AS domain_name, 'Game Developer' AS name, 'Build gameplay systems and ship games' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Game Development' AS domain_name, 'Unity Developer' AS name, 'Create 3D/2D games in the Unity engine' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Game Development' AS domain_name, 'Level Designer' AS name, 'Design engaging levels and player flows' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Blockchain & Web3' AS domain_name, 'Blockchain Developer' AS name, 'Build decentralized applications' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Blockchain & Web3' AS domain_name, 'Smart Contract Auditor' AS name, 'Find vulnerabilities in smart contracts' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Blockchain & Web3' AS domain_name, 'Web3 Frontend Developer' AS name, 'Build dApp interfaces connected to wallets' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'IoT & Embedded Systems' AS domain_name, 'Embedded Systems Engineer' AS name, 'Program microcontrollers at the hardware level' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'IoT & Embedded Systems' AS domain_name, 'IoT Developer' AS name, 'Connect devices to cloud platforms' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'IoT & Embedded Systems' AS domain_name, 'Firmware Engineer' AS name, 'Write low-level firmware for devices' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Robotics & Automation' AS domain_name, 'Robotics Engineer' AS name, 'Design and program robotic systems' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Robotics & Automation' AS domain_name, 'Automation Engineer' AS name, 'Automate industrial processes' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Robotics & Automation' AS domain_name, 'Mechatronics Engineer' AS name, 'Blend mechanics, electronics and software' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Civil & Construction' AS domain_name, 'Civil Engineer' AS name, 'Plan and supervise construction projects' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Civil & Construction' AS domain_name, 'Structural Engineer' AS name, 'Design safe structural systems' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Civil & Construction' AS domain_name, 'Quantity Surveyor' AS name, 'Estimate and control construction costs' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Electrical & Power' AS domain_name, 'Electrical Design Engineer' AS name, 'Design electrical systems and panels' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Electrical & Power' AS domain_name, 'Power Systems Engineer' AS name, 'Analyze and maintain power networks' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Electrical & Power' AS domain_name, 'PLC Automation Engineer' AS name, 'Program industrial control systems' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Manufacturing & Industrial' AS domain_name, 'Production Engineer' AS name, 'Run efficient production lines' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Manufacturing & Industrial' AS domain_name, 'CNC Programmer' AS name, 'Program CNC machines for precision parts' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Manufacturing & Industrial' AS domain_name, 'Industrial Engineer' AS name, 'Optimize systems, time and resources' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Automobile Engineering' AS domain_name, 'Automotive Design Engineer' AS name, 'Design vehicle systems and components' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Automobile Engineering' AS domain_name, 'EV Design Engineer' AS name, 'Design electric vehicle systems' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Automobile Engineering' AS domain_name, 'Vehicle Testing Engineer' AS name, 'Validate vehicles against standards' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Chemical & Process' AS domain_name, 'Process Engineer' AS name, 'Design and optimize chemical processes' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Chemical & Process' AS domain_name, 'Plant Operations Engineer' AS name, 'Run safe and efficient plant operations' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Chemical & Process' AS domain_name, 'R&D Chemist' AS name, 'Research and develop chemical products' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Biotechnology & Pharma Research' AS domain_name, 'Biotech Research Associate' AS name, 'Run wet-lab experiments and studies' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Biotechnology & Pharma Research' AS domain_name, 'Clinical Research Associate' AS name, 'Monitor clinical trials end to end' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Biotechnology & Pharma Research' AS domain_name, 'Bioinformatics Analyst' AS name, 'Analyze genomic data computationally' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Nursing & Patient Care' AS domain_name, 'Staff Nurse' AS name, 'Provide frontline patient care' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Nursing & Patient Care' AS domain_name, 'ICU Nurse' AS name, 'Care for critical patients in ICUs' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Nursing & Patient Care' AS domain_name, 'Community Health Officer' AS name, 'Deliver preventive community healthcare' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Teaching & Education' AS domain_name, 'School Teacher' AS name, 'Teach and mentor school students' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Teaching & Education' AS domain_name, 'Assistant Professor' AS name, 'Teach and research at university level' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Teaching & Education' AS domain_name, 'Instructional Designer' AS name, 'Design effective learning experiences' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Law & Legal Services' AS domain_name, 'Corporate Lawyer' AS name, 'Advise companies on deals and compliance' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Law & Legal Services' AS domain_name, 'Litigation Advocate' AS name, 'Represent clients in court' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Law & Legal Services' AS domain_name, 'Legal Analyst' AS name, 'Research and analyze legal matters' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Human Resources' AS domain_name, 'HR Executive' AS name, 'Handle day-to-day HR operations' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Human Resources' AS domain_name, 'Talent Acquisition Specialist' AS name, 'Find and hire great candidates' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Human Resources' AS domain_name, 'HR Business Partner' AS name, 'Align people strategy with business goals' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Sales & Business Development' AS domain_name, 'Sales Executive' AS name, 'Sell products and hit revenue targets' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Sales & Business Development' AS domain_name, 'Business Development Manager' AS name, 'Grow revenue through new business' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Sales & Business Development' AS domain_name, 'Account Manager' AS name, 'Retain and grow key client accounts' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Banking & Insurance' AS domain_name, 'Bank Probationary Officer' AS name, 'Manage branch banking operations' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Banking & Insurance' AS domain_name, 'Credit Analyst' AS name, 'Assess creditworthiness of borrowers' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Banking & Insurance' AS domain_name, 'Insurance Underwriter' AS name, 'Price and accept insurance risks' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Supply Chain & Logistics' AS domain_name, 'Supply Chain Analyst' AS name, 'Optimize inventory and supply flows' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Supply Chain & Logistics' AS domain_name, 'Logistics Coordinator' AS name, 'Coordinate shipments and deliveries' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Supply Chain & Logistics' AS domain_name, 'Procurement Specialist' AS name, 'Buy goods and services smartly' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Hospitality & Tourism' AS domain_name, 'Front Office Executive' AS name, 'Run hotel reception and guest services' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Hospitality & Tourism' AS domain_name, 'Chef' AS name, 'Create menus and lead kitchen production' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Hospitality & Tourism' AS domain_name, 'Travel Consultant' AS name, 'Plan and book travel experiences' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Animation & VFX' AS domain_name, 'VFX Artist' AS name, 'Create cinematic visual effects' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Animation & VFX' AS domain_name, '3D Animator' AS name, 'Bring characters and worlds to life' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Animation & VFX' AS domain_name, 'Motion Graphics Designer' AS name, 'Animate graphics for video and web' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Graphic Design & Branding' AS domain_name, 'Graphic Designer' AS name, 'Design visuals for print and digital' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Graphic Design & Branding' AS domain_name, 'Brand Designer' AS name, 'Build complete brand identities' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Graphic Design & Branding' AS domain_name, 'Print & Layout Designer' AS name, 'Design print-ready publications' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'Architecture & Interior Design' AS domain_name, 'Architect' AS name, 'Design buildings and oversee projects' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Architecture & Interior Design' AS domain_name, 'Interior Designer' AS name, 'Design functional beautiful interiors' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Architecture & Interior Design' AS domain_name, 'Urban Planner' AS name, 'Plan cities and public spaces' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Agriculture & AgriTech' AS domain_name, 'Agronomist' AS name, 'Improve crop yield and soil health' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Agriculture & AgriTech' AS domain_name, 'Agri Business Manager' AS name, 'Run agri products and supply businesses' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Agriculture & AgriTech' AS domain_name, 'Soil Scientist' AS name, 'Study and classify soils' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Psychology & Counselling' AS domain_name, 'Counselling Psychologist' AS name, 'Support clients through life challenges' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Psychology & Counselling' AS domain_name, 'Clinical Psychologist' AS name, 'Assess and treat mental health conditions' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Psychology & Counselling' AS domain_name, 'HR Psychologist' AS name, 'Apply psychology to workplaces' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Government & Public Administration' AS domain_name, 'Civil Services Officer (UPSC)' AS name, 'Serve in IAS, IPS and allied services' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'Government & Public Administration' AS domain_name, 'Public Policy Analyst' AS name, 'Research and evaluate public policies' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'Government & Public Administration' AS domain_name, 'Government Officer (SSC/Banking)' AS name, 'Crack SSC, banking and state exams' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'QA & Software Testing' AS domain_name, 'QA Analyst' AS name, 'Test software manually and report defects' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'QA & Software Testing' AS domain_name, 'Automation Test Engineer' AS name, 'Automate regression test suites' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'QA & Software Testing' AS domain_name, 'Performance Test Engineer' AS name, 'Stress-test systems for scale' AS description, 'Advanced' AS avg_level
    UNION ALL SELECT 'E-commerce Operations' AS domain_name, 'E-commerce Manager' AS name, 'Run online stores and marketplaces' AS description, 'Intermediate' AS avg_level
    UNION ALL SELECT 'E-commerce Operations' AS domain_name, 'Marketplace Specialist' AS name, 'Grow sales on Amazon and Flipkart' AS description, 'Beginner' AS avg_level
    UNION ALL SELECT 'E-commerce Operations' AS domain_name, 'Catalog Quality Specialist' AS name, 'Keep product data clean and complete' AS description, 'Beginner' AS avg_level
) t
JOIN `domains` d ON d.name = t.domain_name
LEFT JOIN `careers_v2` c ON c.name = t.name
WHERE c.id IS NULL;

-- extra career-skill requirements (chunked)
INSERT IGNORE INTO `career_skill_requirements` (`career_id`, `skill_id`, `required_level`)
SELECT c.id, s.id, t.required_level
FROM (
    SELECT 'Data Engineer' AS career_name, 'SQL' AS skill_name, 90 AS required_level
    UNION ALL SELECT 'Data Engineer' AS career_name, 'Python' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Data Engineer' AS career_name, 'Apache Spark' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Data Engineer' AS career_name, 'ETL Design' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Data Engineer' AS career_name, 'Data Warehousing' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Data Engineer' AS career_name, 'Apache Airflow' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Data Engineer' AS career_name, 'Docker' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Analytics Engineer' AS career_name, 'SQL' AS skill_name, 90 AS required_level
    UNION ALL SELECT 'Analytics Engineer' AS career_name, 'dbt' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Analytics Engineer' AS career_name, 'Data Warehousing' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Analytics Engineer' AS career_name, 'Power BI' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Analytics Engineer' AS career_name, 'Data Modeling' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Analytics Engineer' AS career_name, 'Git & GitHub' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Big Data Engineer' AS career_name, 'Apache Spark' AS skill_name, 90 AS required_level
    UNION ALL SELECT 'Big Data Engineer' AS career_name, 'Apache Kafka' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Big Data Engineer' AS career_name, 'Hadoop' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Big Data Engineer' AS career_name, 'Python' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Big Data Engineer' AS career_name, 'Scala' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Big Data Engineer' AS career_name, 'Data Warehousing' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Game Developer' AS career_name, 'Unity' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Game Developer' AS career_name, 'C#' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Game Developer' AS career_name, 'Game Design Fundamentals' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Game Developer' AS career_name, 'Game Physics' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Game Developer' AS career_name, 'Blender' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Game Developer' AS career_name, 'Git & GitHub' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Unity Developer' AS career_name, 'Unity' AS skill_name, 90 AS required_level
    UNION ALL SELECT 'Unity Developer' AS career_name, 'C#' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Unity Developer' AS career_name, '3D Mathematics' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Unity Developer' AS career_name, 'Shader Programming' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Unity Developer' AS career_name, 'Git & GitHub' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Unity Developer' AS career_name, 'Performance Optimization' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Level Designer' AS career_name, 'Level Design' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Level Designer' AS career_name, 'Game Design Fundamentals' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Level Designer' AS career_name, 'Unreal Engine' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Level Designer' AS career_name, 'Blender' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Level Designer' AS career_name, 'Prototyping' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Level Designer' AS career_name, 'Scriptwriting' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Blockchain Developer' AS career_name, 'Solidity' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Blockchain Developer' AS career_name, 'Smart Contracts' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Blockchain Developer' AS career_name, 'Ethereum' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Blockchain Developer' AS career_name, 'Cryptography' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Blockchain Developer' AS career_name, 'Web3.js' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Blockchain Developer' AS career_name, 'JavaScript' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Smart Contract Auditor' AS career_name, 'Smart Contracts' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Smart Contract Auditor' AS career_name, 'Web3 Security' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Smart Contract Auditor' AS career_name, 'Solidity' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Smart Contract Auditor' AS career_name, 'Cryptography' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Smart Contract Auditor' AS career_name, 'Ethereum' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Smart Contract Auditor' AS career_name, 'Python' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Web3 Frontend Developer' AS career_name, 'JavaScript' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Web3 Frontend Developer' AS career_name, 'Web3.js' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Web3 Frontend Developer' AS career_name, 'React' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Web3 Frontend Developer' AS career_name, 'HTML & CSS' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Web3 Frontend Developer' AS career_name, 'TypeScript' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Web3 Frontend Developer' AS career_name, 'Ethereum' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Embedded Systems Engineer' AS career_name, 'Embedded C' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Embedded Systems Engineer' AS career_name, 'Microcontrollers' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Embedded Systems Engineer' AS career_name, 'C Programming' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Embedded Systems Engineer' AS career_name, 'RTOS' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Embedded Systems Engineer' AS career_name, 'Circuit Debugging' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Embedded Systems Engineer' AS career_name, 'Git & GitHub' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'IoT Developer' AS career_name, 'Arduino Programming' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'IoT Developer' AS career_name, 'Raspberry Pi' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'IoT Developer' AS career_name, 'MQTT' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'IoT Developer' AS career_name, 'Sensor Integration' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'IoT Developer' AS career_name, 'Python' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'IoT Developer' AS career_name, 'AWS' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Firmware Engineer' AS career_name, 'Embedded C' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Firmware Engineer' AS career_name, 'C Programming' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Firmware Engineer' AS career_name, 'Microcontrollers' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Firmware Engineer' AS career_name, 'RTOS' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Firmware Engineer' AS career_name, 'Device Drivers' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Firmware Engineer' AS career_name, 'Linux Administration' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Robotics Engineer' AS career_name, 'Control Systems' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Robotics Engineer' AS career_name, 'ROS' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Robotics Engineer' AS career_name, 'Kinematics' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Robotics Engineer' AS career_name, 'Python' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Robotics Engineer' AS career_name, 'MATLAB' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Robotics Engineer' AS career_name, 'Sensor Fusion' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Automation Engineer' AS career_name, 'PLC Programming' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Automation Engineer' AS career_name, 'Control Systems' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Automation Engineer' AS career_name, 'SCADA' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Automation Engineer' AS career_name, 'HMI Development' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Automation Engineer' AS career_name, 'Industrial Wiring' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Automation Engineer' AS career_name, 'Manufacturing Processes' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Mechatronics Engineer' AS career_name, 'Control Systems' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Mechatronics Engineer' AS career_name, 'Embedded C' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Mechatronics Engineer' AS career_name, 'SolidWorks' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Mechatronics Engineer' AS career_name, 'Sensor Fusion' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Mechatronics Engineer' AS career_name, 'MATLAB' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Mechatronics Engineer' AS career_name, 'Microcontrollers' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Civil Engineer' AS career_name, 'AutoCAD' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Civil Engineer' AS career_name, 'Structural Analysis' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Civil Engineer' AS career_name, 'Estimation & Costing' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Civil Engineer' AS career_name, 'Construction Management' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Civil Engineer' AS career_name, 'Surveying' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Civil Engineer' AS career_name, 'Concrete Technology' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Structural Engineer' AS career_name, 'STAAD Pro' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Structural Engineer' AS career_name, 'Structural Analysis' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Structural Engineer' AS career_name, 'ETABS' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Structural Engineer' AS career_name, 'RCC Design' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Structural Engineer' AS career_name, 'AutoCAD' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Structural Engineer' AS career_name, 'Foundation Design' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Quantity Surveyor' AS career_name, 'Estimation & Costing' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Quantity Surveyor' AS career_name, 'Excel' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Quantity Surveyor' AS career_name, 'Billing Engineering' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Quantity Surveyor' AS career_name, 'Rate Analysis' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Quantity Surveyor' AS career_name, 'AutoCAD' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Quantity Surveyor' AS career_name, 'Contract Management' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Electrical Design Engineer' AS career_name, 'AutoCAD Electrical' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Electrical Design Engineer' AS career_name, 'Electrical Design' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Electrical Design Engineer' AS career_name, 'Panel Design' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Electrical Design Engineer' AS career_name, 'ETAP' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Electrical Design Engineer' AS career_name, 'Cable Sizing' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Electrical Design Engineer' AS career_name, 'Indian Electricity Rules' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Power Systems Engineer' AS career_name, 'Power System Analysis' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Power Systems Engineer' AS career_name, 'ETAP' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Power Systems Engineer' AS career_name, 'Protection Systems' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Power Systems Engineer' AS career_name, 'MATLAB' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Power Systems Engineer' AS career_name, 'SCADA' AS skill_name, 70 AS required_level
) t
JOIN `careers_v2` c ON c.name = t.career_name
JOIN `skills_v2` s ON s.name = t.skill_name;
INSERT IGNORE INTO `career_skill_requirements` (`career_id`, `skill_id`, `required_level`)
SELECT c.id, s.id, t.required_level
FROM (
    SELECT 'Power Systems Engineer' AS career_name, 'Renewable Energy Systems' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'PLC Automation Engineer' AS career_name, 'PLC Programming' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'PLC Automation Engineer' AS career_name, 'Ladder Logic' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'PLC Automation Engineer' AS career_name, 'SCADA' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'PLC Automation Engineer' AS career_name, 'HMI Development' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'PLC Automation Engineer' AS career_name, 'Instrumentation' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'PLC Automation Engineer' AS career_name, 'Industrial Wiring' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Production Engineer' AS career_name, 'Manufacturing Processes' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Production Engineer' AS career_name, 'Lean Manufacturing' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Production Engineer' AS career_name, 'Production Planning' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Production Engineer' AS career_name, 'Six Sigma' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Production Engineer' AS career_name, 'Kaizen' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Production Engineer' AS career_name, 'AutoCAD' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'CNC Programmer' AS career_name, 'CNC Programming' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'CNC Programmer' AS career_name, 'Mastercam' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'CNC Programmer' AS career_name, 'GD&T' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'CNC Programmer' AS career_name, 'Machine Tools' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'CNC Programmer' AS career_name, 'Manufacturing Processes' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'CNC Programmer' AS career_name, 'AutoCAD' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Industrial Engineer' AS career_name, 'Lean Manufacturing' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Industrial Engineer' AS career_name, 'Time Study' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Industrial Engineer' AS career_name, 'Excel' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Industrial Engineer' AS career_name, 'Production Planning' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Industrial Engineer' AS career_name, 'Six Sigma' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Industrial Engineer' AS career_name, 'Operations Research' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Automotive Design Engineer' AS career_name, 'CATIA' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Automotive Design Engineer' AS career_name, 'SolidWorks' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Automotive Design Engineer' AS career_name, 'GD&T' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Automotive Design Engineer' AS career_name, 'Vehicle Dynamics' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Automotive Design Engineer' AS career_name, 'Powertrain Systems' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Automotive Design Engineer' AS career_name, 'ANSYS' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'EV Design Engineer' AS career_name, 'Battery Management Systems' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'EV Design Engineer' AS career_name, 'Electric Vehicle Architecture' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'EV Design Engineer' AS career_name, 'MATLAB' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'EV Design Engineer' AS career_name, 'Simulink' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'EV Design Engineer' AS career_name, 'Powertrain Systems' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'EV Design Engineer' AS career_name, 'Thermal Management' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Vehicle Testing Engineer' AS career_name, 'Vehicle Dynamics' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Vehicle Testing Engineer' AS career_name, 'CAN Bus' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Vehicle Testing Engineer' AS career_name, 'Data Acquisition' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Vehicle Testing Engineer' AS career_name, 'Problem Solving' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Vehicle Testing Engineer' AS career_name, 'Homologation' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Vehicle Testing Engineer' AS career_name, 'MATLAB' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Process Engineer' AS career_name, 'Aspen HYSYS' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Process Engineer' AS career_name, 'Process Simulation' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Process Engineer' AS career_name, 'Heat & Mass Transfer' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Process Engineer' AS career_name, 'Chemical Reaction Engineering' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Process Engineer' AS career_name, 'P&ID Reading' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Process Engineer' AS career_name, 'Excel' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Plant Operations Engineer' AS career_name, 'Plant Operations' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Plant Operations Engineer' AS career_name, 'Safety Procedures' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Plant Operations Engineer' AS career_name, 'P&ID Reading' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Plant Operations Engineer' AS career_name, 'Process Control' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Plant Operations Engineer' AS career_name, 'Instrumentation' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Plant Operations Engineer' AS career_name, 'Regulatory Compliance' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'R&D Chemist' AS career_name, 'Analytical Chemistry' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'R&D Chemist' AS career_name, 'Lab Techniques' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'R&D Chemist' AS career_name, 'Spectroscopy' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'R&D Chemist' AS career_name, 'Chemical Reaction Engineering' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'R&D Chemist' AS career_name, 'Report Writing' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'R&D Chemist' AS career_name, 'HAZOP Basics' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Biotech Research Associate' AS career_name, 'Molecular Biology' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Biotech Research Associate' AS career_name, 'PCR Techniques' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Biotech Research Associate' AS career_name, 'Lab Techniques' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Biotech Research Associate' AS career_name, 'Cell Culture' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Biotech Research Associate' AS career_name, 'Genomics' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Biotech Research Associate' AS career_name, 'Report Writing' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Clinical Research Associate' AS career_name, 'Clinical Trials' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Clinical Research Associate' AS career_name, 'GCP Guidelines' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Clinical Research Associate' AS career_name, 'Clinical Data Management' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Clinical Research Associate' AS career_name, 'Regulatory Compliance' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Clinical Research Associate' AS career_name, 'Medical Terminology' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Clinical Research Associate' AS career_name, 'Communication' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Bioinformatics Analyst' AS career_name, 'Bioinformatics Tools' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Bioinformatics Analyst' AS career_name, 'Genomics' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Bioinformatics Analyst' AS career_name, 'Python' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Bioinformatics Analyst' AS career_name, 'Statistics & Probability' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Bioinformatics Analyst' AS career_name, 'Molecular Biology' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Bioinformatics Analyst' AS career_name, 'R' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Staff Nurse' AS career_name, 'Patient Care' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Staff Nurse' AS career_name, 'First Aid & BLS' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Staff Nurse' AS career_name, 'Infection Control' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Staff Nurse' AS career_name, 'Medication Administration' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Staff Nurse' AS career_name, 'Medical Documentation' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Staff Nurse' AS career_name, 'Communication' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'ICU Nurse' AS career_name, 'Critical Care Nursing' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'ICU Nurse' AS career_name, 'Patient Care' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'ICU Nurse' AS career_name, 'Ventilator Management' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'ICU Nurse' AS career_name, 'First Aid & BLS' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'ICU Nurse' AS career_name, 'Infection Control' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'ICU Nurse' AS career_name, 'Triage' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Community Health Officer' AS career_name, 'Community Health' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Community Health Officer' AS career_name, 'Health Education' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Community Health Officer' AS career_name, 'Patient Care' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Community Health Officer' AS career_name, 'First Aid & BLS' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Community Health Officer' AS career_name, 'Medical Documentation' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Community Health Officer' AS career_name, 'Communication' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'School Teacher' AS career_name, 'Lesson Planning' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'School Teacher' AS career_name, 'Classroom Management' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'School Teacher' AS career_name, 'Subject Expertise' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'School Teacher' AS career_name, 'Communication' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'School Teacher' AS career_name, 'Assessment Design' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'School Teacher' AS career_name, 'Educational Technology' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Assistant Professor' AS career_name, 'Subject Expertise' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Assistant Professor' AS career_name, 'Curriculum Design' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Assistant Professor' AS career_name, 'Assessment Design' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Assistant Professor' AS career_name, 'Research Methods' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Assistant Professor' AS career_name, 'Academic Writing' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Assistant Professor' AS career_name, 'Educational Technology' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Instructional Designer' AS career_name, 'Curriculum Design' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Instructional Designer' AS career_name, 'E-learning Tools' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Instructional Designer' AS career_name, 'Learning Management Systems' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Instructional Designer' AS career_name, 'Storyboarding' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Instructional Designer' AS career_name, 'Assessment Design' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Instructional Designer' AS career_name, 'Storytelling' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Corporate Lawyer' AS career_name, 'Corporate Law' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Corporate Lawyer' AS career_name, 'Contract Drafting' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Corporate Lawyer' AS career_name, 'Legal Research' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Corporate Lawyer' AS career_name, 'M&A Basics' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Corporate Lawyer' AS career_name, 'Compliance' AS skill_name, 70 AS required_level
) t
JOIN `careers_v2` c ON c.name = t.career_name
JOIN `skills_v2` s ON s.name = t.skill_name;
INSERT IGNORE INTO `career_skill_requirements` (`career_id`, `skill_id`, `required_level`)
SELECT c.id, s.id, t.required_level
FROM (
    SELECT 'Corporate Lawyer' AS career_name, 'Negotiation' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Litigation Advocate' AS career_name, 'Litigation' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Litigation Advocate' AS career_name, 'Court Procedures' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Litigation Advocate' AS career_name, 'Legal Research' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Litigation Advocate' AS career_name, 'Case Management' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Litigation Advocate' AS career_name, 'Drafting & Pleadings' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Litigation Advocate' AS career_name, 'Communication' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Legal Analyst' AS career_name, 'Legal Research' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Legal Analyst' AS career_name, 'Contract Drafting' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Legal Analyst' AS career_name, 'Case Management' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Legal Analyst' AS career_name, 'Intellectual Property' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Legal Analyst' AS career_name, 'Communication' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Legal Analyst' AS career_name, 'Excel' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'HR Executive' AS career_name, 'Recruitment' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'HR Executive' AS career_name, 'Onboarding' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'HR Executive' AS career_name, 'Communication' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'HR Executive' AS career_name, 'HRMS Tools' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'HR Executive' AS career_name, 'Employee Engagement' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'HR Executive' AS career_name, 'Excel' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Talent Acquisition Specialist' AS career_name, 'Recruitment' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Talent Acquisition Specialist' AS career_name, 'Interviewing' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Talent Acquisition Specialist' AS career_name, 'Sourcing Strategies' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Talent Acquisition Specialist' AS career_name, 'HRMS Tools' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Talent Acquisition Specialist' AS career_name, 'Negotiation' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Talent Acquisition Specialist' AS career_name, 'Social Media Strategy' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'HR Business Partner' AS career_name, 'Performance Management' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'HR Business Partner' AS career_name, 'Labour Laws' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'HR Business Partner' AS career_name, 'Employee Engagement' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'HR Business Partner' AS career_name, 'Payroll Processing' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'HR Business Partner' AS career_name, 'HR Analytics' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'HR Business Partner' AS career_name, 'Leadership' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Sales Executive' AS career_name, 'Lead Generation' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Sales Executive' AS career_name, 'Communication' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Sales Executive' AS career_name, 'Cold Calling' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Sales Executive' AS career_name, 'CRM Tools' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Sales Executive' AS career_name, 'Negotiation' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Sales Executive' AS career_name, 'Product Knowledge' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Business Development Manager' AS career_name, 'B2B Sales' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Business Development Manager' AS career_name, 'Negotiation' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Business Development Manager' AS career_name, 'Pipeline Management' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Business Development Manager' AS career_name, 'CRM Tools' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Business Development Manager' AS career_name, 'Market Research' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Business Development Manager' AS career_name, 'Leadership' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Account Manager' AS career_name, 'Client Relationship Management' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Account Manager' AS career_name, 'Communication' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Account Manager' AS career_name, 'CRM Tools' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Account Manager' AS career_name, 'Negotiation' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Account Manager' AS career_name, 'Upselling & Cross-selling' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Account Manager' AS career_name, 'Excel' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Bank Probationary Officer' AS career_name, 'Banking Operations' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Bank Probationary Officer' AS career_name, 'Financial Products' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Bank Probationary Officer' AS career_name, 'Customer Service' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Bank Probationary Officer' AS career_name, 'Quantitative Aptitude' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Bank Probationary Officer' AS career_name, 'KYC & AML' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Bank Probationary Officer' AS career_name, 'Excel' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Credit Analyst' AS career_name, 'Credit Analysis' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Credit Analyst' AS career_name, 'Financial Statement Analysis' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Credit Analyst' AS career_name, 'Excel' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Credit Analyst' AS career_name, 'Risk Assessment' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Credit Analyst' AS career_name, 'Banking Operations' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Credit Analyst' AS career_name, 'Financial Modeling' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Insurance Underwriter' AS career_name, 'Risk Assessment' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Insurance Underwriter' AS career_name, 'Insurance Products' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Insurance Underwriter' AS career_name, 'Underwriting Guidelines' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Insurance Underwriter' AS career_name, 'Regulatory Compliance' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Insurance Underwriter' AS career_name, 'Financial Statement Analysis' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Insurance Underwriter' AS career_name, 'Problem Solving' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Supply Chain Analyst' AS career_name, 'Inventory Management' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Supply Chain Analyst' AS career_name, 'Demand Forecasting' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Supply Chain Analyst' AS career_name, 'Excel' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Supply Chain Analyst' AS career_name, 'SAP MM' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Supply Chain Analyst' AS career_name, 'SQL' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Supply Chain Analyst' AS career_name, 'Data Visualization' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Logistics Coordinator' AS career_name, 'Logistics Planning' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Logistics Coordinator' AS career_name, 'Inventory Management' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Logistics Coordinator' AS career_name, 'Route Optimization' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Logistics Coordinator' AS career_name, 'Communication' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Logistics Coordinator' AS career_name, 'Excel' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Logistics Coordinator' AS career_name, 'Vendor Management' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Procurement Specialist' AS career_name, 'Procurement' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Procurement Specialist' AS career_name, 'Vendor Management' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Procurement Specialist' AS career_name, 'Negotiation' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Procurement Specialist' AS career_name, 'SAP MM' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Procurement Specialist' AS career_name, 'Cost Analysis' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Procurement Specialist' AS career_name, 'Contract Management' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Front Office Executive' AS career_name, 'Front Office Operations' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Front Office Executive' AS career_name, 'Guest Relations' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Front Office Executive' AS career_name, 'Communication' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Front Office Executive' AS career_name, 'Reservation Systems' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Front Office Executive' AS career_name, 'Problem Solving' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Front Office Executive' AS career_name, 'Excel' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Chef' AS career_name, 'Culinary Arts' AS skill_name, 90 AS required_level
    UNION ALL SELECT 'Chef' AS career_name, 'Food Safety & Hygiene' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Chef' AS career_name, 'Menu Planning' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Chef' AS career_name, 'Kitchen Management' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Chef' AS career_name, 'Time Management' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Chef' AS career_name, 'Inventory Management' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Travel Consultant' AS career_name, 'Travel Planning' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Travel Consultant' AS career_name, 'Destination Knowledge' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Travel Consultant' AS career_name, 'Customer Service' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Travel Consultant' AS career_name, 'GDS Systems' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Travel Consultant' AS career_name, 'Communication' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Travel Consultant' AS career_name, 'Sales Techniques' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'VFX Artist' AS career_name, 'Nuke' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'VFX Artist' AS career_name, 'After Effects' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'VFX Artist' AS career_name, 'Compositing' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'VFX Artist' AS career_name, 'Color Grading' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'VFX Artist' AS career_name, '3D Modeling' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'VFX Artist' AS career_name, 'Storyboarding' AS skill_name, 55 AS required_level
    UNION ALL SELECT '3D Animator' AS career_name, 'Maya' AS skill_name, 85 AS required_level
    UNION ALL SELECT '3D Animator' AS career_name, '3D Modeling' AS skill_name, 80 AS required_level
    UNION ALL SELECT '3D Animator' AS career_name, 'Character Animation' AS skill_name, 80 AS required_level
    UNION ALL SELECT '3D Animator' AS career_name, 'Texturing & Lighting' AS skill_name, 70 AS required_level
    UNION ALL SELECT '3D Animator' AS career_name, 'Blender' AS skill_name, 60 AS required_level
    UNION ALL SELECT '3D Animator' AS career_name, 'Storyboarding' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Motion Graphics Designer' AS career_name, 'After Effects' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Motion Graphics Designer' AS career_name, 'Motion Graphics' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Motion Graphics Designer' AS career_name, 'Adobe Premiere Pro' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Motion Graphics Designer' AS career_name, 'Typography' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Motion Graphics Designer' AS career_name, 'Storytelling' AS skill_name, 60 AS required_level
) t
JOIN `careers_v2` c ON c.name = t.career_name
JOIN `skills_v2` s ON s.name = t.skill_name;
INSERT IGNORE INTO `career_skill_requirements` (`career_id`, `skill_id`, `required_level`)
SELECT c.id, s.id, t.required_level
FROM (
    SELECT 'Motion Graphics Designer' AS career_name, 'Figma' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Graphic Designer' AS career_name, 'Adobe Photoshop' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Graphic Designer' AS career_name, 'Adobe Illustrator' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Graphic Designer' AS career_name, 'Typography' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Graphic Designer' AS career_name, 'Layout Design' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Graphic Designer' AS career_name, 'Branding' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Graphic Designer' AS career_name, 'Figma' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Brand Designer' AS career_name, 'Branding' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Brand Designer' AS career_name, 'Adobe Illustrator' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Brand Designer' AS career_name, 'Visual Identity Design' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Brand Designer' AS career_name, 'Typography' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Brand Designer' AS career_name, 'Adobe Photoshop' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Brand Designer' AS career_name, 'Design Systems' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Print & Layout Designer' AS career_name, 'Layout Design' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Print & Layout Designer' AS career_name, 'InDesign' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Print & Layout Designer' AS career_name, 'Adobe Photoshop' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Print & Layout Designer' AS career_name, 'Print Production' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Print & Layout Designer' AS career_name, 'Typography' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Print & Layout Designer' AS career_name, 'Color Theory' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Architect' AS career_name, 'AutoCAD' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Architect' AS career_name, 'Revit' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Architect' AS career_name, 'SketchUp' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Architect' AS career_name, 'Building Codes' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Architect' AS career_name, 'Sustainable Design' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Architect' AS career_name, 'Site Planning' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Interior Designer' AS career_name, 'Space Planning' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Interior Designer' AS career_name, 'SketchUp' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Interior Designer' AS career_name, 'AutoCAD' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Interior Designer' AS career_name, 'Material Selection' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Interior Designer' AS career_name, '3D Visualization' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Interior Designer' AS career_name, 'Client Relationship Management' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Urban Planner' AS career_name, 'Urban Planning' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Urban Planner' AS career_name, 'GIS Tools' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Urban Planner' AS career_name, 'Sustainable Design' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Urban Planner' AS career_name, 'AutoCAD' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Urban Planner' AS career_name, 'Policy Analysis' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Urban Planner' AS career_name, 'Report Writing' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Agronomist' AS career_name, 'Agronomy' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Agronomist' AS career_name, 'Crop Management' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Agronomist' AS career_name, 'Soil Testing' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Agronomist' AS career_name, 'Pest & Disease Management' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Agronomist' AS career_name, 'Precision Farming' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Agronomist' AS career_name, 'Field Research' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Agri Business Manager' AS career_name, 'Agri Supply Chain' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Agri Business Manager' AS career_name, 'Market Research' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Agri Business Manager' AS career_name, 'Excel' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Agri Business Manager' AS career_name, 'Procurement' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Agri Business Manager' AS career_name, 'Communication' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Agri Business Manager' AS career_name, 'Financial Modeling' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Soil Scientist' AS career_name, 'Soil Testing' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Soil Scientist' AS career_name, 'Soil Chemistry' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Soil Scientist' AS career_name, 'Agronomy' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Soil Scientist' AS career_name, 'GIS Tools' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Soil Scientist' AS career_name, 'Lab Techniques' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Soil Scientist' AS career_name, 'Report Writing' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Counselling Psychologist' AS career_name, 'Counselling Techniques' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Counselling Psychologist' AS career_name, 'Psychological Assessment' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Counselling Psychologist' AS career_name, 'Active Listening' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Counselling Psychologist' AS career_name, 'Communication' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Counselling Psychologist' AS career_name, 'CBT Basics' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Counselling Psychologist' AS career_name, 'Case Documentation' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Clinical Psychologist' AS career_name, 'Psychological Assessment' AS skill_name, 90 AS required_level
    UNION ALL SELECT 'Clinical Psychologist' AS career_name, 'Clinical Diagnosis' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Clinical Psychologist' AS career_name, 'CBT Basics' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Clinical Psychologist' AS career_name, 'Ethics in Psychology' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Clinical Psychologist' AS career_name, 'Counselling Techniques' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Clinical Psychologist' AS career_name, 'Research Methods' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'HR Psychologist' AS career_name, 'Psychological Assessment' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'HR Psychologist' AS career_name, 'Employee Engagement' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'HR Psychologist' AS career_name, 'Communication' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'HR Psychologist' AS career_name, 'Counselling Techniques' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'HR Psychologist' AS career_name, 'HR Analytics' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'HR Psychologist' AS career_name, 'Research Methods' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Civil Services Officer (UPSC)' AS career_name, 'Indian Polity' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Civil Services Officer (UPSC)' AS career_name, 'General Studies' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Civil Services Officer (UPSC)' AS career_name, 'Current Affairs' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Civil Services Officer (UPSC)' AS career_name, 'Indian History & Geography' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Civil Services Officer (UPSC)' AS career_name, 'Essay Writing' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Civil Services Officer (UPSC)' AS career_name, 'Answer Writing Practice' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Public Policy Analyst' AS career_name, 'Policy Analysis' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Public Policy Analyst' AS career_name, 'Research Methods' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Public Policy Analyst' AS career_name, 'Report Writing' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Public Policy Analyst' AS career_name, 'Economics Basics' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Public Policy Analyst' AS career_name, 'Data Visualization' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Public Policy Analyst' AS career_name, 'Statistics & Probability' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Government Officer (SSC/Banking)' AS career_name, 'Quantitative Aptitude' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Government Officer (SSC/Banking)' AS career_name, 'Logical Reasoning' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Government Officer (SSC/Banking)' AS career_name, 'General Awareness' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Government Officer (SSC/Banking)' AS career_name, 'English Language' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Government Officer (SSC/Banking)' AS career_name, 'Time Management' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Government Officer (SSC/Banking)' AS career_name, 'Excel' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'QA Analyst' AS career_name, 'Manual Testing' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'QA Analyst' AS career_name, 'Test Case Design' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'QA Analyst' AS career_name, 'Bug Tracking' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'QA Analyst' AS career_name, 'JIRA' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'QA Analyst' AS career_name, 'SDLC & STLC' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'QA Analyst' AS career_name, 'SQL' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Automation Test Engineer' AS career_name, 'Selenium' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Automation Test Engineer' AS career_name, 'Test Automation' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Automation Test Engineer' AS career_name, 'API Testing' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Automation Test Engineer' AS career_name, 'Java' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Automation Test Engineer' AS career_name, 'Git & GitHub' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Automation Test Engineer' AS career_name, 'CI/CD Pipelines' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Performance Test Engineer' AS career_name, 'JMeter' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Performance Test Engineer' AS career_name, 'Performance Testing' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Performance Test Engineer' AS career_name, 'LoadRunner' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Performance Test Engineer' AS career_name, 'API Testing' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Performance Test Engineer' AS career_name, 'Monitoring & Observability' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Performance Test Engineer' AS career_name, 'SQL' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'E-commerce Manager' AS career_name, 'E-commerce Platforms' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'E-commerce Manager' AS career_name, 'Digital Cataloging' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'E-commerce Manager' AS career_name, 'Order Management' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'E-commerce Manager' AS career_name, 'Google Analytics' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'E-commerce Manager' AS career_name, 'Supply Chain Basics' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'E-commerce Manager' AS career_name, 'Meta Ads' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Marketplace Specialist' AS career_name, 'Amazon Seller Central' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Marketplace Specialist' AS career_name, 'Product Listing' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Marketplace Specialist' AS career_name, 'Digital Cataloging' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Marketplace Specialist' AS career_name, 'E-commerce SEO' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Marketplace Specialist' AS career_name, 'Excel' AS skill_name, 70 AS required_level
) t
JOIN `careers_v2` c ON c.name = t.career_name
JOIN `skills_v2` s ON s.name = t.skill_name;
INSERT IGNORE INTO `career_skill_requirements` (`career_id`, `skill_id`, `required_level`)
SELECT c.id, s.id, t.required_level
FROM (
    SELECT 'Marketplace Specialist' AS career_name, 'Customer Service' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Catalog Quality Specialist' AS career_name, 'Digital Cataloging' AS skill_name, 85 AS required_level
    UNION ALL SELECT 'Catalog Quality Specialist' AS career_name, 'Product Listing' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Catalog Quality Specialist' AS career_name, 'Content Quality Review' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Catalog Quality Specialist' AS career_name, 'Excel' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Catalog Quality Specialist' AS career_name, 'Problem Solving' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Catalog Quality Specialist' AS career_name, 'SEO Writing' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Data Engineer' AS career_name, 'Apache Kafka' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Data Engineer' AS career_name, 'Communication' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Analytics Engineer' AS career_name, 'Data Visualization' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Analytics Engineer' AS career_name, 'Communication' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Big Data Engineer' AS career_name, 'ETL Design' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Big Data Engineer' AS career_name, 'Linux Administration' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Game Developer' AS career_name, 'Problem Solving' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Game Developer' AS career_name, 'Teamwork & Collaboration' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Unity Developer' AS career_name, 'Game Design Fundamentals' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Unity Developer' AS career_name, 'Problem Solving' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Level Designer' AS career_name, 'Game Physics' AS skill_name, 50 AS required_level
    UNION ALL SELECT 'Level Designer' AS career_name, 'Communication' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Blockchain Developer' AS career_name, 'Node.js' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Blockchain Developer' AS career_name, 'Teamwork & Collaboration' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Smart Contract Auditor' AS career_name, 'OWASP Top 10' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Smart Contract Auditor' AS career_name, 'Incident Response' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Web3 Frontend Developer' AS career_name, 'Git & GitHub' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Web3 Frontend Developer' AS career_name, 'REST API Design' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Embedded Systems Engineer' AS career_name, 'Sensor Integration' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Embedded Systems Engineer' AS career_name, 'Problem Solving' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'IoT Developer' AS career_name, 'Networking Fundamentals' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'IoT Developer' AS career_name, 'Communication' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Firmware Engineer' AS career_name, 'Problem Solving' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Firmware Engineer' AS career_name, 'Report Writing' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Robotics Engineer' AS career_name, 'C Programming' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Robotics Engineer' AS career_name, 'Teamwork & Collaboration' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Automation Engineer' AS career_name, 'Ladder Logic' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Automation Engineer' AS career_name, 'Instrumentation' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Mechatronics Engineer' AS career_name, 'PLC Programming' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Mechatronics Engineer' AS career_name, 'Problem Solving' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Civil Engineer' AS career_name, 'Revit' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Civil Engineer' AS career_name, 'Report Writing' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Structural Engineer' AS career_name, 'Concrete Technology' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Structural Engineer' AS career_name, 'Problem Solving' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Quantity Surveyor' AS career_name, 'Negotiation' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Quantity Surveyor' AS career_name, 'Communication' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Electrical Design Engineer' AS career_name, 'Instrumentation' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Electrical Design Engineer' AS career_name, 'Report Writing' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Power Systems Engineer' AS career_name, 'Report Writing' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Power Systems Engineer' AS career_name, 'Teamwork & Collaboration' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'PLC Automation Engineer' AS career_name, 'Control Systems' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'PLC Automation Engineer' AS career_name, 'Problem Solving' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Production Engineer' AS career_name, 'Excel' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Production Engineer' AS career_name, 'Communication' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'CNC Programmer' AS career_name, 'Lean Manufacturing' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'CNC Programmer' AS career_name, 'Problem Solving' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Industrial Engineer' AS career_name, 'Communication' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Industrial Engineer' AS career_name, 'Report Writing' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Automotive Design Engineer' AS career_name, 'MATLAB' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Automotive Design Engineer' AS career_name, 'Report Writing' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'EV Design Engineer' AS career_name, 'CAN Bus' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'EV Design Engineer' AS career_name, 'Problem Solving' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Vehicle Testing Engineer' AS career_name, 'Report Writing' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Vehicle Testing Engineer' AS career_name, 'Excel' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Process Engineer' AS career_name, 'Safety Procedures' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Process Engineer' AS career_name, 'Communication' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Plant Operations Engineer' AS career_name, 'Teamwork & Collaboration' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Plant Operations Engineer' AS career_name, 'Excel' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'R&D Chemist' AS career_name, 'Regulatory Compliance' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'R&D Chemist' AS career_name, 'Communication' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Biotech Research Associate' AS career_name, 'GCP Guidelines' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Biotech Research Associate' AS career_name, 'Communication' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Clinical Research Associate' AS career_name, 'Excel' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Clinical Research Associate' AS career_name, 'Report Writing' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Bioinformatics Analyst' AS career_name, 'SQL' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Bioinformatics Analyst' AS career_name, 'Machine Learning' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Staff Nurse' AS career_name, 'Teamwork & Collaboration' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Staff Nurse' AS career_name, 'Time Management' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'ICU Nurse' AS career_name, 'Teamwork & Collaboration' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'ICU Nurse' AS career_name, 'Medical Documentation' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Community Health Officer' AS career_name, 'Report Writing' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Community Health Officer' AS career_name, 'Time Management' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'School Teacher' AS career_name, 'Time Management' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'School Teacher' AS career_name, 'Teamwork & Collaboration' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Assistant Professor' AS career_name, 'Communication' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Assistant Professor' AS career_name, 'Time Management' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Instructional Designer' AS career_name, 'Figma' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Instructional Designer' AS career_name, 'Communication' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Corporate Lawyer' AS career_name, 'Communication' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Corporate Lawyer' AS career_name, 'Time Management' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Litigation Advocate' AS career_name, 'Time Management' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Litigation Advocate' AS career_name, 'Report Writing' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Legal Analyst' AS career_name, 'Time Management' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Legal Analyst' AS career_name, 'Report Writing' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'HR Executive' AS career_name, 'Time Management' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'HR Executive' AS career_name, 'Teamwork & Collaboration' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Talent Acquisition Specialist' AS career_name, 'Communication' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Talent Acquisition Specialist' AS career_name, 'Time Management' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'HR Business Partner' AS career_name, 'Communication' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'HR Business Partner' AS career_name, 'Negotiation' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Sales Executive' AS career_name, 'Time Management' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Sales Executive' AS career_name, 'Teamwork & Collaboration' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Business Development Manager' AS career_name, 'Communication' AS skill_name, 80 AS required_level
    UNION ALL SELECT 'Business Development Manager' AS career_name, 'Time Management' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Account Manager' AS career_name, 'Time Management' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Account Manager' AS career_name, 'Report Writing' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Bank Probationary Officer' AS career_name, 'Communication' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Bank Probationary Officer' AS career_name, 'Time Management' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Credit Analyst' AS career_name, 'Communication' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Credit Analyst' AS career_name, 'Report Writing' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Insurance Underwriter' AS career_name, 'Excel' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Insurance Underwriter' AS career_name, 'Communication' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Supply Chain Analyst' AS career_name, 'Communication' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Supply Chain Analyst' AS career_name, 'Report Writing' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Logistics Coordinator' AS career_name, 'Time Management' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Logistics Coordinator' AS career_name, 'Problem Solving' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Procurement Specialist' AS career_name, 'Communication' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Procurement Specialist' AS career_name, 'Market Research' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Front Office Executive' AS career_name, 'Time Management' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Front Office Executive' AS career_name, 'Teamwork & Collaboration' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Chef' AS career_name, 'Teamwork & Collaboration' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Chef' AS career_name, 'Problem Solving' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Travel Consultant' AS career_name, 'Problem Solving' AS skill_name, 65 AS required_level
) t
JOIN `careers_v2` c ON c.name = t.career_name
JOIN `skills_v2` s ON s.name = t.skill_name;
INSERT IGNORE INTO `career_skill_requirements` (`career_id`, `skill_id`, `required_level`)
SELECT c.id, s.id, t.required_level
FROM (
    SELECT 'Travel Consultant' AS career_name, 'Time Management' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'VFX Artist' AS career_name, 'Maya' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'VFX Artist' AS career_name, 'Teamwork & Collaboration' AS skill_name, 55 AS required_level
    UNION ALL SELECT '3D Animator' AS career_name, 'Motion Graphics' AS skill_name, 60 AS required_level
    UNION ALL SELECT '3D Animator' AS career_name, 'Time Management' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Motion Graphics Designer' AS career_name, 'Adobe Illustrator' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Motion Graphics Designer' AS career_name, 'Time Management' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Graphic Designer' AS career_name, 'InDesign' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Graphic Designer' AS career_name, 'Time Management' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Brand Designer' AS career_name, 'Communication' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Brand Designer' AS career_name, 'Color Theory' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Print & Layout Designer' AS career_name, 'Adobe Illustrator' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Print & Layout Designer' AS career_name, 'Time Management' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Architect' AS career_name, 'Communication' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Architect' AS career_name, 'Time Management' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Interior Designer' AS career_name, 'Communication' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Interior Designer' AS career_name, 'Time Management' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Urban Planner' AS career_name, 'Communication' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Urban Planner' AS career_name, 'Data Visualization' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Agronomist' AS career_name, 'Report Writing' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Agronomist' AS career_name, 'Communication' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Agri Business Manager' AS career_name, 'Negotiation' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Agri Business Manager' AS career_name, 'Report Writing' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Soil Scientist' AS career_name, 'Research Methods' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Soil Scientist' AS career_name, 'Communication' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Counselling Psychologist' AS career_name, 'Ethics in Psychology' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Counselling Psychologist' AS career_name, 'Time Management' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Clinical Psychologist' AS career_name, 'Communication' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Clinical Psychologist' AS career_name, 'Case Documentation' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'HR Psychologist' AS career_name, 'Interviewing' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'HR Psychologist' AS career_name, 'Report Writing' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Civil Services Officer (UPSC)' AS career_name, 'Logical Reasoning' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Civil Services Officer (UPSC)' AS career_name, 'Time Management' AS skill_name, 75 AS required_level
    UNION ALL SELECT 'Public Policy Analyst' AS career_name, 'Communication' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Public Policy Analyst' AS career_name, 'Excel' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Government Officer (SSC/Banking)' AS career_name, 'Current Affairs' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Government Officer (SSC/Banking)' AS career_name, 'Communication' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'QA Analyst' AS career_name, 'Communication' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'QA Analyst' AS career_name, 'API Testing' AS skill_name, 50 AS required_level
    UNION ALL SELECT 'Automation Test Engineer' AS career_name, 'SDLC & STLC' AS skill_name, 65 AS required_level
    UNION ALL SELECT 'Automation Test Engineer' AS career_name, 'Python' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Performance Test Engineer' AS career_name, 'Report Writing' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Performance Test Engineer' AS career_name, 'Communication' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'E-commerce Manager' AS career_name, 'Excel' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'E-commerce Manager' AS career_name, 'Communication' AS skill_name, 70 AS required_level
    UNION ALL SELECT 'Marketplace Specialist' AS career_name, 'Meta Ads' AS skill_name, 55 AS required_level
    UNION ALL SELECT 'Marketplace Specialist' AS career_name, 'Time Management' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Catalog Quality Specialist' AS career_name, 'Communication' AS skill_name, 60 AS required_level
    UNION ALL SELECT 'Catalog Quality Specialist' AS career_name, 'Time Management' AS skill_name, 65 AS required_level
) t
JOIN `careers_v2` c ON c.name = t.career_name
JOIN `skills_v2` s ON s.name = t.skill_name;
-- <<< MEGA SEED END <<<

-- =====================================================
-- 9) VERIFY — expected after a fresh run (approx. minimums):
--    education_categories 10+, education_programs 79+, domains 37+,
--    careers_v2 114+, skills_v2 340+, career_skill_requirements 850+
-- =====================================================
SELECT 'education_categories'     AS tbl, COUNT(*) AS rows_count FROM `education_categories`
UNION ALL SELECT 'education_programs',     COUNT(*) FROM `education_programs`
UNION ALL SELECT 'domains',                COUNT(*) FROM `domains`
UNION ALL SELECT 'careers_v2',             COUNT(*) FROM `careers_v2`
UNION ALL SELECT 'skills_v2',              COUNT(*) FROM `skills_v2`
UNION ALL SELECT 'career_skill_requirements', COUNT(*) FROM `career_skill_requirements`;

-- Per-career skill counts (should be 4-9 per career):
SELECT c.name AS career, d.name AS domain, COUNT(csr.id) AS skills
FROM `careers_v2` c
LEFT JOIN `domains` d ON d.id = c.domain_id
LEFT JOIN `career_skill_requirements` csr ON csr.career_id = c.id
GROUP BY c.id, c.name, d.name
ORDER BY d.name, c.name;
