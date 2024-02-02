#!/bin/bash

# switch to environment JVM as needed
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
#JAVA_HOME=/usr
JAVAC_CMD=$JAVA_HOME/bin/javac
JAVA_CMD=$JAVA_HOME/bin/java

# Contest tool
TOOL_HOME=/usr/local/bin
JAR=$TOOL_HOME/lib/benchmarktool-shaded.jar
# dependencies
JUNIT_JAR=$TOOL_HOME/lib/junit.jar
JUNIT_DEP_JAR=$TOOL_HOME/lib/hamcrest-core.jar
PITEST_JAR=$TOOL_HOME/lib/pitest.jar:$TOOL_HOME/lib/pitest-command-line.jar
JACOCO_JAR=$TOOL_HOME/lib/jacocoagent.jar

# Contest benchmarks (CUTs)
BENCH_HOME=/var/benchmarks
CONF=$BENCH_HOME/conf/benchmarks.list

echo "---------"
echo "SBST-Contest"
$JAVA_HOME/bin/java -version
echo "---------"
exec $JAVA_CMD -ea -Dsbst.benchmark.jacoco="$JACOCO_JAR" \
	-Dsbst.benchmark.java="$JAVA_CMD" \
	-Dsbst.benchmark.javac="$JAVAC_CMD" \
	-Dsbst.benchmark.config="$CONF" \
	-Dsbst.benchmark.junit="$JUNIT_JAR" \
	-Dsbst.benchmark.junit.dependency="$JUNIT_DEP_JAR" \
	-Dsbst.benchmark.pitest="$PITEST_JAR" \
	-jar "$JAR" $*
