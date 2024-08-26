

import processing.serial.*;
import processing.sound.*;
import java.util.*;
import ddf.minim.*;



Serial myPort;  // Create object from Serial class
SoundFile[] sounds;
Minim minim;
AudioSample[] sn;
AudioSample[] se;
AudioSample[] sw;
AudioSample[] ss;

boolean is_modifying = false;
boolean is_recording = false;
boolean is_modified = false;
int loopTo = -1;

int curSoundPack = 3;

int curDrawTime;

//int recSounds[][]; //soundIndex, curSoundPack, StartTime
//int numRec = 0;

int loop0[][];
int vars0[];       // isPlaying, i, abs_next_startTime, numRec, abs_prev_startTime

int loop1[][];
int vars1[];

int loop2[][];
int vars2[];

int loop3[][];
int vars3[];

int loop4[][];
int vars4[];

int prevRecord = 0;

void setup() 
{
  minim = new Minim(this);
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 57600);
  sounds = new SoundFile[12];

  initializeSounds();

  loop0 = new int[10000][3];

  vars0 = new int[5];
  vars0[0] = 0;
  vars0[1] = 0;
  vars0[2] = 0;
  vars0[3] = 0;

  loop1 = new int[10000][3];
  vars1 = new int[5];


  loop2 = new int[10000][3];
  vars2 = new int[5];


  loop3 = new int[10000][3];
  vars3 = new int[5];


  loop4 = new int[10000][3];
  vars4 = new int[5];





  frameRate(200);



  //sounds[0] = new SoundFile(this, "1.aif");
  //sounds[1] = new SoundFile(this, "2.aif");
  //sounds[2] = new SoundFile(this, "3.aif");
  //sounds[3] = new SoundFile(this, "4.aif");
  //sounds[4] = new SoundFile(this, "5.aif");
  //sounds[5] = new SoundFile(this, "6.aif");
}


void draw()
{
  // curDrawTime = millis();

  if ( myPort.available() > 0) 
  {  // If data is available,


    char val1 = myPort.readChar();
    int val2 = myPort.read();   

    if (val2 >= 0)
    {
      //println(val1);
      //println(val2);
      manageSerial(val1, val2);
    }
  }

  //println(is_recording);
  checkLoop(0);
  checkLoop(1);
  checkLoop(2);
  checkLoop(3);
  checkLoop(4);
}

void manageSerial(char command, int index)
{

  if (command == 'p')
  {
    if (index != 10)
    {      
      if (!is_modifying)
      {        
        playSound(index, curSoundPack);

        if (is_recording)
        {
          addToLoop(index, loopTo, millis());
        }
      }// 
      else // if is_modifying
      {
        if (index <= 4)
        {

          if (isEmpty(index))    // record if empty
          {       
            if (!is_recording)
            {
              loopTo = index;
              is_recording = true;
              println("Recording Started : " + index);
            }
          } //
          else                 // play/stop if not empty
          {
            if (!isPlaying(index))
            {
              if (index == loopTo)
              {
                addToLoop(-1, loopTo, millis());
                is_recording = false;
              }

              playLoop(index);
            } else
            {
              stopLoop(index);
            }
          }

          is_modified = true;
        } else // index > 4           clear recordings
        {
          if (index == 7)
          {
            emptyLoop(0);
            emptyLoop(1);
            emptyLoop(2);
            emptyLoop(3);
            emptyLoop(4);
            is_recording = false;
          }
        }
      }
    } // if index == 10
    else
    { 

      is_modifying = true;
    }
  } 
  //
  else if (command == 'r')
  {
    if (index == 10)
    {
      is_modifying = false;
      is_modified = false;
    }
  }
  //
  else if (command == 'n')
  {
    curSoundPack = 0;
  } 
  //
  else if (command == 'e')
  {
    curSoundPack = 1;
  } 
  //
  else if (command == 'w')
  {
    curSoundPack = 2;
  } 
  //
  else if (command == 's')
  {
    curSoundPack = 3;
  }
}



void playSound(int index, int soundPack)
{
  if (soundPack == 0)
  {
    //sn[index].trigger();
  } 
  //
  else if (soundPack == 1)
  {
     se[index].trigger();
  } 
  //
  else if (soundPack == 2)
  {
    sw[index].trigger();
  } 
  //
  else if (soundPack == 3)
  {
    ss[index].trigger();
  }
}

void addToLoop(int soundIndex, int loopIndex, int time)
{
  println("Recording: " + soundIndex);

  int[][] loopArray = chooseLoop(loopIndex);
  int[] varsArray = chooseVars(loopIndex);

  int numRec = varsArray[3];

  loopArray[numRec][0] = soundIndex;
  loopArray[numRec][1] = curSoundPack;

  if (numRec > 0)    
  {
    loopArray[numRec][2] = time - prevRecord; // time starts x seconds after previous, x = cur - prev
    prevRecord = time;
  } else
  {
    loopArray[numRec][2] = 0; // time starts at 0
    prevRecord = time;
  }
  varsArray[3]++;
}

//void assignLoop(int index)
//{
//  if (loopTo==0)
//  {
//    loop0 = recSounds;
//  }
//  if (index==1)
//  {
//    loop1 = recSounds;
//  }
//  if (index==2)
//  {
//    loop2 = recSounds;
//  }
//  if (index==3)
//  {
//    loop3 = recSounds;
//  }
//  if (index==4)
//  {
//    loop4 = recSounds;
//  }
//}

void checkLoop(int loopIndex)
{

  int[][] loopArray = chooseLoop(loopIndex);
  int[] varsArray = chooseVars(loopIndex);

  if (varsArray[0] == 1)
  {


    int nextTime = varsArray[2];
    int curTime = millis();    

    if (curTime >= nextTime)
    {
      int i = varsArray[1]; 
      if (loopArray[i][0] >= 0)
      {      

        playSound(loopArray[i][0], loopArray[i][1]);

        varsArray[2] = curTime + loopArray[i+1][2];     // set nextTime
        varsArray[1]++;                           //i++
      } //
      else 
      {
        i = 0;                               // 
        varsArray[1] = 0;                         // reset i

        playSound(loopArray[i][0], loopArray[i][1]);
        varsArray[2] = curTime + loopArray[i+1][2];
        varsArray[1]++;
      }
    }
  } else
  {
    //vars0[4] = millis();
  }
}


void initializeSounds()
{
  sn = new AudioSample[10];
  se = new AudioSample[10];
  sw = new AudioSample[10];
  ss = new AudioSample[10];

  //  sn[0] = minim.loadSample("n/0.wav", 128);
  //  sn[1] = minim.loadSample("n/1.mp3", 128);
  //  sn[2] = minim.loadSample("n/2.aif", 128);
  //  sn[3] = minim.loadSample("n/3.wav", 128);
  //  sn[4] = minim.loadSample("n/4.mp3", 128);
  //  sn[5] = minim.loadSample("n/6.wav", 128);
  //  sn[6] = minim.loadSample("n/7.mp3", 128);
  //  sn[7] = minim.loadSample("n/8.wav", 128);
  //  sn[8] = minim.loadSample("n/9.mp3", 128);
  //  sn[9] = minim.loadSample("n/10.mp3", 128);

  se[0] = minim.loadSample("e/Perc (01).mp3", 128);
  se[1] = minim.loadSample("e/Perc (02).mp3", 128);
  se[2] = minim.loadSample("e/Perc (03).mp3", 128);
  se[3] = minim.loadSample("e/Perc (04).mp3", 128);
  se[4] = minim.loadSample("e/Perc (05).mp3", 128);
  se[5] = minim.loadSample("e/Perc (06).mp3", 128);
  se[6] = minim.loadSample("e/Perc (07).mp3", 128);
  se[7] = minim.loadSample("e/Perc (08).mp3", 128);
  se[8] = minim.loadSample("e/Perc (09).mp3", 128);
  se[9] = minim.loadSample("e/Perc (10).mp3", 128);
  
  
  //se[1] = minim.loadSample("e/f4.mp3", 128);
  //se[2] = minim.loadSample("e/e4.aif", 128);
  //se[3] = minim.loadSample("e/snare.wav", 128);
  //se[4] = minim.loadSample("e/bass.mp3", 128);
  //se[5] = minim.loadSample("e/d4.wav", 128);
  //se[6] = minim.loadSample("e/c4.mp3", 128);
  //se[7] = minim.loadSample("e/b3.wav", 128);
  //se[8] = minim.loadSample("e/a3.mp3", 128);
  //se[9] = minim.loadSample("e/g3.mp3", 128);

  sw[0] = minim.loadSample("w/Perc (01).mp3", 128);
  sw[1] = minim.loadSample("w/f4.wav", 128);
  sw[2] = minim.loadSample("w/e4.wav", 128);
  sw[3] = minim.loadSample("w/Clap (05).mp3", 128);
  sw[4] = minim.loadSample("w/Kick (01).mp3", 128);
  sw[5] = minim.loadSample("w/d4.wav", 128);
  sw[6] = minim.loadSample("w/c4.wav", 128);
  sw[7] = minim.loadSample("w/b3.wav", 128);
  sw[8] = minim.loadSample("w/a3.wav", 128);
  sw[9] = minim.loadSample("w/g3.wav", 128);

  ss[0] = minim.loadSample("s/c6.wav", 128);
  ss[1] = minim.loadSample("s/b5.wav", 128);
  ss[2] = minim.loadSample("s/a5.wav", 128);
  ss[3] = minim.loadSample("s/g5.wav", 128);
  ss[4] = minim.loadSample("s/f5.wav", 128);
  ss[5] = minim.loadSample("s/e5.wav", 128);
  ss[6] = minim.loadSample("s/d5.wav", 128);
  ss[7] = minim.loadSample("s/c5.wav", 128);
  ss[8] = minim.loadSample("s/b4.wav", 128);
  ss[9] = minim.loadSample("s/a4.wav", 128);
}










// -----------------------loop commands


boolean isEmpty(int loopIndex)
{
  int varsArray[] = chooseVars(loopIndex);

  if (varsArray[3] == 0)
    return true;
  else
    return false;
} //


void playLoop(int index)
{
  println("playLoop");

  int varsArray[] = chooseVars(index);

  varsArray[0] = 1;
}


boolean isPlaying(int index)
{
  int varsArray[] = chooseVars(index);
  {
    if (varsArray[0] == 1)
      return true;
    else 
    return false;
  }
}


void stopLoop(int index)
{
  println("STOPPEDD!!!"); 


  int varsArray[] = chooseVars(index);
  varsArray[0] = 0;
}

void printRecordings()
{
  for (int i = 0; i<= vars0[3]; i++)
  {
    println("Index : " + i + "    Sound : " + loop0[0][0] + "    Time : " + loop0[i][2]);
  }
}

int[][] chooseLoop(int loopIndex)
{
  if (loopIndex == 0)
  {
    return loop0;
  } //
  else if (loopIndex == 1)
  {
    return loop1;
  }// 
  else if (loopIndex == 2)
  {
    return loop2;
  }//
  else if (loopIndex == 3)
  {
    return loop3;
  }//
  else if (loopIndex == 4)
  {
    return loop4;
  } else
  {
    println("ERROR AT chooseLoop");
    return null;
  }
}

int[] chooseVars(int loopIndex)
{
  if (loopIndex == 0)
  {
    return vars0;
  } //
  else if (loopIndex == 1)
  {
    return vars1;
  }// 
  else if (loopIndex == 2)
  {
    return vars2;
  }//
  else if (loopIndex == 3)
  {
    return vars3;
  }//
  else if (loopIndex == 4)
  {
    return vars4;
  } else
  {
    println("ERROR AT chooseVars");
    {
      return null;
    }
  }
}

void emptyLoop(int index)
{
  int varsArray[] = chooseVars(index);
  //  int[][] loopArray = chooseLoop(loopIndex);

  varsArray[0] = 0;  // Stop Playing
  varsArray[3] = 0;  // set numRec = 0;
}