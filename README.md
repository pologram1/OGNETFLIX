# OGNETFLIX

Collaborators: **Miguel A. De Jesus** and **Ricardo J. Lopez Ortiz**.

A collaborative academic movie-rental application for CPEN 410, Universidad Ana G. Méndez, Gurabo. This repository contains the original Java/JSP project and a browser adaptation that runs on GitHub Pages.

## Run the browser demo

Open **https://pologram1.github.io/OGNETFLIX/**. No installation or database is needed.

To run it locally, clone this repository, then start a static server in its root:

```sh
python3 -m http.server 8080
```

Open http://localhost:8080. A server is needed because the app uses JavaScript modules.

### Try the complete rental workflow

1. In the Member workspace, open a movie and add it to the queue.
2. Switch to Administrator and dispatch the selected member’s next active movie.
3. Switch back to Member, open At home, and mark the rental as watched.
4. Switch to Administrator and register the return. The next active queued title dispatches automatically.
5. Open History to see the completed rental.

The administrator workspace also creates local demo profiles and adds, edits, deactivates, and reactivates movies. Deactivation preserves queues and rental history. Poster uploads accept JPEG, PNG, or WebP files up to 1 MB.

## Browser demo scope

- The workspace switch demonstrates member/admin workflows. It is **not authentication** or a security boundary.
- Data is saved in this browser’s local storage, independently on each device. Do not enter private information.
- No films are streamed, shipped, or sold. The rental actions are simulations.
- The movie posters come from the supplied academic archive. Descriptions and display metadata are sample catalog content for this browser adaptation; Ben 10’s exact release year is left unset.
- Changes to the browser demo do not alter the original Java database or JSP application.

## Original Java/JSP source

`source/OGNETFLIX/` contains the supplied JSP/HTML pages, Java sources, and poster assets. Compiled `.class` files, embedded database credentials, and the report containing student identifiers are not included.

The only Java configuration changes replace hard-coded database connection settings with environment variables and update the MySQL driver class name. JSP exception redirects and application navigation are retained.

To run the original application, use Apache Tomcat, a compatible JDK, MySQL, and MySQL Connector/J. Restore your original `og_netflix` schema and seed data (not supplied in this archive). Set these environment variables before starting Tomcat:

```sh
export OGNETFLIX_DB_URL='jdbc:mysql://localhost:3306/og_netflix'
export OGNETFLIX_DB_USER='your_local_database_user'
export OGNETFLIX_DB_PASSWORD='your_local_database_password'
```

On Windows PowerShell, use `$env:OGNETFLIX_DB_URL`, `$env:OGNETFLIX_DB_USER`, and `$env:OGNETFLIX_DB_PASSWORD` instead. Keep the real values outside this repository.

Place Connector/J in the application’s `WEB-INF/lib` directory, compile the Java sources into `WEB-INF/classes`, and deploy `source/OGNETFLIX` to Tomcat. The archived project is academic source, not a production-ready service.

## Development

```sh
npm test
```

Domain tests cover queue ordering, duplicate prevention, one-rental limits, watched/return rules, automatic dispatch, inactive titles, profile isolation, and preservation of existing rental references.

Pushes to `main` validate the browser model and publish only the frontend files and assets through GitHub Actions. GitHub Pages serves the browser adaptation; it does not execute Java or JSP.

## Credits

Original academic project: Miguel A. De Jesus and Ricardo J. Lopez Ortiz. Browser adaptation prepared for the Polo Studios portfolio. Poster artwork belongs to its respective owners and is included as part of the supplied academic project assets; no license to third-party artwork is asserted.
