void mousePressed() {
  if (selectButton.hover) {
    selectInput("Select an audio file to train on:", "fileSelected");
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {

    println("User selected " + selection.getAbsolutePath());
    audioSample = minim.loadFile(selection.getAbsolutePath(), 2048);

    myAudioFFT = new FFT(audioSample.bufferSize(), audioSample.sampleRate());
    myAudioFFT.linAverages(myAudioRange);
    myAudioFFT.window(FFT.GAUSS);

    audioSample.play();
    selectButton.buttonActivate();
    //Start training
    OscMessage msg = new OscMessage("/wekinator/control/startDtwRecording");
    msg.add(int(currentGestureNo));
    oscP5.send(msg, dest);
  }
}

class Button {

  boolean hover = false;
  boolean active = false;
  float x_pos, y_pos, size;
  color c_idle = color(127);
  color c_hover = color(255);
  color c_active = color(255, 0, 0);

  Button() {

  }

  void drawButton(float x, float y, float s) {
        x_pos = x;
    y_pos = y;
    size = s;
    mouseHover();
    noStroke();
    if (active) fill(c_active);
    else if (hover) fill(c_hover);
    else fill(c_idle);
    rect(x_pos, y_pos, size, size);
    fill(0);
    text("+", x_pos+size*0.4, y_pos+size*0.6);
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
