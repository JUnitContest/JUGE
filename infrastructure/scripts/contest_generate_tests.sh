#!/bin/bash

# author: Urko Rueda (2018)

if [ $# -ne 4 ]
then
        echo "Usage <tool-name> <runs-number> <runs-start-from> <time-budget (seconds)>"
        echo "example: contest_generate_tests.sh myToolName 6 7 60"
        exit 0;
fi

# Contest benchmarks (CUTs)
BENCH_HOME=/var/benchmarks
CONF=$BENCH_HOME/conf/benchmarks.list

BENCH_SUTS=$(cat $CONF | grep -E "(\w+-[0-9]+=)+" | awk -F'=' '{print $1}')
echo Benchmark SUTs: $BENCH_SUTS

RESULTS_DIR=results_$1_$4
mkdir -p $RESULTS_DIR
runstop=$(( $2 + $3 ))
for ((RUN=$3; RUN<$runstop; RUN++));
do
	echo "RUN: $RUN"
	# Contest benchmarks
	for SUT in $BENCH_SUTS
        do
          SUT_RUN_DIR=$RESULTS_DIR/$SUT\_$RUN
		if [ -d $SUT_RUN_DIR ]; then
			echo "Folder $SUT_RUN_DIR already exists. Skipping"
		else
	                mkdir -p $SUT_RUN_DIR
        	        >&2 echo "Running SUT = $SUT; RUN = $RUN at $(date)"
                  if echo "$SUT" | grep -q "ERRORPRONE"; then
                          contest_run_benchmark_tool_on_error-prone.sh $1 $SUT . $RUN $4 --only-generate-tests
                  else
                          contest_run_benchmark_tool.sh $1 $SUT . $RUN $4 --only-generate-tests
                  fi
                	>&2 echo "... moving run results to: $SUT_RUN_DIR at $(date)"
                	>&2 echo ""
                	mv log.txt $SUT_RUN_DIR
                	mv log_detailed.txt $SUT_RUN_DIR
                	mv transcript.csv $SUT_RUN_DIR
                	mv temp $SUT_RUN_DIR
                        mv *.log $SUT_RUN_DIR

			# contest tool specific code
			if [ $1 == "t3" ]; then
				# T3 tool: trdir patch
				mv trdir $SUT_RUN_DIR
			fi

			touch $SUT_RUN_DIR/GENERATION_FINISHED.txt
		fi
        done
done
