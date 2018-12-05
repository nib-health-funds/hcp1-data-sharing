<#
.SYNOPSIS

Uploads a CSV file to snowflake. This is a script file and not a function to make execution from a job scheduler more simple.

.DESCRIPTION

Uses snowsql to create a stage, upload the file and load into an existing Snowflake table.

.PARAMETER snowflakeAccount

The name of the snowflake account

.PARAMETER snowflakeUser

The snowflake user account to use (password must be supplied using the SNOWSQL_PWD environment variable)

.PARAMETER snowflakeRole

The snowflake role to use

.PARAMETER snowflakeWarehouse

The snowflake warehouse to use

.PARAMETER snowflakeRegion

The region of the snowflake account

.PARAMETER snowflakeDatabase

The snowflake database

.PARAMETER fileName

The path to the input file

.PARAMETER tableName

The name of the target table

.PARAMETER dateFormat

The date format for the dates in the file (see snowflake), defaults to AUTO.

.PARAMETER timeFormat

The time format for the times in the file (see snowflake), defaults to AUTO.

.PARAMETER fieldDelimiter

The field delimiter in the input file, defaults to the comma character

.PARAMETER skipHeader

The number of rows to skip at the start of the file, defaults to 1

.PARAMETER encoding

The encoding of the file

.PARAMETER nullIfValues

An array of values to treat as null when importing. For example, to treat both the empty string and a single space as null, provide @("''","' '")

.PARAMETER truncateTable

Whether or not to truncate the table as part of the upload. Pass in $true for full loads, or $false for incremental.

.EXAMPLE

Deploying to a test environment with Verbose output

.\upload-csv.ps1 -snowflakeAccount 'ly12345' -snowflakeUser 'uploader' -snowflakeRole 'DATA_UPLOAD' -snowflakeWarehouse 'DATA_UPLOAD' -snowflakeRegion 'ap-southeast-2' -fileName "customers.csv" -tableName "CUSTOMERS"

.NOTES

You must have snowsql installed and on your path prior to running this function.

#>
param(
    [String][ValidateNotNullOrEmpty()]$snowflakeAccount,
    [String][ValidateNotNullOrEmpty()]$snowflakeUser,
    [String][ValidateNotNullOrEmpty()]$snowflakeRole,
    [String][ValidateNotNullOrEmpty()]$snowflakeWarehouse,
    [String][ValidateNotNullOrEmpty()]$snowflakeRegion,
    [String][ValidateNotNullOrEmpty()]$snowflakeDatabase,
    [String][ValidateNotNullOrEmpty()]$snowflakeSchema,
    [String]$fileName,
    [String]$tableName,
    [String]$dateFormat="AUTO",
    [String]$timeFormat="AUTO",
    [String]$fieldDelimiter=",",
    [int]$skipHeader=1,
    [String]$encoding='UTF8',
    [Array]$nullIfValues=@(),
    [boolean]$truncateTable=$false)

$ErrorActionPreference = 'Stop'
if (!(Test-Path $fileName)){
    throw "File $fileName does not exist"
}
$file = get-item (Resolve-Path $fileName)
Write-Verbose "File: $($file.FullName)"
if ($env:SNOWSQL_PWD -eq $null){
    throw "SNOWSQL_PWD environment variable not defined"
}

$truncateTableStatement=""
if ($truncateTable){
    $truncateTableStatement="truncate table {2};" -f $tableName
}

$upload_sql_template=@"
use schema {0};

create or replace temporary stage temp_stage copy_options = (on_error='ABORT_STATEMENT');

put 'file://{1}' @temp_stage;

begin transaction;
{10}
copy into {2} 
from @temp_stage/{3}
file_format = (ENCODING='{8}' type = csv field_delimiter = '{6}' skip_header = {7} date_format = {4} time_format = {5} null_if=({9}) field_optionally_enclosed_by='""')
on_error=ABORT_STATEMENT;
commit;

drop stage temp_stage;

"@
$upload_sql = $upload_sql_template -f $snowflakeSchema,$file.FullName.Replace('\','\\'),$tableName,$file.Name,$dateFormat,$timeFormat,$fieldDelimiter,$skipHeader,$encoding, ($nullIfValues -join ','), $truncateTableStatement
Write-Host "SQL: $upload_sql"
snowsql -a $snowflakeAccount -u $snowflakeUser -r $snowflakeRole -d $snowflakeDatabase -w $snowflakeWarehouse --region $snowflakeRegion -s $snowflakeSchema -q $upload_sql -o header=false -o output_format=plain -o quiet=True -o log_level=CRITICAL -o remove_comments=True -o friendly=False
