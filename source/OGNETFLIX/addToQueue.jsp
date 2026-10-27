<%@ page import="java.lang.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>
<%//Import the ut package for accessing the database %>
<%@ page import="ut.*"%>
<html>
	<head>
		<title>OG Netflix - Add to Queue</title>
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
	
		String currentPage="addToQueue.jsp";
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
					
					//Retrieve the selected movie
					String movieId = request.getParameter("movieId");
					//Retrieve the genre of the search
					String genre = request.getParameter("genre");
					
					//Create the appDBMnger object
					applicationDBManager appDBMnger = new applicationDBManager();
					
					//Call the addToQueue method. The customer is the user of the session
					boolean added=appDBMnger.addToQueue(userName, movieId);
					
					//Close the connection to the database
					appDBMnger.close();
					%>
					<h1>OG Netflix</h1>
					<%if (added){%>
						<p>Movie added to your queue!</p>
					<%}else{%>
						<p>The movie could not be added: it is already in your queue, at home or it is not available.</p>
					<%}
					
					//Return to the page where the customer selected the movie
					if (genre!=null && !genre.equals("")){%>
						<form action="SearchMovie.jsp" method="post">
							<input type="hidden" name="genre" value="<%=genre%>">
							<input type="submit" value="Back to search">
						</form>
					<%}else{%>
						<a href="MovieList.jsp"><button>Back to movie list</button></a> <br><br>
					<%}%>
					<a href="CurrentList.jsp">See Queue</a> | <a href="netflixMenu.jsp">Home</a> | <a href="signout.jsp">Sign out</a>
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
