import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motion_toast/motion_toast.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _saveRegistrationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _userController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setString('name', _nameController.text);
  }

  Widget _buildTextField(TextEditingController controller, String labelText, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText),
        TextField(
          controller: controller,
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
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: const Image(
                image: AssetImage('assets/images/udec.jpg'),
                width: 200,
                height: 150,
              )
            ),
            Container(
              margin: const EdgeInsets.only(left: 50, right: 50, bottom: 50),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_userController, "Usuario", false),
                  _buildTextField(_passwordController, "Contraseña", true),
                  _buildTextField(_password2Controller, "Repetir Contraseña", true),
                  _buildTextField(_nameController, "Nombre", false),

                  ElevatedButton(
                    onPressed: () async {
                      if (_userController.text.isEmpty ||
                          _passwordController.text.isEmpty ||
                          _password2Controller.text.isEmpty ||
                          _nameController.text.isEmpty) {
                        MotionToast.error(
                          title: const Text("Error"),
                          description: const Text("Por favor, complete todos los campos"),
                          toastDuration: const Duration(seconds: 3),
                        ).show(context);
                        return;
                      }

                      if (_passwordController.text != _password2Controller.text) {
                        MotionToast.error(
                          title: const Text("Error"),
                          description: const Text("Las contraseñas no coinciden"),
                          toastDuration: const Duration(seconds: 3),
                        ).show(context);
                        return;
                      }

                      // Mostrar diálogo de espera
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );

                      try {
                        await _saveRegistrationData();
                        if (context.mounted) {
                          Navigator.of(context).pop(); // Cerrar diálogo de espera
                          MotionToast.success(
                            title: const Text("Éxito"),
                            description: const Text("Usuario registrado"),
                            toastDuration: const Duration(seconds: 3),
                          ).show(context);
                        }
                      } catch (e) {
                        // Manejar error aquí
                        if (context.mounted) {
                          Navigator.of(context).pop(); // Cerrar diálogo de espera
                          MotionToast.error(
                            title: const Text("Error"),
                            description: const Text("Ocurrió un error al registrar el usuario"),
                            toastDuration: const Duration(seconds: 3),
                          ).show(context);
                        }
                      }
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 40)),
                    ),
                    child: const Text("Guardar"),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 40)),
                    ),
                    child: const Text("Volver"), 
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
