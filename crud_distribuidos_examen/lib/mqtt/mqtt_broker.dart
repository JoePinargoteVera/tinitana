// import 'dart:math';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_browser_client.dart';
// import 'package:intl/intl.dart';
// import 'dart:convert';

// final Random random = Random();
// final String mClientId = 'dart-mqtt-${random.nextInt(1000)}';
// final String mBroker = 'server-manta';
// final int mPort = 1883;
// final String mTopic = 'topic/temperatura/Pinargote-joe';
// final String mUsername = 'mqtt-test';
// final String mPassword = 'mqtt-test';

// MqttClient connectMqtt() {
//   void onConnect(MqttClient client) {
//     print('Connected to MQTT Broker!');
//   }

//   void onConnectionFailed(MqttClient client, Object exception, StackTrace stackTrace) {
//     print('Failed to connect, return code: $exception');
//   }

//   final MqttClient client = MqttBrowserClient(mBroker, mClientId);
//   client.logging(on: true);
//   client.onConnected = onConnect;
//   client.onDisconnected = onConnect;
//   client.onConnectionFailed = onConnectionFailed;
//   client.keepAlivePeriod = 20;
//   client.autoReconnect = true;
//   client.secure = false;
//   client.setProtocolV311();

//   final MqttConnectMessage connectMessage = MqttConnectMessage()
//       .withClientIdentifier(mClientId)
//       .startClean() // Clean session
//       .keepAliveFor(20) // Keep alive interval
//       .withWillTopic('willtopic')
//       .withWillMessage('My Will message')
//       .withWillRetain()
//       .withWillQos(MqttQos.atLeastOnce)
//       .authenticateAs(mUsername, mPassword);

//   client.connectionMessage = connectMessage;

//   client.connect();

//   return client;
// }

// void main() async {
//   final MqttClient client = connectMqtt();

//   await client.connect();

//   final double temperatura = 25.5;
//   final double humedad = 60.0;
//   final double latitud = 12.3456;
//   final double longitud = -78.9101;
//   final String fechaHora = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());

//   final Map<String, dynamic> data = {
//     'temperatura': temperatura,
//     'humedad': humedad,
//     'latitud': latitud,
//     'longitud': longitud,
//     'fecha_hora': fechaHora,
//   };
//   final String payload = jsonEncode(data);

//   client.publishMessage(mTopic, MqttQos.exactlyOnce, payload);

//   client.disconnect();
// }
