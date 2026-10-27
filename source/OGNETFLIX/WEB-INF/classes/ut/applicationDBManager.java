/* Server catalog, queue, and rental operations called by JSP pages. Deactivation preserves IDs; rental return/dispatch logic lives here. Separate from the browser model. */

//This class belongs to the ut package
package ut;

//Import the java.sql package for managing the ResulSet objects
import java.sql.* ;

/******
	This class manage a connection to the database and it should be accessed from the front End. Therefore,
	this class must contain all needed methods for manipulating data without showing how to access the database

*/
public class applicationDBManager{

	//myDBConn is an MySQLCompleteConnector object for accessing to the database
	private MySQLCompleteConnector myDBConn;
	
	/********
		Default constructor
		It creates a new MySQLCompleteConnector object and open a connection to the database
		@parameters:
		
	*/
	public applicationDBManager(){
		//Create the MySQLCompleteConnector object
		myDBConn = new MySQLCompleteConnector();
		
		//Open the connection to the database
		myDBConn.doConnection();
	}
	


	/***
		listAllMovies method
			List all Movies in the database
			@parameters:
			@returns:
				A ResultSet containing all movies in the database
	*/
	public ResultSet listAllMovies()
	{
		
		//Declare function variables
		String fields, tables, whereClause;
		
		//Define the table where the selection is performed
		tables="movie";
		//Define the list fields list to retrieve from the table movie
		fields ="movieId,title,genre,plot,actors,director,releaseYear,country,picture";
		//Only the movies that are available (active=1)
		whereClause="active=1";
		
		System.out.println("Movies...");
		
		//Return the ResultSet containing all Movies in the database
		return myDBConn.doSelect(fields, tables, whereClause);
		
		
	}
	
	/*******
	listCustomers method
		List all users with the customer role (rol2)
		@parameters:
		@returns:
		A ResultSet containing the userName, Name and Telephone of each customer
	*/
	public ResultSet listCustomers()
	{
		//Declare function variables
		String fields, tables, whereClause, orderBy;
		
		//Define the tables where the selection is performed
		tables="usergood, roleuser";
		//Define the list fields list to retrieve from the tables
		fields ="usergood.userName, usergood.Name, usergood.Telephone";
		//Only the users with the customer role
		whereClause="usergood.userName = roleuser.userName and roleuser.roleId='rol2'";
		//Order the customers by name
		orderBy="usergood.Name";
		
		System.out.println("listing customers...");
		
		//Return the ResultSet containing all customers
		return myDBConn.doSelect(fields, tables, whereClause, orderBy);
	}
	

	/*******
	addMovie method
		Insert a new movie in the database
		@parameters:
			title, plot, actors, director, releaseYear, country, picture, genre: the information of the movie
		@returns:
			true if the movie was inserted, false in other case
	*/
	public boolean addMovie(String title, String plot, String actors, String director, int releaseYear, String country, String picture, String genre)
	{
		boolean res;
		String table, values;
		
		//Define the table where the movie is inserted
		table = "movie";
		//Define the values of the movie. NULL is used because movieId is auto_increment
		values = "NULL, '" + fixQuote(title) + "', '" + fixQuote(plot) + "', '" + fixQuote(actors) + "', '" + fixQuote(director) + "', " + releaseYear + ", '" + fixQuote(country) + "', '" + fixQuote(picture) + "', '" + fixQuote(genre) + "', 1";
		
		//Insert the movie
		res = myDBConn.doInsert(table, values);
		System.out.println("Insertion result: " + res);
		return res;
	}
	
	
	/*******
	RemoveMovie method
		Remove one movie from the catalog (it is marked as not available)
		@parameters:
			movieId: the id of the movie
		@returns:
			true if the movie was removed, false in other case
	*/
	public boolean RemoveMovie(int movieId)
	{
		boolean res;
		String table, condition;
		
		//Define the table where the movie is removed
		table = "movie";
		//Only the selected movie
		condition = "movieId = " + movieId;
		
		//The movie is not deleted, it is marked as not available (active=0).
		//The customers that have it in the queue or at home keep it until it is removed or returned
		res = myDBConn.doUpdate(table, "active=0", condition);
		System.out.println("Update result: " + res);
		return res;
	}
	

	
	/*******
	getCustomer method
		Retrieve the information of one customer
		@parameters:
		customer: the userName of the customer
		@returns:
		A ResultSet containing the userName, Name and Telephone of the customer
	*/
	public ResultSet getCustomer(String customer)
	{
		//Declare function variables
		String fields, tables, whereClause;
		
		//Define the table where the selection is performed
		tables="usergood";
		//Define the list fields list to retrieve from the table
		fields ="userName, Name, Telephone";
		//Only the selected customer
		whereClause="userName='" + fixQuote(customer) + "'";
		
		System.out.println("getting customer...");
		
		//Return the ResultSet containing the customer
		return myDBConn.doSelect(fields, tables, whereClause);
	}
	
	/*******
		customerQueue method
			List the movies that are waiting in the queue of one customer
			@parameters:
				customer: the userName of the customer
			@returns:
				A ResultSet containing queuePosition, title, picture and movieId, ordered by the position in the queue
	*/
	public ResultSet customerQueue(String customer)
	{
		//Declare function variables
		String fields, tables, whereClause, orderBy;
		
		//Define the tables where the selection is performed
		tables="moviequeue, movie";
		//Define the list fields list to retrieve from the tables
		fields ="moviequeue.queuePosition, movie.title, movie.picture, movie.movieId";
		//Join moviequeue with movie, only the queue of the selected customer
		whereClause="moviequeue.movieId = movie.movieId and moviequeue.userName='" + fixQuote(customer) + "'";
		//Order the movies by their position in the queue
		orderBy="moviequeue.queuePosition";
		
		System.out.println("listing customer queue...");
		
		//Return the ResultSet containing the queue of the customer
		return myDBConn.doSelect(fields, tables, whereClause, orderBy);
	}
	
	/*******
		customerRentals method
			List the movies that were mailed to one customer
			@parameters:
				customer: the userName of the customer
			@returns:
				A ResultSet containing rentalId, title, status, picture and movieId
	*/
	public ResultSet customerRentals(String customer)
	{
		//Declare function variables
		String fields, tables, whereClause, orderBy;
		
		//Define the tables where the selection is performed
		tables="movierental, movie";
		//Define the list fields list to retrieve from the tables
		fields ="movierental.rentalId, movie.title, movierental.status, movie.picture, movie.movieId";
		//Join movierental with movie, only the movies of the selected customer
		whereClause="movierental.movieId = movie.movieId and movierental.userName='" + fixQuote(customer) + "'";
		//Order the movies in the order they were mailed
		orderBy="movierental.rentalId";
		
		System.out.println("listing customer rentals...");
		
		//Return the ResultSet containing the movies mailed to the customer
		return myDBConn.doSelect(fields, tables, whereClause, orderBy);
	}
	
	/*******
		registerReturn method
			Register that a customer returned a movie. Only a watched movie can be returned.
			If the customer does not have another movie at home, the next movie of his queue is mailed
			@parameters:
				customer: the userName of the customer
				rentalId: the id of the rental that is returned
			@returns:
				true if the return was registered, false in other case
	*/
	public boolean registerReturn(String customer, String rentalId)
	{
		boolean res;
		
		//Change the status to returned. Only a watched movie of this customer can be returned
		res=myDBConn.doUpdate("movierental", "status='returned'",
			"rentalId=" + rentalId + " and userName='" + fixQuote(customer) + "' and status='watched'");
		
		//If the customer does not have a movie at home, mail the next movie of his queue
		if (res && !hasMovieAtHome(customer)){
			mailNextMovie(customer);
		}
		return res;
	}
	
	/*******
		hasMovieAtHome method
			Verify if a customer has a movie at home
			@parameters:
				customer: the userName of the customer
			@returns:
				true if the customer has a movie at home, false in other case
	*/
	public boolean hasMovieAtHome(String customer)
	{
		boolean atHome=false;
		try{
			//Search a movie of the customer with status mailed or watched
			ResultSet res=myDBConn.doSelect("rentalId", "movierental",
				"userName='" + fixQuote(customer) + "' and (status='mailed' or status='watched')");
			atHome=res.next();
			res.close();
		} catch(Exception e){
			e.printStackTrace();
		}
		return atHome;
	}
	
	/*******
		mailNextMovie method
			Mail the first movie of the queue of a customer. The movie is inserted in movierental
			with status mailed, and the other movies of the queue move one place up
			@parameters:
				customer: the userName of the customer
			@returns:
				true if a movie was mailed, false if the queue was empty
	*/
	public boolean mailNextMovie(String customer)
	{
		boolean res=false;
		try{
			//Search the first movie of the queue
			ResultSet next=myDBConn.doSelect("movieId", "moviequeue",
				"userName='" + fixQuote(customer) + "' and queuePosition=1");
			
			if (next.next()){
				//Store the movieId before the next query
				String movieId=next.getString(1);
				next.close();
				
				// Insert the movie in movierental with status mailed
				res=myDBConn.doInsert("movierental", "null, '" + fixQuote(customer) + "', " + movieId + ", 'mailed'");
				
				if (res){
					//Delete the movie from the queue
					myDBConn.doDelete("moviequeue", "userName='" + fixQuote(customer) + "' and queuePosition=1");
					//The other movies of the queue move one place up
					myDBConn.doUpdate("moviequeue", "queuePosition=queuePosition-1", "userName='" + fixQuote(customer) + "'");
				}
			}else{
				//The queue of the customer is empty
				next.close();
			}
		} catch(Exception e){
			e.printStackTrace();
		}
		return res;
	}
	
	
	/*******
		getMovie method
			Retrieve the complete description of one movie
			@parameters:
				movieId: the id of the movie
			@returns:
				A ResultSet containing movieId, title, genre, plot, actors, director, releaseYear, country and picture
	*/
	public ResultSet getMovie(String movieId)
	{
		//Declare function variables
		String fields, tables, whereClause;
		
		//Define the table where the selection is performed
		tables="movie";
		//Define the list fields list to retrieve from the table
		fields ="movieId, title, genre, plot, actors, director, releaseYear, country, picture";
		//Only the selected movie
		whereClause="movieId=" + movieId;
		
		System.out.println("getting movie...");
		
		//Return the ResultSet containing the movie
		return myDBConn.doSelect(fields, tables, whereClause);
	}
	
	
	/*******
	searchMovieByGenre method
		List the movies of one genre
		@parameters:
		genre: the genre selected by the customer
		@returns:
		A ResultSet containing movieId, title, genre, releaseYear and picture, ordered by title
	*/
	public ResultSet searchMovieByGenre(String genre)
	{
		//Declare function variables
		String fields, tables, whereClause, orderBy;
		
		//Define the table where the selection is performed
		tables="movie";
		//Define the list fields list to retrieve from the table
		fields ="movieId, title, genre, releaseYear, picture";
		//Only the movies of the selected genre
		whereClause="genre='" + fixQuote(genre) + "' and active=1";
		//Order the movies by title
		orderBy="title";
		
		System.out.println("searching movies by genre...");
		
		//Return the ResultSet containing the movies of the genre
		return myDBConn.doSelect(fields, tables, whereClause, orderBy);
	}
	
		/*******
		addToQueue method
		Add a movie to the end of the queue of a customer.
		If the customer does not have a movie at home, the first movie of his queue is mailed
		@parameters:
			customer: the userName of the customer
			movieId: the id of the movie
			@returns:
		true if the movie was added, false if it is in the queue, at home or not available
	*/
	public boolean addToQueue(String customer, String movieId)
	{
		boolean res=false;
		try{
			//Verify that the movie is not already in the queue of the customer
			ResultSet inQueue=myDBConn.doSelect("queueId", "moviequeue",
				"userName='" + fixQuote(customer) + "' and movieId=" + movieId);
			boolean exists=inQueue.next();
			inQueue.close();
			
			//Verify that the customer does not have the movie at home (mailed or watched)
			ResultSet atHome=myDBConn.doSelect("rentalId", "movierental",
				"userName='" + fixQuote(customer) + "' and movieId=" + movieId + " and (status='mailed' or status='watched')");
			if (atHome.next()) exists=true;
			atHome.close();
			
			//Verify that the movie is available (a removed movie can not be added)
			ResultSet available=myDBConn.doSelect("movieId", "movie", "movieId=" + movieId + " and active=1");
			if (!available.next()) exists=true;
			available.close();
			
			if (!exists){
				//Insert the movie in the queue. The trigger moviequeue_position assigns the position
				res=myDBConn.doInsert("moviequeue", "null, '" + fixQuote(customer) + "', " + movieId + ", 0");
				
				//If the customer does not have a movie at home, mail the first movie of his queue
				if (res && !hasMovieAtHome(customer)){
					mailNextMovie(customer);
				}
			}
		} catch(Exception e){
			e.printStackTrace();
		}
		return res;
	}
	
	
	/*******
	listMoviesByGenre method
		List all the movies of the database ordered by genre
		@parameters:
		@returns:
		A ResultSet containing movieId, title, genre, releaseYear and picture, ordered by genre and title
	*/
	public ResultSet listMoviesByGenre()
	{
		//Declare function variables
		String fields, tables, whereClause, orderBy;
		
		//Define the table where the selection is performed
		tables="movie";
		//Define the list fields list to retrieve from the table
		fields ="movieId, title, genre, releaseYear, picture";
		//Only the movies that are available
		whereClause="active=1";
		//Order the movies by genre, and inside each genre by title
		orderBy="genre, title";
		
		System.out.println("listing movies by genre...");
		
		//Return the ResultSet containing all the movies
		return myDBConn.doSelect(fields, tables, whereClause, orderBy);
	}
	
	
		/*******
		customerCurrentRentals method
			List the movies that one customer has at home
			@parameters:
				customer: the userName of the customer
			@returns:
				A ResultSet containing rentalId, title, status, picture and movieId
	*/
	public ResultSet customerCurrentRentals(String customer)
	{
		//Declare function variables
		String fields, tables, whereClause, orderBy;
		
		//Define the tables where the selection is performed
		tables="movierental, movie";
		//Define the list fields list to retrieve from the tables
		fields ="movierental.rentalId, movie.title, movierental.status, movie.picture, movie.movieId";
		//Join movierental with movie, only the movies at home of the selected customer
		whereClause="movierental.movieId = movie.movieId and movierental.userName='" + fixQuote(customer) + "'";
		whereClause+=" and (movierental.status='mailed' or movierental.status='watched')";
		//Order the movies in the order they were mailed
		orderBy="movierental.rentalId";
		
		System.out.println("listing current rentals...");
		
		//Return the ResultSet containing the movies at home of the customer
		return myDBConn.doSelect(fields, tables, whereClause, orderBy);
	}
	
	
		/*******
		removeFromQueue method
			Remove a movie from the queue of a customer. The movies after it move one place up
			@parameters:
				customer: the userName of the customer
				movieId: the id of the movie
			@returns:
				true if the movie was removed, false if the movie was not in the queue
	*/
	public boolean removeFromQueue(String customer, String movieId)
	{
		boolean res=false;
		try{
			// Search the position of the movie in the queue
			ResultSet movie=myDBConn.doSelect("queuePosition", "moviequeue",
				"userName='" + fixQuote(customer) + "' and movieId=" + movieId);
			
			if (movie.next()){
				//Store the position before the next query
				String position=movie.getString(1);
				movie.close();
				
				// Delete the movie from the queue
				res=myDBConn.doDelete("moviequeue", "userName='" + fixQuote(customer) + "' and movieId=" + movieId);
				
				// The movies after the removed movie move one place up
				myDBConn.doUpdate("moviequeue", "queuePosition=queuePosition-1",
					"userName='" + fixQuote(customer) + "' and queuePosition>" + position);
			}else{
				//The movie is not in the queue of the customer
				movie.close();
			}
		} catch(Exception e){
			e.printStackTrace();
		}
		return res;
	}
	
	/*******
		markWatched method
			Mark a movie mailed to a customer as watched
			@parameters:
				customer: the userName of the customer
				rentalId: the id of the rental
			@returns:
				true if the movie was marked as watched, false in other case
	*/
	public boolean markWatched(String customer, String rentalId)
	{
		//Change the status to watched. Only a mailed movie of this customer can be marked
		return myDBConn.doUpdate("movierental", "status='watched'",
			"rentalId=" + rentalId + " and userName='" + fixQuote(customer) + "' and status='mailed'");
	}
	
	
	/*******
	returnedMovieslist method
		List the movies that one customer has returned
		@parameters:
			customer: the userName of the customer
		@returns:
			A ResultSet containing movieId, title, genre, releaseYear and picture of the returned movies, ordered by genre and title
	*/
	public ResultSet returnedMovieslist(String customer)
	{
		//Declare function variables
		String fields, tables, whereClause, orderBy;
		
		//Define the tables where the selection is performed
		tables="movie, movierental";
		//Define the list fields list to retrieve from the tables
		fields ="DISTINCT movie.movieId, movie.title, movie.genre, movie.releaseYear, movie.picture";
		//Join movie and movierental, only the returned movies of the selected customer
		whereClause="movie.movieId = movierental.movieId and movierental.status='returned'";
		whereClause+=" and movierental.userName='" + fixQuote(customer) + "'";
		//Order the movies by genre and title
		orderBy="movie.genre, movie.title";
		
		System.out.println("listing returned movies...");
		
		//Return the ResultSet containing the returned movies of the customer
		return myDBConn.doSelect(fields, tables, whereClause, orderBy);
	}
	
	/*******
	EditMovie method
		Update the information of one movie
		@parameters:
			movieId: the id of the movie
			title, plot, actors, director, releaseYear, country, picture, genre: the new information of the movie
		@returns:
			true if the movie was updated, false in other case
	*/
	public boolean EditMovie(int movieId, String title, String plot, String actors, String director, int releaseYear, String country, String picture, String genre)
	{
		boolean res;
		String table, changes, condition;
		
		//Define the table to update
		table = "movie";
		//Define the new values of the movie
		changes = "title='" + fixQuote(title) + "', plot='" + fixQuote(plot) + "', actors='" + fixQuote(actors) + "', director='" + fixQuote(director) + "', ";
		changes += "releaseYear=" + releaseYear + ", country='" + fixQuote(country) + "', picture='" + fixQuote(picture) + "', genre='" + fixQuote(genre) + "'";
		//Only the selected movie
		condition = "movieId = " + movieId;
		
		//Update the movie
		res = myDBConn.doUpdate(table, changes, condition);
		System.out.println("Update result: " + res);
		return res;
	}
	
	
	/*******
		fixQuote method
		Duplicate the single quotes of a text to avoid a query injection
		@parameters:
		text: the text that will be used inside a SQL statement
		@returns:
		The text with the single quotes duplicated
	*/
	private String fixQuote(String text)
	{
		if (text==null) return "";
		return text.replace("\\", "\\\\").replace("'", "''");
	}
	
	

	/*********
		close method
			Close the connection to the database.
			This method must be called at the end of each page/object that instatiates a applicationDBManager object
			@parameters:
			@returns:
	*/
	public void close()
	{
		//Close the connection
		myDBConn.closeConnection();
	}

	/***********
		Debugging method
			This method creates an applicationDBManager object, retrieves all movies in the database, and close the connection to the database
			@parameters:
				args[]: String array 
			@returns:
	*/
	public static void main(String[] args)
	{
		
		try{
			//Create a applicationDBManager object
			applicationDBManager appDBMnger = new applicationDBManager();
			System.out.println("Connecting...");
			System.out.println(appDBMnger.toString());
			
			//Call the listAllMovies in order to retrieve all MOVIES in the database
			ResultSet res=appDBMnger.listAllMovies();
			
			//Iterate over the ResulSet containing all movies in the database, and count how many tuples were retrieved
			int count=0;
			while (res.next()){
				count++;	
			}
			//Print the results count
			System.out.println("Count:"  + count);
			
			//Close the ResulSet
			res.close();
			//Close the database connection
			appDBMnger.close();
			
		} catch(Exception e)
		{
			//Nothing to show!
			e.printStackTrace();
		}		
	}

}
