//This class belongs to the ut package
package ut;

//Import the java.sql package for managing the ResulSet objects
import java.sql.* ;

//Import hashing functions
import org.apache.commons.codec.*;

/******
	This class authenticate users using userName and passwords

*/
public class applicationDBAuthenticationGoodComplete{

	//myDBConn is an MySQLCompleteConnector object for accessing to the database
	private MySQLCompleteConnector myDBConn;
	
	/********
		Default constructor
		It creates a new MySQLCompleteConnector object and open a connection to the database
		@parameters:
		
	*/
	public applicationDBAuthenticationGoodComplete(){
		//Create the MySQLCompleteConnector object
		myDBConn = new MySQLCompleteConnector();
		
		//Open the connection to the database
		myDBConn.doConnection();
	}
	
	
	
	
	
	/*******
		authenticate method
			Authentication method
			@parameters:
				userName: the user name in the login
				userPass: the password in the login
			@returns:
				A ResultSet containing the userName and all roles assigned to them.
	*/
	public ResultSet authenticate(String userName, String userPass)
	{
		
		//Declare function variables
		String fields, tables, whereClause, hashingVal;
		
		//Define the table where the selection is performed
		tables="usergood, roleuser";
		//Define the list fields list to retrieve assigned roles to the user
		fields ="usergood.userName, roleuser.roleId, usergood.Name";
		hashingVal = hashingSha256(userName + userPass);
		whereClause="usergood.userName = roleuser.userName and usergood.userName='" + fixQuote(userName) + "' and hashing='" + hashingVal + "'";
		
		
		System.out.println("listing...");
		
		//Return the ResultSet containing all roles assigned to the user
		return myDBConn.doSelect(fields, tables, whereClause);
	}





	/*******
	verifyUser method
	Verify if a user can visit the current page coming from the previous page
		@parameters:
			userName: the user of the session
			currentPage: the page that the user wants to visit
			previousPage: the last page visited by the user
		@returns:
			A ResultSet containing the userName, roleId and Name of the user if he has permission, empty in other case
	*/
	public ResultSet verifyUser(String userName, String currentPage, String previousPage)
	{
		
		//Declare function variables
		String fields, tables, whereClause, hashingVal;
		
		//Define the table where the selection is performed
		tables="roleuser, role, rolewebpagegood, webpagegood, usergood, webpageprevious";
		//Define the list fields list to retrieve assigned roles to the user
		fields ="usergood.userName, roleuser.roleId, usergood.Name ";
		whereClause=" usergood.userName = roleuser.userName and usergood.userName='" + fixQuote(userName) + "' and role.roleId=roleuser.roleId and ";
		whereClause+=" rolewebpagegood.roleId=role.roleId and rolewebpagegood.pageURL=webpagegood.pageURL and webpagegood.pageURL='" +currentPage+"' and ";
		whereClause+=" webpageprevious.previousPageURL='"+previousPage+"' and webpageprevious.currentPageURL=webpagegood.pageURL";
		
		
		System.out.println("listing...");
		
		//Return the ResultSet containing all roles assigned to the user
		return myDBConn.doSelect(fields, tables, whereClause);
	}
	
	
	
	
	
	/*******
	addUser method
	Insert a new user
	@parameters:
		userName, completeName, userPass, userTelephone: the information of the new user
	@returns:
		true if the user was inserted, false in other case
	*/
	public boolean addUser(String userName, String completeName, String userPass, String userTelephone)
	{
		boolean res;
		String table, values, hashingValue;
		
		//The password is not stored, only the hash of the userName and the password
		hashingValue=hashingSha256(userName + userPass);
		//Define the table where the user is inserted
		table="usergood";
		//Define the values of the new user
		values="'" + fixQuote(userName) + "', '" + hashingValue + "', '" + fixQuote(completeName) + "', '" + fixQuote(userTelephone) + "'";
		
		//Insert the user
		res=myDBConn.doInsert(table, values);
		System.out.println("Insertion result" + res);
		return res;
	}
	
	
	
	
	/*********
		hashingSha256 method
			Generates a hash value using the sha256 algorithm.
			@parameters: Plain text
			@returns: the hash string based on the plainText
	*/
	private String hashingSha256(String plainText)
	{
			String sha256hex = org.apache.commons.codec.digest.DigestUtils.sha256Hex(plainText); 
			return sha256hex;
	}
	
	
	
	
/*******
fixQuote method
	Duplicate the single quotes of a text to avoid a query injection
	@parameters:
		text: the text that will be used inside a SQL statement
	@returns:
		The text with the single quotes duplicated
*/
	private String fixQuote(String text)
	{
		if (text==null) return "";
		return text.replace("\\", "\\\\").replace("'", "''");
	}
	
	
	/*********
		close method
			Close the connection to the database.
			This method must be called at the end of each page/object that instatiates a applicationDBAuthenticationGoodComplete object
			@parameters:
			@returns:
	*/
	public void close()
	{
		//Close the connection
		myDBConn.closeConnection();
	}

}
