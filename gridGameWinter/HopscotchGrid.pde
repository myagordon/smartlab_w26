//file: HopscotchView.pde
class HopscotchView {

  float corner = 16;
  float shadowOffset = 6;
  float shadowAlpha = 25;

  boolean SHOW_NUMBERS = false; // set true for debugging

  // A simple playful palette
  color[] palette = {
    color(255, 183, 3), // warm yellow
    color(142, 202, 230), // light blue
    color(255, 120, 150), // pink
    color(120, 220, 170), // mint
    color(180, 140, 255)  // lavender
  };

  void display() {
    background(248);

    for (int row = 0; row < 5; row++) {
      if (row % 2 == 0) {
        drawHopTile(row, 2); // single tile at (row,2)
      } else {
        for (int col = 1; col <= 3; col++) {
          drawHopTile(row, col);  // three tiles at (row,1..3)
        }
      }
    }
  }

  void drawHopTile(int row, int col) {
    GridCell c = grid.cells[row][col];

    // Pick a base color per-tile 
    color base = palette[(int)random(palette.length)];

    // tint 
    base = lerpColor(base, color(255), random(0.05, 0.20));

    // keep glitch tiles slightly "washed"? 
    if (c.isGlitching) {
      base = lerpColor(base, color(255), 0.35);
    }

    // Subtle shadow
    noStroke();
    fill(0, shadowAlpha);
    rect(c.x + shadowOffset, c.y + shadowOffset, c.size, c.size, corner);

    // Tile fill (no outline)
    noStroke();
    fill(base);
    rect(c.x, c.y, c.size, c.size, corner);

    if (c.isUserHere) {
      noStroke();
      fill(255, 255, 255, 80);
      rect(c.x, c.y, c.size, c.size, corner);
    }

    // Optional numbers for debugging
    if (SHOW_NUMBERS) {
      fill(0, 180);
      textAlign(CENTER, CENTER);
      textSize(14);
      text(c.number, c.x + c.size/2, c.y + c.size/2);
    }
  }

  // Convert continuous colPos to a 5x5 grid col for hopscotch
  int mapHopscotchCol(int row, float colPos) {
    boolean singleRow = (row % 2 == 0);
    if (singleRow) {
      if (colPos >= 2.0 && colPos < 3.0) return 2;
      return -1;
    } else {
      if (colPos >= 1.0 && colPos < 2.0) return 1;
      if (colPos >= 2.0 && colPos < 3.0) return 2;
      if (colPos >= 3.0 && colPos < 4.0) return 3;
      return -1;
    }
  }
}
