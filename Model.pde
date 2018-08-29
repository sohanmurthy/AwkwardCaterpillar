//Defines the model

static class Model extends LXModel {
  
    public final EastWest eW;
    public final NorthSouth nS;

  
  Model() {
    super(new Fixture());
    Fixture f = (Fixture) this.fixtures.get(0);
    this.nS = f.nS;
    this.eW = f.eW;

  }
  
  private static class Fixture extends LXAbstractFixture {
    
    
    private final EastWest eW;
    private final NorthSouth nS;

    
    Fixture(){
      addPoints(this.eW = new EastWest());
      addPoints(this.nS = new NorthSouth());

    }
    
  }
  
}

static class EastWest extends LXModel {
    
    private static final float X_POS = 1.34;
    private static final int Z_POS = 0;
    
    private static final int SIZE_X = 96;
    private static final int SIZE_Z = 2;
    
    private static final float X_SPACING = 1.34;
    private static final int Z_SPACING = 11*12;
    
    
    EastWest(){
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


static class NorthSouth extends LXModel {
    
    
    private static final int X_POS = 0;
    private static final int Z_POS = 0;
    
    private static final int SIZE_X = 2;
    private static final int SIZE_Z = 96;
    
    private static final float X_SPACING = 11*12;
    private static final float Z_SPACING = 1.34;
    
    
    NorthSouth(){
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