import 'package:flutter/material.dart';
import 'package:solo_listas_app/pages/barra_lateral.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_listas_app/pages/tarea.dart';
import 'dart:convert';

class Lista extends StatefulWidget {
  const Lista({super.key});

  @override
  State<Lista> createState() => _ListaState();
}

class _ListaState extends State<Lista> {
  List<Task> tasks = [];

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = prefs.getStringList('tasks') ?? [];

    setState(() {
      tasks = taskList.map((taskString) {
        final Map<String, dynamic> taskMap = json.decode(taskString);
        return Task.fromMap(taskMap);
      }).toList();
    });
  }

  Future<void> _deleteTask(int index) async {
    setState(() {
      tasks.removeAt(index);
    });

    await _saveTasks();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskStrings = tasks.map((task) => json.encode(task.toMap())).toList();
    await prefs.setStringList('tasks', taskStrings);
  }

  void clearAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tasks');
    setState(() {
      tasks = [];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista'),
      ),
      body: Scrollbar(
        child: tasks.isEmpty ? const Center(child: Text('No hay tareas'),) 
        : ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return InkWell(
              onTap: () {
                _showTaskDetails(context, task);
              },
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.taskName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                task.taskDescription,
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${task.startDate} - ${task.endDate}',
                              style: const TextStyle(fontSize: 10),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirmación'),
                                      content: const Text('¿Está seguro de eliminar la tarea?'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancelar'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Aceptar'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _deleteTask(index);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < task.isSelected.length; i++)
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: task.isSelected[i] ? getColorForIndex(i) : Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      drawer: BarraLateral(clearAllTasks: clearAllTasks),
    );
  }


  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            task.taskName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(task.taskDescription),
                const SizedBox(height: 10,),
                Text("Fecha de inicio: ${task.startDate}"),
                Text("Fecha de finalización: ${task.endDate}"),
                const SizedBox(height: 10,),
                Container(
                  alignment: Alignment.center,
                  child: Wrap(
                    spacing: 10.0, // Espaciado horizontal entre los elementos
                    runSpacing: 10.0, // Espaciado vertical entre las filas de elementos
                    children: task.isSelected.asMap().entries.map((entry) {
                      final index = entry.key;
                      final isSelected = entry.value;
                      final color = getColorForIndex(index);
                      final texto = getTextoForIndex(index);
                      return Container(
                        width: 100, // Ancho del contenedor
                        height: 40, // Alto del contenedor
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.grey,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        alignment: Alignment.center, // Para centrar el texto verticalmente
                        child: Text(
                          texto,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // Esta función devuelve el color según el índice
  Color getColorForIndex(int index) {
    final colors = [Colors.green, Colors.yellow, Colors.red, Colors.purple];
    return colors[index];
  }

  // Esta función devuelve el texto según el índice
  String getTextoForIndex(int index) {
    final textos = ["Codear", "Flojear", "Comer", "Comprar"];
    return textos[index];
  }
}
