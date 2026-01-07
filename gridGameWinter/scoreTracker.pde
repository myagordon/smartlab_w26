//file: ScoreTracker.pde
class ScoreTracker {
  // state 
  int successPoints = 0;   // objective: ONLY bell hits
  float a = 2.0;           // Beta prior
  float b = 2.0;           // Beta prior
  float r = 0.0;           // playfulness/resilience in [0,1]
  float i = 0.7;           // impostor bias in [0,1] (starts high)

  // constants 
  final float w = 1.0;

  final float gainPlay = 0.03;
  final float dropBiasFromPlay = 0.01;

  final float kSurprise = 0.05;
  final float kFail = 0.02;

  final float kPlay = 0.25;
  final float kBias = 0.7;

  boolean silenceGlitchApplied = false;

  //  Events 

  // Off-grid entry: playfulness + bias reduction (no success/failure evidence here)
  void onOffGridEntered() {
    r = clamp01(r + gainPlay);
    i = clamp01(i - dropBiasFromPlay);
  }

  // Bell hit: the only way to gain successPoints
  void onBellHit() {
    float p_prev = getP();           // Step 1: expectation BEFORE outcome

    // Step 3: objective updates
    successPoints += 1;
    a += w;

    // Step 4: bias update using p_prev (success)
    i = clamp01(i - kSurprise * (1.0 - p_prev));
  }

  // Missed bell opportunity: failure evidence (no successPoints change)
  void onBellMiss() {
    float p_prev = getP(); // Step 1: expectation BEFORE outcome

    // Step 3: objective updates (fair evidence)
    b += w;

    // Step 4: bias update using p_prev (failure softened by resilience)
    i = clamp01(i + kFail * p_prev * (1.0 - r));
  }

  //  Outputs 
  float getP() {
    float denom = a + b;
    if (denom <= 0.0001) return 0.5;
    return a / denom;
  }

  float getConfidence() {
    float p = getP();
    return clamp01(p + kPlay * r - kBias * i);
  }


  void applySilenceGlitchSupportive() {
    // wipe external points once; keep internal belief state unchanged
    if (silenceGlitchApplied) return;
    silenceGlitchApplied = true;
    successPoints = 0;
  }

  // UI 
  void display() {
    float confidence = getConfidence();

    fill(0);
    textAlign(LEFT, CENTER);
    textSize(16);

    text("Success",     20, 30);
    text("Confidence",  20, 70);

    // Bars
    drawBar(170, 20, successPoints, 10,  color(0, 200, 0)); // visual cap at 10
    drawBar(170, 60, confidence,    1.0, color(0, 0, 200));
  }

  void drawBar(float x, float y, float value, float maxVal, color c) {
    noFill();
    stroke(0);
    strokeWeight(2);
    rect(x, y, 200, 20);

    noStroke();
    fill(c);
    float v = constrain(value, 0, maxVal);
    float filled = map(v, 0, maxVal, 0, 200);
    rect(x, y, filled, 20);
  }

  float clamp01(float v) {
    return constrain(v, 0, 1);
  }
}
