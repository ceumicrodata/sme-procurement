FROM 'data/derived/sme_by_country_CPV.csv'
SELECT
    country_code,
    SUM(total_value_sme) / (SUM(total_value_large) + SUM(total_value_sme)) AS share_value_sme,
    SUM(n_contracts_sme) / (SUM(n_contracts_large) + SUM(n_contracts_sme)) AS share_contracts_sme,    
    SUM(n_contractors_sme) / (SUM(n_contractors_large) + SUM(n_contractors_sme)) AS share_contractors_sme
GROUP BY
    country_code
ORDER BY
    share_value_sme DESC;
