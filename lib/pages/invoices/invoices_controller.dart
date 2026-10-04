import 'package:proveedify/domain/models/invoice_item.dart';
import 'package:proveedify/domain/models/invoice_period.dart';

abstract class InvoicesController {
  List<InvoiceItem> get items;
  Set<int> get selectedIds;
  List<InvoicePeriod> get availablePeriods;
  InvoicePeriod? get activePeriod;

  void toggleSelection(int serviceId);
  void changePeriod(InvoicePeriod period);
  void clearSelection();

  /// RN-12: aplica la facturacion de la seleccion. La pantalla la invoca solo
  /// despues de una confirmacion explicita del usuario.
  Future<bool> confirmInvoicing();
}
