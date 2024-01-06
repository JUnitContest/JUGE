
# TODO Automate the build of benchmarktool in a temporary container

FROM ubuntu:20.04
RUN apt-get update
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y unzip

# SMT Solver 
RUN apt-get install -y cvc4

# Copy the utility scripts to run the infrastructure
COPY infrastructure/scripts/ /usr/local/bin/

# [R](https://www.r-project.org)
RUN apt-get install -y libgmp-dev libmpfr-dev
RUN apt-get install -y r-base
RUN Rscript /usr/local/bin/get-libraries.R

# Copy dependencies
RUN mkdir -p /usr/local/bin/lib/
COPY infrastructure/lib/junit-4.12.jar /usr/local/bin/lib/junit.jar
COPY infrastructure/lib/hamcrest-core-1.3.jar /usr/local/bin/lib/hamcrest-core.jar
COPY infrastructure/lib/pitest-1.1.11.jar /usr/local/bin/lib/pitest.jar
COPY infrastructure/lib/pitest-command-line-1.1.11.jar /usr/local/bin/lib/pitest-command-line.jar
COPY infrastructure/lib/jacocoagent.jar /usr/local/bin/lib/jacocoagent.jar

# Copy the last version of the benchmarktool utilities
COPY benchmarktool/target/benchmarktool-1.0.0-shaded.jar /usr/local/bin/lib/benchmarktool-shaded.jar

# Copy the projects and configuration file to run the tools on a set of CUTs
RUN mkdir /var/benchmarks
COPY infrastructure/benchmarks/ /var/benchmarks/
RUN for f in /var/benchmarks/projects/*.zip; do unzip $f -d /var/benchmarks/projects/; done;
RUN rm -f /var/benchmarks/projects/*.zip
RUN rm -f /var/benchmarks/projects/*_split.z*

