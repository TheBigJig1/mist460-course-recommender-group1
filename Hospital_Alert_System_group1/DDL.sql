-- MIST 460 - Group 1: Hospital Alert System
-- Authors: Nada Mikky
-- Description: DDL script to create the database 
-- and tables for the Hospital Alert System

-- Create Database
CREATE DATABASE HospitalAlertSystem;
GO
USE HospitalAlertSystem;
GO

-- Users
CREATE TABLE User (
    userID INT PRIMARY KEY IDENTITY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(50)
);

-- Medical Staff
CREATE TABLE MedicalStaff (
    staffID INT PRIMARY KEY IDENTITY,
    name VARCHAR(100),
    role VARCHAR(50),
    specialty VARCHAR(50),
    shift VARCHAR(50)
);

-- Weather Data
CREATE TABLE WeatherData (
    weatherID INT PRIMARY KEY IDENTITY,
    temperature DECIMAL(4,1),
    humidity DECIMAL(4,1),
    forecast VARCHAR(100),
    date DATE
);

-- Event Data
CREATE TABLE EventData (
    eventID INT PRIMARY KEY IDENTITY,
    eventName VARCHAR(100),
    date DATE,
    location VARCHAR(100),
    expectedAttendance INT,
    type VARCHAR(50)
);

-- Previous Surge Data
CREATE TABLE PreviousSurgeData (
    surgeID INT PRIMARY KEY IDENTITY,
    date DATE,
    type VARCHAR(50),
    timeOfDay VARCHAR(50),
    patientCount INT
);

-- Data Source
CREATE TABLE DataSource (
    dataSourceID INT PRIMARY KEY IDENTITY,
    type VARCHAR(50),
    lastFetched DATETIME
);

-- Alert
CREATE TABLE Alert (
    alertID INT PRIMARY KEY IDENTITY,
    alertMessage VARCHAR(255),
    severityLevel VARCHAR(20),
    timeStamp DATETIME
);

-- Administrator
CREATE TABLE Administrator (
    adminID INT PRIMARY KEY IDENTITY,
    name VARCHAR(100),
    department VARCHAR(100)
);

-- Distributor
CREATE TABLE Distributor (
    distributorID INT PRIMARY KEY IDENTITY,
    companyName VARCHAR(100),
    supplyCategory VARCHAR(100)
);

-- Prediction Engine
CREATE TABLE PredictionEngine (
    engineID INT PRIMARY KEY IDENTITY,
    modelType VARCHAR(50),
    accuracy DECIMAL(4,2)
);

-- Patient Count Prediction
CREATE TABLE PatientCountPrediction (
    predictionID INT PRIMARY KEY IDENTITY,
    predictedVolume INT,
    confidenceLevel DECIMAL(4,2),
    timestamp DATETIME
);

-- Agent System
CREATE TABLE AgentSystem (
    systemID INT PRIMARY KEY IDENTITY,
    lastUpdateTime DATETIME
);

-- Recommendation Engine
CREATE TABLE RecommendationEngine (
    recommendationID INT PRIMARY KEY IDENTITY,
    type VARCHAR(50)
);

-- Recommendation
CREATE TABLE Recommendation (
    recommendationID INT PRIMARY KEY,
    description VARCHAR(255)
);
