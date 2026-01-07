//file: OSCSend.pde
class OSCSender {

  void sendOSC() {
    OscMessage msg = new OscMessage("/cells");

    for (int row = 0; row < grid.rows; row++) {
      for (int col = 0; col < grid.cols; col++) {

        // If you still use the restricted-column mechanic anywhere, keep this:
        // if (isRestrictedColumnRound && col != 2) continue;

        GridCell c = grid.cells[row][col];

        msg.add(c.number);
        msg.add(c.col);
        msg.add(c.row);
        msg.add(c.isUserHere ? 1 : 0);
        msg.add(c.isGlitching ? 1 : 0);
      }
    }

    oscP5.send(msg, remoteAddress);
  }
}
