import 'package:flutter/material.dart';
import 'shared_pref_page.dart';
import 'secure_storage_page.dart';
import 'sqlite_page.dart';
import 'firebase_page.dart';
import 'supabase_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar Firebase para persistência em nuvem
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase inicializado com sucesso!');
  } catch (e) {
    print('Erro ao inicializar Firebase: $e');
    // Continue mesmo se o Firebase falhar - outras funcionalidades ainda funcionarão
  }

  try {
    // Inicializar Supabase (alternativa open-source ao Firebase)
    await Supabase.initialize(
      url: 'https://xfecnhxjchfdsbfeaatg.supabase.co',
      anonKey:
          '<prefer publishable key instead of anon key for mobile and desktop apps>',
    );
    print('Supabase inicializado com sucesso!');
  } catch (e) {
    print('Erro ao inicializar Supabase: $e');
    // Continue mesmo se o Supabase falhar - outras funcionalidades ainda funcionarão
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter - Demonstração de Persistência',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Persistência de Dados no Flutter'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho explicativo
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipos de Persistência de Dados',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explore diferentes formas de armazenar dados em aplicações Flutter, desde preferências simples até bancos de dados complexos.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Lista de opções de persistência
            Expanded(
              child: ListView(
                children: [
                  _buildPersistenceCard(
                    context,
                    title: 'SharedPreferences',
                    subtitle: 'Armazenamento de configurações simples',
                    description:
                        'Para preferências do usuário, configurações básicas e dados primitivos.',
                    icon: Icons.settings,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SharedPrefPage()),
                    ),
                  ),
                  _buildPersistenceCard(
                    context,
                    title: 'Secure Storage',
                    subtitle: 'Armazenamento seguro e criptografado',
                    description:
                        'Para tokens, senhas e dados sensíveis que precisam de criptografia.',
                    icon: Icons.security,
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SecureStoragePage()),
                    ),
                  ),
                  _buildPersistenceCard(
                    context,
                    title: 'SQLite',
                    subtitle: 'Banco de dados local relacional',
                    description:
                        'Para dados estruturados complexos que funcionam offline.',
                    icon: Icons.storage,
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SQLitePage()),
                    ),
                  ),
                  _buildPersistenceCard(
                    context,
                    title: 'Firebase Firestore',
                    subtitle: 'Banco NoSQL em tempo real na nuvem',
                    description:
                        'Para sincronização em tempo real e backup automático na nuvem.',
                    icon: Icons.cloud,
                    color: Colors.red,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FirebasePage()),
                    ),
                  ),
                  _buildPersistenceCard(
                    context,
                    title: 'Supabase',
                    subtitle: 'Alternativa open-source ao Firebase',
                    description:
                        'Banco PostgreSQL com recursos em tempo real e APIs REST.',
                    icon: Icons.code,
                    color: Colors.teal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SupabasePage()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersistenceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
