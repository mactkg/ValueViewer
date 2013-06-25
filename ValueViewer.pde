import javax.swing.*;
import java.awt.*;
import java.util.Map;
import java.lang.reflect.*;
import java.awt.event.*;

class Size {
  int width, height;

  Size(int _width, int _height) {
    width = _width;
    height = _height;
  }
}

class ValueViewer extends JFrame{
  static final int margin = 8;
  static final int rowHeight = 30;
  final String[] showType = {"int", "java.lang.Integer", "long", "java.lang.Long", "float", "java.lang.Float", "double", "java.lang.Double", "boolean", "java.lang.Boolean", "class java.lang.String", "java.lang.String"};
  final String[] numericType = {"int", "java.lang.Integer", "float", "java.lang.Float", "double", "java.lang.Double", "long", "java.lang.Long"};
  HashMap<String, Object> userValues = new HashMap<String, Object>();
  HashMap<String, Object> prevDict = new HashMap<String, Object>();
  StringList rmList = new StringList();
  int row;
  boolean onPause = false;
  Object pObject;
  Size screenSize;
  ViewPanel panel;
  JScrollBar scrollbar;

  ValueViewer(Object _pObject) {
    pObject = _pObject;
    
    panel = new ViewPanel();
    panel.setLayout(new BorderLayout());
    panel.setBounds(getInsets().left, getInsets().top, 400, 600);
    add(panel);
    
    scrollbar = new JScrollBar();
    scrollbar.setMinimum(0);
    scrollbar.setMaximum(0);
    scrollbar.addAdjustmentListener(new AdjustmentListener(){
      void adjustmentValueChanged(AdjustmentEvent e){
        onPause = false;
      }
    }
    );
    panel.add(scrollbar, BorderLayout.EAST);
    
    screenSize = new Size(400 + getInsets().left + scrollbar.getWidth(), 600 + getInsets().top);
    setSize(screenSize.width, screenSize.height);
    setVisible(true);
    
    screenSize.width = getWidth() - scrollbar.getWidth();
    screenSize.height = getHeight() - getInsets().top;
    
    addComponentListener(new ComponentListener() {
      void componentHidden(ComponentEvent e) {}
      void componentMoved(ComponentEvent e) {}
      void componentShown(ComponentEvent e) {}
      
      void componentResized(ComponentEvent e) {
        screenSize.width = getWidth() - scrollbar.getWidth();
        screenSize.height = getHeight() - getInsets().top;
        onPause = false;
      }
    }
    );
    
    addMouseListener(new MouseListener(){
     void mousePressed(java.awt.event.MouseEvent e) {}
     void mouseReleased(java.awt.event.MouseEvent e) {}
     void mouseEntered(java.awt.event.MouseEvent e) {}
     void mouseExited(java.awt.event.MouseEvent e) {}
     
     void mouseClicked(java.awt.event.MouseEvent e) {
       onPause = !onPause;
       repaint();
     }
    }
    );

    Thread thread = new Thread(new Runnable() {
      void run() {
        while (true) {
          if (!onPause){
            repaint();
          }
          try {
            Thread.sleep(50);
          } catch (Exception e) {}
        }
      }
    }
    );
    thread.start();
  }

  void addValue(String name, Object value) {
    userValues.put(name, value);
  }
  
  void removeValue(String name){
    if (!rmList.hasValue(name)){
      rmList.append(name);
    }
  }

  void paint(Graphics g) {
    super.paint(g);
  }
  
  private class ViewPanel extends JPanel {
    void paintComponent(Graphics g) {
      g.setColor(new Color(255, 255, 255));
      g.fillRect(0, 0, screenSize.width, screenSize.height);

      row = min(-scrollbar.getValue(), 0);
      Field[] fields = pObject.getClass().getDeclaredFields();
      for (Field f : fields) {
        if (rmList.hasValue(f.getName()))
          continue;
        
        try {
          String type = f.getType().toString();
          if (f.getType().isArray()) {
            drawArray(g, f);
          }
          drawValue(g, f.getName(), f.get(pObject).toString(), type);
        } catch(Exception e) {}
      }

      for (Map.Entry v : userValues.entrySet()) {
        String type = v.getValue().getClass().getName().toString();
        drawValue(g, v.getKey().toString(), v.getValue().toString(), type);
      }
      
      row += scrollbar.getValue();
      scrollbar.setMaximum(max(ceil((float)(row * rowHeight - screenSize.height) / rowHeight), 0));
      g.drawLine(screenSize.width / 2, 0, screenSize.width / 2, screenSize.height);
      
      if (onPause){
        g.setColor(new Color(255, 0, 0));
        g.drawRect(0, 0, screenSize.width - 1, screenSize.height - 1);
      }
    }

    private boolean containsString(String[] strs, String key) {
      for (String s : strs) {
        if (s.equals(key))
          return true;
      }
      return false;
    }

    private void compareValues(Graphics g, float f1, float f2, int x, int width) {
      if (f1 > f2) {
        g.setColor(Color.getHSBColor(0.0, min(1.0, (f1 - f2) / 10.0), 1.0));
        g.fillRect(x, row * rowHeight + 1, width, rowHeight - 1);
      }
      if (f1 < f2) {
        g.setColor(Color.getHSBColor(0.6, min(1.0, (f2 - f1) / 10.0), 1.0));
        g.fillRect(x, row * rowHeight + 1, width, rowHeight - 1);
      }
    }
    
    private void drawValue(Graphics g, String name, String value, String type) {
      if (!containsString(showType, type))
        return;

      if (prevDict.containsKey(name) && containsString(numericType, type)) {
        compareValues(g, Float.parseFloat(value.toString()), Float.parseFloat(prevDict.get(name).toString()), screenSize.width/2, ceil((float)screenSize.width/2));
      }
      
      prevDict.put(name, value);
      
      g.setColor(new Color(0, 0, 0));
      g.drawLine(0, (row + 1) * rowHeight, screenSize.width, (row + 1) * rowHeight);
      g.drawString(name+" ("+type+")", margin, (row + 1) * rowHeight - margin);
      g.drawString(value, screenSize.width / 2 + margin, (row + 1) * rowHeight - margin);
      row++;
    }
    
    private String keyName = "";
    private int keyNum = 0;
    private HashMap<String, Integer> arrayCount = new HashMap<String, Integer>();
    private HashMap<String, Integer> arrayDim = new HashMap<String, Integer>();
    private HashMap<String, IntList> depthCount = new HashMap<String, IntList>();
    private HashMap<String, IntList> arrayIndex = new HashMap<String, IntList>();
    private StringList initilizedKey = new StringList();
    
    private int countArrayDimention(Object object, int depth){
      if (Array.get(object, 0).getClass().isArray()) {
        return countArrayDimention(Array.get(object, 0), depth + 1);
      }else{
        return depth + 1;
      }
    }
    
    private int countArray(Object object){
      if (Array.get(object, 0).getClass().isArray()) {
        return Array.getLength(object) * countArray(Array.get(object, 0));
      }else{
        return 1;
      }
    }
    
    private void drawFrameLow(Graphics g, Object object, int depth) {
      if (Array.get(object, 0).getClass().isArray()) {
        for(int i = 0; i < Array.getLength(object); i++){
          drawFrameLow(g, Array.get(object, i), depth + 1);
        }
      } else {
        int len = Array.getLength(object);
        for(int i = 0; i < len; i++){
          int x = (int)((float)screenSize.width / 2 + (((float)screenSize.width / 2) / len) * i);
          int w = ceil(((float)screenSize.width / 2) / len);
          
          if (prevDict.containsKey(keyName + keyNum) && containsString(numericType, Array.get(object, i).getClass().getName())){
            compareValues(g, Float.parseFloat(Array.get(object, i).toString()), Float.parseFloat(prevDict.get(keyName + keyNum).toString()), x, w);
          }
          keyNum++;
        }
        row++;
      }
    }
    
    private int drawFrameHigh(Graphics g, Object object, int depth){
      if (Array.get(object, 0).getClass().isArray()) {
        int size = drawFrameHigh(g, Array.get(object, 0), depth + 1);
        g.setColor(Color.getHSBColor(1.0 / arrayDim.get(keyName) * depth, 1.0, 1.0));
        
        for(int i = 0; i < arrayCount.get(keyName)/size; i++){
          int k1 = min(depthCount.get(keyName).get(i*size), depth);
          int k2 = min(depthCount.get(keyName).get((i+1)*size), depth);
          g.drawRect(screenSize.width / 2 + 1 + depth, (row + i * size) * rowHeight + k1, ceil((float)screenSize.width / 2) - (1 + depth) * 2, rowHeight * size - k1 - k2);
          
          if (!initilizedKey.hasValue(keyName)){
            depthCount.get(keyName).increment(i * size);
          }
          
        }
        return Array.getLength(object) * size;
      }else{
        return 1;
      }
    }
    
    private void enumArray(Graphics g, Object object, int depth) {
      if (Array.get(object, 0).getClass().isArray()) {
        for(int i = 0; i < Array.getLength(object); i++){
          arrayIndex.get(keyName).set(depth, i);
          
          enumArray(g, Array.get(object, i), depth + 1);
        }
      } else {
        int len = Array.getLength(object);
        for(int i = 0; i < len; i++){
          arrayIndex.get(keyName).set(depth, i);
          
          int x = (int)((float)screenSize.width / 2 + (((float)screenSize.width / 2) / len) * i);
          int w = ceil(((float)screenSize.width / 2) / len);
          
          g.setColor(new Color(0, 0, 0));
          g.drawLine(x, row * rowHeight, x, (row + 1) * rowHeight);
          
          String idx = "";
          for(int j : arrayIndex.get(keyName)){
            idx = idx + "[" + j + "]";
          }
          g.drawString(idx + " " + Array.get(object, i).toString(), x + margin, (row + 1) * rowHeight - margin);
          
          prevDict.put(keyName + keyNum, Array.get(object, i).toString());
          keyNum++;
        }
        row++;
      }
    }
    
    private void drawArray(Graphics g, Field f){
      try{
        keyName = f.getName();
        keyNum = 0;
        if (!arrayCount.containsKey(keyName))
          arrayCount.put(keyName, countArray(f.get(pObject)));
        if (!arrayDim.containsKey(keyName))
          arrayDim.put(keyName, max(1, countArrayDimention(f.get(pObject), 0) - 1));
        if (!depthCount.containsKey(keyName)){
          depthCount.put(keyName, new IntList());
          for(int i = 0; i < arrayCount.get(keyName); i++){
            depthCount.get(keyName).append(0);
          }
        }
        if (!arrayIndex.containsKey(keyName)){
          arrayIndex.put(keyName, new IntList());
          for(int i = 0; i < arrayDim.get(keyName); i++){
            depthCount.get(keyName).append(0);
          }
        }
        
        g.drawString(keyName, margin, (row + 1) * rowHeight - margin);
        int tmp = row;
        drawFrameLow(g, f.get(pObject), 0);
        row = tmp;
        keyNum = 0;
        drawFrameHigh(g, f.get(pObject), 0);
        enumArray(g, f.get(pObject), 0);
        g.drawLine(0, row * rowHeight, screenSize.width, row * rowHeight);
        
        if (!initilizedKey.hasValue(keyName))
          initilizedKey.append(keyName);
      } catch(Exception e) {}
    }
  }
}

