.mode csv
WITH ted AS (
    FROM 
        'data/raw/export_CAN_2023.csv'
    SELECT
        ISO_COUNTRY_CODE AS country_code,
        CPV,
        AWARD_VALUE_EURO AS value,
        LENGTH(B_CONTRACTOR_SME) - LENGTH(REPLACE(B_CONTRACTOR_SME, 'Y', '')) AS n_sme,
        LENGTH(B_CONTRACTOR_SME) - LENGTH(REPLACE(B_CONTRACTOR_SME, 'N', '')) AS n_large
    WHERE
        B_MULTIPLE_COUNTRY = 'N'
),
sme AS (
    SELECT
        country_code,
        CPV,
        SUM(value) AS total_value_sme,
        COUNT(value) AS n_contracts_sme,
        SUM(n_sme + n_large) AS n_contractors_sme,
    FROM
        ted
    WHERE
        n_sme > 0
    GROUP BY
        country_code,
        CPV
    ORDER BY
        country_code,
        CPV
),
large AS (
    SELECT
        country_code,
        CPV,
        SUM(value) AS total_value_large,
        COUNT(value) AS n_contracts_large,
        SUM(n_sme + n_large) AS n_contractors_large,
    FROM
        ted
    WHERE
        n_large > 0
    GROUP BY
        country_code,
        CPV
    ORDER BY
        country_code,
        CPV
)
SELECT
    COALESCE(sme.country_code, large.country_code) AS country_code,
    COALESCE(sme.CPV, large.CPV) AS CPV,
    COALESCE(sme.total_value_sme, 0) AS total_value_sme,
    COALESCE(sme.n_contracts_sme, 0) AS n_contracts_sme,
    COALESCE(sme.n_contractors_sme, 0) AS n_contractors_sme,
    COALESCE(large.total_value_large, 0) AS total_value_large,
    COALESCE(large.n_contracts_large, 0) AS n_contracts_large,
    COALESCE(large.n_contractors_large, 0) AS n_contractors_large
FROM
    sme
FULL OUTER JOIN
    large
ON
    sme.country_code = large.country_code
    AND sme.CPV = large.CPV;

