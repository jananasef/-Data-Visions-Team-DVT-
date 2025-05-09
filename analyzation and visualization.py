import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

df = pd.read_csv('dataaa.csv')
print(df.head(10))
print(df.describe())
print(df.info())
print(df.isnull().sum())
print(df.duplicated())
print(df.drop_duplicates())
print(df.columns.tolist())


df[' total_sales '] = df[' total_sales '].replace(r'[\$,]', '', regex=True)
df[' total_sales '] = pd.to_numeric(df[' total_sales '], errors='coerce')


promo_sales = df[df['promotion_effectiveness'] == 'High'][' total_sales ']
non_promo_sales = df[df['promotion_effectiveness'] != 'High'][' total_sales ']
print(f'Average Sales during Promotions: {promo_sales.mean()}')
print(f'Average Sales without Promotions: {non_promo_sales.mean()}')





plt.figure(figsize=(10, 10))
sns.histplot(df[' total_sales '].head(10), bins=10, kde=True)
plt.title('Distribution of Total Sales')
plt.xlabel('Total Sales')
plt.ylabel('Frequency')
plt.show()




top_product_category = df.groupby('product_category')[' total_sales '].sum().sort_values(ascending=False)
top_product_category.head(10).plot(kind='bar')
plt.title('Product categories ranked')
plt.xlabel('Product Category')
plt.ylabel('Total Sales')
plt.show()





sales_by_season = df.groupby('season')[' total_sales '].sum()
sales_by_season.plot(kind='bar')
plt.title('Total Sales by Season')
plt.xlabel('Season')
plt.ylabel('Total Sales')
plt.show()



plt.figure(figsize=(10, 6))
sns.boxplot(x=' avg_purchase_value ', data=df, color='green')
plt.title('Box Plot of Average Purchase Value')
plt.xlabel('Average Purchase Value')
plt.grid(True)
plt.show()




purchase_data = df[['online_purchases', 'in_store_purchases']].sum()
print(purchase_data)
plt.figure(figsize=(10, 6))
purchase_data.plot(kind='bar', stacked=True, color=['blue', 'red'])
plt.title('Total Online vs. In-Store Purchases')
plt.xlabel('Purchase Type')
plt.ylabel('Total Number of Purchases')
plt.xticks(rotation=0)
plt.grid(True)
plt.show()




plt.figure(figsize=(12, 6))
sns.histplot(df['customer_support_calls'], bins=30, kde=True)
plt.title('Distribution of Customer Support Calls')
plt.xlabel('Number of Support Calls')
plt.ylabel('Frequency')
plt.grid(True)
plt.show()





app_usage_counts = df['app_usage'].value_counts()

colors = ['blue', 'red', 'green']

plt.figure(figsize=(8, 8))
plt.pie(
    app_usage_counts,
    labels=app_usage_counts.index,
    autopct='%1.1f%%',
    startangle=140,
    colors=colors
)

plt.title('App Usage Frequency')
plt.axis('equal')
plt.show()



