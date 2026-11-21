package conexion;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Gestiona la conexión nativa mediante JDBC hacia la base de datos MySQL
 * de la Veterinaria Carlos Holguino, sin el uso de frameworks ORM.
 */
public class ConexionBD {

    private static final String URL = "jdbc:mysql://localhost:3306/bd_veterinaria?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=America/Lima";
    private static String usuario = "root";
    private static String password = "";

    /**
     * Configura credenciales personalizadas en tiempo de ejecución si es necesario.
     * @param user Usuario de MySQL.
     * @param pass Contraseña de MySQL.
     */
    public static void configurarCredenciales(String user, String pass) {
        usuario = user;
        password = pass;
    }

    /**
     * Abre y retorna una nueva conexión activa con MySQL 8.0.
     * @return Objeto Connection activo.
     * @throws SQLException Si ocurre un error de red o credenciales inválidas.
     */
    public static Connection obtenerConexion() throws SQLException {
        return DriverManager.getConnection(URL, usuario, password);
    }
}
