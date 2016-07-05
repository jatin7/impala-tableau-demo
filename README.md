# Fast Big Data Analytics with Impala and Tableau

Recreate the demo setup and try Apache Impala yourself to evaluate.
You will find all notes and links on solution architecture, helper files, Tableau workbook
and information to recreate the demo, as presented at the
[ DFW Cloudera User Group](http://www.meetup.com/DFW-Cloudera-User-Group/events/230547045/)
Meetup event on 06/30/2016.

A [PDF copy of the presentation](Apache%20Impala%20Meetup%20v2.pdf) is included in the repo. If you have any questions, contact information is available in the deck. 

## Setup
We have used the following cluster configuration for the demo, on AWS.
* Nodes: 1 Name Node + 3 Data Nodes
* ECS Instance Type : m4.4xlarge
* Instance Config: 64GB RAM, 100GB Storage

### 1. Setting up Cluster
To setup cluster, suggest using Cloudera Director. Follow [instructions here](http://www.cloudera.com/documentation/director/latest/topics/director_get_started_aws.html#concept_td3_wk5_ht) to setup the cluster on AWS. 

There is also a Quickstart template on AWS to setup the cluster. See [instructions here](http://docs.aws.amazon.com/quickstart/latest/cloudera/welcome.html).

You can also use a single node on your desktop in a VM. Follow [instructions here to setup a Quickstart VM ](https://www.cloudera.com/developers/get-started-with-hadoop-tutorial.html) on your desktop.

### 2. Flight On-Time Performance Dataset
Flight on-time performance data is available at [Bureau Of Transportation Statistics (BTS)](http://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=236&DB_Short_Name=On-Time). One CSV file is available for each month of data reported. Users can select list of columns and download data for a given month. [Data dictionary](http://www.transtats.bts.gov/Fields.asp?Table_ID=236) for the data can be reviewed [here](http://www.transtats.bts.gov/Fields.asp?Table_ID=236).

**Note on file format**: Data files downloaded are comma separated, with "(double quotes) used as escape character for string data. When the data is loaded to impala, the escape characters are included in the data by default. We used **sed** to change files from comma separated to | separated and stripped all double quotes from the CSV files. 

The bash shell script, download.sh (included in the repo) downloads all 12 files given a year, unzip files, cleanup files as explained above and delete those zip files.

```bash
download.sh <year>
```

Run the above script for each year that you are interested in to download data. For the demo we have loaded data from 2010 through April 2016.

### 3. Loading data to Impala
* Create a folder in HDFS
```bash
sudo -u hdfs hdfs dfs -mkdir <HDFS Folder>
```

* Copy all folders/files to HDFS to the designated folder.
```bash
hadoop fs -copyFromLocal *.csv <HDFS Folder>

#Example
hadoop fs -copyFromLocal *.csv /user/admin/flight_data
```

* Create table definition, pointing to the files in the HDFS folder. You can execute this SQL script either from Hue or from Impala Shell.
```sql
CREATE EXTERNAL TABLE flight_data(
   Year INT,
   Quarter INT,
   Month INT,
   DayofMonth INT,
   DayOfWeek INT,
   FlightDate TIMESTAMP,
   UniqueCarrier STRING,
   AirlineID INT,
   Carrier STRING,
   TailNum STRING,
   FlightNum INT,
   OriginAirportID INT,
   OriginAirportSeqID INT,
   OriginCityMarketID INT,
   Origin STRING,
   OriginCityName STRING,
   OriginState STRING,
   OriginStateFips INT,
   OriginStateName STRING,
   OriginWac INT,
   DestAirportID INT,
   DestAirportSeqID INT,
   DestCityMarketID INT,
   Dest STRING,
   DestCityName STRING,
   DestState STRING,
   DestStateFips INT,
   DestStateName STRING,
   DestWac STRING,
   CRSDepTime INT,
   DepTime INT,
   DepDelay FLOAT,
   DepDelayMinutes FLOAT,
   DepDel15 INT,
   DepartureDelayGroups INT,
   DepTimeBlk STRING,
   TaxiOut FLOAT,
   WheelsOff INT,
   WheelsOn INT,
   TaxiIn FLOAT,
   CRSArrTime INT,
   ArrTime INT,
   ArrDelay FLOAT,
   ArrDelayMinutes FLOAT,
   ArrDel15 INT,
   ArrivalDelayGroups INT,
   ArrTimeBlk STRING,
   Cancelled INT,
   CancellationCode STRING,
   Diverted INT,
   CRSElapsedTime INT,
   ActualElapsedTime INT,
   AirTime FLOAT,
   Flights INT,
   Distance FLOAT,
   DistanceGroup INT,
   CarrierDelay FLOAT,
   WeatherDelay FLOAT,
   NASDelay FLOAT,
   SecurityDelay FLOAT,
   LateAircraftDelay FLOAT,
   FirstDepTime INT,
   TotalAddGTime INT,
   LongestAddGTime INT,
   DivAirportLandings INT,
   DivReachedDest INT,
   DivActualElapsedTime INT,
   DivArrDelay FLOAT,
   DivDistance FLOAT,
   Div1Airport INT,
   Div1AirportID INT,
   Div1AirportSeqID INT,
   Div1WheelsOn INT,
   Div1TotalGTime INT,
   Div1LongestGTime INT,
   Div1WheelsOff INT,
   Div1TailNum INT,
   Div2Airport INT,
   Div2AirportID INT,
   Div2AirportSeqID INT,
   Div2WheelsOn INT,
   Div2TotalGTime INT,
   Div2LongestGTime INT,
   Div2WheelsOff INT,
   Div2TailNum INT,
   Div3Airport INT,
   Div3AirportID INT,
   Div3AirportSeqID INT,
   Div3WheelsOn INT,
   Div3TotalGTime INT,
   Div3LongestGTime INT,
   Div3WheelsOff INT,
   Div3TailNum INT,
   Div4Airport INT,
   Div4AirportID INT,
   Div4AirportSeqID INT,
   Div4WheelsOn INT,
   Div4TotalGTime INT,
   Div4LongestGTime INT,
   Div4WheelsOff INT,
   Div4TailNum INT,
   Div5Airport INT,
   Div5AirportID INT,
   Div5AirportSeqID INT,
   Div5WheelsOn INT,
   Div5TotalGTime INT,
   Div5LongestGTime INT,
   Div5WheelsOff INT,
   Div5TailNum INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|' location '/user/admin/flight_data';
```

* Compute stats
```sql
compute stats default.flight_data
```

* If you add additional files to HDFS folder after the table is created, you can refresh the metastore to load all new data.
```sql
REFRESH flight_data;
```

* To load invidual files, use the explicit load command. 
```sql
load data inpath '<datafilepath>' overwrite into table flight_data;
```

### 4. Accessing from Tableau

* Download and install Cloudera Impala ODBC Driver from [Cloudera ODBC driver downloads page](http://www.cloudera.com/downloads/connectors/impala/odbc/2-5-33.html).
* Start Tableau Desktop Professional and choose "Cloudera Hadoop" Server
* Specify the Server IP Address/hostname of the cluster and port number (default port: 20150) and choose "Impala" from the Type dropdown.
* Choose the authentication mechanism configured on the cluster and fill-in information appropriately
* Once connected, choose the Schema name (default) and choose the table(s). For the demo, choose default schema and flight_data table
* Viola! Everything is ready. Go ahead and build your dashboard using the data.

#### Using Tableau Demo Workbook
* Open the Tableau workbook
* From the data source pane, click on the datasource IP Address/hostname. This will pop open the Clouder Hadoop server connection window. Update your server address (and authentication information) and you are ready to refresh the data. 


### 5. (Optional) Store data in [Parquet](https://parquet.apache.org/) format

We can easily convert existing data stored in CSV files to parquet format
```sql
create table par.flight_data stored as parquet as select * from default.flight_data 
```

## Links
* [Apache Impala (incubating)](http://impala.io/)
* [Cloudera Downloads](http://www.cloudera.com/downloads.html)
* [Impala ODBC Drivers](http://www.cloudera.com/downloads/connectors/impala/odbc/2-5-33.html)
* [Cluster Sizing Guidelines for Impala](http://www.cloudera.com/documentation/enterprise/latest/topics/impala_cluster_sizing.html)
* [Documentation on Impala](http://www.cloudera.com/documentation/enterprise/latest/topics/impala.html)

