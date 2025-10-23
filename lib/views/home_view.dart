import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body:  SafeArea(
        child: Padding(padding: EdgeInsets.all(16.0),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selecione o perfil'),
            SizedBox(height: 20),
            Text('Perfil'),
            SizedBox(height: 10),
            PopupMenuButton(
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: 'freelancer',
                child: Text('Gerente'),
              ),
              const PopupMenuItem(
                value: 'client',
                child: Text('Recursos Humanos'),
              ),
                  const PopupMenuItem(
                    value: 'client',
                    child: Text('Diretoria'),
                  ),
            ]),
            ElevatedButton(onPressed: (){},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent
                ),
                child: Text('ENTRAR', style: TextStyle(color: Colors.black),))
          ],
        )),
      ),
    );
  }
}
