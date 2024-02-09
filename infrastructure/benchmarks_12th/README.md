# SBFT Tool Competition 2024 - Java Test Case Generation Track

## Subjects

- (Bytecode Manipulation) [Byte Buddy (byte-buddy-dep module) v1.14.11](https://github.com/raphw/byte-buddy/tree/byte-buddy-1.14.11): Further simplifies bytecode generation with a fluent API.
- (Code Analysis) [Error Prone (core module) v2.10.0](https://github.com/google/error-prone/tree/v2.10.0): Catches common programming mistakes as compile-time errors.
- (Code Generators) [JavaPoet v1.13.0](https://github.com/square/javapoet/tree/javapoet-1.13.0): API to generate source files.

```
# Check for the `tools.jar`, is it really needed?  Most likely it is not.

mvn dependency:build-classpath -DincludeScope=compile -Dmdep.pathSeparator="," -Dmdep.outputFile=target/dependency/cp.txt
cat target/dependency/cp.txt | sed "s|$HOME/.m2/repository/||g" # TODO replace it /var/benchmarks/projects/<project>/target/dependency/

mvn dependency:copy-dependencies -DincludeScope=compile -DoutputDirectory=target/dependency
```

| Project     | # CUTs | # Branches             | Complexity              |
|------------:|-------:|-----------------------:|------------------------:|
| byte-buddy  |    200 | 14.09 (min=0, max=149) | 15.48 (min=1,  max=220) |
| error-prone |    816 | 16.12 (min=0, max=160) | 14.58 (min=1,  max=163) |
| javapoet    |     17 | 45.12 (min=6, max=150) | 38.71 (min=15, max=117) |
| *total*     |   1033 |                        |                         |

Among all 1033 classes across three projects, we only kept the ones that (i)
have at least two branches and (ii) have at least one method with McCabe's
cyclomatic complexity higher than five.  To calculate the number of branches in
each class and the cyclomatic complexity of each method in that class we used
the [JaCoCo](https://www.eclemma.org/jacoco) code coverage tool.  This filtering
step left us with a set of 601 classes (see the following table).

<!--
Rscript projects/scripts/filter-out-classes.R projects/data/byte-buddy.txt projects/data/byte-buddy-filtered-out.txt
Rscript projects/scripts/filter-out-classes.R projects/data/error-prone.txt projects/data/error-prone-filtered-out.txt
Rscript projects/scripts/filter-out-classes.R projects/data/javapoet.txt projects/data/javapoet-filtered-out.txt
-->

| Project     | # Filtered CUTs | # Branches              | Complexity            |
|------------:|----------------:|------------------------:|----------------------:|
| byte-buddy  |             128 | 15.82 (min=7,  max=142) |  9.34 (min=5, max=74) |
| error-prone |             461 | 18.90 (min=6,  max=136) | 11.07 (min=5, max=76) |
| javapoet    |              12 | 42.75 (min=10, max=110) | 24.67 (min=6, max=66) |
| *total*     |             601 |                         |                       |

Then, we filtered out all the classes that are *non-testable*.  We verified
testability by running the [Randoop](https://randoop.github.io/randoop) test
case generation tool for 10 seconds and checking whether any test case was
generated.  If that was not the case, the class was classified as
*non-testable*, and *testable* otherwise.  This filtering step left us with a
set of 563 classes (see the following table).  Most of the classes that were
considered *non-testable* were abstract classes.

<!--
Rscript projects/scripts/testable-classes.R projects/data/byte-buddy-filtered-out.txt projects/data/byte-buddy-gen-tests.txt projects/data/byte-buddy-testable.txt
Rscript projects/scripts/testable-classes.R projects/data/error-prone-filtered-out.txt projects/data/error-prone-gen-tests.txt projects/data/error-prone-testable.txt
Rscript projects/scripts/testable-classes.R projects/data/javapoet-filtered-out.txt projects/data/javapoet-gen-tests.txt projects/data/javapoet-testable.txt
-->

| Project     | # Testable CUTs | # Branches              | Complexity            |
|------------:|----------------:|------------------------:|----------------------:|
| byte-buddy  |             122 | 15.81 (min=7,  max=142) |  9.34 (min=5, max=74) |
| error-prone |             429 | 18.78 (min=6,  max=136) | 11.00 (min=5, max=76) |
| javapoet    |              12 | 42.75 (min=10, max=110) | 24.67 (min=6, max=66) |
| *total*     |             563 |                         |                       |

Based on the time and resources available for running the competition, we
randomly sampled 10% of all testable classes, per project, to use as our
benchmark.  This filtering step left us with a set of 58 classes (see the
following table).

<!--
Rscript projects/scripts/sample-classes.R projects/data/byte-buddy-testable.txt projects/data/byte-buddy-sample.txt
Rscript projects/scripts/sample-classes.R projects/data/error-prone-testable.txt projects/data/error-prone-sample.txt
Rscript projects/scripts/sample-classes.R projects/data/javapoet-testable.txt projects/data/javapoet-sample.txt
-->

| Project     | # Sampled CUTs | # Branches             | Complexity             |
|------------:|---------------:|-----------------------:|-----------------------:|
| byte-buddy  |             13 | 15.15 (min=7,  max=32) |  9.00 (min=6,  max=18) |
| error-prone |             43 | 18.09 (min=8,  max=66) | 10.51 (min=5,  max=36) |
| javapoet    |              2 | 23.50 (min=21, max=26) | 15.50 (min=15, max=16) |
| *total*     |             58 |                        |                        |

### Runs

Tools:
- randoop
- evofuzz
- evosuite
- kex
- evokex

Time budget:
- 30 seconds
- 120 seconds

Repetitions: 10

58 CUTs x 5 tools x 2 time budgets x 10 repetitions = 5,800 executions in total

58 CUTs x 5 tools x 10 repetitions x  30 seconds =  87,600 seconds ~  24.3 hours ~ 1 day
58 CUTs x 5 tools x 10 repetitions x 120 seconds = 348,000 seconds ~  96.7 hours ~ 4 days
                                                 = 435,500 seconds ~ 120.9 hours ~ 5 days

## Miscellaneous

- `infrastructure/scripts/contest_generate_tests.sh` and `infrastructure/scripts/contest_compute_metrics.sh`
have been modified to run `infrastructure/scripts/contest_run_benchmark_tool_on_error-prone.sh`
instead of `infrastructure/scripts/contest_run_benchmark_tool.sh` when the `error-prone`
project is called.  The `infrastructure/scripts/contest_run_benchmark_tool_on_error-prone.sh` basically
runs `java -Xbootclasspath/p:/var/benchmarks/projects/error-prone/core/target/dependency/javac-9+181-r4173-1.jar`
rather than just as `java` as suggested in [here](https://github.com/google/error-prone/blob/v2.10.0/pom.xml#L239).

## Util commands

### 30 seconds :: 10 seeds

#### randoop

```
docker run -v $(pwd)/tools/randoop:/home/randoop -it junitcontest/infrastructure:latest
cd /home/randoop
contest_generate_tests.sh randoop 10 1 30
contest_compute_metrics.sh /home/randoop/results_randoop_30 > /home/randoop/results_randoop_30/stat_log.txt 2> /home/randoop/results_randoop_30/error_log.txt
```

#### evofuzz

```
docker run -v $(pwd)/tools/evofuzz:/home/evofuzz -it junitcontest/infrastructure:latest
cd /home/evofuzz
contest_generate_tests.sh evofuzz 10 1 30
contest_compute_metrics.sh /home/evofuzz/results_evofuzz_30 > /home/evofuzz/results_evofuzz_30/stat_log.txt 2> /home/evofuzz/results_evofuzz_30/error_log.txt
```

#### kex

```
docker run -v $(pwd)/tools/kex:/home/kex -it junitcontest/infrastructure:latest
cd /home/kex
contest_generate_tests.sh kex 10 1 30
contest_compute_metrics.sh /home/kex/results_kex_30 > /home/kex/results_kex_30/stat_log.txt 2> /home/kex/results_kex_30/error_log.txt
```

#### evokex

```
docker run -v $(pwd)/tools/evokex:/home/evokex -it junitcontest/infrastructure:latest
cd /home/evokex
contest_generate_tests.sh evokex 10 1 30
contest_compute_metrics.sh /home/evokex/results_evokex_30 > /home/evokex/results_evokex_30/stat_log.txt 2> /home/evokex/results_evokex_30/error_log.txt
```

#### evosuite

```
docker run -v $(pwd)/tools/evosuite:/home/evosuite -it junitcontest/infrastructure:latest
cd /home/evosuite
contest_generate_tests.sh evosuite 10 1 30
contest_compute_metrics.sh /home/evosuite/results_evosuite_30 > /home/evosuite/results_evosuite_30/stat_log.txt 2> /home/evosuite/results_evosuite_30/error_log.txt
```

### 120 seconds :: 10 seeds

#### randoop

```
docker run -v $(pwd)/tools/randoop:/home/randoop -it junitcontest/infrastructure:latest
cd /home/randoop
contest_generate_tests.sh randoop 10 1 120
contest_compute_metrics.sh /home/randoop/results_randoop_120 > /home/randoop/results_randoop_120/stat_log.txt 2> /home/randoop/results_randoop_120/error_log.txt
```

#### evofuzz

```
docker run -v $(pwd)/tools/evofuzz:/home/evofuzz -it junitcontest/infrastructure:latest
cd /home/evofuzz
contest_generate_tests.sh evofuzz 10 1 120
contest_compute_metrics.sh /home/evofuzz/results_evofuzz_120 > /home/evofuzz/results_evofuzz_120/stat_log.txt 2> /home/evofuzz/results_evofuzz_120/error_log.txt
```

#### kex

```
docker run -v $(pwd)/tools/kex:/home/kex -it junitcontest/infrastructure:latest
cd /home/kex
contest_generate_tests.sh kex 10 1 120
contest_compute_metrics.sh /home/kex/results_kex_120 > /home/kex/results_kex_120/stat_log.txt 2> /home/kex/results_kex_120/error_log.txt
```

#### evokex

```
docker run -v $(pwd)/tools/evokex:/home/evokex -it junitcontest/infrastructure:latest
cd /home/evokex
contest_generate_tests.sh evokex 10 1 120
contest_compute_metrics.sh /home/evokex/results_evokex_120 > /home/evokex/results_evokex_120/stat_log.txt 2> /home/evokex/results_evokex_120/error_log.txt
```

#### evosuite

```
docker run -v $(pwd)/tools/evosuite:/home/evosuite -it junitcontest/infrastructure:latest
cd /home/evosuite
contest_generate_tests.sh evosuite 10 1 120
contest_compute_metrics.sh /home/evosuite/results_evosuite_120 > /home/evosuite/results_evosuite_120/stat_log.txt 2> /home/evosuite/results_evosuite_120/error_log.txt
```
