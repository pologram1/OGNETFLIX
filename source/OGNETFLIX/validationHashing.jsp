<%@ page import="java.lang.*"%>
<%@ page import="ut.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>
<html>
	<head>
		<title>OG Netflix - Login</title>
	</head>
	<body>

<%
	//Retrieve variables
	String userName = request.getParameter("userName");
	String userPass = request.getParameter("userPass");
	
	
	//Try to connect the database using the applicationDBAuthenticationGoodComplete class
	try{
			//Create the appDBAuth object
			applicationDBAuthenticationGoodComplete appDBAuth = new applicationDBAuthenticationGoodComplete();
			System.out.println("Connecting...");
			System.out.println(appDBAuth.toString());
			
			//Call the authenticate method. This method returns a ResultSet containing the user and his role
			ResultSet res=appDBAuth.authenticate(userName, userPass);%>
		
			<%//Verify if the user has been authenticated
			if (res.next()){ //EXAMPLE: user1 | rol1 | user1
				
				
				//Create the current page attribute
				session.setAttribute("currentPage", "validationHashing.jsp");
				
				//Create a session variable
				if (session.getAttribute("userName")==null ){
					//create the session variable
					session.setAttribute("userName", userName);
				} else{
					//Update the session variable
					session.setAttribute("userName", userName);
				}
				
					//Retrieve the role of the user (rol1: administrator, rol2: customer)
					String roleId=res.getString(2);

					//redirect to the menu of the role
					if (roleId.equals("rol1")){
						response.sendRedirect("AdminMenu.jsp");
					}else{
						response.sendRedirect("netflixMenu.jsp");
					}
				
			}else{
				//Close any session associated with the user
				session.setAttribute("userName", null);
				
				//return to the login page
				response.sendRedirect("Netflixlogin.html");
				}
				res.close();
				//Close the connection to the database
				appDBAuth.close();
			
			} catch(Exception e)
			{%>
				Nothing to show!
				<%e.printStackTrace();
				response.sendRedirect("Netflixlogin.html");
			}finally{
				System.out.println("Finally");
			}
			%>		
		
		
	</body>
</html>
