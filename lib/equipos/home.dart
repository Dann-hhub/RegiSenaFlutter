import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Equipment {
  final String serial;
  final String marca;
  final String accesorios;
  final String color;
  final String fechaRegistro;
  final int tipoEquipoId;
  final int estado;

  Equipment({
    required this.serial,
    required this.marca,
    required this.accesorios,
    required this.color,
    required this.fechaRegistro,
    required this.tipoEquipoId,
    required this.estado,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      serial: json['serial'] ?? '',
      marca: json['marca'] ?? '',
      accesorios: json['accesorios'] ?? '',
      color: json['color'] ?? '',
      fechaRegistro: json['fechaRegistro'] ?? '',
      tipoEquipoId: json['tipoEquipoId'] ?? 0,
      estado: json['estado'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serial': serial,
      'marca': marca,
      'accesorios': accesorios,
      'color': color,
      'fechaRegistro': fechaRegistro,
      'tipoEquipoId': tipoEquipoId,
      'estado': estado,
    };
  }
}

class EquipmentListScreen extends StatefulWidget {
  const EquipmentListScreen({super.key});

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  late Future<List<Equipment>> futureEquipos;
  final String apiUrl = 'http://127.0.0.1:5000/equipo';
  List<Equipment> equiposList = [];
  List<Equipment> filteredEquipos = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureEquipos = _fetchEquipos();
    searchController.addListener(_filterEquipos);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<Equipment>> _fetchEquipos() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        equiposList = (data['equipos'] as List)
            .map((e) => Equipment.fromJson(e))
            .toList();
        filteredEquipos = List.from(equiposList);
        return equiposList;
      } else {
        throw Exception('Failed to load equipos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load equipos: $e');
    }
  }

  void _filterEquipos() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredEquipos = equiposList.where((equipo) {
        return equipo.serial.toLowerCase().contains(query) ||
            equipo.marca.toLowerCase().contains(query) ||
            equipo.tipoEquipoId.toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _deleteEquipo(String serial) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$serial'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        _refreshEquipos();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipo eliminado correctamente')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el equipo: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _toggleEstado(String serial, int currentEstado) async {
    try {
      final newEstado = currentEstado == 1 ? 0 : 1;
      final response = await http.put(
        Uri.parse('$apiUrl/$serial/estado'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'estado': newEstado}),
      );

      if (response.statusCode == 200) {
        _refreshEquipos();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado cambiado a ${newEstado == 1 ? 'Activo' : 'Inactivo'}')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _refreshEquipos() {
    setState(() {
      futureEquipos = _fetchEquipos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Equipos'),
        backgroundColor: const Color(0xFF128941),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshEquipos,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar equipos',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Equipment>>(
              future: futureEquipos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || filteredEquipos.isEmpty) {
                  return const Center(child: Text('No hay equipos registrados'));
                } else {
                  return ListView.builder(
                    itemCount: filteredEquipos.length,
                    itemBuilder: (context, index) {
                      final equipo = filteredEquipos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.computer, color: Color(0xFF128941)),
                          title: Text(equipo.serial),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Marca: ${equipo.marca}'),
                              Text('Tipo Equipo: ${equipo.tipoEquipoId}'),
                              Text('Fecha Registro: ${equipo.fechaRegistro}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.toggle_on,
                                  color: equipo.estado == 1 ? Colors.green : Colors.red,
                                  size: 30,
                                ),
                                onPressed: () => _toggleEstado(equipo.serial, equipo.estado),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddEditEquipmentScreen(
                                        equipo: equipo,
                                        isEditing: true,
                                      ),
                                    ),
                                  ).then((_) => _refreshEquipos());
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteDialog(equipo.serial),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EquipmentDetailScreen(equipo: equipo),
                              ),
                            ).then((_) => _refreshEquipos());
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF128941),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditEquipmentScreen(isEditing: false),
            ),
          ).then((_) => _refreshEquipos());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(String serial) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este equipo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEquipo(serial);
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class AddEditEquipmentScreen extends StatefulWidget {
  final Equipment? equipo;
  final bool isEditing;

  const AddEditEquipmentScreen({
    super.key,
    this.equipo,
    required this.isEditing,
  });

  @override
  State<AddEditEquipmentScreen> createState() => _AddEditEquipmentScreenState();
}

class _AddEditEquipmentScreenState extends State<AddEditEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serialController;
  late TextEditingController _marcaController;
  late TextEditingController _accesoriosController;
  late TextEditingController _colorController;
  late TextEditingController _fechaRegistroController;
  late TextEditingController _tipoEquipoIdController;
  late int _estado;

  @override
  void initState() {
    super.initState();
    _serialController = TextEditingController(text: widget.equipo?.serial ?? '');
    _marcaController = TextEditingController(text: widget.equipo?.marca ?? '');
    _accesoriosController = TextEditingController(text: widget.equipo?.accesorios ?? '');
    _colorController = TextEditingController(text: widget.equipo?.color ?? '');
    _fechaRegistroController = TextEditingController(text: widget.equipo?.fechaRegistro ?? '');
    _tipoEquipoIdController = TextEditingController(text: widget.equipo?.tipoEquipoId.toString() ?? '');
    _estado = widget.equipo?.estado ?? 1;
  }

  @override
  void dispose() {
    _serialController.dispose();
    _marcaController.dispose();
    _accesoriosController.dispose();
    _colorController.dispose();
    _fechaRegistroController.dispose();
    _tipoEquipoIdController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final equipment = {
          'serial': _serialController.text,
          'marca': _marcaController.text,
          'accesorios': _accesoriosController.text,
          'color': _colorController.text,
          'fechaRegistro': _fechaRegistroController.text,
          'tipoEquipoId': int.parse(_tipoEquipoIdController.text),
          'estado': _estado,
        };

        final url = Uri.parse(widget.isEditing
            ? 'http://127.0.0.1:5000/equipo/${_serialController.text}'
            : 'http://127.0.0.1:5000/equipo');

        final response = widget.isEditing
            ? await http.put(
                url,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(equipment),
              )
            : await http.post(
                url,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(equipment),
              );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEditing
                  ? 'Equipo actualizado correctamente'
                  : 'Equipo creado correctamente'),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar el equipo: ${response.body}')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Equipo' : 'Agregar Equipo'),
        backgroundColor: const Color(0xFF128941),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _serialController,
                decoration: const InputDecoration(labelText: 'Serial'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el serial';
                  }
                  return null;
                },
                readOnly: widget.isEditing,
              ),
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(labelText: 'Marca'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la marca';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _accesoriosController,
                decoration: const InputDecoration(labelText: 'Accesorios'),
              ),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextFormField(
                controller: _fechaRegistroController,
                decoration: const InputDecoration(labelText: 'Fecha de Registro'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _fechaRegistroController.text =
                        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                  }
                },
              ),
              TextFormField(
                controller: _tipoEquipoIdController,
                decoration: const InputDecoration(labelText: 'Tipo de Equipo ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el tipo de equipo';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Estado'),
                subtitle: Text(_estado == 1 ? 'Activo' : 'Inactivo'),
                value: _estado == 1,
                onChanged: (value) {
                  setState(() {
                    _estado = value ? 1 : 0;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF128941),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _submitForm,
                child: Text(
                  widget.isEditing ? 'Actualizar' : 'Guardar',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EquipmentDetailScreen extends StatelessWidget {
  final Equipment equipo;

  const EquipmentDetailScreen({super.key, required this.equipo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(equipo.serial),
        backgroundColor: const Color(0xFF128941),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Serial: ${equipo.serial}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Marca: ${equipo.marca}'),
            const SizedBox(height: 10),
            Text('Accesorios: ${equipo.accesorios}'),
            const SizedBox(height: 10),
            Text('Color: ${equipo.color}'),
            const SizedBox(height: 10),
            Text('Fecha Registro: ${equipo.fechaRegistro}'),
            const SizedBox(height: 10),
            Text('Tipo Equipo ID: ${equipo.tipoEquipoId}'),
            const SizedBox(height: 10),
            Chip(
              label: Text(
                equipo.estado == 1 ? 'Activo' : 'Inactivo',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: equipo.estado == 1 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}