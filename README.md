# Sound Gloves

## Description
- Sound Gloves for playing music or audio live
  
## Demo
- [Demo.mp4 ](https://github.com/bjarro/sound_gloves/blob/92ed46496e745248bce3614b2cc112aa8ef51da7/Demo.mp4)
  
## Features
 - play up to 10 unique sounds per sound kit by tapping fingers on a surface
 - Change the current sound kit (up to 4) by tilting the left hand (North, South, East, West)
 - Record loops using a combination of inputs 
	 - by tilting the left hand and tapping the corresponding finger to save the loop to
 - Play loops using a combination of inputs
	 - by pressing the palm sensor, and then tapping the corresponding finger where the loop is saved
 - Calibration feature to adapt to varying light conditions and surfaces (setting the baseline light thresholds).

## Challenges:
- Since light sensors were used (due to availability):
	- Lighting issues
		- lighting of the environment must be controlled
		- stray lightings can accidentally trigger the sensors
	- Durability considerations
		- Light sensors are probably not  designed to withstand constant impacts
	- In the demo, I used a white towel to maximize reflectivity and to soften impacts to the light sensors
- latency between tapping fingers and hearing the audio, delay could be due to laptop / drivers / arduino
	 - difficult to synchronize loops, can be managed by quantizing the loops

## Components:
- Hardware components include Arduino, 11 light sensors, and 1 tilt sensor.

## Software
- Written using c/c++ (.ino, .pde) files
