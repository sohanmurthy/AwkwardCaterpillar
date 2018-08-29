/***************************************

BORING LIGHT

****************************************/

class BoringLight extends LXPattern {
  
    BoringLight(LX lx) {
    super(lx);
  }
  
  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      colors[p.index] = palette.getColor(p, 100);
    }
  }
   
}


/***************************************

PIXEL TESTER

****************************************/

class GetPixel extends LXPattern {
  
    GetPixel(LX lx) {
    super(lx);
  }
  
  public void run(double deltaMs) {
      addColor(15, LXColor.hsb(0, 0, 100));
  }
   
}



/***************************************

INTERFERENCE

****************************************/

class Interference extends LXPattern {

      class Concentric extends LXLayer{

        private final SinLFO sync = new SinLFO(13*SECONDS,21*SECONDS, 34*SECONDS);
        private final SinLFO speed = new SinLFO(7700*6,3200*6, sync);
        private final SinLFO tight = new SinLFO(6,12, sync);

        private final TriangleLFO cy = new TriangleLFO(model.yMin, model.yMax, random(4*MINUTES+sync.getValuef(),6*MINUTES+sync.getValuef()));
        private final SawLFO move = new SawLFO(TWO_PI, 0, speed);
        
        private final TriangleLFO hue = new TriangleLFO(0,88, sync);

        private final float cx;
        private final int slope = 25;

        Concentric(LX lx, float x){
        super(lx);
        cx = x;
        addModulator(sync.randomBasis()).start();
        addModulator(speed.randomBasis()).start();
        addModulator(tight.randomBasis()).start();
        addModulator(move.randomBasis()).start();
        addModulator(hue.randomBasis()).start();
        addModulator(cy.randomBasis()).start();
        }

         public void run(double deltaMs) {
           for(LXPoint p : model.points) {
           float dx = (dist(p.x, p.y, cx, cy.getValuef()))/ slope;
           float ds = (dist(p.x, p.y, cx, cy.getValuef()))/ (slope/1.1);
           float b = 22 + 22 * sin(dx * tight.getValuef() + move.getValuef());
             blendColor(p.index, palette.getColor(
                        p,
                        b), LXColor.Blend.ADD);
           }
         }
      }

  Interference(LX lx){
    super(lx);
    addLayer(new Concentric(lx, model.xMin));
    addLayer(new Concentric(lx, model.cx));
    addLayer(new Concentric(lx, model.xMax));
  }

  public void run(double deltaMs) {
    setColors(#000000);
    lx.cycleBaseHue(7.86*MINUTES);
  }

}


/***************************************

ColorSwatches

****************************************/

class ColorSwatches extends LXPattern{

  class Swatch extends LXLayer {

    private final SinLFO sync = new SinLFO(8*SECONDS, 14*SECONDS, 39*SECONDS);
    private final SinLFO bright = new SinLFO(-80,100, sync);
    private final SinLFO sat = new SinLFO(35,55, sync);
    private final TriangleLFO hueValue = new TriangleLFO(0, 26, sync);

    private int sPixel;
    private int fPixel;
    private float hOffset;

    Swatch(LX lx, int s, int f, float o){
      super(lx);
      sPixel = s;
      fPixel = f;
      hOffset = o;
      addModulator(sync.randomBasis()).start();
      addModulator(bright.randomBasis()).start();
      addModulator(sat.randomBasis()).start();
      addModulator(hueValue.randomBasis()).start();
    }

    public void run(double deltaMs) {
      float s = sat.getValuef();
      float b = constrain(bright.getValuef(), 0, 100);

      for(int i = sPixel; i < fPixel; i++){
        blendColor(i, LXColor.hsb(
          lx.getBaseHuef() + hueValue.getValuef() + hOffset,
          //lx.getBaseHuef() + hOffset,
          s,
          b
          ), LXColor.Blend.LIGHTEST);
        }
    }

  }

  ColorSwatches(LX lx, int num_sec){
   super(lx);
   //size of each swatch in pixels
    final int section = num_sec;
   for(int s = 0; s <= model.size-section; s+=section){
     if((s+section) % (section*2) == 0){
     addLayer(new Swatch(lx, s, s+section, 55));
     }else{
       addLayer(new Swatch(lx, s, s+section, 0));
     }  
   }
  }

  public void run(double deltaMs) {
    setColors(#000000);
    lx.cycleBaseHue(3.37*MINUTES);
  }

}


/***************************************

STARS

****************************************/

class Stars extends LXPattern {
  
  final static int MAX_STARS = 400;
  
  final DiscreteParameter numStars = new DiscreteParameter("Num", 200, 1, MAX_STARS);
  final BasicParameter speed = new BasicParameter("Spd", 3000, 5000, 800);
  final BasicParameter bright = new BasicParameter("Bright", 75, 25, 100);
  final BasicParameter white = new BasicParameter("Wht", 0, 0, 100);
  
  Stars(LX lx) {
    super(lx);
    addParameter(numStars);
    addParameter(speed);
    addParameter(bright);
    addParameter(white);
    for (int i = 0; i < MAX_STARS; ++i) {
      addLayer(new Star(lx, i));
    }
  }
  
  public void run(double deltaMs) {
    setColors(0);
  }
  
  class Star extends LXLayer {
    final int num;
    final SinLFO level = new SinLFO(0, 1, 5000);
    
    private int index;
    private float brightness = 100;
    
    Star(LX lx, int num) {
      super(lx);
      this.num = num;
      addModulator(level);
      level.setLooping(false);
      trigger();
    }
    
    private void trigger() {
      if (this.num < numStars.getValuei()) {
        brightness = random(bright.getValuef() / 2, bright.getValuef());
        index = (int) random(0, lx.total - 1);
        level.setPeriod(random(speed.getValuef(), 2*speed.getValuef()));
        level.trigger();
      }
    }
    
    public void run(double deltaMs) {
      if (!level.isRunning()) {
        trigger();
      }
      float lvl = level.getValuef();
      if (lvl > 0) {
        addColor(index, palette.getColor(model.points.get(index), 100 - white.getValuef(), lvl*brightness));
      }
    }
  }
}