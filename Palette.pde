class Palette extends LXPalette {
  
  final BasicParameter spread = new BasicParameter("Sprd", .5, 0, 3);
  final BasicParameter spreadModulate = new BasicParameter("SpMod", .4, 0, 2);  
  
  final BasicParameter xpos = new BasicParameter("CX", model.cx, model.xMin, model.xMax);
  final BasicParameter ypos = new BasicParameter("CY", model.cy, model.yMin, model.yMax);
  
  final BasicParameter motion = new BasicParameter("Motion", .5, 0, 1);
  
  final SinLFO xm = new SinLFO(
    startModulator(new SinLFO(0, -5*FEET, 11000)),
    startModulator(new SinLFO(0, 5*FEET, 17000)),
    startModulator(new SinLFO(15000, 27000, 39000))
  );
  
  final SinLFO ym = new SinLFO(
    startModulator(new SinLFO(0, -5*FEET, 13000)),
    startModulator(new SinLFO(0, 5*FEET, 21000)),
    startModulator(new SinLFO(19000, 21000, 43000))
  );
  
  final SinLFO moreSpread = new SinLFO(0, spreadModulate, 15000);
  
  final SawLFO shape = new SawLFO(0, 5, 53000);
  
  Palette(LX lx) {
    super(lx);
    addParameter(spread);
    addParameter(spreadModulate);
    addParameter(motion);
    addParameter(xpos);
    addParameter(ypos);
    startModulator(moreSpread);
    startModulator(xm);
    startModulator(ym);
    startModulator(shape);
  }
  
  private float sf;
  private float msf;
  private float mf;
  private float xf;
  private float xmf;
  private float yf;
  private float ymf;
  
  private float shp;
  
  
  public void loop(double deltaMs) {
    super.loop(deltaMs);
    shp = shape.getValuef();
    sf = spread.getValuef();
    msf = moreSpread.getValuef();
    mf = motion.getValuef();
    xf = xpos.getValuef();
    xmf = xm.getValuef();
    yf = ypos.getValuef();
    ymf = ym.getValuef();    
  }
    
  public double getHue(LXPoint p) {
    float radial = dist(p.x, p.y, xf + mf*xmf, yf + mf*ymf);
    float horizontal = abs(p.y - yf + mf*ymf);
    float vertical = abs(p.x - xf + mf*xmf);
    float dist = 0;
    if (shp < 1) {
      dist = lerp(radial, horizontal, shp);
    } else if (shp < 2) {
      dist = lerp(horizontal, (horizontal+vertical)*.7, shp-1);
    } else if (shp < 3) {
      dist = lerp((horizontal+vertical)*.7, vertical, shp-2);
    } else if (shp < 4) {
      dist = lerp(vertical, horizontal, shp-3);
    } else {
      dist = lerp(horizontal, radial, shp-4);
    }
    return (360 + getHue() + (sf + msf) * dist) % 360;
  }
  
}

class PaletteTest extends LXPattern {
  PaletteTest(LX lx) {
    super(lx);
  }
  
  public void run(double deltaMs) {
    for (LXPoint p :  model.points) {
      setColor(p.index, palette.getColor(p, 100));
    }
  }
}