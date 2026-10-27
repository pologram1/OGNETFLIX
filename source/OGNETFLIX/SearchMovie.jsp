<%@ page import="java.lang.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>
<%//Import the ut package for accessing the database %>
<%@ page import="ut.*"%>
<html>
	<head>
		<title>OG Netflix - Search Movies</title>
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
	
		String currentPage="SearchMovie.jsp";
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
				
					//Retrieve the selected genre
					String genre = request.getParameter("genre");
					
					//If no genre is selected, show all the movies in MovieList.jsp
					if (genre==null || genre.equals("")){
						res.close();
						appDBAuth.close();
						response.sendRedirect("MovieList.jsp");
						return;
					}
				
					//Update the current page attribute
					session.setAttribute("currentPage", currentPage);
					%>
					<h1>Search Movies</h1>
					
					<%//Search bar: the customer can search another genre from this page%>
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
						<input type="submit" value="Search">
					</form>
					<br>
					<%
					//Verify that a genre was selected
					if (genre!=null && !genre.equals("")){
						//Create the appDBMnger object
						applicationDBManager appDBMnger = new applicationDBManager();
						
						//Call the searchMovieByGenre method. This method returns the movies of the genre
						ResultSet movies=appDBMnger.searchMovieByGenre(genre);
						int count=0;
						%>
						<h3>Genre: <%=genre%></h3>
						<table border=1>
						<tr><td>Picture</td><td>Title</td><td>Genre</td><td>Release year</td><td>Description</td><td>Queue</td></tr>
						<%
						//Iterate over the ResultSet
						while (movies.next()){ //EXAMPLE: 1 | The Dark Knight | Action | 2008 | darkknight.jpg
							//Count each movie
							count++;%>
							<tr>
							<td><img src="images/<%=movies.getString(5)%>" width="60"></td>
							<td><%=movies.getString(2)%></td>
							<td><%=movies.getString(3)%></td>
							<td><%=movies.getString(4)%></td>
							<td>
								<form action="MovieDescription.jsp" method="post">
									<input type="hidden" name="movieId" value="<%=movies.getString(1)%>">
									<input type="hidden" name="genre" value="<%=genre%>">
									<button>Movie description</button>
								</form></td>
							<td>
								<form action="addToQueue.jsp" method="post">
									<input type="hidden" name="movieId" value="<%=movies.getString(1)%>">
									<input type="hidden" name="genre" value="<%=genre%>">
									<button>Add to Queue</button>
									
								</form>
							</td>
							</tr>
						<%}%>
						</table>
						Movies found: <%=count%> <br><br>
						<%
						//Close the ResultSet
						movies.close();
						//Close the connection to the database
						appDBMnger.close();
					}
					%>
					<a href="netflixMenu.jsp"><button>Home</button></a> | <a href="signout.jsp"><button>Sign out</button></a>
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
