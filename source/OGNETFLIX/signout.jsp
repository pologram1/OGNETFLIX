<%-- Clears the signed-in session user and redirects to the login form. --%>
<%@ page import="java.lang.*"%>

<%
	session.setAttribute("userName",null);
	session.setAttribute("currentPage",null);
	response.sendRedirect("Netflixlogin.html");

%>
