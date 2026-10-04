/// Estado de un servicio dentro del periodo de facturacion.
enum InvoiceStatus { pendiente, facturado }

class InvoiceItem {
  final int id;
  final String servicio;
  final String isp;
  final double monto;
  final InvoiceStatus estado;

  const InvoiceItem({
    required this.id,
    required this.servicio,
    required this.isp,
    required this.monto,
    required this.estado,
  });

  InvoiceItem copyWith({InvoiceStatus? estado}) {
    return InvoiceItem(
      id: id,
      servicio: servicio,
      isp: isp,
      monto: monto,
      estado: estado ?? this.estado,
    );
  }
}
