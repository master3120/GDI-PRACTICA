package dao;

import conexion.ConexionBD;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.swing.table.DefaultTableModel;

/**
 * Capa de acceso a datos (DAO) que interactúa con MySQL exclusivamente
 * mediante llamadas nativas a Procedimientos Almacenados (CallableStatement).
 */
public class VeterinariaDAO {

    /**
     * Ejecuta cualquier procedimiento almacenado de consulta o reporte y convierte
     * dinámicamente el ResultSet en un modelo listo para JTable.
     * @param llamadaSql Sentencia CALL con marcadores de posición.
     * @param parametros Parámetros de entrada opcionales.
     * @return DefaultTableModel con columnas y filas obtenidas.
     * @throws SQLException Si falla la ejecución en base de datos.
     */
    public DefaultTableModel ejecutarConsultaTabla(String llamadaSql, Object... parametros) throws SQLException {
        DefaultTableModel modelo = new DefaultTableModel() {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };

        try (Connection cn = ConexionBD.obtenerConexion();
             CallableStatement cs = cn.prepareCall(llamadaSql)) {

            for (int i = 0; i < parametros.length; i++) {
                cs.setObject(i + 1, parametros[i]);
            }

            try (ResultSet rs = cs.executeQuery()) {
                ResultSetMetaData meta = rs.getMetaData();
                int columnas = meta.getColumnCount();

                for (int c = 1; c <= columnas; c++) {
                    modelo.addColumn(meta.getColumnLabel(c));
                }

                while (rs.next()) {
                    Object[] fila = new Object[columnas];
                    for (int c = 1; c <= columnas; c++) {
                        fila[c - 1] = rs.getObject(c);
                    }
                    modelo.addRow(fila);
                }
            }
        }
        return modelo;
    }

    /**
     * Obtiene pares clave-valor (ID - Descripción) para poblar componentes JComboBox.
     */
    public List<String[]> listarCombo(String llamadaSql, Object... parametros) throws SQLException {
        List<String[]> lista = new ArrayList<>();
        try (Connection cn = ConexionBD.obtenerConexion();
             CallableStatement cs = cn.prepareCall(llamadaSql)) {
            for (int i = 0; i < parametros.length; i++) {
                cs.setObject(i + 1, parametros[i]);
            }
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    lista.add(new String[]{rs.getString(1), rs.getString(2)});
                }
            }
        }
        return lista;
    }

    // ==================== CRUD PROVEEDOR ====================

    public void insertarProveedor(String ruc, String razon, String correo, String calle,
                                  String numero, String mz, String lote, String tel) throws SQLException {
        try (Connection cn = ConexionBD.obtenerConexion();
             CallableStatement cs = cn.prepareCall("{call sp_insertar_proveedor(?,?,?,?,?,?,?,?)}")) {
            cs.setString(1, ruc);
            cs.setString(2, razon);
            cs.setString(3, correo);
            cs.setString(4, calle);
            cs.setString(5, numero);
            cs.setString(6, mz);
            cs.setString(7, lote);
            cs.setString(8, tel);
            cs.executeUpdate();
        }
    }

    public void actualizarProveedor(String ruc, String razon, String correo, String calle,
                                    String numero, String mz, String lote) throws SQLException {
        try (Connection cn = ConexionBD.obtenerConexion();
             CallableStatement cs = cn.prepareCall("{call sp_actualizar_proveedor(?,?,?,?,?,?,?)}")) {
            cs.setString(1, ruc);
            cs.setString(2, razon);
            cs.setString(3, correo);
            cs.setString(4, calle);
            cs.setString(5, numero);
            cs.setString(6, mz);
            cs.setString(7, lote);
            cs.executeUpdate();
        }
    }

    public void eliminarLogicoProveedor(String ruc) throws SQLException {
        try (Connection cn = ConexionBD.obtenerConexion();
             CallableStatement cs = cn.prepareCall("{call sp_eliminar_logico_proveedor(?)}")) {
            cs.setString(1, ruc);
            cs.executeUpdate();
        }
    }

    // ==================== CRUD PRODUCTO ====================

    public void insertarProducto(String nombre, String desc, int stock, int idCat,
                                 int idPres, String rucProv) throws SQLException {
        try (Connection cn = ConexionBD.obtenerConexion();
             CallableStatement cs = cn.prepareCall("{call sp_insertar_producto(?,?,?,?,?,?)}")) {
            cs.setString(1, nombre);
            cs.setString(2, desc);
            cs.setInt(3, stock);
            cs.setInt(4, idCat);
            cs.setInt(5, idPres);
            cs.setString(6, rucProv);
            cs.executeUpdate();
        }
    }

    public void actualizarProducto(int codigo, String nombre, String desc, int stock,
                                   int idCat, int idPres) throws SQLException {
        try (Connection cn = ConexionBD.obtenerConexion();
             CallableStatement cs = cn.prepareCall("{call sp_actualizar_producto(?,?,?,?,?,?)}")) {
            cs.setInt(1, codigo);
            cs.setString(2, nombre);
            cs.setString(3, desc);
            cs.setInt(4, stock);
            cs.setInt(5, idCat);
            cs.setInt(6, idPres);
            cs.executeUpdate();
        }
    }

    public void eliminarLogicoProducto(int codigo) throws SQLException {
        try (Connection cn = ConexionBD.obtenerConexion();
             CallableStatement cs = cn.prepareCall("{call sp_eliminar_logico_producto(?)}")) {
            cs.setInt(1, codigo);
            cs.executeUpdate();
        }
    }

    // ==================== CRUD ORDEN DE COMPRA Y DETALLE ====================

    public int insertarOrdenConDetalles(String rucProveedor, Date fechaEmision, Date fechaEntrega,
                                        List<Object[]> lineasDetalle) throws SQLException {
        Connection cn = null;
        try {
            cn = ConexionBD.obtenerConexion();
            cn.setAutoCommit(false);

            int codigoGenerado;
            try (CallableStatement csOrden = cn.prepareCall("{call sp_insertar_orden_compra(?,?,?,?)}")) {
                csOrden.setString(1, rucProveedor);
                csOrden.setDate(2, fechaEmision);
                if (fechaEntrega != null) {
                    csOrden.setDate(3, fechaEntrega);
                } else {
                    csOrden.setNull(3, Types.DATE);
                }
                csOrden.registerOutParameter(4, Types.INTEGER);
                csOrden.executeUpdate();
                codigoGenerado = csOrden.getInt(4);
            }

            try (CallableStatement csDet = cn.prepareCall("{call sp_insertar_detalle_orden(?,?,?,?,?)}")) {
                int numLinea = 1;
                for (Object[] item : lineasDetalle) {
                    csDet.setInt(1, codigoGenerado);
                    csDet.setInt(2, numLinea++);
                    csDet.setInt(3, (Integer) item[0]);
                    csDet.setInt(4, (Integer) item[1]);
                    csDet.setBigDecimal(5, (BigDecimal) item[2]);
                    csDet.executeUpdate();
                }
            }

            cn.commit();
            return codigoGenerado;
        } catch (SQLException ex) {
            if (cn != null) cn.rollback();
            throw ex;
        } finally {
            if (cn != null) {
                cn.setAutoCommit(true);
                cn.close();
            }
        }
    }

    public void actualizarFechaEntregaOrden(int codigoOrden, Date fechaEntrega) throws SQLException {
        try (Connection cn = ConexionBD.obtenerConexion();
             CallableStatement cs = cn.prepareCall("{call sp_actualizar_fecha_entrega_orden(?,?)}")) {
            cs.setInt(1, codigoOrden);
            cs.setDate(2, fechaEntrega);
            cs.executeUpdate();
        }
    }

    public void eliminarLogicoOrden(int codigoOrden) throws SQLException {
        try (Connection cn = ConexionBD.obtenerConexion();
             CallableStatement cs = cn.prepareCall("{call sp_eliminar_logico_orden(?)}")) {
            cs.setInt(1, codigoOrden);
            cs.executeUpdate();
        }
    }

    // ==================== CRUD FACTURA Y REGISTRO DE CONTROL ====================

    public void insertarFactura(String rucProv, String numFactura, int codOrden, String numPedido,
                                String numGuia, String vendedor, Date fecha, String condPago,
                                BigDecimal total) throws SQLException {
        try (Connection cn = ConexionBD.obtenerConexion();
             CallableStatement cs = cn.prepareCall("{call sp_insertar_factura(?,?,?,?,?,?,?,?,?)}")) {
            cs.setString(1, rucProv);
            cs.setString(2, numFactura);
            cs.setInt(3, codOrden);
            cs.setString(4, numPedido);
            cs.setString(5, numGuia);
            cs.setString(6, vendedor);
            cs.setDate(7, fecha);
            cs.setString(8, condPago);
            cs.setBigDecimal(9, total);
            cs.executeUpdate();
        }
    }

    public void eliminarLogicoFactura(String rucProv, String numFactura) throws SQLException {
        try (Connection cn = ConexionBD.obtenerConexion();
             CallableStatement cs = cn.prepareCall("{call sp_eliminar_logico_factura(?,?)}")) {
            cs.setString(1, rucProv);
            cs.setString(2, numFactura);
            cs.executeUpdate();
        }
    }

    public void insertarRegistroControl(int codProducto, int cantidad, Date fecha,
                                        BigDecimal precioUnit) throws SQLException {
        try (Connection cn = ConexionBD.obtenerConexion();
             CallableStatement cs = cn.prepareCall("{call sp_insertar_registro_control(?,?,?,?)}")) {
            cs.setInt(1, codProducto);
            cs.setInt(2, cantidad);
            cs.setDate(3, fecha);
            cs.setBigDecimal(4, precioUnit);
            cs.executeUpdate();
        }
    }

    public void eliminarLogicoRegistroControl(int numLinea) throws SQLException {
        try (Connection cn = ConexionBD.obtenerConexion();
             CallableStatement cs = cn.prepareCall("{call sp_eliminar_logico_registro_control(?)}")) {
            cs.setInt(1, numLinea);
            cs.executeUpdate();
        }
    }
}
