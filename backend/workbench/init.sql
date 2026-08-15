-- =====================================================
-- AI SKILL GAP ANALYZER - CLEAN DATABASE SEED
-- Generated from generate_seed.py
-- Quality-first dataset: counts are NOT artificially forced.
-- =====================================================

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `resume_analyses`;
DROP TABLE IF EXISTS `career_skill_requirements`;
DROP TABLE IF EXISTS `careers_v2`;
DROP TABLE IF EXISTS `skills_v2`;
DROP TABLE IF EXISTS `domains`;
DROP TABLE IF EXISTS `education_programs`;
DROP TABLE IF EXISTS `education_categories`;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE `education_categories` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_education_categories_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `education_programs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `category_id` INT NULL,
  `name` VARCHAR(150) NOT NULL,
  `level` VARCHAR(50),
  `description` TEXT,
  PRIMARY KEY (`id`),
  KEY `idx_program_category` (`category_id`),
  CONSTRAINT `fk_program_category` FOREIGN KEY (`category_id`) REFERENCES `education_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `domains` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `description` TEXT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_domains_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `careers_v2` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `domain_id` INT NULL,
  `name` VARCHAR(150) NOT NULL,
  `description` TEXT,
  `average_level` VARCHAR(50),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_careers_name` (`name`),
  KEY `idx_career_domain` (`domain_id`),
  CONSTRAINT `fk_career_domain` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `skills_v2` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `category` VARCHAR(100),
  `description` TEXT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_skills_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `career_skill_requirements` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `career_id` INT NOT NULL,
  `skill_id` INT NOT NULL,
  `required_level` INT NOT NULL DEFAULT 50,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_career_skill` (`career_id`,`skill_id`),
  KEY `idx_csr_skill` (`skill_id`),
  CONSTRAINT `fk_csr_career` FOREIGN KEY (`career_id`) REFERENCES `careers_v2` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_csr_skill` FOREIGN KEY (`skill_id`) REFERENCES `skills_v2` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `resume_analyses` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `file_name` VARCHAR(255) NOT NULL,
  `file_size` INT NULL,
  `owner_token` VARCHAR(64) NULL,
  `raw_text` TEXT NULL,
  `extracted_skills` JSON NULL,
  `target_career_id` INT NULL,
  `extraction_source` VARCHAR(20) DEFAULT 'keyword',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_resume_owner_token` (`owner_token`),
  KEY `idx_resume_target_career` (`target_career_id`),
  CONSTRAINT `fk_resume_target_career` FOREIGN KEY (`target_career_id`) REFERENCES `careers_v2` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Education categories
INSERT INTO `education_categories` (`name`,`description`) VALUES
('Computer Science & IT','Computing, software, information technology and data programs'),
('Engineering','Engineering degrees and technical specializations'),
('Business & Management','Business, management, marketing and operations programs'),
('Commerce & Finance','Accounting, finance, banking and taxation programs'),
('Science','Pure and applied science programs'),
('Arts, Design & Media','Design, communication, media and creative programs'),
('Health & Life Sciences','Healthcare, life science and allied health programs'),
('Law','Legal education and professional law programs'),
('Education','Teacher education and instructional programs'),
('Vocational & Diploma','Practical technical, trade and diploma pathways');

-- Education programs
INSERT INTO `education_programs` (`category_id`,`name`,`level`,`description`)
SELECT c.id, p.name, p.level, p.description
FROM (
  SELECT 'Computer Science & IT' AS category_name, 'BCA' AS name, 'Undergraduate' AS level, 'Bachelor''s program focused on computer applications and software' AS description
  UNION ALL SELECT 'Computer Science & IT' AS category_name, 'B.Sc Computer Science' AS name, 'Undergraduate' AS level, 'Foundations of computer science and programming' AS description
  UNION ALL SELECT 'Computer Science & IT' AS category_name, 'B.Tech Computer Science & Engineering' AS name, 'Undergraduate' AS level, 'Engineering degree in computing and software' AS description
  UNION ALL SELECT 'Computer Science & IT' AS category_name, 'B.Tech Artificial Intelligence & Data Science' AS name, 'Undergraduate' AS level, 'Engineering degree focused on AI and data' AS description
  UNION ALL SELECT 'Computer Science & IT' AS category_name, 'MCA' AS name, 'Postgraduate' AS level, 'Postgraduate degree in computer applications' AS description
  UNION ALL SELECT 'Computer Science & IT' AS category_name, 'M.Sc Data Science' AS name, 'Postgraduate' AS level, 'Advanced data analysis and data science' AS description
  UNION ALL SELECT 'Computer Science & IT' AS category_name, 'M.Tech Computer Science' AS name, 'Postgraduate' AS level, 'Advanced computer science and engineering' AS description
  UNION ALL SELECT 'Engineering' AS category_name, 'B.Tech Mechanical Engineering' AS name, 'Undergraduate' AS level, 'Mechanical systems, design and manufacturing' AS description
  UNION ALL SELECT 'Engineering' AS category_name, 'B.Tech Civil Engineering' AS name, 'Undergraduate' AS level, 'Infrastructure, structures and construction' AS description
  UNION ALL SELECT 'Engineering' AS category_name, 'B.Tech Electrical Engineering' AS name, 'Undergraduate' AS level, 'Electrical systems and power' AS description
  UNION ALL SELECT 'Engineering' AS category_name, 'B.Tech Electronics & Communication' AS name, 'Undergraduate' AS level, 'Electronics, communications and embedded systems' AS description
  UNION ALL SELECT 'Engineering' AS category_name, 'B.Tech Chemical Engineering' AS name, 'Undergraduate' AS level, 'Chemical processes and industrial systems' AS description
  UNION ALL SELECT 'Engineering' AS category_name, 'B.Tech Biotechnology' AS name, 'Undergraduate' AS level, 'Biological engineering and biotechnology' AS description
  UNION ALL SELECT 'Engineering' AS category_name, 'B.Tech Automobile Engineering' AS name, 'Undergraduate' AS level, 'Vehicle engineering and automotive systems' AS description
  UNION ALL SELECT 'Business & Management' AS category_name, 'BBA' AS name, 'Undergraduate' AS level, 'Business administration and management' AS description
  UNION ALL SELECT 'Business & Management' AS category_name, 'BMS' AS name, 'Undergraduate' AS level, 'Management studies' AS description
  UNION ALL SELECT 'Business & Management' AS category_name, 'MBA' AS name, 'Postgraduate' AS level, 'Advanced business and management' AS description
  UNION ALL SELECT 'Business & Management' AS category_name, 'MBA Marketing' AS name, 'Postgraduate' AS level, 'Marketing strategy and brand management' AS description
  UNION ALL SELECT 'Business & Management' AS category_name, 'MBA Finance' AS name, 'Postgraduate' AS level, 'Corporate finance and financial management' AS description
  UNION ALL SELECT 'Business & Management' AS category_name, 'MBA HR' AS name, 'Postgraduate' AS level, 'Human resources and organizational management' AS description
  UNION ALL SELECT 'Business & Management' AS category_name, 'MBA Operations' AS name, 'Postgraduate' AS level, 'Operations and supply chain management' AS description
  UNION ALL SELECT 'Commerce & Finance' AS category_name, 'B.Com' AS name, 'Undergraduate' AS level, 'Commerce, accounting and business foundations' AS description
  UNION ALL SELECT 'Commerce & Finance' AS category_name, 'B.Com Accounting & Finance' AS name, 'Undergraduate' AS level, 'Accounting and finance specialization' AS description
  UNION ALL SELECT 'Commerce & Finance' AS category_name, 'CA' AS name, 'Professional' AS level, 'Professional qualification in accounting, audit and taxation' AS description
  UNION ALL SELECT 'Commerce & Finance' AS category_name, 'CS' AS name, 'Professional' AS level, 'Professional qualification in company law and governance' AS description
  UNION ALL SELECT 'Commerce & Finance' AS category_name, 'CMA' AS name, 'Professional' AS level, 'Professional qualification in cost and management accounting' AS description
  UNION ALL SELECT 'Science' AS category_name, 'B.Sc Mathematics' AS name, 'Undergraduate' AS level, 'Mathematics and quantitative foundations' AS description
  UNION ALL SELECT 'Science' AS category_name, 'B.Sc Statistics' AS name, 'Undergraduate' AS level, 'Statistics and data analysis foundations' AS description
  UNION ALL SELECT 'Science' AS category_name, 'B.Sc Physics' AS name, 'Undergraduate' AS level, 'Physics and scientific methods' AS description
  UNION ALL SELECT 'Science' AS category_name, 'B.Sc Chemistry' AS name, 'Undergraduate' AS level, 'Chemistry and laboratory science' AS description
  UNION ALL SELECT 'Science' AS category_name, 'B.Sc Biotechnology' AS name, 'Undergraduate' AS level, 'Biotechnology and life sciences' AS description
  UNION ALL SELECT 'Science' AS category_name, 'B.Sc Psychology' AS name, 'Undergraduate' AS level, 'Psychology and human behaviour' AS description
  UNION ALL SELECT 'Arts, Design & Media' AS category_name, 'BA English' AS name, 'Undergraduate' AS level, 'English language, literature and communication' AS description
  UNION ALL SELECT 'Arts, Design & Media' AS category_name, 'BA Journalism & Mass Communication' AS name, 'Undergraduate' AS level, 'Journalism, media and communication' AS description
  UNION ALL SELECT 'Arts, Design & Media' AS category_name, 'B.Des' AS name, 'Undergraduate' AS level, 'Design foundations and creative practice' AS description
  UNION ALL SELECT 'Arts, Design & Media' AS category_name, 'B.Des Fashion Design' AS name, 'Undergraduate' AS level, 'Fashion and textile design' AS description
  UNION ALL SELECT 'Arts, Design & Media' AS category_name, 'B.Sc Animation & VFX' AS name, 'Undergraduate' AS level, 'Animation, 3D and visual effects' AS description
  UNION ALL SELECT 'Health & Life Sciences' AS category_name, 'B.Pharm' AS name, 'Professional' AS level, 'Pharmacy and pharmaceutical sciences' AS description
  UNION ALL SELECT 'Health & Life Sciences' AS category_name, 'BPT' AS name, 'Professional' AS level, 'Physiotherapy and rehabilitation' AS description
  UNION ALL SELECT 'Health & Life Sciences' AS category_name, 'B.Sc Nursing' AS name, 'Professional' AS level, 'Nursing and patient care' AS description
  UNION ALL SELECT 'Health & Life Sciences' AS category_name, 'B.Sc Medical Lab Technology' AS name, 'Undergraduate' AS level, 'Clinical laboratory diagnostics' AS description
  UNION ALL SELECT 'Health & Life Sciences' AS category_name, 'MBBS' AS name, 'Professional' AS level, 'Medical education and clinical practice' AS description
  UNION ALL SELECT 'Law' AS category_name, 'LLB' AS name, 'Professional' AS level, 'Professional law degree' AS description
  UNION ALL SELECT 'Law' AS category_name, 'BA LLB' AS name, 'Professional' AS level, 'Integrated undergraduate law degree' AS description
  UNION ALL SELECT 'Law' AS category_name, 'LLM' AS name, 'Postgraduate' AS level, 'Advanced legal specialization' AS description
  UNION ALL SELECT 'Education' AS category_name, 'B.Ed' AS name, 'Professional' AS level, 'Teacher education and pedagogy' AS description
  UNION ALL SELECT 'Education' AS category_name, 'M.Ed' AS name, 'Postgraduate' AS level, 'Advanced education studies' AS description
  UNION ALL SELECT 'Vocational & Diploma' AS category_name, 'Diploma in Computer Applications' AS name, 'Diploma' AS level, 'Practical computing and office applications' AS description
  UNION ALL SELECT 'Vocational & Diploma' AS category_name, 'Polytechnic Diploma in Engineering' AS name, 'Diploma' AS level, 'Technical engineering diploma' AS description
  UNION ALL SELECT 'Vocational & Diploma' AS category_name, 'ITI Electrician' AS name, 'Certificate' AS level, 'Electrical trade training' AS description
  UNION ALL SELECT 'Vocational & Diploma' AS category_name, 'Diploma in Digital Marketing' AS name, 'Diploma' AS level, 'Applied digital marketing' AS description
  UNION ALL SELECT 'Vocational & Diploma' AS category_name, 'Diploma in Graphic Design' AS name, 'Diploma' AS level, 'Applied graphic and visual design' AS description
) p JOIN `education_categories` c ON c.name=p.category_name;

-- Domains
INSERT INTO `domains` (`name`,`description`) VALUES
('Agriculture & Agribusiness','Professional careers in agriculture & agribusiness'),
('Animation & 3D','Professional careers in animation & 3d'),
('Architecture & Interior Design','Professional careers in architecture & interior design'),
('Artificial Intelligence','Build intelligent systems and AI-powered applications'),
('Automotive Engineering','Professional careers in automotive engineering'),
('Banking & Financial Services','Professional careers in banking & financial services'),
('Biotechnology & Life Sciences','Professional careers in biotechnology & life sciences'),
('Blockchain & Web3','Professional careers in blockchain & web3'),
('Business Analysis','Translate business needs into processes, requirements and decisions'),
('Chemical Engineering','Professional careers in chemical engineering'),
('Civil Engineering & Construction','Professional careers in civil engineering & construction'),
('Cloud Computing','Build and operate scalable cloud infrastructure'),
('Cybersecurity','Protect applications, systems, networks and data'),
('Data Engineering','Build data pipelines, platforms and analytical data systems'),
('Data Science & Analytics','Turn data into insights, forecasts and decisions'),
('Database & Data Management','Design, operate and optimize data storage systems'),
('DevOps & Site Reliability','Automate delivery and keep production systems reliable'),
('E-commerce','Professional careers in e-commerce'),
('Education & Teaching','Professional careers in education & teaching'),
('Electrical Engineering','Professional careers in electrical engineering'),
('Game Development','Professional careers in game development'),
('Government & Public Administration','Professional careers in government & public administration'),
('Graphic Design & Branding','Professional careers in graphic design & branding'),
('Hospitality & Tourism','Professional careers in hospitality & tourism'),
('Human Resources','Professional careers in human resources'),
('IoT & Embedded Systems','Professional careers in iot & embedded systems'),
('Law & Legal Services','Professional careers in law & legal services'),
('Machine Learning','Develop predictive and learning-based systems'),
('Manufacturing & Industrial Engineering','Professional careers in manufacturing & industrial engineering'),
('Mobile App Development','Build applications for mobile platforms'),
('Nursing & Patient Care','Professional careers in nursing & patient care'),
('Product Management','Guide products from discovery through delivery'),
('Psychology & Counselling','Professional careers in psychology & counselling'),
('Robotics & Automation','Professional careers in robotics & automation'),
('Sales & Business Development','Professional careers in sales & business development'),
('Software Development','Build and maintain software applications and services'),
('Software Testing & QA','Validate software quality, reliability and performance'),
('Supply Chain & Logistics','Professional careers in supply chain & logistics'),
('Web Development','Create modern web applications and digital experiences');

-- Canonical skills
INSERT INTO `skills_v2` (`name`,`category`,`description`) VALUES
('3D Mathematics','Professional Skills','Skill relevant to game development'),
('3D Modeling','Professional Skills','Skill relevant to animation & 3d'),
('3D Visualization','Professional Skills','Skill relevant to architecture & interior design'),
('ANSYS','Professional Skills','Skill relevant to automotive engineering'),
('API Testing','Professional Skills','Skill relevant to software testing & qa'),
('AWS','Cloud & DevOps','Cloud platform for compute, storage, networking and managed services'),
('Academic Writing','Professional Skills','Skill relevant to education & teaching'),
('Active Listening','Professional Skills','Skill relevant to psychology & counselling'),
('Adobe Illustrator','Professional Skills','Skill relevant to graphic design & branding'),
('Adobe Photoshop','Professional Skills','Skill relevant to graphic design & branding'),
('Adobe Premiere Pro','Professional Skills','Skill relevant to animation & 3d'),
('After Effects','Professional Skills','Skill relevant to animation & 3d'),
('Agile & Scrum','Professional Skills','Skill relevant to product management'),
('Agri Supply Chain','Professional Skills','Skill relevant to agriculture & agribusiness'),
('Agronomy','Professional Skills','Skill relevant to agriculture & agribusiness'),
('Amazon Seller Central','Professional Skills','Skill relevant to e-commerce'),
('Analytical Chemistry','Professional Skills','Skill relevant to chemical engineering'),
('Android SDK','Professional Skills','Skill relevant to mobile app development'),
('Answer Writing Practice','Professional Skills','Skill relevant to government & public administration'),
('Apache Airflow','Professional Skills','Skill relevant to data engineering'),
('Apache Kafka','Professional Skills','Skill relevant to data engineering'),
('Apache Spark','Professional Skills','Skill relevant to data engineering'),
('Arduino Programming','Professional Skills','Skill relevant to iot & embedded systems'),
('Aspen HYSYS','Professional Skills','Skill relevant to chemical engineering'),
('Assessment Design','Professional Skills','Skill relevant to education & teaching'),
('Authentication & Authorization','Professional Skills','Skill relevant to software development'),
('AutoCAD','Professional Skills','Skill relevant to civil engineering & construction'),
('AutoCAD Electrical','Professional Skills','Skill relevant to electrical engineering'),
('B2B Sales','Professional Skills','Skill relevant to sales & business development'),
('Backup & Recovery','Professional Skills','Skill relevant to database & data management'),
('Banking Operations','Professional Skills','Skill relevant to banking & financial services'),
('Battery Management Systems','Professional Skills','Skill relevant to automotive engineering'),
('Billing Engineering','Professional Skills','Skill relevant to civil engineering & construction'),
('Bioinformatics Tools','Professional Skills','Skill relevant to biotechnology & life sciences'),
('Blender','Professional Skills','Skill relevant to game development'),
('Branding','Professional Skills','Skill relevant to graphic design & branding'),
('Bug Tracking','Professional Skills','Skill relevant to software testing & qa'),
('Building Codes','Professional Skills','Skill relevant to architecture & interior design'),
('Burp Suite','Professional Skills','Skill relevant to cybersecurity'),
('Business Analysis','Professional Skills','Skill relevant to data science & analytics'),
('Business Process Modeling','Professional Skills','Skill relevant to business analysis'),
('C','Programming','Low-level programming language used in systems and embedded development'),
('C#','Professional Skills','Skill relevant to game development'),
('CAN Bus','Professional Skills','Skill relevant to automotive engineering'),
('CATIA','Professional Skills','Skill relevant to automotive engineering'),
('CBT Basics','Professional Skills','Skill relevant to psychology & counselling'),
('CI/CD Pipelines','Professional Skills','Skill relevant to software testing & qa'),
('CNC Programming','Professional Skills','Skill relevant to manufacturing & industrial engineering'),
('CRM Tools','Professional Skills','Skill relevant to sales & business development'),
('CSS','Web','Language used to style and lay out web pages'),
('Cable Sizing','Professional Skills','Skill relevant to electrical engineering'),
('Case Documentation','Professional Skills','Skill relevant to psychology & counselling'),
('Case Management','Professional Skills','Skill relevant to law & legal services'),
('Cell Culture','Professional Skills','Skill relevant to biotechnology & life sciences'),
('Character Animation','Professional Skills','Skill relevant to animation & 3d'),
('Chemical Reaction Engineering','Professional Skills','Skill relevant to chemical engineering'),
('Circuit Debugging','Professional Skills','Skill relevant to iot & embedded systems'),
('Classroom Management','Professional Skills','Skill relevant to education & teaching'),
('Client Relationship Management','Professional Skills','Skill relevant to sales & business development'),
('Clinical Data Management','Professional Skills','Skill relevant to biotechnology & life sciences'),
('Clinical Diagnosis','Professional Skills','Skill relevant to psychology & counselling'),
('Clinical Trials','Professional Skills','Skill relevant to biotechnology & life sciences'),
('Cloud Computing','Professional Skills','Skill relevant to devops & site reliability'),
('Cold Calling','Professional Skills','Skill relevant to sales & business development'),
('Color Grading','Professional Skills','Skill relevant to animation & 3d'),
('Color Theory','Professional Skills','Skill relevant to graphic design & branding'),
('Communication','Soft Skills','Clear written and verbal professional communication'),
('Community Health','Professional Skills','Skill relevant to nursing & patient care'),
('Compliance','Professional Skills','Skill relevant to law & legal services'),
('Compositing','Professional Skills','Skill relevant to animation & 3d'),
('Computer Vision','Professional Skills','Skill relevant to machine learning'),
('Concrete Technology','Professional Skills','Skill relevant to civil engineering & construction'),
('Construction Management','Professional Skills','Skill relevant to civil engineering & construction'),
('Content Quality Review','Professional Skills','Skill relevant to e-commerce'),
('Contract Drafting','Professional Skills','Skill relevant to law & legal services'),
('Contract Management','Professional Skills','Skill relevant to civil engineering & construction'),
('Control Systems','Professional Skills','Skill relevant to robotics & automation'),
('Corporate Law','Professional Skills','Skill relevant to law & legal services'),
('Cost Analysis','Professional Skills','Skill relevant to supply chain & logistics'),
('Counselling Techniques','Professional Skills','Skill relevant to psychology & counselling'),
('Court Procedures','Professional Skills','Skill relevant to law & legal services'),
('Credit Analysis','Professional Skills','Skill relevant to banking & financial services'),
('Critical Care Nursing','Professional Skills','Skill relevant to nursing & patient care'),
('Crop Management','Professional Skills','Skill relevant to agriculture & agribusiness'),
('Cryptography','Professional Skills','Skill relevant to blockchain & web3'),
('Culinary Arts','Professional Skills','Skill relevant to hospitality & tourism'),
('Current Affairs','Professional Skills','Skill relevant to government & public administration'),
('Curriculum Design','Professional Skills','Skill relevant to education & teaching'),
('Customer Service','Professional Skills','Skill relevant to banking & financial services'),
('DAX','Professional Skills','Skill relevant to data science & analytics'),
('Dart','Programming','Programming language used by Flutter'),
('Data Acquisition','Professional Skills','Skill relevant to automotive engineering'),
('Data Analysis','Professional Skills','Skill relevant to business analysis'),
('Data Cleaning','Professional Skills','Skill relevant to data science & analytics'),
('Data Modeling','Professional Skills','Skill relevant to data engineering'),
('Data Structures & Algorithms','Professional Skills','Skill relevant to software development'),
('Data Visualization','Data & AI','Communicating patterns and insights through visualizations'),
('Data Warehousing','Professional Skills','Skill relevant to data engineering'),
('Database Administration','Professional Skills','Skill relevant to database & data management'),
('Database Security','Professional Skills','Skill relevant to database & data management'),
('Deep Learning','Data & AI','Neural-network methods for complex learning tasks'),
('Demand Forecasting','Professional Skills','Skill relevant to supply chain & logistics'),
('Design Systems','Professional Skills','Skill relevant to graphic design & branding'),
('Destination Knowledge','Professional Skills','Skill relevant to hospitality & tourism'),
('Device Drivers','Professional Skills','Skill relevant to iot & embedded systems'),
('Digital Cataloging','Professional Skills','Skill relevant to e-commerce'),
('Docker','Cloud & DevOps','Containerization technology'),
('Drafting & Pleadings','Professional Skills','Skill relevant to law & legal services'),
('E-commerce Platforms','Professional Skills','Skill relevant to e-commerce'),
('E-commerce SEO','Professional Skills','Skill relevant to e-commerce'),
('E-learning Tools','Professional Skills','Skill relevant to education & teaching'),
('ETABS','Professional Skills','Skill relevant to civil engineering & construction'),
('ETAP','Professional Skills','Skill relevant to electrical engineering'),
('ETL Design','Professional Skills','Skill relevant to data engineering'),
('Economics Basics','Professional Skills','Skill relevant to government & public administration'),
('Educational Technology','Professional Skills','Skill relevant to education & teaching'),
('Electric Vehicle Architecture','Professional Skills','Skill relevant to automotive engineering'),
('Electrical Design','Professional Skills','Skill relevant to electrical engineering'),
('Embedded C','Professional Skills','Skill relevant to iot & embedded systems'),
('Embeddings','Professional Skills','Skill relevant to artificial intelligence'),
('Employee Engagement','Professional Skills','Skill relevant to human resources'),
('English Language','Professional Skills','Skill relevant to government & public administration'),
('Essay Writing','Professional Skills','Skill relevant to government & public administration'),
('Estimation & Costing','Professional Skills','Skill relevant to civil engineering & construction'),
('Ethereum','Professional Skills','Skill relevant to blockchain & web3'),
('Ethics in Psychology','Professional Skills','Skill relevant to psychology & counselling'),
('Excel','Analytics Tools','Spreadsheet analysis, formulas, pivots and reporting'),
('Exploratory Data Analysis','Professional Skills','Skill relevant to data science & analytics'),
('Feature Engineering','Professional Skills','Skill relevant to data science & analytics'),
('Field Research','Professional Skills','Skill relevant to agriculture & agribusiness'),
('Figma','Professional Skills','Skill relevant to animation & 3d'),
('Financial Modeling','Professional Skills','Skill relevant to banking & financial services'),
('Financial Products','Professional Skills','Skill relevant to banking & financial services'),
('Financial Statement Analysis','Professional Skills','Skill relevant to banking & financial services'),
('First Aid & BLS','Professional Skills','Skill relevant to nursing & patient care'),
('Flutter','Professional Skills','Skill relevant to mobile app development'),
('Food Safety & Hygiene','Professional Skills','Skill relevant to hospitality & tourism'),
('Foundation Design','Professional Skills','Skill relevant to civil engineering & construction'),
('Front Office Operations','Professional Skills','Skill relevant to hospitality & tourism'),
('GCP Guidelines','Professional Skills','Skill relevant to biotechnology & life sciences'),
('GD&T','Professional Skills','Skill relevant to manufacturing & industrial engineering'),
('GDS Systems','Professional Skills','Skill relevant to hospitality & tourism'),
('GIS Tools','Professional Skills','Skill relevant to architecture & interior design'),
('Game Design Fundamentals','Professional Skills','Skill relevant to game development'),
('Game Physics','Professional Skills','Skill relevant to game development'),
('General Awareness','Professional Skills','Skill relevant to government & public administration'),
('General Studies','Professional Skills','Skill relevant to government & public administration'),
('Genomics','Professional Skills','Skill relevant to biotechnology & life sciences'),
('Git','Tools','Version control for source code'),
('Google Analytics','Professional Skills','Skill relevant to e-commerce'),
('Guest Relations','Professional Skills','Skill relevant to hospitality & tourism'),
('HAZOP Basics','Professional Skills','Skill relevant to chemical engineering'),
('HMI Development','Professional Skills','Skill relevant to robotics & automation'),
('HR Analytics','Professional Skills','Skill relevant to human resources'),
('HRMS Tools','Professional Skills','Skill relevant to human resources'),
('HTML','Web','Markup language used to structure web pages'),
('Hadoop','Professional Skills','Skill relevant to data engineering'),
('Health Education','Professional Skills','Skill relevant to nursing & patient care'),
('Heat & Mass Transfer','Professional Skills','Skill relevant to chemical engineering'),
('Homologation','Professional Skills','Skill relevant to automotive engineering'),
('IAM','Professional Skills','Skill relevant to cloud computing'),
('InDesign','Professional Skills','Skill relevant to graphic design & branding'),
('Incident Response','Professional Skills','Skill relevant to cybersecurity'),
('Indian Electricity Rules','Professional Skills','Skill relevant to electrical engineering'),
('Indian History & Geography','Professional Skills','Skill relevant to government & public administration'),
('Indian Polity','Professional Skills','Skill relevant to government & public administration'),
('Industrial Wiring','Professional Skills','Skill relevant to robotics & automation'),
('Infection Control','Professional Skills','Skill relevant to nursing & patient care'),
('Infrastructure as Code','Professional Skills','Skill relevant to cloud computing'),
('Instrumentation','Professional Skills','Skill relevant to electrical engineering'),
('Insurance Products','Professional Skills','Skill relevant to banking & financial services'),
('Intellectual Property','Professional Skills','Skill relevant to law & legal services'),
('Interviewing','Professional Skills','Skill relevant to human resources'),
('Inventory Management','Professional Skills','Skill relevant to supply chain & logistics'),
('JIRA','Professional Skills','Skill relevant to software testing & qa'),
('JMeter','Professional Skills','Skill relevant to software testing & qa'),
('Java','Programming','Object-oriented language widely used for enterprise applications'),
('JavaScript','Programming','Core programming language for modern web applications'),
('Jetpack Compose','Professional Skills','Skill relevant to mobile app development'),
('KYC & AML','Professional Skills','Skill relevant to banking & financial services'),
('Kaizen','Professional Skills','Skill relevant to manufacturing & industrial engineering'),
('Kinematics','Professional Skills','Skill relevant to robotics & automation'),
('Kitchen Management','Professional Skills','Skill relevant to hospitality & tourism'),
('Kotlin','Programming','Modern language commonly used for Android development'),
('Kubernetes','Cloud & DevOps','Platform for orchestrating containerized applications'),
('LLM Fundamentals','Professional Skills','Skill relevant to artificial intelligence'),
('Lab Techniques','Professional Skills','Skill relevant to chemical engineering'),
('Labour Laws','Professional Skills','Skill relevant to human resources'),
('Ladder Logic','Professional Skills','Skill relevant to electrical engineering'),
('Layout Design','Professional Skills','Skill relevant to graphic design & branding'),
('Lead Generation','Professional Skills','Skill relevant to sales & business development'),
('Leadership','Soft Skills','Leading people, decisions and initiatives'),
('Lean Manufacturing','Professional Skills','Skill relevant to manufacturing & industrial engineering'),
('Learning Management Systems','Professional Skills','Skill relevant to education & teaching'),
('Legal Research','Professional Skills','Skill relevant to law & legal services'),
('Lesson Planning','Professional Skills','Skill relevant to education & teaching'),
('Level Design','Professional Skills','Skill relevant to game development'),
('Linux Administration','Professional Skills','Skill relevant to iot & embedded systems'),
('Litigation','Professional Skills','Skill relevant to law & legal services'),
('LoadRunner','Professional Skills','Skill relevant to software testing & qa'),
('Logical Reasoning','Professional Skills','Skill relevant to government & public administration'),
('Logistics Planning','Professional Skills','Skill relevant to supply chain & logistics'),
('M&A Basics','Professional Skills','Skill relevant to law & legal services'),
('MATLAB','Professional Skills','Skill relevant to robotics & automation'),
('MLOps','Data & AI','Practices for deploying and operating machine-learning systems'),
('MQTT','Professional Skills','Skill relevant to iot & embedded systems'),
('Machine Learning','Data & AI','Algorithms that learn patterns from data'),
('Machine Tools','Professional Skills','Skill relevant to manufacturing & industrial engineering'),
('Manual Testing','Professional Skills','Skill relevant to software testing & qa'),
('Manufacturing Processes','Professional Skills','Skill relevant to robotics & automation'),
('Market Research','Professional Skills','Skill relevant to sales & business development'),
('Mastercam','Professional Skills','Skill relevant to manufacturing & industrial engineering'),
('Material Selection','Professional Skills','Skill relevant to architecture & interior design'),
('Maya','Professional Skills','Skill relevant to animation & 3d'),
('Medical Documentation','Professional Skills','Skill relevant to nursing & patient care'),
('Medical Terminology','Professional Skills','Skill relevant to biotechnology & life sciences'),
('Medication Administration','Professional Skills','Skill relevant to nursing & patient care'),
('Menu Planning','Professional Skills','Skill relevant to hospitality & tourism'),
('Meta Ads','Professional Skills','Skill relevant to e-commerce'),
('Microcontrollers','Professional Skills','Skill relevant to iot & embedded systems'),
('Mobile UI Design','Professional Skills','Skill relevant to mobile app development'),
('Model Evaluation','Professional Skills','Skill relevant to data science & analytics'),
('Molecular Biology','Professional Skills','Skill relevant to biotechnology & life sciences'),
('Monitoring & Observability','Professional Skills','Skill relevant to software testing & qa'),
('Motion Graphics','Professional Skills','Skill relevant to animation & 3d'),
('Negotiation','Professional Skills','Skill relevant to law & legal services'),
('Networking Fundamentals','Professional Skills','Skill relevant to cloud computing'),
('Node.js','Web','JavaScript runtime used for server-side applications'),
('Nuke','Professional Skills','Skill relevant to animation & 3d'),
('OWASP Top 10','Professional Skills','Skill relevant to cybersecurity'),
('Object-Oriented Programming','Professional Skills','Skill relevant to software development'),
('Onboarding','Professional Skills','Skill relevant to human resources'),
('OpenCV','Professional Skills','Skill relevant to machine learning'),
('Operations Research','Professional Skills','Skill relevant to manufacturing & industrial engineering'),
('Order Management','Professional Skills','Skill relevant to e-commerce'),
('P&ID Reading','Professional Skills','Skill relevant to chemical engineering'),
('PCR Techniques','Professional Skills','Skill relevant to biotechnology & life sciences'),
('PLC Programming','Professional Skills','Skill relevant to robotics & automation'),
('Pandas','Data & AI','Python library for tabular data manipulation and analysis'),
('Panel Design','Professional Skills','Skill relevant to electrical engineering'),
('Patient Care','Professional Skills','Skill relevant to nursing & patient care'),
('Payroll Processing','Professional Skills','Skill relevant to human resources'),
('Penetration Testing','Professional Skills','Skill relevant to cybersecurity'),
('Performance Management','Professional Skills','Skill relevant to human resources'),
('Performance Optimization','Professional Skills','Skill relevant to game development'),
('Performance Testing','Professional Skills','Skill relevant to software testing & qa'),
('Performance Tuning','Professional Skills','Skill relevant to database & data management'),
('Pest & Disease Management','Professional Skills','Skill relevant to agriculture & agribusiness'),
('Pipeline Management','Professional Skills','Skill relevant to sales & business development'),
('Plant Operations','Professional Skills','Skill relevant to chemical engineering'),
('Policy Analysis','Professional Skills','Policy research, evaluation and public-sector decision analysis'),
('Power BI','Analytics Tools','Business intelligence dashboards and reporting'),
('Power System Analysis','Professional Skills','Skill relevant to electrical engineering'),
('Powertrain Systems','Professional Skills','Skill relevant to automotive engineering'),
('Precision Farming','Professional Skills','Skill relevant to agriculture & agribusiness'),
('Print Production','Professional Skills','Skill relevant to graphic design & branding'),
('Probability','Data & AI','Mathematical framework for uncertainty and random events'),
('Problem Solving','Soft Skills','Structured analysis and troubleshooting'),
('Process Control','Professional Skills','Skill relevant to chemical engineering'),
('Process Simulation','Professional Skills','Skill relevant to chemical engineering'),
('Procurement','Professional Skills','Skill relevant to supply chain & logistics'),
('Product Analytics','Professional Skills','Skill relevant to product management'),
('Product Knowledge','Professional Skills','Skill relevant to sales & business development'),
('Product Listing','Professional Skills','Skill relevant to e-commerce'),
('Product Roadmapping','Professional Skills','Skill relevant to product management'),
('Product Strategy','Professional Skills','Skill relevant to product management'),
('Production Planning','Professional Skills','Skill relevant to manufacturing & industrial engineering'),
('Programming Fundamentals','Professional Skills','Skill relevant to software development'),
('Prompt Engineering','Professional Skills','Skill relevant to artificial intelligence'),
('Protection Systems','Professional Skills','Skill relevant to electrical engineering'),
('Prototyping','Professional Skills','Skill relevant to game development'),
('Psychological Assessment','Professional Skills','Skill relevant to psychology & counselling'),
('PyTorch','Professional Skills','Skill relevant to machine learning'),
('Python','Programming','General-purpose programming language widely used in software, data and AI'),
('Quantitative Aptitude','Professional Skills','Skill relevant to banking & financial services'),
('R','Professional Skills','Skill relevant to biotechnology & life sciences'),
('RAG','Professional Skills','Skill relevant to artificial intelligence'),
('RCC Design','Professional Skills','Skill relevant to civil engineering & construction'),
('REST API Design','Professional Skills','Skill relevant to software development'),
('REST API Integration','Professional Skills','Skill relevant to web development'),
('ROS','Professional Skills','Skill relevant to robotics & automation'),
('RTOS','Professional Skills','Skill relevant to iot & embedded systems'),
('Raspberry Pi','Professional Skills','Skill relevant to iot & embedded systems'),
('Rate Analysis','Professional Skills','Skill relevant to civil engineering & construction'),
('React','Web','Component-based JavaScript library for user interfaces'),
('Recruitment','Professional Skills','Skill relevant to human resources'),
('Regulatory Compliance','Professional Skills','Skill relevant to chemical engineering'),
('Renewable Energy Systems','Professional Skills','Skill relevant to electrical engineering'),
('Report Writing','Professional Skills','Skill relevant to chemical engineering'),
('Requirements Analysis','Professional Skills','Skill relevant to business analysis'),
('Research Methods','Professional Skills','Skill relevant to education & teaching'),
('Reservation Systems','Professional Skills','Skill relevant to hospitality & tourism'),
('Responsive Web Design','Professional Skills','Skill relevant to web development'),
('Revit','Professional Skills','Skill relevant to architecture & interior design'),
('Risk Assessment','Professional Skills','Skill relevant to banking & financial services'),
('Route Optimization','Professional Skills','Skill relevant to supply chain & logistics'),
('SAP MM','Professional Skills','Skill relevant to supply chain & logistics'),
('SCADA','Professional Skills','Skill relevant to robotics & automation'),
('SDLC & STLC','Professional Skills','Skill relevant to software testing & qa'),
('SEO Writing','Professional Skills','Skill relevant to e-commerce'),
('SIEM','Professional Skills','Skill relevant to cybersecurity'),
('SQL','Databases','Language for querying and managing relational data'),
('STAAD Pro','Professional Skills','Skill relevant to civil engineering & construction'),
('Safety Procedures','Professional Skills','Skill relevant to chemical engineering'),
('Sales Techniques','Professional Skills','Skill relevant to hospitality & tourism'),
('Scala','Professional Skills','Skill relevant to data engineering'),
('Scikit-learn','Data & AI','Python machine-learning library'),
('Scriptwriting','Professional Skills','Skill relevant to game development'),
('Security Fundamentals','Professional Skills','Skill relevant to cybersecurity'),
('Selenium','Professional Skills','Skill relevant to software testing & qa'),
('Sensor Fusion','Professional Skills','Skill relevant to robotics & automation'),
('Sensor Integration','Professional Skills','Skill relevant to iot & embedded systems'),
('Shader Programming','Professional Skills','Skill relevant to game development'),
('Simulink','Professional Skills','Skill relevant to automotive engineering'),
('Site Planning','Professional Skills','Skill relevant to architecture & interior design'),
('Six Sigma','Professional Skills','Skill relevant to manufacturing & industrial engineering'),
('SketchUp','Professional Skills','Skill relevant to architecture & interior design'),
('Smart Contracts','Professional Skills','Skill relevant to blockchain & web3'),
('Social Media Strategy','Professional Skills','Skill relevant to human resources'),
('Soil Chemistry','Professional Skills','Skill relevant to agriculture & agribusiness'),
('Soil Testing','Professional Skills','Skill relevant to agriculture & agribusiness'),
('SolidWorks','Professional Skills','Skill relevant to robotics & automation'),
('Solidity','Professional Skills','Skill relevant to blockchain & web3'),
('Sourcing Strategies','Professional Skills','Skill relevant to human resources'),
('Space Planning','Professional Skills','Skill relevant to architecture & interior design'),
('Spectroscopy','Professional Skills','Skill relevant to chemical engineering'),
('Spring Boot','Backend','Java framework for production backend services'),
('Stakeholder Management','Professional Skills','Skill relevant to product management'),
('State Management','Professional Skills','Skill relevant to web development'),
('Statistics','Data & AI','Methods for describing and reasoning from data'),
('Storyboarding','Professional Skills','Planning visual sequences for learning, animation and media'),
('Storytelling','Professional Skills','Communicating ideas through structured narrative'),
('Structural Analysis','Professional Skills','Skill relevant to civil engineering & construction'),
('Subject Expertise','Professional Skills','Skill relevant to education & teaching'),
('Supply Chain Basics','Professional Skills','Skill relevant to e-commerce'),
('Surveying','Professional Skills','Skill relevant to civil engineering & construction'),
('Sustainable Design','Professional Skills','Skill relevant to architecture & interior design'),
('Test Automation','Professional Skills','Skill relevant to software testing & qa'),
('Test Case Design','Professional Skills','Skill relevant to software testing & qa'),
('Testing Fundamentals','Professional Skills','Skill relevant to software development'),
('Texturing & Lighting','Professional Skills','Skill relevant to animation & 3d'),
('Thermal Management','Professional Skills','Skill relevant to automotive engineering'),
('Threat Analysis','Professional Skills','Skill relevant to cybersecurity'),
('Time Management','Soft Skills','Prioritizing work and meeting deadlines'),
('Time Study','Professional Skills','Skill relevant to manufacturing & industrial engineering'),
('Travel Planning','Professional Skills','Skill relevant to hospitality & tourism'),
('Triage','Professional Skills','Skill relevant to nursing & patient care'),
('TypeScript','Programming','Typed language used for scalable JavaScript applications'),
('Typography','Professional Skills','Skill relevant to animation & 3d'),
('Underwriting Guidelines','Professional Skills','Skill relevant to banking & financial services'),
('Unit Testing','Professional Skills','Skill relevant to software development'),
('Unity','Professional Skills','Skill relevant to game development'),
('Unreal Engine','Professional Skills','Skill relevant to game development'),
('Upselling & Cross-selling','Professional Skills','Skill relevant to sales & business development'),
('Urban Planning','Professional Skills','Skill relevant to architecture & interior design'),
('User Research','Professional Skills','Skill relevant to product management'),
('Vector Databases','Professional Skills','Skill relevant to artificial intelligence'),
('Vehicle Dynamics','Professional Skills','Skill relevant to automotive engineering'),
('Vendor Management','Professional Skills','Skill relevant to supply chain & logistics'),
('Ventilator Management','Professional Skills','Skill relevant to nursing & patient care'),
('Visual Identity Design','Professional Skills','Skill relevant to graphic design & branding'),
('Web Accessibility','Professional Skills','Skill relevant to web development'),
('Web Security','Professional Skills','Skill relevant to cybersecurity'),
('Web3 Security','Professional Skills','Skill relevant to blockchain & web3'),
('Web3.js','Professional Skills','Skill relevant to blockchain & web3'),
('dbt','Professional Skills','Skill relevant to data engineering');

-- Careers
INSERT INTO `careers_v2` (`domain_id`,`name`,`description`,`average_level`)
SELECT d.id, x.name, x.description, x.average_level
FROM (
  SELECT 'Data Engineering' AS domain_name, 'Data Engineer' AS name, 'Build reliable data pipelines and platforms' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Data Engineering' AS domain_name, 'Analytics Engineer' AS name, 'Model clean data marts for analytics teams' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Data Engineering' AS domain_name, 'Big Data Engineer' AS name, 'Process massive datasets on distributed systems' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Game Development' AS domain_name, 'Game Developer' AS name, 'Build gameplay systems and ship games' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Game Development' AS domain_name, 'Unity Developer' AS name, 'Create 3D/2D games in the Unity engine' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Game Development' AS domain_name, 'Level Designer' AS name, 'Design engaging levels and player flows' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Blockchain & Web3' AS domain_name, 'Blockchain Developer' AS name, 'Build decentralized applications' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Blockchain & Web3' AS domain_name, 'Smart Contract Auditor' AS name, 'Find vulnerabilities in smart contracts' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Blockchain & Web3' AS domain_name, 'Web3 Frontend Developer' AS name, 'Build dApp interfaces connected to wallets' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'IoT & Embedded Systems' AS domain_name, 'Embedded Systems Engineer' AS name, 'Program microcontrollers at the hardware level' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'IoT & Embedded Systems' AS domain_name, 'IoT Developer' AS name, 'Connect devices to cloud platforms' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'IoT & Embedded Systems' AS domain_name, 'Firmware Engineer' AS name, 'Write low-level firmware for devices' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Robotics & Automation' AS domain_name, 'Robotics Engineer' AS name, 'Design and program robotic systems' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Robotics & Automation' AS domain_name, 'Automation Engineer' AS name, 'Automate industrial processes' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Robotics & Automation' AS domain_name, 'Mechatronics Engineer' AS name, 'Blend mechanics, electronics and software' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Civil Engineering & Construction' AS domain_name, 'Civil Engineer' AS name, 'Plan and supervise construction projects' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Civil Engineering & Construction' AS domain_name, 'Structural Engineer' AS name, 'Design safe structural systems' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Civil Engineering & Construction' AS domain_name, 'Quantity Surveyor' AS name, 'Estimate and control construction costs' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Electrical Engineering' AS domain_name, 'Electrical Design Engineer' AS name, 'Design electrical systems and panels' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Electrical Engineering' AS domain_name, 'Power Systems Engineer' AS name, 'Analyze and maintain power networks' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Electrical Engineering' AS domain_name, 'PLC Automation Engineer' AS name, 'Program industrial control systems' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Manufacturing & Industrial Engineering' AS domain_name, 'Production Engineer' AS name, 'Run efficient production lines' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Manufacturing & Industrial Engineering' AS domain_name, 'CNC Programmer' AS name, 'Program CNC machines for precision parts' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Manufacturing & Industrial Engineering' AS domain_name, 'Industrial Engineer' AS name, 'Optimize systems, time and resources' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Automotive Engineering' AS domain_name, 'Automotive Design Engineer' AS name, 'Design vehicle systems and components' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Automotive Engineering' AS domain_name, 'EV Design Engineer' AS name, 'Design electric vehicle systems' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Automotive Engineering' AS domain_name, 'Vehicle Testing Engineer' AS name, 'Validate vehicles against standards' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Chemical Engineering' AS domain_name, 'Process Engineer' AS name, 'Design and optimize chemical processes' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Chemical Engineering' AS domain_name, 'Plant Operations Engineer' AS name, 'Run safe and efficient plant operations' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Chemical Engineering' AS domain_name, 'R&D Chemist' AS name, 'Research and develop chemical products' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Biotechnology & Life Sciences' AS domain_name, 'Biotech Research Associate' AS name, 'Run wet-lab experiments and studies' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Biotechnology & Life Sciences' AS domain_name, 'Clinical Research Associate' AS name, 'Monitor clinical trials end to end' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Biotechnology & Life Sciences' AS domain_name, 'Bioinformatics Analyst' AS name, 'Analyze genomic data computationally' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Nursing & Patient Care' AS domain_name, 'Staff Nurse' AS name, 'Provide frontline patient care' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Nursing & Patient Care' AS domain_name, 'ICU Nurse' AS name, 'Care for critical patients in ICUs' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Nursing & Patient Care' AS domain_name, 'Community Health Officer' AS name, 'Deliver preventive community healthcare' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Education & Teaching' AS domain_name, 'School Teacher' AS name, 'Teach and mentor school students' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Education & Teaching' AS domain_name, 'Assistant Professor' AS name, 'Teach and research at university level' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Education & Teaching' AS domain_name, 'Instructional Designer' AS name, 'Design effective learning experiences' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Law & Legal Services' AS domain_name, 'Corporate Lawyer' AS name, 'Advise companies on deals and compliance' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Law & Legal Services' AS domain_name, 'Litigation Advocate' AS name, 'Represent clients in court' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Law & Legal Services' AS domain_name, 'Legal Analyst' AS name, 'Research and analyze legal matters' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Human Resources' AS domain_name, 'HR Executive' AS name, 'Handle day-to-day HR operations' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Human Resources' AS domain_name, 'Talent Acquisition Specialist' AS name, 'Find and hire great candidates' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Human Resources' AS domain_name, 'HR Business Partner' AS name, 'Align people strategy with business goals' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Sales & Business Development' AS domain_name, 'Sales Executive' AS name, 'Sell products and hit revenue targets' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Sales & Business Development' AS domain_name, 'Business Development Manager' AS name, 'Grow revenue through new business' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Sales & Business Development' AS domain_name, 'Account Manager' AS name, 'Retain and grow key client accounts' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Banking & Financial Services' AS domain_name, 'Bank Probationary Officer' AS name, 'Manage branch banking operations' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Banking & Financial Services' AS domain_name, 'Credit Analyst' AS name, 'Assess creditworthiness of borrowers' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Banking & Financial Services' AS domain_name, 'Insurance Underwriter' AS name, 'Price and accept insurance risks' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Supply Chain & Logistics' AS domain_name, 'Supply Chain Analyst' AS name, 'Optimize inventory and supply flows' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Supply Chain & Logistics' AS domain_name, 'Logistics Coordinator' AS name, 'Coordinate shipments and deliveries' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Supply Chain & Logistics' AS domain_name, 'Procurement Specialist' AS name, 'Buy goods and services smartly' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Hospitality & Tourism' AS domain_name, 'Front Office Executive' AS name, 'Run hotel reception and guest services' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Hospitality & Tourism' AS domain_name, 'Chef' AS name, 'Create menus and lead kitchen production' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Hospitality & Tourism' AS domain_name, 'Travel Consultant' AS name, 'Plan and book travel experiences' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Animation & 3D' AS domain_name, 'VFX Artist' AS name, 'Create cinematic visual effects' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Animation & 3D' AS domain_name, '3D Animator' AS name, 'Bring characters and worlds to life' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Animation & 3D' AS domain_name, 'Motion Graphics Designer' AS name, 'Animate graphics for video and web' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Graphic Design & Branding' AS domain_name, 'Graphic Designer' AS name, 'Design visuals for print and digital' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Graphic Design & Branding' AS domain_name, 'Brand Designer' AS name, 'Build complete brand identities' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Graphic Design & Branding' AS domain_name, 'Print & Layout Designer' AS name, 'Design print-ready publications' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Architecture & Interior Design' AS domain_name, 'Architect' AS name, 'Design buildings and oversee projects' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Architecture & Interior Design' AS domain_name, 'Interior Designer' AS name, 'Design functional beautiful interiors' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Architecture & Interior Design' AS domain_name, 'Urban Planner' AS name, 'Plan cities and public spaces' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Agriculture & Agribusiness' AS domain_name, 'Agronomist' AS name, 'Improve crop yield and soil health' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Agriculture & Agribusiness' AS domain_name, 'Agri Business Manager' AS name, 'Run agri products and supply businesses' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Agriculture & Agribusiness' AS domain_name, 'Soil Scientist' AS name, 'Study and classify soils' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Psychology & Counselling' AS domain_name, 'Counselling Psychologist' AS name, 'Support clients through life challenges' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Psychology & Counselling' AS domain_name, 'Clinical Psychologist' AS name, 'Assess and treat mental health conditions' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Psychology & Counselling' AS domain_name, 'HR Psychologist' AS name, 'Apply psychology to workplaces' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Government & Public Administration' AS domain_name, 'Civil Services Officer (UPSC)' AS name, 'Serve in IAS, IPS and allied services' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Government & Public Administration' AS domain_name, 'Public Policy Analyst' AS name, 'Research and evaluate public policies' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Government & Public Administration' AS domain_name, 'Government Administrative Officer' AS name, 'Support public administration through government service' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Software Testing & QA' AS domain_name, 'QA Analyst' AS name, 'Test software manually and report defects' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Software Testing & QA' AS domain_name, 'Automation Test Engineer' AS name, 'Automate regression test suites' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Software Testing & QA' AS domain_name, 'Performance Test Engineer' AS name, 'Stress-test systems for scale' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'E-commerce' AS domain_name, 'E-commerce Manager' AS name, 'Run online stores and marketplaces' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'E-commerce' AS domain_name, 'Marketplace Specialist' AS name, 'Grow sales on Amazon and Flipkart' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'E-commerce' AS domain_name, 'Catalog Quality Specialist' AS name, 'Keep product data clean and complete' AS description, 'Beginner' AS average_level
  UNION ALL SELECT 'Software Development' AS domain_name, 'Software Engineer' AS name, 'Design, build and maintain production software' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Software Development' AS domain_name, 'Backend Developer' AS name, 'Build server-side applications and APIs' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Software Development' AS domain_name, 'Java Developer' AS name, 'Build enterprise applications using Java' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Software Development' AS domain_name, 'Python Developer' AS name, 'Build applications and automation with Python' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Web Development' AS domain_name, 'Frontend Developer' AS name, 'Build responsive browser-based user interfaces' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Web Development' AS domain_name, 'Full Stack Developer' AS name, 'Build complete web applications across frontend and backend' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Web Development' AS domain_name, 'React Developer' AS name, 'Develop production interfaces with React' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Mobile App Development' AS domain_name, 'Android Developer' AS name, 'Build Android applications' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Mobile App Development' AS domain_name, 'Flutter Developer' AS name, 'Build cross-platform mobile applications' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Data Science & Analytics' AS domain_name, 'Data Analyst' AS name, 'Analyze data and communicate actionable insights' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Data Science & Analytics' AS domain_name, 'Data Scientist' AS name, 'Build statistical and machine-learning solutions from data' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Data Science & Analytics' AS domain_name, 'Business Intelligence Analyst' AS name, 'Build dashboards and analytical reporting for business decisions' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Artificial Intelligence' AS domain_name, 'AI Engineer' AS name, 'Build and integrate AI systems into applications' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Artificial Intelligence' AS domain_name, 'Generative AI Engineer' AS name, 'Build applications using generative AI models' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Machine Learning' AS domain_name, 'Machine Learning Engineer' AS name, 'Develop and productionize machine-learning models' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Machine Learning' AS domain_name, 'Computer Vision Engineer' AS name, 'Build systems that understand images and video' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Cloud Computing' AS domain_name, 'Cloud Engineer' AS name, 'Deploy and operate scalable cloud infrastructure' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'DevOps & Site Reliability' AS domain_name, 'DevOps Engineer' AS name, 'Automate software delivery and infrastructure operations' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Cybersecurity' AS domain_name, 'Cybersecurity Analyst' AS name, 'Detect, investigate and respond to security threats' AS description, 'Intermediate' AS average_level
  UNION ALL SELECT 'Cybersecurity' AS domain_name, 'Penetration Tester' AS name, 'Identify and validate security vulnerabilities' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Database & Data Management' AS domain_name, 'Database Administrator' AS name, 'Operate, secure and optimize database systems' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Product Management' AS domain_name, 'Product Manager' AS name, 'Define product strategy, requirements and outcomes' AS description, 'Advanced' AS average_level
  UNION ALL SELECT 'Business Analysis' AS domain_name, 'Business Analyst' AS name, 'Translate business needs into actionable requirements' AS description, 'Intermediate' AS average_level
) x JOIN `domains` d ON d.name=x.domain_name;

-- Career -> skill requirements
INSERT INTO `career_skill_requirements` (`career_id`,`skill_id`,`required_level`)
SELECT c.id, s.id, r.required_level
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
  UNION ALL SELECT 'Analytics Engineer' AS career_name, 'Git' AS skill_name, 62 AS required_level
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
  UNION ALL SELECT 'Game Developer' AS career_name, 'Git' AS skill_name, 57 AS required_level
  UNION ALL SELECT 'Unity Developer' AS career_name, 'Unity' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Unity Developer' AS career_name, 'C#' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Unity Developer' AS career_name, '3D Mathematics' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Unity Developer' AS career_name, 'Shader Programming' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Unity Developer' AS career_name, 'Git' AS skill_name, 62 AS required_level
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
  UNION ALL SELECT 'Web3 Frontend Developer' AS career_name, 'HTML' AS skill_name, 72 AS required_level
  UNION ALL SELECT 'Web3 Frontend Developer' AS career_name, 'CSS' AS skill_name, 72 AS required_level
  UNION ALL SELECT 'Web3 Frontend Developer' AS career_name, 'TypeScript' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Web3 Frontend Developer' AS career_name, 'Ethereum' AS skill_name, 60 AS required_level
  UNION ALL SELECT 'Embedded Systems Engineer' AS career_name, 'Embedded C' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Embedded Systems Engineer' AS career_name, 'Microcontrollers' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Embedded Systems Engineer' AS career_name, 'C' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Embedded Systems Engineer' AS career_name, 'RTOS' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Embedded Systems Engineer' AS career_name, 'Circuit Debugging' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Embedded Systems Engineer' AS career_name, 'Git' AS skill_name, 52 AS required_level
  UNION ALL SELECT 'IoT Developer' AS career_name, 'Arduino Programming' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'IoT Developer' AS career_name, 'Raspberry Pi' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'IoT Developer' AS career_name, 'MQTT' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'IoT Developer' AS career_name, 'Sensor Integration' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'IoT Developer' AS career_name, 'Python' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'IoT Developer' AS career_name, 'AWS' AS skill_name, 55 AS required_level
  UNION ALL SELECT 'Firmware Engineer' AS career_name, 'Embedded C' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Firmware Engineer' AS career_name, 'C' AS skill_name, 85 AS required_level
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
  UNION ALL SELECT 'Power Systems Engineer' AS career_name, 'Renewable Energy Systems' AS skill_name, 65 AS required_level
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
  UNION ALL SELECT 'Bioinformatics Analyst' AS career_name, 'Statistics' AS skill_name, 62 AS required_level
  UNION ALL SELECT 'Bioinformatics Analyst' AS career_name, 'Probability' AS skill_name, 62 AS required_level
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
  UNION ALL SELECT 'Corporate Lawyer' AS career_name, 'Negotiation' AS skill_name, 65 AS required_level
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
  UNION ALL SELECT 'Motion Graphics Designer' AS career_name, 'Figma' AS skill_name, 55 AS required_level
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
  UNION ALL SELECT 'Public Policy Analyst' AS career_name, 'Statistics' AS skill_name, 57 AS required_level
  UNION ALL SELECT 'Public Policy Analyst' AS career_name, 'Probability' AS skill_name, 57 AS required_level
  UNION ALL SELECT 'Government Administrative Officer' AS career_name, 'Quantitative Aptitude' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Government Administrative Officer' AS career_name, 'Logical Reasoning' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Government Administrative Officer' AS career_name, 'General Awareness' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Government Administrative Officer' AS career_name, 'English Language' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Government Administrative Officer' AS career_name, 'Time Management' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Government Administrative Officer' AS career_name, 'Excel' AS skill_name, 55 AS required_level
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
  UNION ALL SELECT 'Automation Test Engineer' AS career_name, 'Git' AS skill_name, 62 AS required_level
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
  UNION ALL SELECT 'Marketplace Specialist' AS career_name, 'Customer Service' AS skill_name, 60 AS required_level
  UNION ALL SELECT 'Catalog Quality Specialist' AS career_name, 'Digital Cataloging' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Catalog Quality Specialist' AS career_name, 'Product Listing' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Catalog Quality Specialist' AS career_name, 'Content Quality Review' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Catalog Quality Specialist' AS career_name, 'Excel' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Catalog Quality Specialist' AS career_name, 'Problem Solving' AS skill_name, 60 AS required_level
  UNION ALL SELECT 'Catalog Quality Specialist' AS career_name, 'SEO Writing' AS skill_name, 55 AS required_level
  UNION ALL SELECT 'Software Engineer' AS career_name, 'Programming Fundamentals' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Software Engineer' AS career_name, 'Data Structures & Algorithms' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Software Engineer' AS career_name, 'Object-Oriented Programming' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Software Engineer' AS career_name, 'Git' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Software Engineer' AS career_name, 'SQL' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Software Engineer' AS career_name, 'REST API Design' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Software Engineer' AS career_name, 'Testing Fundamentals' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Backend Developer' AS career_name, 'Programming Fundamentals' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Backend Developer' AS career_name, 'Data Structures & Algorithms' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Backend Developer' AS career_name, 'REST API Design' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Backend Developer' AS career_name, 'SQL' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Backend Developer' AS career_name, 'Git' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Backend Developer' AS career_name, 'Authentication & Authorization' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Backend Developer' AS career_name, 'Testing Fundamentals' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Java Developer' AS career_name, 'Java' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Java Developer' AS career_name, 'Object-Oriented Programming' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Java Developer' AS career_name, 'Spring Boot' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Java Developer' AS career_name, 'SQL' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Java Developer' AS career_name, 'REST API Design' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Java Developer' AS career_name, 'Git' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Java Developer' AS career_name, 'Unit Testing' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Python Developer' AS career_name, 'Python' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Python Developer' AS career_name, 'Object-Oriented Programming' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Python Developer' AS career_name, 'REST API Design' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Python Developer' AS career_name, 'SQL' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Python Developer' AS career_name, 'Git' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Python Developer' AS career_name, 'Testing Fundamentals' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Frontend Developer' AS career_name, 'HTML' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Frontend Developer' AS career_name, 'CSS' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Frontend Developer' AS career_name, 'JavaScript' AS skill_name, 95 AS required_level
  UNION ALL SELECT 'Frontend Developer' AS career_name, 'Responsive Web Design' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Frontend Developer' AS career_name, 'React' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Frontend Developer' AS career_name, 'TypeScript' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Frontend Developer' AS career_name, 'REST API Integration' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Frontend Developer' AS career_name, 'Git' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Frontend Developer' AS career_name, 'Web Accessibility' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Full Stack Developer' AS career_name, 'HTML' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Full Stack Developer' AS career_name, 'CSS' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Full Stack Developer' AS career_name, 'JavaScript' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Full Stack Developer' AS career_name, 'React' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Full Stack Developer' AS career_name, 'Node.js' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Full Stack Developer' AS career_name, 'REST API Design' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Full Stack Developer' AS career_name, 'SQL' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Full Stack Developer' AS career_name, 'Git' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Full Stack Developer' AS career_name, 'Authentication & Authorization' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'React Developer' AS career_name, 'JavaScript' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'React Developer' AS career_name, 'React' AS skill_name, 95 AS required_level
  UNION ALL SELECT 'React Developer' AS career_name, 'TypeScript' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'React Developer' AS career_name, 'HTML' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'React Developer' AS career_name, 'CSS' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'React Developer' AS career_name, 'State Management' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'React Developer' AS career_name, 'REST API Integration' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'React Developer' AS career_name, 'Git' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Android Developer' AS career_name, 'Kotlin' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Android Developer' AS career_name, 'Android SDK' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Android Developer' AS career_name, 'Jetpack Compose' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Android Developer' AS career_name, 'REST API Integration' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Android Developer' AS career_name, 'SQL' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Android Developer' AS career_name, 'Git' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Android Developer' AS career_name, 'Mobile UI Design' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Flutter Developer' AS career_name, 'Dart' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Flutter Developer' AS career_name, 'Flutter' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Flutter Developer' AS career_name, 'Mobile UI Design' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Flutter Developer' AS career_name, 'REST API Integration' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Flutter Developer' AS career_name, 'State Management' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Flutter Developer' AS career_name, 'Git' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Data Analyst' AS career_name, 'SQL' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Data Analyst' AS career_name, 'Excel' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Data Analyst' AS career_name, 'Statistics' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Data Analyst' AS career_name, 'Data Cleaning' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Data Analyst' AS career_name, 'Pandas' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Data Analyst' AS career_name, 'Data Visualization' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Data Analyst' AS career_name, 'Power BI' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Data Analyst' AS career_name, 'Exploratory Data Analysis' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Data Scientist' AS career_name, 'Python' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Data Scientist' AS career_name, 'Statistics' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Data Scientist' AS career_name, 'SQL' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Data Scientist' AS career_name, 'Data Cleaning' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Data Scientist' AS career_name, 'Exploratory Data Analysis' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Data Scientist' AS career_name, 'Machine Learning' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Data Scientist' AS career_name, 'Feature Engineering' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Data Scientist' AS career_name, 'Scikit-learn' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Data Scientist' AS career_name, 'Model Evaluation' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Data Scientist' AS career_name, 'Data Visualization' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Business Intelligence Analyst' AS career_name, 'SQL' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Business Intelligence Analyst' AS career_name, 'Excel' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Business Intelligence Analyst' AS career_name, 'Power BI' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Business Intelligence Analyst' AS career_name, 'DAX' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Business Intelligence Analyst' AS career_name, 'Data Modeling' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Business Intelligence Analyst' AS career_name, 'Data Visualization' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Business Intelligence Analyst' AS career_name, 'Business Analysis' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'AI Engineer' AS career_name, 'Python' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'AI Engineer' AS career_name, 'Machine Learning' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'AI Engineer' AS career_name, 'Deep Learning' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'AI Engineer' AS career_name, 'LLM Fundamentals' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'AI Engineer' AS career_name, 'Prompt Engineering' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'AI Engineer' AS career_name, 'Model Evaluation' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'AI Engineer' AS career_name, 'REST API Design' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'AI Engineer' AS career_name, 'Git' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Generative AI Engineer' AS career_name, 'Python' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Generative AI Engineer' AS career_name, 'LLM Fundamentals' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Generative AI Engineer' AS career_name, 'Prompt Engineering' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Generative AI Engineer' AS career_name, 'RAG' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Generative AI Engineer' AS career_name, 'Vector Databases' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Generative AI Engineer' AS career_name, 'Embeddings' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Generative AI Engineer' AS career_name, 'Model Evaluation' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Generative AI Engineer' AS career_name, 'REST API Design' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Machine Learning Engineer' AS career_name, 'Python' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Machine Learning Engineer' AS career_name, 'Machine Learning' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Machine Learning Engineer' AS career_name, 'Statistics' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Machine Learning Engineer' AS career_name, 'Feature Engineering' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Machine Learning Engineer' AS career_name, 'Scikit-learn' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Machine Learning Engineer' AS career_name, 'Model Evaluation' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Machine Learning Engineer' AS career_name, 'MLOps' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Machine Learning Engineer' AS career_name, 'Docker' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Machine Learning Engineer' AS career_name, 'SQL' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Computer Vision Engineer' AS career_name, 'Python' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Computer Vision Engineer' AS career_name, 'Deep Learning' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Computer Vision Engineer' AS career_name, 'Computer Vision' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Computer Vision Engineer' AS career_name, 'PyTorch' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Computer Vision Engineer' AS career_name, 'OpenCV' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Computer Vision Engineer' AS career_name, 'Model Evaluation' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Computer Vision Engineer' AS career_name, 'Git' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Cloud Engineer' AS career_name, 'AWS' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Cloud Engineer' AS career_name, 'Linux Administration' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Cloud Engineer' AS career_name, 'Networking Fundamentals' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Cloud Engineer' AS career_name, 'Docker' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Cloud Engineer' AS career_name, 'Kubernetes' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Cloud Engineer' AS career_name, 'Infrastructure as Code' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Cloud Engineer' AS career_name, 'IAM' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Cloud Engineer' AS career_name, 'Git' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'DevOps Engineer' AS career_name, 'Linux Administration' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'DevOps Engineer' AS career_name, 'Git' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'DevOps Engineer' AS career_name, 'CI/CD Pipelines' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'DevOps Engineer' AS career_name, 'Docker' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'DevOps Engineer' AS career_name, 'Kubernetes' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'DevOps Engineer' AS career_name, 'Infrastructure as Code' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'DevOps Engineer' AS career_name, 'Monitoring & Observability' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'DevOps Engineer' AS career_name, 'Cloud Computing' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Cybersecurity Analyst' AS career_name, 'Networking Fundamentals' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Cybersecurity Analyst' AS career_name, 'Linux Administration' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Cybersecurity Analyst' AS career_name, 'Security Fundamentals' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Cybersecurity Analyst' AS career_name, 'SIEM' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Cybersecurity Analyst' AS career_name, 'Incident Response' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Cybersecurity Analyst' AS career_name, 'Threat Analysis' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Cybersecurity Analyst' AS career_name, 'OWASP Top 10' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Penetration Tester' AS career_name, 'Networking Fundamentals' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Penetration Tester' AS career_name, 'Linux Administration' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Penetration Tester' AS career_name, 'Penetration Testing' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Penetration Tester' AS career_name, 'OWASP Top 10' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Penetration Tester' AS career_name, 'Web Security' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Penetration Tester' AS career_name, 'Burp Suite' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Penetration Tester' AS career_name, 'Python' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Database Administrator' AS career_name, 'SQL' AS skill_name, 95 AS required_level
  UNION ALL SELECT 'Database Administrator' AS career_name, 'Database Administration' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Database Administrator' AS career_name, 'Database Security' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Database Administrator' AS career_name, 'Backup & Recovery' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Database Administrator' AS career_name, 'Performance Tuning' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Database Administrator' AS career_name, 'Linux Administration' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Product Manager' AS career_name, 'Product Strategy' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Product Manager' AS career_name, 'Product Roadmapping' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Product Manager' AS career_name, 'User Research' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Product Manager' AS career_name, 'Product Analytics' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Product Manager' AS career_name, 'Stakeholder Management' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Product Manager' AS career_name, 'Communication' AS skill_name, 80 AS required_level
  UNION ALL SELECT 'Product Manager' AS career_name, 'Agile & Scrum' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Business Analyst' AS career_name, 'Requirements Analysis' AS skill_name, 90 AS required_level
  UNION ALL SELECT 'Business Analyst' AS career_name, 'Business Process Modeling' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Business Analyst' AS career_name, 'Stakeholder Management' AS skill_name, 85 AS required_level
  UNION ALL SELECT 'Business Analyst' AS career_name, 'SQL' AS skill_name, 65 AS required_level
  UNION ALL SELECT 'Business Analyst' AS career_name, 'Excel' AS skill_name, 75 AS required_level
  UNION ALL SELECT 'Business Analyst' AS career_name, 'Data Analysis' AS skill_name, 70 AS required_level
  UNION ALL SELECT 'Business Analyst' AS career_name, 'Communication' AS skill_name, 80 AS required_level
) r JOIN `careers_v2` c ON c.name=r.career_name JOIN `skills_v2` s ON s.name=r.skill_name;

-- =====================================================
-- VERIFICATION
-- =====================================================
-- The checks below make a fresh rebuild easy to audit.
SELECT 'education_categories' AS table_name, COUNT(*) AS row_count FROM education_categories
UNION ALL SELECT 'education_programs', COUNT(*) FROM education_programs
UNION ALL SELECT 'domains', COUNT(*) FROM domains
UNION ALL SELECT 'careers_v2', COUNT(*) FROM careers_v2
UNION ALL SELECT 'skills_v2', COUNT(*) FROM skills_v2
UNION ALL SELECT 'career_skill_requirements', COUNT(*) FROM career_skill_requirements
UNION ALL SELECT 'resume_analyses', COUNT(*) FROM resume_analyses;

-- Duplicate/invalid mapping checks: all should return 0 rows.
SELECT career_id, skill_id, COUNT(*) AS duplicate_count
FROM career_skill_requirements
GROUP BY career_id, skill_id
HAVING COUNT(*) > 1;

SELECT csr.id
FROM career_skill_requirements csr
LEFT JOIN careers_v2 c ON c.id = csr.career_id
LEFT JOIN skills_v2 s ON s.id = csr.skill_id
WHERE c.id IS NULL OR s.id IS NULL;

-- Skill coverage per career. Target: 6-10 core skills for most careers.
SELECT c.name AS career, d.name AS domain, COUNT(csr.id) AS skill_count
FROM careers_v2 c
LEFT JOIN domains d ON d.id=c.domain_id
LEFT JOIN career_skill_requirements csr ON csr.career_id=c.id
GROUP BY c.id,c.name,d.name
ORDER BY d.name,c.name;
