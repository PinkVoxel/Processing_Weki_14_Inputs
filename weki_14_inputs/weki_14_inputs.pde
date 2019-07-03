//Messy FFT sound input alternative to Wekinator - will clean it later. Decent enough for prototyping, but consider using something like 
//https://github.com/fiebrink1/wekinator_examples/tree/master/inputs/AudioInput/AudioInputWithOpenFrameworks/Various_Audio_Inputs
//for better results.

//Change volThreshold according to the loudness of the sounds you want to use as training input
//Change the boolean triggerMode to false to send sound information at all times

//Updated 07/19 Pawel Kudel edit
//Added a function for processing audio files
//use number keys to select gesture number
//then the GUI button to select an audio file

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

import oscP5.*;
import netP5.*;

//

OscP5      oscP5;
NetAddress dest;



Minim       minim;
AudioInput  myAudio; //Use líne in input (microphone/soundflower/lineIn)
AudioPlayer mySample;
FFT         myAudioFFT;

Button      selectButton = new Button();
Button      toggleButton = new Button();
File        soundSelected;

int         myAudioRange     = 13;
int         myAudioMax       = 180;
float       myAudioAmp       = 200.0;
float       myAudioIndex     = 0.2;
float       myAudioIndexAmp  = myAudioIndex;
float       myAudioIndexStep = 0.35;

float       audioBarPosX = 250;
float       audioBarPosY = 10;
float       audioBarSpread = 20;

float       UI_X = 10;
float       UI_Y = 20;
float       UI_Off = 20;
float       UI_bttns = 30;

float       avgVolume = 0;
float       volThreshold = 2.0;

int         currentGestureNo = 1;
int         triggerTimerThreshold = 200;

long        startTimer = 0;

boolean     triggerMode = false;
boolean     sending = false;
boolean     thresholdMode = true;
boolean     samplePlaying = false;

color       bgColor; 
color       white = color(255);
color       black = color(0);
color       red = color(255, 0, 0);
color       c_sending = color(20, 80, 20);
color       c_notSending = color(80, 20, 20);


void setup() {
  size(550, 200);

  minim   = new Minim(this);
  myAudio = minim.getLineIn(Minim.MONO); 

  myAudioFFT = new FFT(myAudio.bufferSize(), myAudio.sampleRate());
  myAudioFFT.linAverages(myAudioRange);
  myAudioFFT.window(FFT.GAUSS);

  //Default values for Wekinator's dynamic time warping setup
  oscP5 = new OscP5(this, 9000); //9000
  dest = new NetAddress("127.0.0.1", 6448); //"127.0.0.1", 6448
}



//---------Main Loop start-------

void draw() {

  long timer = millis() - startTimer;
  currentGestureNo = key-48;

  if (mySample != null) {
    samplePlaying = true;
    triggerMode = false;
    
    if (mySample.position() >= mySample.length()) {
      samplePlaying = false;

      selectButton.buttonDeactivate();
      myAudioFFT = new FFT(myAudio.bufferSize(), myAudio.sampleRate());
      myAudioFFT.linAverages(myAudioRange);
      myAudioFFT.window(FFT.GAUSS);
      //Stop training
      println("Training finished for Gesture number: "+currentGestureNo);
      OscMessage msg = new OscMessage("/wekinator/control/stopDtwRecording");
      msg.add(int(currentGestureNo));
      oscP5.send(msg, dest);

      mySample = null;
    }
  }

  if (sending) bgColor = c_sending;
  else bgColor = c_notSending;

  background(bgColor);

  if (!samplePlaying) myAudioFFT.forward(myAudio.mix);
  else myAudioFFT.forward(mySample.mix);

  for (int i = 0; i < myAudioRange; ++i) {
    stroke(black);
    fill(white);
    float tempIndexAvg = (myAudioFFT.getAvg(i) * myAudioAmp) * myAudioIndexAmp;
    float tempIndexCon = constrain(tempIndexAvg, 0, myAudioMax);
    rect(audioBarPosX + (i*audioBarSpread), audioBarPosY, audioBarSpread*0.9, tempIndexCon);
    avgVolume+=tempIndexAvg;
  }
  stroke(black); 
  line(audioBarPosX, audioBarPosY, audioBarPosX+((myAudioRange+1)*audioBarSpread*0.9), audioBarPosY);
  stroke(red); 
  line(audioBarPosX, audioBarPosY+myAudioMax, audioBarPosX+((myAudioRange+1)*audioBarSpread*0.9), audioBarPosY+myAudioMax);

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


  text("Average volume: " + avgVolume, UI_X, UI_Y);
  if (sending) text("Sending!", UI_X, UI_Y+UI_Off);
  else text("Not sending", UI_X, UI_Y+UI_Off);
  text("Select gesture no. with number keys", UI_X, UI_Y+UI_Off*2);
  text("Current Gesture: "+currentGestureNo, UI_X, UI_Y+UI_Off*3);

  selectButton.drawButton("+", UI_X, UI_Y+UI_Off*4, UI_bttns);
  fill(white);
  if (samplePlaying) text("Training...", UI_X+UI_bttns*1.2, UI_Y+UI_Off*4+UI_bttns*0.6);
  toggleButton.drawButton("T", UI_X, UI_Y+UI_Off*5+UI_bttns, UI_bttns);

  myAudioIndexAmp = myAudioIndex;


  if (sending) sendOsc();
}

//---------Main Loop end-------
