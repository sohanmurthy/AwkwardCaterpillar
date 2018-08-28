import oscP5.*;
import netP5.*;

class OscEngine implements LXLoopTask,LXParameterListener {

  private final OscP5 osc;
  private String client = null;

  private final int SERVER_PORT = 8000;
  private final int CLIENT_PORT = 9000;

  private final int NUM_KNOBS = 12;
  private LXListenableNormalizedParameter[] knobs = new LXListenableNormalizedParameter[NUM_KNOBS]; 

  private final HashMap<String, LXListenableNormalizedParameter> oscMap =
    new HashMap<String, LXListenableNormalizedParameter>();

  private String controlUpdate = null;

  private final BooleanParameter monitorBeat = new BooleanParameter("Monitor", false);
  
  private final BasicParameter rotateTime = new BasicParameter("RotateTime", 60000, 5000, 360000);

  public OscEngine(final LX lx) {
    this.osc = new OscP5(this, SERVER_PORT);

    // Pattern handling
    LXChannel.AbstractListener lxListener = new LXChannel.AbstractListener() {
      
      void patternWillChange(LXChannel channel, LXPattern pattern, LXPattern nextPattern) {
        int pi = 0;
        for (LXPattern p : lx.engine.getChannel(0).getPatterns()) {
          sendOsc("/list/pattern/" + pi + "/color", (p == pattern) ? "green" : (p == nextPattern ? "blue" : "gray"));
          sendOsc("/list/patternName" + pi + "/color", (p == pattern) ? "green" : (p == nextPattern ? "blue" : "gray"));
          ++pi;
        }
      }
      
      void patternDidChange(LXChannel channel, LXPattern pattern) {
        int pi = 0;
        for (LXPattern p : lx.engine.getChannel(0).getPatterns()) {
          sendOsc("/list/patternName" + pi + "/color", (p == pattern) ? "green" : "gray");
          sendOsc("/list/pattern/" + pi + "/color", (p == pattern) ? "green" : "gray");
          ++pi;
        }
        
        // Remove existing listeners
        for (LXListenableNormalizedParameter knob : knobs) {
          if (knob != null) {
            knob.removeListener(OscEngine.this);
          }
        }
        pi = 0;
        for (LXParameter parameter : pattern.getParameters()) {
          if (pi >= knobs.length) {
            break;
          }
          if (parameter instanceof LXListenableNormalizedParameter) {
            setKnob(pi++, (LXListenableNormalizedParameter) parameter);
          }
        }
        while (pi < knobs.length) {
          setKnob(pi++, null);
        }
        sendOsc("/pattern/name", pattern.getName());
      }
    };
    LXChannel channel = lx.engine.getChannel(0); 
    channel.addListener(lxListener);
    lxListener.patternDidChange(channel, channel.getActivePattern());

    // Color handling
    final LXParameterListener clrListener = new LXParameterListener() {
      public void onParameterChanged(LXParameter p) {
        sendOsc("/palette/hs", palette.clr.hue.getNormalizedf(), 1.f - palette.clr.saturation.getNormalizedf());
      }
    }; 
    palette.clr.addListener(clrListener);

    palette.hueMode.addListener(new LXParameterListener() {
      public void onParameterChanged(LXParameter p) {
        sendOsc("/palette/autoCycle", (palette.hueMode.getValuei() == LXPalette.HUE_MODE_STATIC) ? 0 : 1);
        sendOsc("/palette/hs/color", (palette.hueMode.getValuei() == LXPalette.HUE_MODE_STATIC) ? "green" : "gray");
      }
    }); 

    // Other parameter handling
    addControl("/palette/spread", palette.spread);
    addControl("/palette/spreadModulate", palette.spreadModulate);
    addControl("/palette/motion", palette.motion);
    addControl("/palette/cx", palette.xpos);
    addControl("/palette/cy", palette.ypos);
       
    addControl("/list/rotateTime", rotateTime); 
    addControl("/list/autoRotate", lx.engine.getChannel(0).autoTransitionEnabled);
    addControl("/list/transitionTime", transitionTime);
    
    addControl("/output/active", output.enabled);
    addControl("/output/brightness", output.brightness);
    addControl("/output/gamma", output.gammaCorrection);
    
    addControl("/effects/white", effects.white);
    addControl("/effects/acid", effects.acid);
    
    addControl("/effects/flash", flash.enabled);
    addControl("/effects/flashAttack", flash.attack);
    addControl("/effects/flashDecay", flash.decay);
    addControl("/effects/flashLevel", flash.intensity);
    
    addControl("/effects/wipeHoriz", effects.wipeHoriz);
    addControl("/effects/wipeRadial", effects.wipeRadial);
    addControl("/effects/wipeVert", effects.wipeVert);
    addControl("/effects/wipeDecay", effects.wipeDecay);
    
    rotateTime.addListener(new LXParameterListener() {
      public void onParameterChanged(LXParameter p) {
        lx.engine.getChannel(0).enableAutoTransition((int) rotateTime.getValue());
      }
    });
    
  }

  public void loop(double deltaMs) {
    
  }

  private void addControl(final String oscPattern, final LXListenableNormalizedParameter parameter) {
    parameter.addListener(new LXParameterListener() {
      public void onParameterChanged(LXParameter p) {
        if (!oscPattern.equals(controlUpdate)) {
          sendOsc(oscPattern, parameter.getNormalizedf());
        }
        sendOsc(oscPattern + "value", parameter.getValuef());
      }
    }
    );
    oscMap.put(oscPattern, parameter);
  }

  private void setKnob(int ki, LXListenableNormalizedParameter parameter) {
    knobs[ki] = parameter;
    if (parameter != null) {
      parameter.addListener(this);
      sendOsc("/pattern/parameter/" + ki, parameter.getNormalizedf());
      sendOsc("/pattern/label/" + ki, parameter.getLabel());
      sendOsc("/pattern/value/" + ki, parameter.getValuef());
      sendOsc("/pattern/parameter/" + ki + "/color", "green");
      sendOsc("/pattern/label/" + ki + "/color", "green");
      sendOsc("/pattern/value/" + ki + "/color", "green");
    } else {
      sendOsc("/pattern/label/" + ki, "-");
      sendOsc("/pattern/value/" + ki, "-");
      sendOsc("/pattern/parameter/" + ki, 0);
      sendOsc("/pattern/parameter/" + ki + "/color", "gray");
      sendOsc("/pattern/label/" + ki + "/color", "gray");
      sendOsc("/pattern/value/" + ki + "/color", "gray");
    }
  }

  private void sendOsc(String message, float v1, float v2) {
    if (this.client != null) {
      this.osc.send(new OscMessage(message).add(v1).add(v2), this.client, CLIENT_PORT);
    }
  }

  private void sendOsc(String message, float val) {
    if (this.client != null) {
      this.osc.send(new OscMessage(message).add(val), this.client, CLIENT_PORT);
    }
  }

  private void sendOsc(String message, boolean val) {
    if (this.client != null) {
      this.osc.send(new OscMessage(message).add(val), this.client, CLIENT_PORT);
    }
  }

  private void sendOsc(String message, String val) {
    if (this.client != null) {
      this.osc.send(new OscMessage(message).add(val), this.client, CLIENT_PORT);
    }
  }

  public void onParameterChanged(LXParameter p) {
    for (int ki = 0; ki < knobs.length; ++ki) {
      if (p == knobs[ki]) {
        sendOsc("/pattern/parameter/" + ki, knobs[ki].getNormalizedf());
        sendOsc("/pattern/value/" + ki, knobs[ki].getValuef());
      }
    }
  }

  void oscEvent(OscMessage message) {
    try {
      this.client = message.netAddress().address();
      String addrPattern = message.addrPattern();
      LXListenableNormalizedParameter control = oscMap.get(addrPattern);
      if (control != null) {
        controlUpdate = addrPattern;
        control.setNormalized(message.get(0).floatValue());
        controlUpdate = null;
      } else {
        String[] parts = addrPattern.split("/");
        if (parts[1].equals("sync")) {
          final int LIST_SIZE = 20;
          int pi = 0;
          LXPattern active = lx.engine.getChannel(0).getActivePattern();
          LXPattern next = lx.engine.getChannel(0).getNextPattern();
          for (LXPattern p : lx.engine.getChannel(0).getPatterns()) {
            sendOsc("/list/patternEligible" + pi, p.isEligible() ? 1 : 0);
            sendOsc("/list/patternName" + pi, p.getName());
            sendOsc("/list/patternName" + pi + "/color", (active == p) ? "green" : ((next == p) ? "blue" : "gray"));
            sendOsc("/list/pattern/" + pi + "/color", (active == p) ? "green" : ((next == p) ? "blue" : "gray"));
            sendOsc("/list/patternEligible/" + pi + "/visible", 1);
            sendOsc("/list/patternName" + pi + "/visible", 1);
            sendOsc("/list/pattern/" + pi + "/visible", 1);
            ++pi;
          }
          while (pi < LIST_SIZE) {
            sendOsc("/list/patternEligible/" + pi + "/visible", 0);
            sendOsc("/list/patternName" + pi + "/visible", 0);
            sendOsc("/list/pattern/" + pi + "/visible", 0);
            ++pi;
          }
          
          for (String oscPattern : oscMap.keySet()) {
            sendOsc(oscPattern, oscMap.get(oscPattern).getNormalizedf());
            sendOsc(oscPattern+"value", oscMap.get(oscPattern).getValuef());
          }
          sendOsc("/palette/hs", palette.clr.hue.getNormalizedf(), 1.f - palette.clr.saturation.getNormalizedf());
          sendOsc("/palette/autoCycle", palette.hueMode.getValuei() == LXPalette.HUE_MODE_CYCLE ? 1 : 0);
          sendOsc("/palette/hs/color", (palette.hueMode.getValuei() == LXPalette.HUE_MODE_STATIC) ? "green" : "gray");
          sendOsc("/pattern/name", lx.engine.getChannel(0).getActivePattern().getName());
          for (int i = 0; i < knobs.length; ++i) {
            if (knobs[i] == null) {
              sendOsc("/pattern/parameter/" + i + "/color", "gray");
              sendOsc("/pattern/label/" + i + "/color", "gray");
              sendOsc("/pattern/value/" + i + "/color", "gray");
              sendOsc("/pattern/parameter/" + i, 0);
              sendOsc("/pattern/label/" + i, "-");
              sendOsc("/pattern/value/" + i, "-");
            } else {
              sendOsc("/pattern/parameter/" + i + "/color", "green");
              sendOsc("/pattern/label/" + i + "/color", "green");
              sendOsc("/pattern/value/" + i + "/color", "green");
              sendOsc("/pattern/parameter/" + i, knobs[i].getNormalizedf());
              sendOsc("/pattern/value/" + i, knobs[i].getValuef());
              sendOsc("/pattern/label/" + i, knobs[i].getLabel());
            }
          }
        } else if (parts[1].equals("list")) {
          if (parts.length > 2) {
            if (parts[2].equals("pattern")) {
              lx.engine.getChannel(0).goIndex(Integer.parseInt(parts[3]));
            } else if (parts[2].equals("patternEligible")) {
              lx.engine.getChannel(0).getPatterns().get(Integer.parseInt(parts[3])).setEligible(message.get(0).floatValue() > 0);
            }
          }
        } else if (parts[1].equals("pattern")) {
          if (parts.length > 2) {          
            if (parts[2].equals("parameter")) {
              int parameterIndex = Integer.parseInt(parts[3]);
              if (parameterIndex >= 0 && parameterIndex < NUM_KNOBS) {
                if (knobs[parameterIndex] != null) {
                  knobs[parameterIndex].setNormalized(message.get(0).floatValue());
                }
              }
            }
          }
        } else if (parts[1].equals("palette")) {
          if (parts.length > 2) {
            if (parts[2].equals("autoCycle")) {
              palette.hueMode.setValue(message.get(0).floatValue() > 0 ? LXPalette.HUE_MODE_CYCLE : LXPalette.HUE_MODE_STATIC);
            } else if (parts[2].equals("hs")) {
              if (palette.hueMode.getValuei() == LXPalette.HUE_MODE_STATIC) {
                palette.clr.hue.setNormalized(message.get(0).floatValue());
                palette.clr.saturation.setNormalized(1.f - message.get(1).floatValue());
              }
            }
          }
        } else {
          println(message);
        }
      }
    } catch (Exception x) {
      println(x);
      println(message);
    }
  }
}