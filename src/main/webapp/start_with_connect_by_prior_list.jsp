<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%

	//현재페이지 currentPage
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	System.out.println(currentPage + "<--- start_with currentPage");

	
	//2.모델 계층
	//db 연동
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn + "접속");
	
	
	// 1)전체행개수 모델
	int totalRow = 0;
	String totalRowSql = " select count(*) from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt("count(*)");
	}
	
	System.out.println(totalRow + "<--- start_with totalRow");
	
	// 시작페이지와 마지막페이지 구하기 rowPerPage -> 한페이지당 보여줄 행의 개수
	int rowPerPage = 10;
	int beginRow = (currentPage -1) * rowPerPage +1;
	int endRow = beginRow + (rowPerPage -1);
	
	if(endRow > totalRow) {
		endRow = totalRow;
	}
		
	// 2)계층쿼리 모델
	/* 계층쿼리 rank
	
		select 번호,  레벨, 이름, 매니저아이디, 직속관계
		from (select rownum 번호, level 레벨, lpad(' ', level-1)||first_name 이름,  manager_id 매니저아이디, SYS_CONNECT_BY_PATH(first_name,'-') 직속관계
        		from employees start with manager_id is null connect by prior employee_id = manager_id)
		where 번호 between 1 and 10
	*/
	String sql = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	
	sql="select 번호, 레벨, 이름, 매니저아이디, 직속관계 from (select rownum 번호, level 레벨, lpad(' ', level-1)||first_name 이름, manager_id 매니저아이디, SYS_CONNECT_BY_PATH(first_name,'-') 직속관계 from employees start with manager_id is null connect by prior employee_id = manager_id) where 번호 between ? and ?";
	stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	rs = stmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("레벨", rs.getInt("레벨"));
		m.put("이름", rs.getString("이름"));
		m.put("매니저아이디", rs.getInt("매니저아이디"));
		m.put("직속관계", rs.getString("직속관계"));
		list.add(m);
	}
	
	System.out.println(stmt + "<--- start_with stmt");
	System.out.println(rs + "<--- start_with rs");
	System.out.println(list.size() + "<--- start_with list.size");
	
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
	<table>
		<tr>
			<td>level</td>
			<td>first_name</td>
			<td>manager_id</td>
			<td>sys_connect_by_path</td>
		</tr>
		
		<%
			for(HashMap<String, Object> m : list) {
		%>
				<tr>
					<td><%=(Integer)m.get("레벨") %></td>
					<td><%=(String)m.get("이름") %></td>
					<td><%=(Integer)m.get("매니저아이디") %></td>
					<td><%=(String)m.get("직속관계") %></td>
				</tr>
		<% 	}
		%>
	</table>
	
	<!--  페이징  -->
		<% 	// 최소페이지가 1보다크면 첫페이지로 가게 해주는 버튼
			if (minPage > 1) {
		%>
					<a href="<%=request.getContextPath()%>/start_with_connect_by_prior_list.jsp?currentPage=<%=1%>">첫페이지로</a>
		<%
			      } 
			// 최소페이지가 1보다크면 이전페이지(이전페이지는 만약 내가 11페이지면 1페이지로 21페이지면 11페이지로)버튼
			if (minPage > 1) {
		%>
					<!-- 이전페이지 -->
					<a href="<%=request.getContextPath()%>/start_with_connect_by_prior_list.jsp?currentPage=<%=minPage - pagePerPage%>">이전</a>
		<%
		   	} 
		      
			for (int i = minPage; i <= maxPage; i+=1) { 
				if (i == currentPage) {
		%>
						<!-- i와 현재페이지가 같은곳이라면 현재위치한 페이지 빨간색표시 -->
						<span style="color: red;"><%=i %></span>
		<%
				// i가 현재페이지와 다르다면 출력
				} else {
		%>			
						<!--  1~10, 11~20... 페이지 출력 -->
						<a href="<%=request.getContextPath()%>/start_with_connect_by_prior_list.jsp?currentPage=<%=i%>"><%=i%></a>
		<% 
				} 
			} 	
				// maxPage가 마지막페이지와 다르다면 다음버튼 마지막페이지에서는 둘이 같으니 다음버튼이 안나오겠죠
				// 다음페이지(만약 내가 1페이지에서 누르면 11페이지로 11페이지에서 누르면 21페이지로)버튼
		      	if(maxPage != lastPage) {
		%>
						<!--  다음페이지 maxPage+1을해도 아래와 같다 -->
						<a href="<%=request.getContextPath()%>/start_with_connect_by_prior_list.jsp?currentPage=<%=minPage + pagePerPage%>">다음</a>
		<% 
			 	 }
				// maxPage가 lastPage보다 작으면 현재마지막페이지가 아닌것 이므로 마지막페이지로 갈 수 있는 버튼
		      	if(maxPage < lastPage) {
		%>
						<!-- 마지막페이지로  -->
					  	<a  href="<%=request.getContextPath()%>/start_with_connect_by_prior_list.jsp?currentPage=<%=lastPage%>">마지막페이지</a>
		<%    
			  	}
		%>
</body>
</html>