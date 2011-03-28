import java.util.*;
import java.io.*;

public class exit0ifreciveinput {
  public static void main (String args[]) throws Exception {
    BufferedReader bf = new BufferedReader(new InputStreamReader(System.in));
    if (bf.readLine () != null) {
      System.exit(0);
    } else {
      System.exit(1);
    }
  }
}
