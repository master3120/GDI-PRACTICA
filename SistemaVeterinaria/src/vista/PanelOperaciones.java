package vista;

import dao.VeterinariaDAO;
import java.awt.*;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import javax.swing.*;
import javax.swing.border.TitledBorder;
import javax.swing.table.DefaultTableModel;

/**
 * Contiene los módulos CRUD operativos del sistema (Proveedores, Productos,
 * Órdenes de Compra y Facturas / Registro de Control) con borrado lógico.
 */
public class PanelOperaciones extends JTabbedPane {

    private final VeterinariaDAO dao = new VeterinariaDAO();

    // Componentes Proveedores
    private JTextField txtProvRuc, txtProvRazon, txtProvCorreo, txtProvCalle, txtProvNum, txtProvMz, txtProvLote, txtProvTel, txtProvBuscar;
    private JTable tblProveedores;

    // Componentes Productos
    private JTextField txtProdCod, txtProdNombre, txtProdDesc, txtProdStock, txtProdBuscar;
    private JComboBox<String> cboProdCat, cboProdPres, cboProdProv;
    private JTable tblProductos;

    // Componentes Órdenes
    private JComboBox<String> cboOrdProv, cboOrdProd;
    private JTextField txtOrdEmision, txtOrdEntrega, txtOrdCant, txtOrdPrecio;
    private DefaultTableModel modCarrito;
    private JTable tblOrdenes;

    // Componentes Facturas y Registro Control
    private JComboBox<String> cboFacProv, cboRcProd;
    private JTextField txtFacNum, txtFacOrden, txtFacPedido, txtFacGuia, txtFacVend, txtFacFecha, txtFacPago, txtFacTotal;
    private JTextField txtRcCant, txtRcFecha, txtRcPrecio;
    private JTable tblFacturas, tblRegistroControl;

    public PanelOperaciones() {
        addTab("1. Proveedores", crearPanelProveedores());
        addTab("2. Productos e Inventario", crearPanelProductos());
        addTab("3. Órdenes de Compra", crearPanelOrdenes());
        addTab("4. Facturas y Control de Ingresos", crearPanelFacturasYControl());
        cargarTodosLosDatos();
    }

    public void cargarTodosLosDatos() {
        cargarProveedores("");
        cargarCombosProducto();
        cargarProductos("");
        cargarOrdenes();
        cargarFacturasYControl();
    }

    // ==================== PESTAÑA 1: PROVEEDORES ====================
    private JPanel crearPanelProveedores() {
        JPanel panel = new JPanel(new BorderLayout(8, 8));
        panel.setBorder(BorderFactory.createEmptyBorder(8, 8, 8, 8));

        JPanel form = new JPanel(new GridLayout(4, 4, 6, 6));
        form.setBorder(new TitledBorder("Datos del Proveedor"));
        txtProvRuc = new JTextField();
        txtProvRazon = new JTextField();
        txtProvCorreo = new JTextField();
        txtProvCalle = new JTextField();
        txtProvNum = new JTextField();
        txtProvMz = new JTextField();
        txtProvLote = new JTextField();
        txtProvTel = new JTextField();

        form.add(new JLabel("RUC (11 dígitos):")); form.add(txtProvRuc);
        form.add(new JLabel("Razón Social:"));     form.add(txtProvRazon);
        form.add(new JLabel("Correo:"));           form.add(txtProvCorreo);
        form.add(new JLabel("Teléfono (9 díg.):"));form.add(txtProvTel);
        form.add(new JLabel("Calle / Av.:"));      form.add(txtProvCalle);
        form.add(new JLabel("Número:"));           form.add(txtProvNum);
        form.add(new JLabel("Manzana:"));          form.add(txtProvMz);
        form.add(new JLabel("Lote:"));             form.add(txtProvLote);

        JPanel botones = new JPanel(new FlowLayout(FlowLayout.LEFT));
        JButton btnNuevo = new JButton("Limpiar");
        JButton btnGuardar = new JButton("Registrar");
        JButton btnActualizar = new JButton("Modificar");
        JButton btnEliminar = new JButton("Dar de Baja (Borrado Lógico)");
        txtProvBuscar = new JTextField(15);
        JButton btnBuscar = new JButton("Buscar");

        botones.add(btnNuevo);
        botones.add(btnGuardar);
        botones.add(btnActualizar);
        botones.add(btnEliminar);
        botones.add(new JLabel("  |  Filtro:"));
        botones.add(txtProvBuscar);
        botones.add(btnBuscar);

        JPanel norte = new JPanel(new BorderLayout());
        norte.add(form, BorderLayout.CENTER);
        norte.add(botones, BorderLayout.SOUTH);

        tblProveedores = new JTable();
        tblProveedores.getSelectionModel().addListSelectionListener(e -> {
            int fila = tblProveedores.getSelectedRow();
            if (fila >= 0) {
                txtProvRuc.setText(tblProveedores.getValueAt(fila, 0).toString());
                txtProvRuc.setEditable(false);
                txtProvRazon.setText(tblProveedores.getValueAt(fila, 1).toString());
                txtProvCorreo.setText(tblProveedores.getValueAt(fila, 2).toString());
                txtProvCalle.setText(tblProveedores.getValueAt(fila, 3).toString());
                txtProvNum.setText(tblProveedores.getValueAt(fila, 4).toString());
                txtProvMz.setText(tblProveedores.getValueAt(fila, 5).toString());
                txtProvLote.setText(tblProveedores.getValueAt(fila, 6).toString());
            }
        });

        btnNuevo.addActionListener(e -> {
            txtProvRuc.setText(""); txtProvRuc.setEditable(true);
            txtProvRazon.setText(""); txtProvCorreo.setText("");
            txtProvCalle.setText(""); txtProvNum.setText("");
            txtProvMz.setText(""); txtProvLote.setText(""); txtProvTel.setText("");
        });

        btnGuardar.addActionListener(e -> {
            try {
                dao.insertarProveedor(txtProvRuc.getText().trim(), txtProvRazon.getText().trim(),
                        txtProvCorreo.getText().trim(), txtProvCalle.getText().trim(),
                        txtProvNum.getText().trim(), txtProvMz.getText().trim(),
                        txtProvLote.getText().trim(), txtProvTel.getText().trim());
                mostrarInfo("Proveedor registrado correctamente.");
                cargarTodosLosDatos();
            } catch (Exception ex) { mostrarError(ex.getMessage()); }
        });

        btnActualizar.addActionListener(e -> {
            try {
                dao.actualizarProveedor(txtProvRuc.getText().trim(), txtProvRazon.getText().trim(),
                        txtProvCorreo.getText().trim(), txtProvCalle.getText().trim(),
                        txtProvNum.getText().trim(), txtProvMz.getText().trim(),
                        txtProvLote.getText().trim());
                mostrarInfo("Proveedor modificado correctamente.");
                cargarTodosLosDatos();
            } catch (Exception ex) { mostrarError(ex.getMessage()); }
        });

        btnEliminar.addActionListener(e -> {
            String ruc = txtProvRuc.getText().trim();
            if (ruc.isEmpty()) { mostrarError("Seleccione un proveedor de la tabla."); return; }
            try {
                dao.eliminarLogicoProveedor(ruc);
                mostrarInfo("Proveedor dado de baja lógicamente (auditado en bitácora).");
                cargarTodosLosDatos();
            } catch (Exception ex) { mostrarError(ex.getMessage()); }
        });

        btnBuscar.addActionListener(e -> cargarProveedores(txtProvBuscar.getText().trim()));

        panel.add(norte, BorderLayout.NORTH);
        panel.add(new JScrollPane(tblProveedores), BorderLayout.CENTER);
        return panel;
    }

    private void cargarProveedores(String filtro) {
        try {
            tblProveedores.setModel(dao.ejecutarConsultaTabla("{call sp_listar_proveedores(?)}", filtro));
        } catch (Exception ex) { mostrarError(ex.getMessage()); }
    }

    // ==================== PESTAÑA 2: PRODUCTOS ====================
    private JPanel crearPanelProductos() {
        JPanel panel = new JPanel(new BorderLayout(8, 8));
        panel.setBorder(BorderFactory.createEmptyBorder(8, 8, 8, 8));

        JPanel form = new JPanel(new GridLayout(3, 4, 6, 6));
        form.setBorder(new TitledBorder("Catálogo de Productos Veterinarios"));
        txtProdCod = new JTextField(); txtProdCod.setEditable(false);
        txtProdNombre = new JTextField();
        txtProdDesc = new JTextField();
        txtProdStock = new JTextField("0");
        cboProdCat = new JComboBox<>();
        cboProdPres = new JComboBox<>();
        cboProdProv = new JComboBox<>();

        form.add(new JLabel("Código (Auto):"));     form.add(txtProdCod);
        form.add(new JLabel("Nombre Insumo:"));     form.add(txtProdNombre);
        form.add(new JLabel("Descripción:"));       form.add(txtProdDesc);
        form.add(new JLabel("Stock Disponible:"));  form.add(txtProdStock);
        form.add(new JLabel("Categoría:"));         form.add(cboProdCat);
        form.add(new JLabel("Presentación:"));      form.add(cboProdPres);

        JPanel extra = new JPanel(new FlowLayout(FlowLayout.LEFT));
        extra.add(new JLabel("Proveedor que lo suministra (al registrar):"));
        extra.add(cboProdProv);

        JPanel botones = new JPanel(new FlowLayout(FlowLayout.LEFT));
        JButton btnLimpiar = new JButton("Limpiar");
        JButton btnGuardar = new JButton("Registrar");
        JButton btnModificar = new JButton("Modificar");
        JButton btnBaja = new JButton("Dar de Baja (Borrado Lógico)");
        txtProdBuscar = new JTextField(15);
        JButton btnBuscar = new JButton("Buscar");

        botones.add(btnLimpiar); botones.add(btnGuardar); botones.add(btnModificar); botones.add(btnBaja);
        botones.add(new JLabel("  |  Buscar:")); botones.add(txtProdBuscar); botones.add(btnBuscar);

        JPanel norte = new JPanel(new BorderLayout());
        norte.add(form, BorderLayout.NORTH);
        norte.add(extra, BorderLayout.CENTER);
        norte.add(botones, BorderLayout.SOUTH);

        tblProductos = new JTable();
        tblProductos.getSelectionModel().addListSelectionListener(e -> {
            int f = tblProductos.getSelectedRow();
            if (f >= 0) {
                txtProdCod.setText(tblProductos.getValueAt(f, 0).toString());
                txtProdNombre.setText(tblProductos.getValueAt(f, 1).toString());
                txtProdDesc.setText(tblProductos.getValueAt(f, 2).toString());
                txtProdStock.setText(tblProductos.getValueAt(f, 3).toString());
                seleccionarComboPorId(cboProdCat, tblProductos.getValueAt(f, 4).toString());
                seleccionarComboPorId(cboProdPres, tblProductos.getValueAt(f, 6).toString());
            }
        });

        btnLimpiar.addActionListener(e -> {
            txtProdCod.setText(""); txtProdNombre.setText("");
            txtProdDesc.setText(""); txtProdStock.setText("0");
        });

        btnGuardar.addActionListener(e -> {
            try {
                int idCat = extraerIdCombo(cboProdCat);
                int idPres = extraerIdCombo(cboProdPres);
                String rucProv = cboProdProv.getSelectedItem().toString().split(" - ")[0];
                dao.insertarProducto(txtProdNombre.getText().trim(), txtProdDesc.getText().trim(),
                        Integer.parseInt(txtProdStock.getText().trim()), idCat, idPres, rucProv);
                mostrarInfo("Producto registrado y vinculado al proveedor.");
                cargarTodosLosDatos();
            } catch (Exception ex) { mostrarError(ex.getMessage()); }
        });

        btnModificar.addActionListener(e -> {
            try {
                int cod = Integer.parseInt(txtProdCod.getText().trim());
                dao.actualizarProducto(cod, txtProdNombre.getText().trim(), txtProdDesc.getText().trim(),
                        Integer.parseInt(txtProdStock.getText().trim()),
                        extraerIdCombo(cboProdCat), extraerIdCombo(cboProdPres));
                mostrarInfo("Producto actualizado.");
                cargarTodosLosDatos();
            } catch (Exception ex) { mostrarError(ex.getMessage()); }
        });

        btnBaja.addActionListener(e -> {
            try {
                int cod = Integer.parseInt(txtProdCod.getText().trim());
                dao.eliminarLogicoProducto(cod);
                mostrarInfo("Producto dado de baja lógicamente.");
                cargarTodosLosDatos();
            } catch (Exception ex) { mostrarError(ex.getMessage()); }
        });

        btnBuscar.addActionListener(e -> cargarProductos(txtProdBuscar.getText().trim()));

        panel.add(norte, BorderLayout.NORTH);
        panel.add(new JScrollPane(tblProductos), BorderLayout.CENTER);
        return panel;
    }

    private void cargarCombosProducto() {
        try {
            cboProdCat.removeAllItems();
            for (String[] item : dao.listarCombo("{call sp_listar_categorias()}")) {
                cboProdCat.addItem(item[0] + " - " + item[1]);
            }
            cboProdPres.removeAllItems();
            for (String[] item : dao.listarCombo("{call sp_listar_presentaciones()}")) {
                cboProdPres.addItem(item[0] + " - " + item[1]);
            }
            cboProdProv.removeAllItems();
            cboOrdProv.removeAllItems();
            cboFacProv.removeAllItems();
            DefaultTableModel modProv = dao.ejecutarConsultaTabla("{call sp_listar_proveedores(?)}", "");
            for (int i = 0; i < modProv.getRowCount(); i++) {
                String txt = modProv.getValueAt(i, 0) + " - " + modProv.getValueAt(i, 1);
                cboProdProv.addItem(txt);
                cboOrdProv.addItem(txt);
                cboFacProv.addItem(txt);
            }
        } catch (Exception ex) { mostrarError(ex.getMessage()); }
    }

    private void cargarProductos(String filtro) {
        try {
            tblProductos.setModel(dao.ejecutarConsultaTabla("{call sp_listar_productos(?)}", filtro));
        } catch (Exception ex) { mostrarError(ex.getMessage()); }
    }

    // ==================== PESTAÑA 3: ÓRDENES DE COMPRA ====================
    private JPanel crearPanelOrdenes() {
        JPanel panel = new JPanel(new BorderLayout(8, 8));
        panel.setBorder(BorderFactory.createEmptyBorder(8, 8, 8, 8));

        JPanel cabecera = new JPanel(new GridLayout(3, 4, 6, 6));
        cabecera.setBorder(new TitledBorder("Nueva Orden de Compra y Líneas de Detalle"));
        cboOrdProv = new JComboBox<>();
        cboOrdProd = new JComboBox<>();
        txtOrdEmision = new JTextField(LocalDate.now().toString());
        txtOrdEntrega = new JTextField();
        txtOrdCant = new JTextField("1");
        txtOrdPrecio = new JTextField("10.00");

        cabecera.add(new JLabel("Proveedor:"));             cabecera.add(cboOrdProv);
        cabecera.add(new JLabel("Fecha Emisión (AAAA-MM-DD):")); cabecera.add(txtOrdEmision);
        cabecera.add(new JLabel("Producto Suministrado:")); cabecera.add(cboOrdProd);
        cabecera.add(new JLabel("Entrega Est. (Opcional):"));    cabecera.add(txtOrdEntrega);
        cabecera.add(new JLabel("Cantidad Requerida:"));    cabecera.add(txtOrdCant);
        cabecera.add(new JLabel("Precio Unitario (S/):"));  cabecera.add(txtOrdPrecio);

        cboOrdProv.addActionListener(e -> {
            if (cboOrdProv.getSelectedItem() == null) return;
            String ruc = cboOrdProv.getSelectedItem().toString().split(" - ")[0];
            try {
                cboOrdProd.removeAllItems();
                for (String[] p : dao.listarCombo("{call sp_listar_productos_por_proveedor(?)}", ruc)) {
                    cboOrdProd.addItem(p[0] + " - " + p[1]);
                }
            } catch (Exception ex) { mostrarError(ex.getMessage()); }
        });

        modCarrito = new DefaultTableModel(new String[]{"Cód. Prod", "Producto", "Cantidad", "Precio Unit.", "Subtotal"}, 0);
        JTable tblCarrito = new JTable(modCarrito);

        JPanel btnsCarrito = new JPanel(new FlowLayout(FlowLayout.LEFT));
        JButton btnAddLinea = new JButton("+ Agregar Producto a la Orden");
        JButton btnEmitirOrden = new JButton("Registrar Orden Completa");
        JButton btnMarcarEntregada = new JButton("Registrar Entrega Hoy (Orden Seleccionada)");
        JButton btnAnularOrden = new JButton("Anular Orden (Borrado Lógico)");

        btnsCarrito.add(btnAddLinea);
        btnsCarrito.add(btnEmitirOrden);
        btnsCarrito.add(btnMarcarEntregada);
        btnsCarrito.add(btnAnularOrden);

        btnAddLinea.addActionListener(e -> {
            if (cboOrdProd.getSelectedItem() == null) {
                mostrarError("El proveedor seleccionado no tiene productos asociados.");
                return;
            }
            try {
                String[] partes = cboOrdProd.getSelectedItem().toString().split(" - ", 2);
                int codProd = Integer.parseInt(partes[0]);
                int cant = Integer.parseInt(txtOrdCant.getText().trim());
                BigDecimal precio = new BigDecimal(txtOrdPrecio.getText().trim());
                BigDecimal sub = precio.multiply(BigDecimal.valueOf(cant));
                modCarrito.addRow(new Object[]{codProd, partes[1], cant, precio, sub});
            } catch (Exception ex) { mostrarError("Verifique cantidad y precio numérico."); }
        });

        btnEmitirOrden.addActionListener(e -> {
            if (modCarrito.getRowCount() == 0) {
                mostrarError("Agregue al menos un producto al detalle de la orden.");
                return;
            }
            try {
                String ruc = cboOrdProv.getSelectedItem().toString().split(" - ")[0];
                Date fEmision = Date.valueOf(txtOrdEmision.getText().trim());
                Date fEntrega = txtOrdEntrega.getText().trim().isEmpty() ? null : Date.valueOf(txtOrdEntrega.getText().trim());

                List<Object[]> detalles = new ArrayList<>();
                for (int i = 0; i < modCarrito.getRowCount(); i++) {
                    detalles.add(new Object[]{
                        (Integer) modCarrito.getValueAt(i, 0),
                        (Integer) modCarrito.getValueAt(i, 2),
                        (BigDecimal) modCarrito.getValueAt(i, 3)
                    });
                }
                int nuevoId = dao.insertarOrdenConDetalles(ruc, fEmision, fEntrega, detalles);
                mostrarInfo("Orden de Compra N° " + nuevoId + " registrada con éxito.");
                modCarrito.setRowCount(0);
                cargarOrdenes();
            } catch (Exception ex) { mostrarError(ex.getMessage()); }
        });

        tblOrdenes = new JTable();

        btnMarcarEntregada.addActionListener(e -> {
            int f = tblOrdenes.getSelectedRow();
            if (f < 0) { mostrarError("Seleccione una orden en la tabla inferior."); return; }
            try {
                int codOrden = Integer.parseInt(tblOrdenes.getValueAt(f, 0).toString());
                dao.actualizarFechaEntregaOrden(codOrden, Date.valueOf(LocalDate.now()));
                mostrarInfo("Fecha de entrega actualizada a hoy.");
                cargarOrdenes();
            } catch (Exception ex) { mostrarError(ex.getMessage()); }
        });

        btnAnularOrden.addActionListener(e -> {
            int f = tblOrdenes.getSelectedRow();
            if (f < 0) { mostrarError("Seleccione una orden en la tabla inferior."); return; }
            try {
                int codOrden = Integer.parseInt(tblOrdenes.getValueAt(f, 0).toString());
                dao.eliminarLogicoOrden(codOrden);
                mostrarInfo("Orden de compra anulada (borrado lógico).");
                cargarOrdenes();
            } catch (Exception ex) { mostrarError(ex.getMessage()); }
        });

        JPanel centroSuperior = new JPanel(new BorderLayout());
        centroSuperior.add(cabecera, BorderLayout.NORTH);
        JScrollPane spCarrito = new JScrollPane(tblCarrito);
        spCarrito.setPreferredSize(new Dimension(600, 95));
        centroSuperior.add(spCarrito, BorderLayout.CENTER);
        centroSuperior.add(btnsCarrito, BorderLayout.SOUTH);

        panel.add(centroSuperior, BorderLayout.NORTH);
        panel.add(new JScrollPane(tblOrdenes), BorderLayout.CENTER);
        return panel;
    }

    private void cargarOrdenes() {
        try {
            tblOrdenes.setModel(dao.ejecutarConsultaTabla("{call sp_listar_ordenes()}"));
        } catch (Exception ex) { mostrarError(ex.getMessage()); }
    }

    // ==================== PESTAÑA 4: FACTURAS Y REGISTRO CONTROL ====================
    private JPanel crearPanelFacturasYControl() {
        JSplitPane split = new JSplitPane(JSplitPane.VERTICAL_SPLIT);
        split.setResizeWeight(0.5);

        // Panel Superior: Facturas Electrónicas
        JPanel pnlFac = new JPanel(new BorderLayout(5, 5));
        pnlFac.setBorder(new TitledBorder("Facturas Electrónicas (Trigger calcula IGV automático)"));
        JPanel frmFac = new JPanel(new GridLayout(3, 6, 4, 4));
        cboFacProv = new JComboBox<>();
        txtFacNum = new JTextField("F001-00019999");
        txtFacOrden = new JTextField("1");
        txtFacPedido = new JTextField("00009001");
        txtFacGuia = new JTextField("T001005001");
        txtFacVend = new JTextField("Vendedor Asignado");
        txtFacFecha = new JTextField(LocalDate.now().toString());
        txtFacPago = new JTextField("Contado");
        txtFacTotal = new JTextField("118.00");

        frmFac.add(new JLabel("Proveedor:")); frmFac.add(cboFacProv);
        frmFac.add(new JLabel("N° Factura:")); frmFac.add(txtFacNum);
        frmFac.add(new JLabel("Cód. Orden:")); frmFac.add(txtFacOrden);
        frmFac.add(new JLabel("N° Pedido:"));  frmFac.add(txtFacPedido);
        frmFac.add(new JLabel("N° Guía:"));    frmFac.add(txtFacGuia);
        frmFac.add(new JLabel("Vendedor:"));   frmFac.add(txtFacVend);
        frmFac.add(new JLabel("Fecha:"));      frmFac.add(txtFacFecha);
        frmFac.add(new JLabel("Cond. Pago:")); frmFac.add(txtFacPago);
        frmFac.add(new JLabel("Total S/:"));   frmFac.add(txtFacTotal);

        JPanel btnFac = new JPanel(new FlowLayout(FlowLayout.LEFT));
        JButton bRegFac = new JButton("Registrar Factura");
        JButton bDelFac = new JButton("Anular Factura (Borrado Lógico)");
        btnFac.add(bRegFac); btnFac.add(bDelFac);

        tblFacturas = new JTable();
        bRegFac.addActionListener(e -> {
            try {
                String ruc = cboFacProv.getSelectedItem().toString().split(" - ")[0];
                dao.insertarFactura(ruc, txtFacNum.getText().trim(), Integer.parseInt(txtFacOrden.getText().trim()),
                        txtFacPedido.getText().trim(), txtFacGuia.getText().trim(), txtFacVend.getText().trim(),
                        Date.valueOf(txtFacFecha.getText().trim()), txtFacPago.getText().trim(),
                        new BigDecimal(txtFacTotal.getText().trim()));
                mostrarInfo("Factura registrada (IGV calculado por trigger).");
                cargarFacturasYControl();
            } catch (Exception ex) { mostrarError(ex.getMessage()); }
        });

        bDelFac.addActionListener(e -> {
            int f = tblFacturas.getSelectedRow();
            if (f < 0) { mostrarError("Seleccione una factura."); return; }
            try {
                dao.eliminarLogicoFactura(tblFacturas.getValueAt(f, 1).toString(), tblFacturas.getValueAt(f, 0).toString());
                mostrarInfo("Factura anulada lógicamente.");
                cargarFacturasYControl();
            } catch (Exception ex) { mostrarError(ex.getMessage()); }
        });

        JPanel topFac = new JPanel(new BorderLayout());
        topFac.add(frmFac, BorderLayout.CENTER);
        topFac.add(btnFac, BorderLayout.SOUTH);
        pnlFac.add(topFac, BorderLayout.NORTH);
        pnlFac.add(new JScrollPane(tblFacturas), BorderLayout.CENTER);

        // Panel Inferior: Registro de Control (Trigger suma stock automáticamente)
        JPanel pnlRc = new JPanel(new BorderLayout(5, 5));
        pnlRc.setBorder(new TitledBorder("Registro de Control de Ingresos (Trigger actualiza Stock en Producto)"));
        JPanel frmRc = new JPanel(new FlowLayout(FlowLayout.LEFT));
        cboRcProd = new JComboBox<>();
        txtRcCant = new JTextField("5", 5);
        txtRcFecha = new JTextField(LocalDate.now().toString(), 9);
        txtRcPrecio = new JTextField("15.00", 7);
        JButton bRegRc = new JButton("Registrar Ingreso (+Stock)");
        JButton bDelRc = new JButton("Anular Ingreso (-Stock)");

        frmRc.add(new JLabel("Producto:")); frmRc.add(cboRcProd);
        frmRc.add(new JLabel("Cantidad:")); frmRc.add(txtRcCant);
        frmRc.add(new JLabel("Fecha:"));    frmRc.add(txtRcFecha);
        frmRc.add(new JLabel("Precio U.:"));frmRc.add(txtRcPrecio);
        frmRc.add(bRegRc); frmRc.add(bDelRc);

        tblRegistroControl = new JTable();
        bRegRc.addActionListener(e -> {
            try {
                int codProd = extraerIdCombo(cboRcProd);
                dao.insertarRegistroControl(codProd, Integer.parseInt(txtRcCant.getText().trim()),
                        Date.valueOf(txtRcFecha.getText().trim()), new BigDecimal(txtRcPrecio.getText().trim()));
                mostrarInfo("Ingreso registrado y stock incrementado automáticamente.");
                cargarTodosLosDatos();
            } catch (Exception ex) { mostrarError(ex.getMessage()); }
        });

        bDelRc.addActionListener(e -> {
            int f = tblRegistroControl.getSelectedRow();
            if (f < 0) { mostrarError("Seleccione una línea del registro de control."); return; }
            try {
                int linea = Integer.parseInt(tblRegistroControl.getValueAt(f, 0).toString());
                dao.eliminarLogicoRegistroControl(linea);
                mostrarInfo("Registro anulado y stock descontado automáticamente.");
                cargarTodosLosDatos();
            } catch (Exception ex) { mostrarError(ex.getMessage()); }
        });

        pnlRc.add(frmRc, BorderLayout.NORTH);
        pnlRc.add(new JScrollPane(tblRegistroControl), BorderLayout.CENTER);

        split.setTopComponent(pnlFac);
        split.setBottomComponent(pnlRc);

        JPanel contenedor = new JPanel(new BorderLayout());
        contenedor.add(split, BorderLayout.CENTER);
        return contenedor;
    }

    private void cargarFacturasYControl() {
        try {
            tblFacturas.setModel(dao.ejecutarConsultaTabla("{call sp_listar_facturas()}"));
            tblRegistroControl.setModel(dao.ejecutarConsultaTabla("{call sp_listar_registro_control()}"));
            cboRcProd.removeAllItems();
            DefaultTableModel modProd = dao.ejecutarConsultaTabla("{call sp_listar_productos(?)}", "");
            for (int i = 0; i < modProd.getRowCount(); i++) {
                cboRcProd.addItem(modProd.getValueAt(i, 0) + " - " + modProd.getValueAt(i, 1) + " (" + modProd.getValueAt(i, 7) + ")");
            }
        } catch (Exception ex) { mostrarError(ex.getMessage()); }
    }

    private int extraerIdCombo(JComboBox<String> combo) {
        return Integer.parseInt(combo.getSelectedItem().toString().split(" - ")[0]);
    }

    private void seleccionarComboPorId(JComboBox<String> combo, String id) {
        for (int i = 0; i < combo.getItemCount(); i++) {
            if (combo.getItemAt(i).startsWith(id + " - ")) {
                combo.setSelectedIndex(i);
                break;
            }
        }
    }

    private void mostrarInfo(String msg) {
        JOptionPane.showMessageDialog(this, msg, "Veterinaria Carlos Holguino", JOptionPane.INFORMATION_MESSAGE);
    }

    private void mostrarError(String msg) {
        JOptionPane.showMessageDialog(this, msg, "Error de Operación", JOptionPane.ERROR_MESSAGE);
    }
}
