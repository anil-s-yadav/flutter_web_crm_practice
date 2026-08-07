import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final res = await http.get(Uri.parse('http://localhost:5000/api/clients'));
  final data = jsonDecode(res.body);
  final List clients = data is List ? data : data['data'];
  
  final converted = clients.firstWhere((c) => c['status'] == 'converted', orElse: () => null);
  if (converted == null) {
    print('No converted client found');
    return;
  }
  
  print('Updating converted client: ${converted['id']}');
  
  // Try to update it
  converted['name'] = '${converted['name']} Updated';
  
  final updateRes = await http.put(
    Uri.parse('http://localhost:5000/api/clients/${converted['id']}'),
    headers: {'Content-Type': 'application/json', 'x-api-key': 'crm-secure-key-2026'},
    body: jsonEncode(converted),
  );
  
  print('Update response: ${updateRes.statusCode} - ${updateRes.body}');
}
