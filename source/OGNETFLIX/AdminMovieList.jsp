
<%@ page import="java.lang.*" %>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*" %>
<%@ page import="ut.*" %>

<html>
<head>
    <title>Movie Manager!</title>
</head>
<body>

<%
    // Check the authentication process
    if ((session.getAttribute("userName") == null) ||(session.getAttribute("currentPage") == null)) {

        session.setAttribute("currentPage", null);
        session.setAttribute("userName", null);
        response.sendRedirect("Netflixlogin.html");
        return;}
		
    else {

        String currentPage = "AdminMovieList.jsp";
        String userName = session.getAttribute("userName").toString();
        String previousPage = session.getAttribute("currentPage").toString();
      
	  //Try to connect the database using the applicationDBAuthenticationGoodComplete class
        try {

            // Create the authentication object
            applicationDBAuthenticationGoodComplete appDBAuth = new applicationDBAuthenticationGoodComplete();
           System.out.println("Connecting...");
		   System.out.println(appDBAuth.toString());
            // Verify user permission
            ResultSet res = appDBAuth.verifyUser(
                userName, currentPage, previousPage
            );
            if (res.next()) {

                String userActualName = res.getString(3);

                // Update current page
                session.setAttribute("currentPage", "AdminMovieList.jsp");

                // Create the database manager object
                applicationDBManager appDBMnger = new applicationDBManager();
				
                // Retrieve all movies
                ResultSet movies = appDBMnger.listAllMovies();
%>

<h2>Movie Manager</h2>

<p>Welcome, <%= userActualName %></p>
  <a href="AddMovie.jsp"><button>Add Movie</button> </a> 
<table border="3">
    <tr> <th>Title</th><th>Genre</th><th>Plot</th><th>Actors</th><th>Director</th><th>Release Year</th><th>Country</th><th>Picture</th><th>Actions</th></tr>

<%
                int count = 0;

                while (movies.next()) { 
				
		        //Count each Movie
                count++;
					
%>

    <tr>
        <td><%= movies.getString("title") %></td>
		<td><%= movies.getString("genre") %></td>
        <td><%= movies.getString("plot") %></td>
        <td><%= movies.getString("actors") %></td>
        <td><%= movies.getString("director") %></td>
        <td><%= movies.getString("releaseYear") %></td>
        <td><%= movies.getString("country") %></td>
        <td><img src="images/<%= movies.getString("picture") %>" width="120"></td>
	 
<td>
    <a href="EditMovie.jsp?movieId=<%= movies.getInt("movieId") %>">
        <button type="button">Edit Movie</button>
    </a>

    <a href="RemoveMovie.jsp?movieId=<%= movies.getInt("movieId") %>">
        <button>Remove Movie</button>
    </a>
</td>
    </tr>
  
<%
                }
%>

</table>

<p>Total Movies: <%= count %></p>

<%
                // Close movie ResultSet
                movies.close();

                // Close database manager connection
                appDBMnger.close();

            }
            else {
%>

<h2>Access Denied!</h2>
<p>You do not have permission to visit this page.</p>

<%
            }

            // Close authentication ResultSet
            res.close();
            appDBAuth.close();

        }
        catch (Exception e) {
            e.printStackTrace();
%>

<h2>Error accessing database!</h2>

<%
        }
    }
%>
<a href="AdminMenu.jsp"><button>Home</button> </a> <a href="signout.jsp"><button>Sign out</button> </a>
</body>
</html>
