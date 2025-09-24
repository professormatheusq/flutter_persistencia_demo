import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStoragePage extends StatefulWidget {
  const SecureStoragePage({super.key});

  @override
  SecureStoragePageState createState() => SecureStoragePageState();
}

class SecureStoragePageState extends State<SecureStoragePage> {
  // Configuração do Secure Storage
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Controladores para diferentes tipos de dados seguros
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();

  // Variáveis para exibir dados carregados
  String _savedUsername = 'Não definido';
  String _savedToken = 'Não definido';
  bool _isPasswordVisible = false;
  List<String> _allKeys = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  /// Carrega todos os dados salvos
  Future<void> _loadAllData() async {
    try {
      final username = await _storage.read(key: 'demo_username');
      final token = await _storage.read(key: 'demo_token');
      final allKeys = await _storage.readAll();

      setState(() {
        _savedUsername = username ?? 'Não definido';
        _savedToken = token ?? 'Não definido';
        _allKeys = allKeys.keys.toList();
      });
    } catch (e) {
      _showSnackBar('Erro ao carregar dados: $e', isError: true);
    }
  }

  /// Salva credenciais de login (username + password)
  Future<void> _saveCredentials() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Preencha usuário e senha', isError: true);
      return;
    }

    try {
      await _storage.write(
        key: 'demo_username',
        value: _usernameController.text,
      );
      await _storage.write(
        key: 'demo_password',
        value: _passwordController.text,
      );

      _usernameController.clear();
      _passwordController.clear();
      _loadAllData();
      _showSnackBar('Credenciais salvas com segurança!');
    } catch (e) {
      _showSnackBar('Erro ao salvar credenciais: $e', isError: true);
    }
  }

  /// Salva token de autenticação
  Future<void> _saveToken() async {
    if (_tokenController.text.isEmpty) {
      _showSnackBar('Digite um token primeiro', isError: true);
      return;
    }

    try {
      await _storage.write(key: 'demo_token', value: _tokenController.text);
      _tokenController.clear();
      _loadAllData();
      _showSnackBar('Token salvo com segurança!');
    } catch (e) {
      _showSnackBar('Erro ao salvar token: $e', isError: true);
    }
  }

  /// Salva chave-valor personalizada
  Future<void> _saveCustomKeyValue() async {
    if (_keyController.text.isEmpty || _valueController.text.isEmpty) {
      _showSnackBar('Preencha a chave e o valor', isError: true);
      return;
    }

    try {
      await _storage.write(
        key: _keyController.text,
        value: _valueController.text,
      );
      _keyController.clear();
      _valueController.clear();
      _loadAllData();
      _showSnackBar('Dados personalizados salvos!');
    } catch (e) {
      _showSnackBar('Erro ao salvar dados: $e', isError: true);
    }
  }

  /// Lê a senha salva
  Future<void> _readPassword() async {
    try {
      final password = await _storage.read(key: 'demo_password');
      if (password != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Senha Salva'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Usuário: $_savedUsername'),
                SizedBox(height: 8),
                Text('Senha: ${_isPasswordVisible ? password : '••••••••'}'),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Dados criptografados!',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                  Navigator.of(context).pop();
                  _readPassword(); // Reabrir com visibilidade alterada
                },
                child: Text(_isPasswordVisible ? 'Ocultar' : 'Mostrar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Fechar'),
              ),
            ],
          ),
        );
      } else {
        _showSnackBar('Nenhuma senha salva encontrada', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erro ao ler senha: $e', isError: true);
    }
  }

  /// Lista todas as chaves salvas
  Future<void> _showAllKeys() async {
    try {
      final allData = await _storage.readAll();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Todas as Chaves Salvas'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: allData.isEmpty
                ? Center(child: Text('Nenhum dado salvo'))
                : ListView.builder(
                    itemCount: allData.length,
                    itemBuilder: (context, index) {
                      final key = allData.keys.elementAt(index);
                      final value = allData[key]!;
                      final isPassword = key.contains('password');

                      return Card(
                        child: ListTile(
                          title: Text(key),
                          subtitle: Text(
                            isPassword ? '••••••••' : value,
                            style: TextStyle(fontFamily: 'monospace'),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _storage.delete(key: key);
                              Navigator.of(context).pop();
                              _loadAllData();
                              _showSnackBar('Chave "$key" removida');
                            },
                          ),
                        ),
                      );
                    },
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
    } catch (e) {
      _showSnackBar('Erro ao listar chaves: $e', isError: true);
    }
  }

  /// Remove todos os dados
  Future<void> _clearAll() async {
    try {
      await _storage.deleteAll();
      _loadAllData();
      _showSnackBar('Todos os dados seguros foram removidos!');
    } catch (e) {
      _showSnackBar('Erro ao limpar dados: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Secure Storage'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card informativo
            _buildInfoCard(),
            SizedBox(height: 20),

            // Credenciais de Login
            _buildSection(
              title: '🔐 Credenciais de Login',
              description: 'Salve username e password de forma segura',
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nome de usuário',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveCredentials,
                          icon: Icon(Icons.save),
                          label: Text('Salvar Credenciais'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _readPassword,
                          icon: Icon(Icons.visibility),
                          label: Text('Ver Senha'),
                        ),
                      ),
                    ],
                  ),
                  if (_savedUsername != 'Não definido')
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Usuário salvo: $_savedUsername'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Token de Autenticação
            _buildSection(
              title: '🎟️ Token de Autenticação',
              description: 'Armazene tokens JWT, API keys, etc.',
              child: Column(
                children: [
                  TextField(
                    controller: _tokenController,
                    decoration: InputDecoration(
                      labelText: 'Token/API Key',
                      hintText: 'ex: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
                      prefixIcon: Icon(Icons.vpn_key),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _saveToken,
                    icon: Icon(Icons.save),
                    label: Text('Salvar Token'),
                  ),
                  if (_savedToken != 'Não definido')
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Token salvo:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _savedToken.length > 50
                                  ? '${_savedToken.substring(0, 50)}...'
                                  : _savedToken,
                              style: TextStyle(fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Dados Personalizados
            _buildSection(
              title: '⚙️ Dados Personalizados',
              description: 'Salve qualquer chave-valor sensível',
              child: Column(
                children: [
                  TextField(
                    controller: _keyController,
                    decoration: InputDecoration(
                      labelText: 'Chave',
                      hintText: 'ex: api_secret, certificate, etc.',
                      prefixIcon: Icon(Icons.key),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _valueController,
                    decoration: InputDecoration(
                      labelText: 'Valor',
                      hintText: 'Valor sensível a ser armazenado',
                      prefixIcon: Icon(Icons.security),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _saveCustomKeyValue,
                    icon: Icon(Icons.save),
                    label: Text('Salvar Dados Personalizados'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Ações Gerais
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showAllKeys,
                    icon: Icon(Icons.list),
                    label: Text('Ver Todas as Chaves'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loadAllData,
                    icon: Icon(Icons.refresh),
                    label: Text('Recarregar'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _clearAll,
              icon: Icon(Icons.delete_forever),
              label: Text('Limpar Todos os Dados'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),

            SizedBox(height: 20),

            // Status
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 Status do Armazenamento:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text('Chaves salvas: ${_allKeys.length}'),
                  if (_allKeys.isNotEmpty)
                    Text(
                      'Chaves: ${_allKeys.join(', ')}',
                      style: TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.orange[700]),
              SizedBox(width: 8),
              Text(
                'Flutter Secure Storage',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Armazenamento criptografado usando Keychain (iOS) e Android Keystore. Ideal para dados sensíveis como senhas, tokens e certificados.',
            style: TextStyle(color: Colors.orange[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            SizedBox(height: 15),
            child,
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sobre Secure Storage'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎯 Quando usar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Senhas e credenciais'),
              Text('• Tokens de autenticação (JWT, API keys)'),
              Text('• Certificados digitais'),
              Text('• Dados de cartão de crédito'),
              SizedBox(height: 10),
              Text(
                '🔒 Como funciona:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• iOS: Keychain Services'),
              Text('• Android: Android Keystore'),
              Text('• Criptografia AES-256'),
              Text('• Chaves protegidas por hardware'),
              SizedBox(height: 10),
              Text(
                '⚠️ Diferenças do SharedPreferences:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Dados são criptografados'),
              Text('• Mais lento (por segurança)'),
              Text('• Protegido contra root/jailbreak'),
              Text('• Pode exigir autenticação biométrica'),
              SizedBox(height: 10),
              Text('💡 Dicas:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Use apenas para dados sensíveis'),
              Text('• Trate possíveis exceções'),
              Text('• Considere backup/restauração'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Entendi'),
          ),
        ],
      ),
    );
  }
}
