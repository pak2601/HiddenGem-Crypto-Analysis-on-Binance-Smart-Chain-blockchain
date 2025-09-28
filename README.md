# HiddenGem-Crypto-Analysis-on-Binance-Smart-Chain-blockchain
The project aims to train a model which can potentially find hidden gem investments on the BSC Dexes via the dataset extracted from Dune Analytics platform.
PythonETLFile: includes ETL functions:
- extract_from_dune: extract data api from Dune 
- extract_from_csv: load csv file
- load: load dataframe to csv file
- transform: pre process data 

ClassificationBSC:
- Use defined ETL functions from  to get data 
- Perform classification task 

duneBSCdexvol:
- duneSQL query language


Plan:
Use the 2025 training dataset -> apply it into testing set (2023 or 2024 dataset)


Purpose of Analysis:
- Train and apply test on past dex data to check whether a certain cryptocurrency is a good invement 
or speculation or not.
- Get important features and assess them and identify whether should be them or not
- Does not includes Risk Management Analysis, just identify potential coins with good returns
- Find hidden gem which meet the following criteria:
1. Quantiative:
- Consistent growth in trading volume
- Low marketshare -> potential to grow 
2. Qualitative:
- Use SENTIMENT Analysis -> track social score (Twitter API)
