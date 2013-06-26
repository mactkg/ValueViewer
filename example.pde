ValueViewer viewer;

boolean fill = true;
String str = "hello";
int x = 100;
float y = 12.8;
double hoge = 1.0;
long fuga = 50000000;
float[] foo = new float[2];
int[][] bar = new int[3][3];

void setup() {
  size(600, 400);
  viewer = new ValueViewer(this);
  viewer.removeValue("foo");
}

void draw() {
  background(128);
  
  viewer.addValue("mouseX", mouseX);
  viewer.addValue("mouseY", mouseY);
  
  viewer.addValue("x%height", x%height);
    
  if(fill)
    fill(255);
  else
    noFill();
  ellipse(x%width, height/2+20.0*sin(y), 50, 50);
  
  y -= 0.05;
  x++;
  bar[1][1] = (int)(20.0*sin(y));
}

void mouseClicked() {
  if(fill == true)
    fill = false;
  else
    fill = true;
}
