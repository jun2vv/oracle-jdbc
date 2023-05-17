<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="EUC-KR"%>
<%@ page import="java.sql.*" %>
<%@page import="java.util.*"%>
<% 
	
	//2.�� ����
	//db ����
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	
	// db���� ���� 
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn + "����");
	
	String nvlSql = null;
	PreparedStatement nvlStmt = null;
	ResultSet nvlRs = null;
	
	nvlSql = "select name, nvl(first_day, 0) ��� from onepiece";
	nvlStmt = conn.prepareStatement(nvlSql);
	nvlRs = nvlStmt.executeQuery();
	System.out.println(nvlStmt + "<--- onepiece_nvl_test nvlStmt");
	System.out.println(nvlRs + "<--- onepiece_nvl_test nvlRs");
	
	ArrayList<HashMap<String, Object>> nvlList = new ArrayList<>();
	while(nvlRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("�̸�", nvlRs.getString("name"));
		m.put("���", nvlRs.getInt("���"));
		nvlList.add(m);
	}
	
	String nvl2Sql = null;
	PreparedStatement nvl2Stmt = null;
	ResultSet nvl2Rs = null;
	
	nvl2Sql = "select name, nvl2(first_day, 'success', 'fail') ��� from onepiece";
	nvl2Stmt = conn.prepareStatement(nvl2Sql);
	nvl2Rs = nvl2Stmt.executeQuery();
	System.out.println(nvl2Stmt + "<--- onepiece_nvl_test nvl2Stmt");
	System.out.println(nvl2Rs + "<--- onepiece_nvl_test nvl2Rs");
	
	ArrayList<HashMap<String, Object>> nvl2List = new ArrayList<>();
	while(nvl2Rs.next()) {
		HashMap<String, Object> m2 = new HashMap<String, Object>();
		m2.put("�̸�", nvl2Rs.getString("name"));
		m2.put("���", nvl2Rs.getString("���"));
		nvl2List.add(m2);
	}
	
	String nullifSql = null;
	PreparedStatement nullifStmt = null;
	ResultSet nullifRs = null;
	
	nullifSql = "select name, nullif(four_day, 100) ���3 from onepiece";
	nullifStmt = conn.prepareStatement(nullifSql);
	nullifRs = nullifStmt.executeQuery();
	System.out.println(nullifStmt + "<--- onepiece_nvl_test nullifStmt");
	System.out.println(nullifRs + "<--- onepiece_nvl_test nullifRs");
	
	ArrayList<HashMap<String, Object>> nullifList = new ArrayList<>();
	while(nullifRs.next()) {
		HashMap<String, Object> m3 = new HashMap<String, Object>();
		m3.put("�̸�", nullifRs.getString("name"));
		m3.put("���3", nullifRs.getInt("���3"));
		nullifList.add(m3);
	}
	
	String coalesceSql = null;
	PreparedStatement coalesceStmt = null;
	ResultSet coalesceRs = null;
	
	coalesceSql = "select name, coalesce(first_day, second_day, three_day, four_day) ���4 from onepiece";
	coalesceStmt = conn.prepareStatement(coalesceSql);
	coalesceRs = coalesceStmt.executeQuery();
	System.out.println(coalesceStmt + "<--- onepiece_nvl_test coalesceStmt");
	System.out.println(coalesceRs + "<--- onepiece_nvl_test coalesceRs");
	
	ArrayList<HashMap<String, Object>> coalesceList = new ArrayList<>();
	while(coalesceRs.next()) {
		HashMap<String, Object> m4 = new HashMap<String, Object>();
		m4.put("�̸�", coalesceRs.getString("name"));
		m4.put("���4", coalesceRs.getInt("���4"));
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
            <h3>1�׽�Ʈ</h3>
            <table border="1">
               <tr>
                  <td>�̸�</td>
                  <td>���</td>
               </tr>
               <%
                  for(HashMap<String,Object> m:nvlList){
               %>
                     <tr>
                        <td><%=m.get("�̸�") %></td>
                        <td><%=(Integer)m.get("���") %></td>
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
                  <td>�̸�</td>
                  <td>���</td>
               </tr>
               <%
                  for(HashMap<String,Object> m2:nvl2List){
               %>
                     <tr>
                        <td><%=m2.get("�̸�") %></td>
                        <td><%=m2.get("���") %></td>
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
                  <td>�̸�</td>
                  <td>���</td>
               </tr>
               <%
                  for(HashMap<String,Object> m3:nullifList){
               %>
                     <tr>
                        <td><%=m3.get("�̸�") %></td>
                        <td><%=(Integer)m3.get("���3") %></td>
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
                  <td>�̸�</td>
                  <td>���</td>
               </tr>
               <%
                  for(HashMap<String,Object> m4:coalesceList){
               %>
                     <tr>
                        <td><%=m4.get("�̸�") %></td>
                        <td><%=(Integer)m4.get("���4") %></td>
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