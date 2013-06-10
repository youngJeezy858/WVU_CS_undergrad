package blah;

import java.sql.SQLException;

import oracle.jdbc.driver.OracleConnection;
import oracle.sql.CustomDatum;
import oracle.sql.CustomDatumFactory;
import oracle.sql.Datum;
import oracle.sql.STRUCT;
import oracle.sql.StructDescriptor;

public class Baseball implements CustomDatum, CustomDatumFactory {

	private String name;
	private int age;
	private int year;
	private char battingPref;
	private double battingAvg;

	public Baseball(String name, int age, int year, char battingPref,
			double battingAvg) {
		super();
		this.name = name;
		this.age = age;
		this.year = year;
		this.battingPref = battingPref;
		this.battingAvg = battingAvg;
	}

	public Object[] getObjArray() {
		return new Object[] { name, age, year, battingPref, battingAvg };
	}

	@Override
	public CustomDatum create(Datum arg0, int arg1) throws SQLException {
		Object[] attributes = ((STRUCT) arg0).getAttributes();
		return new Baseball((String) attributes[0], (Integer) attributes[1],
				(Integer) attributes[2], (Character) attributes[3],
				(Double) attributes[4]);
	}

	@Override
	public Datum toDatum(OracleConnection arg0) throws SQLException {
		StructDescriptor descriptor = new StructDescriptor("baseball_obj", arg0);
		return new STRUCT(descriptor, arg0, getObjArray());
	}

	public String toString() {
		return "NAME: " + name + "\nAGE: " + age + "\nYEAR: " + year
				+ "\nBATTING PREFERENCE: " + battingPref + "\nBATTING AVG: "
				+ battingAvg+ "\n\n";
	}

}
