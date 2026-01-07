//file: gridGameFall B.pde
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress remoteAddress;
NetAddress pythonResetAddress;

int gridRows = 5;
int gridCols = 5;
int cellSize = 110; //we want it to be 14inx14in

//globals so we know exactly where lines are drawn
int gridOffsetX;
int gridOffsetY;

Grid grid;
User user;
OSCSender sendingOSC;
OSCReceiveClass receivingOSC;
ScoreTracker scoreTracker;
HopscotchView hopView;

//round variables
int currentRound = 1;
int totalRounds = 3;
int roundDuration = 30 * 1000;
int roundStartTime;
boolean showingRoundScreen = true;
int roundScreenStartTime;
boolean isRestrictedColumnRound = false;
boolean USE_TIMER = false; //disable round timer

void advanceToNextRound() {
  if (currentRound < totalRounds) {
    currentRound++;
    showingRoundScreen = true;
    roundScreenStartTime = millis();

    // apply per-round rules
    isRestrictedColumnRound = (currentRound == 3);

    grid = new Grid(gridRows, gridCols, cellSize);
    // calibration will trigger after slide finishes
  }
  
    // refresh grid for new round
  if (currentRound == 3) {
    isRestrictedColumnRound = false;        // ensure old restriction logic is off
    grid = new Grid(gridRows, gridCols, cellSize);
  } else {
    isRestrictedColumnRound = false;
    grid = new Grid(gridRows, gridCols, cellSize);
  }
  
  // reset user so (0,0) is marked correctly in the new grid
  user = new User();

}

void setup() {
  size(900, 900);

  grid = new Grid(gridRows, gridCols, cellSize);
  user = new User();
  scoreTracker = new ScoreTracker();
  hopView = new HopscotchView();

  // Initialize OSC for receiving and remote address for sending
  oscP5 = new OscP5(this, 6800);
  remoteAddress = new NetAddress("127.0.0.1", 8100);
  pythonResetAddress = new NetAddress("127.0.0.1", 6801);

  sendingOSC = new OSCSender();
  receivingOSC = new OSCReceiveClass();

  roundScreenStartTime = millis();
}

void draw() {
  background(255);

  if (showingRoundScreen) {
    fill(0);
    textAlign(CENTER);
    textSize(16);
    text("Round " + currentRound, width/2, height/2);

    if (millis() - roundScreenStartTime > 3000) {
      showingRoundScreen = false;
      roundStartTime = millis();
      needsCalibration = true;
    }
  } else {
    if (currentRound == 3) hopView.display();
    else grid.display();

    user.display();
    
    //sending OSC continuously
    if (frameCount % 2 == 0) sendingOSC.sendOSC(); // ~30 Hz 


    if (USE_TIMER && (millis() - roundStartTime > roundDuration)) {
      advanceToNextRound();
    }
  }

  scoreTracker.display();
}

void keyPressed() {
  if (key == 'r' || key == 'R') { //triggers sensor to recalibrate
    println("New Round");
    needsCalibration = true;
    sendingOSC.sendOSC();
  }

  if (key == 'n' || key == 'N') {
    if (!showingRoundScreen) {
      advanceToNextRound();
    }
  }

  // keyboard controls for debugging (kept)
  if (key == 'w' || key == 'W') user.updatePosition(user.currentRow - 1, user.currentCol);
  if (key == 's' || key == 'S') user.updatePosition(user.currentRow + 1, user.currentCol);
  if (key == 'a' || key == 'A') user.updatePosition(user.currentRow, user.currentCol - 1);
  if (key == 'd' || key == 'D') user.updatePosition(user.currentRow, user.currentCol + 1);

  // b = force a success event (debug)
  if (key == 'b' || key == 'B') user.tryBellHit();
}
