//Connects to local Fadecandy server and maps P3LX points to physical pixels 

FadecandyOutput buildOutput() {
  FadecandyOutput output = null;
  //int[] pointIndices = buildPoints();
  //int[] pointIndices = buildPointsSimple();
  int[] pointIndices = buildPointsManual();
  output = new FadecandyOutput(lx, "192.168.1.50", 7890, pointIndices);
  lx.addOutput(output);
  output.gammaCorrection.setValue(1);
  output.enabled.setValue(true);
  return output;
}

//Function that maps point indices to pixels on led strips
int[] buildPoints() {
  int pointIndices[] = new int[384];
  int i = 0;
  for (int strips = 0; strips < 8; strips = strips + 1) {
    for (int pixels_per_strip = 0; pixels_per_strip < 64; pixels_per_strip = pixels_per_strip + 1) {
          pointIndices[i] = (pixels_per_strip+64*strips);
      i++;
    } 
  }
  return pointIndices; 
}


int[] buildPointsSimple() {
  int pointIndices[] = new int[384];
  int i = 0;
  for (int pixels = 0; pixels < 384; pixels = pixels + 1) {
          pointIndices[i] = pixels;
      i++;
  }
  
  return pointIndices; 
}


int[] buildPointsManual() {
  int pointIndices[] = new int[384];
  
  /*
  
  MANUAL CONFIG
  TODO: FINISH ONSITE :(
  
  pointIndices[physical pixel] = lx point;
  
  */
  
  pointIndices[0] = 0;
  pointIndices[1] = 1*2;
  pointIndices[2] = 2*2;
  pointIndices[3] = 3*2;
  pointIndices[4] = 4*2;
  pointIndices[5] = 5*2;
  pointIndices[6] = 6*2;
  pointIndices[7] = 7*2;
  pointIndices[8] = 8*2;
  pointIndices[9] = 9*2;
  
  pointIndices[10] = 10*2;
  pointIndices[11] = 11*2;
  pointIndices[12] = 12*2;
  pointIndices[13] = 13*2;
  pointIndices[14] = 14*2;
  pointIndices[15] = 15*2;
  pointIndices[16] = 16*2;
  pointIndices[17] = 17*2;
  pointIndices[18] = 18*2;
  pointIndices[19] = 19*2;
  
  pointIndices[20] = 20*2;
  pointIndices[21] = 21*2;
  pointIndices[22] = 22*2;
  pointIndices[23] = 23*2;
  pointIndices[24] = 24*2;
  pointIndices[25] = 25*2;
  pointIndices[26] = 26*2;
  pointIndices[27] = 27*2;
  pointIndices[28] = 28*2;
  pointIndices[29] = 29*2;


  
  return pointIndices; 
}