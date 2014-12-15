import java.io.BufferedReader;
import java.io.FileReader;
import java.util.Arrays;

class LibsvmModelLoader {
  HashMap<String, String> headers;
  ArrayList<SupportVector> supportVectors;

  LibsvmModelLoader(String path) {
    try {
      BufferedReader in = new BufferedReader(new FileReader(path));

      boolean headerComplete = false;

      headers = new HashMap<String, String>();
      supportVectors = new ArrayList<SupportVector>();

      while (in.ready ()) {
        String s = in.readLine();

        if (headerComplete) {
          //TODO: set number of feature vectors
          supportVectors.add(parseSupportVector(s, getNumClasses()-1, 1728));
        } else {
          if (!s.equals("SV")) {
            parseAndLoadHeader(s);
          }
        }

        if (s.equals("SV")) {
          headerComplete = true;
        }
      }
      in.close();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }  

  void parseAndLoadHeader(String s) {
    String[] parts = split(s, " ");
    headers.put(parts[0], join(Arrays.copyOfRange(parts, 1, parts.length), " "));
  }

  String getSVMType() {
    return headers.get("svm_type");
  }  

  String getKernelType() {
    return headers.get("kernel_type");
  }

  int getNumClasses() {
    return int(headers.get("nr_class"));
  }

  int getTotalSV() {
    return int(headers.get("total_sv"));
  }
  
  double[] getRho() {
    String string = headers.get("rho");
    return parseDoubleValues(string);
  }

  double[] getProbA(){
    String string = headers.get("probA");
    return parseDoubleValues(string);
  }
  
  double[] getProbB(){
    String string = headers.get("probB");
    return parseDoubleValues(string);
  }

  int[] getLabels() {
    String string = headers.get("label");
    return parseIntValues(string);
  }
  
  int[] getNumSVs(){
    String string = headers.get("nr_sv");
    return parseIntValues(string);
  }

  int[] parseIntValues(String string){
    String[] parts = split(string, " ");
    int[] result = new int[parts.length];
    for (int i = 0; i < parts.length; i++) {
      result[i] = parseInt(parts[i]);
    }
    return result;
  }

  double[] parseDoubleValues(String string) {
    String[] parts = split(string, " ");
    double[] result = new double[parts.length];
    for (int i = 0; i < parts.length; i++) {
      result[i] = Double.parseDouble(parts[i]);
    }
    return result;
  }
  
  SupportVector parseSupportVector(String s, int nClasses, int nFeatures) {
    String[] parts = split(s, " ");

    SupportVector result = new SupportVector(nClasses, nFeatures);

    int numClasses = 0;
    int numFeatures = 0;
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].length() > 0) {

        String[] match = split(parts[i], ":");
        if (match.length > 1) {
          result.featureValues[numFeatures] = Double.parseDouble(parts[i].split(":")[1]);
          numFeatures++;
        } else {
          result.classValues[numClasses] = Double.parseDouble(parts[i]);
          numClasses++;
        }
      }
    }

    return result;
  }
}

