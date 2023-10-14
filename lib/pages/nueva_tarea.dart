import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solo_listas_app/pages/lista.dart';
import 'package:solo_listas_app/pages/tarea.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:motion_toast/motion_toast.dart';

class NuevaTarea extends StatefulWidget {
  const NuevaTarea({Key? key}) : super(key: key);

  @override
  State<NuevaTarea> createState() => _NuevaTareaState();
}

class _NuevaTareaState extends State<NuevaTarea> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();

  // Estados para los botones de alternancia
  List<bool> isSelected = [false, false, false, false];
  
  List<Task> tasks = [];

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    )) ?? DateTime.now();

    if (picked != DateTime.now()) {
      final formattedDate = DateFormat('d/M/y', 'es').format(picked);
      setState(() {
        // Usa DateFormat para formatear la fecha
        controller.text = formattedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = prefs.getStringList('tasks') ?? [];

    setState(() {
      tasks = taskList.map((taskString){
        final Map<String, dynamic> taskMap = json.decode(taskString);
        return Task.fromMap(taskMap);
      }).toList();
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskStrings = tasks.map((task) => json.encode(task.toMap())).toList();
    await prefs.setStringList('tasks', taskStrings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Tarea'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Lista()));
          },
        )
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _startDateController,
                    "Fecha Inicial",
                    1,
                    20,
                    false,
                    false,
                    () {
                      _selectDate(context, _startDateController);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _endDateController,
                    "Fecha Final",
                    1,
                    20,
                    false,
                    false,
                    () {
                      _selectDate(context, _endDateController);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _taskNameController,
              "Título",
              1,
              30,
              true,
              false,
              null
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _taskDescriptionController,
              "Descripción",
              3,
              255,
              true,
              false,
              null
            ),
            const SizedBox(height: 20),
            Container(
              //Centrar
              alignment: Alignment.center,
              child: Wrap(
                spacing: 40.0, // Espaciado horizontal entre botones
                runSpacing: 10.0, // Espaciado vertical entre filas de botones
                children: [
                  _buildButton("Codear", Colors.green, 0),
                  _buildButton("Flojear", Colors.yellow, 1),
                  _buildButton("Comer", Colors.red, 2),
                  _buildButton("Comprar", Colors.purple, 3),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  if (_startDateController.text.isEmpty ||
                      _endDateController.text.isEmpty) {
                    MotionToast.error(
                      title: const Text("Error"),
                      description: const Text("Por favor, asigne una fecha inicial y final"),
                      toastDuration: const Duration(seconds: 3),
                    ).show(context);
                    return;
                  }
            
                  if (_taskNameController.text.isEmpty) {
                    MotionToast.error(
                      title: const Text("Error"),
                      description: const Text("Por favor, asigne un título a la tarea"),
                      toastDuration: const Duration(seconds: 3),
                    ).show(context);
                    return;
                  }
            
                  final newTask = Task(
                    startDate: _startDateController.text,
                    endDate: _endDateController.text,
                    taskName: _taskNameController.text,
                    taskDescription: _taskDescriptionController.text,
                    isSelected: isSelected,
                  );
            
                  setState(() {
                    tasks.add(newTask);
                  });
            
                  _saveTasks();
            
                  // Restablecer los campos de entrada
                  _startDateController.clear();
                  _endDateController.clear();
                  _taskNameController.clear();
                  _taskDescriptionController.clear();
                  isSelected = [false, false, false, false];
            
                  MotionToast.success(
                    title: const Text("Éxito"),
                    description: const Text("Tarea creada correctamente"),
                    toastDuration: const Duration(seconds: 3),
                  ).show(context);
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(240, 50)),
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                    color: Colors.white,
                  ),  
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
    int maxLines, int maxLength, bool showLength, bool isPassword, void Function()? onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText),
        TextField(
          controller: controller,
          onTap: onTap,
          readOnly: onTap != null,
          maxLines: maxLines,
          maxLength: maxLength,
          buildCounter: (BuildContext context, {required int currentLength, required bool isFocused, required int? maxLength}){
            if(showLength){
              return Text('$currentLength/$maxLength');
            }else{
              return null;
            }
          },
          decoration: const InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 2,
                color: Colors.blue,
              ),
            ),
            contentPadding: EdgeInsets.all(10),
          ),
          obscureText: isPassword,
        ),
      ],
    );
  }

  Widget _buildButton(String text, Color color, int i) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isSelected[i] = !isSelected[i];
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected[i]? color : Colors.white ,
        minimumSize: const Size(100, 40),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected[i]? Colors.white : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
