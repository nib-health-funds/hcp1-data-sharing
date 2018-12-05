# hcp1-data-sharing
A pattern for sharing de-sensitised HCP1 datasets

##  Background
In order to gain a collective view on the performance of hospitals, all Private Health Insurers (PHIs) in Australia send data to  [Private Healthcare Australia](https://www.privatehealthcareaustralia.org.au/) (PHA) using the  [Hospital Casemix Protocol (HCP)](http://www.health.gov.au/internet/main/publishing.nsf/Content/health-casemix-data-collections-about-HCP).

As this data is no longer distributed  back to funds and hospitals, this repository outlines a technical approach to sharing the data using the [Snowflake](https://www.snowflake.net) data warehouse product.

## Approach
### 1. Create target tables in Snowflake
The ```table_definitions.sql``` file contains the Snowflake schema to store the de-sensitised HCP1 data.
This step is only performed once and can be executed manually from the Snowflake web console (appropriate user privileges must also be granted).

### 2. Parse and de-sensitise the HCP1 data file
The file ```hcp1_parser.ps1``` is a Powershell script that can parse a file in [HCP1 format](http://www.health.gov.au/internet/main/publishing.nsf/Content/1A61745E0B296274CA257BF0001B5EC4/$File/Attachment%20B%20HCP1%20data%20specifications%20insurer%20to%20department%202018-19.PDF).

It outputs 4 CSV files:
-  episodes.csv
- medical.csv
- prosthesis.csv
- ansnap.csv

A data dictionary for each of these is available in the spec document linked above.

The HCP1 format includes sensitive information relating to patient demographic as well as pricing (which may be confidential between hospitals and PHIs). These are ignored as part of the parsing process so that the sensitive data never leaves the PHI.

### 3. Upload datasets to Snowflake
The ```upload_csvfile.ps1``` file is a Powershell script which can be used to upload each of the CSV files produced in step 2, like so:

```
$env:SNOWSQL_PWD='MyPassword'
$snowflakeAccount="ly12345"
$snowflakeUser="me"
$snowflakeRole="PUBLIC"
$snowflakeWarehouse="COMPUTE_WH"
$snowflakeRegion="ap-southeast-2"
$snowflakeDatabase="MY_DATABASE"
$snowflakeSchema="PUBLIC"

.\upload_csvfile.ps1 -snowflakeAccount $snowflakeAccount -snowflakeUser $snowflakeUser -snowflakeRole $snowflakeRole -snowflakeWarehouse $snowflakeWarehouse -snowflakeRegion $snowflakeRegion -snowflakeDatabase $snowflakeDatabase -snowflakeSchema $snowflakeSchema -fileName .\episodes.csv -tableName "EPISODES" -dateFormat "DDMMYYYY" -timeFormat "HH24MI" -nullIfValues @("''","'0000'") -fieldDelimiter ','
.\upload_csvfile.ps1 -snowflakeAccount $snowflakeAccount -snowflakeUser $snowflakeUser -snowflakeRole $snowflakeRole -snowflakeWarehouse $snowflakeWarehouse -snowflakeRegion $snowflakeRegion -snowflakeDatabase $snowflakeDatabase -snowflakeSchema $snowflakeSchema -fileName .\medical.csv -tableName "MEDICAL" -dateFormat "DDMMYYYY" -timeFormat "HH24MI" -nullIfValues @("''","'0000'") -fieldDelimiter ','
.\upload_csvfile.ps1 -snowflakeAccount $snowflakeAccount -snowflakeUser $snowflakeUser -snowflakeRole $snowflakeRole -snowflakeWarehouse $snowflakeWarehouse -snowflakeRegion $snowflakeRegion -snowflakeDatabase $snowflakeDatabase -snowflakeSchema $snowflakeSchema -fileName .\prosthesis.csv -tableName "PROSTHESIS" -dateFormat "DDMMYYYY" -timeFormat "HH24MI" -nullIfValues @("''","'0000'") -fieldDelimiter ','
.\upload_csvfile.ps1 -snowflakeAccount $snowflakeAccount -snowflakeUser $snowflakeUser -snowflakeRole $snowflakeRole -snowflakeWarehouse $snowflakeWarehouse -snowflakeRegion $snowflakeRegion -snowflakeDatabase $snowflakeDatabase -snowflakeSchema $snowflakeSchema -fileName .\ansnap.csv -tableName "ANSNAP" -dateFormat "DDMMYYYY" -timeFormat "HH24MI" -nullIfValues @("''","'0000'") -fieldDelimiter ','
```


### 4. Share datasets

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details