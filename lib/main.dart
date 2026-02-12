import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/views/client/client_list_view.dart';
import 'presentation/views/client/client_form_modal.dart';
import 'presentation/views/product/product_list_view.dart';
import 'presentation/views/product/product_form_modal.dart';
import 'presentation/views/quotation/quotation_list_page.dart';
import 'presentation/views/quotation/quotation_form_modal.dart';
import 'presentation/views/settings/company_config_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

enum MenuOption { clients, products, quotations, settings }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MenuOption _currentView = MenuOption.clients;

  String _getTitle() {
    switch (_currentView) {
      case MenuOption.clients:
        return 'Gestion de Clientes';
      case MenuOption.products:
        return 'Gestion de Productos/Servicios';
      case MenuOption.quotations:
        return 'Lista de Cotizaciones';
      case MenuOption.settings:
        return 'Configuracion de la Empresa';
    }
  }

  Widget _getBody() {
    switch (_currentView) {
      case MenuOption.clients:
        return const ClientListView();
      case MenuOption.products:
        return const ProductListView();
      case MenuOption.quotations:
        return const QuotationListView();
      case MenuOption.settings:
        return const CompanyConfigView();
    }
  }

  Widget? _getFab() {
    switch (_currentView) {
      case MenuOption.clients:
        return FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              barrierColor: Colors.black54,
              builder: (context) => const ClientFormModal(),
            );
          },
          child: const Icon(Icons.add),
        );
      case MenuOption.products:
        return FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              barrierColor: Colors.black54,
              builder: (context) => const ProductFormModal(),
            );
          },
          child: const Icon(Icons.add),
        );
      case MenuOption.quotations:
        return FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const QuotationFormModal(),
            );
          },
          child: const Icon(Icons.add),
        );
      case MenuOption.settings:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getTitle())),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text(
                'Menu Principal',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Clientes'),
              selected: _currentView == MenuOption.clients,
              onTap: () {
                setState(() => _currentView = MenuOption.clients);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Productos/Servicios'),
              selected: _currentView == MenuOption.products,
              onTap: () {
                setState(() => _currentView = MenuOption.products);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Cotizaciones'),
              selected: _currentView == MenuOption.quotations,
              onTap: () {
                setState(() => _currentView = MenuOption.quotations);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuracion'),
              selected: _currentView == MenuOption.settings,
              onTap: () {
                setState(() => _currentView = MenuOption.settings);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _getBody(),
      floatingActionButton: _getFab(),
    );
  }
}
