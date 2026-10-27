<%-- Customer queue/current rentals. The archive references a missing removeFromQueue.jsp handler. --%>
<%@ page import="java.lang.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>
<%//Import the ut package for accessing the database %>
<%@ page import="ut.*"%>
<html>
	<head>
		<title>OG Netflix - Current List</title>
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
	
		String currentPage="CurrentList.jsp";
		String userName = session.getAttribute("userName").toString();
		String previousPage = session.getAttribute("currentPage").toString();
		
		//Try to connect the database using the applicationDBAuthenticationGoodComplete class
		try{
				//Create the appDBAuth object
				applicationDBAuthenticationGoodComplete appDBAuth = new applicationDBAuthenticationGoodComplete();
				
				//Call the verifyUser method. This method returns a ResultSet only if the user can visit this page from the previous page
				ResultSet res=appDBAuth.verifyUser(userName, currentPage, previousPage);
				
				//Verify if the user has permission to visit this page
				if (res.next()){ //EXAMPLE: user2 | rol2 | user2
					//Update the current page attribute
					session.setAttribute("currentPage", currentPage);
					
					//Create the appDBMnger object
					applicationDBManager appDBMnger = new applicationDBManager();
					%>
					<h1>Current List</h1>
					
					<h2>My queue</h2>
					<table border=1>
					<tr><td>Queue position</td><td>Picture</td><td>Title</td><td>Description</td><td>Action</td></tr>
					<%
					//Call the customerQueue method. The customer is the user of the session
					ResultSet queue=appDBMnger.customerQueue(userName);
					int queueCount=0;
					
					//Iterate over the ResultSet
					while (queue.next()){ //EXAMPLE: 1 | Paddington 2 | Paddington2.jpg | 9
						//Count each movie in the queue
						queueCount++;%>
						<tr>
						<td><%=queue.getString(1)%></td>
						<td><img src="images/<%=queue.getString(3)%>" width="60"></td>
						<td><%=queue.getString(2)%></td>
						<td>
							<form action="MovieDescription.jsp" method="post">
								<input type="hidden" name="movieId" value="<%=queue.getString(4)%>">
								<button>Movie description</button>
							</form></td>
						<td>
							<form action="removeFromQueue.jsp" method="post">
								<input type="hidden" name="movieId" value="<%=queue.getString(4)%>">
								<button>Remove from queue</button>
							</form></td>
						</tr>
					<%}%>
					</table>
					Movies in the queue: <%=queueCount%> <br>
					<%
					//Close the queue ResultSet before the next query
					queue.close();
					%>
					
					<h2>Movies at home</h2>
					<table border=1>
					<tr><td>Picture</td><td>Title</td><td>Status</td><td>Description</td><td>Action</td></tr>
					<%
					//Call the customerCurrentRentals method. This method returns the movies mailed or watched
					ResultSet rentals=appDBMnger.customerCurrentRentals(userName);
					int rentalCount=0;
					
					//Iterate over the ResultSet
					while (rentals.next()){ //EXAMPLE: 4 | 300 | watched | 300.jpg | 5
						//Count each movie at home
						rentalCount++;%>
						<tr>
						<td><img src="images/<%=rentals.getString(4)%>" width="60"></td>
						<td><%=rentals.getString(2)%></td>
						<td><%=rentals.getString(3)%></td>
						<td>
							<form action="MovieDescription.jsp" method="post">
								<input type="hidden" name="movieId" value="<%=rentals.getString(5)%>">
								<button>Movie description</button>
							</form></td>
						<td>
						<%//Only a mailed movie can be marked as watched
						if (rentals.getString(3).equals("mailed")){%>
							<form action="markWatched.jsp" method="post">
								<input type="hidden" name="rentalId" value="<%=rentals.getString(1)%>">
								<button>Mark as watched</button>
							</form>
						<%}else{ //The movie was already watched%>
							-
						<%}%>
						</td>
						</tr>
					<%}%>
					</table>
					Movies at home: <%=rentalCount%> <br><br>
					<a href="netflixMenu.jsp"><button>Home</button></a> | <a href="signout.jsp"><button>Sign out</button></a>
					<%
					//Close the ResultSet
					rentals.close(); 
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
