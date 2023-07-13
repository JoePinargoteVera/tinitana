// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart' as mqtt;
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'dart:math';
import 'dart:convert';

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late mqtt.MqttServerClient mqttClient;
  List<String> receivedMessages = [];

  @override
  void initState() {
    super.initState();
    final Random random = Random();
    mqttClient = mqtt.MqttServerClient(
        'broker.emqx.io', 'dart-mqtt-${random.nextInt(1000)}')
      ..port = 1883 // Especificar el puerto aquí
      ..secure = false; 
    mqttClient.logging(on: true);
  }

  Future<void> connectSubscribeAndSave() async {
    try {
      final MqttConnectMessage connectMessage = MqttConnectMessage()
          .withClientIdentifier('dart-mqtt-${Random().nextInt(1000)}')
          .keepAliveFor(60)
          .withWillTopic('willtopic')
          .withWillMessage('My Will message')
          .startClean()
          .authenticateAs('admin', 'password');

      mqttClient.connectionMessage = connectMessage;

      await mqttClient.connect();
      mqttClient.subscribe('uleam/fcvt/#', MqttQos.atLeastOnce);
      mqttClient.updates!
          .listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        final mqttMessage = messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
            mqttMessage.payload.message);
        final decodedPayload = jsonDecode(payload) as Map<String, dynamic>;
        final messageText = jsonEncode(decodedPayload);
        setState(() {
          receivedMessages.add(messageText);
        });

        final db = mongo.Db(
            'mongodb://192.168.1.42:27017');
        db.open().then((_) {
          final collection = db.collection('temperatura');
          collection.save(decodedPayload);
          db.close();
        });
      });
    } catch (e) {
      print('Error al conectar y suscribirse al broker MQTT: $e');
    }
  }

  Future<void> publishDataToMQTT() async {
    try {
      final db = mongo.Db('mongodb://192.168.1.42:27017');
      await db.open();
      final collection = db.collection('temperatura');
      final List<Map<String, dynamic>> data = await collection.find().toList();
      await db.close();

      // final mqttClient = mqtt.MqttServerClient(
      //     '192.168.1.20', 'dart-mqtt-${Random().nextInt(1000)}');
      // mqttClient.logging(on: true);
      final MqttConnectMessage connectMessage = MqttConnectMessage()
          .withClientIdentifier('dart-mqtt-${Random().nextInt(1000)}')
          .keepAliveFor(60)
          .withWillTopic('willtopic')
          .withWillMessage('My Will message')
          .startClean()
          .authenticateAs('admin', 'password');

      mqttClient.connectionMessage = connectMessage;

      await mqttClient.connect();
      for (final item in data) {
        const topic = 'uleam/fcvt/temperatura';
        final payload = MqttClientPayloadBuilder();
        payload.addString(jsonEncode(item));
        mqttClient.publishMessage(topic, MqttQos.exactlyOnce, payload.payload!);
      }
    } catch (e) {
      print('Error al publicar los datos en el broker MQTT: $e');
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Ejemplo MQTT y MongoDB'),
    ),
    body: SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: connectSubscribeAndSave,
              child: const Text('Conectar y Suscribirse al Broker'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: publishDataToMQTT,
              child: const Text('Publicar datos en MQTT'),
            ),
            const SizedBox(height: 20),
            const Text('Mensajes recibidos:'),
            ListView.builder(
              shrinkWrap: true,
              itemCount: receivedMessages.length,
              itemBuilder: (context, index) {
                final message = receivedMessages[index];
                final messageText =
                    message.toString(); // Convertir a String si es necesario
                return Center(
                  child: ListTile(
                    title: Text(messageText),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}


}
