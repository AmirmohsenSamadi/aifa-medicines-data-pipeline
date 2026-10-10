CREATE TABLE Medicines (
    AIC INT PRIMARY KEY,
    Principio_Attivo TEXT,
    Descrizione_Gruppo TEXT,
    Codice_Atc TEXT,
    Codice_Gruppo_Equivalenza TEXT
);

INSERT INTO Medicines (
    principio_attivo,
    descrizione_gruppo,
    aic,
    codice_gruppo_equivalenza,
    codice_atc
)
SELECT
    `Principio Attivo`,
    `Descrizione Gruppo`,
    `AIC`,
    `Codice Gruppo Equivalenza`,
    `codiceAtc`
FROM final_dataset;



CREATE TABLE Commercial_information (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Principio_Attivo TEXT,
    Denominazione_e_Confezione TEXT,
    Titolare_AIC TEXT,
    AIC INT,
    FOREIGN KEY (AIC) REFERENCES Medicines(AIC) ON DELETE CASCADE
);

INSERT INTO Commercial_information (
    principio_attivo,
    Denominazione_e_Confezione,
    Titolare_AIC,
    AIC
)
SELECT
    `Principio Attivo`,
    `Denominazione e Confezione`,
    `Titolare AIC`,
    `AIC`
FROM final_dataset;



CREATE TABLE Consumption (
    id INT AUTO_INCREMENT PRIMARY KEY,
    AIC INT,
    Indicazioni_Terapeutiche TEXT,
    Posologia_e_Modo_di_Somministrazione TEXT,
    Fertility_Pregnancy_Lactation TEXT,
    FOREIGN KEY (AIC) REFERENCES Medicines(AIC) ON DELETE CASCADE
);

INSERT INTO Consumption (
    Indicazioni_Terapeutiche,
    Posologia_e_Modo_di_Somministrazione,
    Fertility_Pregnancy_Lactation,
    AIC
)
SELECT
    `4.1 Indicazioni terapeutiche`,
    `4.2 Posologia e modo di somministrazione`,
    `4.6 Fertility, pregnancy and lactation`,
    `AIC`
FROM final_dataset;



CREATE TABLE Contraindications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    AIC int,
    Contraindications TEXT,
    Special_Warnings_and_Precautions TEXT,
    Interactions_with_Other_Medicinal_Products TEXT,
    Effects_on_Ability_to_Drive_and_Use_Machines TEXT,
    Undesirable_Effects TEXT,
    Overdose TEXT,
    Incompatibilities TEXT,
    FOREIGN KEY (AIC) REFERENCES Medicines(AIC) ON DELETE CASCADE
);

INSERT INTO Contraindications (
    AIC,
    Contraindications,
    Special_Warnings_and_Precautions,
    Interactions_with_Other_Medicinal_Products,
    Effects_on_Ability_to_Drive_and_Use_Machines,
    Undesirable_Effects,
    Overdose,
    Incompatibilities
)
SELECT
	`AIC`,
    `4.3 Contraindications`,
    `4.4 Special warnings and precautions for use`,
    `4.5 Interactions with other medicinal products`,
    `4.7 Effects on ability to drive and use machines`,
    `4.8 Undesirable effects (side effects)`,
    `4.9 Overdose`,
    `6.2 Incompatibilities`
FROM final_dataset;


-- Medicines grouped by equivalence group
SELECT 
    Codice_Gruppo_Equivalenza,
    GROUP_CONCAT(Principio_Attivo) AS Medicines
FROM Medicines
GROUP BY Codice_Gruppo_Equivalenza;


-- Medicines by ATC classification
SELECT 
    Codice_Atc,
    GROUP_CONCAT(Principio_Attivo) AS Medicines
FROM Medicines
GROUP BY Codice_Atc
ORDER BY Codice_Atc;


-- Number of medicines per manufacturers
SELECT 
    ci.Titolare_AIC AS Manufacturer,
    COUNT(DISTINCT m.Principio_Attivo) AS Number_of_Medicines
FROM Medicines m
JOIN Commercial_information ci ON m.AIC = ci.AIC
GROUP BY ci.Titolare_AIC
ORDER BY Number_of_Medicines DESC;


-- How many products each Titolare AIC holds
SELECT 
    Titolare_AIC,
    COUNT(*) AS Product_Count
FROM Commercial_information
GROUP BY Titolare_AIC
ORDER BY Product_Count DESC;


-- Number of dosage forms per active ingredient
SELECT 
    LOWER(TRIM(Principio_Attivo)) AS Normalized_Principio_Attivo,
    COUNT(DISTINCT Descrizione_Gruppo) AS Dose_Count
FROM Medicines
GROUP BY Normalized_Principio_Attivo
ORDER BY Dose_Count DESC;

-- Approximate number of side effects per active ingredient
SELECT 
    m.Principio_Attivo,
    COUNT(*) AS Records,
    SUM(LENGTH(c.Undesirable_Effects) - LENGTH(REPLACE(c.Undesirable_Effects, ';', '')) + 1) AS Side_Effect_Count
FROM Contraindications c
JOIN Medicines m ON c.AIC = m.AIC
WHERE c.Undesirable_Effects IS NOT NULL AND c.Undesirable_Effects <> ''
GROUP BY m.Principio_Attivo
ORDER BY Side_Effect_Count DESC;



