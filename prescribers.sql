--1.a. Which prescriber had the highest total number of claims (totaled over all drugs)?
--Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS total_over_all_drugs
FROM prescriber INNER JOIN prescription USING (npi)
GROUP BY npi
ORDER BY total_over_all_drugs DESC
LIMIT 1;

--1.Repeat the above, but this time report the nppes_provider_first_name, 
--nppes_provider_last_org_name,  specialty_description, and the total number of 
--claims.
SELECT nppes_provider_first_name,
	   nppes_provider_last_org_name,
	   specialty_description,
	   SUM(total_claim_count) AS total_over_all_drugs
FROM prescriber INNER JOIN prescription USING (npi)
GROUP BY nppes_provider_first_name,
	   nppes_provider_last_org_name,
	   specialty_description
ORDER BY total_over_all_drugs DESC
LIMIT 1;

--2.  a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description, COUNT(total_claim_count) AS total_claims_all_drugs
FROM prescriber LEFT JOIN prescription USING (npi)
GROUP BY specialty_description
ORDER BY total_claims_all_drugS DESC
LIMIT 1;

-- b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description, COUNT (opioid_drug_flag) AS opioid_drug_flag
FROM prescriber INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY opioid_drug_flag DESC
LIMIT 1;

--c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have 
--no associated prescriptions in the prescription table?

SELECT specialty_description
FROM prescriber LEFT JOIN prescription USING (npi)
WHERE total_claim_count IS NULL
GROUP BY specialty_description;

--d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, 
--report the percentage of total claims by that specialty which are for opioids. 
--Which specialties have a high percentage of opioids?


--3. a. Which drug (generic_name) had the highest total drug cost?
SELECT generic_name, SUM (total_drug_cost) AS total_cost
FROM drug JOIN prescription USING (drug_name) 
GROUP BY generic_name
ORDER BY total_cost DESC
LIMIT 1;


--b. Which drug (generic_name) has the hightest total cost per day?
--**Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, ROUND(SUM(total_drug_cost)/NULLIF(SUM(total_day_supply),0),2) AS total_cost_per_day
FROM drug JOIN prescription USING (drug_name)
GROUP BY generic_name
ORDER BY total_cost_per_day DESC
LIMIT 1;

--4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says
--'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have 
--antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. 
--**Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 

SELECT drug_name,
 	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	     WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug;

--    b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost)
--on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT *
FROM drug JOIN prescription USING (drug_name);

--5. a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, 
--not just Tennessee.

SELECT COUNT(*)
FROM cbsa
WHERE cbsaname ILIKE '%TN%';

  -- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name 
  --and total population.
SELECT *
FROM cbsa  JOIN population USING (fipscounty);

SELECT *
FROM population;












	