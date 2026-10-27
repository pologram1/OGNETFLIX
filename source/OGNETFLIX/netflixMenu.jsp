<%@ page import="java.lang.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>
<%//Import the ut package for accessing the database %>
<%@ page import="ut.*"%>

<html>
	<head>
		<title>OG Netflix - Menu</title>
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
	
		String currentPage="netflixMenu.jsp";
		String userName = session.getAttribute("userName").toString();
		String previousPage = session.getAttribute("currentPage").toString();
		
		//Try to connect the database using the applicationDBAuthenticationGoodComplete class
		try{
				//Create the appDBAuth object
				applicationDBAuthenticationGoodComplete appDBAuth = new applicationDBAuthenticationGoodComplete();
				
				//Call the verifyUser method. This method returns a ResultSet only if the user can visit this page from the previous page
				ResultSet res=appDBAuth.verifyUser(userName, currentPage, previousPage);
				
				//Verify if the user has permission to visit this page
				if (res.next()){
					//Retrieve the name of the user
					String userActualName=res.getString(3);
					
					//Update the current page attribute
					session.setAttribute("currentPage", currentPage);
					%>
						<h1>OG Netflix</h1>
						<h4>Welcome! <%=userActualName%></h4>
												<%//Customer menu %>
						<table> 
							<tr><td>Movies</td></tr>
							<tr><td>
								<%//Search by genre %>
								<form action="SearchMovie.jsp" method="post">
									Search by genre:
									<select name="genre">
										<option value="">Select Genre</option>
										<option value="Action">Action</option>
										<option value="Adventure">Adventure</option>
										<option value="Comedy">Comedy</option>
										<option value="Drama">Drama</option>
										<option value="Family">Family</option>
										<option value="History">History</option>
										<option value="Science Fiction">Science Fiction</option>
										<option value="Thriller">Thriller</option>
									</select>
									<button>Search</button>
								</form>
							</td></tr>
							<tr><td><a href="MovieList.jsp">Complete Movie Catalog</a></td></tr>
							<tr><td>My Movies</td></tr>
							<tr><td><a href="CurrentList.jsp">See Queue</a></td></tr>
							<tr><td><a href="PastList.jsp">Returned Movies</a></td></tr>
						</table>
						<br>
						<a href="signout.jsp"><button>Sign out</button></a>
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
	</body>
	
</html>
