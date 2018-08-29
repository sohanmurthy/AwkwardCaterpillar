//Defines the model

/*

ROOM DIMENSIONS

North wall:
112 pixels

East Wall:
117 pixels

South Wall (window):
140

West Wall:
371-256 = 115



*/

static class Model extends LXModel {
      
    public final East e;
    public final West w;
    public final North n;
    public final South s;

  
  Model() {
    super(new Fixture());
    Fixture f = (Fixture) this.fixtures.get(0);

    this.e = f.e;
    this.w = f.w;
    this.n = f.n;
    this.s = f.s;

  }
  
  private static class Fixture extends LXAbstractFixture {
    
    
    private final East e;
    private final West w;
    private final North n;
    private final South s;

    
    Fixture(){
  
      addPoints(this.n = new North());
      addPoints(this.e = new East());
      addPoints(this.w = new West());
      addPoints(this.s = new South());
    }
    
  }
  
}




static class East extends LXModel {
    
    private static final int SIZE_X = 116;
    private static final int SIZE_Z = 1;
    
    private static final float X_SPACING = 1.34;
    private static final int Z_SPACING = 1;
    
    private static final float X_POS = 1.34;
    private static final float Z_POS = (X_SPACING*SIZE_X);
    
    East(){
     super(new Fixture()); 
    }
    
    private static class Fixture extends LXAbstractFixture {
      Fixture(){
      for (int x = 0; x < SIZE_X; ++x) {
          for (int z = 0; z < SIZE_Z; ++z){
            // Adds points to the fixture
            addPoint(new LXPoint(X_POS+x*X_SPACING, Z_POS+z*Z_SPACING));
          } 
        
      }
    }
  }
}



static class West extends LXModel {
    
    private static final int SIZE_X = 115;
    private static final int SIZE_Z = 1;
    
    private static final float X_SPACING = 1.34;
    private static final int Z_SPACING = 1;
      
    private static final float X_POS = 1.34;
    private static final float Z_POS = -X_SPACING;
    
    West(){
     super(new Fixture()); 
    }
    
    private static class Fixture extends LXAbstractFixture {
      Fixture(){
      for (int x = 0; x < SIZE_X; ++x) {
          for (int z = 0; z < SIZE_Z; ++z){
            // Adds points to the fixture
            addPoint(new LXPoint(X_POS+x*X_SPACING, Z_POS+z*Z_SPACING));
          } 
        
      }
    }
  }
}


static class North extends LXModel {
    
    private static final int SIZE_X = 1;
    private static final int SIZE_Z = 112;
    
    private static final float X_SPACING = 1;
    private static final float Z_SPACING = 1.34;
    
    private static final float X_POS = 0;
    private static final float Z_POS = 0;
    
    
    North(){
     super(new Fixture()); 
    }
    
    private static class Fixture extends LXAbstractFixture {
      Fixture(){
      for (int x = 0; x < SIZE_X; ++x) {
          for (int z = 0; z < SIZE_Z; ++z){
            // Adds points to the fixture
            addPoint(new LXPoint(X_POS+x*X_SPACING, Z_POS+z*Z_SPACING));
          } 
        
      }
    }
  }
}


static class South extends LXModel {
    
    private static final int SIZE_X = 1;
    private static final int SIZE_Z = 136;
    
    private static final float X_SPACING = 1;
    private static final float Z_SPACING = 1.34;
    
    private static final float X_POS = (Z_SPACING*(SIZE_Z+1));
    private static final float Z_POS = 0;
    
    South(){
     super(new Fixture()); 
    }
    
    private static class Fixture extends LXAbstractFixture {
      Fixture(){
      for (int x = 0; x < SIZE_X; ++x) {
          for (int z = 0; z < SIZE_Z; ++z){
            // Adds points to the fixture
            addPoint(new LXPoint(X_POS+x*X_SPACING, Z_POS+z*Z_SPACING));
          } 
        
      }
    }
  }
}