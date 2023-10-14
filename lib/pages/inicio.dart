import 'package:flutter/material.dart';
import 'package:solo_listas_app/pages/registro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:solo_listas_app/pages/lista.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String username = "";
  String password = "";

  Future<Map> _loadRegistrationData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username') ?? '';
    final savedPassword = prefs.getString('password') ?? '';

    return {'username': savedUsername, 'password': savedPassword};
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

                  ElevatedButton(
                    onPressed: () async {
                      final enteredUsername = _userController.text;
                      final enteredPassword = _passwordController.text;

                      if (enteredUsername.isEmpty || enteredPassword.isEmpty) {
                        MotionToast.error(
                          title: const Text("Error"),
                          description: const Text("Por favor, complete todos los campos"),
                          toastDuration: const Duration(seconds: 3),
                        ).show(context);
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
                        final savedData = await _loadRegistrationData();
                        if(context.mounted){
                          Navigator.of(context).pop(); // Cerrar diálogo de espera
                          if (enteredUsername == savedData['username'] && enteredPassword == savedData['password']) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Lista()),
                            );
                          } else {
                            MotionToast.error(
                              title: const Text("Error"),
                              description: const Text("Usuario o contraseña incorrectos"),
                              toastDuration: const Duration(seconds: 3),
                            ).show(context);
                          }
                        }
                      } catch (e) {
                        // Manejar error aquí
                        Navigator.of(context).pop(); // Cerrar diálogo de espera
                        MotionToast.error(
                          title: const Text("Error"),
                          description: const Text("Ocurrió un error al registrar el usuario"),
                          toastDuration: const Duration(seconds: 3),
                        ).show(context);
                      }
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 40)),
                    ),
                    child: const Text("Ingresar"),
                  ),

                  ElevatedButton(
                    onPressed:() {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const Registro())
                      );
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 40)),
                    ),
                    child: const Text("Registrarse"), 
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
