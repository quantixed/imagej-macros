macro 'myTool Tool - C000O4488D88' {
  getCursorLoc(x, y, z, modifiers);
  left=16;
  while ((modifiers&left)!=0) {
    getCursorLoc(x, y, z, modifiers);
    makeRectangle(x-200,y-200,400,400);
    wait(10);
  }
} 