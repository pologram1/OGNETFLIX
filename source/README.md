# Original Java/JSP application

Collaborators: **Miguel A. De Jesus** and **Ricardo J. Lopez Ortiz**.

This directory preserves the academic application's page names and Tomcat layout. It is separate from the browser demo in `src/`. Comments explain page responsibilities; the original request handling, SQL operations, session checks, and exception redirects are retained.

## Start reading here

| Area | Files | Purpose |
| --- | --- | --- |
| Sign in and sign up | `Netflixlogin.html`, `NetflixSignUp.html`, `validationHashing.jsp`, `addUser.jsp`, `signout.jsp` | Forms, authentication, account creation, session routing, and sign out. |
| Customer entry | `netflixMenu.jsp` | Customer navigation. |
| Discovery | `MovieList.jsp`, `SearchMovie.jsp`, `MovieDescription.jsp` | Active catalog, genre search, movie details, and queue display. |
| Queue actions | `addToQueue.jsp` | Adds a movie to the customer's queue. The removal handler is referenced but absent from the archive. |
| Rental views | `CurrentList.jsp`, `PastList.jsp` | Current and returned rentals. |
| Rental actions | `markWatched.jsp` | Marks the customer's rental as watched. See the archived handler mismatch below for returns. |
| Administrator entry | `AdminMenu.jsp`, `CustomerList.jsp`, `UserReview.jsp` | Admin navigation and customer rental management. |
| Catalog administration | `AdminMovieList.jsp`, `AddMovie.jsp`, `EditMovie.jsp`, `UpdateMovie.jsp` | Catalog list, add/edit forms, and update action. Save/deactivation handlers are referenced but absent from the archive. |
| Database logic | `WEB-INF/classes/ut/` | Java business and persistence helpers used by the JSP pages. |
| Images | `images/` | Supplied poster assets, compressed for repository size. |

## Java classes

- `applicationDBManager`: movie metadata, active catalog queries, customer queues, rental state changes, and current/returned listings. Begin with `registerReturn`, `hasMovieAtHome`, and `mailNextMovie` to understand the rental cycle. `RemoveMovie` sets the availability flag instead of deleting the row.
- `applicationDBAuthenticationGoodComplete`: database authentication, role/page navigation checks, account creation, and the archived hashing helper.
- `MySQLCompleteConnector`: connection lifecycle and SQL helper methods. Connection configuration comes from the three `OGNETFLIX_DB_*` environment variables documented in the root README.

The lowercase class names and existing `WEB-INF/classes/ut` source location are retained because the JSP imports and original project refer to them. Compile `.java` files into this package path for Tomcat; do not commit generated `.class` files.

## Runtime requirements

Use a compatible JDK, Apache Tomcat, MySQL, MySQL Connector/J, and Apache Commons Codec (imported by the authentication class). Put required runtime JARs in `WEB-INF/lib`, compile the Java classes with those dependencies on the classpath, and deploy `OGNETFLIX/` to Tomcat. The archive does not contain a SQL dump; restore the original schema and seed data separately. GitHub Pages cannot execute these JSP pages.

## Maintenance boundaries

### Incomplete archived page wiring

The supplied archive references `SaveMovie.jsp`, `RemoveMovie.jsp`, and `removeFromQueue.jsp`, but does not include those handlers. Also, `UserReview.jsp` posts rental returns to `registerReturn.jsp`, while that supplied file reads movie metadata and calls `addMovie` instead of `registerReturn`. The Java manager contains the intended return method. These original inconsistencies are documented here rather than silently repaired during the readability cleanup. The independently implemented browser demo has its own tested rental flow.

This is preserved academic code. The SQL helpers build SQL strings and the authentication helper retains its original hashing scheme. A production backend would need a separate security and persistence review, including parameterized queries, modern password hashing, authorization, and transaction handling. Read the archived behavior as implemented; the browser demo's validation is not a security layer for this server application.
