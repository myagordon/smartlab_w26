//file: User.pde
class User {
  int currentRow = 0;
  int currentCol = 0;
  boolean isOffGrid = false;

  // bell opportunity latch 
  boolean bellOpportunityActive = false;

  User() {
    grid.cells[currentRow][currentCol].isUserHere = true;
  }

  // Call when 'b' is pressed
  void tryBellHit() {
    // Only counts if there is an active bell opportunity
    if (!bellOpportunityActive) return;

    bellOpportunityActive = false;
    scoreTracker.onBellHit();
    println("Bell hit! successPoints=" + scoreTracker.successPoints);
  }

  // Update position directly from sensor coordinates
  void updatePosition(int newRow, int newCol) {
    boolean outOfBounds = newRow < 0 || newRow >= grid.rows || newCol < 0 || newCol >= grid.cols;
    if (isRestrictedColumnRound && newCol != 2) outOfBounds = true;

    // Prevent double-counting when sensor repeats the same tile
    boolean sameTileAndState =
      (newRow == currentRow) && (newCol == currentCol) && (outOfBounds == isOffGrid);
    if (sameTileAndState) return;

    boolean wasOffGrid = isOffGrid;

    clearCurrentPosition();

    currentRow = newRow;
    currentCol = newCol;
    isOffGrid = outOfBounds;

    if (isOffGrid) {
      // Entering off-grid starts a bell opportunity (once per excursion)
      if (!wasOffGrid) {
        bellOpportunityActive = true;
        scoreTracker.onOffGridEntered();  // B2: playfulness boosts confidence / reduces bias
      }
      println("User is OFF-GRID at position (" + newRow + ", " + newCol + ")");
      return;
    }

    // On-grid
    grid.cells[currentRow][currentCol].isUserHere = true;

    // If returning from off-grid and opportunity still active, that's a failure event
    if (wasOffGrid && bellOpportunityActive) {
      bellOpportunityActive = false;
      scoreTracker.onBellMiss();
      println("Missed bell opportunity (failure event).");
    }

    printCurrentPosition();
  }

  void clearCurrentPosition() {
    if (!isOffGrid) {
      if (currentRow >= 0 && currentRow < gridRows && currentCol >= 0 && currentCol < gridCols) {
        grid.cells[currentRow][currentCol].isUserHere = false;
      }
    }
  }

  // Keep avatar visible even off-grid 
  void display() {
    float x, y;
  
    // If on-grid and the cell exists, draw at the cell's actual center
    if (!isOffGrid
        && currentRow >= 0 && currentRow < grid.rows
        && currentCol >= 0 && currentCol < grid.cols
        && grid.cells[currentRow][currentCol].number >= 0) {
  
      GridCell c = grid.cells[currentRow][currentCol];
      x = c.x + cellSize / 2.0;
      y = c.y + cellSize / 2.0;
  
    } else {
      // Off-grid: fall back to grid-relative position so it's still visible
      x = gridOffsetX + (currentCol + 0.5) * cellSize;
      y = gridOffsetY + (currentRow + 0.5) * cellSize;
    }
  
    fill(0, 0, 0, 25);
    noStroke();
    ellipse(x + 3, y + 3, cellSize / 2, cellSize / 2);
    
    fill(255, 50, 80, 220);
    stroke(0, 120);
    strokeWeight(2);
    ellipse(x, y, cellSize / 2, cellSize / 2);
  }

  void printCurrentPosition() {
    if (!isOffGrid && currentRow >= 0 && currentRow < gridRows && currentCol >= 0 && currentCol < gridCols) {
      int cellIndex = grid.cells[currentRow][currentCol].number;
      println("User is on cell at row " + currentRow + ", column " + currentCol + " (" + cellIndex + ")");
    }
  }
}
