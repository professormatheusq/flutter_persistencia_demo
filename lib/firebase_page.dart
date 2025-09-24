import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePage extends StatelessWidget {
  const FirebasePage({super.key});

  FirebaseFirestore? get db {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      return null;
    }
  }

  void _addUser(BuildContext context) async {
    if (db == null) {
      _showError(context, 'Firebase não está configurado corretamente');
      return;
    }

    try {
      await db!.collection('usuarios').add({
        'nome': 'João',
        'email': 'joao@gmail.com',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      _showMessage(context, 'Usuário adicionado com sucesso!');
    } catch (e) {
      _showError(context, 'Erro ao adicionar usuário: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getUsers(BuildContext context) async {
    if (db == null) {
      _showError(context, 'Firebase não está configurado corretamente');
      return [];
    }

    try {
      final snapshot = await db!.collection('usuarios').get();
      return snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();
    } catch (e) {
      _showError(context, 'Erro ao listar usuários: $e');
      return [];
    }
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Firestore'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informação sobre Firebase
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Firebase Firestore',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Banco de dados NoSQL em tempo real na nuvem. Esta demonstração usa configurações mock para fins educativos.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () => _addUser(context),
              icon: Icon(Icons.person_add),
              label: Text('Adicionar Usuário'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () async {
                final users = await _getUsers(context);
                if (users.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Usuários'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: users
                              .map(
                                (user) => ListTile(
                                  leading: Icon(Icons.person),
                                  title: Text(
                                    user['nome'] ?? 'Nome não informado',
                                  ),
                                  subtitle: Text(
                                    user['email'] ?? 'Email não informado',
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Fechar'),
                        ),
                      ],
                    ),
                  );
                }
              },
              icon: Icon(Icons.list),
              label: Text('Listar Usuários'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            SizedBox(height: 24),

            // Informações adicionais
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sobre o Firebase Firestore:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• Banco NoSQL na nuvem\n'
                      '• Sincronização em tempo real\n'
                      '• Escalabilidade automática\n'
                      '• Backup automático\n'
                      '• Segurança integrada\n'
                      '• Funciona offline',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
