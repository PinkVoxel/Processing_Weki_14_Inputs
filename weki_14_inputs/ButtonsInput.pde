
void mousePressed() {
  //File selection is not limited to audio files, but only audio will work fine
  if (selectButton.hover) {
    if(!samplePlaying) selectInput("Select an audio file to train on:", "fileSelected");
  }

  if (toggleButton.hover) {
    if(!samplePlaying) triggerMode =  !triggerMode;
  }
}


void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    mySample = minim.loadFile(selection.getAbsolutePath(), 2048);

    myAudioFFT = new FFT(mySample.bufferSize(), mySample.sampleRate());
    myAudioFFT.linAverages(myAudioRange);
    myAudioFFT.window(FFT.GAUSS);

    mySample.play();
    selectButton.buttonActivate();

    println("Training started for Gesture number: "+currentGestureNo);
    OscMessage msg = new OscMessage("/wekinator/control/startDtwRecording");
    msg.add(int(currentGestureNo));
    oscP5.send(msg, dest);
  }
}

class Button {

  boolean hover = false;
  boolean active = false;
  float x_pos, y_pos, size;
  String content;
  color c_idle = color(127);
  color c_hover = color(255);
  color c_active = color(255, 0, 0);

  Button() {
  }

  void drawButton(String _c, float _x, float _y, float _s) {
    x_pos = _x;
    y_pos = _y;
    size = _s;
    content = _c;
    mouseHover();
    noStroke();
    if (active) fill(c_active);
    else if (hover) fill(c_hover);
    else fill(c_idle);
    rect(x_pos, y_pos, size, size);
    fill(0);
    text(content, x_pos+size*0.4, y_pos+size*0.6);
  }

  void mouseHover() {
    if (mouseX >= x_pos 
      && mouseX <= x_pos + size 
      && mouseY >= y_pos
      && mouseY <= y_pos + size) {
      hover = true;
    } else {
      hover = false;
    }
  }

  void buttonActivate() {
    active = true;
  }

  void buttonDeactivate() {
    active = false;
  }
}
