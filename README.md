# Processing+Wekinator for audio samples and live audio input

Simple sketch allowing easy handling of audio samples and a live audio input for the purpose of training and classifying Wekinator Inputs.

Based on the default Dynamic Time Warping setup in Wekinator.


###### Instructions

Setup your Wekinator Dynamic Time Warping Project to take 14 inputs. 
This sketch works for any number of gestures when using only live input and up to 9 gestures when using audio samples.

Launch using Processing 3.
You'll need Minim and OSCP5 libraries.

The sketch should automatically grab your default live audio input. If you'd like to specify a different one, you'll have to change the code.

For audio input straight to Wekinator make sure the status is "sending" - the rest should be handled automatically.

For training on audio samples:
- Press any number keys (1-9) to specify the target gesture
- Press the "+" button
- In the popup window select the audio file
- Training should begin automatically - wait for it to finish
