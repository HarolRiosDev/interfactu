import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Importa dart:convert para manejar base64
import 'config.dart'; // Importa el archivo de configuración
import 'package:intl/intl.dart'; // Importa intl para formatear números

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Facturas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Registro de Facturas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nifEmisorController = TextEditingController();
  final TextEditingController _numeroFacturaController = TextEditingController();
  final TextEditingController _fechaEmisionController = TextEditingController();
  final TextEditingController _nifDestinatarioController = TextEditingController();
  final TextEditingController _nombreDestinatarioController = TextEditingController();
  final TextEditingController _ivaController = TextEditingController();
  final TextEditingController _importeController = TextEditingController();
  String? _qrImageBase64;
  String? _qrContent;
  bool _isTestMode = false;

  Future<void> nback(Map<String, String> formData) async {
    final url = Uri.parse(Config.endpointUrl).replace(queryParameters: formData);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _qrImageBase64 = base64Encode(response.bodyBytes); // Convierte la respuesta en base64
      });
    } else {
      _showErrorDialog();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _fechaEmisionController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _generateTestValues() {
    final now = DateTime.now();
    _nifEmisorController.text = 'A12345678';
    _numeroFacturaController.text = 'FACT-${now.hour}${now.minute}${now.second}';
    _fechaEmisionController.text = DateFormat('yyyy-MM-dd').format(now);
    _nifDestinatarioController.text = 'B87654321';
    _nombreDestinatarioController.text = 'Test Destinatario';
    _ivaController.text = '21';
    _importeController.text = '1000';
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Oops, algo ha ido mal.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white), // Cambia el color a blanco
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(_isTestMode ? Icons.toggle_on : Icons.toggle_off),
            onPressed: () {
              setState(() {
                _isTestMode = !_isTestMode;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Añade margen horizontal
          child: isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildFormCard(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildQrCard(),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormCard(),
                    const SizedBox(height: 16),
                    _buildQrCard(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 50.0), // Añade margen horizontal
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Center(
                child: Text(
                  'Datos de la Factura',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nifEmisorController,
                decoration: const InputDecoration(
                  labelText: 'NIF Emisor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el NIF del emisor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numeroFacturaController,
                decoration: const InputDecoration(
                  labelText: 'Número de Factura',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el número de factura';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaEmisionController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Emisión',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la fecha de emisión';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nifDestinatarioController,
                decoration: const InputDecoration(
                  labelText: 'NIF Destinatario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el NIF del destinatario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreDestinatarioController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Destinatario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre del destinatario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ivaController,
                decoration: const InputDecoration(
                  labelText: 'IVA',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}$')),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _importeController,
                decoration: const InputDecoration(
                  labelText: 'Importe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.\,]?\d*')),
                ],
              ),
              const SizedBox(height: 20),
              if (_isTestMode)
                Center(
                  child: ElevatedButton(
                    onPressed: _generateTestValues,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text(
                      'Generar Valores de Prueba',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final formData = {
                              'nifEmisor': _nifEmisorController.text,
                              'InvoiceName': _numeroFacturaController.text,//numeroFactura
                              'fechaEmision': _fechaEmisionController.text,
                              'nifDestinatario': _nifDestinatarioController.text,
                              'nombreDestinatario': _nombreDestinatarioController.text,
                              'Rate': _ivaController.text,//iva
                              'Base': _importeController.text,//importe
                            };
                      nback(formData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Procesando datos')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text(
                    'Enviar',
                    style: TextStyle(color: Colors.white), // Cambia el color a blanco
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0), // Añade margen horizontal
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _qrImageBase64 != null
            ? Column(
                children: [
                  Image.memory(
                    base64Decode(_qrImageBase64!),
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Error al cargar la imagen');
                    },
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 8),
                  Text(
                    _qrContent ?? '',
                    style: const TextStyle(color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : const Center(
                child: Text('La imagen del QR se mostrará aquí'),
              ),
      ),
    );
  }
}