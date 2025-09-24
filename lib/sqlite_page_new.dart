import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Tarefa {
  final int? id;
  final String nome;
  final String descricao;
  final bool concluida;

  Tarefa({
    this.id,
    required this.nome,
    required this.descricao,
    this.concluida = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'descricao': descricao,
    'concluida': concluida ? 1 : 0,
  };

  static Tarefa fromMap(Map<String, dynamic> map) => Tarefa(
    id: map['id'],
    nome: map['nome'],
    descricao: map['descricao'],
    concluida: map['concluida'] == 1,
  );
}

class SQLitePage extends StatefulWidget {
  const SQLitePage({super.key});

  @override
  State<SQLitePage> createState() => _SQLitePageState();
}

class _SQLitePageState extends State<SQLitePage> {
  Database? _database;
  List<Tarefa> _tarefas = [];
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'tarefas_demo.db');
    
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE tarefas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            descricao TEXT NOT NULL,
            concluida INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
    
    await _loadTarefas();
    setState(() => _isLoading = false);
  }

  Future<void> _loadTarefas() async {
    if (_database == null) return;
    
    final List<Map<String, dynamic>> maps = await _database!.query(
      'tarefas', 
      orderBy: 'id DESC'
    );
    
    setState(() {
      _tarefas = maps.map((map) => Tarefa.fromMap(map)).toList();
    });
  }

  Future<void> _addTarefa() async {
    if (_database == null) return;
    if (_nomeController.text.trim().isEmpty) {
      _showMessage('Digite o nome da tarefa');
      return;
    }

    final tarefa = Tarefa(
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
    );

    await _database!.insert('tarefas', tarefa.toMap());
    _nomeController.clear();
    _descricaoController.clear();
    await _loadTarefas();
    _showMessage('Tarefa adicionada!');
  }

  Future<void> _toggleTarefa(Tarefa tarefa) async {
    if (_database == null || tarefa.id == null) return;
    
    await _database!.update(
      'tarefas',
      {'concluida': tarefa.concluida ? 0 : 1},
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
    
    await _loadTarefas();
    _showMessage(tarefa.concluida ? 'Tarefa reaberta!' : 'Tarefa concluída!');
  }

  Future<void> _deleteTarefa(int id) async {
    if (_database == null) return;
    
    await _database!.delete('tarefas', where: 'id = ?', whereArgs: [id]);
    await _loadTarefas();
    _showMessage('Tarefa removida!');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _confirmDelete(Tarefa tarefa) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir "${tarefa.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (tarefa.id != null) _deleteTarefa(tarefa.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final total = _tarefas.length;
    final concluidas = _tarefas.where((t) => t.concluida).length;
    final pendentes = total - concluidas;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', '$total', Colors.blue),
          _buildStatItem('Pendentes', '$pendentes', Colors.orange),
          _buildStatItem('Concluídas', '$concluidas', Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Database'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.storage, color: Colors.purple[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Sistema de Tarefas SQLite',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Banco de dados relacional local com operações CRUD. Ideal para dados estruturados offline.',
                  style: TextStyle(color: Colors.purple[700], fontSize: 12),
                ),
              ],
            ),
          ),

          // Form
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da tarefa',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.task_alt),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _addTarefa,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Tarefa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),

          // Stats
          _buildStatsCard(),

          // Task List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tarefas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma tarefa encontrada',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                            Text(
                              'Adicione uma nova tarefa acima',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tarefas.length,
                        itemBuilder: (context, index) {
                          final tarefa = _tarefas[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: Checkbox(
                                value: tarefa.concluida,
                                onChanged: (_) => _toggleTarefa(tarefa),
                              ),
                              title: Text(
                                tarefa.nome,
                                style: TextStyle(
                                  decoration: tarefa.concluida
                                      ? TextDecoration.lineThrough
                                      : null,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: tarefa.descricao.isNotEmpty
                                  ? Text(
                                      tarefa.descricao,
                                      style: TextStyle(
                                        decoration: tarefa.concluida
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: tarefa.concluida ? Colors.green : Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      tarefa.concluida ? 'Concluída' : 'Pendente',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmDelete(tarefa),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Sobre SQLite'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🎯 Quando usar:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Dados estruturados complexos'),
              Text('• Relacionamentos entre entidades'),
              Text('• Consultas SQL avançadas'),
              Text('• Apps que funcionam offline'),
              SizedBox(height: 10),
              Text('💪 Recursos demonstrados:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• CRUD completo (Create, Read, Update, Delete)'),
              Text('• Modelo de dados estruturado'),
              Text('• Interface reativa'),
              Text('• Validações básicas'),
              SizedBox(height: 10),
              Text('🔧 Características técnicas:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Banco relacional SQL'),
              Text('• Suporte a transações'),
              Text('• Consultas otimizadas'),
              Text('• Schema versionado'),
              SizedBox(height: 10),
              Text('⚡ Performance:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Acesso rápido a dados locais'),
              Text('• Suporte a índices'),
              Text('• Consultas complexas eficientes'),
              SizedBox(height: 10),
              Text('📊 Exemplo prático:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Sistema de tarefas completo'),
              Text('• Estados (pendente/concluída)'),
              Text('• Contadores automáticos'),
              Text('• Validações de entrada'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}