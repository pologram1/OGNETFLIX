//This class belongs to the ut package
package ut;

//Import the java.sql package for managing the ResulSet objects
import java.sql.* ;

/******
	This class manage a connection to the og_netflix database and it should not be accessed from the front End.
*/
public class MySQLCompleteConnector{

	//Database credential <jdbc:<protocol>://<hostName>/<databaseName>>
	private String DB_URL=System.getenv("OGNETFLIX_DB_URL");
	
	//Database authorized user information
	private String USER=System.getenv("OGNETFLIX_DB_USER");
	private String PASS=System.getenv("OGNETFLIX_DB_PASSWORD");
   
   //Connection objects
   private Connection conn;
   
   //Statement object to perform queries and transations on the database
   private Statement stmt;
   
	/********
		Default constructor
		@parameters:
		
	*/
	public MySQLCompleteConnector()
	{
		//define connections ojects null
		conn = null;
		stmt = null;}
		
	/********
		doConnection method
			It creates a new connection object and open a connection to the database
			@parameters:

	*/		
	public void doConnection(){
		try{
		  //Register JDBC the driver
		  Class.forName("com.mysql.cj.jdbc.Driver");

								   
		  System.out.println("Connecting to database...");
		   //Open a connection using the database credentials
		  conn = DriverManager.getConnection(DB_URL, USER, PASS);
		  
		  System.out.println("Creating statement...");
		  //Create an Statement object for performing queries and transations
		  stmt = conn.createStatement();
		  System.out.println("Statement Ok...");
		} catch(SQLException sqlex){
			sqlex.printStackTrace();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	
	
	/********
		closeConnection method
			Close the connection to the database
			@parameters:

	*/		
	public void closeConnection()
	{
		try{
			//close the statement object
			stmt.close();
			//close the connection to the database
			conn.close();
			}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	
	
	
	
	
	
	/***********
		doSelect method
			This method performs a query to the database
			@parameters:
				fields: list of fields to be projected from the tables
				tables: list of tables to be selected
				where: where clause
			@returns:
				ResulSet result containing the project tuples resulting from the query
	*/
	public ResultSet doSelect(String fields, String tables, String where){
		//Create a ResulSet
		ResultSet result=null;
		
		//Create the selection statement 
		String selectionStatement = "Select " + fields+ " from " + tables + " where " + where + " ;";
		System.out.println(selectionStatement);
		
		try{
			//perform the query and catch results in the result object
			result = stmt.executeQuery(selectionStatement);
		} catch(Exception e){
			e.printStackTrace();
		}
		finally{
			//return results
			return result;
		}
	}
	
	
	
	
	
/***********
	doSelect method
		This method performs a query to the database
		@parameters:
			fields: list of fields to be projected from the tables
			tables: list of tables to be selected
		@returns:
			ResulSet result containing the project tuples resulting from the query
	*/
	
	public ResultSet doSelect(String fields, String tables){
		//Create a ResulSet
		ResultSet result=null;
		
		//Create the selection statement 
		String selectionStatement = "Select " + fields+ " from " + tables + ";";
		System.out.println(selectionStatement);
		
		try{
			//perform the query and catch results in the result object
			result = stmt.executeQuery(selectionStatement);
		} catch(Exception e){
			e.printStackTrace();
		}
		finally{
			//return results
			return result;
		}
	}
	
	
	
	
	/***********
		doSelect method
			This method performs a query to the database
			@parameters:
				fields: list of fields to be projected from the tables
				tables: list of tables to be selected
				where: where clause
				orderBy: order by condition
			@returns:
				ResulSet result containing the project tuples resulting from the query
	*/
	public ResultSet doSelect(String fields, String tables, String where, String orderBy){
		
		//Create a ResulSet
		ResultSet result=null;
		
		//Create the selection statement 
		String selectionStatement = "Select " + fields+ " from " + tables + " where " + where + " order by " + orderBy + ";";
		
		try{
			//perform the query and catch results in the result object
			result = stmt.executeQuery(selectionStatement);
		} catch(Exception e){
			e.printStackTrace();
		}
		finally{
			//return results
			return result;
		}
	}
	
	
	
	/***********
		doInsertion method
			This method performs an insertion to the database
			@parameters:
				values: values to be inserted 
				table: table to be updated
				
			@returns:
				boolean value: true: the insertion was ok, an error was generated
	*/
	public boolean doInsert(String table, String values)
	{
		boolean result =false;
		String  InsertStatement ="INSERT INTO "+ table + " values (" + values +");";
		System.out.println( InsertStatement);
		//try to insert a record to the selected table
		try{
			result=stmt.execute( InsertStatement);
			result = true;
			 System.out.println("MySQLCompleteConnector insertion: " + result);
			 
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally{
			return result;
		}
			
	}
	
    /********
		doDelete method
		Delete the tuples of a table
		@parameters:
			table: the table
			condition: the condition of the tuples to delete
		@returns:
			true if the delete statement was executed, false if there was an error
	*/
	public boolean doDelete(String table, String condition)
	{
		boolean result = false;
		
		//Create the delete statement
		String DropStatement = "DELETE FROM " + table + " WHERE " + condition + ";";
		System.out.println(DropStatement);
		
		try{
			//Perform the delete
			result = stmt.execute(DropStatement);
			result = true;
			System.out.println("MySQLCompleteConnector Deletion: " + result);
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			return result;
		}
	}


	/********
		doUpdate method
			Update the tuples of a table
			@parameters:
				table: the table to update
				changes: the changes of the update
				where: the condition of the tuples to update
			@returns:
				true if at least one tuple was updated, false in other case
	*/
	public boolean doUpdate(String table, String changes, String where)
	{
		boolean res=false;
		
		//Create the update statement
		String updateStatement = "update " + table + " set " + changes + " where " + where + ";";
		System.out.println(updateStatement);
		
		try{
			//Perform the update
			res = stmt.executeUpdate(updateStatement) > 0;
		} catch(Exception e){
			e.printStackTrace();
		}
		return res;
	}
}
