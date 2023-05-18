<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@page import="java.util.*"%>
<%
	// 1.컨트롤러계층 요청값 분석
	
	// 현재페이지 currentPage
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	System.out.println(currentPage + "<--- windowsFunctionEmpList currentPage");
	
	
	// 2.모델 계층
	// db 연동
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	
	// db연동 변수 
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn + "접속");
	
	// 1)전체행개수 구하는 모델
	int totalRow = 0;
	String totalRowSql = " select count(*) from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt("count(*)");
	}
	
	System.out.println(totalRow + "<--- windowsFunctionEmpList totalRow");
	
	// 시작페이지와 마지막페이지 구하기 rowPerPage -> 한페이지당 보여줄 행의 개수
	int rowPerPage = 10;
	int beginRow = (currentPage -1) * rowPerPage +1;
	int endRow = beginRow + (rowPerPage -1);
	
	if(endRow > totalRow) {
		endRow = totalRow;
	}
	
	// 2)출력할 모델데이터
	String sql="";
	PreparedStatement stmt = null;
	ResultSet rs = null;
	
	/*	분석함수 쿼리
		select employee_id, last_name, salary, 
	    round(avg(salary) over()) 전체급여평균,
	    sum(salary) over() 전체급여합계,
	    count(*) over() 전체사원수
		from employees;
	*/
	sql="select 번호, 직원ID, 이름, 급여, 전체급여평균, 전체급여합계, 전체사원수 from (select rownum 번호, employee_id 직원ID, last_name 이름, salary 급여, round(avg(salary) over()) 전체급여평균, sum(salary) over() 전체급여합계, count(*) over() 전체사원수 from employees) where 번호 between ? and ?";
	stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	rs = stmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("번호", rs.getInt("번호"));
		m.put("직원id", rs.getString("직원id"));
		m.put("이름", rs.getString("이름"));
		m.put("급여", rs.getInt("급여"));
		m.put("전체급여평균", rs.getInt("전체급여평균"));
		m.put("전체급여합계", rs.getInt("전체급여합계"));
		m.put("전체사원수", rs.getInt("전체사원수"));
		list.add(m);
	}
	
	System.out.println(list.size() + "<--- windowsFunctionEmpList list.size");
	System.out.println(stmt + "<--- windowsFunctionEmpList stmt");
	System.out.println(rs + "<--- windowsFunctionEmpList rs");

	// 페이지 네비게이션 페이징
	
		// 이전 1,2,3,4,5,6,7,8,9,10 다음 -> 이렇게 페이징할 수 있도록 값 구하기
		int pagePerPage = 10;
		/*	cp	minPage		maxPage
			1		1	~	10
			2		1	~	10
			10		1	~	10
			
			11		11	~	20
			12		11	~	20
			20		11	~	20
			
			((cp-1) / pagePerPage) * pagePerPage + 1 --> minPage
			minPage + (pagePerPgae -1) --> maxPage
			maxPage > lastPage --> maxPage = lastPage;
		*/
		// 마지막 페이지 구하기
		int lastPage = totalRow / rowPerPage;
		if(totalRow / rowPerPage != 0) {
			lastPage = lastPage+1;
		}
		// 최소페이지,최대페이지 구하기
		int minPage = ((currentPage-1) / pagePerPage) * pagePerPage + 1;
		int maxPage = minPage + (pagePerPage -1);
		if(maxPage > lastPage) {
			maxPage = lastPage;
		}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<h1> </h1>
	<table border =1>
		<tr>
			<td>번호</td>
			<td>직원id</td>
			<td>이름</td>
			<td>급여</td>
			<td>전체급여평균</td>
			<td>전체급여합계</td>
			<td>전체사원수</td>
		</tr>
		
		<%
			for(HashMap<String, Object> m : list) {
		%>
				<tr>
					<td><%=(Integer)m.get("번호") %></td>
					<td><%=(String)m.get("직원id") %></td>
					<td><%=(String)m.get("이름") %></td>
					<td><%=(Integer)m.get("급여") %></td>
					<td><%=(Integer)m.get("전체급여평균") %></td>
					<td><%=(Integer)m.get("전체급여합계") %></td>
					<td><%=(Integer)m.get("전체사원수") %></td>
				</tr>
		<% 	}
		%>
	</table>
		<!-- 페이징 부분 -->
		<% 
			//  최소페이지가 1보다 작으면 아무것도 없다
			if(minPage > 1) {
		%>
				<!-- 이전페이지 -->
				<a href="<%=request.getContextPath() %>/windowsFunctionEmpList.jsp?currentPage=<%=minPage - pagePerPage%>">이전</a>
		<% 
			}
			// i = minPage, maxPage = 10//  1 <= 10   --> i++
			for(int i = minPage; i <= maxPage; i=i+1) {
				if(i == currentPage){
		%>
					<span style="color: red;"><%=i %></span>
		<% 
				} else {
		%>
				<!--  1~10, 11~20... 페이지 출력 -->
				<a href="<%=request.getContextPath() %>/windowsFunctionEmpList.jsp?currentPage=<%=i%>"><%=i %></a>	
		<%
				}
			}
			// maxPage가 마지막페이지랑 다르면 다음 10페이지 뒤로보낸다
			if(maxPage != lastPage){
		%>
				<!--  다음페이지 maxPage+1을해도 아래와 같다 -->
				<a href="<%=request.getContextPath() %>/windowsFunctionEmpList.jsp?currentPage=<%=minPage + pagePerPage%>">다음</a>
		<% 	}
		%>
</body>
</html>