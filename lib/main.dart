// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/views/client/client_list_view.dart';
import 'presentation/views/client/client_form_modal.dart';
// Importamos la vista de Productos (placeholder por ahora)
import 'presentation/views/product/product_list_view.dart';

void main() async {
  // Asegura que los widgets de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Envolvemos la app con ProviderScope para usar Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giova SAS - Cotizaciones',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// Enum para manejar las opciones del menú de navegación
enum MenuOption { clients, products, quotations, settings }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Estado que define qué vista se muestra en el body
  MenuOption _currentView = MenuOption.clients;

  // Mapea la opción actual al título de la AppBar
  String _getTitle() {
    switch (_currentView) {
      case MenuOption.clients:
        return 'Gestión de Clientes';
      case MenuOption.products:
        return 'Gestión de Productos/Servicios';
      case MenuOption.quotations:
        return 'Lista de Cotizaciones';
      case MenuOption.settings:
        return 'Configuración de la Empresa';
    }
  }

  // Mapea la opción actual al widget que se muestra en el body
  Widget _getBody() {
    switch (_currentView) {
      case MenuOption.clients:
        return const ClientListView();
      case MenuOption.products:
        return const ProductListView();
      case MenuOption.quotations:
        // Placeholder
        return const Center(
          child: Text('Lista de Cotizaciones (En desarrollo)'),
        );
      case MenuOption.settings:
        // Placeholder
        return const Center(child: Text('Configuración (En desarrollo)'));
    }
  }

  // Muestra el modal para añadir un cliente
  void _showAddClientForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ClientFormModal(),
    );
  }

  // Muestra el modal para añadir un producto (función placeholder)
  void _showAddProductForm(BuildContext context) {
    // Implementaremos esto una vez que tengamos el ProductFormModal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abriendo Formulario de Producto...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determina si el FloatingActionButton debe ser visible
    final bool showFab =
        _currentView == MenuOption.clients ||
        _currentView == MenuOption.products;

    // Define el icono del FAB según la vista
    final IconData fabIcon = _currentView == MenuOption.clients
        ? Icons.person_add
        : Icons.inventory_2;

    return Scaffold(
      // La AppBar muestra el título de la vista actual y el ícono de menú (Drawer)
      appBar: AppBar(title: Text(_getTitle())),

      // Menú lateral de navegación
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text(
                'Menú Principal',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            // Opción Clientes
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Clientes'),
              onTap: () {
                setState(() => _currentView = MenuOption.clients);
                Navigator.pop(context); // Cierra el drawer
              },
              selected: _currentView == MenuOption.clients,
            ),
            // Opción Productos
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Productos/Servicios'),
              onTap: () {
                setState(() => _currentView = MenuOption.products);
                Navigator.pop(context); // Cierra el drawer
              },
              selected: _currentView == MenuOption.products,
            ),
            const Divider(),
            // Opción Cotizaciones
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Cotizaciones'),
              onTap: () {
                setState(() => _currentView = MenuOption.quotations);
                Navigator.pop(context);
              },
              selected: _currentView == MenuOption.quotations,
            ),
            // Opción Configuración
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                setState(() => _currentView = MenuOption.settings);
                Navigator.pop(context);
              },
              selected: _currentView == MenuOption.settings,
            ),
          ],
        ),
      ),

      body:
          _getBody(), // Muestra la vista seleccionada (ClientListView o ProductListView)

      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () {
                if (_currentView == MenuOption.clients) {
                  _showAddClientForm(context);
                } else if (_currentView == MenuOption.products) {
                  _showAddProductForm(context);
                }
              },
              child: Icon(fabIcon),
            )
          : null,
    );
  }
}
