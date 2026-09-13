import pandas as pd
import os

# List of files
files = [
    "../data/bm_skus.csv",
    "../data/bm_promotions.csv",
    "../data/bm_sales.csv",
    "../data/bm_inventory.csv",
    "../data/bm_stores.csv",
    "../data/bm_Customers.csv"
]

for file in files:

    print("\n" + "=" * 80)
    print("FILE:", file)
    print("=" * 80)

    # Read CSV
    df = pd.read_csv(file)

    # Basic information
    print("\nRows:", df.shape[0])
    print("Columns:", df.shape[1])

    # Column names
    print("\nColumn Names:")
    print(df.columns.tolist())

    # Data types
    print("\nData Types:")
    print(df.dtypes)

    # Missing values
    print("\nMissing Values:")
    print(df.isnull().sum())

    # Duplicate rows
    print("\nDuplicate Rows:", df.duplicated().sum())

    # First 5 records
    print("\nFirst 5 Records:")
    print(df.head())