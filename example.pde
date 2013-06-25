ValueViewer viewer = new ValueViewer(this);

boolean hoge = true;
String fuga = "hello";
int aa = 100;
float bb = 12.8;
double cc = 1.0;
long dd = 50000000;
float[] i = new float[2];
int[][] j = new int[3][3];

void setup() {
  size(600, 400);
  viewer.removeValue("i");
}

void draw() {
  background(128);
  
  viewer.addValue("mouseX", mouseX);
  viewer.addValue("mouseY", mouseY);
  
  viewer.addValue("aa%600", aa%600);
  
  aa++;
  ellipse(aa%600, 200+20.0*sin(bb), 50, 50);
  
  bb -= 0.05;
  j[1][1] = (int)(20.0*sin(bb));
}
