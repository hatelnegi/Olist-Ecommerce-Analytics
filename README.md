# Olist-Ecommerce-Analytics
# 📦 Olist Brazilian E-Commerce Analytics
### SQL | Power BI | Python | Machine Learning | Streamlit

An end-to-end data analytics and machine learning project exploring Brazilian e-commerce data to understand sales performance, customer behavior, product categories, delivery operations, and customer satisfaction.

The project combines SQL-based data analysis, interactive Power BI dashboards, Python-based analytics, and a machine learning application that estimates late-delivery risk.

---

## 🌐 Project Links

- **Interactive Machine Learning Application:** [Olist Late Delivery Risk Prediction](https://olist-late-delivery-prediction.streamlit.app/)
- **GitHub Repository:** [Olist Late Delivery Risk Prediction](https://github.com/hatelnegi/olist-late-delivery-prediction)
- **Power BI Report:** A PDF preview and dashboard screenshots will be added to this repository.

> Note: The Streamlit application is a separate deployed component of this project. The Power BI report is currently shared through portfolio materials rather than a publicly hosted interactive report.

---

## 📌 Project Overview

E-commerce businesses generate large amounts of data through orders, payments, products, sellers, customers, reviews, and delivery operations.

However, raw data alone does not explain which product categories generate the most revenue, how customers behave, or how delivery delays affect customer satisfaction.

This project uses the Olist Brazilian E-Commerce dataset to investigate these business questions and transform raw data into actionable insights.

### 🎯 Project Objectives

- Analyze overall sales and order performance.
- Identify high-performing product categories.
- Understand customer purchasing behavior and repeat purchases.
- Examine payment methods and transaction patterns.
- Analyze seller and customer geographical distribution.
- Evaluate delivery performance and customer satisfaction.
- Investigate factors associated with late deliveries.
- Build an interactive application to demonstrate late-delivery risk prediction.

---

## 🗂️ Dataset

**Source:** Olist Brazilian E-Commerce Public Dataset

The dataset contains anonymized information about orders placed through a Brazilian e-commerce marketplace.

### Main Data Tables

| Table | Description |
|---|---|
| Customers | Customer identifiers and geographical information |
| Orders | Order status and purchase, approval, and delivery timestamps |
| Order Items | Products purchased, sellers, prices, and freight values |
| Order Payments | Payment methods and payment amounts |
| Order Reviews | Customer ratings and review information |
| Products | Product attributes and category information |
| Sellers | Seller identifiers and locations |
| Geolocation | Geographical coordinates associated with Brazilian postal codes |
| Category Translation | Portuguese product category names and their English translations |

The project uses approximately 100,000 orders and multiple related tables.

**Data preparation considerations:**
- Checking missing values and duplicate records.
- Validating identifiers and table relationships.
- Examining date and numeric data types.
- Avoiding duplicate inflation when joining tables.
- Handling repeated review identifiers appropriately.
- Preventing inaccurate geographical aggregation caused by duplicate coordinates.

---

## 🛠️ Technology Stack

| Tool | Purpose |
|---|---|
| SQL Server | Data exploration, cleaning, joins, aggregations, and business analysis |
| SQL Server Management Studio | Writing and executing SQL queries |
| Microsoft Power BI | Interactive dashboards and business reporting |
| Python | Data cleaning, exploratory analysis, and machine learning |
| Pandas | Data manipulation and analysis |
| NumPy | Numerical operations |
| Scikit-learn | Machine learning and model evaluation |
| Joblib | Saving and loading the trained model |
| Streamlit | Deploying the interactive prediction application |
| GitHub | Version control and project documentation |

---

# 🧹 1. SQL Data Analysis

SQL Server was used to explore the dataset, validate data quality, connect related tables, and answer business questions.

### Key Activities

- Examined row counts and table structures.
- Checked duplicate records and identifier uniqueness.
- Investigated missing values and data quality issues.
- Joined orders with customer, payment, product, seller, and review information.
- Calculated revenue, order counts, and average order value.
- Analyzed product categories and payment methods.
- Compared delivery performance with customer review scores.
- Created analytical outputs for Power BI reporting.

### 📊 Selected SQL Findings

| Metric | Result |
|---|---:|
| Total orders in the orders table | 99,441 |
| Delivered orders | 96,478 |
| Delivery rate | 97.02% |
| Item revenue | R$13,591,643.70 |
| Average order value | R$137.75 |
| Repeat-customer rate in the analyzed customer population | 3.12% |

**Important metric definitions:**
- Item revenue is calculated from order-item prices and does not necessarily represent total customer spending including freight.
- The repeat-customer rate uses the denominator from the original SQL analysis; its precise definition should accompany the metric when used in formal reporting.
- Delivery rate is based on the delivered-order count divided by the total order count in the analyzed dataset.

### 🛍️ Top Product Categories by Item Revenue

| Product Category | Item Revenue |
|---|---:|
| Health & Beauty | R$1,258,681.34 |
| Watches & Gifts | R$1,205,005.68 |
| Bed, Bath & Table | R$1,036,988.68 |
| Sports & Leisure | R$988,048.97 |
| Computers & Accessories | R$911,954.32 |

These results highlight categories that contributed substantially to item revenue in the analyzed dataset.

### 💳 Payment Method Analysis

| Payment Method | Recorded Payment Value |
|---|---:|
| Credit Card | R$12,542,084.19 |
| Boleto | R$2,869,361.27 |
| Voucher | R$379,436.87 |
| Debit Card | R$217,989.79 |

Payment records may include multiple transactions for a single order. Therefore, payment-method totals should be interpreted using the relevant transaction-level aggregation.

### 🚚 Delivery Performance and Customer Satisfaction

The SQL analysis found a substantial difference between review scores for late deliveries and orders delivered on time or early.

| Delivery Group | Average Review Score |
|---|---:|
| Late deliveries | 2.57 |
| On-time or early deliveries | 4.29 |

This association suggests that delivery performance is an important area to investigate when studying customer satisfaction.

It does not, by itself, establish that delivery delays are the sole cause of lower ratings.

---

# 📊 2. Power BI Dashboard

Microsoft Power BI was used to transform analytical results into visual reports designed for business users.

### Dashboard Areas

**1. Sales & Order Performance**
- Total revenue and order KPIs.
- Monthly order activity.
- Revenue trends.
- Average order value.
- Order performance over time.

**2. Product Category & Seller Analysis**
- Revenue by product category.
- Category performance comparisons.
- Seller performance.
- Product and seller contribution to sales.

**3. Customer & Geographical Analysis**
- Customer distribution.
- Customer activity and revenue comparisons.
- Geographical coverage.
- Customer-base analysis.

**4. Delivery & Customer Satisfaction**
- Delivery performance indicators.
- Late versus on-time delivery analysis.
- Customer review score comparisons.
- Relationship between logistics performance and customer experience.

### Dashboard Features

- KPI cards.
- Time-based charts.
- Category and seller comparisons.
- Interactive slicers and filters.
- Business-focused visual layouts.
- Report pages designed to support exploratory analysis.

### Business Value

The dashboard helps stakeholders investigate where revenue is generated, which categories perform well, how customer activity changes over time, and where delivery performance may require further attention.

**Dashboard Preview:**  
Add your exported report PDF and screenshots to this repository when they are ready.

---

# 🐍 3. Python Analysis

Python supports data preparation, analytical validation, and the machine learning workflow.

### Main Activities

- Loaded and inspected the dataset.
- Checked data types and missing values.
- Investigated duplicates and data-quality issues.
- Prepared features for machine learning.
- Evaluated model predictions using classification metrics.
- Saved the trained model for use in the Streamlit application.

### Libraries

- Pandas
- NumPy
- Scikit-learn
- Joblib

The Python workflow complements SQL and Power BI by supporting more advanced statistical and predictive analysis.

---

# 🤖 4. Machine Learning: Late Delivery Risk Prediction

A machine learning model was developed to estimate the probability that an order will be delivered late.

### Business Problem

Late deliveries can negatively affect customer experience and operational performance.

The objective is to explore whether information available about an order can help identify patterns associated with late delivery.

### Model Inputs

The Streamlit application accepts features such as:

- Purchase month.
- Purchase day of the week.
- Purchase hour.
- Promised delivery duration.
- Number of items.
- Total item price.
- Total freight value.
- Number of unique sellers.
- Number of unique products.
- Main product category.
- Main seller state.

### Model Evaluation

The recorded model evaluation produced the following results:

| Metric | Result |
|---|---:|
| Accuracy | 75.56% |
| Precision | 10.41% |
| Recall | 35.42% |
| F1-score | 16.09% |
| ROC-AUC | 0.6432 |
| Classification threshold | 0.40 |

### Interpretation

The model demonstrates a machine learning workflow, but its performance has important limitations.

- Accuracy alone does not adequately describe performance when late deliveries are relatively uncommon.
- Low precision means many orders flagged as late-delivery risks are not late according to the evaluation labels.
- Recall indicates that the model identifies only a portion of the late-delivery cases.
- The ROC-AUC suggests limited ability to distinguish between the two classes.

The model should be treated as an educational demonstration rather than a production-ready operational forecasting system.

### Important Limitation

The current model was trained on delivered orders and has not been validated for operational predictions on orders currently in transit.

Consequently, the application should not be used to make consequential decisions about live orders without further validation, appropriate feature-timing checks, and testing on suitable data.

---

# 🌐 5. Streamlit Web Application

The trained model is integrated into a Streamlit application that lets users enter order information and receive a predicted late-delivery probability.

### Live Demo

**[Open the Olist Late Delivery Risk Prediction App](https://olist-late-delivery-prediction.streamlit.app/)**

### Application Features

- Interactive order input form.
- Model-based probability estimation.
- Classification using a configurable threshold.
- Visual probability indicator.
- Prediction result and explanatory warnings.
- Browser-based access to the deployed application.

### How It Works

1. The user enters order details.
2. The application prepares the input features.
3. The saved machine learning model calculates the estimated probability of late delivery.
4. The probability is compared with the configured threshold.
5. The application displays the prediction and a probability indicator.

The output is a model estimate, not a guarantee of delivery performance.

---

# 💡 6. Key Business Insights

The analyses conducted so far highlight several areas of business interest:

1. **Sales concentration:** A small group of product categories contributes substantially to item revenue.
2. **Customer retention:** The repeat-customer rate in the analyzed population is relatively low, making customer retention worth investigating.
3. **Payment preferences:** Credit cards account for the largest recorded payment value among the payment methods analyzed.
4. **Delivery and satisfaction:** Late deliveries are associated with substantially lower average review scores.
5. **Predictive limitations:** The late-delivery model requires improvement before it could support reliable operational decisions.

These findings can help guide further investigation into customer retention, category performance, delivery reliability, and customer experience.

---

# 📁 7. Project Structure

The repository can be organized as follows:

```text
olist-ecommerce-analytics/
│
├── README.md
│
├── sql/
│   ├── data_quality_checks.sql
│   ├── data_cleaning.sql
│   └── business_analysis.sql
│
├── python/
│   ├── exploratory_data_analysis.ipynb
│   └── late_delivery_model.ipynb
│
├── powerbi/
│   ├── Olist_Ecommerce_Analytics.pdf
│   └── dashboard_screenshots/
│
├── streamlit-app/
│   ├── app.py
│   ├── requirements.txt
│   └── olist_late_delivery_model_final.joblib
│
└── docs/
    └── project_documentation.md
```

This is a suggested structure. Include only the folders and files that actually exist in your repository.

---

# 🚀 8. How to Run the Streamlit Application Locally

### Prerequisites

- Python installed.
- Git installed.
- The application source code and trained model file.

### Installation

Clone the application repository:

```bash
git clone https://github.com/hatelnegi/olist-late-delivery-prediction.git
```

Move into the project directory:

```bash
cd olist-late-delivery-prediction
```

Install the required libraries:

```bash
pip install -r requirements.txt
```

Run the application:

```bash
streamlit run app.py
```

The application will provide a local address that you can open in your browser.

**Security note:** If the application uses login credentials, configure them through Streamlit Secrets or an appropriate local secrets configuration. Never commit passwords or private credentials to GitHub.

---

# 📈 9. Future Improvements

Potential next steps include:

- Improving the predictive model through feature engineering and model comparison.
- Investigating class imbalance and threshold selection.
- Evaluating precision-recall trade-offs.
- Validating predictions on data appropriate for real-time forecasting.
- Adding automated model evaluation and monitoring.
- Expanding customer retention and cohort analysis.
- Improving geographical analysis while controlling for duplicate location records.
- Adding more detailed dashboard documentation and screenshots.
- Publishing an interactive Power BI report through an eligible hosting method.

---

# 👩‍💻 About the Author

**Hatel Negi**

Aspiring Data Analyst interested in SQL, Python, Power BI, business intelligence, and machine learning.

This project demonstrates my approach to exploring real-world datasets, investigating business questions, developing analytical reports, and communicating data-driven findings.

### Connect

- **GitHub:** [hatelnegi](https://github.com/hatelnegi)
- **LinkedIn:** [Hatel Negi](https://www.linkedin.com/in/hatel-negi/)

---

## 📌 Project Disclaimer

This project is intended for educational and portfolio purposes.

The findings reflect analysis of the selected public dataset. Results may vary depending on data preparation, aggregation methods, and analytical assumptions.

The late-delivery prediction model is experimental and is not validated for production use.

---

⭐ If you find this project interesting, feel free to explore the repository and the deployed application.
