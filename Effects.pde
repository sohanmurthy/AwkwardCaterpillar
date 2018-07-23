class Effects extends LXEffect {
  
  final int MAX_STAR_DENSITY = 200;
  
  final BasicParameter white = new BasicParameter("White", 0, 1);
  final BasicParameter acid = new BasicParameter("Acid", 0, 1);
  
  final BasicParameter beatPulse = new BasicParameter("Pulse", 0, 0, 100);
  final BasicParameter beatSpotLevel = new BasicParameter("SptLvl", 0, 0, 100);  
  final BasicParameter beatSpotDecay = new BasicParameter("SptDcy", 500, 100, 2000);
  final DiscreteParameter beatSpotDensity = new DiscreteParameter("SptDns", 1, 1, 4);
  
  final BasicParameter beatStarLevel = new BasicParameter("StrLvl", 0, 0, 100);  
  final BasicParameter beatStarDecay = new BasicParameter("StrDcy", 500, 100, 2000);
  final DiscreteParameter beatStarDensity = new DiscreteParameter("StrDns", 60, 20, MAX_STAR_DENSITY);
  
  final BasicParameter wipeDecay = new BasicParameter("WipDcy", 500, 100, 2000);
  
  final BeatSpot[] spots;
  final int MAX_SPOTS = 10;
  
  final BeatStars[] stars;
  final int MAX_STARS = 10;
  
  final Wipe[] wipes;
  final int MAX_WIPES = 10;
  final BooleanParameter wipeHoriz = new BooleanParameter("wipeHoriz", false);
  final BooleanParameter wipeRadial = new BooleanParameter("wipeRadial", false);
  final BooleanParameter wipeVert = new BooleanParameter("wipeVert", false);
  
  Effects(LX lx) {
    super(lx);
    addParameter(beatPulse);
    addParameter(beatSpotLevel);
    addParameter(beatSpotDecay);
    
    spots = new BeatSpot[MAX_SPOTS];
    for (int i = 0; i < spots.length; ++i) {
      addLayer(spots[i] = new BeatSpot(lx));
    }
    
    stars = new BeatStars[MAX_SPOTS];
    for (int i = 0; i < stars.length; ++i) {
      addLayer(stars[i] = new BeatStars(lx));
    }
    
    wipes = new Wipe[MAX_WIPES];
    for (int i = 0; i < wipes.length; ++i) {
      addLayer(wipes[i] = new Wipe(lx));
    }
    
    wipeHoriz.addListener(new LXParameterListener() {
      public void onParameterChanged(LXParameter p) {
        if (wipeHoriz.isOn()) {
          triggerWipe(random(0, 1) > 0.5 ? 0 : 1);
        }
      }
    });
    wipeRadial.addListener(new LXParameterListener() {
      public void onParameterChanged(LXParameter p) {
        if (wipeRadial.isOn()) {
          triggerWipe(4);
        }
      }
    });
    wipeVert.addListener(new LXParameterListener() {
      public void onParameterChanged(LXParameter p) {
        if (wipeVert.isOn()) {
          triggerWipe(random(0, 1) > 0.5 ? 2 : 3);
        }
      }
    });
      
  }
  
  void triggerWipe(int dir) {
    for (Wipe w : wipes) {
      if (!w.pos.isRunning()) {
        w.trigger(dir);
        break;
      }
    }
  }
  
  private float[] hsb = new float[3];
  
  public void run(double deltaMs) {
    if (kick.peak()) {
      
      // Trigger a beatspot
      if (beatSpotLevel.getValue() > 0) {
        int count = 0;
        for (BeatSpot spot : spots) {
          if (!spot.b.isRunning()) {
            spot.trigger();
            if (++count >= beatSpotDensity.getValuei()) {
              break;
            }
          }
        }
      }
      
      // Or a beatstar
      if (beatStarLevel.getValue() > 0) {
        for (BeatStars star : stars) {
          if (!star.b.isRunning()) {
            star.trigger();
            break;
          }
        }
      }
    }
  }
  
  private float nv = 0;
  
  protected void afterLayers(double deltaMs) {
    nv += deltaMs / 2000.;
    
    float h, s, b;
    float bpv = beatPulse.getValuef();
    float whtv = white.getValuef();
    float acidv = acid.getValuef();
    for (LXPoint p : model.points) {
      LXColor.RGBtoHSB(colors[p.index], hsb);
      h = 360*hsb[0]; s = 100*hsb[1]; b = 100*hsb[2];
      if (acidv > 0) {
        h = (h + 720 + acidv*1080*(-0.5+noise(p.x*.01, p.y*.01, nv))) % 360;
      }
      
      if (bpv > 0) {
        b = max(0, b - bpv * (1-kick.getValuef()));
      }
      if (whtv > 0) {
        s = s * (1-whtv);
      }
      colors[p.index] = LX.hsb(h,s, b);
    }
  }
  
  class Wipe extends LXLayer {
    final LinearEnvelope pos = new LinearEnvelope(0, 1, wipeDecay);
    
    private int direction = 0;
    private float cx = model.cy;
    private float cy = model.cx;
    
    Wipe(LX lx) {
      super(lx);
      addModulator(pos);
    }
    
    void trigger(int dir) {
      direction = dir;
      cx = model.cx + random(-4*FEET, 4*FEET);
      cy = model.cy + random(-4*FEET, 4*FEET);
      pos.trigger();
    }
    
    public void run(double deltaMs) {
      if (!pos.isRunning()) {
        return;
      }
      float pv = 0;
      float pvf = 1 - (1-pos.getValuef())*(1-pos.getValuef());
      switch (direction) {
        case 0: pv = lerp(model.xMin, model.xMax, pvf); break;
        case 1: pv = lerp(model.xMax, model.xMin, pvf); break;
        case 2: pv = lerp(model.yMin, model.yMax, pvf); break;
        case 3: pv = lerp(model.yMax, model.yMin, pvf); break;
        case 4: pv = pvf * .7*model.xRange; break;
      }
      
      for (LXPoint p : model.points) {
        float dist = 0;
        switch (direction) {
          case 0:
          case 1:
            dist = abs(p.x - pv); break;
          case 2:
          case 3:
            dist = abs(p.y - pv); break;
          case 4:
            dist = abs(dist(p.x, p.y, cx, cy) - pv); break;
        }
        float b = min(1, 2-2*pos.getValuef()) * (100 - 10*dist);
        if (b > 0) {
          addColor(p.index, palette.getColor(p, b));
        }
      }
    }
    
  }
  
  class BeatSpot extends LXLayer {
    
    final LinearEnvelope b = new LinearEnvelope(1, 0, beatSpotDecay);  
    
    private float r;
    private float xp;
    private float yp;
    
    BeatSpot(LX lx) {
      super(lx);
      addModulator(b);
    }
    
    void trigger() {
      xp = random(model.xMin, model.xMax);
      yp = random(model.yMin, model.yMax);
      r = random(2*FEET, 5*FEET);
      b.trigger();
    }
    
    public void run(double deltaMs) {
      float bv = b.getValuef() * beatSpotLevel.getValuef();
      if (bv > 0) {
        for (LXPoint p : model.points) {
          float bp = 1 - (1/r) * dist(p.x, p.y, xp, yp);
          if (bp > 0) {
            addColor(p.index, palette.getColor(p, bv*bp));
          }
        }
      }
    }
  }
  
  class BeatStars extends LXLayer {
    
    final LinearEnvelope b = new LinearEnvelope(1, 0, beatStarDecay);  
    
    private int[] indices = new int[MAX_STAR_DENSITY];
    private int num;
    
    BeatStars(LX lx) {
      super(lx);
      addModulator(b);
    }
    
    void trigger() {
      num = beatStarDensity.getValuei();
      for (int i = 0; i < num; ++i) {
        indices[i] = (int) constrain(random(0, lx.total), 0, lx.total-1);
      }
      b.trigger();
    }
    
    public void run(double deltaMs) {
      float bv = b.getValuef() * beatStarLevel.getValuef();
      if (bv > 0) {
        for (int i = 0; i < num; ++i) {
          LXPoint p = model.points.get(indices[i]);
          addColor(p.index, palette.getColor(p, bv));
        }
      }
    }
  }
}