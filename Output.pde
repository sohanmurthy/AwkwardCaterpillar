//Connects to local Fadecandy server and maps P3LX points to physical pixels 

FadecandyOutput buildOutput() {
  FadecandyOutput output = null;
  int[] pointIndices = buildPoints();
  output = new FadecandyOutput(lx, "192.168.7.46", 7890, pointIndices);
  lx.addOutput(output);
  output.gammaCorrection.setValue(1);
  output.enabled.setValue(true);
  return output;
}

//Function that maps point indices to pixels on led strips
int[] buildPoints() {
  int pointIndices[] = new int[479];
  int i = 0;
  for (int pixels = 0; pixels < 479; pixels = pixels + 1) {
          pointIndices[i] = pixels;
      i++;
  }
  
  return pointIndices; 
}