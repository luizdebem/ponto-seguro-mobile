import 'package:flutter/material.dart';
import 'package:ponto_seguro/screens/Login/LoginScreen.dart';
import 'package:ponto_seguro/services/AuthService.dart';

class SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey,
            ),
            child: Text(
              'Aqui vai ter alguma coisa maneira',
            ),
          ),
          MaterialButton(
            onPressed: () {},
            child: ListTile(
              title: Text('Meu perfil'),
              leading: Icon(
                Icons.person,
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {},
            child: ListTile(
              title: Text('Minhas ocorrências'),
              leading: Icon(Icons.report_problem),
            ),
          ),
          MaterialButton(
            onPressed: () {
              AuthService.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                LoginScreen.routeName,
                (route) => false,
              );
            },
            child: ListTile(
              title: Text('Sair'),
              leading: Icon(
                Icons.logout,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
