// The ESP32 can act as a client, connect to your local server, and keep the connection open to receive data sent from the server.

#include <WiFi.h>
#include <LiquidCrystal_I2C.h>

const char* ssid = "Your_SSID";         // Your Wi-Fi SSID
const char* password = "Your_PASSWORD"; // Your Wi-Fi password
const char* serverIP = "192.168.1.100"; // IP address of the server (replace with your local server's IP)
const int serverPort = 9191;            // The port your server is listening on

WiFiClient client;
LiquidCrystal_I2C lcd(0x20, 16, 2);     // LCD address and size (adjust the address if needed)

void setup() {
  // Initialize serial communication and the LCD display
  Serial.begin(9600);
  lcd.begin(16, 2);
  lcd.backlight();
  
  // Connect to Wi-Fi
  connectToWiFi();
  
  // Attempt to connect to the server
  if (connectToServer()) {
    lcd.setCursor(0, 0);
    lcd.print("Connected to srv");
    Serial.println("Connected to server");
  } else {
    lcd.setCursor(0, 0);
    lcd.print("Conn failed");
    Serial.println("Connection to server failed");
  }
}

void loop() {
  if (client.connected()) {
    // Check if the server has sent any data
    if (client.available()) {
      String data = client.readStringUntil('\n');  // Read incoming data until newline
      Serial.println("Data from server: " + data);
      
      // Display the received data on the LCD
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("Data: ");
      lcd.setCursor(0, 1);
      lcd.print(data);
    }
  } else {
    // Reconnect if the connection is lost
    Serial.println("Disconnected, reconnecting...");
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Reconnecting...");
    
    if (connectToServer()) {
      Serial.println("Reconnected to server");
      lcd.setCursor(0, 0);
      lcd.print("Reconnected to srv");
    } else {
      Serial.println("Reconnection failed");
      lcd.setCursor(0, 0);
      lcd.print("Conn failed");
    }
  }

  delay(1000); // Adjust delay based on your use case
}

void connectToWiFi() {
  Serial.println("Connecting to Wi-Fi...");
  lcd.setCursor(0, 0);
  lcd.print("Connecting Wi-Fi");

  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("Wi-Fi connected");
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Wi-Fi connected");
}

bool connectToServer() {
  Serial.println("Connecting to server...");
  
  // Attempt to connect to the server
  if (client.connect(serverIP, serverPort)) {
    Serial.println("Connected to server");
    return true;
  } else {
    Serial.println("Failed to connect to server");
    return false;
  }
}
