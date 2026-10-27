
<%@ page import="java.lang.*"%>
<%//Import the ut package for accessing the database %>
<%@ page import="ut.*"%>
<%//Import the java.sql package to use the ResultSet class %>
<%@ page import="java.sql.*"%>

<html>
    <head>
        <title>OG Netflix - Update Movie</title>
    </head>
    <body>
<%
    //Check the authentication process
    if ((session.getAttribute("userName")==null) || (session.getAttribute("currentPage")==null)){
        session.setAttribute("currentPage", null);
        session.setAttribute("userName", null);

        //Return to the login page
        response.sendRedirect("Netflixlogin.html");
        return;
    }
    else{

        String currentPage="UpdateMovie.jsp";
        String userName = session.getAttribute("userName").toString();
        String previousPage = session.getAttribute("currentPage").toString();

        //Try to connect the database using the applicationDBAuthenticationGoodComplete class
        try{
            //Create the appDBAuth object
            applicationDBAuthenticationGoodComplete appDBAuth = new applicationDBAuthenticationGoodComplete();

            //Call the verifyUser method
            ResultSet res=appDBAuth.verifyUser(userName, currentPage, previousPage);

            //Verify if the user has permission to visit this page
            if (res.next()){

                //Update the current page attribute
                session.setAttribute("currentPage", currentPage);

                //Retrieve the fields of the form of EditMovie.jsp
                int movieId = Integer.parseInt(request.getParameter("movieId"));
                String title = request.getParameter("title");
                String plot = request.getParameter("plot");
                String actors = request.getParameter("actors");
                String director = request.getParameter("director");
                int releaseYear = Integer.parseInt(request.getParameter("releaseYear"));
               
				String country = request.getParameter("country");
				String picture = request.getParameter("picture");
				String oldPicture = request.getParameter("oldPicture");
				String genre = request.getParameter("genre");

				//Keep the previous picture if no new picture is selected
					if (picture == null || picture.isEmpty()) {
					picture = oldPicture;
					}

                //Create the appDBMnger object
                applicationDBManager appDBMnger = new applicationDBManager();

                //Call the EditMovie method. This method updates the movie
                boolean updated=appDBMnger.EditMovie(movieId, title, plot, actors, director, releaseYear, country, picture, genre);

                //Close the connection to the database
                appDBMnger.close();

                //Verify if the movie was updated
                if (updated){
%>
                    <h1>OG Netflix</h1>
                    <p>Movie updated successfully!</p>
<%
                }else{
%>
                    <h1>OG Netflix</h1>
                    <p>Error updating movie!</p>
<%
                }
%>
               
			<a href="AdminMovieList.jsp">Movie Manager</a>

<%
            }else{
                //Close any session associated with the user
                session.setAttribute("userName", null);

                //Return to the login page
                response.sendRedirect("Netflixlogin.html");
            }

            res.close();

            //Close the connection to the database
            appDBAuth.close();

        }catch(Exception e){
            e.printStackTrace();
%>
            <h1>OG Netflix</h1>
            <p>Error updating movie!</p>
            <a href="AdminMovieList.jsp">Movie Manager</a>
<%
        }finally{
            System.out.println("Finally");
        }
    }
%>
<br><a href="AdminMenu.jsp"><button>Home</button></a> | <a href="signout.jsp"><button>Sign out</button></a>
    </body>
</html>

