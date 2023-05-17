<%@page import="java.util.*"%>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.sql.*" %>
<%

	//2.모델 계층
	//db 연동
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	
	// db연동 변수 
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn + "접속");
	
	String sql = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	
	/*
		select department_id 부서id, count(*) 부서인원, sum(salary) 급여합계, round(avg(salary),1) 급여평균, max(salary) 최대급여, min(salary) 최소급여 
		from employees 
		where department_id is not null 
		group by department_id 
		having count(*) > 1 
		order by 부서인원 desc; 
	*/
	sql = "select department_id 부서id, count(*) 부서인원, sum(salary) 급여합계, round(avg(salary),1) 급여평균, max(salary) 최대급여, min(salary) 최소급여 from employees where department_id is not null group by department_id having count(*) > 1 order by 부서인원 desc";
	stmt = conn.prepareStatement(sql);
	rs = stmt.executeQuery();
	System.out.println(stmt + "stmt");
	System.out.println(rs + "rs");
	
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("부서id", rs.getInt("부서id"));
		m.put("부서인원", rs.getInt("부서인원"));
		m.put("급여합계", rs.getInt("급여합계"));
		m.put("급여평균", rs.getInt("급여평균"));
		m.put("최대급여", rs.getInt("최대급여"));
		m.put("최소급여", rs.getInt("최소급여"));
		list.add(m);
	}
	System.out.println(list + "list");



%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Insert title here</title>
</head>
<body>
	<h1>Employees table GROUP BY Test</h1>
	<table>
		<tr>
			<td>부서id</td>
			<td>부서인원</td>
			<td>급여합계</td>
			<td>급여평균</td>
			<td>최대급여</td>
			<td>최소급여</td>
		</tr>
		
		<%
			for( HashMap<String, Object> m : list){
			
		%>
				<tr>
					<td><%=(Integer)(m.get("부서id")) %></td>
					<td><%=(Integer)(m.get("부서인원")) %></td>
					<td><%=(Integer)(m.get("급여합계")) %></td>
					<td><%=(Integer)(m.get("급여평균")) %></td>
					<td><%=(Integer)(m.get("최대급여")) %></td>
					<td><%=(Integer)(m.get("최소급여")) %></td>
				</tr>
		<% 
			}
		%>
	</table>	
	
</body>
</html>