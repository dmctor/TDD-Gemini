import 'package:flutter/material.dart';
import 'package:proveedify/domain/models/invoice_item.dart';
import 'package:proveedify/domain/models/invoice_period.dart';
import 'package:proveedify/pages/invoices/invoices_controller.dart';

class InvoicesPage extends StatelessWidget {
  final InvoicesController controller;

  const InvoicesPage({super.key, required this.controller});

  /// HU-06 criterio 4: se pide confirmacion explicita antes de facturar.
  Future<void> _solicitarConfirmacion(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar facturacion'),
        content: const Text('¿Desea facturar los servicios seleccionados?'),
        actions: [
          TextButton(
            key: const Key('btn_cancel_dialog_action'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: const Key('btn_confirm_dialog_action'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      await controller.confirmInvoicing();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = controller.items;
    final periodos = controller.availablePeriods;
    final periodoActivo = controller.activePeriod;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturacion de Servicios'),
        actions: [
          if (periodos.isNotEmpty)
            DropdownButton<InvoicePeriod>(
              value: periodoActivo,
              items: periodos.map((periodo) {
                return DropdownMenuItem<InvoicePeriod>(
                  value: periodo,
                  child: Text(periodo.label),
                );
              }).toList(),
              onChanged: (nuevoPeriodo) {
                if (nuevoPeriodo != null) {
                  controller.changePeriod(nuevoPeriodo);
                  controller.clearSelection();
                }
              },
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(
          key: const Key('btn_invoice_services'),
          onPressed: controller.selectedIds.isEmpty
              ? null
              : () => _solicitarConfirmacion(context),
          child: const Text('Facturar servicios seleccionados'),
        ),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text('No hay servicios disponibles'),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final esFacturado = item.estado == InvoiceStatus.facturado;
                final estaSeleccionado =
                    controller.selectedIds.contains(item.id);

                return ListTile(
                  title: Text(item.servicio),
                  subtitle: Text(
                    '${item.isp} - S/ ${item.monto.toStringAsFixed(2)} (${item.estado.name})',
                  ),
                  trailing: Checkbox(
                    value: estaSeleccionado,
                    onChanged: esFacturado
                        ? null
                        : (_) {
                            controller.toggleSelection(item.id);
                          },
                  ),
                  onTap: esFacturado
                      ? null
                      : () {
                          controller.toggleSelection(item.id);
                        },
                );
              },
            ),
    );
  }
}
