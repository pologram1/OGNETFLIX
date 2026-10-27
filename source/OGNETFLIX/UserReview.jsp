<%@ page import="java.lang.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>
<%//Import the ut package for accessing the database %>
<%@ page import="ut.*"%>
<html>
	<head>
		<title>OG Netflix - User Review</title>
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
	
		String currentPage="UserReview.jsp";
		String userName = session.getAttribute("userName").toString();
		String previousPage = session.getAttribute("currentPage").toString();
		
		//Try to connect the database using the applicationDBAuthenticationGoodComplete class
		try{
				//Create the appDBAuth object
				applicationDBAuthenticationGoodComplete appDBAuth = new applicationDBAuthenticationGoodComplete();
				
				//Call the verifyUser method. This method returns a ResultSet only if the user can visit this page from the previous page
				ResultSet res=appDBAuth.verifyUser(userName, currentPage, previousPage);
				
				//Verify if the user has permission to visit this page
				if (res.next()){  //EXAMPLE: user1 | rol1 | user1
					//Update the current page attribute
					session.setAttribute("currentPage", currentPage);

					//Retrieve the selected customer
					String customer = request.getParameter("customer");
					
					//Verify that a customer was selected
					if (customer==null){%>
						No customer selected <br>
						<a href="CustomerList.jsp">Back to customers</a>
					<%}
					else{
						//Create the appDBMnger object
						applicationDBManager appDBMnger = new applicationDBManager();
						
						//Call the getCustomer method. This method returns the information of the customer
						ResultSet customerRes=appDBMnger.getCustomer(customer);
						
						//Store the customer information in variables
						String customerName="";
						String customerTelephone="";
						if (customerRes.next()){ //EXAMPLE: user2 | user2 | 123456
							customerName=customerRes.getString(2);
							customerTelephone=customerRes.getString(3);
						}
						customerRes.close();
						%>
						<h1>Movie list of <%=customerName%></h1>
						User name: <%=customer%> <br>
						Telephone: <%=customerTelephone%> <br><br>
						
						<h2>Queue</h2>
						<table border=1>
						<tr><td>Queue position</td><td>Picture</td><td>Title</td><td>Status</td><td>Description</td></tr>
						<%
						//Call the customerQueue method. This method returns the movies waiting in the queue of the customer
						ResultSet queue=appDBMnger.customerQueue(customer);
						int queueCount=0;
						
						//Iterate over the ResultSet
						while (queue.next()){ //EXAMPLE: 1 | Paddington 2 | Paddington2.jpg | 9
							//Count each movie in the queue
							queueCount++;%>
							<tr>
							<td><%=queue.getString(1)%></td>
							<td><img src="images/<%=queue.getString(3)%>" width="60"></td>
							<td><%=queue.getString(2)%></td>
							<td>queued</td>
							<td>
								<form action="MovieDescription.jsp" method="post">
									<input type="hidden" name="movieId" value="<%=queue.getString(4)%>">
									<input type="hidden" name="customer" value="<%=customer%>">
									<button>Movie description</button>
								</form>
							</td>
							</tr>
						<%}%>
						</table>
						Movies in the queue: <%=queueCount%> <br>
						<%
						//Close the queue ResultSet before the next query
						queue.close();
						%>
						
						<h2>Movies mailed to the customer</h2>
						<table border=1>
						<tr><td>Picture</td><td>Title</td><td>Description</td><td>Status</td><td>Action</td></tr>
						<%
						//Call the customerRentals method. This method returns the movies mailed to the customer with their status
						ResultSet rentals=appDBMnger.customerRentals(customer);
						int rentalCount=0;
						
						//Iterate over the ResultSet
						while (rentals.next()){ //EXAMPLE: 1 | 300 | returned | 300.jpg | 5
							//Count each mailed movie
							rentalCount++;
							String status=rentals.getString(3);%>
							<tr>
							<td><img src="images/<%=rentals.getString(4)%>" width="60"></td>
							<td><%=rentals.getString(2)%></td>
							<td>
								<form action="MovieDescription.jsp" method="post">
									<input type="hidden" name="movieId" value="<%=rentals.getString(5)%>">
									<input type="hidden" name="customer" value="<%=customer%>">
									<button>Movie description</button>
								</form>
							</td>
							<td><%=status%></td>
							<td>
							<%
							//Only a movie that the customer already watched can be registered as returned
							if (status.equals("watched")){%>
								<form action="registerReturn.jsp" method="post">
									<input type="hidden" name="rentalId" value="<%=rentals.getString(1)%>">
									<input type="hidden" name="customer" value="<%=customer%>">
									<button>Register return</button>
								</form>
							<%}else{ //No actions for movies that have not been watched
							%>
								- 
							<%}%>
							</td>
							</tr>
						<%}%>
						</table>
						Movies mailed: <%=rentalCount%> <br><br>
						<%
						//Close the ResultSet
						rentals.close();
						//Close the connection to the database
						appDBMnger.close();
					}%>
					<a href="CustomerList.jsp">Back to customers</a> | <a href="AdminMenu.jsp">Home</a> | <a href="signout.jsp">Sign out</a>
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

