# GDI-PRACTICA
codigo y funcionamiento del aplicativo
# VetCompras — Sistema de Gestión de Órdenes de Compra
**Entidad Beneficiaria:** Veterinaria Carlos Holguino (RUC: `10248901743`) — Arequipa, Perú  
**Autor:** Sebastián Alberto Arestegui Condori (Grupo 02)  
**Curso:** Gestión de Datos e Información — Universidad Católica de Santa María (UCSM)

---

## Descripción General
**VetCompras** es un aplicativo de escritorio bajo arquitectura **Cliente-Servidor de dos capas**, desarrollado en **Java SE (Swing + JDBC nativo)** sin frameworks ORM, conectado a una base de datos relacional en **MySQL 8.0**. 

Automatiza el ciclo de abastecimiento de insumos veterinarios: mantenimiento de proveedores y productos, emisión de órdenes de compra, validación de facturas electrónicas, control de ingresos de stock y reportes analíticos.

---

## Estructura del Repositorio

* **`mysqlworkbrench/`** *(Capa de Datos — Backend MySQL 8.0)*
  * `01_crear_base_de_datos.sql`: Crea la base `bd_veterinaria` con sus **12 tablas en 3FN**, soporte para **borrado lógico** (`activo = 1`) y la tabla `bitacora_bajas`.
  * `02_triggers_y_procedimientos.sql`: Implementa **6 Triggers** automáticos (control de stock, cálculo de IGV, validación de suministro y auditoría) y **32 Procedimientos Almacenados** (22 CRUD + 10 Reportes con `JOIN`).
  * `03_insertar_datos.sql`: Carga datos iniciales y registros de prueba de la veterinaria.

* **`SistemaVeterinaria/`** *(Capa Cliente — Frontend Java SE)*
  * `src/conexion/`: Clase `ConexionBD.java` (conexión nativa JDBC en `localhost:3306`).
  * `src/dao/`: Clase `VeterinariaDAO.java` (invocación exclusiva de procedimientos mediante `CallableStatement`).
  * `src/vista/`: Interfaces gráficas en Java Swing (`PanelOperaciones.java` y `PanelReportes.java`).
  * `src/app/`: Clase principal `MainApp.java`.
  * `lib/`: Driver oficial `mysql-connector-j-26.10.0.jar`.
  * `SistemaVeterinaria.jar`: Ejecutable compilado listo para usar.

---

## Instrucciones de Instalación y Ejecución

### Paso 1: Configurar la Base de Datos
1. Abrir **MySQL Workbench** (MySQL Server 8.0+).
2. Ejecutar los scripts de la carpeta `mysqlworkbrench/` en orden estricto:
   1. `01_crear_base_de_datos.sql`
   2. `02_triggers_y_procedimientos.sql`
   3. `03_insertar_datos.sql`

### Paso 2: Ejecutar el Aplicativo
1. Verificar tener instalado **Java JDK/JRE 17 o superior**.
2. Abrir una terminal dentro de la carpeta `SistemaVeterinaria/` y ejecutar:
   ```bash
   java -cp "SistemaVeterinaria.jar;lib\mysql-connector-j-26.10.0.jar" app.MainApp
   ```
3. Ingresar las credenciales de acceso en la ventana inicial:
   * **Host / Puerto:** `localhost:3306`
   * **Base de datos:** `bd_veterinaria`
   * **Usuario:** `root` *(o usuario configurado en MySQL)*
