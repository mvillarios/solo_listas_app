import 'package:flutter/material.dart';
import 'package:solo_listas_app/pages/lista.dart';

class AcercaDe extends StatelessWidget {
  const AcercaDe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Lista()));
          },
        )
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(20),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Integrantes:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),  
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Miguel Villa",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}