import java.io.*;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

public class MergePDF {  


     public static void main(String[] args){
        try {

        if (args.length < 2) {
           System.out.println
             ("Usage: ConcatPDFFiles file1.pdf [file2.pdf... fileN.pdf] out.pdf");
           System.exit(1);
         }

          String[] files = args;
          String combined_doc = args[args.length - 1];

          Document PDFCombineUsingJava = new Document();
          PdfCopy copy = new PdfCopy(PDFCombineUsingJava, new FileOutputStream(combined_doc));
          PDFCombineUsingJava.open();
          PdfReader ReadInputPDF;
          int number_of_pages;

          for (int i = 0; i < files.length-1; i++) {
                  ReadInputPDF = new PdfReader(files[i]);
                  number_of_pages = ReadInputPDF.getNumberOfPages();
                  for (int page = 0; page < number_of_pages; ) {
                          copy.addPage(copy.getImportedPage(ReadInputPDF, ++page));
                        }
          }
          PDFCombineUsingJava.close();
        }
        catch (Exception i)
        {
            System.out.println(i);
        }
    }
}
