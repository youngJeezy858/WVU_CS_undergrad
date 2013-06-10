package blah;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public abstract class JdbcDriver {

	protected Connection conn;

	public void run() throws SQLException, ClassNotFoundException {
		setConnection();
	}
	
	public JdbcDriver() {
		super();
	}
	

	protected void setConnection() throws ClassNotFoundException,
	SQLException {
		Class.forName("oracle.jdbc.OracleDriver");
		//DriverManager.registerDriver (new oracle.jdbc.driver.OracleDriver());
		conn = DriverManager.getConnection("jdbc:oracle:thin:@cs440.systems.wvu.edu:2222:cs440", "kfrank", "1234.yup");
	}
}
