#include <OneWire.h>
#include <DallasTemperature.h>

#define ONE_WIRE_BUS 2
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

int relay_pin = 5;
volatile int counter = 0;
unsigned long last_temp_ping = 0;
unsigned long temp_interval = 60000; // one minute
unsigned long startTime = 0;
float last = 0;
float lastTime;
float lastCount;
String incomingString;
int allowTics = 0;
int sameFor = 0;  // initialize same count
unsigned long zeroStart = -1; // for zero timeout
int maxZero = 20000;  // timeout before pour
int maxSame = 20;  // count threshold for stagnant flow
unsigned long maxMillis = 50000;  // max pour time
String reason = "unknown";  // default 'reason' for break

void setup() {
    pinMode(relay_pin, OUTPUT);
    digitalWrite(relay_pin, LOW);
    attachInterrupt(1, blink, RISING);
    Serial.begin(9600);
    sensors.begin();
}

void loop() {
    if (Serial.available() > 0) {
      incomingString = Serial.readStringUntil('\n');
      allowTics = incomingString.toInt();
      Serial.print("start-flow-amount: ");
      Serial.println(allowTics);
      startTime = millis();
      lastTime = startTime;
      lastCount = 0;
      digitalWrite(relay_pin, HIGH);
      counter = 0;
      sameFor = 0;
      while((millis() - startTime < maxMillis) && (counter <= allowTics)) {
        if(Serial.available() > 0) {
          if(Serial.read() == '1') {  // for calibration or cancelation
            reason = "stopped";
            break;
          }
        }
        Serial.print("update-flow: ");
        Serial.print(counter);
        Serial.print(" ");
        Serial.println(millis()-startTime);
        
        if (lastCount == counter) {
          sameFor++;
          if(sameFor > maxSame && lastCount > 10) {
            reason = "same";
            break;
          }
          // count is low for a time, start zero timeout count
          if (sameFor > 10 && lastCount < 10 && zeroStart > millis()) {
            zeroStart = millis();
          }
          // wait for pour
          if (zeroStart + maxZero < millis() && lastCount < 10) {
            reason = "zero";
            break;
          }
        }

        lastCount = counter;
        //float thisTime = millis();
        //float thisCount = counter;
        //float d = (thisCount - lastCount) / (thisTime - lastTime) * 1000;
        //lastCount = thisCount;
        //lastTime = thisTime;
        //Serial.println(d);
        delay(100);
      }
      if (counter > allowTics) {
        reason = "reached";
      }
      digitalWrite(relay_pin, LOW);
      Serial.print("update-flow: ");
      Serial.print(counter);
      Serial.print(" ");
      Serial.println(millis() - startTime);
      Serial.print("end-flow: ");
      Serial.println(reason);
    } else if (last_temp_ping + temp_interval < millis()) {
      last_temp_ping = millis();
      Serial.print("update-temps: ");
      sensors.requestTemperatures();
      Serial.print(sensors.getTempCByIndex(0));
      Serial.print(' ');
      Serial.print(sensors.getTempCByIndex(1));
      Serial.print(' ');
      Serial.println(sensors.getTempCByIndex(2));
    } else {
      delay(100);
    }
}

void blink() {
    counter++;
}
