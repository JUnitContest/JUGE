package sbst.runtool;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.io.IOException;

public class SymflowerTool implements ITestingTool {

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
        return null;
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
     * @param cName      Name of the class for which unit tests should be generated
     * @param timeBudget How long the tool must run to test the class (in
     *                   miliseconds)
     */
    @Override
    public void run(String cName, long timeBudget) {
        List<String> commands = new ArrayList<>();
        commands.add("lib/tackletestBLABLA");
        

        ProcessBuilder processBuilder = new ProcessBuilder(commands);
        try {
            Process process = processBuilder.start();
            process.waitFor();
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }
}
