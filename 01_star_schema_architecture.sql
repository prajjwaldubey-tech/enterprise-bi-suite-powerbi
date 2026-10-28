# Enterprise Business Intelligence Suite (Multi-Region Sales Performance)

## Executive Dashboard
![Executive Dashboard](DA-01_Executive_Dashboard.png)

## Project Overview
An end-to-end Power BI reporting suite built to monitor $118.73M in multi-region sales performance across North American and European markets (USA, Canada, France, Germany, Mexico). The project eliminates legacy data silos through dimensional modeling and automated DAX analytics.

## Technical Architecture & Modeling
- **Dimensional Model:** Kimball Star Schema connecting central transactional logs (`FactResellerSales`) with conformed dimension tables (`DimGeography`, `DimDate`).
- **ETL Transformation:** Power Query pipelines handling schema normalization, type coercion, and currency standardization.
- **DAX Metrics Engine:** Explicit DAX calculations for Gross Revenue, Net Margin, and Monthly Trend run-rates.

## Key Commercial Insights
- **Top Regional Contributors:** The United States drove 21.08% ($25.03M) of total revenue, closely followed by Canada (20.96%) and France (20.51%).
- **Seasonality Peaks:** Sales remained steady through Q1–Q3 ($6M–$9M/month) with an aggressive peak in October exceeding $21.8M.

## Repository Contents
- `DA-01_Executive_Dashboard.png`: Clean executive dashboard visual proof.
- `DA-01_Enterprise_BI_Suite.pbix`: Full interactive Power BI Desktop workbook.
- `01_star_schema_architecture.sql`: Dimensional Kimball schema DDL script.