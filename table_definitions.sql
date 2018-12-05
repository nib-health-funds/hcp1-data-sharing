CREATE OR REPLACE TABLE EPISODES(
"Insurer identifier" char(3),
"Link Identifier" char(24),
"Provider (hospital) code" varchar(8),
"Total days paid" numeric,
"Age" numeric,
"Postcode - Australian" char(4),
"Sex" char(1),
"Admission date" date,
"Separation date" date,
"Hospital type" char(1),
"ICU days" numeric,
"Diagnosis related group" varchar(4),
"DRG version" varchar(2),
"Admission time" time,
"Infant weight, neonate, stillborn" numeric,
"Hours of mechanical ventilation" numeric,
"Mode of separation" varchar(2),
"Separation time" time,
"Source of referral" char(1),
"Care Type" varchar(3),
"Total leave days" numeric,
"Non-Certified days of stay" numeric,
"Principal diagnosis" varchar(6),
"Additional diagnosis" varchar(294),
"Procedure" varchar(350),
"Same-day status" char(1),
"Principal MBS item number" varchar(14),
"Principal Item Date" date,
"Minutes of operating theatre time" numeric,
"Secondary MBS item numbers" varchar(126),
"Number of days of hospital-in-the-home care" numeric,
"Total psychiatric care days" numeric,
"Mental health legal status" char(1),
"ICU hours" numeric,
"Urgency of admission" char(1),
"Inter-hospital contracted patient" char(1),
"Palliative care Status" char(1),
"Re-admission within 28 days" char(1),
"Unplanned theatre visit during episode" char(1),
"Provider number of hospital from which transferred" varchar(8),
"Provider number of hospital to which transferred" varchar(8),
"Discharge intention on admission" char(1),
"Person Identifier" varchar(21),
"Miscellaneous Service Codes" varchar(110),
"Special Care Nursery Hours" numeric,
"Coronary Care Unit Hours" numeric,
"Special Care Nursery Days" numeric,
"Coronary Care Unit Days" numeric,
"Number of Qualified Days for Newborns" numeric,
"Hospital-in-the-home care Commencement Date" date,
"Hospital-in-the-home care Completed Date" date,
"Palliative Care Days" numeric);

CREATE OR REPLACE TABLE MEDICAL(
"Insurer identifier" char(3),
"Link Identifier" char(24),
"MBS item" varchar(14),
"MBS benefit" numeric(10,2),
"MBS date of service" date,
"Medical Payment Type" char(1),
"MBS Fee" numeric(10,2));

CREATE OR REPLACE TABLE PROSTHESIS(
"Insurer identifier" char(3),
"Link Identifier" char(24),
"Prosthetic Item" varchar(5),
"Number of Items" numeric(3));
 
CREATE OR REPLACE TABLE ANSNAP(
"Insurer identifier" char(3),
"Link Identifier" char(24),
"Episode Type" char(1),
"Admission FIM  Item Scores" char(18),
"Discharge FIM Item Scores" char(18),
"AROC Impairment Codes" varchar(7),
"Assessment Only Indicator" char(1),
"AN-SNAP Class" varchar(4),
"SNAP Version" numeric(2),
"Rehabilitation plan date" date,
"Discharge plan date" date);
