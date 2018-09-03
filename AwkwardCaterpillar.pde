/********************************************************

AWKWARD CATERPILLAR
Sohan Murthy & Carrie Phillips
2018

AWKWARD CATERPILLAR is an LED art installation located
in a private residence in San Francisco. This program
controls hundreds of individually addressable LEDs,
balancing artistic expression and functional interior
lighting.

*********************************************************/




import ddf.minim.*;

P3LX lx;
Palette palette;
Model mdl;
OscP5 osc;
LXOutput output;
FlashEffect flash;
Effects effects;

final BasicParameter transitionTime = new BasicParameter("Trans", 5000, 250, 30000);

final float INCHES = 1;
final float FEET = 12 * INCHES;
final int SECONDS = 1000;
final int MINUTES = 60*SECONDS;

void setup() {
  
  //Define model
  mdl = new Model();
  lx = new P3LX(this, mdl);
  
  //Add color palette selector
  lx.engine.addComponent(palette = new Palette(lx));
  lx.engine.getChannel(0).setPalette(palette);
  
  //Set transition to "multiply"
  LXTransition transition = new MultiplyTransition(lx).setDuration(transitionTime);  
  
  
  //Initiate patterns
  LXPattern[] patterns = {
    
    new BoringLight(lx),
    new Interference(lx),
    new Waves(lx),
    new Pulsar(lx),
    new Headspace(lx),
    new Turrellian(lx),
    new Stars(lx)
    
  };
  for (LXPattern p : patterns) {
    p.setTransition(transition);
  }
  lx.setPatterns(patterns);
  
  // Effects
  lx.addEffect(effects = new Effects(lx));
  lx.addEffect(flash = new FlashEffect(lx));
  effects.setPalette(palette);
  
  // Output
  output = buildOutput();
  
  // UI (REMOVE WHEN RUNNING HEADLESS)
  size(960, 720, P3D);
  lx.ui.addLayer(new UI3dContext(lx.ui)
    .addComponent(new UIPointCloud(lx).setPointSize(4))
    .setCenter(mdl.cx, mdl.cy, 0)
    .setRadius(15*FEET)
    .setPhi(-PI/3)
  );
  lx.ui.addLayer(new UIChannelControl(lx.ui, lx, 4, 4));
  lx.ui.addLayer(new UIPalette(lx.ui, palette, 4, 326));
  lx.ui.addLayer(new UIOutput(lx.ui, width - 144, 4));
  lx.ui.addLayer(new UIEffects(lx.ui, width - 144, 144));
  
  // OSC engine
  lx.engine.addLoopTask(new OscEngine(lx));
}

void draw() {
  background(#111111);
}