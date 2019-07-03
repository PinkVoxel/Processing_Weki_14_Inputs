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
