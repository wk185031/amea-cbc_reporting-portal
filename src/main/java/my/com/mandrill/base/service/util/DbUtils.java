package my.com.mandrill.base.service.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DbUtils {

	private static final Logger log = LoggerFactory.getLogger(DbUtils.class);

	public static void cleanDbResources(Connection conn, PreparedStatement ps, ResultSet rs) {
		try {
			if (ps != null) {
				ps.close();
			}
		} catch (SQLException e) {
			log.warn("Failed to close prepared statement", e);
		}

		try {
			if (rs != null) {
				rs.close();
			}
		} catch (SQLException e) {
			log.warn("Failed to close resultset", e);
		}

		try {
			if (conn != null) {
				conn.close();
			}
		} catch (Exception e) {
			log.warn("Failed to close db connection: ", e);
		}

	}
}
