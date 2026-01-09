//file: ScoreTracker.pde
class ScoreTracker {
  // State 
  int successPoints = 0;   // "objective" success score shown to player (only increases on bell hits)

  // Beta belief state for "how likely am I to succeed?" (Bayesian running estimate)
  // a = success evidence, b = failure evidence
  float a = 2.0; // prior success variable
  float b = 2.0;  // prior failure variable

  // Two psychological modifiers:
  float r = 0.0;  // playfulness/resilience in [0,1] (built by going off-grid)
  float i = 0.7;  // impostor bias in [0,1] (starts high; updates on success/failure)

  // constants (modify these as needed)
  final float w = 1.0;   // evidence weight per event

  // Off-grid effects 
  final float gainPlay = 0.03;
  final float dropBiasFromPlay = 0.01;

  // Bias update rates 
  final float kSurprise = 0.05;  // how much successes reduce bias
  final float kFail = 0.02;      // how much failures increase bias

  // Confidence composition weights
  final float kPlay = 0.25;
  final float kBias = 0.7;

  boolean silenceGlitchApplied = false;

  // Events (called by game logic)

  // Off-grid entry:
  // - does NOT change success/failure evidence
  // - builds resilience and slightly reduces bias 
  void onOffGridEntered() {
    r = clamp01(r + gainPlay);
    i = clamp01(i - dropBiasFromPlay);
  }

  // Bell hit:
  // Step 1) compute expected success BEFORE updating (p_prev)
  // Step 2) add objective success + success evidence (a)
  // Step 3) reduce impostor bias more when success was "unexpected"
  void onBellHit() {
    float p_prev = getP(); // expectation BEFORE outcome

    successPoints += 1;    // objective score
    a += w;   // success evidence

    i = clamp01(i - kSurprise * (1.0 - p_prev)); // bias reduction
  }

  // Missed bell opportunity:
  // Step 1) compute expected success BEFORE updating (p_prev)
  // Step 2) add failure evidence (b) (no successPoints change)
  // Step 3) increase bias, but resilience r reduces the penalty
  void onBellMiss() {
    float p_prev = getP(); // expectation BEFORE outcome
    b += w;   // failure evidence
    i = clamp01(i + kFail * p_prev * (1.0 - r)); // resilience-softened bias increase
  }

  // Outputs for UI

  // Bayesian estimate of success probability
  float getP() {
    float denom = a + b;
    if (denom <= 0.0001) return 0.5;
    return a / denom;
  }

  // belief (p) + playfulness boost (r) - impostor bias penalty (i)
  float getConfidence() {
    float p = getP();
    return clamp01(p + kPlay * r - kBias * i);
  }

  // "Silence glitch": wipe the visible success points once, without changing the belief state (a,b,r,i)
  void applySilenceGlitchSupportive() {
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
