# 📊 SQL Advanced Module Task: Análise de Métricas de E-mail e Contas

Este projeto demonstra a consolidação de métricas de engajamento de e-mail e criação de contas em uma única query SQL, focada em resolver um desafio comum de data warehousing: unificar métricas que vêm de fontes com granularidades diferentes (Contas/Sessões vs. E-mails/Envios).

---

## 🎯 Problema de Negócio (Business Goal)

O objetivo principal era criar uma base de dados diária e não-duplicada que unisse dados de Contas Ativas e Eventos de E-mail (Enviados, Abertos, Visitados) para permitir análises de desempenho e rankings por dimensões importantes como País e Status da Conta.

## ⚙️ Tecnologias e Habilidades Técnicas

Este projeto utiliza BigQuery SQL e demonstra proficiência nas seguintes áreas:

* **SQL (BigQuery Dialect):** Foco em performance e lógica.
* **Common Table Expressions (CTEs):** Organização da lógica complexa em blocos claros (`account_daily`, `email_daily`, `base_metrics`).
* **Data Consolidation (`UNION ALL`):** Estratégia para consolidar métricas de diferentes granularidades sem duplicação de dados, garantindo a atomicidade das contagens.
* **Window Functions (`DENSE_RANK`, `SUM OVER PARTITION`):** Uso para calcular totais agregados por país e gerar rankings dinâmicos (Top 10) diretamente na query.
* **Tratamento de Datas:** Uso de `DATE_ADD` para ajustar a data de envio de e-mail corretamente, desacoplando-a da data da sessão.

## 📈 Resultados da Análise (Dashboard)

A query final extrai a base necessária para gerar um dashboard com os seguintes insights:

1.  **Top 10 Países:** Ranking por volume total de contas criadas e por volume total de e-mails enviados.
2.  **Dinâmica de Envio de E-mails:** Visualização da tendência de envio ao longo do tempo.

---

### Visualização

![Dashboard com o Ranking de Países, Criação de Contas e Dinâmica de Envio de E-mails](images/final_dashboard_metrics.png.png)
