# Visualizing Sensors using Processing 

The aim of this project is to use Processing to read the sensor outputs from an arduino.

This project includes a .pde file that reads from the serial port 9600 text from the arduino. The text needs to follow the following format **sensor_id$sensor_type$sensor_name:output** for each sensor. Each sensor's output is comma separated.

To use the project, clone the repo,  make your arduino print to serial port 9600 with the format described above, and run the .pde file with. Processing. Processing  will create a graph for each sensor. The .pde file also contains variables that you can modify to change the aspect of the graphs.

Happy hacking.
