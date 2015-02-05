import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import processing.serial.*;

int BACKGROUND = 5;
int HEIGHT = 700;
int WIDTH  = 1000;
int TICK_WIDTH = 3;

int TICK_QUANTITY = WIDTH/TICK_WIDTH;
int FRAME_WIDTH = 50;
int serial_number = 5;
HashSet<String> SENSOR_NAMES = new HashSet<String>();
int MEASUREMENT_INTERVAL = 10;

PFont FONT = createFont("Arial", 28,true);
PFont measurement_font = createFont("console", MEASUREMENT_INTERVAL,true);


Serial myPort; // The serial port:
HashMap<String, int[]> graph_arrays = new HashMap<String, int[]>();
HashMap<String, Integer> values_map = new HashMap<String, Integer>();
HashMap<String, Boolean> update_map = new HashMap<String, Boolean>();
HashMap<String, String> names_map = new HashMap<String, String>();
HashMap<String, String> types_map = new HashMap<String, String>();

// Divide the window into segments.
int segment_height; 


void setup()
{
  if (TICK_WIDTH >= WIDTH) {
    println("Invalid TICK_WIDTH");
    System.exit(-1);
  }
  // Arduino Graph Project
  size(WIDTH, HEIGHT);

  // Specifying Background Color.
  background(BACKGROUND);


  
  //println(Serial.list());
  myPort = new Serial(this, Serial.list()[serial_number], 9600);


  // Hack to start reading the arduino's output.
  myPort.readStringUntil('\t');
  myPort.readStringUntil('\n');
  myPort.bufferUntil('\n');

  while (SENSOR_NAMES.size () == 0) {
    getNames(SENSOR_NAMES);
  }
  println(SENSOR_NAMES);
  segment_height = HEIGHT/SENSOR_NAMES.size();

  

  // Initialize graph array of values.
  for (String name : SENSOR_NAMES) {
    int[] graph = new int[TICK_QUANTITY];
    graph_arrays.put(name, graph);
    values_map.put(name, 0);
    update_map.put(name, false);
  }
}

void updateGraph(int new_value, int[] graph) {
  int current_value = new_value;
  for (int at_index = 0; at_index < graph.length; at_index++) {
    int tmp = graph[at_index];
    graph[at_index] = current_value;
    current_value = tmp;
  }
}

void drawGraph(int[] graph, float bottom_coord, String type, String name, String id) {


  stroke(255);
  int strong_stroke = 6;
  strokeWeight(strong_stroke);  
  float bottom = bottom_coord - (segment_height - FRAME_WIDTH);
  float top = bottom_coord;
  
  float text_y_coord = bottom_coord - (segment_height + strong_stroke - FRAME_WIDTH );
  textFont(FONT);
  fill(255);
  text(name+" / "+id,0, text_y_coord);
  line(0, bottom, WIDTH, bottom);
  line(0, top, WIDTH, top);

  if (type.equals("A")) {
    int measurement = 0;
    for (float current_line = (bottom + MEASUREMENT_INTERVAL); current_line < top; current_line += MEASUREMENT_INTERVAL) {
      stroke(200, 255, 255, 255);
      strokeWeight(1);
      line(0, current_line, WIDTH, current_line);
      textFont(measurement_font);
      text(measurement * MEASUREMENT_INTERVAL, 10, current_line);
      measurement++;
    }
  }




stroke(255, 200, 200);
strokeWeight(2);
for (int tick=0; tick < TICK_QUANTITY; tick++) {
  int start = tick * TICK_WIDTH;
  int end = (tick + 1) * TICK_WIDTH;
  //int x_coord = tick * TICK_WIDTH;
  int x_coord = (start + end)/2;
  
  if (type.equals("A")) {
    // Values are 0 - 100.x
    float percentage = ((float)graph[tick])/ 100.0;    
    float y_coord = (bottom_coord - FRAME_WIDTH) - percentage * (segment_height - 2* FRAME_WIDTH);
    line(x_coord, y_coord, x_coord, bottom_coord);
  } else {
    float percentage = ((float)graph[tick])/ 200.0;
    float y_coord = (bottom_coord - FRAME_WIDTH) - percentage * (segment_height - 2* FRAME_WIDTH);
    point(x_coord, y_coord);
  }
}
}

void getNames(Set names) {
  // get the ASCII string:
  String line = myPort.readStringUntil('\n');
  if (line !=null && !"".equals(line) ) {
    for (String inString : split (line, ',')) {
      // split the string into multiple strings
      // where there is a ":"
      String items[] = split(inString, ':');
      if (items.length > 1) {
        String identifiers[] = split(items[0], '$'); 
        if (identifiers.length != 3) {
          break;
        }       
        // remove any whitespace from the label
        String id = trim(identifiers[0]);
        String type = trim(identifiers[1]);
        String name = trim(identifiers[2]);
        types_map.put(id, type);
        names_map.put(id, name);
        names.add(id);
      }
    }
  }
}
void updateGraphValues() {
  // get the ASCII string:
  String line = myPort.readStringUntil('\n');
  if (line !=null && !"".equals(line) ) {
    for (String inString : split (line, ',')) {
      // split the string into multiple strings
      // where there is a ":"
      String items[] = split(inString, ':');
      if (items.length > 1) {
        String identifiers[] = split(items[0], '$'); 
        if (identifiers.length == 3) {
          // remove any whitespace from the label
          String id = trim(identifiers[0]);
          String type = trim(identifiers[1]);
          String name = trim(identifiers[2]);

          // remove the ',' off the end
          String val = items[1];
          val = trim(val);
          if (val !=null && !"".equals(val) && values_map.containsKey(id)) {
            try {
              values_map.put(id, Integer.parseInt(val));
              update_map.put(id, true);
            } 
            catch (NumberFormatException e) {
              System.out.println("Val: ");
              System.out.println(val);
              System.out.println("This is not a number");
              System.out.println(e.getMessage());
            }
          } // else {
          // println("Not a valid label:("+label+") or value:("+val+")");
          // }
        }
      } // else {
      // println("Not a valid item: "+inString);
      // }
    }
  } // else {
  //println("Not a valid line: "+line);
  // }
}

void draw() {
  background(BACKGROUND);

  updateGraphValues();

  // Graph arrays.
  int segment_number = 0;
  for (String sensor : SENSOR_NAMES) {
    int[] graph = graph_arrays.get(sensor);

    int new_value;
    if (update_map.get(sensor)) {
      new_value = values_map.get(sensor);
    } else {
      new_value = graph[0];
    }
    updateGraph(new_value, graph);
    String type = types_map.get(sensor);
    String name = names_map.get(sensor);  
    //println(sensor,type, name);  
    float segment_bottom = segment_height * (segment_number + 1);
    segment_number++;
    drawGraph(graph, segment_bottom, type, name, sensor);
  }
}

