import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_listas_app/pages/acerca_de.dart';
import 'package:solo_listas_app/pages/nueva_tarea.dart';

class BarraLateral extends StatelessWidget {
  final VoidCallback clearAllTasks;

  const BarraLateral({super.key, required this.clearAllTasks});

  Future<String?> _getStoredName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getStoredName(),
      builder: (context, snapshot) {
        final name = snapshot.data;
        return Drawer(
          child: Container(
            color: Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(name ?? ''), // Muestra el nombre de usuario o cadena vacía si es nulo
                  accountEmail: const Text(''),
                ),
                ListTile(
                  title: const Text("Nueva Tarea"),
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const NuevaTarea())
                    );
                  },
                ),
                ListTile(
                  title: const Text("Borrar Todo"),
                  onTap: () {
                    clearAllTasks();
                  },
                ),
                ListTile(
                  title: const Text("Acerca de"),
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const AcercaDe())
                    );
                  },
                ),
                ListTile(
                  title: const Text("Salir"),
                  onTap: () {
                    Navigator.of(context).
                      pushReplacementNamed('/');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
