import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Modelo de dados simples
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'concluida': concluida ? 1 : 0,
    };
  }

  static Tarefa fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      concluida: map['concluida'] == 1,
    );
  }
}

class SQLitePage extends StatefulWidget {
  const SQLitePage({super.key});

  @override
  SQLitePageState createState() => SQLitePageState();
}

class SQLitePageState extends State<SQLitePage> {
  late Database _db;
  List<Tarefa> _tarefas = [];
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _initDb() async {
    setState(() => _isLoading = true);

    _db = await openDatabase(
      join(await getDatabasesPath(), 'tarefas_demo.db'),
      onCreate: (db, version) {
        return db.execute('''CREATE TABLE tarefas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            descricao TEXT NOT NULL,
            concluida INTEGER NOT NULL DEFAULT 0
          )''');
      },
      version: 1,
    );

    await _carregarTarefas();
    setState(() => _isLoading = false);
  }

  Future<void> _carregarTarefas() async {
    final maps = await _db.query('tarefas', orderBy: 'id DESC');
    setState(() {
      _tarefas = maps.map((map) => Tarefa.fromMap(map)).toList();
    });
  }

  Future<void> _adicionarTarefa(BuildContext context) async {
    if (_nomeController.text.trim().isEmpty) {
      _showSnackBar(context, 'Digite o nome da tarefa');
      return;
    }

    final tarefa = Tarefa(
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
    );

    await _db.insert('tarefas', tarefa.toMap());
    _nomeController.clear();
    _descricaoController.clear();
    await _carregarTarefas();
    _showSnackBar(context, 'Tarefa adicionada com sucesso!');
  }

  Future<void> _toggleConcluida(BuildContext context, Tarefa tarefa) async {
    await _db.update(
      'tarefas',
      {'concluida': tarefa.concluida ? 0 : 1},
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
    await _carregarTarefas();
    _showSnackBar(
      context,
      tarefa.concluida ? 'Tarefa reaberta!' : 'Tarefa concluída!',
    );
  }

  Future<void> _removerTarefa(BuildContext context, int id) async {
    await _db.delete('tarefas', where: 'id = ?', whereArgs: [id]);
    await _carregarTarefas();
    _showSnackBar(context, 'Tarefa removida!');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite Database'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Card informativo
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
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
                    SizedBox(width: 8),
                    Text(
                      'Sistema de Tarefas com SQLite',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Banco de dados relacional local com CRUD completo. Ideal para dados estruturados que precisam funcionar offline.',
                  style: TextStyle(color: Colors.purple[700], fontSize: 12),
                ),
              ],
            ),
          ),

          // Formulário
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome da tarefa',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.task_alt),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                    labelText: 'Descrição (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () => _adicionarTarefa(context),
                  icon: Icon(Icons.add),
                  label: Text('Adicionar Tarefa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),

          // Estatísticas
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', '${_tarefas.length}', Colors.blue),
                _buildStatItem(
                  'Pendentes',
                  '${_tarefas.where((t) => !t.concluida).length}',
                  Colors.orange,
                ),
                _buildStatItem(
                  'Concluídas',
                  '${_tarefas.where((t) => t.concluida).length}',
                  Colors.green,
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Lista de tarefas
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _tarefas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma tarefa encontrada',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
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
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: tarefa.concluida,
                            onChanged: (_) => _toggleConcluida(context, tarefa),
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
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: tarefa.concluida
                                      ? Colors.green
                                      : Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tarefa.concluida ? 'Concluída' : 'Pendente',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _confirmarRemocao(context, tarefa),
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
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  void _confirmarRemocao(BuildContext context, Tarefa tarefa) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Deseja excluir a tarefa "${tarefa.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _removerTarefa(context, tarefa.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Sobre SQLite'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎯 Quando usar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Dados estruturados complexos'),
              Text('• Relacionamentos entre entidades'),
              Text('• Consultas SQL avançadas'),
              Text('• Apps que funcionam offline'),
              SizedBox(height: 10),
              Text(
                '💪 Recursos demonstrados:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• CRUD completo (Create, Read, Update, Delete)'),
              Text('• Modelo de dados estruturado'),
              Text('• Interface reativa'),
              Text('• Validações básicas'),
              SizedBox(height: 10),
              Text(
                '🔧 Características técnicas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Banco relacional SQL'),
              Text('• Suporte a transações'),
              Text('• Consultas otimizadas'),
              Text('• Schema versionado'),
              SizedBox(height: 10),
              Text(
                '⚡ Performance:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Acesso rápido a dados locais'),
              Text('• Suporte a índices'),
              Text('• Consultas complexas eficientes'),
              SizedBox(height: 10),
              Text(
                '📊 Exemplo prático:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Sistema de tarefas completo'),
              Text('• Estados (pendente/concluída)'),
              Text('• Contadores automáticos'),
              Text('• Validações de entrada'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Entendi'),
          ),
        ],
      ),
    );
  }
}
