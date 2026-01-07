//file: GridCell.pde
class GridCell {
  float x, y;
  int size;
  int number;
  int row, col;
  boolean isGlitching = false;
  boolean isUserHere = false;

  GridCell(float x, float y, int size, int number, int row, int col) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.number = number;
    this.row = row;
    this.col = col;
  }

  void enableGlitching() {
    isGlitching = true;
  }

  void display() {
    if (isGlitching) {
      fill(random(255), random(255), random(255));
    } else {
      fill(255);
    }

    stroke(0);
    strokeWeight(3);
    rect(x, y, size, size);

    fill(0);
    textAlign(CENTER, CENTER);
    text(number + "\n" + (isUserHere ? "1" : "0"), x + size / 2.0, y + size / 2.0);
  }
}
