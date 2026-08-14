--1.a. Which prescriber had the highest total number of claims (totaled over all drugs)?
--Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS total_claim_count
FROM prescriber JOIN prescription USING (npi)
GROUP BY npi
ORDER BY total_claim_count DESC
LIMIT 1;

-- npi 1881634483 highest claims at 99707 

--1.b. Repeat the above, but this time report the nppes_provider_first_name, 
--nppes_provider_last_org_name,  specialty_description, and the total number of 
--claims.
SELECT npi,nppes_provider_first_name,
	   nppes_provider_last_org_name,
	   specialty_description,
	   SUM(total_claim_count) AS total_over_all_drugs
FROM prescriber INNER JOIN prescription USING (npi)
GROUP BY npi,nppes_provider_first_name,
	   nppes_provider_last_org_name,
	   specialty_description
ORDER BY total_over_all_drugs DESC
LIMIT 1;

-- Bruce Pendley Family Practice 99707

--2.  a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description, SUM(total_claim_count) AS total_claims 
FROM prescriber JOIN prescription USING (npi)
GROUP BY specialty_description
ORDER BY total_claims DESC
LIMIT 1;

---- FAMILY PRACTICE had highest total claims (left npi in, as grouping by name grouped different 
--people with the same name together)


-- b. Which specialty had the most total number of claims for opioids? 
SELECT specialty_description, SUM(total_claim_count) AS total_opioid_claim_count
FROM prescriber JOIN prescription USING (npi)
     JOIN drug USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY total_opioid_claim_count DESC; -- NURSE PRACTIONER 900845

--OR 
SELECT specialty_description, 
	SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count END) AS total_opioid_claim_count
FROM prescriber JOIN prescription USING (npi)
     JOIN drug USING (drug_name)
GROUP BY specialty_description
ORDER BY total_opioid_claim_count DESC NULLS LAST;  -- NURSE PRACTIONER 900845




--c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have 
--no associated prescriptions in the prescription table?


SELECT specialty_description,COUNT(total_claim_count) AS total_claim_count
FROM prescriber LEFT JOIN prescription USING (npi)
GROUP BY specialty_description
ORDER BY total_claim_count ASC;

----OR----

SELECT specialty_description,SUM(total_claim_count) AS total_claim_count
FROM prescriber LEFT JOIN prescription USING (npi)
WHERE total_claim_count IS NULL
GROUP BY specialty_description;


--d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, 
--report the percentage of total claims by that specialty which are for opioids. 
--Which specialties have a high percentage of opioids?

SELECT specialty_description,
 COALESCE(SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count END)/ NULLIF(ROUND(SUM(total_claim_count),2),0) *100,0) AS percent_of_opioid_claims 
FROM prescriber JOIN prescription USING (npi)
    JOIN drug USING (drug_name)
GROUP BY specialty_description;

--3. a. Which drug (generic_name) had the highest total drug cost?
SELECT generic_name, SUM (total_drug_cost) AS total_cost
FROM drug JOIN prescription USING (drug_name) 
GROUP BY generic_name
ORDER BY total_cost DESC
LIMIT 1;

-- INSULIN GLARGINE,HUM.REC.ANLOG 104264066.35


--b. Which drug (generic_name) has the hightest total cost per day?
--**Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, ROUND(SUM(total_drug_cost)/NULLIF(SUM(total_day_supply),0),2) AS total_cost_per_day
FROM drug JOIN prescription USING (drug_name)
GROUP BY generic_name
ORDER BY total_cost_per_day DESC
LIMIT 1;

--C1 ESTERASE INHIBITOR 3495.22

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

SELECT 
SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_drug_cost::MONEY END) AS total_drug_cost_opioid, 
 SUM (CASE WHEN antibiotic_drug_flag = 'Y' THEN total_drug_cost::MONEY END) AS total_drug_cost_antibiotic
  FROM drug JOIN prescription USING (drug_name);

  --Opioids had a higer total cost $105,080,626.37

--5. a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, 
--not just Tennessee.

SELECT COUNT(*)
FROM cbsa
WHERE cbsaname ILIKE '%TN%';

--58

  -- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name 
  --and total population.
SELECT cbsa, cbsaname, SUM(population) AS combined_pop
FROM cbsa  JOIN population USING (fipscounty)
GROUP BY cbsa, cbsaname
ORDER BY combined_pop DESC
LIMIT 1;

-- cbsa Largest population Nashville-Davidson--Murfreesboro--Franklin, TN 1830410

SELECT cbsa, cbsaname, SUM(population) AS combined_pop
FROM cbsa  JOIN population USING (fipscounty)
GROUP BY cbsa, cbsaname
ORDER BY combined_pop ASC
LIMIT 1;

-- cbsa smallest population Morristown, TN 116352

--What is the largest (in terms of population) county which is not included in a CBSA?
--Report the county name and population.

SELECT fipscounty,county,SUM(population) AS total_pop
FROM population LEFT JOIN cbsa USING (fipscounty)
 JOIN fips_county USING (fipscounty)
WHERE cbsa IS NULL
GROUP BY fipscounty,county
ORDER BY total_pop DESC
LIMIT 1; 

-- Largest county (population) not included in CBSA is Sevier, pop. 95523


--6. a. Find all rows in the prescription table where total_claims is at least 3000. 
--Report the drug_name and the total_claim_count.

SELECT drug_name,total_claim_count
FROM prescription JOIN drug USING (drug_name)
WHERE total_claim_count >3000
ORDER BY total_claim_count DESC;

--6. b. For each instance that you found in part a, add a column that indicates whether the drug is an 
--opioid.

SELECT drug_name,total_claim_count, 
CASE WHEN opioid_drug_flag = 'Y' THEN 'Y' 
 ELSE 'N' END AS opioid
FROM prescription JOIN drug USING (drug_name)
WHERE total_claim_count >3000
ORDER BY total_claim_count DESC;

--6. c. Add another column to you answer from the previous part which gives the prescriber 
--first and last name associated with each row.

SELECT nppes_provider_last_org_name,
       nppes_provider_first_name,
       drug_name,
	   total_claim_count, 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'Y' 
 	ELSE 'N' END AS opioid
FROM prescription JOIN drug USING (drug_name)
		JOIN prescriber USING (npi)
WHERE total_claim_count >3000
ORDER BY total_claim_count DESC;

--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville
--and the number of claims they had for each opioid. 
--**Hint:** The results from all 3 parts will have 637 rows.
--a. First, create a list of all npi/drug_name combinations for pain management specialists 
--(specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'),
--where the drug is an opioid (opiod_drug_flag = 'Y').
--**Warning:** Double-check your query before running it. You will only need to use the prescriber and 
--drug tables since you don't need the claims numbers yet.



SELECT npi,drug_name 
FROM prescriber
	CROSS JOIN drug
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
    AND opioid_drug_flag = 'Y';

	
--b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations,
--whether or not the prescriber had any claims. 
--You should report the npi, the drug name, and the number of claims (total_claim_count).

--c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. 
--Hint - Google the COALESCE function.

SELECT prescriber.npi,drug.drug_name,COALESCE(total_claim_count,0)
FROM prescriber
	CROSS JOIN drug
	LEFT JOIN prescription ON prescriber.npi=prescription.npi 
	   AND drug.drug_name = prescription.drug_name
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
    AND opioid_drug_flag = 'Y';












	