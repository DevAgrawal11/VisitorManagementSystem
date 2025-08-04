package com.verifyVisitor;

import java.sql.*;

public class DatabaseConnection {
    // Update with your actual SQL Server credentials and DB details
    private static final String DB_URL = "jdbc:sqlserver://10.80.50.153:1433;databaseName=helpdesk;encrypt=true;trustServerCertificate=true";
    private static final String DB_USER = "Intern"; 
    private static final String DB_PASSWORD = "Intern@2025"; 

    // Static method to get database connection
    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        // Load SQL Server JDBC driver
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

        // Return connection
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    // Method to close resources
    public static void closeResources(Connection conn, PreparedStatement stmt, ResultSet rs) {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Overloaded method without ResultSet
    public static void closeResources(Connection conn, PreparedStatement stmt) {
        closeResources(conn, stmt, null);
    }

    // Method to test database connection
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
