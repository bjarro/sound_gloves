
//-------------------------------------------------------------------------------------------
int numLDR = 0;
int LDR[12][6]; // Analog, P_Threshold, prevPressed? , Out1/LED , Release R_Threhold, prevReleased?

int numTilt = 0;
int tilt[2][7];  // B_Analog, A_Analog, prevX, Out1, Out2, Out3, Out4

boolean prntVals = 0;
boolean prntThreshs = 0;
boolean threshLEDMode = 0;
unsigned long timers[12];

//-----------------------------------------------------------------------------------------
void setup() {
  // put your setup code here, to run once:
  Serial.begin(57600);
  setPins(0, 13, OUTPUT);

  //  setLDRtoLED(0, 3, 20, 0, 0);
  //  setLDRtoLED(1, 11, 200, 0, 0);
  //  setLDRtoLED(2, 9, 50, 0, 0);
  //  setLDRtoLED(3, 7, 200, 0, 0);
  //  setLDRtoLED(4, 5, 60, 0, 0);
  //  setLDRtoLED(5, 13, 50, 0, 0);



  setLDRtoLED(0, 2, 0, 0, 0); //0
  setLDRtoLED(5, 3, 0, 0, 0); //1
  setLDRtoLED(1, 4, 0, 0, 0); //2
  setLDRtoLED(4, 5, 0, 0, 0); //3
  setLDRtoLED(3, 6, 0, 0, 0); //4

  setLDRtoLED(8, 7, 0, 0, 0); //5
  setLDRtoLED(9, 8, 0, 0, 0); //6
  setLDRtoLED(10, 9, 0, 0, 0); //7
  setLDRtoLED(11, 11, 0, 0, 0); //8
  setLDRtoLED(12, 12, 0, 0, 0); //9


  setLDRtoLED(2, 13, 0, 0, 0); //10


  setTilt(37, 35 , 33, 31);



  int temp = analogRead(5);
  //  Serial.println();
  //  Serial.print(temp);
  calibrate(3000, 500);
}

//-------------------------------------------------------------------------------------------
void loop() {
  // put your main code here, to run repeatedly:
  checkLDR(0, 0);
  checkLDR(1, 0);
  checkLDR(2, 0);
  checkLDR(3, 0);
  checkLDR(4, 0);


  checkLDR(5, 0);
  checkLDR(6, 0);
  checkLDR(7, 0);
  checkLDR(8, 0);
  checkLDR(9, 0);


  checkLDR(10, 1);

  checkTilt(0);

  if (prntThreshs)
    printThreshs();

  if (prntVals)
    Serial.println();

}


//----------------------------Mini Methods--------------------------------------------

//-------------------------------------------------------------------------------------------
//inside loop()
void switchLEDs(int first, int last, int swtch)
{
  for (int i = first; i <= last; i++)
  {
    digitalWrite(i, swtch);

  }

}
//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
void printThreshs()
{
  for (int i = 0; i < numLDR; i++)
  {
    char buf[50];
    int n = sprintf(buf, "Thresh%d : %d   |   ", LDR[i][0], LDR[i][1]);
    for (int i = 0; i <= n; i++)
      Serial.print(buf[i]);

  }
  // Serial.println();
}

//-------------------------------------------------------------------------------------------


//-------------------------------Check Val ----------------------------------------
//inside loop()
void checkLDR(int index, boolean releas)
{
  int LED = LDR[index][3];
  int analog = LDR[index][0];
  int val = analogRead(analog);

  if (val <= LDR[index][1])
  {
    // LED

    if (threshLEDMode && LED >= 0)
      digitalWrite(LED, HIGH);
    // LED END

    // WRITE
    if (LDR[index][2] == 0 && LDR[index][5] == 1)
    {
      Serial.write('p');
      Serial.write(index);
      if (!threshLEDMode)
      {
        digitalWrite(LED, HIGH);
        timers[index] = millis();
      }

    }
    // WRITE END

    LDR[index][2] = 1;
    LDR[index][5] = 0;
  }
  else
  {
    // LED
    if (threshLEDMode && LED >= 0)
      digitalWrite(LED, LOW);
    // LED END

    // WRITE
    if (releas)
      if ( LDR[index][2] == 1 && LDR[index][5] == 0)
      {

        Serial.write('r');
        Serial.write(index);
        if (!threshLEDMode)
          digitalWrite(LED, HIGH);
      }
    // WRITE END
    LDR[index][2] = 0;

    if (val >= LDR[index][4])
    {
      LDR[index][5] = 1;
    }
  }

  if (prntVals)
  {
    char buf[50];
    int n = sprintf(buf, "analog%d : %d   |   ", analog, val);
    for (int i = 0; i <= n; i++)
      Serial.print(buf[i]);
  }

  if (!threshLEDMode)
  {
    if (millis() - timers[index] >= 100)
    {
      digitalWrite(LED, LOW);
    }
  }

}
//----------------------- Check Val End --------------------------------

//----------------------- Check Tilt --------------------------------

void checkTilt(int index)
{
  int x1 = digitalRead(tilt[index][0]); // tilt[0][0]
  int x2 = digitalRead(tilt[index][1]); // tilt[0][1]
  int prevx = tilt[index][2];
  int x = x2 * 2 + x1;

  //  Serial.print("x1 : ");
  //  Serial.print(x1);
  //  Serial.print("   |   ");
  //  Serial.print("x2 : ");
  //  Serial.println(x2);
  //  Serial.println

  //  Serial.println("--------------");
  //  Serial.print("x : ");
  //    Serial.println(x);
  //  Serial.print("prevx : ");
  //  Serial.println(prevx);

  //  for (int i = 14; i <= 18; i++)
  //  {
  //    digitalWrite(i, LOW);
  //  }

  if (x == 0 && prevx != 0)
  {
    // UP
    Serial.write('n');
    Serial.write(index);

  }
  else if (x == 1 && prevx != 1)
  {
    //RIGHT
    Serial.write('e');
    Serial.write(index);
  }
  else if (x == 2 && prevx != 2)
  {
    //LEFT
    Serial.write('w');
    Serial.write(index);
  }
  else if (x == 3 && prevx != 3)
  {
    //DOWN
    Serial.write('s');
    Serial.write(index);
  }
  else
  {
    // CENTER
  }

  tilt[index][2] = x;

}

//----------------------- Check Tilt End --------------------------------

//------------------------inside setup()----------------------------------------------------


//-------------------------------------------------------------------------------------------
void setPins(int first, int last, int setting)
{
  for (int i = first; i <= last; i++)
  {
    pinMode(i, setting);
  }
}
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

void setLDRtoLED(int analog, int LED, int threshold, int flatCal, float scaleCal)
{
  LDR[numLDR][0] = analog;
  LDR[numLDR][1] = threshold;

  if (LED >= 0)
  {
    LDR[numLDR][3] = LED;

  }
  numLDR++;
}

//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
void setTilt(int B, int A, int gnd, int vcc)
{

  tilt[numTilt][0] = B;
  tilt[numTilt][1] = A;
  tilt[numTilt][2] = -1;

  pinMode(B, INPUT);   //B
  pinMode(A, INPUT);  //A
  pinMode(gnd, OUTPUT); //gnd
  pinMode(vcc, OUTPUT); //Vcc
  delay(100);
  digitalWrite(gnd, LOW); //gnd
  digitalWrite(vcc, HIGH); //Vcc

  numTilt++;
}

//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

void calibrate(int duration, int interval) //in milliseconds
{
  for (int i = 0; i < 4; i++) //Warning lights
  {
    switchLEDs(3, 13, LOW);
    delay(750);
    switchLEDs(3, 13, HIGH);
    delay(750);
  }

  int n = duration / interval;
  int values[numLDR + 1];

  for (int i = 0; i < numLDR + 1; i++)
  {
    values[i] = 0;
  }

  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < numLDR; j++)
    {
      if (j == 0)
      {
        //        Serial.println();
        //        Serial.print(j);
        //        Serial.print(" : ");
        //        Serial.print(values[j]);
        //        Serial.print(" : ");
        //        Serial.println(analogRead(LDR[j][0]));
      }
      values[j] += analogRead(LDR[j][0]);

    }
    delay(interval);
  }

  for (int j = 0; j < numLDR; j++)
  {
    //    Serial.print(j);
    //    Serial.print(" : ");
    //    Serial.print(values[j]);
    values[j] /= n;
    //    Serial.print(" : ");
    //    Serial.print(values[j]);
    LDR[j][1] = values[j] * 0.3;
    LDR[j][4] = values[j] * 0.4;
    //    Serial.print(" : ");
    //    Serial.println(LDR[j][1]);
    //    Serial.print(" : ");
    //    Serial.println(LDR[j][4]);
    
    if(j == 10)
    {
      LDR[j][1] = values[j] * 0.2;
    }
    
    
  }
  switchLEDs(0, 13, LOW);
}

//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

