import '../../models/entities/invoice.dart';
import '../../models/entities/isp_service.dart';
import '../contracts/logic.dart';
import '../models/invoice_item.dart';

class InvoiceItemMapperImpl implements InvoiceItemMapper {
  @override
  List<InvoiceItem> map({
    required List<Invoice> invoices,
    required List<IspService> services,
    Map<int, String>? ispNames,
  }) {
    final List<InvoiceItem> resultado = [];

    for (final factura in invoices) {
      // Buscar el servicio correspondiente (RN-04)
      IspService? servicioEncontrado;
      for (final s in services) {
        if (s.id == factura.serviceId) {
          servicioEncontrado = s;
          break;
        }
      }

      // Si no existe en la lista, se omite
      if (servicioEncontrado == null) {
        continue;
      }

      // Determinar nombre del operador
      final nombreIsp =
          ispNames != null && ispNames.containsKey(servicioEncontrado.ispId)
              ? ispNames[servicioEncontrado.ispId]!
              : 'Desconocido';

      // Estado pendiente o facturado (Criterio 7)
      final estado = factura.estaFacturada
          ? InvoiceStatus.facturado
          : InvoiceStatus.pendiente;

      resultado.add(
        InvoiceItem(
          id: int.tryParse(factura.id) ?? 0,
          servicio: servicioEncontrado.descripcion,
          isp: nombreIsp,
          monto: servicioEncontrado.monto,
          estado: estado,
        ),
      );
    }

    return resultado;
  }
}
