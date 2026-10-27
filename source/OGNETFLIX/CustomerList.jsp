<%@ page import="java.lang.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>
<%//Import the ut package for accessing the database %>
<%@ page import="ut.*"%>

<html>
	<head>
		<title>OG Netflix - Customers</title>
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
	
		String currentPage="CustomerList.jsp";
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
					
					//Create the current page attribute
					session.setAttribute("currentPage", "CustomerList.jsp");
					
					//create the session variable
					session.setAttribute("userName", userName);
					
					%>
					<h1>Customers</h1>
					<table border=1>
					<tr><td>User name</td><td>Name</td><td>Telephone</td><td>Movies</td></tr>
					<%
					//Create the appDBMnger object
					applicationDBManager appDBMnger = new applicationDBManager();
					
					//Call the listCustomers method. This method returns all users with the customer role
					ResultSet customers=appDBMnger.listCustomers();
					int count=0;
					
					//Iterate over the ResultSet
					while (customers.next()){ 	//EXAMPLE: user2 | user2 | 123456
						//Count each customer
						count++;%>
						<tr>
						<td><%=customers.getString(1)%></td>
						<td><%=customers.getString(2)%></td>
						<td><%=customers.getString(3)%></td>
						<td>
							<form action="UserReview.jsp" method="post">
								<input type="hidden" name="customer" value="<%=customers.getString(1)%>">
								<button>Movie list</button>
							</form></td>
						</tr>
					<%}%>
					</table>
					Customers: <%=count%> <br><br>
					<a href="AdminMenu.jsp"><button>Home</button></a> | <a href="signout.jsp"><button>Sign out</button></a>
					<%
					//Close the ResultSet
					customers.close();
					//Close the connection to the database
					appDBMnger.close();
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
	</body>
</html>

