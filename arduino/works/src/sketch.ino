#include <OneWire.h>
#include <DallasTemperature.h>

#define TEMP_PIN 2
OneWire oneWire(TEMP_PIN);
DallasTemperature sensors(&oneWire);

#define RELAY_PIN 5
#define INTERRUPT_PIN 1 // corresponds to pin 3
volatile int counter = 0;  // flow counter
unsigned long last_temp_ping = 0;  // last time temperature was checked
unsigned long temp_interval = 6000; // check temperature 1/minute
unsigned long startTime = 0;
float last = 0;
float lastTime;
int lastCount;
String incomingString;
int allowTics = 0;
int sameFor = 0;  // initialize same count
unsigned long zeroStart = 0; // for zero timeout
int maxZero = 20000;  // timeout before pour
int maxSame = 20;  // count threshold for stagnant flow
unsigned long maxMillis = 50000;  // max pour time
String reason = "unknown";  // default 'reason' for break
String stopString = "stop";

void setup() {
    pinMode(RELAY_PIN, OUTPUT);
    attachInterrupt(INTERRUPT_PIN, blink, RISING);
    Serial.begin(9600);
    sensors.begin();
}

void loop() {
    if (Serial.available() > 0) {
      incomingString = Serial.readStringUntil('\n');
      if(incomingString != stopString) {
        allowTics = incomingString.toInt();
        Serial.print("start-flow-amount: ");
        Serial.println(allowTics);
        lastCount = 0;
        counter = 0;
        sameFor = 0;
        zeroStart = 0;
        startTime = millis();
        digitalWrite(RELAY_PIN, HIGH);  // open valve
        
        while((millis() - startTime < maxMillis) && (counter <= allowTics)) {
          if(Serial.available() > 0) {
            if(Serial.readStringUntil('\n') == stopString) {  // for calibration or cancelation
              reason = "stopped";
              break;
            }
          }
          
          printFlowStatus(counter, millis() - startTime);
          
          if (lastCount < 20) {
            if(zeroStart == 0) {
              zeroStart = millis();
            } else if (millis() - zeroStart > maxZero) {
              reason = "zero";
              break;   
            }
          } else if (lastCount >= 20 && lastCount == counter) {
            sameFor++;
            // flow started, became stagnant
            if(sameFor > maxSame && lastCount > 20) {
              reason = "same";
              sameFor = 0;
              break;
            }
          } else {
            sameFor = 0;
          }
          lastCount = counter;
          delay(100);
        }
        
        digitalWrite(RELAY_PIN, LOW); // close valve
        
        if (counter >= allowTics) {
          reason = "reached";
        }
        
        printFlowStatus(counter, millis() - startTime);
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
      }
    } else {
      delay(100);
    }
}

void printFlowStatus(int c, int t) {
  Serial.print("update-flow: ");
  Serial.print(c);
  Serial.print(" ");
  Serial.println(millis() - startTime);
}

void blink() {
    counter++;
}
