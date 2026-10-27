<%@ page import="java.lang.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>
<%//Import the ut package for accessing the database %>
<%@ page import="ut.*"%>
<html>
	<head>
		<title>OG Netflix - Movie Description</title>
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
	
		String currentPage="MovieDescription.jsp";
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
				
					//Page where the user was before (Back button)
					String backPage=previousPage;
					if (previousPage.equals("MovieDescription.jsp")){
						//If the page is reloaded, use the page stored before
						backPage=session.getAttribute("backPage").toString();
					}else{
						//Store the previous page in the session
						session.setAttribute("backPage", backPage);
					}
					
					//Values needed to return to UserReview.jsp and SearchMovie.jsp
					String customer = request.getParameter("customer"); //UserReview.jsp
					String genre = request.getParameter("genre");       //SearchMovie.jsp
					if (customer==null) customer="";
					if (genre==null) genre="";
					//Update the current page attribute
					session.setAttribute("currentPage", currentPage);
					
					//Retrieve the role of the user (rol1: administrator, rol2: customer)
					String roleId=res.getString(2);
					
					//Retrieve the selected movie
					String movieId = request.getParameter("movieId");
					
					//Create the appDBMnger object
					applicationDBManager appDBMnger = new applicationDBManager();
					
					//Call the getMovie method. This method returns the complete description of the movie
					ResultSet movie=appDBMnger.getMovie(movieId);
					
					//Verify that the movie exists
					if (movie.next()){ //EXAMPLE: 1 | The Dark Knight | Action | Batman fights... | Christian Bale, Heath Ledger | Christopher Nolan | 2008 | USA | darkknight.jpg
					%>
						<h1><%=movie.getString(2)%></h1>
						<img src="images/<%=movie.getString(9)%>" width="250"> <br><br>
						<table border=1>
						<tr><td>Genre</td><td><%=movie.getString(3)%></td></tr>
						<tr><td>Plot</td><td><%=movie.getString(4)%></td></tr>
						<tr><td>Actors</td><td><%=movie.getString(5)%></td></tr>
						<tr><td>Director</td><td><%=movie.getString(6)%></td></tr>
						<tr><td>Release year</td><td><%=movie.getString(7)%></td></tr>
						<tr><td>Country</td><td><%=movie.getString(8)%></td></tr>
						</table>
						<br>
					<%}else{%>
						The movie does not exist <br><br>
					<%}
					
					//Close the ResultSet
					movie.close();
					//Close the connection to the database
					appDBMnger.close();
					
					//Only the customer can add the movie to his queue
					if (roleId.equals("rol2")){%>
						<form action="addToQueue.jsp" method="post">
							<input type="hidden" name="movieId" value="<%=movieId%>">
							<input type="hidden" name="genre" value="<%=genre%>">
							<input type="submit" value="Add to Queue">
						</form>
					<%}
					
					//Back button: return to the page where the user was
					%>
					<form action="<%=backPage%>" method="post">
						<input type="hidden" name="customer" value="<%=customer%>">
						<input type="hidden" name="genre" value="<%=genre%>">
						<input type="submit" value="Back">
					</form>
					<%
					//Home: each role returns to its own menu
					if (roleId.equals("rol1")){%>
						<a href="AdminMenu.jsp">Home</a> | <a href="signout.jsp">Sign out</a>
					<%}else{%>
						<a href="netflixMenu.jsp">Home</a> | <a href="signout.jsp">Sign out</a>
					<%}
	
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

