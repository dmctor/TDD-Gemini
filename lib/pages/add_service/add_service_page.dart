import 'package:flutter/material.dart';

import 'add_service_controller.dart';

class AddServicePage extends StatefulWidget {
  final AddServiceController controller;

  const AddServicePage({super.key, required this.controller});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _payCodeController = TextEditingController();
  int? _ispId;
  bool _registered = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    _payCodeController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final ok = await widget.controller.submit(
      description: _descriptionController.text,
      price: _priceController.text,
      payCode: _payCodeController.text,
      ispId: _ispId,
    );
    if (!mounted) return;
    setState(() {
      _registered = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final errors = widget.controller.fieldErrors;
    final errorMessage = widget.controller.errorMessage;
    final options = widget.controller.ispOptions;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar servicio ISP')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('add_service_description_field'),
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripcion',
                errorText: errors['description'],
              ),
            ),
            TextField(
              key: const Key('add_service_price_field'),
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Precio',
                errorText: errors['price'],
              ),
            ),
            TextField(
              key: const Key('add_service_paycode_field'),
              controller: _payCodeController,
              decoration: InputDecoration(
                labelText: 'Codigo de pago',
                errorText: errors['payCode'],
              ),
            ),
            DropdownButtonFormField<int>(
              key: const Key('add_service_isp_field'),
              value: _ispId,
              decoration: InputDecoration(
                labelText: 'Operador',
                errorText: errors['ispId'],
              ),
              items: options.entries
                  .map((e) => DropdownMenuItem<int>(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _ispId = value),
            ),
            const SizedBox(height: 16),
            if (errorMessage != null)
              Text(
                errorMessage,
                key: const Key('add_service_error_message'),
                style: const TextStyle(color: Colors.red),
              ),
            if (_registered)
              const Text(
                'Servicio registrado correctamente',
                key: Key('add_service_success_message'),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('add_service_submit_button'),
              onPressed: _onSubmit,
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
