package sbst.runtool;

import java.io.InputStreamReader;
import java.io.OutputStreamWriter;

public class Main {

    public static void main(String[] args) {
        ITestingTool tool = new AUTCGTool();
        RunTool runTool = new RunTool(tool, new InputStreamReader(System.in), new OutputStreamWriter(System.out));
        try {
            runTool.run();
            System.exit(0);
        } catch (Exception e) {
            System.err.print("Exception caught: "+ e.toString());
            e.printStackTrace();
            System.exit(1);
        }
    }

}
