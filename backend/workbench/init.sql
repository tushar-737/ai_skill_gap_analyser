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
  `raw_text` TEXT NULL,
  `extracted_skills` JSON NULL,
  `target_career_id` INT NULL,
  `extraction_source` VARCHAR(20) NOT NULL DEFAULT 'keyword',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_resume_career` (`target_career_id`),
  CONSTRAINT `fk_resume_career`
    FOREIGN KEY (`target_career_id`) REFERENCES `careers_v2` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- Verify
-- -----------------------------------------------------
-- SHOW TABLES;
-- SELECT COUNT(*) FROM skills_v2;
-- SELECT COUNT(*) FROM careers_v2;
