#!/bin/bash
# This job copies Sample PySpark script and some test data to your S3 bucket which will enable you to run the following Spark Operator script

# Prerequisites for running this shell script
#     1/ Execute the shell script with the required arguments
#         ./your_script.sh <S3_BUCKET> <REGION> <JOB_NAME>
#     2/ Ensure <S3_BUCKET> and <JOB_NAME> is replaced in "ebs-storage-dynamic-pvc.yaml" file
#     3/ Execute the shell script which creates the input data in your S3 bucket
#     4/ Run `kubectl apply -f ebs-storage-dynamic-pvc.yaml` to trigger the Spark job
#     5/ Monitor the Spark job using "kubectl get pods -n spark-team-a -w"

# Script usage ./taxi-trip-execute my-s3-bucket us-west-2 nvme-taxi-trip

if [ $# -ne 3 ]; then
  echo "Usage: $0 <S3_BUCKET> <REGION> <JOB_NAME>"
  exit 1
fi

S3_BUCKET="$1"
REGION="$2"
JOB_NAME="$3"

INPUT_DATA_S3_PATH="s3://${S3_BUCKET}/${JOB_NAME}/input/"

# Copy PySpark Script to S3 bucket
aws s3 cp pyspark-taxi-trip.py s3://${S3_BUCKET}/${JOB_NAME}/scripts/ --region ${REGION}

# Copy Test Input data to S3 bucket
wget https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2022-01.parquet -O "input/yellow_tripdata_2022-0.parquet"

# Making duplicate copies to increase the size of the data.
max=20
for (( i=1; i <= $max; ++i ))
do
   cp -rf "input/yellow_tripdata_2022-0.parquet" "input/yellow_tripdata_2022-${i}.parquet"
done

aws s3 sync "input/" ${INPUT_DATA_S3_PATH}
