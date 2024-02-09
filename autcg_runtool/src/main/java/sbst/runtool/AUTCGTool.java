package sbst.runtool;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.io.IOException;

public class AUTCGTool implements ITestingTool {

    /**
     * The class under test classpath
     */
    private String cutClassPath;

    /**
     * List of additional class path entries required by a testing tool
     *
     * @return List of directories/jar files
     */
    @Override
    public List<File> getExtraClassPath() {
        List<File> files = new ArrayList();
        File smtut = new File("lib", "smartut-master-1.1.0.jar");
        if (!smtut.exists()) {
            System.err.println("Wrong smartut-master-1.1.0 jar setting, jar is not at: " + smtut.getAbsolutePath());
        } else {
            files.add(smtut);
        }
        return files;
    }

    /**
     * Initialize the testing tool, with details about the code to be tested (SUT)
     * Called only once.
     *
     * @param src       Directory containing source files of the SUT
     * @param bin       Directory containing class files of the SUT
     * @param classPath List of directories/jar files (dependencies of the SUT)
     */
    @Override
    public void initialize(File src, File bin, List<File> classPath) {
        StringBuilder sb = new StringBuilder();
        sb.append(bin.getAbsolutePath());
        for (File f : classPath) {
            sb.append(File.pathSeparator);
            sb.append(f.getAbsolutePath());
        }
        this.cutClassPath = sb.toString();
    }

    /**
     * Run the test tool, and let it generate test cases for a given class
     *
     * @param cName Name of the class for which unit tests should be generated
     */
    @Override
public void run(String cName, long timeBudget) {
    try {
        long halfTime = timeBudget / 2L;
        System.err.println("TimeBudget: " + timeBudget);
        long remainingTime = halfTime;
        long initialization = remainingTime / 5L;
        remainingTime -= initialization;
        long minimization = remainingTime / 4L;
        remainingTime -= minimization;
        long assertions = remainingTime / 3L;
        remainingTime -= assertions;
        long junit = remainingTime / 2L;
        remainingTime -= junit;
        long write = remainingTime;

        long search = timeBudget - (initialization + minimization + assertions + junit + write);

        System.err.println("Search    : " + search);
        System.err.println("Init      : " + initialization);
        System.err.println("Min       : " + minimization);
        System.err.println("Ass       : " + assertions);
        System.err.println("Extra     : " + timeBudget);
        System.err.println("JUnit     : " + junit);
        System.err.println("Write     : " + write);

        List<String> commands = new ArrayList();
        commands.add("java");
        commands.add("-jar");
        commands.add("lib/smartut-master-1.1.0.jar");
        commands.addAll(Arrays.asList(
                "-projectCP=" + this.cutClassPath,
                "-class", cName,
                "-Dshow_progress=false",
                "-Dstopping_condition=MaxTime",
                "-Dassertion_strategy=all",
                "-Dtest_comments=false",
                "-Dminimize=true",
                "-Dinline=false",
                "-Dcoverage=false",
                "-Dvariable_pool=true",
                "-Dsearch_budget=" + search,
                "-Dglobal_timeout=" + search,
                "-Dnew_statistics=false",
                "-Dstatistics_backend=NONE",
                "-Dminimization_timeout=" + minimization,
                "-Dassertion_timeout=" + assertions,
                "-Dinitialization_timeout=" + initialization,
                "-Djunit_check_timeout=" + junit,
                "-Dextra_timeout=" + (timeBudget + (long) ((int) Math.floor((double) timeBudget / 11.0D))),
                "-Dwrite_junit_timeout=" + write,
                "-Dtest_dir=temp/testcases",
                "-Dp_functional_mocking=0.8",
                "-Dfunctional_mocking_percent=0.5",
                "-Dp_reflection_on_private=0.5",
                "-Dreflection_start_percent=0.8",
                "-Dreuse_leftover_time=true"));
        System.err.println(commands);
        ProcessBuilder processBuilder = new ProcessBuilder(commands);
        Process process = processBuilder.start();
        process.waitFor();
    } catch (IOException | InterruptedException e) {
        e.printStackTrace();
    }

    }
}
