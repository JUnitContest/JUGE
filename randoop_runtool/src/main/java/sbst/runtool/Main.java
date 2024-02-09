package sbst.runtool;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;

public class Main {
    public static void main(String[] args) throws IOException {
        RunTool runtool = new RunTool(new Randoop(), new InputStreamReader(System.in),
                new OutputStreamWriter(System.out));
        runtool.run();
    }
}
