# 🦠 COVID-19 Global Data Analysis with SQL

This project focuses on the exploratory analysis of global COVID-19 data using SQL. It covers key metrics like deaths, infections, population impact, and vaccination progress, providing insights into the pandemic's trends and trajectory.

---

## 🌍 Project Overview

- **Title**: COVID-19 SQL Data Analysis
- **Tools Used**: SQL (MySQL / PostgreSQL), Excel
- **Focus Areas**: Data cleaning, transformation, joining, and exploratory analysis
- **Datasets**:
  - `CovidDeaths.xlsx` – daily global death and case data
  - `CovidVaccinations.xlsx` – vaccine administration statistics

---

## 📁 Project Structure

├── Covid-19.sql # SQL queries for cleaning and analysis 

├── CovidDeaths.xlsx # Deaths and case data 

├── CovidVaccinations.xlsx # Vaccination data 

├── README.md # Project documentation

yaml
Copy
Edit

---

## 🧾 Dataset Details

### 1. `CovidDeaths.xlsx`
- `location`, `continent`, `date`
- `population`, `total_cases`, `new_cases`, `total_deaths`, `new_deaths`
- Case fatality rates, case growth trends

### 2. `CovidVaccinations.xlsx`
- `location`, `date`
- `total_vaccinations`, `people_vaccinated`, `people_fully_vaccinated`
- `new_vaccinations`, `total_boosters`

---

## 🧹 Data Cleaning Highlights

Performed in SQL script (`Covid-19.sql`):
- Handled null and inconsistent values
- Converted date formats
- Filtered invalid data (e.g., non-country records like 'World')
- Joined both datasets using `location` and `date` for combined analysis

---

## 📌 Questions Explored

- What percentage of the population has been infected per country?
- Which countries have the highest death rates?
- What are the case fatality ratios per continent?
- How does vaccination progress compare to population size?
- What are the trends over time in cases and vaccinations?

---

## 📈 Sample SQL Query

```sql
-- Countries with highest death count per population
SELECT location, MAX(total_deaths) AS highest_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_deaths DESC;
📊 Key Insights
United States, Brazil, and India had the highest reported deaths.

Several countries reached over 70% vaccination coverage by 2022.

Africa had lower vaccination rates and higher underreporting trends.

There's a visible gap in vaccine equity between continents.

🧰 Tools & Skills Demonstrated
SQL joins, window functions, and aggregates

Temporal data analysis

Population-normalized metrics

Data storytelling through query results

🚀 How to Run
Clone the repo:

bash
Copy
Edit
git clone https://github.com/yourusername/covid19-sql-analysis.git
Import Excel data into your SQL database or data warehouse.

Run Covid-19.sql in your SQL IDE.

Modify queries to explore different patterns or time periods.

👤 Author
Anyakwu Chukwuemeka Isaac
📫 LinkedIn | 📧 Email

📝 License
This project is intended for educational and portfolio use.
© 2025 Great Learning – All rights reserved.

yaml
Copy
Edit
