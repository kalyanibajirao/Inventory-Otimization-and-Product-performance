import pandas as pd
import os


# PRODUCT PERFORMANCE & INVENTORY OPTIMIZATION
# FINAL DATA CLEANING SCRIPT


# Input and output folders
input_folder = "../data"
output_folder = "../data/cleaned"

# Create cleaned folder if it doesn't exist
os.makedirs(output_folder, exist_ok=True)

print("=" * 80)
print("FINAL DATA CLEANING PROCESS")
print("=" * 80)



# 1. SKU DATA


print("\n" + "=" * 80)
print("1. CLEANING SKU DATA")
print("=" * 80)

skus = pd.read_csv(
    os.path.join(input_folder, "bm_skus.csv")
)

print("Original rows:", len(skus))

# Remove duplicate rows
skus = skus.drop_duplicates()

# Remove duplicate SKU IDs
skus = skus.drop_duplicates(
    subset=["sku_id"],
    keep="first"
)

# Remove rows with missing critical values
critical_columns = [
    "sku_id",
    "sku_name",
    "category",
    "subcategory",
    "unit_price",
    "cost_price",
    "brand"
]

skus = skus.dropna(
    subset=critical_columns
)

# Validate prices
skus = skus[
    (skus["unit_price"] > 0) &
    (skus["cost_price"] > 0)
]

# Standardize text columns
text_columns = [
    "sku_name",
    "category",
    "subcategory",
    "brand"
]

for column in text_columns:
    skus[column] = skus[column].astype(str).str.strip()

# Calculate profit per unit
skus["profit_per_unit"] = (
    skus["unit_price"] -
    skus["cost_price"]
)

# Calculate profit margin
skus["profit_margin_pct"] = (
    skus["profit_per_unit"] /
    skus["unit_price"]
) * 100

# Save
skus.to_csv(
    os.path.join(
        output_folder,
        "bm_skus_cleaned.csv"
    ),
    index=False
)

print("Final SKU rows:", len(skus))
print("SKU file saved successfully.")



# 2. SALES DATA


print("\n" + "=" * 80)
print("2. CLEANING SALES DATA")
print("=" * 80)

sales = pd.read_csv(
    os.path.join(input_folder, "bm_sales.csv")
)

print("Original rows:", len(sales))

# Remove exact duplicate rows
sales = sales.drop_duplicates()

print("Rows after duplicate removal:", len(sales))

# Convert date
sales["date"] = pd.to_datetime(
    sales["date"],
    errors="coerce"
)

# Remove rows with invalid dates
sales = sales.dropna(
    subset=["date"]
)

# Check critical numerical columns
numeric_columns = [
    "store_id",
    "sku_id",
    "quantity",
    "unit_price",
    "total_value",
    "discount_pct"
]

# Remove rows with missing critical numerical data
sales = sales.dropna(
    subset=numeric_columns
)

# Remove invalid quantities
sales = sales[
    sales["quantity"] > 0
]

# Remove invalid unit prices
sales = sales[
    sales["unit_price"] > 0
]

# Remove negative total values
sales = sales[
    sales["total_value"] >= 0
]

# Keep discount between 0 and 100
sales = sales[
    (sales["discount_pct"] >= 0) &
    (sales["discount_pct"] <= 100)
]

# Convert customer ID to nullable integer
sales["customer_id"] = sales["customer_id"].astype("Int64")

# Standardize channel
sales["channel"] = (
    sales["channel"]
    .astype(str)
    .str.strip()
)

# ------------------------------------------------------------
# Revenue validation
# ------------------------------------------------------------

calculated_value = (
    sales["quantity"] *
    sales["unit_price"] *
    (1 - sales["discount_pct"] / 100)
)

sales["calculated_value"] = calculated_value.round(2)

sales["value_difference"] = (
    sales["total_value"] -
    sales["calculated_value"]
).round(2)

# ------------------------------------------------------------
# Add year/month fields
# ------------------------------------------------------------

sales["year"] = sales["date"].dt.year
sales["month"] = sales["date"].dt.month
sales["month_name"] = sales["date"].dt.month_name()

# Save
sales.to_csv(
    os.path.join(
        output_folder,
        "bm_sales_cleaned.csv"
    ),
    index=False
)

print("Final Sales rows:", len(sales))
print("Missing Customer IDs:", sales["customer_id"].isna().sum())
print("Sales file saved successfully.")



# 3. INVENTORY DATA


print("\n" + "=" * 80)
print("3. CLEANING INVENTORY DATA")
print("=" * 80)

inventory = pd.read_csv(
    os.path.join(input_folder, "bm_inventory.csv")
)

print("Original rows:", len(inventory))

# Remove duplicate rows
inventory = inventory.drop_duplicates()

# Convert dates
inventory["last_restock_date"] = pd.to_datetime(
    inventory["last_restock_date"],
    errors="coerce"
)

inventory["snapshot_date"] = pd.to_datetime(
    inventory["snapshot_date"],
    errors="coerce"
)

# Remove invalid dates
inventory = inventory.dropna(
    subset=[
        "last_restock_date",
        "snapshot_date"
    ]
)

# Remove invalid stock values
inventory = inventory[
    inventory["stock_on_hand"] >= 0
]

inventory = inventory[
    inventory["reorder_point"] >= 0
]

inventory = inventory[
    inventory["safety_stock"] >= 0
]

# Standardize date-related values
inventory["stock_on_hand"] = inventory[
    "stock_on_hand"
].astype(int)

inventory["reorder_point"] = inventory[
    "reorder_point"
].astype(int)

inventory["safety_stock"] = inventory[
    "safety_stock"
].astype(int)

# ------------------------------------------------------------
# Stock status
# ------------------------------------------------------------

inventory["stock_status"] = "Healthy"

inventory.loc[
    inventory["stock_on_hand"] <= inventory["reorder_point"],
    "stock_status"
] = "Reorder Required"

inventory.loc[
    inventory["stock_on_hand"] == 0,
    "stock_status"
] = "Out of Stock"

# ------------------------------------------------------------
# Save
# ------------------------------------------------------------

inventory.to_csv(
    os.path.join(
        output_folder,
        "bm_inventory_cleaned.csv"
    ),
    index=False
)

print("Final Inventory rows:", len(inventory))
print("Inventory file saved successfully.")



# 4. STORE DATA


print("\n" + "=" * 80)
print("4. CLEANING STORE DATA")
print("=" * 80)

stores = pd.read_csv(
    os.path.join(input_folder, "bm_stores.csv")
)

print("Original rows:", len(stores))

# Remove duplicates
stores = stores.drop_duplicates()

stores = stores.drop_duplicates(
    subset=["store_id"],
    keep="first"
)

# Convert opening date
stores["opening_date"] = pd.to_datetime(
    stores["opening_date"],
    errors="coerce"
)

# Remove invalid dates
stores = stores.dropna(
    subset=["opening_date"]
)

# Standardize text
store_text_columns = [
    "store_name",
    "city",
    "store_type"
]

for column in store_text_columns:
    stores[column] = (
        stores[column]
        .astype(str)
        .str.strip()
    )

# Save
stores.to_csv(
    os.path.join(
        output_folder,
        "bm_stores_cleaned.csv"
    ),
    index=False
)

print("Final Store rows:", len(stores))
print("Store file saved successfully.")



# 5. CUSTOMER DATA


print("\n" + "=" * 80)
print("5. CLEANING CUSTOMER DATA")
print("=" * 80)

customers = pd.read_csv(
    os.path.join(input_folder, "bm_Customers.csv")
)

print("Original rows:", len(customers))

# Remove duplicates
customers = customers.drop_duplicates()

customers = customers.drop_duplicates(
    subset=["cust_id"],
    keep="first"
)

# Validate age
customers = customers[
    (customers["age"] >= 18) &
    (customers["age"] <= 100)
]

# Convert registration date
customers["registration_date"] = pd.to_datetime(
    customers["registration_date"],
    errors="coerce"
)

# Remove invalid registration dates
customers = customers.dropna(
    subset=["registration_date"]
)

# Standardize text
customer_text_columns = [
    "gender",
    "city",
    "loyalty_segment",
    "preferred_channel"
]

for column in customer_text_columns:
    customers[column] = (
        customers[column]
        .astype(str)
        .str.strip()
    )

# Save
customers.to_csv(
    os.path.join(
        output_folder,
        "bm_Customers_cleaned.csv"
    ),
    index=False
)

print("Final Customer rows:", len(customers))
print("Customer file saved successfully.")



# 6. PROMOTION DATA


print("\n" + "=" * 80)
print("6. CLEANING PROMOTION DATA")
print("=" * 80)

promotions = pd.read_csv(
    os.path.join(input_folder, "bm_promotions.csv")
)

print("Original rows:", len(promotions))

# Remove duplicates
promotions = promotions.drop_duplicates()

promotions = promotions.drop_duplicates(
    subset=["promo_id"],
    keep="first"
)

# Convert dates
promotions["start_date"] = pd.to_datetime(
    promotions["start_date"],
    errors="coerce"
)

promotions["end_date"] = pd.to_datetime(
    promotions["end_date"],
    errors="coerce"
)

# Remove invalid dates
promotions = promotions.dropna(
    subset=[
        "start_date",
        "end_date"
    ]
)

# Remove invalid date ranges
promotions = promotions[
    promotions["end_date"] >=
    promotions["start_date"]
]

# Validate discount
promotions = promotions[
    (promotions["discount_pct"] >= 0) &
    (promotions["discount_pct"] <= 100)
]

# Standardize text
promotion_text_columns = [
    "promo_name",
    "promo_type"
]

for column in promotion_text_columns:
    promotions[column] = (
        promotions[column]
        .astype(str)
        .str.strip()
    )

# Calculate promotion duration
promotions["promotion_duration_days"] = (
    promotions["end_date"] -
    promotions["start_date"]
).dt.days + 1

# Save
promotions.to_csv(
    os.path.join(
        output_folder,
        "bm_promotions_cleaned.csv"
    ),
    index=False
)

print("Final Promotion rows:", len(promotions))
print("Promotion file saved successfully.")



# FINAL SUMMARY


print("\n" + "=" * 80)
print("ALL DATASETS CLEANED SUCCESSFULLY")
print("=" * 80)

print("\nFiles created:")

for file in os.listdir(output_folder):
    print("✓", file)

print("\nOutput folder:")
print(os.path.abspath(output_folder))

print("\n" + "=" * 80)
print("DATA CLEANING COMPLETED")
print("=" * 80)