<%@ page import="java.lang.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>
<%//Import the ut package for accessing the database %>
<%@ page import="ut.*"%>
<html>
	<head>
		<title>OG Netflix - Register Return</title>
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
	
		String currentPage="registerReturn.jsp";
		String userName = session.getAttribute("userName").toString();
		String previousPage = session.getAttribute("currentPage").toString();
		
		//Try to connect the database using the applicationDBAuthenticationGoodComplete class
		try{
				//Create the appDB…2516 tokens truncated…ttribute("currentPage").toString();
		
		//Try to connect the database using the applicationDBAuthenticationGoodComplete class
		try{
				//Create the appDBAuth object
				applicationDBAuthenticationGoodComplete appDBAuth = new applicationDBAuthenticationGoodComplete();
				
				//Call the verifyUser method. This method returns a ResultSet only if the user can visit this page from the previous page
				ResultSet res=appDBAuth.verifyUser(userName, currentPage, previousPage);
				
				//Verify if the user has permission to visit this page
				if (res.next()){ //EXAMPLE: user1 | rol1 | user1
					//Update the current page attribute
					session.setAttribute("currentPage", currentPage);
					
					//Retrieve the fields of the form of AddMovie.jsp
					String title = request.getParameter("title");
					String plot = request.getParameter("plot");
					String actors = request.getParameter("actors");
					String director = request.getParameter("director");
					int releaseYear = Integer.parseInt(request.getParameter("releaseYear"));
					String country = request.getParameter("country");
					String picture = request.getParameter("picture");
					String genre = request.getParameter("genre");
					
					//Create the appDBMnger object
					applicationDBManager appDBMnger = new applicationDBManager();
					
					//Call the addMovie method. This method inserts the movie and returns true if it was inserted
					boolean added=appDBMnger.addMovie(title, plot, actors, director, releaseYear, country, picture, genre);
					
					//Close the connection to the database
					appDBMnger.close();
					
					//Verify if the movie was inserted
					if (added){%>
						<h1>OG Netflix</h1>
						<p>Movie added successfully!</p>
					<%}else{%>
						<h1>OG Netflix</h1>
						<p>Error adding movie!</p>
					<%}%>
					<a href="AdminMovieList.jsp">Movie List</a>
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
	<br><a href="AdminMenu.jsp"><button>Home</button></a> | <a href="signout.jsp"><button>Sign out</button></a>
	</body>
</html> 






































































