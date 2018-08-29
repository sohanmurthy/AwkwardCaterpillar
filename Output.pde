//Connects to local Fadecandy server and maps P3LX points to physical pixels 

FadecandyOutput buildOutput() {
  FadecandyOutput output = null;
  //int[] pointIndices = buildPoints();
  int[] pointIndices = buildPointsManual();
  output = new FadecandyOutput(lx, "192.168.1.50", 7890, pointIndices);
  lx.addOutput(output);
  output.gammaCorrection.setValue(1);
  output.enabled.setValue(true);
  return output;
}

//Function that maps point indices to pixels on led strips
int[] buildPoints() {
  int pointIndices[] = new int[512];
  int i = 0;
  for (int strips = 0; strips < 8; strips = strips + 1) {
    for (int pixels_per_strip = 0; pixels_per_strip < 64; pixels_per_strip = pixels_per_strip + 1) {
          pointIndices[i] = (pixels_per_strip+64*strips);
      i++;
    } 
  }
  return pointIndices; 
}


int[] buildPointsManual() {
  int pointIndices[] = new int[30];
  
  pointIndices[0] = 0;
  pointIndices[1] = 1;
  pointIndices[2] = 2;
  pointIndices[3] = 3;
  pointIndices[4] = 4;
  pointIndices[5] = 5;
  pointIndices[6] = 6;
  pointIndices[7] = 7;
  pointIndices[8] = 8;
  pointIndices[9] = 9;
  
  pointIndices[10] = 10;
  pointIndices[11] = 11;
  pointIndices[12] = 12;
  pointIndices[13] = 13;
  pointIndices[14] = 14;
  pointIndices[15] = 15;
  pointIndices[16] = 16;
  pointIndices[17] = 17;
  pointIndices[18] = 18;
  pointIndices[19] = 19;
  
  pointIndices[20] = 20;
  pointIndices[21] = 21;
  pointIndices[22] = 22;
  pointIndices[23] = 23;
  pointIndices[24] = 24;
  pointIndices[25] = 25;
  pointIndices[26] = 26;
  pointIndices[27] = 27;
  pointIndices[28] = 28;
  pointIndices[29] = 29;
  
  
  return pointIndices; 
}