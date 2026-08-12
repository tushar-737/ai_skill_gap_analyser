#!/usr/bin/env python3
"""
Mega-seed generator for the AI Skill Gap Analyzer.

Reads backend/workbench/init.sql, keeps everything that is already there,
and (re)generates the EXPANDED SEED section between the markers:

    -- >>> MEGA SEED BEGIN >>>
    ...
    -- <<< MEGA SEED END <<<

Design rules (do not break these):
  - ADDITIVE ONLY. Existing rows/tables are never modified or deleted.
  - Idempotent: INSERT IGNORE for name-UNIQUE tables; name-guarded
    inserts for tables without a UNIQUE name (programs, careers).
  - No hard-coded IDs anywhere - everything joins by name.
  - EVERY career gets skills mapped, so users always see results.

Regenerate after editing the data below:
    python3 backend/workbench/generate_seed.py
"""

import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
INIT_SQL = HERE / "init.sql"

BEGIN = "-- >>> MEGA SEED BEGIN >>>"
END = "-- <<< MEGA SEED END <<<"

def esc(text: str) -> str:
    return text.replace("'", "''")

# =====================================================================
# 1) NEW EDUCATION CATEGORIES
# =====================================================================

CATEGORIES = [
    ("Law", "Legal studies and bar-track programs"),
    ("Vocational & Diploma", "Polytechnic, ITI and certificate programs"),
    ("Education & Teaching", "Teacher training and education degrees"),
]

# =====================================================================
# 2) NEW EDUCATION PROGRAMS  (category, name, level, description)
# =====================================================================

PROGRAMS = [
    # Computer Science & IT
    ("Computer Science & IT", "B.Sc Computer Science", "Undergraduate", "Foundations of computing and programming"),
    ("Computer Science & IT", "B.Tech Artificial Intelligence & Data Science", "Undergraduate", "Engineering degree focused on AI and data"),
    ("Computer Science & IT", "M.Sc Information Technology", "Postgraduate", "Advanced IT systems and software"),
    ("Computer Science & IT", "PG Diploma in Data Science", "Postgraduate", "One year applied data science diploma"),
    # Engineering (Core)
    ("Engineering (Core)", "B.Tech Automobile Engineering", "Undergraduate", "Vehicle design, engines and manufacturing"),
    ("Engineering (Core)", "B.Tech Chemical Engineering", "Undergraduate", "Process design and chemical technology"),
    ("Engineering (Core)", "M.Tech Structural Engineering", "Postgraduate", "Advanced structural analysis and design"),
    ("Engineering (Core)", "M.Tech VLSI Design", "Postgraduate", "Chip design and semiconductor systems"),
    # Business & Management
    ("Business & Management", "MBA Marketing", "Postgraduate", "Marketing strategy and brand management"),
    ("Business & Management", "MBA Finance", "Postgraduate", "Corporate finance and investment management"),
    ("Business & Management", "MBA Human Resources", "Postgraduate", "People management and organizational behaviour"),
    ("Business & Management", "MBA Operations", "Postgraduate", "Supply chain and operations management"),
    ("Business & Management", "BMS", "Undergraduate", "Bachelor of Management Studies"),
    ("Business & Management", "Executive MBA", "Postgraduate", "MBA for working professionals"),
    # Commerce & Finance
    ("Commerce & Finance", "CA (Chartered Accountancy)", "Professional", "Accounting, audit and taxation qualification"),
    ("Commerce & Finance", "CS (Company Secretary)", "Professional", "Corporate law and governance qualification"),
    ("Commerce & Finance", "CMA (Cost & Management Accountancy)", "Professional", "Cost accounting and management"),
    ("Commerce & Finance", "B.Com Accounting & Finance", "Undergraduate", "Specialized accounting and finance degree"),
    ("Commerce & Finance", "B.Com Banking & Insurance", "Undergraduate", "Banking and insurance focused commerce degree"),
    # Science
    ("Science", "M.Sc Physics", "Postgraduate", "Advanced physics and research methods"),
    ("Science", "M.Sc Mathematics", "Postgraduate", "Advanced pure and applied mathematics"),
    ("Science", "M.Sc Chemistry", "Postgraduate", "Advanced chemistry and lab research"),
    ("Science", "M.Sc Biotechnology", "Postgraduate", "Advanced biotech research and industry skills"),
    ("Science", "B.Sc Microbiology", "Undergraduate", "Microbes, immunology and lab techniques"),
    ("Science", "B.Sc Psychology", "Undergraduate", "Human behaviour and mental processes"),
    ("Science", "M.Sc Psychology", "Postgraduate", "Advanced psychology and counselling basics"),
    ("Science", "B.Sc Agriculture", "Undergraduate", "Crop science, soil and agri technology"),
    # Arts, Design & Media
    ("Arts, Design & Media", "MA English", "Postgraduate", "Literature, language and academic writing"),
    ("Arts, Design & Media", "B.Des Interior Design", "Undergraduate", "Space, materials and interior styling"),
    ("Arts, Design & Media", "B.Des Fashion Design", "Undergraduate", "Apparel and textile design"),
    ("Arts, Design & Media", "B.Sc Animation & VFX", "Undergraduate", "2D/3D animation and visual effects"),
    ("Arts, Design & Media", "MA Journalism", "Postgraduate", "Advanced reporting and media studies"),
    ("Arts, Design & Media", "BMM", "Undergraduate", "Bachelor of Mass Media"),
    # Health & Life Sciences
    ("Health & Life Sciences", "BDS", "Professional", "Bachelor of Dental Surgery"),
    ("Health & Life Sciences", "BAMS", "Professional", "Ayurvedic medicine and surgery"),
    ("Health & Life Sciences", "BHMS", "Professional", "Homeopathic medicine and surgery"),
    ("Health & Life Sciences", "BPT (Physiotherapy)", "Professional", "Physical therapy and rehabilitation"),
    ("Health & Life Sciences", "M.Pharm", "Postgraduate", "Advanced pharmacy and research"),
    ("Health & Life Sciences", "GNM Nursing", "Diploma", "General Nursing and Midwifery diploma"),
    # Law
    ("Law", "LLB", "Professional", "Three year law degree for graduates"),
    ("Law", "BA LLB", "Professional", "Five year integrated law degree"),
    ("Law", "LLM", "Postgraduate", "Masters in a legal specialization"),
    # Vocational & Diploma
    ("Vocational & Diploma", "Polytechnic Diploma (Engineering)", "Diploma", "Three year technical diploma after 10th"),
    ("Vocational & Diploma", "ITI Electrician", "Certificate", "Trade certificate in electrical work"),
    ("Vocational & Diploma", "ITI Fitter", "Certificate", "Trade certificate in fitting and assembly"),
    ("Vocational & Diploma", "Diploma in Hotel Management", "Diploma", "Hospitality operations and service"),
    ("Vocational & Diploma", "Certificate in Digital Marketing", "Certificate", "Short course on online marketing"),
    ("Vocational & Diploma", "Diploma in Graphic Design", "Diploma", "Visual design and print media"),
    ("Vocational & Diploma", "Diploma in Medical Lab Technology", "Diploma", "Clinical lab testing and diagnostics"),
    # Education & Teaching
    ("Education & Teaching", "B.Ed", "Professional", "Bachelor of Education - required for school teaching"),
    ("Education & Teaching", "M.Ed", "Postgraduate", "Master of Education"),
    # Agriculture-adjacent (category Science exists already)
    ("Science", "B.Tech Agricultural Engineering", "Undergraduate", "Farm machinery, irrigation and agri tech"),
]

# =====================================================================
# 3) NEW DOMAINS  (name, description)
# =====================================================================

DOMAINS = [
    ("Data Engineering", "Build the pipelines and platforms behind data products"),
    ("Game Development", "Design and build games for PC, console and mobile"),
    ("Blockchain & Web3", "Decentralized apps, smart contracts and crypto systems"),
    ("IoT & Embedded Systems", "Software and hardware for connected devices"),
    ("Robotics & Automation", "Robots, control systems and industrial automation"),
    ("Civil & Construction", "Designing and building infrastructure"),
    ("Electrical & Power", "Power systems, panels and industrial electricity"),
    ("Manufacturing & Industrial", "Production planning, CNC and process optimization"),
    ("Automobile Engineering", "Vehicle design, EVs and automotive testing"),
    ("Chemical & Process", "Process plants, simulation and chemical operations"),
    ("Biotechnology & Pharma Research", "Lab research, clinical trials and bioinformatics"),
    ("Nursing & Patient Care", "Frontline clinical care and community health"),
    ("Teaching & Education", "Teaching, academic research and course design"),
    ("Law & Legal Services", "Corporate law, litigation and legal analysis"),
    ("Human Resources", "Hiring, people operations and workplace culture"),
    ("Sales & Business Development", "Revenue growth, clients and partnerships"),
    ("Banking & Insurance", "Banking operations, credit and risk products"),
    ("Supply Chain & Logistics", "Moving goods efficiently from source to customer"),
    ("Hospitality & Tourism", "Hotels, food service and travel experiences"),
    ("Animation & VFX", "Visual effects, 3D animation and motion design"),
    ("Graphic Design & Branding", "Visual identities, print and brand systems"),
    ("Architecture & Interior Design", "Buildings, spaces and urban environments"),
    ("Agriculture & AgriTech", "Farming science and agri business"),
    ("Psychology & Counselling", "Mental health, assessment and human behaviour"),
    ("Government & Public Administration", "Civil services, policy and public sector careers"),
    ("QA & Software Testing", "Manual, automation and performance testing"),
    ("E-commerce Operations", "Online marketplaces, catalogs and D2C operations"),
]

# Category assigned to skills that are auto-registered per domain
DOMAIN_SKILL_CATEGORY = {
    "Data Engineering": "Data Engineering",
    "Game Development": "Game Development",
    "Blockchain & Web3": "Blockchain",
    "IoT & Embedded Systems": "Embedded Systems",
    "Robotics & Automation": "Robotics",
    "Civil & Construction": "Civil Engineering",
    "Electrical & Power": "Electrical Engineering",
    "Manufacturing & Industrial": "Manufacturing",
    "Automobile Engineering": "Automobile",
    "Chemical & Process": "Chemical Engineering",
    "Biotechnology & Pharma Research": "Biotechnology",
    "Nursing & Patient Care": "Nursing",
    "Teaching & Education": "Education",
    "Law & Legal Services": "Law",
    "Human Resources": "Human Resources",
    "Sales & Business Development": "Sales",
    "Banking & Insurance": "Banking & Insurance",
    "Supply Chain & Logistics": "Supply Chain",
    "Hospitality & Tourism": "Hospitality",
    "Animation & VFX": "Animation & VFX",
    "Graphic Design & Branding": "Design",
    "Architecture & Interior Design": "Architecture",
    "Agriculture & AgriTech": "Agriculture",
    "Psychology & Counselling": "Psychology",
    "Government & Public Administration": "Public Administration",
    "QA & Software Testing": "Quality Assurance",
    "E-commerce Operations": "E-commerce",
}

# Explicit metadata for cross-cutting skills (category, description)
SKILL_INFO = {
    "Communication": ("Soft Skills", "Clear written and verbal communication"),
    "Problem Solving": ("Soft Skills", "Structured thinking and troubleshooting"),
    "Time Management": ("Soft Skills", "Prioritizing work and meeting deadlines"),
    "Leadership": ("Soft Skills", "Leading people and initiatives"),
    "Teamwork & Collaboration": ("Soft Skills", "Working effectively in teams"),
    "Report Writing": ("Soft Skills", "Structured professional documentation"),
    "Sales Techniques": ("Sales", "Prospecting, pitching and closing"),
}

# =====================================================================
# 4) NEW CAREERS with their skill requirements
#    (domain, career, description, avg_level, [(skill, required_level), ...])
# =====================================================================

CAREERS = [
    # ---- Data Engineering ----
    ("Data Engineering", "Data Engineer", "Build reliable data pipelines and platforms", "Advanced",
     [("SQL", 90), ("Python", 80), ("Apache Spark", 85), ("ETL Design", 85),
      ("Data Warehousing", 80), ("Apache Airflow", 75), ("Docker", 55)]),
    ("Data Engineering", "Analytics Engineer", "Model clean data marts for analytics teams", "Intermediate",
     [("SQL", 90), ("dbt", 80), ("Data Warehousing", 80), ("Power BI", 75),
      ("Data Modeling", 75), ("Git & GitHub", 65)]),
    ("Data Engineering", "Big Data Engineer", "Process massive datasets on distributed systems", "Advanced",
     [("Apache Spark", 90), ("Apache Kafka", 80), ("Hadoop", 75), ("Python", 80),
      ("Scala", 70), ("Data Warehousing", 70)]),

    # ---- Game Development ----
    ("Game Development", "Game Developer", "Build gameplay systems and ship games", "Intermediate",
     [("Unity", 80), ("C#", 80), ("Game Design Fundamentals", 70), ("Game Physics", 65),
      ("Blender", 55), ("Git & GitHub", 60)]),
    ("Game Development", "Unity Developer", "Create 3D/2D games in the Unity engine", "Intermediate",
     [("Unity", 90), ("C#", 85), ("3D Mathematics", 70), ("Shader Programming", 65),
      ("Git & GitHub", 65), ("Performance Optimization", 60)]),
    ("Game Development", "Level Designer", "Design engaging levels and player flows", "Beginner",
     [("Level Design", 80), ("Game Design Fundamentals", 75), ("Unreal Engine", 65),
      ("Blender", 60), ("Prototyping", 60), ("Scriptwriting", 55)]),

    # ---- Blockchain & Web3 ----
    ("Blockchain & Web3", "Blockchain Developer", "Build decentralized applications", "Advanced",
     [("Solidity", 85), ("Smart Contracts", 85), ("Ethereum", 75), ("Cryptography", 70),
      ("Web3.js", 70), ("JavaScript", 65)]),
    ("Blockchain & Web3", "Smart Contract Auditor", "Find vulnerabilities in smart contracts", "Advanced",
     [("Smart Contracts", 85), ("Web3 Security", 85), ("Solidity", 80), ("Cryptography", 70),
      ("Ethereum", 65), ("Python", 55)]),
    ("Blockchain & Web3", "Web3 Frontend Developer", "Build dApp interfaces connected to wallets", "Intermediate",
     [("JavaScript", 85), ("Web3.js", 80), ("React", 80), ("HTML & CSS", 75),
      ("TypeScript", 70), ("Ethereum", 60)]),

    # ---- IoT & Embedded Systems ----
    ("IoT & Embedded Systems", "Embedded Systems Engineer", "Program microcontrollers at the hardware level", "Advanced",
     [("Embedded C", 85), ("Microcontrollers", 85), ("C Programming", 80), ("RTOS", 70),
      ("Circuit Debugging", 65), ("Git & GitHub", 55)]),
    ("IoT & Embedded Systems", "IoT Developer", "Connect devices to cloud platforms", "Intermediate",
     [("Arduino Programming", 80), ("Raspberry Pi", 75), ("MQTT", 75), ("Sensor Integration", 70),
      ("Python", 70), ("AWS", 55)]),
    ("IoT & Embedded Systems", "Firmware Engineer", "Write low-level firmware for devices", "Advanced",
     [("Embedded C", 85), ("C Programming", 85), ("Microcontrollers", 80), ("RTOS", 75),
      ("Device Drivers", 70), ("Linux Administration", 60)]),

    # ---- Robotics & Automation ----
    ("Robotics & Automation", "Robotics Engineer", "Design and program robotic systems", "Advanced",
     [("Control Systems", 80), ("ROS", 80), ("Kinematics", 75), ("Python", 70),
      ("MATLAB", 70), ("Sensor Fusion", 70)]),
    ("Robotics & Automation", "Automation Engineer", "Automate industrial processes", "Intermediate",
     [("PLC Programming", 85), ("Control Systems", 75), ("SCADA", 70), ("HMI Development", 65),
      ("Industrial Wiring", 65), ("Manufacturing Processes", 60)]),
    ("Robotics & Automation", "Mechatronics Engineer", "Blend mechanics, electronics and software", "Advanced",
     [("Control Systems", 80), ("Embedded C", 75), ("SolidWorks", 70), ("Sensor Fusion", 70),
      ("MATLAB", 70), ("Microcontrollers", 65)]),

    # ---- Civil & Construction ----
    ("Civil & Construction", "Civil Engineer", "Plan and supervise construction projects", "Intermediate",
     [("AutoCAD", 80), ("Structural Analysis", 75), ("Estimation & Costing", 70),
      ("Construction Management", 70), ("Surveying", 65), ("Concrete Technology", 65)]),
    ("Civil & Construction", "Structural Engineer", "Design safe structural systems", "Advanced",
     [("STAAD Pro", 85), ("Structural Analysis", 85), ("ETABS", 80), ("RCC Design", 75),
      ("AutoCAD", 70), ("Foundation Design", 70)]),
    ("Civil & Construction", "Quantity Surveyor", "Estimate and control construction costs", "Beginner",
     [("Estimation & Costing", 85), ("Excel", 80), ("Billing Engineering", 75),
      ("Rate Analysis", 70), ("AutoCAD", 65), ("Contract Management", 60)]),

    # ---- Electrical & Power ----
    ("Electrical & Power", "Electrical Design Engineer", "Design electrical systems and panels", "Intermediate",
     [("AutoCAD Electrical", 85), ("Electrical Design", 80), ("Panel Design", 70), ("ETAP", 70),
      ("Cable Sizing", 70), ("Indian Electricity Rules", 60)]),
    ("Electrical & Power", "Power Systems Engineer", "Analyze and maintain power networks", "Advanced",
     [("Power System Analysis", 85), ("ETAP", 85), ("Protection Systems", 75), ("MATLAB", 70),
      ("SCADA", 70), ("Renewable Energy Systems", 65)]),
    ("Electrical & Power", "PLC Automation Engineer", "Program industrial control systems", "Intermediate",
     [("PLC Programming", 85), ("Ladder Logic", 80), ("SCADA", 75), ("HMI Development", 70),
      ("Instrumentation", 70), ("Industrial Wiring", 65)]),

    # ---- Manufacturing & Industrial ----
    ("Manufacturing & Industrial", "Production Engineer", "Run efficient production lines", "Intermediate",
     [("Manufacturing Processes", 85), ("Lean Manufacturing", 75), ("Production Planning", 75),
      ("Six Sigma", 70), ("Kaizen", 65), ("AutoCAD", 65)]),
    ("Manufacturing & Industrial", "CNC Programmer", "Program CNC machines for precision parts", "Intermediate",
     [("CNC Programming", 85), ("Mastercam", 75), ("GD&T", 75), ("Machine Tools", 70),
      ("Manufacturing Processes", 70), ("AutoCAD", 65)]),
    ("Manufacturing & Industrial", "Industrial Engineer", "Optimize systems, time and resources", "Intermediate",
     [("Lean Manufacturing", 80), ("Time Study", 75), ("Excel", 75), ("Production Planning", 70),
      ("Six Sigma", 70), ("Operations Research", 65)]),

    # ---- Automobile Engineering ----
    ("Automobile Engineering", "Automotive Design Engineer", "Design vehicle systems and components", "Intermediate",
     [("CATIA", 85), ("SolidWorks", 80), ("GD&T", 75), ("Vehicle Dynamics", 70),
      ("Powertrain Systems", 70), ("ANSYS", 65)]),
    ("Automobile Engineering", "EV Design Engineer", "Design electric vehicle systems", "Advanced",
     [("Battery Management Systems", 80), ("Electric Vehicle Architecture", 80), ("MATLAB", 75),
      ("Simulink", 70), ("Powertrain Systems", 70), ("Thermal Management", 65)]),
    ("Automobile Engineering", "Vehicle Testing Engineer", "Validate vehicles against standards", "Intermediate",
     [("Vehicle Dynamics", 75), ("CAN Bus", 70), ("Data Acquisition", 70), ("Problem Solving", 70),
      ("Homologation", 65), ("MATLAB", 60)]),

    # ---- Chemical & Process ----
    ("Chemical & Process", "Process Engineer", "Design and optimize chemical processes", "Intermediate",
     [("Aspen HYSYS", 80), ("Process Simulation", 80), ("Heat & Mass Transfer", 75),
      ("Chemical Reaction Engineering", 70), ("P&ID Reading", 70), ("Excel", 65)]),
    ("Chemical & Process", "Plant Operations Engineer", "Run safe and efficient plant operations", "Beginner",
     [("Plant Operations", 80), ("Safety Procedures", 75), ("P&ID Reading", 70), ("Process Control", 65),
      ("Instrumentation", 60), ("Regulatory Compliance", 55)]),
    ("Chemical & Process", "R&D Chemist", "Research and develop chemical products", "Intermediate",
     [("Analytical Chemistry", 80), ("Lab Techniques", 75), ("Spectroscopy", 70),
      ("Chemical Reaction Engineering", 65), ("Report Writing", 60), ("HAZOP Basics", 55)]),

    # ---- Biotechnology & Pharma Research ----
    ("Biotechnology & Pharma Research", "Biotech Research Associate", "Run wet-lab experiments and studies", "Intermediate",
     [("Molecular Biology", 80), ("PCR Techniques", 75), ("Lab Techniques", 75), ("Cell Culture", 70),
      ("Genomics", 65), ("Report Writing", 60)]),
    ("Biotechnology & Pharma Research", "Clinical Research Associate", "Monitor clinical trials end to end", "Intermediate",
     [("Clinical Trials", 85), ("GCP Guidelines", 80), ("Clinical Data Management", 70),
      ("Regulatory Compliance", 70), ("Medical Terminology", 65), ("Communication", 65)]),
    ("Biotechnology & Pharma Research", "Bioinformatics Analyst", "Analyze genomic data computationally", "Intermediate",
     [("Bioinformatics Tools", 80), ("Genomics", 75), ("Python", 75), ("Statistics & Probability", 65),
      ("Molecular Biology", 60), ("R", 60)]),

    # ---- Nursing & Patient Care ----
    ("Nursing & Patient Care", "Staff Nurse", "Provide frontline patient care", "Beginner",
     [("Patient Care", 85), ("First Aid & BLS", 80), ("Infection Control", 75),
      ("Medication Administration", 75), ("Medical Documentation", 70), ("Communication", 65)]),
    ("Nursing & Patient Care", "ICU Nurse", "Care for critical patients in ICUs", "Intermediate",
     [("Critical Care Nursing", 85), ("Patient Care", 80), ("Ventilator Management", 75),
      ("First Aid & BLS", 75), ("Infection Control", 70), ("Triage", 70)]),
    ("Nursing & Patient Care", "Community Health Officer", "Deliver preventive community healthcare", "Beginner",
     [("Community Health", 80), ("Health Education", 75), ("Patient Care", 70),
      ("First Aid & BLS", 70), ("Medical Documentation", 60), ("Communication", 65)]),

    # ---- Teaching & Education ----
    ("Teaching & Education", "School Teacher", "Teach and mentor school students", "Beginner",
     [("Lesson Planning", 85), ("Classroom Management", 80), ("Subject Expertise", 75),
      ("Communication", 75), ("Assessment Design", 70), ("Educational Technology", 60)]),
    ("Teaching & Education", "Assistant Professor", "Teach and research at university level", "Advanced",
     [("Subject Expertise", 85), ("Curriculum Design", 80), ("Assessment Design", 75),
      ("Research Methods", 75), ("Academic Writing", 70), ("Educational Technology", 65)]),
    ("Teaching & Education", "Instructional Designer", "Design effective learning experiences", "Intermediate",
     [("Curriculum Design", 80), ("E-learning Tools", 80), ("Learning Management Systems", 75),
      ("Storyboarding", 70), ("Assessment Design", 65), ("Storytelling", 65)]),

    # ---- Law & Legal Services ----
    ("Law & Legal Services", "Corporate Lawyer", "Advise companies on deals and compliance", "Advanced",
     [("Corporate Law", 85), ("Contract Drafting", 85), ("Legal Research", 75), ("M&A Basics", 70),
      ("Compliance", 70), ("Negotiation", 65)]),
    ("Law & Legal Services", "Litigation Advocate", "Represent clients in court", "Intermediate",
     [("Litigation", 85), ("Court Procedures", 80), ("Legal Research", 80), ("Case Management", 75),
      ("Drafting & Pleadings", 75), ("Communication", 70)]),
    ("Law & Legal Services", "Legal Analyst", "Research and analyze legal matters", "Beginner",
     [("Legal Research", 80), ("Contract Drafting", 70), ("Case Management", 65),
      ("Intellectual Property", 60), ("Communication", 65), ("Excel", 60)]),

    # ---- Human Resources ----
    ("Human Resources", "HR Executive", "Handle day-to-day HR operations", "Beginner",
     [("Recruitment", 80), ("Onboarding", 75), ("Communication", 75), ("HRMS Tools", 70),
      ("Employee Engagement", 65), ("Excel", 65)]),
    ("Human Resources", "Talent Acquisition Specialist", "Find and hire great candidates", "Intermediate",
     [("Recruitment", 85), ("Interviewing", 80), ("Sourcing Strategies", 75), ("HRMS Tools", 70),
      ("Negotiation", 65), ("Social Media Strategy", 55)]),
    ("Human Resources", "HR Business Partner", "Align people strategy with business goals", "Advanced",
     [("Performance Management", 80), ("Labour Laws", 75), ("Employee Engagement", 75),
      ("Payroll Processing", 70), ("HR Analytics", 65), ("Leadership", 60)]),

    # ---- Sales & Business Development ----
    ("Sales & Business Development", "Sales Executive", "Sell products and hit revenue targets", "Beginner",
     [("Lead Generation", 80), ("Communication", 75), ("Cold Calling", 75), ("CRM Tools", 70),
      ("Negotiation", 70), ("Product Knowledge", 65)]),
    ("Sales & Business Development", "Business Development Manager", "Grow revenue through new business", "Advanced",
     [("B2B Sales", 85), ("Negotiation", 80), ("Pipeline Management", 80), ("CRM Tools", 75),
      ("Market Research", 70), ("Leadership", 65)]),
    ("Sales & Business Development", "Account Manager", "Retain and grow key client accounts", "Intermediate",
     [("Client Relationship Management", 85), ("Communication", 80), ("CRM Tools", 75),
      ("Negotiation", 70), ("Upselling & Cross-selling", 70), ("Excel", 60)]),

    # ---- Banking & Insurance ----
    ("Banking & Insurance", "Bank Probationary Officer", "Manage branch banking operations", "Beginner",
     [("Banking Operations", 85), ("Financial Products", 75), ("Customer Service", 75),
      ("Quantitative Aptitude", 70), ("KYC & AML", 70), ("Excel", 65)]),
    ("Banking & Insurance", "Credit Analyst", "Assess creditworthiness of borrowers", "Intermediate",
     [("Credit Analysis", 85), ("Financial Statement Analysis", 80), ("Excel", 75),
      ("Risk Assessment", 75), ("Banking Operations", 65), ("Financial Modeling", 60)]),
    ("Banking & Insurance", "Insurance Underwriter", "Price and accept insurance risks", "Intermediate",
     [("Risk Assessment", 85), ("Insurance Products", 80), ("Underwriting Guidelines", 75),
      ("Regulatory Compliance", 70), ("Financial Statement Analysis", 65), ("Problem Solving", 65)]),

    # ---- Supply Chain & Logistics ----
    ("Supply Chain & Logistics", "Supply Chain Analyst", "Optimize inventory and supply flows", "Intermediate",
     [("Inventory Management", 80), ("Demand Forecasting", 80), ("Excel", 80), ("SAP MM", 70),
      ("SQL", 60), ("Data Visualization", 60)]),
    ("Supply Chain & Logistics", "Logistics Coordinator", "Coordinate shipments and deliveries", "Beginner",
     [("Logistics Planning", 80), ("Inventory Management", 75), ("Route Optimization", 70),
      ("Communication", 70), ("Excel", 70), ("Vendor Management", 65)]),
    ("Supply Chain & Logistics", "Procurement Specialist", "Buy goods and services smartly", "Intermediate",
     [("Procurement", 85), ("Vendor Management", 80), ("Negotiation", 75), ("SAP MM", 70),
      ("Cost Analysis", 70), ("Contract Management", 65)]),

    # ---- Hospitality & Tourism ----
    ("Hospitality & Tourism", "Front Office Executive", "Run hotel reception and guest services", "Beginner",
     [("Front Office Operations", 85), ("Guest Relations", 80), ("Communication", 75),
      ("Reservation Systems", 70), ("Problem Solving", 60), ("Excel", 55)]),
    ("Hospitality & Tourism", "Chef", "Create menus and lead kitchen production", "Intermediate",
     [("Culinary Arts", 90), ("Food Safety & Hygiene", 85), ("Menu Planning", 75),
      ("Kitchen Management", 70), ("Time Management", 65), ("Inventory Management", 55)]),
    ("Hospitality & Tourism", "Travel Consultant", "Plan and book travel experiences", "Beginner",
     [("Travel Planning", 85), ("Destination Knowledge", 75), ("Customer Service", 75),
      ("GDS Systems", 70), ("Communication", 70), ("Sales Techniques", 60)]),

    # ---- Animation & VFX ----
    ("Animation & VFX", "VFX Artist", "Create cinematic visual effects", "Intermediate",
     [("Nuke", 80), ("After Effects", 80), ("Compositing", 75), ("Color Grading", 65),
      ("3D Modeling", 60), ("Storyboarding", 55)]),
    ("Animation & VFX", "3D Animator", "Bring characters and worlds to life", "Intermediate",
     [("Maya", 85), ("3D Modeling", 80), ("Character Animation", 80), ("Texturing & Lighting", 70),
      ("Blender", 60), ("Storyboarding", 60)]),
    ("Animation & VFX", "Motion Graphics Designer", "Animate graphics for video and web", "Beginner",
     [("After Effects", 85), ("Motion Graphics", 80), ("Adobe Premiere Pro", 70), ("Typography", 65),
      ("Storytelling", 60), ("Figma", 55)]),

    # ---- Graphic Design & Branding ----
    ("Graphic Design & Branding", "Graphic Designer", "Design visuals for print and digital", "Beginner",
     [("Adobe Photoshop", 85), ("Adobe Illustrator", 80), ("Typography", 75), ("Layout Design", 75),
      ("Branding", 65), ("Figma", 60)]),
    ("Graphic Design & Branding", "Brand Designer", "Build complete brand identities", "Intermediate",
     [("Branding", 85), ("Adobe Illustrator", 80), ("Visual Identity Design", 80), ("Typography", 70),
      ("Adobe Photoshop", 70), ("Design Systems", 60)]),
    ("Graphic Design & Branding", "Print & Layout Designer", "Design print-ready publications", "Beginner",
     [("Layout Design", 85), ("InDesign", 80), ("Adobe Photoshop", 70), ("Print Production", 70),
      ("Typography", 65), ("Color Theory", 65)]),

    # ---- Architecture & Interior Design ----
    ("Architecture & Interior Design", "Architect", "Design buildings and oversee projects", "Advanced",
     [("AutoCAD", 85), ("Revit", 80), ("SketchUp", 75), ("Building Codes", 75),
      ("Sustainable Design", 70), ("Site Planning", 70)]),
    ("Architecture & Interior Design", "Interior Designer", "Design functional beautiful interiors", "Intermediate",
     [("Space Planning", 85), ("SketchUp", 80), ("AutoCAD", 75), ("Material Selection", 70),
      ("3D Visualization", 70), ("Client Relationship Management", 60)]),
    ("Architecture & Interior Design", "Urban Planner", "Plan cities and public spaces", "Advanced",
     [("Urban Planning", 80), ("GIS Tools", 75), ("Sustainable Design", 70), ("AutoCAD", 65),
      ("Policy Analysis", 65), ("Report Writing", 60)]),

    # ---- Agriculture & AgriTech ----
    ("Agriculture & AgriTech", "Agronomist", "Improve crop yield and soil health", "Intermediate",
     [("Agronomy", 85), ("Crop Management", 80), ("Soil Testing", 75),
      ("Pest & Disease Management", 70), ("Precision Farming", 65), ("Field Research", 65)]),
    ("Agriculture & AgriTech", "Agri Business Manager", "Run agri products and supply businesses", "Intermediate",
     [("Agri Supply Chain", 75), ("Market Research", 70), ("Excel", 70), ("Procurement", 65),
      ("Communication", 65), ("Financial Modeling", 55)]),
    ("Agriculture & AgriTech", "Soil Scientist", "Study and classify soils", "Advanced",
     [("Soil Testing", 85), ("Soil Chemistry", 80), ("Agronomy", 70), ("GIS Tools", 65),
      ("Lab Techniques", 65), ("Report Writing", 60)]),

    # ---- Psychology & Counselling ----
    ("Psychology & Counselling", "Counselling Psychologist", "Support clients through life challenges", "Intermediate",
     [("Counselling Techniques", 85), ("Psychological Assessment", 80), ("Active Listening", 80),
      ("Communication", 75), ("CBT Basics", 70), ("Case Documentation", 65)]),
    ("Psychology & Counselling", "Clinical Psychologist", "Assess and treat mental health conditions", "Advanced",
     [("Psychological Assessment", 90), ("Clinical Diagnosis", 80), ("CBT Basics", 80),
      ("Ethics in Psychology", 75), ("Counselling Techniques", 75), ("Research Methods", 70)]),
    ("Psychology & Counselling", "HR Psychologist", "Apply psychology to workplaces", "Intermediate",
     [("Psychological Assessment", 75), ("Employee Engagement", 70), ("Communication", 70),
      ("Counselling Techniques", 65), ("HR Analytics", 65), ("Research Methods", 65)]),

    # ---- Government & Public Administration ----
    ("Government & Public Administration", "Civil Services Officer (UPSC)", "Serve in IAS, IPS and allied services", "Advanced",
     [("Indian Polity", 85), ("General Studies", 85), ("Current Affairs", 80),
      ("Indian History & Geography", 75), ("Essay Writing", 70), ("Answer Writing Practice", 70)]),
    ("Government & Public Administration", "Public Policy Analyst", "Research and evaluate public policies", "Intermediate",
     [("Policy Analysis", 85), ("Research Methods", 75), ("Report Writing", 75),
      ("Economics Basics", 70), ("Data Visualization", 60), ("Statistics & Probability", 60)]),
    ("Government & Public Administration", "Government Officer (SSC/Banking)", "Crack SSC, banking and state exams", "Beginner",
     [("Quantitative Aptitude", 85), ("Logical Reasoning", 85), ("General Awareness", 75),
      ("English Language", 75), ("Time Management", 70), ("Excel", 55)]),

    # ---- QA & Software Testing ----
    ("QA & Software Testing", "QA Analyst", "Test software manually and report defects", "Beginner",
     [("Manual Testing", 85), ("Test Case Design", 85), ("Bug Tracking", 80), ("JIRA", 75),
      ("SDLC & STLC", 70), ("SQL", 60)]),
    ("QA & Software Testing", "Automation Test Engineer", "Automate regression test suites", "Intermediate",
     [("Selenium", 85), ("Test Automation", 80), ("API Testing", 75), ("Java", 70),
      ("Git & GitHub", 65), ("CI/CD Pipelines", 60)]),
    ("QA & Software Testing", "Performance Test Engineer", "Stress-test systems for scale", "Advanced",
     [("JMeter", 85), ("Performance Testing", 85), ("LoadRunner", 70), ("API Testing", 70),
      ("Monitoring & Observability", 65), ("SQL", 65)]),

    # ---- E-commerce Operations ----
    ("E-commerce Operations", "E-commerce Manager", "Run online stores and marketplaces", "Intermediate",
     [("E-commerce Platforms", 80), ("Digital Cataloging", 75), ("Order Management", 75),
      ("Google Analytics", 70), ("Supply Chain Basics", 65), ("Meta Ads", 60)]),
    ("E-commerce Operations", "Marketplace Specialist", "Grow sales on Amazon and Flipkart", "Beginner",
     [("Amazon Seller Central", 85), ("Product Listing", 80), ("Digital Cataloging", 75),
      ("E-commerce SEO", 70), ("Excel", 70), ("Customer Service", 60)]),
    ("E-commerce Operations", "Catalog Quality Specialist", "Keep product data clean and complete", "Beginner",
     [("Digital Cataloging", 85), ("Product Listing", 80), ("Content Quality Review", 75),
      ("Excel", 75), ("Problem Solving", 60), ("SEO Writing", 55)]),
]

# =====================================================================
# GENERATION LOGIC
# =====================================================================

def parse_existing(sql: str):
    """Extract existing row names so generated data never duplicates them."""
    skills = set()
    # matches ('Skill Name', 'Category', 'desc'),  tuples in section 5
    for m in re.finditer(r"^\('([^']+)',\s*'[^']+',\s*'[^']*'\),?$", sql, re.M):
        skills.add(m.group(1))

    domains = set(re.findall(r"^\('([^']+)',\s*'[^']+'\),?$", sql, re.M)) - skills

    careers = set()
    req_pairs = set()
    for m in re.finditer(r"SELECT '([^']+)' AS career_name, '([^']+)' AS skill_name", sql):
        req_pairs.add((m.group(1), m.group(2)))
    for m in re.finditer(r"UNION ALL SELECT '([^']+)', '([^']+)', (\d+)", sql):
        req_pairs.add((m.group(1), m.group(2)))
    # career names defined in section 4 style rows
    for m in re.finditer(r"SELECT '[^']+' AS domain_name, '([^']+)' AS name", sql):
        careers.add(m.group(1))
    for m in re.finditer(r"UNION ALL SELECT '[^']+', '([^']+)', '[^']+', '(?:Beginner|Intermediate|Advanced)'", sql):
        careers.add(m.group(1))

    programs = set(re.findall(r"SELECT '[^']+' AS category_name, '([^']+)'", sql))
    for m in re.finditer(r"UNION ALL SELECT '[^']+',\s*'([^']+)',\s*'(Undergraduate|Postgraduate|Professional)'", sql):
        programs.add(m.group(1))

    categories = set()
    for m in re.finditer(r"^\('([^']+)',\s*'[^']+'\),?$", sql.split("-- 3) DOMAINS")[0], re.M):
        categories.add(m.group(1))

    return categories, programs, domains, careers, skills, req_pairs


def main() -> None:
    sql = INIT_SQL.read_text()

    # For idempotent re-runs: ignore our own previously generated block
    # when deciding what already exists — it is fully replaced below.
    base_sql = sql
    if BEGIN in sql and END in sql:
        base_sql = sql.split(BEGIN)[0] + sql.split(END)[1]

    (ex_categories, ex_programs, ex_domains,
     ex_careers, ex_skills, ex_reqs) = parse_existing(base_sql)

    errors = []

    # ---- validations -------------------------------------------------
    seen_careers = set()
    for domain, career, desc, avg, skills in CAREERS:
        if career in seen_careers:
            errors.append(f"duplicate career in new data: {career}")
        seen_careers.add(career)
        if career in ex_careers:
            errors.append(f"career already exists in init.sql: {career}")
        if avg not in ("Beginner", "Intermediate", "Advanced"):
            errors.append(f"bad avg_level '{avg}' for {career}")
        seen_skills = set()
        for skill, level in skills:
            if skill in seen_skills:
                errors.append(f"duplicate skill '{skill}' within {career}")
            seen_skills.add(skill)
            if not (1 <= int(level) <= 100):
                errors.append(f"bad level {level} for {career}/{skill}")

    new_domain_names = [d for d, _ in DOMAINS]
    if len(set(new_domain_names)) != len(new_domain_names):
        errors.append("duplicate domain in new data")
    for d in new_domain_names:
        if d in ex_domains:
            errors.append(f"domain already exists in init.sql: {d}")

    all_domains = ex_domains | set(new_domain_names)
    for domain, career, *_ in CAREERS:
        if domain not in all_domains:
            errors.append(f"career {career} references unknown domain {domain}")

    # ---- collect new skills (auto-register unknown ones) -------------
    new_skills = {}
    auto_registered = set()
    for domain, career, desc, avg, skills in CAREERS:
        for skill, level in skills:
            if skill in ex_skills or skill in new_skills:
                continue
            info = SKILL_INFO.get(skill)
            if info is None:
                category = DOMAIN_SKILL_CATEGORY[domain]
                info = (category, f"Core skill for {domain.lower()} roles")
                auto_registered.add(skill)
            new_skills[skill] = info

    # new programs dedupe vs existing
    new_programs = [p for p in PROGRAMS if p[1] not in ex_programs]
    new_categories = [c for c in CATEGORIES if c[0] not in ex_categories]
    new_domains = [d for d in DOMAINS if d[0] not in ex_domains]

    # category existence for programs
    all_categories = ex_categories | {c for c, _ in new_categories} | {
        "Computer Science & IT", "Engineering (Core)", "Business & Management",
        "Commerce & Finance", "Science", "Arts, Design & Media", "Health & Life Sciences",
    }
    for category, name, *_ in new_programs:
        if category not in all_categories:
            errors.append(f"program {name} references unknown category {category}")

    # requirements: skip pairs already seeded
    new_reqs = []
    for domain, career, desc, avg, skills in CAREERS:
        for skill, level in skills:
            if (career, skill) in ex_reqs:
                continue
            new_reqs.append((career, skill, int(level)))

    if errors:
        print("VALIDATION FAILED:")
        for e in errors:
            print("  -", e)
        raise SystemExit(1)

    # ---- emit SQL ----------------------------------------------------
    lines = []
    add = lines.append
    add(BEGIN)
    add("-- 27 domains / 81 careers / ~260 skills / 54 programs.")
    add("-- Generated by generate_seed.py - edit data there, then re-run it.")

    if new_categories:
        add("\n-- extra education categories")
        add("INSERT IGNORE INTO `education_categories` (`name`, `description`) VALUES")
        add(",\n".join(
            f"('{esc(n)}', '{esc(d)}')" for n, d in new_categories
        ) + ";")

    if new_programs:
        add("\n-- extra education programs (guarded by name)")
        add("INSERT INTO `education_programs` (`category_id`, `name`, `level`, `description`)")
        add("SELECT c.id, t.name, t.level, t.description")
        add("FROM (")
        rows = []
        for i, (cat, name, level, desc) in enumerate(new_programs):
            prefix = "    SELECT" if i == 0 else "    UNION ALL SELECT"
            rows.append(
                f"{prefix} '{esc(cat)}' AS category_name, '{esc(name)}' AS name, "
                f"'{esc(level)}' AS level, '{esc(desc)}' AS description"
            )
        add("\n".join(rows))
        add(") t")
        add("JOIN `education_categories` c ON c.name = t.category_name")
        add("LEFT JOIN `education_programs` p ON p.name = t.name")
        add("WHERE p.id IS NULL;")

    if new_domains:
        add("\n-- extra domains")
        add("INSERT IGNORE INTO `domains` (`name`, `description`) VALUES")
        add(",\n".join(
            f"('{esc(n)}', '{esc(d)}')" for n, d in new_domains
        ) + ";")

    add("\n-- extra skills")
    add("INSERT IGNORE INTO `skills_v2` (`name`, `category`, `description`) VALUES")
    add(",\n".join(
        f"('{esc(n)}', '{esc(c)}', '{esc(d)}')"
        for n, (c, d) in sorted(new_skills.items())
    ) + ";")

    add("\n-- extra careers (guarded by name)")
    add("INSERT INTO `careers_v2` (`domain_id`, `name`, `description`, `average_level`)")
    add("SELECT d.id, t.name, t.description, t.avg_level")
    add("FROM (")
    rows = []
    for i, (domain, career, desc, avg, _s) in enumerate(CAREERS):
        prefix = "    SELECT" if i == 0 else "    UNION ALL SELECT"
        rows.append(
            f"{prefix} '{esc(domain)}' AS domain_name, '{esc(career)}' AS name, "
            f"'{esc(desc)}' AS description, '{avg}' AS avg_level"
        )
    add("\n".join(rows))
    add(") t")
    add("JOIN `domains` d ON d.name = t.domain_name")
    add("LEFT JOIN `careers_v2` c ON c.name = t.name")
    add("WHERE c.id IS NULL;")

    add("\n-- extra career-skill requirements (chunked)")
    chunk = 120
    for start in range(0, len(new_reqs), chunk):
        part = new_reqs[start:start + chunk]
        add("INSERT IGNORE INTO `career_skill_requirements` (`career_id`, `skill_id`, `required_level`)")
        add("SELECT c.id, s.id, t.required_level")
        add("FROM (")
        rows = []
        for i, (career, skill, level) in enumerate(part):
            prefix = "    SELECT" if i == 0 else "    UNION ALL SELECT"
            rows.append(
                f"{prefix} '{esc(career)}' AS career_name, '{esc(skill)}' AS skill_name, {level} AS required_level"
            )
        add("\n".join(rows))
        add(") t")
        add("JOIN `careers_v2` c ON c.name = t.career_name")
        add("JOIN `skills_v2` s ON s.name = t.skill_name;")

    add(END)
    mega = "\n".join(lines) + "\n"

    # ---- patch init.sql -----------------------------------------------
    if BEGIN in sql and END in sql:
        before = sql.split(BEGIN)[0].rstrip("\n") + "\n"
        after = sql.split(END)[1].lstrip("\n")
        sql_new = before + mega.strip("\n") + "\n\n" + after
    else:
        marker = "-- =====================================================\n-- 7) VERIFY"
        assert marker in sql, "verify marker not found in init.sql"
        sql_new = sql.replace(
            marker,
            "-- =====================================================\n"
            "-- 8) EXPANDED SEED DATA - ALL DOMAINS (generated)\n"
            "-- =====================================================\n"
            + mega.strip("\n") + "\n\n" + marker,
        )
        sql_new = sql_new.replace("-- 7) VERIFY", "-- 9) VERIFY")

    # refresh expected counts comment (the two lines under the VERIFY header)
    sql_new = re.sub(
        r"--\s*9\) VERIFY[^\n]*\n--[^\n]*\n--[^\n]*\n",
        "-- 9) VERIFY — expected after a fresh run (approx. minimums):\n"
        "--    education_categories 10+, education_programs 79+, domains 37+,\n"
        "--    careers_v2 114+, skills_v2 340+, career_skill_requirements 680+\n",
        sql_new,
        count=1,
    )

    INIT_SQL.write_text(sql_new)

    # ---- report -------------------------------------------------------
    print("✔ init.sql updated")
    print(f"  new categories : {len(new_categories)}")
    print(f"  new programs   : {len(new_programs)}")
    print(f"  new domains    : {len(new_domains)}")
    print(f"  new careers    : {len(CAREERS)}")
    print(f"  new skills     : {len(new_skills)}")
    print(f"  new requirements: {len(new_reqs)}")
    if auto_registered:
        print(f"  auto-registered skills ({len(auto_registered)}):")
        for s in sorted(auto_registered):
            print(f"    + {s} [{new_skills[s][0]}]")
    print("  totals (approx, incl. existing):")
    print(f"    domains {len(ex_domains) + len(new_domains)} | "
          f"careers {len(ex_careers) + len(CAREERS)} | "
          f"skills {len(ex_skills) + len(new_skills)} | "
          f"requirements {len(ex_reqs) + len(new_reqs)} | "
          f"programs {len(ex_programs) + len(new_programs)}")


if __name__ == "__main__":
    main()
