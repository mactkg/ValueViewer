ValueViewer viewer = new ValueViewer(this);

int u = 0;

void setup() {
  size(600, 400);
}

boolean hoge = true;
String fuga = "hello";
int aa = 100;
float bb = 12.8;
boolean hige = false;

void draw() {
  int a = 0;
  background(128);
  aa++;
  bb-= 0.1;
  
  ellipse(aa%600, 200, 50, 50);
}



