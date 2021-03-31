
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DataHasher {
  static long object;
  private static final long HSTART = 0xBB40E64DA205B064L;
  private static final long HMULT = 7664345821815920749L;
   
  public static long DataHasher(byte[] data) {
    long h = HSTART;
    final long hmult = HMULT;
    final long[] ht = createLookupTable();//byteTable;
    for (int len = data.length, i = 0; i < len; i++) {
      h = (h * hmult) ^ ht[data[i] & 0xff];
    }
    
    return h;
  }

 private static  long[] createLookupTable() {
  long [] byteTable = new long[256];
  long h = 0x544B2FBACAAF1684L;
  for (int i = 0; i < 256; i++) {
    for (int j = 0; j < 31; j++) {
      h = (h >>> 7) ^ h;
      h = (h << 11) ^ h;
      h = (h >>> 10) ^ h;
    }
    byteTable[i] = h;
  }
  return byteTable ;
}
  
public static void main(String[] args) {
    
    
    byte[] valuesDefault = args[0].getBytes();
    object = DataHasher(valuesDefault);
    String strnew = Long.toString(object);
    File file = new File("C:\\Users\\Panos\\Desktop/arxeio.txt");
    if(!file.exists()){
         FileWriter fw = null;
        try {
            fw = new FileWriter(file.getAbsoluteFile());
            BufferedWriter bw = new BufferedWriter(fw);
            bw.write(strnew);
            bw.close();
           } catch (IOException ex) {
            Logger.getLogger(DataHasher.class.getName()).log(Level.SEVERE, null, ex);
        } 
    }else{
        file.delete();
        file = new File("C:\\Users\\Panos\\Desktop/arxeio.txt");
        FileWriter fw = null;
        try {
            fw = new FileWriter(file.getAbsoluteFile());
            BufferedWriter bw = new BufferedWriter(fw);
            bw.write(strnew);
            bw.close();
           } catch (IOException ex) {
            Logger.getLogger(DataHasher.class.getName()).log(Level.SEVERE, null, ex);
        } 
    }
       
    
}

}