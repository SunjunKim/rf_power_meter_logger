import controlP5.*;
import meter.*;
import processing.serial.*;
import java.text.SimpleDateFormat;
import java.util.Date;

// V: Query meter version
// D: Query current average power, dBm
// E: Query current peak power, dBm
// F: Query current frequency
// F<freqIdx>: Set current frequency based on index
//            (0 = first supported freq., 1 = next, etc. )

Meter m;
Serial logger = null;
float lastValue = 0;
boolean reset = false;

ControlP5 cp5;
DropdownList dl_ports, dl_freqs;

String[] ports = null;
int[] freqs = {35, 72, 433, 868, 900, 1200, 2400, 5600, 5650, 5700,
  5750, 5800, 5850, 5900, 5950, 6000};
int port_idx = -1;
int freq_idx = -1;

PrintWriter log_output = null;
String log_file = null;
int log_start_time = 0;

void setup() {
  size(500, 330);

  ports = Serial.list();
  printArray(ports);

  frameRate(10);

  cp5 = new ControlP5(this);
  dl_ports = cp5.addDropdownList("ports")
    .setPosition(10, 10)
    .setSize(100, 100);
  customize(dl_ports);
  for (int i=0; i<ports.length; i++) {
    dl_ports.addItem(ports[i], i);
  }

  dl_freqs = cp5.addDropdownList("freqs")
    .setPosition(120, 10)
    .setSize(100, 300);
  customize(dl_freqs);
  for (int i=0; i<freqs.length; i++) {
    dl_freqs.addItem(freqs[i]+" MHz", i);
  }

  // and add another 2 buttons
  cp5.addButton("connect")
    .setPosition(240, 10)
    .setSize(50, 15)
    ;

  cp5.addButton("reset_limit")
    .setPosition(300, 10)
    .setSize(60, 15)
    ;

  cp5.addButton("record")
    .setPosition(370, 10)
    .setSize(50, 15)
    ;

  m = new Meter(this, 30, 40, false);

  m.setMinInputSignal(-4000);
  m.setMaxInputSignal(4000);

  m.setMinScaleValue(-40.0);
  m.setMaxScaleValue(40.0);

  m.setDisplayMaximumNeedle(true);
  m.setDisplayMinimumNeedle(true);

  m.setDisplayDigitalMeterValue(true);
  m.setTitle("Peak Power (dBm)");

  String[] scaleLabels = {"-40", "-30", "-20", "-10", "0", "10", "20", "30", "40" };
  m.setScaleLabels(scaleLabels);
  m.setShortTicsBetweenLongTics(9);

  reset = true;
}

void draw() {
  background(127);

  float mwVal = round(pow(10, lastValue/10)*100)/100.0;

  while (logger != null && logger.available() > 0) {
    String inBuffer = logger.readStringUntil(10);
    if (inBuffer != null) {
      float value = float(inBuffer.strip());

      if (!Float.isNaN(value)) {
        if (value < -40 || value > 40)
          continue;
        //println(value);
        lastValue = value;
        mwVal = round(pow(10, lastValue/10)*100)/100.0;

        if (reset) {
          m.setMaximumValue(lastValue);
          m.setMinimumValue(lastValue);
          reset = false;
        }

        if (log_output != null) {
          log_output.println(
            (millis()-log_start_time)+","+
            lastValue+","+
            mwVal+","
            );
          log_output.flush();

          if (millis()%1000 > 500) {
            fill(255, 0, 0);
            noStroke();
            circle(430, 18, 10);
          }
          fill(0);
          textSize(12);
          text(log_file, 370, 37);
        }
      }
    }
  }

  m.updateMeter(int(lastValue*100));

  fill(0);
  textSize(20);
  text(mwVal+" mW", 320, 290);


  if (logger != null) {
    logger.write('E');
    logger.write('\n');
  }
}

void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
  } else if (theEvent.isController()) {
    int idx = int(theEvent.getController().getValue());
    if (theEvent.getController() == dl_ports) {
      port_idx = idx;
    } else if (theEvent.getController() == dl_freqs) {
      freq_idx = idx;
    }
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
  }
}

public void connect() {
  if (port_idx == -1 || freq_idx == -1)
    return;

  println(ports[port_idx]);
  println(freqs[freq_idx]);

  String portName = ports[port_idx];
  String freqCmd = "F"+freq_idx+"\n";

  if (logger != null) {
    logger.clear();
    logger.stop();
  }
  logger = new Serial(this, portName, 9600);
  delay(200);

  println(portName);
  logger.write(freqCmd);
  delay(50);
  logger.write(freqCmd);
  delay(50);
  logger.clear();
  reset = true;
}

public void reset_limit() {
  reset = true;
}

public void record() {
  if (logger == null)
    return;

  //PrintWriter log_output = null;
  //String log_file = null;
  //int log_start_time = 0;

  if (log_output == null) {
    log_file = getCurrentTimeStamp()+".csv";
    log_output = createWriter(log_file);
    log_start_time = millis();

    println("Logging start "+log_file);
  } else {
    log_output.flush();
    log_output.close();
    log_output = null;
    log_file = null;

    println("Logging stop");
  }
}

public String getCurrentTimeStamp() {
  return new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
}
