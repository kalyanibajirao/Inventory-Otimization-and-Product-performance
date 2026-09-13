import pandas as pd

# Load datasets
skus = pd.read_csv("../data/bm_skus.csv")
sales = pd.read_csv("../data/bm_sales.csv")
inventory = pd.read_csv("../data/bm_inventory.csv")
stores = pd.read_csv("../data/bm_stores.csv")
customers = pd.read_csv("../data/bm_Customers.csv")


print("=" * 80)
print("PRIMARY KEY CHECK")
print("=" * 80)



# 1. SKU CHECK


print("\nSKU TABLE")
print("-" * 50)

print("Total SKU rows:", len(skus))
print("Unique SKU IDs:", skus["sku_id"].nunique())
print("Duplicate SKU IDs:", skus["sku_id"].duplicated().sum())



# 2. STORE CHECK


print("\nSTORE TABLE")
print("-" * 50)

print("Total Store rows:", len(stores))
print("Unique Store IDs:", stores["store_id"].nunique())
print("Duplicate Store IDs:", stores["store_id"].duplicated().sum())



# 3. CUSTOMER CHECK


print("\nCUSTOMER TABLE")
print("-" * 50)

print("Total Customer rows:", len(customers))
print("Unique Customer IDs:", customers["cust_id"].nunique())
print("Duplicate Customer IDs:", customers["cust_id"].duplicated().sum())



# 4. SALES → SKU RELATIONSHIP


print("\nSALES → SKU CHECK")
print("-" * 50)

invalid_skus = sales[~sales["sku_id"].isin(skus["sku_id"])]

print("Sales rows with invalid SKU:", len(invalid_skus))



# 5. SALES → STORE RELATIONSHIP


print("\nSALES → STORE CHECK")
print("-" * 50)

invalid_stores = sales[~sales["store_id"].isin(stores["store_id"])]

print("Sales rows with invalid Store:", len(invalid_stores))



# 6. SALES → CUSTOMER RELATIONSHIP


print("\nSALES → CUSTOMER CHECK")
print("-" * 50)

sales_with_customer = sales[sales["customer_id"].notna()]

invalid_customers = sales_with_customer[
    ~sales_with_customer["customer_id"].isin(customers["cust_id"])
]

print("Sales with customer ID:", len(sales_with_customer))
print("Sales rows with invalid Customer:", len(invalid_customers))



# 7. INVENTORY DUPLICATES


print("\nINVENTORY CHECK")
print("-" * 50)

inventory_duplicates = inventory.duplicated(
    subset=["store_id", "sku_id", "snapshot_date"]
).sum()

print("Duplicate Store + SKU + Snapshot:", inventory_duplicates)



# 8. INVENTORY SKU VALIDATION


invalid_inventory_skus = inventory[
    ~inventory["sku_id"].isin(skus["sku_id"])
]

print("Inventory rows with invalid SKU:", len(invalid_inventory_skus))



# 9. INVENTORY STORE VALIDATION


invalid_inventory_stores = inventory[
    ~inventory["store_id"].isin(stores["store_id"])
]

print("Inventory rows with invalid Store:", len(invalid_inventory_stores))


print("\n" + "=" * 80)
print("RELATIONSHIP CHECK COMPLETED")
print("=" * 80)