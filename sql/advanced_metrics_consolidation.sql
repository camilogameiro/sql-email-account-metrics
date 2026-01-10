-- =========================================================
-- SQL Advanced Module Task
-- Consolidação correta de métricas de CONTA e E-MAIL
-- Separando lógicas de data para evitar duplicações
-- =========================================================




WITH account_daily AS (
  -- ---------------------------------------------------------
  -- Métricas de CONTA por data da sessão
  -- (representa contas ativas/criadas por dia)
  -- ---------------------------------------------------------
  SELECT
    s.date AS date,
    sp.country,
    ac.send_interval,
    ac.is_verified,
    ac.is_unsubscribed,


    COUNT(DISTINCT ac.id) AS account_cnt,
    0 AS sent_msg,
    0 AS open_msg,
    0 AS visit_msg


  FROM `data-analytics-mate.DA.account` ac


  JOIN `data-analytics-mate.DA.account_session` acs
    ON ac.id = acs.account_id


  JOIN `data-analytics-mate.DA.session` s
    ON acs.ga_session_id = s.ga_session_id


  JOIN `data-analytics-mate.DA.session_params` sp
    ON s.ga_session_id = sp.ga_session_id


  GROUP BY
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed
),




email_daily AS (
  -- ---------------------------------------------------------
  -- Métricas de E-MAIL por data real de envio
  -- (evita replicar e-mails em múltiplas datas de sessão)
  -- ---------------------------------------------------------
  SELECT
    DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date,
    sp.country,
    ac.send_interval,
    ac.is_verified,
    ac.is_unsubscribed,


    0 AS account_cnt,
    COUNT(DISTINCT es.id_message) AS sent_msg,
    COUNT(DISTINCT eo.id_message) AS open_msg,
    COUNT(DISTINCT ev.id_message) AS visit_msg


  FROM `data-analytics-mate.DA.email_sent` es


  JOIN `data-analytics-mate.DA.account` ac
    ON es.id_account = ac.id


  JOIN `data-analytics-mate.DA.account_session` acs
    ON es.id_account = acs.account_id


  JOIN `data-analytics-mate.DA.session` s
    ON acs.ga_session_id = s.ga_session_id


  JOIN `data-analytics-mate.DA.session_params` sp
    ON s.ga_session_id = sp.ga_session_id


  LEFT JOIN `data-analytics-mate.DA.email_open` eo
    ON es.id_message = eo.id_message


  LEFT JOIN `data-analytics-mate.DA.email_visit` ev
    ON es.id_message = ev.id_message


  GROUP BY
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed
),




base_metrics AS (
  -- ---------------------------------------------------------
  -- Consolidação das métricas de CONTA + E-MAIL
  -- UNION ALL evita duplicações e preserva granularidade
  -- ---------------------------------------------------------
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,


    SUM(account_cnt) AS account_cnt,
    SUM(sent_msg) AS sent_msg,
    SUM(open_msg) AS open_msg,
    SUM(visit_msg) AS visit_msg


  FROM (
    SELECT * FROM account_daily
    UNION ALL
    SELECT * FROM email_daily
  )
  GROUP BY
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed
),




country_totals AS (
  -- ---------------------------------------------------------
  -- Totais agregados por país (window functions)
  -- ---------------------------------------------------------
  SELECT
    *,
    SUM(account_cnt) OVER (PARTITION BY country) AS total_country_account_cnt,
    SUM(sent_msg) OVER (PARTITION BY country) AS total_country_sent_cnt
  FROM base_metrics
),




ranked_countries AS (
  -- ---------------------------------------------------------
  -- Ranking dos países por contas e envios
  -- ---------------------------------------------------------
  SELECT
    *,
    DENSE_RANK() OVER (ORDER BY total_country_account_cnt DESC)
      AS rank_total_country_account_cnt,
    DENSE_RANK() OVER (ORDER BY total_country_sent_cnt DESC)
      AS rank_total_country_sent_cnt
  FROM country_totals
)




-- -----------------------------------------------------------
-- Resultado final: TOP 10 países por contas OU envios
-- -----------------------------------------------------------
SELECT *
FROM ranked_countries
WHERE
  rank_total_country_account_cnt <= 10
  OR rank_total_country_sent_cnt <= 10
ORDER BY
  rank_total_country_sent_cnt,
  rank_total_country_account_cnt,
  date;
