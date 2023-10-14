class Task {
  final String startDate;
  final String endDate;
  final String taskName;
  final String taskDescription;
  final List<bool> isSelected;

  Task({
    required this.startDate,
    required this.endDate,
    required this.taskName,
    required this.taskDescription,
    required this.isSelected,
  });

  // Convierte una tarea en un mapa para ser almacenada en SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'taskName': taskName,
      'taskDescription': taskDescription,
      'isSelected': isSelected,
    };
  }

  // Crea una tarea a partir de un mapa obtenido desde SharedPreferences
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      startDate: map['startDate'],
      endDate: map['endDate'],
      taskName: map['taskName'],
      taskDescription: map['taskDescription'],
      isSelected: List<bool>.from(map['isSelected']),
    );
  }
}
