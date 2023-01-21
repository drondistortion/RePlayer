/*
 *  RePlayer, simple player of .mp3 files for rehearsal purposes.
 *  Hitting space bar starts playback, hitting space bar again stops
 *  playback and rewinds.

 *  Copyright (C) 2022 Dron Distortion

 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import ddf.minim.*;
import java.io.File;
import java.io.FilenameFilter;

//String FOLDER = "/Music";
int rectColor;
class mySq {
        public int x;
        public int y;
        public int size;
        public boolean rectOver;
        public boolean isPressed;
        public int countDown;
        public boolean isReleased;
        public String btnText;

        public mySq(
                        int x,
                        int y,
                        int size,
                        boolean rectOver,
                        boolean isPressed,
                        int countDown,
                        boolean isReleased,
                        String btnText) {
                this.x = x;
                this.y = y;
                this.size = size;
                this.rectOver = rectOver;
                this.isPressed = isPressed;
                this.countDown = countDown;
                this.isReleased = isReleased;
                this.btnText = btnText;
        }
}


// list files
String[] listFiles(String dir)
{
        java.io.File file = new java.io.File(dir);
        if (file.isDirectory())
        {
                FilenameFilter filter = new FilenameFilter() {
                        @Override
                        public boolean accept(File pathname, String name) {
                                return name.endsWith(".mp3");
                        }
                };

                String[] files = file.list(filter);

                return files;
        }
        else
        {
                return null;
        }
}

boolean overRect(int x, int y, int width, int height)
{
    if (mouseX >= x && mouseX <= x+width &&
            mouseY >= y && mouseY <= y+height) {
        return true;
    }
    else {
        return false;
    }
}

int lastY = 0;
void update()
{
    if (gPressed) {
      gPositionY = gPositionY + (gLastMouseY - mouseY)/1000;
    }
    for (int i = 0; i < filenames.length; i++){
        if (play != null) {
            boolean isPlaying = play.isPlaying();
            if (start && !isPlaying) {
                play.play();
            }
            else if (!start && isPlaying) {
                stop();
            }
        }

        /*list.get(i).y -= gScroll*5;*/
        if (lastY != gPositionY) {
          list.get(i).y -= gPositionY;
        }

        if (overRect(list.get(i).x, list.get(i).y, width, list.get(i).size) ) {
            list.get(i).rectOver = true;
        }
        else {

            list.get(i).rectOver = false;
        }
    }
    lastY = gPositionY;
    gScroll = 0;
}

Minim minim;
AudioPlayer play;
ArrayList<mySq> list = new ArrayList<mySq>();
String[] filenames;
int rectX = 0;
final int rectSize = 30;
int tab = 8;
boolean start = false;
PFont f;

void setup()
{
    size(800, 600);
    //fullScreen();
    background(0);
    f = createFont("Monospaced.plain", 24);
    int rectY = -rectSize;
    rectColor = 0;
    colorMode(HSB, 160, 100, 100);

    String path = sketchPath();
    //path += FOLDER;
    print("Music path: ");
    println(path);
    filenames = listFiles(path);
    minim = new Minim(this);
    for (String i:filenames) {
        list.add(new mySq(rectX, rectY+=rectSize, rectSize, false, false, -1, false, i));
    }
}

int scrollWidth = 0;

boolean checkScroll(int y)
{
  if (y > height)
    return true;
  else
    return false;
}

int gScroll = height;
int gPositionY;
int gScrollH;

void lockScrollPosition()
{
    if (gPositionY + gScrollH > height) {
	gPositionY = height - gScrollH;
    }

    if (gPositionY < 0) {
	gPositionY = 0;
    }
}

void showScroll()
{
    scrollWidth = 10;
    int maxItems = height / rectSize;
    gScrollH = list.size() * rectSize;
    for (int i = 0; i < list.size() - maxItems; i++) {
	gScrollH -= rectSize;
    }
    /*
    if (gScrollH > height) {
        gScrollH = height - rectSize;
    }
    */
    fill(0, 255, 255, 50);
    lockScrollPosition();
    rect(width-scrollWidth, gPositionY, scrollWidth, gScrollH);
}

void draw()
{
    background(0);
    update();

    boolean scroll_flag = false;
    for (int i = 0; i < filenames.length; i++) {
        rectColor = i*10%160;
        fill(rectColor, 40, 70);
        stroke(255);
        int y = list.get(i).y;
        rect(list.get(i).x, y, width, list.get(i).size);
        scroll_flag = checkScroll(y);
        stroke(0);
        if (list.get(i).isPressed)  {
            fill(160-i*10,30,70);
        }
        else if (list.get(i).rectOver) {
            fill(80-i*10,30,70);
        }
        else {
            fill(160 - i*10,100,30);
        }
        textFont(f);
        text(filenames[i], tab, list.get(i).y+rectSize/2+10);
    }
    if (scroll_flag) {
        showScroll();
    }
    /*
       if (gPressed) {
       gPositionY += (gLast
       }
     */
}

int gLastMouseY = 0;
boolean gPressed = false;

void mousePressed()
{
  gPressed = true;
  gLastMouseY = mouseY;
}

void mouseReleased()
{
    gPressed = false;
    gLastMouseY = mouseY;
    for (int i = 0; i < filenames.length; i++) {
        list.get(i).isPressed = false;
        start = false;
        if (list.get(i).rectOver) {
            list.get(i).isPressed = !list.get(i).isPressed;
            play = minim.loadFile(filenames[i], 2048);
        }
    }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  gScroll = int(e);
  gPositionY += int(e);
}

void stop()
{
    if (play == null)
        return;
    if (play.isPlaying()) {
        if (play.hasControl(Controller.GAIN)) {
            for (float val = 0; val != -48; val -= 0.5) {
                play.setGain(val);
                delay(5);
            }
            delay(50);
            play.setGain(-100);
            delay(50);
        }
        play.pause();
        play.rewind();
        if (play.hasControl(Controller.GAIN))
            play.setGain(0);
        start = false;
    }
}

void keyPressed()
{
    if (key == ' ') {
        start = !start;
    }
}
