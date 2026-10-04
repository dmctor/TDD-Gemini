import '../contracts/logic.dart';
import '../models/invoice_item.dart';

class InvoicingSelectionImpl implements InvoicingSelection {
  @override
  Set<int> toggle(Set<int> selection, int index, List<InvoiceItem> services) {
    if (index < 0 || index >= services.length) {
      return selection;
    }

    final item = services[index];

    // RN-11: Los servicios facturados no se pueden seleccionar
    if (item.estado == InvoiceStatus.facturado) {
      return selection;
    }

    final nuevaSeleccion = Set<int>.from(selection);

    // Alternar seleccion
    if (nuevaSeleccion.contains(item.id)) {
      nuevaSeleccion.remove(item.id);
    } else {
      nuevaSeleccion.add(item.id);
    }

    return nuevaSeleccion;
  }

  /// RN-12: los servicios seleccionados pasan a facturado y la seleccion
  /// queda vacia. Un servicio ya facturado permanece facturado sin error y
  /// sin seleccion no se produce ningun cambio.
  @override
  List<InvoiceItem> confirm(Set<int> selection, List<InvoiceItem> services) {
    final actualizados = services
        .map((item) => selection.contains(item.id)
            ? item.copyWith(estado: InvoiceStatus.facturado)
            : item)
        .toList();

    selection.clear();
    return actualizados;
  }
}
