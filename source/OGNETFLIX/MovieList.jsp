<%@ page import="java.lang.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>
<%//Import the ut package for accessing the database %>
<%@ page import="ut.*"%>
<html>
	<head>
		<title>OG Netflix - Movie List</title>
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
	
		String currentPage="MovieList.jsp";
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
					%>
					<h1>Movie List</h1>
					
					<%//Search bar: refine the list by genre in SearchMovie.jsp%>
					<form action="SearchMovie.jsp" method="post">
						Search by genre:
						<select name="genre">
							<option value="">All genres</option>
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
					//Create the appDBMnger object
					applicationDBManager appDBMnger = new applicationDBManager();
					
					//Call the listMoviesByGenre method. This method returns all the movies ordered by genre
					ResultSet movies=appDBMnger.listMoviesByGenre();
					int count=0;
					
					//Genre of the previous movie, to know when a new genre starts
					String lastGenre="";
					%>
					<table border=1>
					<%
					//Iterate over the ResultSet
					while (movies.next()){ //EXAMPLE: 1 | The Dark Knight | Action | 2008 | darkknight.jpg
						//Count each movie
						count++;
						
						//Genre of this movie
						String genre=movies.getString(3);
						if (genre==null) genre="No genre";
						
						//If the genre changed, print the name of the new genre
						if (!genre.equals(lastGenre)){
							lastGenre=genre;%>
							<tr><td colspan="5"><h3><%=genre%></h3></td></tr>
							<tr><td>Picture</td><td>Title</td><td>Release year</td><td>Description</td><td>Queue</td></tr>
						<%}%>
						<tr>
						<td><img src="images/<%=movies.getString(5)%>" width="60"></td>
						<td><%=movies.getString(2)%></td>
						<td><%=movies.getString(4)%></td>
						<td>
							<form action="MovieDescription.jsp" method="post">
								<input type="hidden" name="movieId" value="<%=movies.getString(1)%>">
								<input type="submit" value="Movie description">
							</form></td>
						<td>
							<form action="addToQueue.jsp" method="post">
								<input type="hidden" name="movieId" value="<%=movies.getString(1)%>">
								<input type="submit" value="Add to Queue">
							</form></td>
						</tr>
					<%}%>
					</table>
					Movies: <%=count%> <br><br>
					<a href="netflixMenu.jsp"><button>Home</button></a> | <a href="signout.jsp"><button>Sign out</button></a>
					<%
					//Close the ResultSet
					movies.close();
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
