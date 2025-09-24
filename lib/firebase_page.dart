import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePage extends StatelessWidget {
  final db = FirebaseFirestore.instance;

  FirebasePage({super.key});

  void _addUser() async {
    await db.collection('usuarios').add({
      'nome': 'João',
      'email': 'joao@gmail.com',
    });
  }

  Future<List<Map<String, dynamic>>> _getUsers() async {
    final snapshot = await db.collection('usuarios').get();
    return snapshot.docs.map((e) => e.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: _addUser, child: Text('Adicionar Usuário')),
        ElevatedButton(
          onPressed: () async {
            final users = await _getUsers();
            showDialog(
              context: context,
              builder: (_) => AlertDialog(content: Text(users.toString())),
            );
          },
          child: Text('Listar Usuários'),
        ),
      ],
    );
  }
}
