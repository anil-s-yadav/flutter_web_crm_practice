import 'package:flutter/material.dart';
import 'package:practice_app/core/mock_data_generator.dart';

class ClientDetailScreen extends StatelessWidget {
  final String clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    int idValue = int.tryParse(clientId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final client = MockDataGenerator.generateClient(idValue);

    return Scaffold(
      appBar: AppBar(title: Text(client.fullName)),
      body: Center(
        child: Text('Client Detail for ${client.fullName}\nPhone: ${client.phone}\nStatus: ${client.status.name}'),
      ),
    );
  }
}
