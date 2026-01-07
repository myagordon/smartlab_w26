//file: GlitchEffect.pde
// UNUSED (kept for later), safe to ignore
class GlitchEffect {
  float flickerChance;
  boolean isGlitching = false;
  int glitchStartTime = 0;
  int glitchDuration = 0;

  boolean shouldFlicker() {
    updateIntensity();

    if (isGlitching) {
      if (millis() - glitchStartTime < glitchDuration) {
        return true;
      } else {
        isGlitching = false;
      }
    } else {
      if (random(1) < flickerChance) {
        isGlitching = true;
        glitchStartTime = millis();
        glitchDuration = (int) random(500, 1000); // 1–2 seconds
        return true;
      }
    }
    return false;
  }

  void updateIntensity() { //play with these values to control glitch frequency 
    if (currentRound == 1) flickerChance = 0.001;
    else if (currentRound == 2) flickerChance = 0.003;
    else if (currentRound == 3) flickerChance = 0.006;
  }
}
