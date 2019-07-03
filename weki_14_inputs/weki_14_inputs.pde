//Messy FFT sound input alternative to Wekinator - will clean it later. Decent enough for prototyping, but consider using something like 
//https://github.com/fiebrink1/wekinator_examples/tree/master/inputs/AudioInput/AudioInputWithOpenFrameworks/Various_Audio_Inputs
//for better results.

//Change volThreshold according to the loudness of the sounds you want to use as training input
//Change the boolean triggerMode to false to send sound information at all times

//Updated 07/19 Pawel Kudel edit
//Added a function for processing audio files
//use keyboard to select gesture number
//then the GUI button to select an audio file

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;

AudioPlayer audioSample;

Button selectButton = new Button();
File soundSelected;
boolean samplePlaying = false;
int currentGestureNo = 1;

Minim       minim;
AudioInput  myAudio; //Use líne in input (microphone/soundflower/lineIn)
AudioSample mySample; //Use an audio sample
FFT         myAudioFFT;

int         myAudioRange     = 13;
int         myAudioMax       = 100;
float       myAudioAmp       = 200.0;
float       myAudioIndex     = 0.2;
float       myAudioIndexAmp  = myAudioIndex;
float       myAudioIndexStep = 0.35;

float avgVolume = 0;

boolean sending = false;
color bgColor; 
boolean thresholdMode = true;
float volThreshold = 2.0;

boolean triggerMode = false;

int triggerTimerThreshold = 200;
long startTimer = 0;


void setup() {
  size(850, 300);
  background(200);

  minim   = new Minim(this);
  myAudio = minim.getLineIn(Minim.MONO); 

  myAudioFFT = new FFT(myAudio.bufferSize(), myAudio.sampleRate());
  myAudioFFT.linAverages(myAudioRange);
  myAudioFFT.window(FFT.GAUSS);

  oscP5 = new OscP5(this, 9000);
  dest = new NetAddress("127.0.0.1", 6448);
  int currentGestureNo = 1;
}

//---------Main Loop start-------

void draw() {
  long timer = millis() - startTimer;

  currentGestureNo = key-48;

  if (sending == true) {
    bgColor = color(0, 180, 0);
  } else {
    bgColor = color(180, 0, 0);
  }
  background(bgColor);

  if (!samplePlaying) myAudioFFT.forward(myAudio.mix);
  else myAudioFFT.forward(audioSample.mix);


  for (int i = 0; i < myAudioRange; ++i) {
    stroke(0);
    fill(255);
    float tempIndexAvg = (myAudioFFT.getAvg(i) * myAudioAmp) * myAudioIndexAmp;
    float tempIndexCon = constrain(tempIndexAvg, 0, myAudioMax);
    rect( 100 + (i*50), 100, 50, tempIndexCon);
    avgVolume+=tempIndexAvg;
  }


  avgVolume = avgVolume/12;

  if (triggerMode) {
    if (timer > triggerTimerThreshold && avgVolume > volThreshold) { 
      sending = true;
      startTimer = millis();
    } else {
      sending = false;
    }
  } else {
    sending = true;
  }

  text("avgVolume: " + avgVolume, 10, 20);
  if (sending) text("sending!", 10, 40);
  text("select gesture number with keyboard", 10, 60);
  text("current Gesture: "+currentGestureNo, 10, 80);
  selectButton.drawButton(10, 100, 30);

  myAudioIndexAmp = myAudioIndex;

  stroke(255, 0, 0); 
  line(100, 100+100, width-100, 100+100);


  if (audioSample != null) {
    samplePlaying = true;
    if (audioSample.position() >= audioSample.length()) {
      samplePlaying = false;
      selectButton.buttonDeactivate();
      myAudioFFT = new FFT(myAudio.bufferSize(), myAudio.sampleRate());
      myAudioFFT.linAverages(myAudioRange);
      myAudioFFT.window(FFT.GAUSS);
      //Stop training
      OscMessage msg = new OscMessage("/wekinator/control/stopDtwRecording");
      msg.add(int(currentGestureNo));
      oscP5.send(msg, dest);
      audioSample = null;
    }
  }

  if (sending) sendOsc();
}

//---------Main Loop end-------

void stop() {
  myAudio.close();
  minim.stop();  
  super.stop();
}

void sendOsc() {
  OscMessage msg = new OscMessage("/wek/inputs");
  for (int i = 0; i < myAudioRange; ++i) {
    float tempIndexAvg = (myAudioFFT.getAvg(i) * myAudioAmp) * myAudioIndexAmp;
    msg.add(tempIndexAvg);
  }
  msg.add(avgVolume);
  oscP5.send(msg, dest);
}
