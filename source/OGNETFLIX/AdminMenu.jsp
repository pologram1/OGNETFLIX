<%-- Administrator navigation, after session and page-permission checks. --%>
<%@ page import="java.lang.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>
<%@ page import="ut.*"%>

<html>
	<head>
		<title>Hello Admin!</title>
	</head>
	<body>

<%
	//Check the authentication process
	if ((session.getAttribute("userName")==null) || (session.getAttribute("currentPage")==null)){
		session.setAttribute("currentPage", null);
		session.setAttribute("userName", null);
		//return to the login page
		response.sendRedirect("Netflixlogin.html");
	}
	else{
	
		String currentPage="AdminMenu.jsp";
		String userName = session.getAttribute("userName").toString();
		String previousPage = session.getAttribute("currentPage").toString();
		
		//Try to connect the database using the applicationDBAuthenticationGoodComplete class
		try{
				//Create the appDBAuth object
				applicationDBAuthenticationGoodComplete appDBAuth = new applicationDBAuthenticationGoodComplete();
				System.out.println("Connecting...");
				System.out.println(appDBAuth.toString());
				
				//Call the verifyUser method. This method returns a ResultSet only if the user can visit this page from the previous page
				ResultSet res=appDBAuth.verifyUser(userName, currentPage, previousPage);
			
				
				
				//Verify if the user has been authenticated
				if (res.next()){
					String userActualName=res.getString(3);
					
					//Create the current page attribute
					session.setAttribute("currentPage", "AdminMenu.jsp");
					
					//create the session variable
						session.setAttribute("userName", userName);
					%>
					Welcome! <%=userActualName%>
					<h3>Netflix Administrator Board</h3>
					
					<a href="CustomerList.jsp"> Manage Users</a>
					<br><br>
					
					<a href="AdminMovieList.jsp"> Manage Movies</a>
	                <br><br>
	             
					<%
					
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
				
	}%>		
			
		<a href="signout.jsp">
    <button>Sign out</button>
</a>
	</body>
</html>
