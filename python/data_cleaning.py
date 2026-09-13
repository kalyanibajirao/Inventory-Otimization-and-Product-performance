import pandas as pd

# Load SKU dataset
skus = pd.read_csv("../data/bm_skus.csv")

print("=" * 70)
print("SKU DATA CLEANING")
print("=" * 70)

print("\nOriginal rows:", len(skus))

#  1. Remove duplicate rows

skus = skus.drop_duplicates()
print("Rows after removing duplicates:", len(skus))

# 2. Check duplicate SKU IDs
duplicate_skus = skus["sku_id"].duplicated().sum()
print("Duplicate SKU IDs:", duplicate_skus)

# 3. Remove rows with missing critical values

critical_columns = [
    "sku_id",
    "sku_name",
    "category",
    "subcategory",
    "unit_price",
    "cost_price",
    "brand"
]

print("\nMissing values before cleaning:")
print(skus[critical_columns].isnull().sum())

skus = skus.dropna(subset=critical_columns)


# 4. Validate prices

print("\nInvalid unit prices:", (skus["unit_price"] <= 0).sum())
print("Invalid cost prices:", (skus["cost_price"] <= 0).sum())

# Keep only valid prices
skus = skus[
    (skus["unit_price"] > 0) &
    (skus["cost_price"] > 0)
]


# 5. Calculate profit per unit

skus["profit_per_unit"] = (
    skus["unit_price"] - skus["cost_price"]
)

# 6. Calculate profit margin

skus["profit_margin_pct"] = (
    skus["profit_per_unit"] /
    skus["unit_price"]
) * 100


# 7. Check negative profit products

negative_profit = (
    skus["profit_per_unit"] < 0
).sum()

print("\nProducts with negative profit:", negative_profit)


# 8. Final result

print("\nFinal SKU rows:", len(skus))

print("\nFinal SKU data:")
print(skus.head())

print("\nFinal columns:")
print(skus.columns.tolist())



# Load sales dataset-------------------------------------------------------------------------
sales = pd.read_csv("../data/bm_sales.csv")

print("=" * 70)
print("SALES DATA CLEANING")
print("=" * 70)

print("\nOriginal rows:", len(sales))


# 1. Check duplicate rows

duplicate_rows = sales.duplicated().sum()

print("Duplicate rows:", duplicate_rows)


# 2. Remove exact duplicate rows

sales = sales.drop_duplicates()

print("Rows after removing duplicates:", len(sales))


# 3. Check missing values

print("\nMissing values:")
print(sales.isnull().sum())


# 4. Convert date column

sales["date"] = pd.to_datetime(
    sales["date"],
    errors="coerce"
)

print("\nInvalid dates:", sales["date"].isnull().sum())


# 5. Check quantity

print("\nQuantity statistics:")
print(sales["quantity"].describe())

print(
    "Zero quantity:",
    (sales["quantity"] == 0).sum()
)

print(
    "Negative quantity:",
    (sales["quantity"] < 0).sum()
)


# 6. Check unit price

print("\nUnit price statistics:")
print(sales["unit_price"].describe())

print(
    "Zero unit price:",
    (sales["unit_price"] == 0).sum()
)

print(
    "Negative unit price:",
    (sales["unit_price"] < 0).sum()
)


# 7. Check total value

print("\nTotal value statistics:")
print(sales["total_value"].describe())

print(
    "Zero total value:",
    (sales["total_value"] == 0).sum()
)

print(
    "Negative total value:",
    (sales["total_value"] < 0).sum()
)


# 8. Check discount percentage

print("\nDiscount statistics:")
print(sales["discount_pct"].describe())

print(
    "Discount below 0:",
    (sales["discount_pct"] < 0).sum()
)

print(
    "Discount above 100:",
    (sales["discount_pct"] > 100).sum()
)


# 9. Validate total value

calculated_value = (
    sales["quantity"] *
    sales["unit_price"] *
    (1 - sales["discount_pct"] / 100)
)

difference = (
    sales["total_value"] - calculated_value
).abs()

print(
    "\nRevenue calculation differences:",
    (difference > 0.01).sum()
)

#  10. Final summary

print("\nFinal rows:", len(sales))

print("\nFinal data types:")
print(sales.dtypes)

print("\nSales data preview:")
print(sales.head())

print("\nSALES CLEANING CHECK COMPLETED")

# Load inventory dataset---------------------------------------------------------------
inventory = pd.read_csv("../data/bm_inventory.csv")

print("=" * 70)
print("INVENTORY DATA CLEANING")
print("=" * 70)

print("\nOriginal rows:", len(inventory))


# 1. Check duplicate rows

duplicate_rows = inventory.duplicated().sum()

print("Duplicate rows:", duplicate_rows)


# 2. Remove exact duplicate rows

inventory = inventory.drop_duplicates()

print("Rows after removing duplicates:", len(inventory))


# 3. Check missing values

print("\nMissing values:")
print(inventory.isnull().sum())


# 4. Convert date columns

inventory["last_restock_date"] = pd.to_datetime(
    inventory["last_restock_date"],
    errors="coerce"
)

inventory["snapshot_date"] = pd.to_datetime(
    inventory["snapshot_date"],
    errors="coerce"
)


print(
    "\nInvalid last restock dates:",
    inventory["last_restock_date"].isnull().sum()
)

print(
    "Invalid snapshot dates:",
    inventory["snapshot_date"].isnull().sum()
)


# 5. Check stock_on_hand

print("\nStock on Hand Statistics:")
print(inventory["stock_on_hand"].describe())

print(
    "Negative stock:",
    (inventory["stock_on_hand"] < 0).sum()
)

print(
    "Zero stock:",
    (inventory["stock_on_hand"] == 0).sum()
)


# 6. Check reorder point

print("\nReorder Point Statistics:")
print(inventory["reorder_point"].describe())

print(
    "Negative reorder points:",
    (inventory["reorder_point"] < 0).sum()
)


# 7. Check safety stock

print("\nSafety Stock Statistics:")
print(inventory["safety_stock"].describe())

print(
    "Negative safety stock:",
    (inventory["safety_stock"] < 0).sum()
)


# 8. Check safety stock vs reorder point

invalid_safety_stock = (
    inventory["safety_stock"] >
    inventory["reorder_point"]
)

print(
    "\nSafety stock greater than reorder point:",
    invalid_safety_stock.sum()
)


# 9. Check date logic

invalid_dates = (
    inventory["last_restock_date"] >
    inventory["snapshot_date"]
)

print(
    "Restock date after snapshot date:",
    invalid_dates.sum()
)


# 10. Inventory status

inventory["stock_status"] = "Healthy"

inventory.loc[
    inventory["stock_on_hand"] <= inventory["reorder_point"],
    "stock_status"
] = "Reorder Required"

inventory.loc[
    inventory["stock_on_hand"] == 0,
    "stock_status"
] = "Out of Stock"


# 11. Inventory value will be added later

print("\nStock Status Distribution:")
print(inventory["stock_status"].value_counts())


# 12. Final summary

print("\nFinal rows:", len(inventory))

print("\nFinal columns:")
print(inventory.columns.tolist())

print("\nInventory preview:")
print(inventory.head())

print("\nFinal data types:")
print(inventory.dtypes)

print("\nINVENTORY CLEANING CHECK COMPLETED")



# Load store dataset---------------------------------------------------------------
stores = pd.read_csv("../data/bm_stores.csv")

print("=" * 70)
print("STORE DATA CLEANING")
print("=" * 70)

print("\nOriginal rows:", len(stores))


# 1. Check duplicate rows

duplicate_rows = stores.duplicated().sum()

print("Duplicate rows:", duplicate_rows)


# 2. Remove exact duplicate rows

stores = stores.drop_duplicates()

print("Rows after removing duplicates:", len(stores))


# 3. Check duplicate Store IDs

duplicate_store_ids = stores["store_id"].duplicated().sum()

print("Duplicate Store IDs:", duplicate_store_ids)


# 4. Check missing values

print("\nMissing values:")
print(stores.isnull().sum())


# 5. Convert opening date

stores["opening_date"] = pd.to_datetime(
    stores["opening_date"],
    errors="coerce"
)

print(
    "\nInvalid opening dates:",
    stores["opening_date"].isnull().sum()
)


# 6. Check future opening dates

today = pd.Timestamp.today()

future_opening_dates = (
    stores["opening_date"] > today
).sum()

print(
    "Future opening dates:",
    future_opening_dates
)


# 7. Check blank text fields

print("\nBlank Store Names:",
      (stores["store_name"].str.strip() == "").sum())

print("Blank Cities:",
      (stores["city"].str.strip() == "").sum())

print("Blank Store Types:",
      (stores["store_type"].str.strip() == "").sum())


# 8. Standardize text columns

stores["store_name"] = (
    stores["store_name"]
    .str.strip()
)

stores["city"] = (
    stores["city"]
    .str.strip()
)

stores["store_type"] = (
    stores["store_type"]
    .str.strip()
)


# 9. Check store types

print("\nStore Types:")
print(stores["store_type"].value_counts())


# 10. Check cities

print("\nCities:")
print(stores["city"].value_counts())


# 11. Final summary

print("\nFinal rows:", len(stores))

print("\nFinal columns:")
print(stores.columns.tolist())

print("\nFinal data types:")
print(stores.dtypes)

print("\nStore preview:")
print(stores.head())


print("\n" + "=" * 70)
print("STORE CLEANING CHECK COMPLETED")
print("=" * 70)



# Load customer dataset--------------------------------------------------------------
customers = pd.read_csv("../data/bm_Customers.csv")

print("=" * 70)
print("CUSTOMER DATA CLEANING")
print("=" * 70)

print("\nOriginal rows:", len(customers))


# 1. Check duplicate rows

duplicate_rows = customers.duplicated().sum()

print("Duplicate rows:", duplicate_rows)


# 2. Remove exact duplicate rows

customers = customers.drop_duplicates()

print("Rows after removing duplicates:", len(customers))


# 3. Check duplicate Customer IDs

duplicate_customer_ids = customers["cust_id"].duplicated().sum()

print("Duplicate Customer IDs:", duplicate_customer_ids)


# 4. Check missing values

print("\nMissing values:")
print(customers.isnull().sum())


# 5. Check age

print("\nAge Statistics:")
print(customers["age"].describe())

print(
    "Age below 18:",
    (customers["age"] < 18).sum()
)

print(
    "Age above 100:",
    (customers["age"] > 100).sum()
)


# 6. Check registration date

customers["registration_date"] = pd.to_datetime(
    customers["registration_date"],
    errors="coerce"
)

print(
    "\nInvalid registration dates:",
    customers["registration_date"].isnull().sum()
)


# 7. Check future registration dates

today = pd.Timestamp.today()

future_registration_dates = (
    customers["registration_date"] > today
).sum()

print(
    "Future registration dates:",
    future_registration_dates
)


# 8. Check blank text fields

print(
    "\nBlank gender values:",
    (customers["gender"].str.strip() == "").sum()
)

print(
    "Blank city values:",
    (customers["city"].str.strip() == "").sum()
)

print(
    "Blank loyalty segment values:",
    (customers["loyalty_segment"].str.strip() == "").sum()
)

print(
    "Blank preferred channel values:",
    (customers["preferred_channel"].str.strip() == "").sum()
)


# 9. Standardize text columns

text_columns = [
    "gender",
    "city",
    "loyalty_segment",
    "preferred_channel"
]

for column in text_columns:
    customers[column] = customers[column].str.strip()


# 10. Check customer categories

print("\nGender Distribution:")
print(customers["gender"].value_counts())


print("\nLoyalty Segment Distribution:")
print(customers["loyalty_segment"].value_counts())


print("\nPreferred Channel Distribution:")
print(customers["preferred_channel"].value_counts())


# 11. Final summary

print("\nFinal rows:", len(customers))

print("\nFinal columns:")
print(customers.columns.tolist())

print("\nFinal data types:")
print(customers.dtypes)

print("\nCustomer preview:")
print(customers.head())


print("\n" + "=" * 70)
print("CUSTOMER CLEANING CHECK COMPLETED")
print("=" * 70)

import pandas as pd

# Load promotion dataset-----------------------------------------------------
promotions = pd.read_csv("../data/bm_promotions.csv")
print("=" * 70)
print("PROMOTION DATA CLEANING")
print("=" * 70)
print("\nOriginal rows:", len(promotions))

# 1. Check duplicate rows
duplicate_rows = promotions.duplicated().sum()
print("Duplicate rows:", duplicate_rows)

# 2. Remove exact duplicate rows
promotions = promotions.drop_duplicates()
print("Rows after removing duplicates:", len(promotions))

# 3. Check duplicate Promotion IDs
duplicate_promo_ids = promotions["promo_id"].duplicated().sum()
print("Duplicate Promotion IDs:", duplicate_promo_ids)

# 4. Check missing values
print("\nMissing values:")
print(promotions.isnull().sum())

# 5. Convert date columns
promotions["start_date"] = pd.to_datetime(
    promotions["start_date"],
    errors="coerce"
)

promotions["end_date"] = pd.to_datetime(
    promotions["end_date"],
    errors="coerce"
)

print(
    "\nInvalid start dates:",
    promotions["start_date"].isnull().sum()
)

print(
    "Invalid end dates:",
    promotions["end_date"].isnull().sum()
)

# 6. Check date logic

invalid_date_ranges = (
    promotions["end_date"] < promotions["start_date"]
)

print(
    "End date before start date:",
    invalid_date_ranges.sum()
)


# 7. Calculate promotion duration

promotions["promotion_duration_days"] = (
    promotions["end_date"] -
    promotions["start_date"]
).dt.days + 1


print("\nPromotion Duration Statistics:")
print(
    promotions["promotion_duration_days"].describe()
)


# 8. Check discount percentage

print("\nDiscount Statistics:")
print(
    promotions["discount_pct"].describe()
)

print(
    "Discount below 0:",
    (promotions["discount_pct"] < 0).sum()
)

print(
    "Discount above 100:",
    (promotions["discount_pct"] > 100).sum()
)


# 9. Check blank text fields

print(
    "\nBlank promotion names:",
    (promotions["promo_name"].str.strip() == "").sum()
)

print(
    "Blank promotion types:",
    (promotions["promo_type"].str.strip() == "").sum()
)


# 10. Standardize text columns

promotions["promo_name"] = (
    promotions["promo_name"]
    .str.strip()
)

promotions["promo_type"] = (
    promotions["promo_type"]
    .str.strip()
)


# 11. Check promotion types

print("\nPromotion Types:")
print(
    promotions["promo_type"].value_counts()
)


# 12. Final summary

print("\nFinal rows:", len(promotions))

print("\nFinal columns:")
print(promotions.columns.tolist())

print("\nFinal data types:")
print(promotions.dtypes)

print("\nPromotion preview:")
print(promotions.head())


print("\n" + "=" * 70)
print("PROMOTION CLEANING CHECK COMPLETED")
print("=" * 70)