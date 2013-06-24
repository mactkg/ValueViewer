import javax.swing.JFrame;
import javax.swing.JPanel;
import java.awt.Graphics;
import java.awt.Color;
import java.awt.Insets;
import java.util.Map;
import java.lang.reflect.Field;

class Size {
  int width, height;

  Size(int _width, int _height) {
    width = _width;
    height = _height;
  }
}

class ValueViewer extends JFrame {
  static final int margin = 5;
  static final int rowHeight = 30;
  HashMap<String, Object> prevDict = new HashMap<String, Object>();
  Object pObject;
  Size screenSize;
  ViewPanel panel;

  ValueViewer(Object _pObject) {
    pObject = _pObject;

    panel = new ViewPanel();
    panel.setBounds(getInsets().left, getInsets().top, 200, 600);
    add(panel);

    screenSize = new Size(200 + getInsets().left, 600 + getInsets().top);
    setSize(screenSize.width, screenSize.height);
    setVisible(true);

    Thread thread = new Thread(new Runnable() {
      void run() {
        while (true) {
          repaint(100, 0, 0, screenSize.width, screenSize.height);
          try {
            Thread.sleep((long)50);
          } catch (Exception e) {}
        }
      }
    }
    );
    thread.start();
  }

  void paint(Graphics g) {
    super.paint(g);
  }

  class ViewPanel extends JPanel {
    public void paintComponent(Graphics g) {
      g.setColor(new Color(255, 255, 255));
      g.fillRect(0, 0, screenSize.width, screenSize.height);

      Field[] fields = pObject.getClass().getDeclaredFields();
      int i = 0;
      for (Field f : fields) {
        try {
          String type = f.getType().toString();
          if (!(type.equals("int") || type.equals("float") || type.equals("boolean") || type.equals("class java.lang.String")))
            continue;

          if (prevDict.containsKey(f.getName()) && (type.equals("int") || type.equals("float"))) {
            float f1 = Float.parseFloat(f.get(pObject).toString());
            float f2 = Float.parseFloat(prevDict.get(f.getName()).toString());
            if (f1 > f2) {
              g.setColor(Color.getHSBColor(0.0, min(1.0, (f1 - f2) / 10.0), 1.0));
              g.fillRect(0, i * rowHeight + 1, screenSize.width, rowHeight - 1);
            }
            if (f1 < f2) {
              g.setColor(Color.getHSBColor(0.6, min(1.0, (f2 - f1) / 10.0), 1.0));
              g.fillRect(0, i * rowHeight + 1, screenSize.width, rowHeight - 1);
            }
          }

          prevDict.put(f.getName(), f.get(pObject).toString());

          g.setColor(new Color(0, 0, 0));
          g.drawLine(0, (i + 1) * rowHeight, screenSize.width, (i + 1) * rowHeight);
          g.drawString(f.getName(), margin, (i + 1) * rowHeight - margin);
          g.drawString(f.get(pObject).toString(), screenSize.width / 2 + margin, (i + 1) * rowHeight - margin);
          i++;
        } catch(Exception e) {}
      }
      g.drawLine(screenSize.width / 2, 0, screenSize.width / 2, screenSize.height);
    }
  }
}

