import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePage extends StatefulWidget {
  const SupabasePage({super.key});

  @override
  SupabasePageState createState() => SupabasePageState();
}

class SupabasePageState extends State<SupabasePage> {
  List<Map<String, dynamic>> produtos = [];

  Future<void> _fetch() async {
    final response = await Supabase.instance.client
        .from('produtos')
        .select()
        .limit(5);
    setState(() {
      produtos = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: _fetch, child: Text('Buscar Produtos')),
        ...produtos.map((p) => ListTile(title: Text(p['nome'].toString()))),
      ],
    );
  }
}
