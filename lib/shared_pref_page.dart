import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Página completa demonstrando SharedPreferences
class SharedPrefPage extends StatefulWidget {
  const SharedPrefPage({super.key});

  @override
  SharedPrefPageState createState() => SharedPrefPageState();
}

class SharedPrefPageState extends State<SharedPrefPage> {
  // Controladores para diferentes tipos de dados
  final _stringController = TextEditingController();
  final _intController = TextEditingController();
  final _doubleController = TextEditingController();
  final _listController = TextEditingController();

  // Variáveis para armazenar valores carregados
  String _savedString = 'Não definido';
  int _savedInt = 0;
  double _savedDouble = 0.0;
  bool _savedBool = false;
  List<String> _savedList = [];

  @override
  void initState() {
    super.initState();
    _loadAllPreferences();
  }

  @override
  void dispose() {
    _stringController.dispose();
    _intController.dispose();
    _doubleController.dispose();
    _listController.dispose();
    super.dispose();
  }

  /// Carrega todas as preferências salvas
  Future<void> _loadAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedString = prefs.getString('demo_string') ?? 'Não definido';
      _savedInt = prefs.getInt('demo_int') ?? 0;
      _savedDouble = prefs.getDouble('demo_double') ?? 0.0;
      _savedBool = prefs.getBool('demo_bool') ?? false;
      _savedList = prefs.getStringList('demo_list') ?? [];
    });
  }

  /// Salva uma string
  Future<void> _saveString() async {
    if (_stringController.text.isEmpty) {
      _showSnackBar('Digite um texto primeiro');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('demo_string', _stringController.text);
    _stringController.clear();
    _loadAllPreferences();
    _showSnackBar('String salva com sucesso!');
  }

  /// Salva um número inteiro
  Future<void> _saveInt() async {
    if (_intController.text.isEmpty) {
      _showSnackBar('Digite um número primeiro');
      return;
    }

    final int? value = int.tryParse(_intController.text);
    if (value == null) {
      _showSnackBar('Digite um número válido');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('demo_int', value);
    _intController.clear();
    _loadAllPreferences();
    _showSnackBar('Número inteiro salvo com sucesso!');
  }

  /// Salva um número decimal
  Future<void> _saveDouble() async {
    if (_doubleController.text.isEmpty) {
      _showSnackBar('Digite um número decimal primeiro');
      return;
    }

    final double? value = double.tryParse(_doubleController.text);
    if (value == null) {
      _showSnackBar('Digite um número decimal válido');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('demo_double', value);
    _doubleController.clear();
    _loadAllPreferences();
    _showSnackBar('Número decimal salvo com sucesso!');
  }

  /// Alterna valor booleano
  Future<void> _toggleBool(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('demo_bool', value);
    _loadAllPreferences();
    _showSnackBar('Valor booleano ${value ? 'ativado' : 'desativado'}!');
  }

  /// Salva uma lista de strings
  Future<void> _saveList() async {
    if (_listController.text.isEmpty) {
      _showSnackBar('Digite itens separados por vírgula');
      return;
    }

    final List<String> items = _listController.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (items.isEmpty) {
      _showSnackBar('Digite pelo menos um item válido');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('demo_list', items);
    _listController.clear();
    _loadAllPreferences();
    _showSnackBar('Lista salva com sucesso!');
  }

  /// Remove todas as preferências
  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('demo_string');
    await prefs.remove('demo_int');
    await prefs.remove('demo_double');
    await prefs.remove('demo_bool');
    await prefs.remove('demo_list');
    _loadAllPreferences();
    _showSnackBar('Todas as preferências foram removidas!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SharedPreferences'),
        backgroundColor: Colors.green[600],
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

            // String
            _buildDataTypeSection(
              title: 'String (Texto)',
              description: 'Armazena texto simples',
              currentValue: 'Valor atual: "$_savedString"',
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _stringController,
                      decoration: InputDecoration(
                        hintText: 'Digite um texto...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(onPressed: _saveString, child: Text('Salvar')),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Integer
            _buildDataTypeSection(
              title: 'Integer (Número Inteiro)',
              description: 'Armazena números inteiros',
              currentValue: 'Valor atual: $_savedInt',
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _intController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Digite um número...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(onPressed: _saveInt, child: Text('Salvar')),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Double
            _buildDataTypeSection(
              title: 'Double (Número Decimal)',
              description: 'Armazena números com casas decimais',
              currentValue: 'Valor atual: $_savedDouble',
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _doubleController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Digite um número decimal...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(onPressed: _saveDouble, child: Text('Salvar')),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Boolean
            _buildDataTypeSection(
              title: 'Boolean (Verdadeiro/Falso)',
              description: 'Armazena valores de liga/desliga',
              currentValue:
                  'Valor atual: ${_savedBool ? 'Ativado' : 'Desativado'}',
              child: SwitchListTile(
                title: Text('Configuração ativada'),
                value: _savedBool,
                onChanged: _toggleBool,
              ),
            ),

            SizedBox(height: 20),

            // List
            _buildDataTypeSection(
              title: 'List<String> (Lista de Textos)',
              description: 'Armazena uma lista de strings',
              currentValue:
                  'Itens salvos: ${_savedList.isEmpty ? 'Nenhum' : _savedList.join(', ')}',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _listController,
                          decoration: InputDecoration(
                            hintText: 'Digite itens separados por vírgula...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _saveList,
                        child: Text('Salvar'),
                      ),
                    ],
                  ),
                  if (_savedList.isNotEmpty) ...[
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Itens na lista:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ..._savedList.map(
                            (item) => Padding(
                              padding: EdgeInsets.only(left: 10, top: 2),
                              child: Text('• $item'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 30),

            // Botão para limpar tudo
            ElevatedButton.icon(
              onPressed: _clearAll,
              icon: Icon(Icons.clear_all),
              label: Text('Limpar Todas as Preferências'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),

            SizedBox(height: 20),

            // Botão para recarregar
            OutlinedButton.icon(
              onPressed: _loadAllPreferences,
              icon: Icon(Icons.refresh),
              label: Text('Recarregar Valores'),
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
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green[700]),
              SizedBox(width: 8),
              Text(
                'SharedPreferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Ideal para armazenar configurações do usuário, preferências e pequenos dados que precisam persistir entre sessões do app.',
            style: TextStyle(color: Colors.green[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTypeSection({
    required String title,
    required String description,
    required String currentValue,
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
            SizedBox(height: 8),
            Text(
              currentValue,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 12),
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
        title: Text('Sobre SharedPreferences'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 Quando usar:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Configurações do usuário (tema, idioma)'),
            Text('• Preferências simples'),
            Text('• Dados primitivos pequenos'),
            SizedBox(height: 10),
            Text(
              '⚠️ Quando não usar:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Dados sensíveis (use Secure Storage)'),
            Text('• Grandes quantidades de dados'),
            Text('• Dados complexos estruturados'),
            SizedBox(height: 10),
            Text(
              '💡 Características:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Sincronização automática'),
            Text('• API simples e rápida'),
            Text('• Disponível em todas as plataformas'),
          ],
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

// Widget simples para usar na página principal (mantendo compatibilidade)
class ThemePreferencePage extends StatefulWidget {
  const ThemePreferencePage({super.key});

  @override
  ThemePreferencePageState createState() => ThemePreferencePageState();
}

class ThemePreferencePageState extends State<ThemePreferencePage> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  void _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  void _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text('Tema escuro'),
      value: _isDarkMode,
      onChanged: _toggleTheme,
    );
  }
}
