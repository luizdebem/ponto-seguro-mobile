import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Color.fromRGBO(0, 150, 199, 1),
      unselectedItemColor: Color.fromRGBO(198, 198, 198, 1),
      backgroundColor: Color.fromRGBO(252, 252, 252, 1),
      type: BottomNavigationBarType.fixed,
      currentIndex: 1,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: 'Alertas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.warning),
          label: 'Ocorrências',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.add,
            color: Color.fromRGBO(252, 252, 252, 1),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Opções',
        ),
      ],
    );
  }
}
