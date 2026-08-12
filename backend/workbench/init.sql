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
-- 7) VERIFY — expected after a fresh run:
--    education_categories 7+, education_programs 27+,
--    domains 10+, careers_v2 32+, skills_v2 81+, requirements 200+
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
