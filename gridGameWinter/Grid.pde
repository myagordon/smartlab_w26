//file: Grid.pde
class Grid {
  int rows;
  int cols;
  int cellSize;
  int offsetX;
  int offsetY;
  GridCell[][] cells;

  Grid(int r, int c, int cs) {
    rows = r;
    cols = c;
    cellSize = cs;
    cells = new GridCell[rows][cols];

    offsetX = (width - cols * cellSize) / 2;  // X offset to center grid
    offsetY = (height - rows * cellSize) / 2; // Y offset to center grid

    // store info for drawing dashed white lines
    gridOffsetX = offsetX;
    gridOffsetY = offsetY;

    int currentNumber = 0;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        float x = offsetX + j * cellSize;
        float y = offsetY + i * cellSize;
        cells[i][j] = new GridCell(x, y, cellSize, currentNumber++, i, j);
      }
    }

    // Enable glitch tiles per round 
    if (currentRound == 1) { // 2 glitching tiles
      enableGlitch(1, 1);
      enableGlitch(3, 4);
    } else if (currentRound == 2) { // 4 glitching tiles
      enableGlitch(2, 0);
      enableGlitch(0, 4);
      enableGlitch(2, 2);
      enableGlitch(3, 3);
    }
  }

  void enableGlitch(int row, int col) {
    if (row >= 0 && row < rows && col >= 0 && col < cols) {
      cells[row][col].enableGlitching();
      println("Cell at row " + row + " and column " + col + " is glitching");
    }
  }

  void display() {
    // Draw the full grid normally
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        cells[i][j].display();
      }
    }

    // Full grid glitch overlay (tile 6, round 1 only)
    if (currentRound == 1
        && !user.isOffGrid
        && cells[user.currentRow][user.currentCol].number == 6) {

      stroke(255);
      float dash = 5;

      // Vertical dashed lines
      for (int i = 0; i <= 5; i++) {
        float gx = gridOffsetX + i * cellSize;
        for (float gy = gridOffsetY; gy < gridOffsetY + 5 * cellSize; gy += dash * 2) {
          line(gx, gy, gx, gy + dash);
        }
      }

      // Horizontal dashed lines
      for (int i = 0; i <= 5; i++) {
        float gy = gridOffsetY + i * cellSize;
        for (float gx = gridOffsetX; gx < gridOffsetX + 5 * cellSize; gx += dash * 2) {
          line(gx, gy, gx + dash, gy);
        }
      }
    }

    // Inverted row glitch overlay (tile 19 only, round 1) - constant (no flicker)
    if (currentRound == 1
        && !user.isOffGrid
        && cells[user.currentRow][user.currentCol].number == 19) {

      noStroke();
      fill(255); // solid white bars
      int keepRow = cells[user.currentRow][user.currentCol].row;

      for (int rr = 0; rr < rows; rr++) {
        if (rr == keepRow) continue; // keep this row normal
        float yRow = gridOffsetY + rr * cellSize;
        rect(gridOffsetX, yRow, cellSize * cols, cellSize);
      }
    }

    // Full screen blackout (round 2, tile 10). Player avatar still visible.
    if (currentRound == 2
        && !user.isOffGrid
        && cells[user.currentRow][user.currentCol].number == 10) {

      noStroke();
      fill(0);
      rect(0, 0, width, height);

      // Version B: supportive silence glitch
      scoreTracker.applySilenceGlitchSupportive();
    }
  }

  // Keep this helper if your OSCSender uses it
  GridCell getCellForLogical(int row, int col) {
    return cells[row][col];
  }
}
