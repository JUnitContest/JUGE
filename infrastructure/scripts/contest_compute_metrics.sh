#!/bin/bash

# authors: Juan Galeotti and Urko Rueda (2016)

if [ $# -ne 1 ]
then
        echo "Results folder is expected"
        echo "example: contest_compute_metrics.sh /home/randoop_4h/results_Randoop_60sec"
        exit 0;
fi

RESULTS_DIR=$1
echo "Results folder is `basename $RESULTS_DIR`"
RESULTS_DIRNAME=`basename $RESULTS_DIR`
oldIFS="$IFS"
set -- "$RESULTS_DIRNAME"
IFS="_"; declare -a Array=($*)
echo "${Array[@]}"
echo "${Array[0]}"
TOOLNAME=${Array[1]}
echo "TOOLNAME=$TOOLNAME"
BUDGET=${Array[2]}
echo "BUDGET=$BUDGET"
IFS=$oldIFS
echo "Searching folders in directory $RESULTS_DIR"
for f in `find $RESULTS_DIR -name '*-*_*'`; do
	echo "========================================="
	echo "Folder $f was found"
	FOLDER_NAME=`basename $f`
	echo "FolderName=$FOLDER_NAME"
	
	if [ -d $RESULTS_DIR/$FOLDER_NAME/metrics ]; then
		echo "metrics folder for $FOLDER_NAME already exists. Skipping"
		continue
	fi	
	
	oldIFS="$IFS"
	set -- "$FOLDER_NAME"
	IFS="_"; declare -a Array=($*)
	SUT_ID=${Array[0]}
	echo "SUT_ID=$SUT_ID"
	RUN_ID=${Array[1]}
	echo "RUN_ID=$RUN_ID"
	IFS=$oldIFS
	TEMP_FOLDER=$RESULTS_DIR/$FOLDER_NAME/temp

	# contest tool specific code
	if [ $TOOLNAME == "t3" ]; then
		# T3 tool: trdir patch
		rm -rf trdir
		cp -R $RESULTS_DIR/$FOLDER_NAME/trdir trdir
	fi

	TESTCASES_FOLDER=$RESULTS_DIR/$FOLDER_NAME/temp/testcases
	echo "TESTCASES_FOLDER=$TESTCASES_FOLDER"
	CMD="contest_run_benchmark_tool.sh $TOOLNAME $SUT_ID . $RUN_ID $BUDGET --only-compute-metrics $TESTCASES_FOLDER"
	if echo "$SUT_ID" | grep -q "ERRORPRONE"; then
		CMD="contest_run_benchmark_tool_on_error-prone.sh $TOOLNAME $SUT_ID . $RUN_ID $BUDGET --only-compute-metrics $TESTCASES_FOLDER"
	fi
	echo "Executing metrics computation using $CMD"
	$CMD
	TRANSCRIPT_FILE="transcript.csv"
	echo "Copying transcript file $TRANSCRIPT_FILE to folder $f"
	cp $TRANSCRIPT_FILE $f/
	echo "Moving working folders and log files"
	METRICS_FOLDER=$RESULTS_DIR/$FOLDER_NAME/metrics
	mkdir -p $METRICS_FOLDER
	mv log.txt $METRICS_FOLDER
	mv log_detailed.txt $METRICS_FOLDER
	mv temp $METRICS_FOLDER
	mv $TRANSCRIPT_FILE $METRICS_FOLDER
        mv *.log $METRICS_FOLDER

	# contest tool specific code
	if [ $TOOLNAME == "t3" ]; then
		# T3 tool: trdir patch
		rm -rf trdir
	fi

	touch $METRICS_FOLDER/COMPUTATION_FINISHED.txt
	echo "Processing of folder $f has finished"
done
