-- ============================================================================
-- AI SKILL GAP ANALYZER — COMPLETE SEED DATA
-- ============================================================================
-- Tables: education_categories, education_programs, domains, skills_v2,
--         careers_v2, career_skill_requirements
--
-- HOW TO USE IN MYSQL WORKBENCH:
--   1. Make sure the database exists and is selected:
--        CREATE DATABASE IF NOT EXISTS ai_skill_gap CHARACTER SET utf8mb4;
--        USE ai_skill_gap;
--   2. (First time only) Create the tables from the backend models:
--        cd backend && python -c "import database, models; database.Base.metadata.create_all(bind=database.engine)"
--   3. Open this file in Workbench (File > Open SQL Script) and run it
--      (lightning icon / Ctrl+Shift+Enter).
--
-- RE-RUNNING / EXISTING DATA:
--   The inserts use explicit IDs, so running twice will fail with duplicate
--   key errors. To wipe everything and reload, uncomment the cleanup block
--   below and run it first.
--
-- ============================================================================

SET NAMES utf8mb4;

-- ----------------------------------------------------------------------------
-- OPTIONAL CLEANUP (uncomment ONLY if you want to wipe and reload all data)
-- ----------------------------------------------------------------------------
-- SET FOREIGN_KEY_CHECKS = 0;
-- TRUNCATE TABLE career_skill_requirements;
-- TRUNCATE TABLE careers_v2;
-- TRUNCATE TABLE skills_v2;
-- TRUNCATE TABLE domains;
-- TRUNCATE TABLE education_programs;
-- TRUNCATE TABLE education_categories;
-- SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- 1. EDUCATION CATEGORIES
-- ============================================================================

INSERT INTO education_categories (id, name, description) VALUES
(1, 'School Education',        'Secondary and higher secondary schooling (10th / 12th standard).'),
(2, 'Undergraduate (Bachelor''s)', '3-4 year bachelor''s degree programs.'),
(3, 'Postgraduate (Master''s)', '1-2 year master''s degree programs after a bachelor''s degree.'),
(4, 'Doctorate',               'PhD and research-oriented programs.'),
(5, 'Diploma & Certificate',   'Short-term diploma and certificate courses.'),
(6, 'Professional Certification', 'Industry certifications (AWS, Cisco, Google, Microsoft, etc.).');

-- ============================================================================
-- 2. EDUCATION PROGRAMS
-- ============================================================================

INSERT INTO education_programs (id, category_id, name, level, description) VALUES
-- School Education
(1,  1, 'Secondary School (10th)',        'Class 10',    'Completed secondary schooling.'),
(2,  1, 'Higher Secondary (10+2)',        'Class 12',    'Completed higher secondary schooling.'),
(3,  1, 'Higher Secondary (Science PCM)', 'Class 12',    'Science stream: Physics, Chemistry, Mathematics.'),
(4,  1, 'Higher Secondary (Commerce)',    'Class 12',    'Commerce stream: Accountancy, Business Studies, Economics.'),
-- Undergraduate
(5,  2, 'B.Tech / B.E. Computer Science', 'Bachelor',    'Bachelor of Technology in Computer Science / Engineering.'),
(6,  2, 'B.Tech / B.E. Other Branches',   'Bachelor',    'Engineering branches like ECE, Mechanical, Civil, Electrical.'),
(7,  2, 'B.Sc. Computer Science',         'Bachelor',    'Bachelor of Science in Computer Science.'),
(8,  2, 'B.Sc. Data Science & Analytics', 'Bachelor',    'Bachelor of Science focused on data science, statistics and analytics.'),
(9,  2, 'BCA (Computer Applications)',    'Bachelor',    'Bachelor of Computer Applications.'),
(10, 2, 'BBA (Business Administration)',  'Bachelor',    'Bachelor of Business Administration.'),
(11, 2, 'B.Com (Commerce)',               'Bachelor',    'Bachelor of Commerce.'),
(12, 2, 'B.A. (Arts / Humanities)',       'Bachelor',    'Bachelor of Arts in humanities or social sciences.'),
(13, 2, 'B.Sc. Mathematics / Statistics', 'Bachelor',    'Bachelor of Science in Mathematics or Statistics.'),
(14, 2, 'B.Des (Design)',                 'Bachelor',    'Bachelor of Design — UI/UX, graphic and product design.'),
-- Postgraduate
(15, 3, 'M.Tech Computer Science',        'Master',      'Master of Technology in Computer Science.'),
(16, 3, 'M.Sc. Computer Science',         'Master',      'Master of Science in Computer Science.'),
(17, 3, 'M.Sc. Data Science',             'Master',      'Master of Science in Data Science.'),
(18, 3, 'MCA (Computer Applications)',    'Master',      'Master of Computer Applications.'),
(19, 3, 'MBA (Management)',               'Master',      'Master of Business Administration.'),
(20, 3, 'M.Com / MA',                     'Master',      'Master of Commerce / Master of Arts.'),
-- Doctorate
(21, 4, 'PhD Computer Science',           'Doctorate',   'Doctoral research in computer science.'),
(22, 4, 'PhD Management',                 'Doctorate',   'Doctoral research in management.'),
-- Diploma & Certificate
(23, 5, 'Diploma in Computer Science',    'Diploma',     'Polytechnic diploma in computer science / IT.'),
(24, 5, 'Diploma in IT / Hardware',       'Diploma',     'Diploma in information technology and hardware.'),
(25, 5, 'Diploma in Digital Marketing',   'Diploma',     'Short diploma in digital marketing.'),
(26, 5, 'Full-Stack / Data Science Bootcamp', 'Certificate', 'Intensive coding or data science bootcamp.'),
-- Professional Certification
(27, 6, 'AWS / Azure / GCP Certification','Professional','Cloud platform certification (AWS, Azure or GCP).'),
(28, 6, 'Cisco CCNA Certification',       'Professional','Networking certification (CCNA).'),
(29, 6, 'Google / Meta Professional Certificate', 'Professional', 'Professional certificate from Google or Meta.');

-- ============================================================================
-- 3. CAREER DOMAINS
-- ============================================================================

INSERT INTO domains (id, name, description) VALUES
(1,  'Software Development',                'Designing, building and maintaining software systems.'),
(2,  'Web Development',                     'Building websites and web applications.'),
(3,  'Mobile App Development',              'Building Android, iOS and cross-platform mobile apps.'),
(4,  'Data Science & Analytics',            'Extracting insights from data to drive decisions.'),
(5,  'Artificial Intelligence & ML',        'Building intelligent systems that learn from data.'),
(6,  'Cloud Computing & DevOps',            'Cloud infrastructure, automation and delivery pipelines.'),
(7,  'Cybersecurity',                       'Protecting systems, networks and data from threats.'),
(8,  'Database Administration & Big Data',  'Managing databases and large-scale data platforms.'),
(9,  'UI/UX Design',                        'Designing user-friendly interfaces and experiences.'),
(10, 'Digital Marketing',                   'Marketing products and brands through digital channels.'),
(11, 'IT & Networking',                     'Managing networks, servers and IT infrastructure.'),
(12, 'Product & Project Management',        'Leading products, teams and projects.');

-- ============================================================================
-- 4. SKILLS
-- ============================================================================

INSERT INTO skills_v2 (id, name, category, description) VALUES
-- Programming Languages
(1,   'Python',                        'Programming Languages', 'General-purpose language for scripting, backend and data science.'),
(2,   'Java',                          'Programming Languages', 'Object-oriented language used in enterprise and Android development.'),
(3,   'JavaScript',                    'Programming Languages', 'Language of the web; used for frontend and backend.'),
(4,   'TypeScript',                    'Programming Languages', 'Typed superset of JavaScript.'),
(5,   'C',                             'Programming Languages', 'Low-level systems programming language.'),
(6,   'C++',                           'Programming Languages', 'Systems and performance-oriented language.'),
(7,   'C#',                            'Programming Languages', 'Language for .NET and game development.'),
(8,   'Go',                            'Programming Languages', 'Compiled language for backend and cloud services.'),
(9,   'PHP',                           'Programming Languages', 'Server-side scripting language for the web.'),
(10,  'Kotlin',                        'Programming Languages', 'Modern JVM language for Android development.'),
(11,  'Swift',                         'Programming Languages', 'Language for iOS/macOS development.'),
(12,  'Dart',                          'Programming Languages', 'Language for Flutter cross-platform apps.'),
(13,  'Data Structures & Algorithms',  'Programming Languages', 'Foundational problem-solving and interview concepts.'),
(14,  'Shell Scripting',               'Programming Languages', 'Bash/PowerShell automation for system administration.'),
(15,  'Software Testing',              'Programming Languages', 'Writing and automating tests for software quality.'),
-- Web Technologies
(16,  'HTML',                          'Web Technologies',      'Structure of web pages.'),
(17,  'CSS',                           'Web Technologies',      'Styling and layout of web pages.'),
(18,  'Tailwind CSS',                  'Web Technologies',      'Utility-first CSS framework.'),
(19,  'React',                         'Web Technologies',      'Component-based JavaScript UI library.'),
(20,  'Angular',                       'Web Technologies',      'Full-featured TypeScript web framework.'),
(21,  'Vue.js',                        'Web Technologies',      'Progressive JavaScript framework.'),
(22,  'Next.js',                       'Web Technologies',      'React framework for production (SSR/SSG).'),
(23,  'Node.js',                       'Web Technologies',      'JavaScript runtime for backend services.'),
(24,  'Express.js',                    'Web Technologies',      'Minimal Node.js web framework.'),
(25,  'Django',                        'Web Technologies',      'High-level Python web framework.'),
(26,  'Flask',                         'Web Technologies',      'Lightweight Python web framework.'),
(27,  'FastAPI',                       'Web Technologies',      'Modern high-performance Python API framework.'),
(28,  'REST API',                      'Web Technologies',      'Designing and consuming RESTful APIs.'),
(29,  'GraphQL',                       'Web Technologies',      'Query language for APIs.'),
-- Data & Analytics
(30,  'SQL',                           'Data & Analytics',      'Querying relational databases.'),
(31,  'MySQL',                         'Data & Analytics',      'Popular open-source relational database.'),
(32,  'PostgreSQL',                    'Data & Analytics',      'Advanced open-source relational database.'),
(33,  'MongoDB',                       'Data & Analytics',      'Document-oriented NoSQL database.'),
(34,  'Excel',                         'Data & Analytics',      'Spreadsheet analysis and reporting.'),
(35,  'Power BI',                      'Data & Analytics',      'Microsoft business intelligence and visualization tool.'),
(36,  'Tableau',                       'Data & Analytics',      'Data visualization platform.'),
(37,  'Statistics',                    'Data & Analytics',      'Probability, distributions, hypothesis testing.'),
(38,  'Data Visualization',            'Data & Analytics',      'Presenting data through charts and dashboards.'),
(39,  'Pandas',                        'Data & Analytics',      'Python data manipulation library.'),
(40,  'NumPy',                         'Data & Analytics',      'Python numerical computing library.'),
(41,  'ETL',                           'Data & Analytics',      'Extract, transform, load data pipelines.'),
(42,  'Data Modeling',                 'Data & Analytics',      'Designing schemas and dimensional models.'),
(43,  'Big Data',                      'Data & Analytics',      'Working with large-scale data technologies.'),
(44,  'Apache Spark',                  'Data & Analytics',      'Distributed data processing engine.'),
(45,  'Hadoop',                        'Data & Analytics',      'Distributed storage and processing framework.'),
(106, 'Query Optimization',            'Data & Analytics',      'Tuning queries and indexes for performance.'),
-- AI & Machine Learning
(46,  'Machine Learning',              'AI & ML',               'Building predictive models from data.'),
(47,  'Deep Learning',                 'AI & ML',               'Neural networks for complex patterns.'),
(48,  'TensorFlow',                    'AI & ML',               'Google''s machine learning framework.'),
(49,  'PyTorch',                       'AI & ML',               'Meta''s deep learning framework.'),
(50,  'Scikit-learn',                  'AI & ML',               'Python ML library for classical algorithms.'),
(51,  'Natural Language Processing',   'AI & ML',               'Processing and understanding text.'),
(52,  'Computer Vision',               'AI & ML',               'Image and video understanding.'),
(53,  'Generative AI & LLMs',          'AI & ML',               'LLM-based applications, RAG, fine-tuning.'),
(54,  'Prompt Engineering',            'AI & ML',               'Designing effective LLM prompts.'),
(55,  'MLOps',                         'AI & ML',               'Deploying and monitoring ML models.'),
-- Cloud & DevOps
(56,  'AWS',                           'Cloud & DevOps',        'Amazon Web Services cloud platform.'),
(57,  'Microsoft Azure',               'Cloud & DevOps',        'Microsoft cloud platform.'),
(58,  'Google Cloud',                  'Cloud & DevOps',        'Google cloud platform (GCP).'),
(59,  'Docker',                        'Cloud & DevOps',        'Containerization platform.'),
(60,  'Kubernetes',                    'Cloud & DevOps',        'Container orchestration.'),
(61,  'Terraform',                     'Cloud & DevOps',        'Infrastructure as code.'),
(62,  'Jenkins',                       'Cloud & DevOps',        'CI/CD automation server.'),
(63,  'CI/CD',                         'Cloud & DevOps',        'Continuous integration and delivery pipelines.'),
(64,  'Linux',                         'Cloud & DevOps',        'Linux operating system administration.'),
(65,  'Git',                           'Cloud & DevOps',        'Version control.'),
(66,  'GitHub Actions',                'Cloud & DevOps',        'GitHub-native CI/CD.'),
-- Mobile Development
(67,  'Flutter',                       'Mobile Development',    'Cross-platform UI framework (Dart).'),
(68,  'React Native',                  'Mobile Development',    'Cross-platform mobile framework (JavaScript).'),
(69,  'Android Development',           'Mobile Development',    'Building native Android apps.'),
(70,  'iOS Development',               'Mobile Development',    'Building native iOS apps.'),
-- Cybersecurity
(71,  'Network Security',              'Cybersecurity',         'Securing networks and infrastructure.'),
(72,  'Ethical Hacking',               'Cybersecurity',         'Finding and exploiting vulnerabilities legally.'),
(73,  'Penetration Testing',           'Cybersecurity',         'Security testing of systems and applications.'),
(74,  'Cryptography',                  'Cybersecurity',         'Encryption and secure communication.'),
(75,  'OWASP',                         'Cybersecurity',         'Web application security standards (Top 10).'),
(76,  'Incident Response',             'Cybersecurity',         'Handling and recovering from security incidents.'),
(77,  'Security Auditing',             'Cybersecurity',         'Assessing security posture and compliance.'),
-- Design
(78,  'Figma',                         'Design',                'Collaborative interface design tool.'),
(79,  'UX Research',                   'Design',                'Understanding users through research.'),
(80,  'Wireframing',                   'Design',                'Low-fidelity layout planning.'),
(81,  'Prototyping',                   'Design',                'Interactive design mockups.'),
(82,  'Design Systems',                'Design',                'Reusable components and design tokens.'),
(83,  'Usability Testing',             'Design',                'Testing designs with real users.'),
(84,  'Visual Design',                 'Design',                'Color, typography, layout and aesthetics.'),
-- Marketing
(85,  'SEO',                           'Marketing',             'Search engine optimization.'),
(86,  'SEM',                           'Marketing',             'Search engine marketing / paid ads.'),
(87,  'Social Media Marketing',        'Marketing',             'Marketing via social platforms.'),
(88,  'Content Marketing',             'Marketing',             'Content-driven marketing.'),
(89,  'Google Analytics',              'Marketing',             'Web analytics platform.'),
(90,  'Email Marketing',               'Marketing',             'Email campaigns and automation.'),
(91,  'Copywriting',                   'Marketing',             'Writing persuasive marketing copy.'),
-- Management & Soft Skills
(92,  'Agile & Scrum',                 'Management',            'Iterative delivery frameworks.'),
(93,  'Jira',                          'Management',            'Issue and project tracking tool.'),
(94,  'Product Management',            'Management',            'Owning product vision and roadmap.'),
(95,  'Project Management',            'Management',            'Planning and delivering projects.'),
(96,  'Leadership',                    'Management',            'Leading and motivating teams.'),
(97,  'Communication',                 'Management',            'Clear written and verbal communication.'),
(98,  'Problem Solving',               'Management',            'Analytical and logical problem solving.'),
(99,  'Documentation',                 'Management',            'Technical and project documentation.'),
-- Networking & Systems
(100, 'TCP/IP',                        'Networking & Systems',  'Networking protocols and addressing.'),
(101, 'Routing & Switching',           'Networking & Systems',  'Network routing and switching (CCNA).'),
(102, 'Wireshark',                     'Networking & Systems',  'Network packet analysis.'),
(103, 'CCNA',                          'Networking & Systems',  'Cisco networking certification topics.'),
(104, 'System Administration',         'Networking & Systems',  'Managing servers, users and services.'),
(105, 'Operating Systems',             'Networking & Systems',  'Windows/Linux OS administration.');

-- ============================================================================
-- 5. CAREERS
-- ============================================================================

INSERT INTO careers_v2 (id, domain_id, name, description, average_level) VALUES
-- Software Development (domain 1)
(1,  1, 'Software Engineer',          'Designs, develops and maintains software applications.', 'Intermediate'),
(2,  1, 'Backend Developer',          'Builds server-side logic, APIs and integrations.', 'Intermediate'),
(3,  1, 'Full Stack Developer',       'Works across frontend and backend of web applications.', 'Intermediate'),
(4,  1, 'QA / Test Engineer',         'Ensures software quality through manual and automated testing.', 'Entry'),
-- Web Development (domain 2)
(5,  2, 'Frontend Developer',         'Builds user interfaces with HTML, CSS and JavaScript frameworks.', 'Entry'),
(6,  2, 'React Developer',            'Specializes in React-based web applications.', 'Intermediate'),
(7,  2, 'Node.js Backend Developer',  'Builds APIs and services with Node.js/Express.', 'Intermediate'),
(8,  2, 'WordPress Developer',        'Builds and customizes WordPress sites and plugins.', 'Entry'),
-- Mobile App Development (domain 3)
(9,  3, 'Android Developer',          'Builds native Android apps with Kotlin/Java.', 'Intermediate'),
(10, 3, 'iOS Developer',              'Builds native iOS apps with Swift.', 'Intermediate'),
(11, 3, 'Flutter Developer',          'Builds cross-platform mobile apps with Flutter.', 'Entry'),
-- Data Science & Analytics (domain 4)
(12, 4, 'Data Analyst',               'Analyzes data to produce reports and dashboards.', 'Entry'),
(13, 4, 'Data Scientist',             'Builds models to extract insights and predictions.', 'Intermediate'),
(14, 4, 'Business Intelligence Developer', 'Builds BI solutions, data models and dashboards.', 'Intermediate'),
-- AI & Machine Learning (domain 5)
(15, 5, 'Machine Learning Engineer',  'Designs and deploys ML models in production.', 'Intermediate'),
(16, 5, 'AI Engineer (LLM)',          'Builds LLM-powered applications (RAG, agents).', 'Intermediate'),
(17, 5, 'NLP Engineer',               'Builds text and language processing systems.', 'Intermediate'),
(18, 5, 'Computer Vision Engineer',   'Builds image/video understanding systems.', 'Intermediate'),
-- Cloud & DevOps (domain 6)
(19, 6, 'DevOps Engineer',            'Automates build, deployment and infrastructure.', 'Intermediate'),
(20, 6, 'Cloud Engineer',             'Designs and manages cloud infrastructure.', 'Intermediate'),
(21, 6, 'Site Reliability Engineer',  'Keeps production systems reliable and scalable.', 'Advanced'),
-- Cybersecurity (domain 7)
(22, 7, 'Cybersecurity Analyst',      'Monitors and protects systems from threats.', 'Entry'),
(23, 7, 'Penetration Tester',         'Ethically hacks systems to find vulnerabilities.', 'Intermediate'),
(24, 7, 'Security Engineer',          'Designs and implements security controls.', 'Intermediate'),
-- Database & Big Data (domain 8)
(25, 8, 'Database Administrator',     'Manages, backs up and optimizes databases.', 'Intermediate'),
(26, 8, 'Data Engineer',              'Builds data pipelines and warehouses.', 'Intermediate'),
(27, 8, 'Big Data Engineer',          'Processes large-scale datasets with distributed tools.', 'Intermediate'),
-- UI/UX Design (domain 9)
(28, 9, 'UI Designer',                'Designs visual interfaces and design systems.', 'Entry'),
(29, 9, 'UX Designer',                'Designs user experiences through research and testing.', 'Intermediate'),
(30, 9, 'Product Designer',           'Owns end-to-end product design.', 'Intermediate'),
-- Digital Marketing (domain 10)
(31, 10, 'Digital Marketing Specialist', 'Runs multi-channel digital marketing campaigns.', 'Entry'),
(32, 10, 'SEO Specialist',            'Improves organic search visibility.', 'Entry'),
(33, 10, 'Social Media Manager',      'Manages brand presence on social platforms.', 'Entry'),
-- IT & Networking (domain 11)
(34, 11, 'Network Engineer',          'Designs and maintains computer networks.', 'Intermediate'),
(35, 11, 'System Administrator',      'Manages servers, OS and IT services.', 'Entry'),
(36, 11, 'IT Support Specialist',     'Provides technical support to users.', 'Entry'),
-- Product & Project Management (domain 12)
(37, 12, 'Product Manager',           'Owns the product vision, roadmap and delivery.', 'Intermediate'),
(38, 12, 'Project Manager',           'Plans and delivers projects on time and budget.', 'Intermediate'),
(39, 12, 'Scrum Master',              'Facilitates Agile teams and ceremonies.', 'Entry');

-- ============================================================================
-- 6. CAREER SKILL REQUIREMENTS  (career_id, skill_id, required_level 0-100)
-- ============================================================================
-- NOTE: the id column is auto-incremented here — do not specify it.

-- Software Engineer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(1, 13, 75), (1, 1, 70), (1, 2, 65), (1, 65, 70), (1, 30, 65), (1, 28, 65), (1, 97, 60), (1, 92, 55);

-- Backend Developer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(2, 1, 80), (2, 28, 80), (2, 25, 70), (2, 30, 70), (2, 27, 55), (2, 65, 65), (2, 59, 55), (2, 64, 50);

-- Full Stack Developer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(3, 3, 75), (3, 19, 70), (3, 16, 70), (3, 17, 65), (3, 23, 70), (3, 30, 65), (3, 28, 70), (3, 65, 65);

-- QA / Test Engineer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(4, 15, 85), (4, 98, 65), (4, 1, 55), (4, 30, 55), (4, 97, 65), (4, 65, 55), (4, 92, 60);

-- Frontend Developer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(5, 16, 80), (5, 17, 80), (5, 3, 80), (5, 19, 75), (5, 18, 65), (5, 28, 60), (5, 65, 60), (5, 78, 45);

-- React Developer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(6, 3, 85), (6, 19, 85), (6, 4, 65), (6, 16, 70), (6, 17, 70), (6, 22, 55), (6, 28, 65), (6, 65, 65);

-- Node.js Backend Developer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(7, 23, 80), (7, 24, 75), (7, 3, 75), (7, 33, 60), (7, 28, 75), (7, 65, 60), (7, 30, 55), (7, 59, 50);

-- WordPress Developer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(8, 9, 80), (8, 16, 75), (8, 17, 70), (8, 3, 60), (8, 31, 60), (8, 85, 50);

-- Android Developer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(9, 10, 75), (9, 69, 80), (9, 2, 60), (9, 28, 65), (9, 65, 60), (9, 13, 55), (9, 30, 50);

-- iOS Developer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(10, 11, 80), (10, 70, 85), (10, 28, 60), (10, 65, 55), (10, 98, 60), (10, 30, 45);

-- Flutter Developer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(11, 67, 85), (11, 12, 75), (11, 28, 65), (11, 65, 60), (11, 30, 50), (11, 78, 45), (11, 98, 55);

-- Data Analyst
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(12, 30, 80), (12, 34, 75), (12, 35, 70), (12, 1, 60), (12, 37, 65), (12, 38, 70), (12, 97, 60);

-- Data Scientist
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(13, 1, 85), (13, 37, 80), (13, 46, 80), (13, 30, 70), (13, 39, 75), (13, 40, 70), (13, 38, 65), (13, 97, 55);

-- Business Intelligence Developer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(14, 30, 85), (14, 35, 85), (14, 36, 70), (14, 42, 75), (14, 41, 70), (14, 34, 65), (14, 37, 55);

-- Machine Learning Engineer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(15, 1, 90), (15, 46, 85), (15, 47, 75), (15, 48, 70), (15, 49, 65), (15, 37, 70), (15, 55, 55), (15, 59, 55);

-- AI Engineer (LLM)
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(16, 1, 85), (16, 53, 75), (16, 54, 70), (16, 46, 75), (16, 51, 70), (16, 27, 60), (16, 59, 55);

-- NLP Engineer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(17, 1, 85), (17, 51, 85), (17, 47, 75), (17, 49, 70), (17, 48, 65), (17, 37, 60), (17, 53, 70), (17, 65, 55);

-- Computer Vision Engineer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(18, 1, 85), (18, 52, 80), (18, 47, 80), (18, 49, 75), (18, 48, 70), (18, 40, 70), (18, 37, 60), (18, 59, 50);

-- DevOps Engineer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(19, 59, 85), (19, 60, 80), (19, 63, 80), (19, 56, 75), (19, 64, 75), (19, 61, 70), (19, 65, 70), (19, 1, 60);

-- Cloud Engineer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(20, 56, 80), (20, 57, 70), (20, 58, 60), (20, 64, 70), (20, 59, 65), (20, 61, 65), (20, 100, 55), (20, 1, 60);

-- Site Reliability Engineer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(21, 64, 85), (21, 60, 80), (21, 59, 80), (21, 1, 70), (21, 63, 75), (21, 56, 70), (21, 100, 60);

-- Cybersecurity Analyst
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(22, 71, 75), (22, 72, 65), (22, 75, 70), (22, 76, 65), (22, 100, 60), (22, 64, 55), (22, 74, 55);

-- Penetration Tester
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(23, 72, 85), (23, 73, 85), (23, 75, 80), (23, 1, 65), (23, 71, 70), (23, 64, 70), (23, 74, 55);

-- Security Engineer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(24, 71, 80), (24, 74, 75), (24, 75, 70), (24, 64, 70), (24, 1, 60), (24, 76, 70), (24, 77, 65), (24, 56, 55);

-- Database Administrator
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(25, 31, 85), (25, 30, 85), (25, 42, 80), (25, 106, 80), (25, 32, 70), (25, 64, 60);

-- Data Engineer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(26, 30, 85), (26, 1, 75), (26, 41, 80), (26, 44, 65), (26, 42, 75), (26, 56, 60), (26, 59, 55), (26, 43, 60);

-- Big Data Engineer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(27, 44, 80), (27, 45, 70), (27, 43, 80), (27, 30, 75), (27, 1, 70), (27, 41, 70), (27, 42, 60), (27, 56, 60);

-- UI Designer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(28, 78, 85), (28, 82, 75), (28, 81, 80), (28, 84, 80), (28, 80, 75), (28, 16, 55), (28, 17, 60);

-- UX Designer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(29, 79, 85), (29, 80, 80), (29, 81, 80), (29, 83, 80), (29, 78, 75), (29, 82, 60), (29, 97, 70);

-- Product Designer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(30, 78, 85), (30, 79, 75), (30, 81, 80), (30, 82, 75), (30, 83, 70), (30, 80, 75), (30, 97, 70);

-- Digital Marketing Specialist
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(31, 85, 80), (31, 86, 70), (31, 87, 75), (31, 88, 70), (31, 89, 75), (31, 90, 60), (31, 91, 65);

-- SEO Specialist
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(32, 85, 90), (32, 88, 80), (32, 89, 75), (32, 86, 70), (32, 91, 70), (32, 16, 50);

-- Social Media Manager
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(33, 87, 85), (33, 88, 75), (33, 91, 75), (33, 90, 60), (33, 89, 60), (33, 85, 50);

-- Network Engineer
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(34, 100, 85), (34, 101, 85), (34, 103, 80), (34, 71, 70), (34, 102, 65), (34, 64, 55);

-- System Administrator
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(35, 64, 80), (35, 104, 85), (35, 100, 70), (35, 14, 65), (35, 59, 55), (35, 97, 60);

-- IT Support Specialist
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(36, 105, 75), (36, 100, 65), (36, 104, 60), (36, 97, 65), (36, 98, 65), (36, 64, 50);

-- Product Manager
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(37, 94, 85), (37, 92, 80), (37, 93, 70), (37, 97, 80), (37, 96, 75), (37, 34, 55), (37, 98, 75);

-- Project Manager
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(38, 95, 85), (38, 92, 80), (38, 93, 75), (38, 96, 75), (38, 97, 80), (38, 99, 65);

-- Scrum Master
INSERT INTO career_skill_requirements (career_id, skill_id, required_level) VALUES
(39, 92, 90), (39, 93, 80), (39, 96, 70), (39, 97, 85), (39, 95, 65), (39, 99, 60);

-- ============================================================================
-- 7. VERIFICATION QUERIES (run these to confirm the seed worked)
-- ============================================================================

SELECT 'education_categories' AS table_name, COUNT(*) AS rows_count FROM education_categories
UNION ALL SELECT 'education_programs', COUNT(*) FROM education_programs
UNION ALL SELECT 'domains', COUNT(*) FROM domains
UNION ALL SELECT 'skills_v2', COUNT(*) FROM skills_v2
UNION ALL SELECT 'careers_v2', COUNT(*) FROM careers_v2
UNION ALL SELECT 'career_skill_requirements', COUNT(*) FROM career_skill_requirements;

-- Sample: careers in each domain with their skill counts
SELECT d.name AS domain, c.name AS career,
       COUNT(r.skill_id) AS skill_count
FROM domains d
JOIN careers_v2 c ON c.domain_id = d.id
LEFT JOIN career_skill_requirements r ON r.career_id = c.id
GROUP BY d.id, c.id
ORDER BY d.name, c.name;
