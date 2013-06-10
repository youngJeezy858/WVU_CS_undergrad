package blah;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import oracle.sql.REF;
import oracle.sql.STRUCT;

public class Execution extends JdbcDriver {

	public Execution() throws ClassNotFoundException, SQLException {
		super();
	}

	public void clear() throws SQLException {
		Statement stmt = conn.createStatement();
		String sql = "drop table baseball_tab";
		stmt.executeUpdate(sql);
	}

	public void prob1() throws SQLException {
		Statement stmt = conn.createStatement();
		String sql = "create or replace type baseball_obj as object (name varchar2(40), "
				+ "age number, year number, battingPref char(1), battingAvg binary_double)";
		stmt.executeUpdate(sql);
	}

	public void prob2() throws SQLException {
		Statement stmt = conn.createStatement();
		String sql = "create table baseball_tab of baseball_obj";
		stmt.executeUpdate(sql);
	}

	public void prob3() throws SQLException {
		Statement stmt = conn.createStatement();
		String sql = "insert into baseball_tab select name, age, year, battingpref, "
				+ "	battingaverage from ramorehead.MLB";
		stmt.executeUpdate(sql);
	}

	public Baseball prob4(String name, int year) throws SQLException {
		Baseball baseball = null;
		Statement stmt = conn.createStatement();
		ResultSet rs = stmt
				.executeQuery("select ref(p) from baseball_tab p where upper(name)='"
						+ name.toUpperCase() + "' and year=" + year);
		if (rs.next()) {
			REF ref = (REF)rs.getObject(1);
			STRUCT results = (STRUCT) ref.getValue();
			Object[] obj = results.getAttributes();
			BigDecimal tAge = (BigDecimal)obj[1];
			BigDecimal tYear = (BigDecimal)obj[2];
			String tBP = (String)obj[3];
			baseball = new Baseball((String)obj[0], tAge.intValue(), tYear.intValue(),
					tBP.charAt(0), (Double)obj[4]);
		}
		return baseball;
	}

	public void prob5() throws SQLException {
		Baseball baseball = prob4("Ty Cobb ", 1922);
		System.out.println(baseball.toString());
	}

	public Baseball[] prob6(int n) throws SQLException {
		Baseball[] baseball = new Baseball[n];
		Statement stmt = conn.createStatement();
		ResultSet rs = stmt
				.executeQuery("with t as (select name, age, year, battingPref, battingAvg, " +
						"rank() over (order by battingAvg desc) r from baseball_tab) "
						+ "select name, age, year, battingPref, battingAvg from t where r <=" + n);
		int i = 0;
		while (rs.next() && rs != null) {
			baseball[i] = new Baseball(rs.getString(1), rs.getInt(2), rs.getInt(3), 
					rs.getString(4).charAt(0), rs.getDouble(5));
			i++;
		}
		return baseball;
	}

	public void prob7() throws SQLException {
		Baseball[] baseball = prob6(10);
		for (Baseball b : baseball) {
			System.out.println(b.toString());
		}
	}

	public void run() throws ClassNotFoundException, SQLException {
		super.run();
		clear();
		prob1();
		prob2();
		prob3();
		prob5();
		prob7();
		conn.close();
	}

	public static void main(String[] args) throws SQLException,
			ClassNotFoundException {
		new Execution().run();
	}
}
