<#
.SYNOPSIS

Converts a single HCP1 file to CSV files.

.DESCRIPTION

Takes a HCP1 file as input, loads it into memory and extracts the episode, medical, prosthesis and AN-SNAP records and fields.

The parser does not enforce order or presence of particular rows, but if the trailer record is encountered it is used to cross-check counts of other records.

.PARAMETER hcp1InputFile

The name of the input file

.PARAMETER episodesOutputFile

The name of the file to write the episode data to

.PARAMETER medicalOutputFile

The name of the file to write the medical data to

.PARAMETER prosthesisOutputFile

The name of the file to write the prosthesis data to

.PARAMETER ansnapOutputFile

The name of the file to write the ansnap data to

.EXAMPLE

.\hcp1_parser.ps1 -hcp1InputFile

#>
param(
    [String][ValidateNotNullOrEmpty()]$hcp1InputFile,
    [String]$episodesOutputFile='episodes.csv',
    [String]$medicalOutputFile='medical.csv',
    [String]$prosthesisOutputFile='prosthesis.csv',
    [String]$ansnapOutputFile='ansnap.csv')

$ErrorActionPreference = 'Stop'
if (!(Test-Path $hcp1InputFile)){
    throw "File $hcp1InputFile does not exist"
}

# Build the table object to store Episodes - sensitive columns commented out
$episodeTable = New-Object system.Data.DataTable 'Episodes'
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Insurer identifier'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Link Identifier'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Provider (hospital) code'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Product code'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Hospital contract status'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Total days paid'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Accommodation charge'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Accommodation benefit'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Theatre charge'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Theatre benefit'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Labour ward charge'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Labour ward benefit'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Intensive Care Unit Charge'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Intensive Care Unit Benefit'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Prosthesis charge'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Prosthesis benefit'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Pharmacy charge'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Pharmacy benefit'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Bundled charges'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Bundled benefits'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Other charges'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Other benefits'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Front end deductible'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Ancillary cover status'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Ancillary charges'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Ancillary benefits'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Total Medical charges'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Total Medical Benefits'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Date of birth'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Age'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Postcode - Australian'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Sex'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Admission date'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Separation date'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Hospital type'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'ICU days'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Diagnosis related group'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'DRG version'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Admission time'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Infant weight, neonate, stillborn'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Hours of mechanical ventilation'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Mode of separation'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Separation time'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Source of referral'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Care Type'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Total leave days'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Non-Certified days of stay'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Principal diagnosis'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Additional diagnosis'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Procedure '))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Same-day status'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Principal MBS item number'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Principal Item Date'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Minutes of operating theatre time'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Secondary MBS item numbers '))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Number of days of hospital-in-the-home care'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Total psychiatric care days'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Mental health legal status'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'ICU hours'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Urgency of admission'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Inter-hospital contracted patient'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Palliative care Status'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Re-admission within 28 days'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Unplanned theatre visit during episode'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Provider number of hospital from which transferred'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Provider number of hospital to which transferred'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Discharge intention on admission'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Person Identifier'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Miscellaneous Service Codes'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Hospital-in-the-home care Charges'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Hospital-in-the-home care Benefits'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Special Care Nursery Charges'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Special Care Nursery Benefits'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Coronary Care Unit Charges'))
#$episodeTable.columns.add((New-Object system.Data.DataColumn 'Coronary Care Unit Benefits'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Special Care Nursery Hours'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Coronary Care Unit Hours'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Special Care Nursery Days'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Coronary Care Unit Days'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Number of Qualified Days for Newborns'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Hospital-in-the-home care Commencement Date'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Hospital-in-the-home care Completed Date'))
$episodeTable.columns.add((New-Object system.Data.DataColumn 'Palliative Care Days'))


# Build the table object to store Medical records - sensitive columns commented out
$medicalTable = New-Object system.Data.DataTable 'Medical'
$medicalTable.columns.add((New-Object system.Data.DataColumn 'Insurer identifier'))
$medicalTable.columns.add((New-Object system.Data.DataColumn 'Link Identifier'))
$medicalTable.columns.add((New-Object system.Data.DataColumn 'MBS item '))
#$medicalTable.columns.add((New-Object system.Data.DataColumn 'Item charge'))
$medicalTable.columns.add((New-Object system.Data.DataColumn 'MBS benefit'))
#$medicalTable.columns.add((New-Object system.Data.DataColumn 'Insurer benefit'))
$medicalTable.columns.add((New-Object system.Data.DataColumn 'MBS date of service'))
$medicalTable.columns.add((New-Object system.Data.DataColumn 'Medical Payment Type'))
#$medicalTable.columns.add((New-Object system.Data.DataColumn 'Gap Cover Scheme Identifier'))
$medicalTable.columns.add((New-Object system.Data.DataColumn 'MBS Fee'))

# Build the table object to store Prosthesis records - sensitive columns commented out
$prosthesisTable = New-Object system.Data.DataTable 'Prosthesis'
$prosthesisTable.columns.add((New-Object system.Data.DataColumn 'Insurer Identifier'))
$prosthesisTable.columns.add((New-Object system.Data.DataColumn 'Link Identifier'))
$prosthesisTable.columns.add((New-Object system.Data.DataColumn 'Prosthetic Item'))
$prosthesisTable.columns.add((New-Object system.Data.DataColumn 'Number of Items'))
#$prosthesisTable.columns.add((New-Object system.Data.DataColumn 'Total Prosthetic Item Charge'))
#$prosthesisTable.columns.add((New-Object system.Data.DataColumn 'Total Prosthetic Item Benefit'))

# Build the table object to store AN-SNAP records - sensitive columns commented out
$ansnapTable = New-Object system.Data.DataTable 'ANSNAP'
$ansnapTable.columns.add((New-Object system.Data.DataColumn 'Insurer Identifier'))
$ansnapTable.columns.add((New-Object system.Data.DataColumn 'Link Identifier'))
$ansnapTable.columns.add((New-Object system.Data.DataColumn 'Episode Type'))
$ansnapTable.columns.add((New-Object system.Data.DataColumn 'Admission FIM  Item Scores'))
$ansnapTable.columns.add((New-Object system.Data.DataColumn 'Discharge FIM Item Scores'))
$ansnapTable.columns.add((New-Object system.Data.DataColumn 'AROC Impairment Codes'))
$ansnapTable.columns.add((New-Object system.Data.DataColumn 'Assessment Only Indicator'))
$ansnapTable.columns.add((New-Object system.Data.DataColumn 'AN-SNAP Class'))
$ansnapTable.columns.add((New-Object system.Data.DataColumn 'SNAP Version'))
$ansnapTable.columns.add((New-Object system.Data.DataColumn 'Rehabilitation plan date'))
$ansnapTable.columns.add((New-Object system.Data.DataColumn 'Discharge plan date'))


Get-Content $hcp1InputFile | %{
    $line=$_

    # Parse an Episode line and add the record to the table
    if ($line[0] -eq 'E'){
        if ($line.length -ne 1371){
            throw "Episode line must be exactly 1371 characters long"
        }
        $episode = $episodeTable.NewRow()
        $episode['Insurer identifier']=$line.Substring(1,3).Trim()
        $episode['Link Identifier']=$line.Substring(4,24).Trim()
        $episode['Provider (hospital) code']=$line.Substring(28,8).Trim()
        #$episode['Product code']=$line.Substring(36,8).Trim()
        #$episode['Hospital contract status']=$line.Substring(44,1).Trim()
        $episode['Total days paid']=$line.Substring(45,4).Trim()
        #$episode['Accommodation charge']=$line.Substring(49,9).Trim()
        #$episode['Accommodation benefit']=$line.Substring(58,9).Trim()
        #$episode['Theatre charge']=$line.Substring(67,9).Trim()
        #$episode['Theatre benefit']=$line.Substring(76,9).Trim()
        #$episode['Labour ward charge']=$line.Substring(85,9).Trim()
        #$episode['Labour ward benefit']=$line.Substring(94,9).Trim()
        #$episode['Intensive Care Unit Charge']=$line.Substring(103,9).Trim()
        #$episode['Intensive Care Unit Benefit']=$line.Substring(112,9).Trim()
        #$episode['Prosthesis charge']=$line.Substring(121,9).Trim()
        #$episode['Prosthesis benefit']=$line.Substring(130,9).Trim()
        #$episode['Pharmacy charge']=$line.Substring(139,9).Trim()
        #$episode['Pharmacy benefit']=$line.Substring(148,9).Trim()
        #$episode['Bundled charges']=$line.Substring(157,9).Trim()
        #$episode['Bundled benefits']=$line.Substring(166,9).Trim()
        #$episode['Other charges']=$line.Substring(175,9).Trim()
        #$episode['Other benefits']=$line.Substring(184,9).Trim()
        #$episode['Front end deductible']=$line.Substring(193,9).Trim()
        #$episode['Ancillary cover status']=$line.Substring(202,1).Trim()
        #$episode['Ancillary charges']=$line.Substring(203,9).Trim()
        #$episode['Ancillary benefits']=$line.Substring(212,9).Trim()
        #$episode['Total Medical charges']=$line.Substring(221,9).Trim()
        #$episode['Total Medical Benefits']=$line.Substring(230,9).Trim()
        #$episode['Date of birth']=$line.Substring(239,8).Trim()
        $dob=[DateTime]::ParseExact($line.Substring(239,8).Trim(),'ddMMyyyy',$null)
        $span = [datetime]::Now - $dob
        $episode['Age']=[math]::floor($span.Days / 365)

        $episode['Postcode - Australian']=$line.Substring(247,4).Trim()
        $episode['Sex']=$line.Substring(251,1).Trim()
        $episode['Admission date']=$line.Substring(252,8).Trim()
        $episode['Separation date']=$line.Substring(260,8).Trim()
        $episode['Hospital type']=$line.Substring(268,1).Trim()
        $episode['ICU days']=$line.Substring(269,3).Trim()
        $episode['Diagnosis related group']=$line.Substring(272,4).Trim()
        $episode['DRG version']=$line.Substring(276,2).Trim()
        $episode['Admission time']=$line.Substring(278,4).Trim()
        $episode['Infant weight, neonate, stillborn']=$line.Substring(282,4).Trim()
        $episode['Hours of mechanical ventilation']=$line.Substring(286,4).Trim()
        $episode['Mode of separation']=$line.Substring(290,2).Trim()
        $episode['Separation time']=$line.Substring(292,4).Trim()
        $episode['Source of referral']=$line.Substring(296,1).Trim()
        $episode['Care Type']=$line.Substring(297,3).Trim()
        $episode['Total leave days']=$line.Substring(300,4).Trim()
        $episode['Non-Certified days of stay']=$line.Substring(304,4).Trim()
        $episode['Principal diagnosis']=$line.Substring(308,6).Trim()
        $episode['Additional diagnosis']=$line.Substring(314,294).Trim()
        $episode['Procedure ']=$line.Substring(608,350).Trim()
        $episode['Same-day status']=$line.Substring(958,1).Trim()
        $episode['Principal MBS item number']=$line.Substring(959,14).Trim()
        $episode['Principal Item Date']=$line.Substring(973,8).Trim()
        $episode['Minutes of operating theatre time']=$line.Substring(981,4).Trim()
        $episode['Secondary MBS item numbers ']=$line.Substring(985,126).Trim()
        $episode['Number of days of hospital-in-the-home care']=$line.Substring(1111,4).Trim()
        $episode['Total psychiatric care days']=$line.Substring(1115,5).Trim()
        $episode['Mental health legal status']=$line.Substring(1120,1).Trim()
        $episode['ICU hours']=$line.Substring(1121,4).Trim()
        $episode['Urgency of admission']=$line.Substring(1125,1).Trim()
        $episode['Inter-hospital contracted patient']=$line.Substring(1126,1).Trim()
        $episode['Palliative care Status']=$line.Substring(1127,1).Trim()
        $episode['Re-admission within 28 days']=$line.Substring(1128,1).Trim()
        $episode['Unplanned theatre visit during episode']=$line.Substring(1129,1).Trim()
        $episode['Provider number of hospital from which transferred']=$line.Substring(1130,8).Trim()
        $episode['Provider number of hospital to which transferred']=$line.Substring(1138,8).Trim()
        $episode['Discharge intention on admission']=$line.Substring(1146,1).Trim()
        $episode['Person Identifier']=$line.Substring(1147,21).Trim()
        $episode['Miscellaneous Service Codes']=$line.Substring(1168,110).Trim()
        #$episode['Hospital-in-the-home care Charges']=$line.Substring(1278,9).Trim()
        #$episode['Hospital-in-the-home care Benefits']=$line.Substring(1287,9).Trim()
        #$episode['Special Care Nursery Charges']=$line.Substring(1296,9).Trim()
        #$episode['Special Care Nursery Benefits']=$line.Substring(1305,9).Trim()
        #$episode['Coronary Care Unit Charges']=$line.Substring(1314,9).Trim()
        #$episode['Coronary Care Unit Benefits']=$line.Substring(1323,9).Trim()
        #$episode['Special Care Nursery Hours']=$line.Substring(1332,4).Trim()
        #$episode['Coronary Care Unit Hours']=$line.Substring(1336,4).Trim()
        $episode['Special Care Nursery Days']=$line.Substring(1340,3).Trim()
        $episode['Coronary Care Unit Days']=$line.Substring(1343,3).Trim()
        $episode['Number of Qualified Days for Newborns']=$line.Substring(1346,5).Trim()
        $episode['Hospital-in-the-home care Commencement Date']=$line.Substring(1351,8).Trim()
        $episode['Hospital-in-the-home care Completed Date']=$line.Substring(1359,8).Trim()
        $episode['Palliative Care Days']=$line.Substring(1367,4).Trim()
        $episodeTable.Rows.Add($episode)
    }

    # Parse an Medical line and add the record to the table
    if ($line[0] -eq 'M'){
        if ($line.length -ne 92){
            throw "Medical line must be exactly 92 characters long"
        }
        
        $medical = $medicalTable.NewRow()
        $medical['Insurer identifier']=$line.Substring(1,3).Trim()
        $medical['Link Identifier']=$line.Substring(4,24).Trim()
        $medical['MBS item ']=$line.Substring(28,14).Trim()
        #$medical['Item charge']=$line.Substring(42,9)
        $medical['MBS benefit']=$line.Substring(51,9).Insert(7,'.') # Spec dictates removal of currency decimal place to save precious bytes
        #$medical['Insurer benefit']=$line.Substring(60,9)
        $medical['MBS date of service']=$line.Substring(69,8).Trim()
        $medical['Medical Payment Type']=$line.Substring(77,1).Trim()
        #$medical['Gap Cover Scheme Identifier']=$line.Substring(78,5)
        $medical['MBS Fee']=$line.Substring(83,9).Insert(7,'.')
        $medicalTable.Rows.Add($medical)
    }
    
    # Parse an Prosthesis line and add the record to the table
    if ($line[0] -eq 'P'){
        if ($line.length -ne 54){
            throw "Prosthesis line must be exactly 54 characters long"
        }
        $prosthesis = $prosthesisTable.NewRow()
        $prosthesis['Insurer Identifier']=$line.Substring(1,3)
        $prosthesis['Link Identifier']=$line.Substring(4,24).Trim()
        $prosthesis['Prosthetic Item']=$line.Substring(28,5).Trim()
        $prosthesis['Number of Items']=$line.Substring(33,3).Trim()
        #$prosthesis['Total Prosthetic Item Charge']=$line.Substring(36,9)
        #$prosthesis['Total Prosthetic Item Benefit']=$line.Substring(45,9)
        $prosthesisTable.Rows.Add($prosthesis)
    }

    # Parse an AN-SNAP line and add the record to the table
    if ($line[0] -eq 'S'){
        if ($line.length -ne 95){
            throw "ANSNAP line must be exactly 95 characters long"
        }
        $ansnap = $ansnapTable.NewRow()
        $ansnap['Insurer Identifier']=$line.Substring(1,3).Trim()
        $ansnap['Link Identifier']=$line.Substring(4,24).Trim()
        $ansnap['Episode Type']=$line.Substring(28,1).Trim()
        $ansnap['Admission FIM  Item Scores']=$line.Substring(29,18).Trim()
        $ansnap['Discharge FIM Item Scores']=$line.Substring(47,18).Trim()
        $ansnap['AROC Impairment Codes']=$line.Substring(65,7).Trim()
        $ansnap['Assessment Only Indicator']=$line.Substring(72,1).Trim()
        $ansnap['AN-SNAP Class']=$line.Substring(73,4).Trim()
        $ansnap['SNAP Version']=$line.Substring(77,2).Trim()
        $ansnap['Rehabilitation plan date']=$line.Substring(79,8).Trim()
        $ansnap['Discharge plan date']=$line.Substring(87,8).Trim()

        $ansnapTable.Rows.Add($ansnap)
    }

    # Parse the trailer line and use it to cross-check record counts (occurs at end of file)
    if ($line[0] -eq 'T'){
        if ($line.length -ne 28){
            throw "ANSNAP line must be exactly 28 characters long"
        }
        $episodeRecordsCount=[int]$line.Substring(4,6)
        $medicalRecordsCount=[int]$line.Substring(10,6)
        $prostheticRecordsCount=[int]$line.Substring(16,6)
        $ansnapRecordsCount=[int]$line.Substring(22,6)
        if ($episodeTable.Rows.Count -ne $episodeRecordsCount){
            throw "Trailer row specified $episodeRecordsCount episode records, but $($episodeTable.Rows.Count) were encountered in the file"
        }
    }
}

$episodeTable | Export-Csv $episodesOutputFile -NoType
$medicalTable | Export-Csv $medicalOutputFile -NoType
$prosthesisTable | Export-Csv $prosthesisOutputFile -NoType
$ansnapTable | Export-Csv $ansnapOutputFile -NoType
