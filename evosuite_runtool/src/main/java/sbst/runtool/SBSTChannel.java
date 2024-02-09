package sbst.runtool;

import java.io.*;

public class SBSTChannel {
    public static class NullOutputStream extends OutputStream {
        public void write(int b) throws IOException {
        }
    }

    private PrintWriter output;
    private PrintStream debug;
    private BufferedReader input;

    public SBSTChannel(Reader input, Writer output, PrintStream debug) {
        this.input = new BufferedReader(input);
        this.output = new PrintWriter(output);
        this.debug = debug;
    }

    public SBSTChannel(Reader inputs, Writer outputs) {
        this(inputs, outputs, new PrintStream(new NullOutputStream()));
    }

    public void token(String string) throws IOException {
        debug.println("expecting: " + string);
        String line = input.readLine();
        debug.println("<< " + line);
        if (!string.equals(line)) {
            throw new IOException("Unexpected: " + line + " expecting: " + string);
        }
    }

    public File directory() throws IOException {
        debug.println("expecting existing directory");
        String line = input.readLine();
        debug.println("<< " + line);
        File file = new File(line);
        if (file.exists() && file.isDirectory()) {
            return file;
        } else {
            throw new IOException("Not a valid directory name: " + line);
        }
    }

    public int number() throws IOException {
        debug.println("expecting number");
        String line = input.readLine();
        debug.println("<< " + line);
        try {
            return Integer.parseInt(line);
        } catch (NumberFormatException e) {
            throw new IOException("Not a valid number: " + line);
        }
    }

    public long longnumber() throws IOException {
        String line = input.readLine();
        try {
            return Long.parseLong(line);
        } catch (NumberFormatException e) {
            throw new IOException("Not a valid longnumber: " + line);
        }
    }

    public File directory_jarfile() throws IOException {
        debug.println("expecting directory or jar file");
        String line = input.readLine();
        debug.println("<< " + line);
        File file = new File(line);
        if (file.exists()) {
            if (file.isDirectory() || (file.isFile() && file.getName().endsWith(".jar"))) {
                return file;
            } else {
                throw new IOException("Not a valid directory/jar file name: " + line);
            }
        } else {
            throw new IOException("File/Directory does not exist: " + line);
        }
    }

    public String className() throws IOException {
        debug.println("expecting fully qualified class name");
        String line = input.readLine();
        debug.println("<< " + line);
        if (line.matches("[a-zA-Z_][a-zA-Z_0-9]*(\\.[a-zA-Z_][a-zA-Z_0-9]*)*")) {
            return line;
        } else {
            throw new IOException("Not a valid class name: " + line);
        }
    }

    public void emit(String string) {
        debug.println(">> " + string);
        output.println(string);
        output.flush();
    }

    public void emit(int k) {
        emit("" + k);
    }

    public void emit(File file) {
        emit(file.getAbsolutePath());
    }

    public String readLine() throws IOException {
        String line = input.readLine();
        debug.println("<< " + line);
        return line;
    }

}
