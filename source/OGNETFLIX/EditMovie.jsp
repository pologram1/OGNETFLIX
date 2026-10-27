<%@ page import="java.lang.*"%>
<%//Import the ut package for accessing the database %>
<%@ page import="ut.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>


<html>
    <head>
        <title>OG Netflix - Edit Movie</title>
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

        String currentPage="EditMovie.jsp";
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
                //Update the current page attribute
                session.setAttribute("currentPage", currentPage);

                //Retrieve the selected movie
                String movieId = request.getParameter("movieId");

                //Create the appDBMnger object
                applicationDBManager appDBMnger = new applicationDBManager();

                //Call the getMovie method. This method returns the information of the selected movie
                ResultSet movie = appDBMnger.getMovie(movieId);

                //Verify that the movie exists
                if (movie.next()){ //EXAMPLE: 1 | The Dark Knight | Action | Batman fights... | Christian Bale, Heath Ledger | Christopher Nolan | 2008 | USA | darkknight.jpg
                    //Genre of the movie, to keep it selected in the list
                    String genre = movie.getString(3);
%>
                    <h2>Edit Movie</h2>

                    <form action="UpdateMovie.jsp" method="post">
                        <%//The id of the movie that is edited %>
                        <input type="hidden" name="movieId" value="<%= movie.getString(1) %>">
                        <table border="1">
                            <tr>
                                <td>Title</td>
                                <td><input type="text" name="title" value="<%= movie.getString(2) %>" required></td>
                            </tr>
                            <tr>
                                <td>Genre</td>
                                <td>
                                    <select name="genre" required>
                                        <option value="Action" <%= "Action".equals(genre) ? "selected" : "" %>>Action</option>
                                        <option value="Adventure" <%= "Adventure".equals(genre) ? "selected" : "" %>>Adventure</option>
                                        <option value="Comedy" <%= "Comedy".equals(genre) ? "selected" : "" %>>Comedy</option>
                                        <option value="Drama" <%= "Drama".equals(genre) ? "selected" : "" %>>Drama</option>
                                        <option value="Family" <%= "Family".equals(genre) ? "selected" : "" %>>Family</option>
                                        <option value="History" <%= "History".equals(genre) ? "selected" : "" %>>History</option>
                                        <option value="Science Fiction" <%= "Science Fiction".equals(genre) ? "selected" : "" %>>Science Fiction</option>
                                        <option value="Thriller" <%= "Thriller".equals(genre) ? "selected" : "" %>>Thriller</option>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td>Plot</td>
                                <td><input type="text" name="plot" value="<%= movie.getString(4) %>" required></td>
                            </tr>
                            <tr>
                                <td>Actors</td>
                                <td><input type="text" name="actors" value="<%= movie.getString(5) %>" required></td>
                            </tr>
                            <tr>
                                <td>Director</td>
                                <td><input type="text" name="director" value="<%= movie.getString(6) %>" required></td>
                            </tr>
                            <tr>
                                <td>Release Year</td>
                                <td><input type="number" name="releaseYear" min="1900" max="2026" value="<%= movie.getString(7) %>" required></td>
                            </tr>
                            <tr>
                                <td>Country</td>
                                <td><input type="text" name="country" value="<%= movie.getString(8) %>" required></td>
                            </tr>
                            <tr>
                                <td>Picture</td>
                                <td>
                                    <img src="images/<%= movie.getString(9) %>" width="120"> <br>
                                    <%//Old picture of the movie %>
                                    <input type="hidden" name="oldPicture" value="<%= movie.getString(9) %>">
                                    <input type="file" name="picture" accept="image/*">
                                </td>
                            </tr>
                        </table>
                        <br>
                        <input type="submit" value="Save Changes">
                    </form>
<%
                }else{
%>
                    <p>The movie does not exist.</p>
<%
                }

                //Close the ResultSet
                movie.close();
                //Close the connection to the database
                appDBMnger.close();
%>
                <a href="AdminMovieList.jsp"><button type="button">Cancel</button></a>
                <a href="AdminMenu.jsp"><button type="button">Home</button></a>
                <a href="signout.jsp"><button type="button">Sign out</button></a>
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

        }catch(Exception e){
            e.printStackTrace();
%>
            <h2>Error accessing database!</h2>
<%
        }finally{
            System.out.println("Finally");
        }
    }
%>
    </body>
</html>

