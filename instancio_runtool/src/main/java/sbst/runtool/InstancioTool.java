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

    private boolean instancio_run(String cp, String cut, long timeBudget) throws Exception {
        final String javaCmd = "java";
        ProcessBuilder pbuilder = new ProcessBuilder(javaCmd, "-jar", "lib/instancio.jar", "-cp", cp, "-class", cut, "-Dsearch_budget=" + timeBudget);

            pbuilder.redirectErrorStream(true);
            Process process = null;
            InputStreamReader stdout = null;
            InputStream stderr = null;
            OutputStreamWriter stdin = null;
            boolean mutationExitStatus = false;
        
            process = pbuilder.start();
            stderr = process.getErrorStream();
            stdout = new InputStreamReader(process.getInputStream());
            stdin = new OutputStreamWriter(process.getOutputStream());
        
            BufferedReader reader = new BufferedReader(stdout);
            String line = null;
            while ((line = reader.readLine()) != null) {
                //System.out.println(line);
            }
            reader.close();
        
            try {
                process.waitFor();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        
            int exitStatus = process.exitValue();
        
            //System.out.println("exit status = " + exitStatus);
        
            mutationExitStatus = exitStatus == 0;
        
            if (stdout != null) {
                stdout.close();
            }
            if (stdin != null) {
                stdin.close();
            }
            if (stderr != null) {
                stderr.close();
            }
            if (process != null) {
                process.destroy();
            }
        
            return mutationExitStatus;
        

    }

}