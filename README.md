# JUnit Tool Contest Infrastructure

The JUnit tool contest is held at the SBST workshop co-located with ICSE.
Here you will find the source code to the contest infrastructure and instructions on how to test your tool with the infrastructure before submitting it to the competition.

# Important dates

Definitive dates will be announce upon acceptance of the workshop at ICSE'20. Here are the planned periods:

- Tool submission: early February
- Benchmark results communicated to authors: mid February
- Authors submit camera ready paper: mid March

# Try it via Docker

For easier access and use, this year we have dockerized the contest infrastructure. Here are the instructions for testing your tool via docker:

## Prerequisites:

Install the docker software on your machine. Docker is available for Linux, Mac and Windows. For installation please follow the instructions for your operating system:
- Windows: https://docs.docker.com/docker-for-windows/install/
- Mac: https://docs.docker.com/docker-for-mac/install/
- Linux/Ubuntu: https://docs.docker.com/install/linux/docker-ce/ubuntu/#extra-steps-for-aufs

The command to run the docker image that contains the junit contest infrastructure is the following:
```sh
$ docker run -v /path/to/host/folder:/path/to/container/folder --name=junitcontest -it dockercontainervm/junitcontest:test
```

* -v: it is needed to specify the tool folder in the host machine that needs to be attached to the docker container. For example:
```sh
$ docker run -v ~/Desktop/randoop/:/home/randoop --name=junitcontest -it dockercontainervm/junitcontest:test
```
The randoop folder under the Desktop folder in host machine is mapped to the randoop folder under the home folder in the docker container (guest). The randoop folder in the host machine is shared with the container, therefore every file written in this folder will be in both the host and the guest machines.

* --name=junitcontest: it is the name of the container (junitcontest in this case). The name is optional, if skipped Docker assigns a random name automatically.

* -it: it means that the user can access the docker container interactively, as if the user was in the command line of the guest system.

* dockercontainervm/junitcontest:test: it is the name of the docker image. The first time the command is run, docker automatically downloads the image from a public repository. Once the image is in the system, docker simply uses it. The image is built upon the last version of Ubuntu (18.04 LTS).

Once you execute the docker run command, you are in the docker container. Move to the container folder where you mapped the tool, using the -v option (in the example is /home/randoop). The tool folder must meet the requirements specified in [DETAILS.md](/DETAILS.md) . For an example of a correct tool folder please see: [RANDOOP](https://github.com/PROSRESEARCHCENTER/junitcontest/tree/master/tools/randoop).
(If you use the randoop tool from the github repository above, make sure to change the variable JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 to JAVA_HOME=/usr in the "runtool" script)

If the tool satisfies the requirements, from the tool folder (/home/randoop), run:
```sh
$ contest_generate_tests.sh tool-name runs-number runs-start-from time-budget-seconds
```

For example:
```sh
$ contest_generate_tests.sh randoop 1 1 10
```
This script runs one excution of the test generation tool randoop for 10 seconds.

As the generation goes on, you should see files written in the shared folder in the host machine (in the example ~/Desktop/randoop).

To compute the metrics (i.e., coverage and mutation score) for the test cases generated by the command in the previous example, run the following command, from the same directory:
```sh
$ contest_compute_metrics.sh results_randoop_10 > stat_log.txt 2> error_log.txt
```
Note that the folder `results_randoop_10` is automatically generated by the `contest_generate_tests.sh` script and contains, among other things, the test cases generated.

Once you are done, you can exit from the container by running:
```sh
$ exit
```
The command brings you back to the host machine.

Optionally you can remove the container by running:
```sh
$ docker rm <container-name>
```
For the example, run:
```sh
$ docker rm junitcontest
```
Other docker commands:
```sh
$ docker ps: shows all running containers
$ docker ps -a: shows all containers (in every status)
```

# Try it via manual installation
You can also install the contest infrastructure directly on your machine and test your tool. Below you find basic information and detailed instructions.

Target: Linux (Ubuntu x64)

Folder contents:

* [bin](/infrastructure):   Contest infrastructure binaries
* [src](/src):   Contest infrastructure source code
* [tools](/tools): Contest tools

Requirements:

Java8 (JDK):
```sh
$ apt-get install default-jdk
```
Installation instructions:

For detailed instructions see [DETAILS](/DETAILS)


# About the contest

This is the source code for the contest infrastructure for junit testing tools.
The contest was initiated during the FITTEST European project no. 257574 (2010-2013)
and hence partly funded by the FP7 programme on ICT Software & Service Architectures and Infrastructures.

The [FITTEST](http://crest.cs.ucl.ac.uk/fittest/) project, which developed an integrated environment for the automated and continuous testing of Future Internet Applications, was coordinated by:

  Tanja E. J. Vos (tvos@pros.upv.es)
  Software Quality & Testing
  Research Center on Software Production Methods ([PROS](http://www.pros.webs.upv.es/))
  Department of Information Systems and Computation ([DSIC](http://www.upv.es/entidades/DSIC/index.html))
  Universitat Politècnica de València ([UPV](http://www.upv.es/))
  Camino de Vera s/n, 46022 Valencia (Spain)

The contest infrastructure has been used in testing contests during yearly events since 2013 (check the [Acknowledgements](ACKNOWLEDGEMENTS.md) and [Publications](PUBLICATIONS.md)).

# Publications

For publications from previous editions see [PUBLICATIONS](/PUBLICATIONS.md).
