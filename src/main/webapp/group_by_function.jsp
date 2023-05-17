<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@page import="java.util.*"%>
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
		select department_id, job_id, count(*) from employees
		group by department_id, job_id;
	*/
	sql = "SELECT department_Id, job_id, COUNT(*) 부서인원 from employees GROUP BY GROUPING SETS(department_id, job_id)";
	stmt = conn.prepareStatement(sql);
	rs = stmt.executeQuery();
	System.out.println(stmt + "<--- group_by_function stmt");
	System.out.println(rs + "<--- group_by_function rs");
	
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("department_id", rs.getInt("department_id"));
		m.put("job_id", rs.getString("job_id"));
		m.put("부서인원", rs.getInt("부서인원"));
		list.add(m);
	}
	System.out.println(list + "<--- group_by_function list");
	
	String rollupSql = null;
	PreparedStatement rollupStmt = null;
	ResultSet rollupRs = null;
	
	/*
		select department_id, job_id, count(*) 
		from employees
		group by rollup(department_id, job_id);
	*/
	rollupSql = "select department_id, job_id, count(*) 부서인원 from employees group by rollup(department_id, job_id)";
	rollupStmt = conn.prepareStatement(rollupSql);
	rollupRs = rollupStmt.executeQuery();
	System.out.println(rollupStmt + "<--- group_by_function rollupStmt");
	System.out.println(rollupRs + "<--- group_by_function rollupRs");
	
	ArrayList<HashMap<String, Object>> rollupList = new ArrayList<>();
	while(rollupRs.next()) {
		HashMap<String, Object> m2 = new HashMap<String, Object>();
		m2.put("department_id", rollupRs.getInt("department_id"));
		m2.put("job_id", rollupRs.getString("job_id"));
		m2.put("부서인원", rollupRs.getInt("부서인원"));

		rollupList.add(m2);
	}
	
	System.out.println(rollupList + "<--- group_by_function rollupList");
	
	String cubeSql = null;
	PreparedStatement cubeStmt = null;
	ResultSet cubeRs = null;
	
	/*
		select department_id, job_id, count(*) 
		from employees
		group by cube(department_id, job_id)
	*/
	cubeSql = "select department_id, job_id, count(*) 부서인원 from employees group by cube(department_id, job_id)";
	cubeStmt = conn.prepareStatement(cubeSql);
	cubeRs = cubeStmt.executeQuery();
	System.out.println(cubeStmt + "<--- group_by_function cubeStmt");
	System.out.println(cubeRs + "<--- group_by_function cubeRs");
	
	ArrayList<HashMap<String, Object>> cubeList = new ArrayList<>();
	while(cubeRs.next()) {
		HashMap<String, Object> m3 = new HashMap<String, Object>();
		m3.put("department_id", cubeRs.getInt("department_id"));
		m3.put("job_id", cubeRs.getString("job_id"));
		m3.put("부서인원", cubeRs.getInt("부서인원"));

		cubeList.add(m3);
	}
	System.out.println(cubeList + "<--- group_by_function cubeList");
	
	
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<div>
	<h1>GROUP BY 확장 함수 사용x 결과물</h1>
		<table>
			<tr>
				<td>부서id</td>
				<td>직업id</td>
				<td>부서인원</td>
			
			</tr>
			
			<%
				for( HashMap<String, Object> m : list){
				
			%>
					<tr>
						<td><%=(Integer)(m.get("department_id")) %></td>
						<td><%=(String)(m.get("job_id")) %></td>
						<td><%=(Integer)(m.get("부서인원")) %></td>
						
					</tr>
			<% 
				}
			%>
		</table>	
	</div>
	<div>
	<h1>rollup사용결과물</h1>
		<table>
			<tr>
				<td>부서id</td>
				<td>직업id</td>
				<td>부서인원</td>
			
			</tr>
			
			<%
				for( HashMap<String, Object> m2 : rollupList){
				
			%>
					<tr>
						<td><%=(Integer)(m2.get("department_id")) %></td>
						<td><%=(String)(m2.get("job_id")) %></td>
						<td><%=(Integer)(m2.get("부서인원")) %></td>
						
					</tr>
			<% 
				}
			%>
		</table>	
	</div>
	<div>
	<h1>cube사용결과물</h1>
		<table>
			<tr>
				<td>부서id</td>
				<td>직업id</td>
				<td>부서인원</td>
			
			</tr>
			
			<%
				for( HashMap<String, Object> m3 : cubeList){
				
			%>
					<tr>
						<td><%=(Integer)(m3.get("department_id")) %></td>
						<td><%=(String)(m3.get("job_id")) %></td>
						<td><%=(Integer)(m3.get("부서인원")) %></td>
						
					</tr>
			<% 
				}
			%>
		</table>	
	</div>
</body>
</html>