<%@ page import="java.lang.*"%>
<%@ page import="ut.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>
<html>
	<head>
		<title>Add User Page!</title>
	</head>
	<body>

<%
	//Retrieve variables
	String userName = request.getParameter("userName");
	String userPass = request.getParameter("userPass");
	String completeName = request.getParameter("completeName");
	String telephone = request.getParameter("telephone");
	
	
	
	//Try to connect the database using the applicationDBAuthenticationGoodComplete class
	try{
			//Create the appDBAuth object
			applicationDBAuthenticationGoodComplete appDBAuth = new applicationDBAuthenticationGoodComplete();
			System.out.println("Connecting...");
			System.out.println(appDBAuth.toString());

			//Call the addUser method. This method returns true if the user was inserted
			boolean res=appDBAuth.addUser(userName, completeName, userPass, telephone);%>
		
			
			
			<%//Verify if the user was inserted
			if (res){%>
				<h1>Netflix</h1>
				<p>User added successfully!</p>
				<a href="Netflixlogin.html">Back to Login</a>
			<%}else{
				//Close any session associated with the user
				session.setAttribute("userName", null);
				%>
				<h1>Netflix</h1>
				<p>Error: the user could not be added. The user name may already exist.</p>
				<a href="NetflixSignUp.html">Try again</a>
			<%}
				
				//Close the connection to the database
				appDBAuth.close();
			
			} catch(Exception e)
			{%>
				Nothing to show!
				<%e.printStackTrace();
			}finally{
				System.out.println("Finally");
			}
			%>		
		
		
		
	</body>
</html>
