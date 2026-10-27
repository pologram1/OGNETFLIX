
<%@ page import="java.lang.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>
<%//Import the ut package for accessing the database %>
<%@ page import="ut.*"%>
<html>
    <head>
        <title>OG Netflix - Returned Movies</title>
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

        String currentPage="PastList.jsp";
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
                    %>
                    <h1>Returned Movies</h1>

                    <%
                    //Create the appDBMnger object
                    applicationDBManager appDBMnger = new applicationDBManager();

                    //Call the returnedMovieslist method
                    //This method returns all returned movies ordered by genre
					//The customer is the user of the session
                    ResultSet movies=appDBMnger.returnedMovieslist(userName);
                    int count=0;

                    //Genre of the previous movie, to know when a new genre starts
                    String lastGenre="";
                    %>
                    <table border=1>
                    <%
                    //Iterate over the ResultSet
                    while (movies.next()){
                        //Count each movie
                        count++;

                        //Genre of this movie
                        String genre=movies.getString(3);
                        if (genre==null) genre="No genre";

                        //If the genre changed, print the name of the new genre
                        if (!genre.equals(lastGenre)){
                            lastGenre=genre;%>
                            <tr><td colspan="4"><h3><%=genre%></h3></td></tr>
                            <tr>
                                <td>Picture</td><td>Title</td><td>Release year</td> <td>Description</td>
                            </tr>
                        <%}%>
                        <tr>
                        <td><img src="images/<%=movies.getString(5)%>" width="60"></td>
                        <td><%=movies.getString(2)%></td>
                        <td><%=movies.getString(4)%></td>
                        <td>
                            <form action="MovieDescription.jsp" method="post">
                                <input type="hidden" name="movieId" value="<%=movies.getString(1)%>">
                                <input type="submit" value="Movie description">
                            </form>
                        </td>
                        </tr>
                    <%}%>
                    </table>

                    Returned Movies: <%=count%> <br><br>

                    <a href="netflixMenu.jsp"><button>Home</button></a> |
                    <a href="signout.jsp"><button>Sign out</button></a>
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

