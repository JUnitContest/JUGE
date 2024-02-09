package sbst.runtool;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class Randoop implements ITestingTool {

    private String cutClassPath;
    private File randoopJar = new File("lib", "randoop.jar");

    public List<File> getExtraClassPath() {
        List<File> files = new ArrayList<>();
        if (!randoopJar.exists()) {
            System.err.println("Incorrect Randoop JAR setting, JAR is not at: " + randoopJar.getAbsolutePath());
        } else {
            files.add(randoopJar);
        }
        return files;
    }

    public void initialize(File src, File bin, List<File> classPath) {
        StringBuilder sb = new StringBuilder();
        sb.append(bin.getAbsolutePath());
        for (File f : classPath) {
            sb.append(File.pathSeparator);
            sb.append(f.getAbsolutePath());
        }
        this.cutClassPath = sb.toString();
    }

    public void run(String cName, long timeBudget) {
        List<String> command;
        ProcessBuilder pbuilder = new ProcessBuilder();
        try {
            command = new ArrayList<>();
            command.add("java");
            command.add("-classpath");
            command.add(randoopJar + ":" + cutClassPath);
            command.add("randoop.main.Main");
            command.add("gentests");
            command.add("--testclass=" + cName);
            command.add("--time-limit=" + timeBudget);
            command.add("--junit-output-dir=./temp/testcases/");
            System.err.println("Running Randoop with command: " + command);
            pbuilder.command(command);

            // redirect error stream to a file
            File errorFile = new File("error.txt");
            pbuilder.redirectError(errorFile);
            Process process = pbuilder.start();

            process.waitFor();

            if (process.exitValue() != 0) {
                System.err.println("Error running Randoop, see error.txt for details");
            }
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }

    }

}
