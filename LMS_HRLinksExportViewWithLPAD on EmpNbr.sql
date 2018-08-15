CREATE OR REPLACE FORCE VIEW LMS.V_LEARNING_MANAGEMENT_USERS
(STATUS, USERID, USERNAME, FIRSTNAME, LASTNAME,
 MI, GENDER, EMAIL, MANAGER, HR,
 DIVISION, DEPARTMENT, LOCATION, JOBCODE, TIMEZONE,
 HIREDATE, EMPID, TITLE, BIZ_PHONE, FAX,
 ADDR1, ADDR2, CITY, STATE, ZIP,
 COUNTRY, REVIEW_FREQ, LAST_REVIEW_DATE, CUSTOM01, CUSTOM02,
 CUSTOM03, CUSTOM04, CUSTOM05, CUSTOM06, CUSTOM07,
 CUSTOM08, CUSTOM09, CUSTOM10, CUSTOM11, CUSTOM12,
 CUSTOM13, CUSTOM14, CUSTOM15, DEFAULT_LOCALE, LOGIN_METHOD)
BEQUEATH DEFINER
AS
SELECT LMSUsers.STATUS,
           LMSUsers.USERID,
           LMSUsers.USERNAME,
           LMSUsers.FIRSTNAME,
           LMSUsers.LASTNAME,
           LMSUsers.MI,
           LMSUsers.GENDER,
           LMSUsers.EMAIL,
           CASE
               WHEN    hrmgr.InactiveTimestamp IS NOT NULL
                    OR admgr.InactiveTimestamp IS NOT NULL
               THEN
                   'NO_MANAGER'
               WHEN admgr.UserPrincipalName IS NULL
               THEN
                   'NO_MANAGER'
               WHEN SUBSTR (admgr.UserPrincipalName, -7) = 'gsa.gov'
               THEN
                   SUBSTR (admgr.UserPrincipalName,
                           1,
                           (INSTR (admgr.UserPrincipalName, '@') - 1))
               WHEN SUBSTR (admgr.UserPrincipalName, -7) <> 'gsa.gov'
               THEN
                   admgr.UserPrincipalName
               WHEN     hrmgr.InactiveTimestamp IS NULL
                    AND admgr.InactiveTimestamp IS NULL
               THEN
                   NVL (
                       SUBSTR (admgr.UserPrincipalName,
                               1,
                               (INSTR (admgr.UserPrincipalName, '@') - 1)),
                       'NO_MANAGER')
               ELSE
                   'NO_MANAGER'
           END
               AS MANAGER,
           LMSUsers.HR,
           NVL (sso.SSOAbbreviation, 'N/A')
               AS DIVISION,
           LMSUsers.DEPARTMENT,
           LMSUsers.LOCATION,
           LMSUsers.JOBCODE,
           LMSUsers.TIMEZONE,
           LMSUsers.HIREDATE,
           LMSUsers.EMPID,
           LMSUsers.TITLE,
           LMSUsers.BIZ_PHONE,
           LMSUsers.FAX,
           LMSUsers.ADDR1,
           LMSUsers.ADDR2,
           LMSUsers.CITY,
           LMSUsers.STATE,
           LMSUsers.ZIP,
           LMSUsers.COUNTRY,
           LMSUsers.REVIEW_FREQ,
           LMSUsers.LAST_REVIEW_DATE,
           LMSUsers.CUSTOM01,
           LMSUsers.CUSTOM02,
           LMSUsers.CUSTOM03,
           LMSUsers.CUSTOM04,
           LMSUsers.CUSTOM05,
           LMSUsers.CUSTOM06,
           LMSUsers.CUSTOM07,
           LMSUsers.CUSTOM08,
           LMSUsers.CUSTOM09,
           LMSUsers.CUSTOM10,
           LMSUsers.CUSTOM11,
           LMSUsers.CUSTOM12,
           LMSUsers.CUSTOM13,
           LMSUsers.CUSTOM14,
           LMSUsers.CUSTOM15,
           LMSUsers.DEFAULT_LOCALE,
           LMSUsers.LOGIN_METHOD
      FROM (SELECT CASE
                       WHEN COALESCE (hr.InactiveTimestamp,
                                      ad.InactiveTimestamp)
                                IS NULL
                       THEN
                           'Active'
                       WHEN     hr.InactiveTimestamp IS NOT NULL
                            AND ad.InactiveTimestamp IS NULL
                       THEN
                           'Active'
                       WHEN COALESCE (hr.InactiveTimestamp,
                                      ad.InactiveTimestamp)
                                IS NOT NULL
                       THEN
                           'Inactive'
                   END
                       AS STATUS,
                   CASE
                       WHEN SUBSTR (ad.UserPrincipalName, -7) = 'gsa.gov'
                       THEN
                           SUBSTR (ad.UserPrincipalName, 1, 10)
                       WHEN SUBSTR (ad.UserPrincipalName, -7) <> 'gsa.gov'
                       THEN
                           ad.UserPrincipalName
                   END
                       AS USERID,
                   LOWER (COALESCE (hr.Email, ad.EmailAddress))
                       AS USERNAME,
                   COALESCE (hr.FirstName, ad.FirstName)
                       AS FIRSTNAME,
                   COALESCE (hr.LastName, ad.LastName)
                       AS LASTNAME,
                   COALESCE (hr.MiddleName, ad.MiddleInitial)
                       AS MI,
                   NULL
                       AS GENDER,
                   LOWER (COALESCE (hr.Email, ad.EmailAddress))
                       AS EMAIL,
                   NVL (hr.REPORTS_TO_EMPLID, 'NO_MANAGER')
                       AS MANAGER_EMPID,
                   'NO_HR'
                       AS HR,
                   NVL (hr.AgencySubElementCode, 'N/A')
                       AS DIVISION,
                   CASE
                       WHEN hr.DEPTID IS NOT NULL
                       THEN
                           hr.DEPTID
                       -- JJM 2017-10-18 TASK 84516 Strip -C from end of Contractor Office Symbols for matching
                       WHEN SUBSTR (ad.OfficeSymbol, -2, 2) = '-C'
                       THEN
                           SUBSTR (ad.OfficeSymbol,
                                   1,
                                   (LENGTH (ad.OfficeSymbol) - 2))
                       WHEN ad.OfficeSymbol IS NOT NULL
                       THEN
                           ad.OfficeSymbol
                       ELSE
                           'NO_DEPARTMENT'
                   END
                       AS DEPARTMENT,
                   hr.DutyStationCode
                       AS LOCATION,
                   hr.OccupationalSeries
                       AS JOBCODE,
                   'US/Eastern'
                       AS TIMEZONE,
                   CASE
                       WHEN hr.REHIREDATE IS NOT NULL
                       THEN
                           TO_CHAR (CAST (hr.REHIREDATE AS DATE),
                                    'YYYY-MM-DD')
                       ELSE
                           NULL
                   END
                       AS HIREDATE,
                   hr.EMPLOYEENUMBER
                       AS EMPID,
                   COALESCE (hr.PositionTitle, ad.PositionTitle)
                       AS TITLE,
                   hr.WorkPhoneNumber
                       AS BIZ_PHONE,
                   NULL
                       AS FAX,
                   hr.WorkAddressLine1
                       AS ADDR1,
                   hr.WorkAddressLine2
                       AS ADDR2,
                   hr.WorkAddressCity
                       AS CITY,
                   hr.WorkAddressState
                       AS STATE,
                   hr.WorkAddressZip
                       AS ZIP,
                   NULL
                       AS COUNTRY,
                   NULL
                       AS REVIEW_FREQ,
                   NULL
                       AS LAST_REVIEW_DATE,
                   hr.OccupationalSeriesDesc
                       AS CUSTOM01,
                   hr.EducationLevel
                       AS CUSTOM02,
                   CASE
                       WHEN SUBSTR (hr.Email, -9) = 'gsaig.gov'
                       THEN
                           'PWD'
                       WHEN SUBSTR (ad.EmailAddress, -9) = 'gsaig.gov'
                       THEN
                           'PWD'
                       WHEN INSTR (ad.EmailAddress, 'gsaig.alias') <> 0
                       THEN
                           'PWD'
                       ELSE
                           'SSO'
                   END
                       AS CUSTOM03,
                   CASE
                       WHEN hr.SupervisorCode = '2' THEN 'Supervisory'
                       WHEN hr.SupervisorCode = '4' THEN 'Supervisory'
                       WHEN hr.SupervisorCode = '5' THEN 'Employee'
                       WHEN hr.SupervisorCode = '6' THEN 'Employee'
                       WHEN hr.SupervisorCode = '7' THEN 'Employee'
                       WHEN ad.Affiliation = 'Government' THEN 'Employee'
                       ELSE 'Contractor'
                   END
                       AS CUSTOM04,
                   hr.Grade
                       AS CUSTOM05,
                   hr.PayPlan
                       AS CUSTOM06,
                   hr.StepOrRate
                       AS CUSTOM07,
                   ad.Region
                       AS CUSTOM08,
                   TO_CHAR (SYSDATE + 7, 'YYYY-MM-DD')
                       AS CUSTOM09,
                   TO_CHAR (CAST (hr.EntryOnPosition AS DATE), 'YYYY-MM-DD')
                       AS CUSTOM10,
                   hr.EMPLOYEENUMBER
                       AS CUSTOM11,
                   'GSA'
                       AS CUSTOM12,
                   TO_CHAR (CAST (hr.SUPVEFFDATE AS DATE), 'YYYY-MM-DD')
                       AS CUSTOM13,
                   NULL
                       AS CUSTOM14,
                   NULL
                       AS CUSTOM15,
                   'en_US'
                       AS DEFAULT_LOCALE,
                   CASE
                       WHEN SUBSTR (hr.Email, -9) = 'gsaig.gov'
                       THEN
                           'PWD'
                       WHEN SUBSTR (ad.EmailAddress, -9) = 'gsaig.gov'
                       THEN
                           'PWD'
                       WHEN INSTR (ad.EmailAddress, 'gsaig.alias') <> 0
                       THEN
                           'PWD'
                       ELSE
                           'SSO'
                   END
                       AS LOGIN_METHOD
              FROM LMS.ActiveDirectoryUsers  ad
                   LEFT OUTER JOIN LMS.HR_LMS_USERS hr
--                     2018-07-12 - JJM
--                     Add LPAD to AD Emp ID since OIG excludes leading zeros
                       ON LPAD(ad.CHRISEmployeeID,8,'0') = hr.EmployeeNumber
             WHERE      (TO_DATE (SYSDATE, 'YYYY-MM-DD'))
                      - (TO_DATE (hr.InactiveTimestamp, 'YYYY-MM-DD')) <=
                      '5'
                   OR   (TO_DATE (SYSDATE, 'YYYY-MM-DD'))
                      - (TO_DATE (ad.InactiveTimestamp, 'YYYY-MM-DD')) <=
                      '5'
                   OR ad.InactiveTimestamp IS NULL) LMSUSERS
           LEFT OUTER JOIN LMS.HR_LMS_USERS hrmgr
               ON hrmgr.EMPLOYEENUMBER = LMSUsers.MANAGER_EMPID
           LEFT OUTER JOIN LMS.ACTIVEDIRECTORYUSERS admgr
               ON admgr.CHRISEmployeeID = hrmgr.EmployeeNumber
           LEFT OUTER JOIN LMS.SsoLkup sso
               ON sso.PosOrgAgySubelementCode = LMSUsers.DIVISION
;