package sbst.runtool;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class EvoSuiteTool implements ITestingTool {

    private List<File> classPath;
    File evoSuiteJar = new File("lib", "evosuite.jar");

    /**
     * List of additional class path entries required by a testing tool
     *
     * @return List of directories/jar files
     */
    public List<File> getExtraClassPath() {
        List<File> extraClassPath = new ArrayList<>();

        if (!evoSuiteJar.exists()) {
            System.err.println("Incorrect EvoSuite jar settings. Check the path for evosuite.jar");
        } else {
            extraClassPath.add(evoSuiteJar);
        }

        return extraClassPath;
    }

    /**
     * Initialize the testing tool, with details about the code to be tested (SUT)
     * Called only once.
     *
     * @param src       Directory containing source files of the SUT
     * @param bin       Directory containing class files of the SUT
     * @param classPath List of directories/jar files (dependencies of the SUT)
     */
    public void initialize(File src, File bin, List<File> classPath) {
        this.classPath = classPath;
    }

    /**
     * Run the test tool, and let it generate test cases for a given class
     *
     * @param cName      Name of the class for which unit tests should be generated
     * @param timeBudget Time budget for the test generation
     */
    public void run(String cName, long timeBudget) {
        try {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < classPath.size(); i++) {
                if (i > 0) {
                    sb.append(":");
                }
                sb.append(classPath.get(i));
            }
            evosuite(sb.toString(), cName, timeBudget);
        } catch (IOException ioe) {
            ioe.printStackTrace();
            throw new RuntimeException("Failed to run EvoSuite");
        }
    }

    private void evosuite(String classPath, String cName, long timeBudget) throws IOException {
        List<String> command = new ArrayList<>();
        command.add("java");
        command.add("-jar");
        command.add("lib/evosuite.jar");
        command.add("-projectCP=" + classPath);
        command.add("-class=" + cName);
        command.add("-Dtest_dir=temp/testcases");
        command.add("-Dsearch_budget=" + timeBudget);

        ProcessBuilder processBuilder = new ProcessBuilder(command);
        Process process = processBuilder.start();

        try {
            int exitCode = process.waitFor();

            if (exitCode != 0) {
                throw new IOException("EvoSuite execution failed with exit code: " + exitCode);
            }
        } catch (InterruptedException e) {
            throw new IOException("EvoSuite execution was interrupted", e);
        }
    }
}