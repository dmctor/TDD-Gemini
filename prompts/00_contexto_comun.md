# Contexto comun a todas las solicitudes

```
CONTEXTO DEL PROYECTO
- Stack: Flutter <version>, Dart <version>
- Librerias de prueba: flutter_test, mocktail, http (MockClient de package:http/testing.dart)
- Arquitectura por capas: presentacion / logica de negocio / datos
- Nombre del paquete: proveedify
- Estructura de carpetas:
  lib/core/                     Result, Formatters
  lib/models/entities/          entidades del dominio
  lib/domain/contracts/         interfaces de datos y de logica
  lib/domain/models/            FinancialItem, FinancialSummary, FilterCriteria,
                                ValidationResult, InvoiceItem
  lib/domain/logic/             implementaciones de la capa de logica
  lib/data/repositories/        implementaciones HTTP de los contratos
  lib/pages/<feature>/          controladores y pantallas
  test/                         replica la estructura de lib/

CONVENCIONES DE PRUEBA
- Patron Arrange-Act-Assert, con los comentarios // Arrange, // Act, // Assert
- Agrupacion con group() por regla de negocio
- Nombres de prueba que describen el comportamiento esperado, en espanol
- En la capa de logica se sustituyen los repositorios; en la capa de datos, el
  cliente HTTP; en la capa de presentacion, el controlador
- Ninguna prueba realiza solicitudes de red reales ni accede al sistema de archivos
- Los dobles de prueba se construyen con mocktail
```
