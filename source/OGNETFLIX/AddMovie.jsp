
<%@ page import="java.lang.*" %>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*" %>
<%@ page import="ut.*" %>

<html>
<head>
    <title>OG Netflix - Add Movie</title>
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

        String currentPage = "AddMovie.jsp";
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
                session.setAttribute("currentPage", "AddMovie.jsp");

           
%>

<p>Welcome, <%= userActualName %></p>

        <h1>Netflix - Add Movie</h1>

        <form id="form_1" action="SaveMovie.jsp" method="post">
            <table border="0">

                <tr>
                    <td>Movie Title</td>
                    <td><input type="text" id="title"
                               name="title" required /></td>
                </tr>

                <tr>
                    <td>Plot</td>
                    <td><textarea id="plot" name="plot"
                                  required></textarea></td>
                </tr>

                <tr>
                    <td>Actors</td>
                    <td><input type="text" id="actors"
                               name="actors" required /></td>
                </tr>

                <tr>
                    <td>Director</td>
                    <td><input type="text" id="director"
                               name="director" required /></td>
                </tr>

                <tr>
                    <td>Release Year</td>
                    <td><input type="number" id="releaseYear"
                               name="releaseYear" min="1900" max="2026" required /></td>
                </tr>

                <tr>
                    <td>Country</td>
                    <td><input type="text" id="country"
                               name="country" required /></td>
                </tr>

                <tr>
                    <td>Picture</td>
                    <td><input type="file" id="picture" name="picture" accept="image/*" required /></td>
                </tr>

                <tr>
                    <td>Genre</td>
    <td>
        <select id="genre" name="genre" required>
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
    </td>
                </tr>

            </table>

            <input type="submit" value="Add Movie" />
            <input type="reset" value="Reset" />

        </form>

<%


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
<a href="AdminMenu.jsp" ><button>Home</button> </a> <a href="signout.jsp" ><button>Sign out</button> </a>
</body>
</html>
