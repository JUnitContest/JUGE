#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# This script runs Randoop on a given class-under-test for 10 seconds.
#
# Usage:
# ./run-randoop.sh
#   --class_under_test <fully qualified name>
#   --classpath <path>
#   --output_dir <path>
#   [--help]
# ------------------------------------------------------------------------------

SCRIPT_DIR=$(cd `dirname $0` && pwd)

#
# Print error message and exit
#
die() {
  echo "$@" >&2
  exit 1
}

# ------------------------------------------------------------------ Envs & Args

RANDOOP_JAR="$SCRIPT_DIR/../../../../tools/randoop/lib/randoop.jar"
# Check whether RANDOOP_JAR is set and exists
[ "$RANDOOP_JAR" != "" ] || die "RANDOOP_JAR is not set!"
[ -s "$RANDOOP_JAR" ] || die "$RANDOOP_JAR does not exist or it is empty!"

USAGE="Usage: ${BASH_SOURCE[0]} --class_under_test <fully qualified name> --classpath <path> --output_dir <path> [--help]"
if [ "$#" -ne "1" ] && [ "$#" -ne "6" ]; then
  die "$USAGE"
fi

CLASS_UNDER_TEST=""
CLASSPATH=""
OUTPUT_DIR=""

while [[ "$1" = --* ]]; do
  OPTION=$1; shift
  case $OPTION in
    (--class_under_test)
      CLASS_UNDER_TEST=$1;
      shift;;
    (--classpath)
      CLASSPATH=$1;
      shift;;
    (--output_dir)
      OUTPUT_DIR=$1;
      shift;;
    (--help)
      echo "$USAGE"
      exit 0
    (*)
      die "$USAGE";;
  esac
done

[ "$CLASS_UNDER_TEST" != "" ] || die "'--class_under_test' not defined. $USAGE"
[ "$CLASSPATH" != "" ]        || die "'--classpath' not defined. $USAGE"
[ "$OUTPUT_DIR" != "" ]       || die "'--output_dir' not defined. $USAGE"

mkdir -p "$OUTPUT_DIR/$CLASS_UNDER_TEST" # Create Randoop output dir

# ------------------------------------------------------------------------- Main

package_name=$(echo "$CLASS_UNDER_TEST" | sed 's/.[^.]*$//')

java -cp "$CLASSPATH:$RANDOOP_JAR" randoop.main.Main gentests \
  --testclass="$CLASS_UNDER_TEST" \
  --timelimit=10 \
  --junit-output-dir="$OUTPUT_DIR/$CLASS_UNDER_TEST" \
  --junit-package-name="$package_name" \
  --clear=10000 \
  --string-maxlen=5000 \
  --forbid-null=false \
  --null-ratio=0.1 \
  --no-error-revealing-tests=true \
  --omitmethods=random \
  --silently-ignore-bad-class-names=true \
  --testsperfile=100 \
  --ignore-flaky-tests=true || die "[ERROR] Failed to generate tests for $CLASS_UNDER_TEST!"

regression_test_suite_file="$OUTPUT_DIR/$CLASS_UNDER_TEST/$(echo $package_name | tr '.' '/')/RegressionTest0.java"
[ -s "$regression_test_suite_file" ] || die "[ERROR] $regression_test_suite_file does not exist or it is empty!"

echo "DONE!"
exit 0
