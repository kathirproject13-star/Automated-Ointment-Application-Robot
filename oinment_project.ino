#include <Servo.h>

#define IN1 4   // L298N Motor Driver Input 1
#define IN2 5   // L298N Motor Driver Input 2
#define IN3 6   // L298N Motor Driver Input 3
#define IN4 7   // L298N Motor Driver Input 4
#define PUMP 8  // Relay to control Pump
#define SERVO_PIN 9

Servo myServo;

void setup() {
  Serial.begin(9600);

  // Motor pins
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);

  // Pump relay
  pinMode(PUMP, OUTPUT);
  digitalWrite(PUMP, HIGH);

  // Servo
  myServo.attach(SERVO_PIN);
  myServo.write(50);  // Initial position
}

void loop() {
  if (Serial.available() > 0) {
    char cmd = Serial.read();

    switch (cmd) {
      case 'A': area1(); break;
      case 'B': area2(); break;
      case 'C': area3(); break;
      case 'D': area4(); break;
      case 'E': area5(); break;
      case 'F': area6(); break;
      default: stopMotors(); break;
    }
  }
}

void moveBackward(unsigned long t) {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
  delay(t);
  stopMotors();
}

void moveForward(unsigned long t) {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
  delay(t);
  stopMotors();
}

void turnLeft(unsigned long t) {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
  delay(t);
  stopMotors();
}

void turnRight(unsigned long t) {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
  delay(t);
  stopMotors();
}

void stopMotors() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
}

void sprayRoutine() {
  digitalWrite(PUMP, LOW);
  delay(1000);
  digitalWrite(PUMP, HIGH);
  delay(500);

  myServo.write(130);
  delay(800);
  myServo.write(50);
  delay(800);
  myServo.write(130);
  delay(800);
  myServo.write(50);
  delay(800);
}

// Area 1: Spray only
void area1() {
  sprayRoutine();
}

// Area 2: L - F - SR - B - R
void area2() {
  turnLeft(1500);
  delay(500);
  moveForward(1000);
  sprayRoutine();
  moveBackward(1000);
  delay(500);
  turnRight(1500);
}

// Area 3: F - SR - B
void area3() {
  moveForward(1000);
  sprayRoutine();
  moveBackward(1000);
}

// Area 4: F - L - F - SR - B - R - B
void area4() {
  moveForward(1000);
  delay(500);
  turnLeft(1500);
  delay(500);
  moveForward(1000);
  sprayRoutine();
  moveBackward(1000);
  delay(500);
  turnRight(1500);
  delay(500);
  moveBackward(1000);
}

// Area 5: F - F - SR - B - B
void area5() {
  moveForward(1000);
  delay(500);
  moveForward(1000);
  sprayRoutine();
  moveBackward(1000);
  delay(500);
  moveBackward(1000);
}

// Area 6: F - F - L - F - SR - B - R - B - B
void area6() {
  moveForward(1000);
  delay(500);
  moveForward(1000);
  delay(500);
  turnLeft(1500);
  delay(500);
  moveForward(1000);
  sprayRoutine();
  moveBackward(1000);
  delay(500);
  turnRight(1500);
  delay(500);
  moveBackward(1000);
  delay(500);
  moveBackward(1000);
}