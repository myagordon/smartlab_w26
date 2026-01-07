// automatically called when OSC message is received
//file: OSCReceive.pde
void oscEvent(OscMessage msg) {
  receivingOSC.handleOSC(msg);
}

// Global variable for tile length, will need to adjust this based on physical tile size
float tileLength = 0.5; //assuming tile length = tile height (m)
boolean needsCalibration = false; //wait for new round to start
Process pythonProcess = null;

class OSCReceiveClass {
  float sensorX, sensorY;
  
  //convert user (x,y) posn in mm to tile coordinates
  void handleOSC(OscMessage msg) {
    if (msg.checkAddrPattern("/position")) {
      if (msg.checkTypetag("ff")) {
        float rawX = msg.get(0).floatValue();
        float rawY = msg.get(1).floatValue();
        //sensor uses aeronautics coordinate system so we have to swap x and y
        sensorX=rawY;
        sensorY=rawX;
        
        // Check if we need to calibrate, mnust do this at start of each new round
        if (needsCalibration) {
          restartPythonWithReset();
          user.updatePosition(0, 0);  // Reset user to (0,0)
          needsCalibration = false;
          println("Player is now at grid corner (0,0) SENSOR CALIBRATED");
        }
        
        // Convert from mm to m, then divide by physical tile length
        //pos x direction is forwards, pos y direction is right from perspective of user
        float posX = (sensorX / 1000.0) / tileLength;
        float posY = (sensorY / 1000.0) / tileLength;
        
        int currentTileY = (int)floor(posY);
        int currentTileX;
        
        if (currentRound == 3) {
          currentTileX = hopView.mapHopscotchCol(currentTileY, posX);
        } else {
          currentTileX = (int)floor(posX);
        }
        user.updatePosition(currentTileY, currentTileX);
        
        // Print raw sensor data and converted tile coordinates
        println("Raw sensor (mm): X= " + sensorX + ", Y= " + sensorY);
        println("Tile coordinates: X=" + currentTileX + ", Y=" + currentTileY);
      }
    }
  }
  
  void restartPythonWithReset() {
    OscMessage myMessage = new OscMessage("/reset");
    oscP5.send(myMessage, pythonResetAddress); // Use pythonResetAddress to send reset command
    println("Reset command sent to Python");
  }
  
}
