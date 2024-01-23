package sbst.runtool;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class InstancioTool implements ITestingTool {

    List<File> classPath;

    public List<File> getExtraClassPath() {
        List<File> ret = new ArrayList<File>();
        File Instancio = new File("lib", "instancio.jar");
        if (!Instancio.exists()) {
            System.err.println("Wrong Instancio jar setting, jar is not at: " + Instancio.getAbsolutePath());
        } else {
            ret.add(Instancio);
        }
        return ret;
    }

    public void initialize(File src, File bin, List<File> classPath) {
        this.classPath = classPath;
    }

    public void run(String cName, long timeBudget) {
        try {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < classPath.size(); i++) {
                if (i > 0) {
                    sb.append(":");
                }
                sb.append(classPath.get(i));
            }
            instancio_run(sb.toString(), cName, timeBudget);
        } catch (Exception ioe) {
            ioe.printStackTrace();
            throw new RuntimeException("Failed to run Instancio" + ioe.getMessage());
        }

    }

    private void instancio_run(String cp, String cName, long timeBudget) throws Exception {
        List<String> command = new ArrayList<>();
        command.add("java");
        command.add("-jar");
        command.add("lib/instancio.jar");
        command.add("-projectCP=" + cp);
        command.add("-class=" + cName);
        command.add("-Dtest_dir=temp/testcases");
        command.add("-Dsearch_budget=" + timeBudget);

        ProcessBuilder processBuilder = new ProcessBuilder(command);
        Process process = processBuilder.start();

        try {
            int exitCode = process.waitFor();

            if (exitCode != 0) {
                throw new IOException("Instancio execution failed with exit code: " + exitCode);
            }
        } catch (InterruptedException e) {
            throw new IOException("Instancio execution was interrupted", e);
        }
    }

}