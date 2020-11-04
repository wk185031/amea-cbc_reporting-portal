//import java.io.*;
//import java.nio.charset.StandardCharsets;
//import java.nio.file.Files;
//import java.nio.file.Path;
//import java.nio.file.Paths;
//import java.time.DayOfWeek;
//import java.time.LocalDate;
//import java.time.temporal.ChronoField;
//import java.time.temporal.ValueRange;
//import java.util.Arrays;
//import java.util.logging.Level;
//import java.util.logging.Logger;
//import java.util.stream.Stream;
//
//public class test {
//
//    public static void main(String[] args) throws IOException {
//        File f = new File("C:\\TestMerge");
//
//        File merged = new File("C:\\TestMerge\\merged.txt");
//        if (!merged.exists()) {
//            merged.createNewFile();
//        }
//
//        PrintWriter pw = new PrintWriter(merged);
//
//        String[] s = f.list();
//        System.out.println("list of files-> " + Arrays.asList(s));
//
//        for (String s1 : s) {
//            File f1 = new File(f, s1);
//            BufferedReader br = new BufferedReader(new FileReader(f1));
//
//            String line = "";
//            while ((line = br.readLine()) != null) {
//                System.out.println(line);
//                pw.println(line);
//            }
//        }
//        pw.flush();
//        pw.close();
//    }
//
//}
