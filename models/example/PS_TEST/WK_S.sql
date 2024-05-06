{{ config(materialized='table') }}

WITH 
  WK_SILVERCTE AS (
    SELECT DISTINCT 
        "EMPLID" AS Employee_ID,
        "COUNTRY_NM_FORMAT" AS COUNTRY_ISO_CODE,
        "FIRST_NAME" AS Legal_First_Name,
        "LAST_NAME" AS Legal_Last_Name,
        "MAR_STATUS" AS Marital_Status_Name,
        "MAR_STATUS_DT" AS Marital_Status_Date,
        "MILITARY_STATUS" AS Military_Status_Name,
        "BIRTHSTATE" AS Region_of_Birth,
        "BIRTHDATE" AS Date_of_Birth,
        "SEX" AS Gender_Description,
        "DISABLED" AS Disability_Name,
        "SMOKER" AS Uses_Tobacco,
        "POSTAL" AS Postal_code
    FROM
        SRIKAR.PS_PERSONAL_DATA
  ),
  WK_ADDRESSES AS (
    SELECT DISTINCT 
        "EMPLID" AS Employee_ID,
        "COUNTRY" AS Country_ISO_Code,
        "ADDRESS_TYPE" AS WORK_ADDRESS_DATA
    FROM
        SRIKAR.PS_ADDRESSES
    WHERE ADDRESS_TYPE IN ('MAIL', 'OTH', 'PERM', 'LEGL')
  ),
  WK_DIVERS_ETHNIC AS (
    SELECT DISTINCT 
        "EMPLID" AS Employee_ID
    FROM
        SRIKAR.PS_DIVERS_ETHNIC
  ),
  WK_PS_VISA_PMT_DATA AS (
    SELECT DISTINCT 
        "EMPLID" AS Employee_ID,
        "COUNTRY" AS Country_ISO_Code,
        "VISA_WRKPMT_NBR" AS Visa_ID,
        "VISA_PERMIT_TYPE" AS Visa_Type_Name 
    FROM
        SRIKAR.PS_VISA_PMT_DATA
  ),
  WK_PERS_NID AS (
    SELECT DISTINCT 
        "EMPLID" AS Employee_ID,
        "COUNTRY" AS Country_ISO_Code,
        "NATIONAL_ID" AS National_ID,
        "NATIONAL_ID_TYPE" AS National_ID_Type_Code 
    FROM
        SRIKAR.PS_PERS_NID
  ),
  WK_DRIVERS_LIC AS (
    SELECT DISTINCT 
        "EMPLID" AS Employee_ID,
        "DRIVERS_LIC_NBR" AS License_ID,
        "VALID_FROM_DT" AS Issued_DATE,
        "EXPIRATN_DT" AS Expiration_Date,
        "COUNTRY" AS Country_ISO_Code,
        "STATE" AS Country_Region,
        "ISSUED_BY_FRA" AS Authority_Name
    FROM
        SRIKAR.PS_DRIVERS_LIC
  ),
  WK_EMPLOYMENT AS (
    SELECT DISTINCT 
        "EMPLID" AS Employee_ID,
        "HIRE_DT" AS Hire_Date,
        "SUPERVISOR_ID" AS Manager_ID
    FROM
        SRIKAR.PS_EMPLOYMENT
  )
  
  
  
--- Combine all CTEs
SELECT DISTINCT
  S.Employee_ID, 
  CASE WHEN S.Country_ISO_Code = ' ' OR S.Country_ISO_Code = '001' THEN '1' ELSE S.Country_ISO_Code END AS Country_ISO_Code,
  S.Legal_First_Name,
  S.Legal_Last_Name,
CASE 
    WHEN S.MARITAL_STATUS_NAME IS NULL THEN 'NA'  ELSE S.MARITAL_STATUS_NAME
END MARITAL_STATUS_NAME,
  CASE 
    WHEN S.Marital_Status_Date IS NULL THEN 'NA'  
END Marital_Status_Date,
  S.Military_Status_Name,
  CASE 
    WHEN S.Region_of_Birth = ' ' THEN 'NA'  ELSE 'NA'
END Region_of_Birth,
 CASE 
    WHEN S.Date_of_Birth IS NULL THEN 'NA'
ELSE TO_CHAR(TRUNC(S.Date_of_Birth),'MM/DD/YYYY')
END Date_of_Birth,
  CASE 
    WHEN S.Gender_Description = 'M' THEN 'Male'
    WHEN S.Gender_Description = 'F' THEN 'Female'
    WHEN S.Gender_Description = 'U' THEN 'Undisclosed'
    WHEN S.Gender_Description IS NULL THEN 'NA'
END AS Gender_Description,
  S.Disability_Name,
  S.Uses_Tobacco,
  CASE 
  WHEN A.WORK_ADDRESS_DATA IS NULL  THEN 'NA'  ELSE A.WORK_ADDRESS_DATA
END WORK_ADDRESS_DATA,
  CASE 
  WHEN V.Visa_ID IS NULL  THEN 'NA'  ELSE V.Visa_ID
END Visa_ID,
CASE 
WHEN V.Visa_Type_Name IS NULL  THEN 'NA'  ELSE V.Visa_Type_Name
END Visa_Type_Name,
  CASE 
  	WHEN N.National_ID_Type_Code = 'PR' THEN 'Permanent Residence' ELSE 'NA'
  END National_ID_Type_Code,
  SUBSTR('650100104', 1, 4) || '-' || SUBSTR('650100104', 5, 3) || '-' || SUBSTR('650100104', 8) AS National_ID,
  CASE 
WHEN DL.License_ID IS NULL  THEN 'NA'  ELSE DL.License_ID
END License_ID,
  CASE 
WHEN DL.Expiration_Date IS NULL  THEN 'NA' 
END Expiration_Date,
 ---- DL.Country_Region AS License_Country_Region,
CASE 
WHEN DL.Country_Region IS NULL  THEN 'NA' 
END License_Country_Region,
 -- E.Hire_Date,
CASE 
    WHEN E.Hire_Date IS NULL THEN 'NA'  ELSE TO_CHAR(E.Hire_Date, 'MM/DD/YYYY')
END Hire_Date,
--  E.Manager_ID
CASE 
    WHEN E.Manager_ID IS NULL THEN 'NA' 
    WHEN E.Manager_ID = ' ' THEN 'NA' ELSE E.Manager_ID
END Manager_ID

FROM 
  WK_SILVERCTE S
LEFT JOIN  
  WK_ADDRESSES A ON S.Employee_ID = A.Employee_ID
LEFT JOIN    
  WK_DIVERS_ETHNIC D ON S.Employee_ID = D.Employee_ID
LEFT JOIN  
  WK_PS_VISA_PMT_DATA V ON S.Employee_ID = V.Employee_ID
LEFT JOIN  
  WK_PERS_NID N ON S.Employee_ID = N.Employee_ID
LEFT JOIN   
  WK_DRIVERS_LIC DL ON S.Employee_ID = DL.Employee_ID
LEFT JOIN  
  WK_EMPLOYMENT E ON S.Employee_ID = E.Employee_ID


