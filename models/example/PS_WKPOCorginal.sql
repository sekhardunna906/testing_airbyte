{{ config(materialized='table') }}

WITH 
  wk_silvercte AS (
    SELECT DISTINCT 
        "emplid" AS employee_id,
        "country_nm_format" AS country_iso_code,
        "first_name" AS legal_first_name,
        "last_name" AS legal_last_name,
        "mar_status" AS marital_status_name,
        "mar_status_dt" AS marital_status_date,
        "military_status" AS military_status_name,
        "birthstate" AS region_of_birth,
        "birthdate" AS date_of_birth,
        "sex" AS gender_description,
        "disabled" AS disability_name,
        "smoker" AS uses_tobacco,
        "postal" AS postal_code
    FROM
        poc.ps_personal_data
  ),
  wk_addresses AS (
    SELECT DISTINCT 
        "emplid" AS employee_id,
        "country" AS country_iso_code,
        "address_type" AS work_address_data
    FROM
        poc.ps_addresses
    WHERE address_type IN ('MAIL', 'OTH', 'PERM', 'LEGL')
  ),
  wk_divers_ethnic AS (
    SELECT DISTINCT 
        "emplid" AS employee_id
    FROM
        poc.ps_divers_ethnic
  ),
  wk_ps_visa_pmt_data AS (
    SELECT DISTINCT 
        "emplid" AS employee_id,
        "country" AS country_iso_code,
        "visa_wrkpmt_nbr" AS visa_id,
        "visa_permit_type" AS visa_type_name 
    FROM
        poc.ps_visa_pmt_data
  ),
  wk_pers_nid AS (
    SELECT DISTINCT 
        "emplid" AS employee_id,
        "country" AS country_iso_code,
        "national_id" AS national_id,
        "national_id_type" AS national_id_type_code 
    FROM
        poc.ps_pers_nid
  ),
  wk_drivers_lic AS (
    SELECT DISTINCT 
        "emplid" AS employee_id,
        "drivers_lic_nbr" AS license_id,
        "valid_from_dt" AS issued_date,
        "expiratn_dt" AS expiration_date,
        "country" AS country_iso_code,
        "STATE" AS country_region,
        "issued_by_fra" AS authority_name
    FROM
        poc.ps_drivers_lic
  ),
  wk_employment AS (
    SELECT DISTINCT 
        "emplid" AS employee_id,
        "hire_dt" AS hire_date,
        "supervisor_id" AS manager_id
    FROM
        poc.ps_employment
  )
  
  
  
--- Combine all CTEs
SELECT DISTINCT
  s.employee_id, 
  CASE WHEN s.country_iso_code = ' ' OR s.country_iso_code = '001' THEN '1' ELSE s.country_iso_code END AS country_iso_code,
  s.legal_first_name,
  s.legal_last_name,
  CASE 
    WHEN s.marital_status_name IS NULL THEN 'NA'  ELSE s.marital_status_name
  END marital_status_name,
  CASE 
    WHEN s.marital_status_date IS NULL THEN 'NA'  
  END marital_status_date,
  s.military_status_name,
  CASE 
    WHEN s.region_of_birth = ' ' THEN 'NA'  ELSE 'NA'
  END region_of_birth,
  CASE 
    WHEN s.date_of_birth IS NULL THEN 'NA'
    ELSE TO_CHAR(CAST(s.date_of_birth AS DATE), 'MM/DD/YYYY')
  END date_of_birth,
  CASE 
    WHEN s.gender_description = 'M' THEN 'Male'
    WHEN s.gender_description = 'F' THEN 'Female'
    WHEN s.gender_description = 'U' THEN 'Undisclosed'
    WHEN s.gender_description IS NULL THEN 'NA'
  END AS gender_description,
  s.disability_name,
  s.uses_tobacco,
  CASE 
  WHEN a.work_address_data IS NULL  THEN 'NA'  ELSE a.work_address_data
  END work_address_data,
  CASE 
  WHEN v.visa_id IS NULL  THEN 'NA'  ELSE v.visa_id
  END visa_id,
  CASE 
  WHEN v.visa_type_name IS NULL  THEN 'NA'  ELSE v.visa_type_name
  END visa_type_name,
  CASE 
    WHEN n.national_id_type_code = 'PR' THEN 'Permanent Residence' ELSE 'NA'
  END national_id_type_code,
  SUBSTR('650100104', 1, 4) || '-' || SUBSTR('650100104', 5, 3) || '-' || SUBSTR('650100104', 8) AS national_id,
  CASE 
  WHEN dl.license_id IS NULL  THEN 'NA'  ELSE dl.license_id
  END license_id,
  CASE 
  WHEN dl.expiration_date IS NULL  THEN 'NA' 
  END expiration_date,
 ---- dl.country_region AS license_country_region,
  CASE 
  WHEN dl.country_region IS NULL  THEN 'NA' 
  END license_country_region,
 -- e.hire_date,
  CASE 
    WHEN e.hire_date IS NULL THEN 'NA'  ELSE TO_CHAR(CAST(e.hire_date AS DATE), 'MM/DD/YYYY')
  END hire_date,
--  e.manager_id
  CASE 
    WHEN e.manager_id IS NULL THEN 'NA' 
    WHEN e.manager_id = ' ' THEN 'NA' ELSE e.manager_id
  END manager_id

FROM 
  wk_silvercte s
LEFT JOIN  
  wk_addresses a ON s.employee_id = a.employee_id
LEFT JOIN    
  wk_divers_ethnic d ON s.employee_id = d.employee_id
LEFT JOIN  
  wk_ps_visa_pmt_data v ON s.employee_id = v.employee_id
LEFT JOIN  
  wk_pers_nid n ON s.employee_id = n.employee_id
LEFT JOIN   
  wk_drivers_lic dl ON s.employee_id = dl.employee_id
LEFT JOIN  
  wk_employment e ON s.employee_id = e.employee_id



