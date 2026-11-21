package vista;

import dao.VeterinariaDAO;
import java.awt.*;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;

/**
 * Módulo de Consultas y Reportes Gerenciales. Ejecuta los 10 Procedimientos
 * Almacenados con cláusulas JOIN definidos en la base de datos.
 */
public class PanelReportes extends JPanel {

    private final VeterinariaDAO dao = new VeterinariaDAO();
    private final JComboBox<String> cboReportes;
    private final JLabel lblParametro;
    private final JTextField txtParametro;
    private final JTable tblResultados;
    private final JLabel lblEstado;

    public PanelReportes() {
        setLayout(new BorderLayout(10, 10));
        setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        String[] listaReportes = {
            "01. Productos con stock crítico (<= 10 unidades) [JOIN]",
            "02. Proveedores y teléfonos de un producto específico [JOIN]",
            "03. Productos con poco stock agrupados por proveedor [JOIN]",
            "04. Historial de precios de compra por código de producto [JOIN]",
            "05. Líneas de detalle de una Orden de Compra específica [JOIN]",
            "06. Órdenes de compra pendientes de entrega [JOIN]",
            "07. Tiempo de demora (días) de órdenes entregadas [JOIN]",
            "08. Auditoría de cuadre: Orden con IGV vs Factura Electrónica [JOIN]",
            "09. Órdenes ya entregadas sin factura registrada [JOIN]",
            "10. Ranking de monto total comprado por proveedor [JOIN]"
        };

        JPanel barraSuperior = new JPanel(new FlowLayout(FlowLayout.LEFT, 8, 5));
        cboReportes = new JComboBox<>(listaReportes);
        lblParametro = new JLabel("Parámetro:");
        txtParametro = new JTextField(12);
        JButton btnConsultar = new JButton("Ejecutar Procedimiento Almacenado");

        lblParametro.setVisible(false);
        txtParametro.setVisible(false);

        cboReportes.addActionListener(e -> actualizarVisibilidadParametro());
        btnConsultar.addActionListener(e -> ejecutarReporteSeleccionado());

        barraSuperior.add(new JLabel("Seleccione Reporte:"));
        barraSuperior.add(cboReportes);
        barraSuperior.add(lblParametro);
        barraSuperior.add(txtParametro);
        barraSuperior.add(btnConsultar);

        tblResultados = new JTable();
        lblEstado = new JLabel("Seleccione un reporte y presione 'Ejecutar Procedimiento Almacenado'.");

        add(barraSuperior, BorderLayout.NORTH);
        add(new JScrollPane(tblResultados), BorderLayout.CENTER);
        add(lblEstado, BorderLayout.SOUTH);

        ejecutarReporteSeleccionado();
    }

    private void actualizarVisibilidadParametro() {
        int idx = cboReportes.getSelectedIndex();
        if (idx == 1) {
            lblParametro.setText("Nombre producto:");
            txtParametro.setText("Ciclosan");
            lblParametro.setVisible(true);
            txtParametro.setVisible(true);
        } else if (idx == 3) {
            lblParametro.setText("Código producto:");
            txtParametro.setText("1");
            lblParametro.setVisible(true);
            txtParametro.setVisible(true);
        } else if (idx == 4) {
            lblParametro.setText("Código orden:");
            txtParametro.setText("1");
            lblParametro.setVisible(true);
            txtParametro.setVisible(true);
        } else {
            lblParametro.setVisible(false);
            txtParametro.setVisible(false);
        }
        revalidate();
        repaint();
    }

    private void ejecutarReporteSeleccionado() {
        int idx = cboReportes.getSelectedIndex();
        try {
            DefaultTableModel modelo;
            switch (idx) {
                case 0: modelo = dao.ejecutarConsultaTabla("{call sp_reporte_01_stock_critico()}"); break;
                case 1: modelo = dao.ejecutarConsultaTabla("{call sp_reporte_02_proveedores_producto(?)}", txtParametro.getText().trim()); break;
                case 2: modelo = dao.ejecutarConsultaTabla("{call sp_reporte_03_stock_bajo_por_proveedor()}"); break;
                case 3: modelo = dao.ejecutarConsultaTabla("{call sp_reporte_04_historial_precios(?)}", Integer.parseInt(txtParametro.getText().trim())); break;
                case 4: modelo = dao.ejecutarConsultaTabla("{call sp_reporte_05_detalle_orden(?)}", Integer.parseInt(txtParametro.getText().trim())); break;
                case 5: modelo = dao.ejecutarConsultaTabla("{call sp_reporte_06_ordenes_pendientes()}"); break;
                case 6: modelo = dao.ejecutarConsultaTabla("{call sp_reporte_07_tiempo_entrega_ordenes()}"); break;
                case 7: modelo = dao.ejecutarConsultaTabla("{call sp_reporte_08_cuadre_orden_factura()}"); break;
                case 8: modelo = dao.ejecutarConsultaTabla("{call sp_reporte_09_entregadas_sin_factura()}"); break;
                case 9: modelo = dao.ejecutarConsultaTabla("{call sp_reporte_10_monto_por_proveedor()}"); break;
                default: return;
            }
            tblResultados.setModel(modelo);
            lblEstado.setText("Registros encontrados: " + modelo.getRowCount());
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Error al ejecutar reporte: " + ex.getMessage(),
                    "Error", JOptionPane.ERROR_MESSAGE);
        }
    }
}
