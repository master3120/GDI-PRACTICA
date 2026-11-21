package app;

import conexion.ConexionBD;
import java.awt.BorderLayout;
import java.sql.Connection;
import javax.swing.*;
import vista.PanelOperaciones;
import vista.PanelReportes;

/**
 * Clase principal del Aplicativo Cliente Nativo (Java Swing + JDBC)
 * para la gestión de Órdenes de Compra de la Veterinaria Carlos Holguino.
 */
public class MainApp extends JFrame {

    public MainApp() {
        setTitle("Sistema de Gestión de Órdenes de Compra - Veterinaria Carlos Holguino");
        setSize(1080, 680);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        JTabbedPane pestanasPrincipales = new JTabbedPane();
        PanelOperaciones pnlOp = new PanelOperaciones();
        PanelReportes pnlRep = new PanelReportes();

        pestanasPrincipales.addTab("Mantenimiento y Operaciones (CRUD)", pnlOp);
        pestanasPrincipales.addTab("Consultas y Reportes (10 SP con JOIN)", pnlRep);

        pestanasPrincipales.addChangeListener(e -> {
            if (pestanasPrincipales.getSelectedIndex() == 0) {
                pnlOp.cargarTodosLosDatos();
            }
        });

        add(pestanasPrincipales, BorderLayout.CENTER);
    }

    public static void main(String[] args) {
        try {
            UIManager.setLookAndFeel("javax.swing.plaf.nimbus.NimbusLookAndFeel");
        } catch (Exception ignored) { }

        // Solicita credenciales de MySQL al iniciar para evitar contraseñas fijas en distintos equipos
        JTextField txtUser = new JTextField("root");
        JPasswordField txtPass = new JPasswordField();
        Object[] campos = {"Usuario MySQL:", txtUser, "Contraseña MySQL:", txtPass};

        int opcion = JOptionPane.showConfirmDialog(null, campos,
                "Conexión Nativa JDBC - bd_veterinaria", JOptionPane.OK_CANCEL_OPTION);

        if (opcion == JOptionPane.OK_OPTION) {
            ConexionBD.configurarCredenciales(txtUser.getText().trim(), new String(txtPass.getPassword()));
            try (Connection cn = ConexionBD.obtenerConexion()) {
                SwingUtilities.invokeLater(() -> new MainApp().setVisible(true));
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(null,
                        "No se pudo conectar a bd_veterinaria:\n" + ex.getMessage(),
                        "Error de Conexión JDBC", JOptionPane.ERROR_MESSAGE);
            }
        }
    }
}
