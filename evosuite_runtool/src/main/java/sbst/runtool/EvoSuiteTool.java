package sbst.runtool;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class EvoSuiteTool implements ITestingTool {

    private List<File> classPath;

    public List<File> getExtraClassPath() {
        List<File> extraClassPath = new ArrayList<>();
        File evoSuiteJar = new File("lib", "evosuite.jar");

        if (!evoSuiteJar.exists()) {
            System.err.println("Incorrect EvoSuite jar settings. Check the path for evosuite.jar");
        } else {
            extraClassPath.add(evoSuiteJar);
        }

        return extraClassPath;
    }

    public void initialize(File src, File bin, List<File> classPath) {
        this.classPath = classPath;
    }

    public void run(String cName, long timeBudget) {
        try {
            String classPathString = buildClassPathString();
            evosuiteRun(classPathString, timeBudget);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to run EvoSuite");
        }
    }

    private String buildClassPathString() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < classPath.size(); i++) {
            if (i > 0) {
                sb.append(File.pathSeparator);
            }
            sb.append(classPath.get(i));
        }
        return sb.toString();
    }

    private void evosuiteRun(String classPath, long timeBudget) throws Exception {
        List<String> command = new ArrayList<>();
        command.add("java");
        command.add("-jar");
        command.add("lib/evosuite.jar");
        command.add("-projectCP");
        command.add(classPath);
        command.add("-Dsearch_budget=" + timeBudget);

        ProcessBuilder processBuilder = new ProcessBuilder(command);
        Process process = processBuilder.start();

        int exitCode = process.waitFor();

        if (exitCode != 0) {
            throw new RuntimeException("EvoSuite execution failed with exit code: " + exitCode);
        }
    }
}
