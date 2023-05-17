<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="EUC-KR"%>
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
	
	String nvlSql = null;
	PreparedStatement nvlStmt = null;
	ResultSet nvlRs = null;
	
	nvlSql = "select name, nvl(first_day, 0) 결과 from onepiece";
	nvlStmt = conn.prepareStatement(nvlSql);
	nvlRs = nvlStmt.executeQuery();
	System.out.println(nvlStmt + "<--- onepiece_nvl_test nvlStmt");
	System.out.println(nvlRs + "<--- onepiece_nvl_test nvlRs");
	
	ArrayList<HashMap<String, Object>> nvlList = new ArrayList<>();
	while(nvlRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("이름", nvlRs.getString("name"));
		m.put("결과", nvlRs.getInt("결과"));
		nvlList.add(m);
	}
	
	String nvl2Sql = null;
	PreparedStatement nvl2Stmt = null;
	ResultSet nvl2Rs = null;
	
	nvl2Sql = "select name, nvl2(first_day, 'success', 'fail') 결과 from onepiece";
	nvl2Stmt = conn.prepareStatement(nvl2Sql);
	nvl2Rs = nvl2Stmt.executeQuery();
	System.out.println(nvl2Stmt + "<--- onepiece_nvl_test nvl2Stmt");
	System.out.println(nvl2Rs + "<--- onepiece_nvl_test nvl2Rs");
	
	ArrayList<HashMap<String, Object>> nvl2List = new ArrayList<>();
	while(nvl2Rs.next()) {
		HashMap<String, Object> m2 = new HashMap<String, Object>();
		m2.put("이름", nvl2Rs.getString("name"));
		m2.put("결과", nvl2Rs.getString("결과"));
		nvl2List.add(m2);
	}
	
	String nullifSql = null;
	PreparedStatement nullifStmt = null;
	ResultSet nullifRs = null;
	
	nullifSql = "select name, nullif(four_day, 100) 결과3 from onepiece";
	nullifStmt = conn.prepareStatement(nullifSql);
	nullifRs = nullifStmt.executeQuery();
	System.out.println(nullifStmt + "<--- onepiece_nvl_test nullifStmt");
	System.out.println(nullifRs + "<--- onepiece_nvl_test nullifRs");
	
	ArrayList<HashMap<String, Object>> nullifList = new ArrayList<>();
	while(nullifRs.next()) {
		HashMap<String, Object> m3 = new HashMap<String, Object>();
		m3.put("이름", nullifRs.getString("name"));
		m3.put("결과3", nullifRs.getInt("결과3"));
		nullifList.add(m3);
	}
	
	String coalesceSql = null;
	PreparedStatement coalesceStmt = null;
	ResultSet coalesceRs = null;
	
	coalesceSql = "select name, coalesce(first_day, second_day, three_day, four_day) 결과4 from onepiece";
	coalesceStmt = conn.prepareStatement(coalesceSql);
	coalesceRs = coalesceStmt.executeQuery();
	System.out.println(coalesceStmt + "<--- onepiece_nvl_test coalesceStmt");
	System.out.println(coalesceRs + "<--- onepiece_nvl_test coalesceRs");
	
	ArrayList<HashMap<String, Object>> coalesceList = new ArrayList<>();
	while(coalesceRs.next()) {
		HashMap<String, Object> m4 = new HashMap<String, Object>();
		m4.put("이름", coalesceRs.getString("name"));
		m4.put("결과4", coalesceRs.getInt("결과4"));
		coalesceList.add(m4);
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	 <div class="container">
      <div class="row">
         <div class="col-sm-6">
            <h3>1테스트</h3>
            <table border="1">
               <tr>
                  <td>이름</td>
                  <td>결과</td>
               </tr>
               <%
                  for(HashMap<String,Object> m:nvlList){
               %>
                     <tr>
                        <td><%=m.get("이름") %></td>
                        <td><%=(Integer)m.get("결과") %></td>
                     </tr>
               <%
                  }
               %>
            </table>
         </div>
         <div class="col-sm-6">
            <h3>2</h3>
            <table border="1">
               <tr>
                  <td>이름</td>
                  <td>결과</td>
               </tr>
               <%
                  for(HashMap<String,Object> m2:nvl2List){
               %>
                     <tr>
                        <td><%=m2.get("이름") %></td>
                        <td><%=m2.get("결과") %></td>
                     </tr>
               <%
                  }
               %>
            </table>
         </div>
      </div>
      <div class="row">
         <div class="col-sm-6">
            <h3>3</h3>
            <table border="1">
               <tr>
                  <td>이름</td>
                  <td>결과</td>
               </tr>
               <%
                  for(HashMap<String,Object> m3:nullifList){
               %>
                     <tr>
                        <td><%=m3.get("이름") %></td>
                        <td><%=(Integer)m3.get("결과3") %></td>
                     </tr>
               <%
                  }
               %>
            </table>
         </div>
         <div class="col-sm-6">
            <h3>4</h3>
            <table border="1">
               <tr>
                  <td>이름</td>
                  <td>결과</td>
               </tr>
               <%
                  for(HashMap<String,Object> m4:coalesceList){
               %>
                     <tr>
                        <td><%=m4.get("이름") %></td>
                        <td><%=(Integer)m4.get("결과4") %></td>
                     </tr>
               <%
                  }
               %>
            </table>
         </div>
      </div><!-- row -->
   </div>
</body>
</html>