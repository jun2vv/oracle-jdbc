<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%
	//현재페이지 currentPage
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	System.out.println(currentPage + "<--- rank_nitle currentPage");

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
	
	System.out.println(totalRow + "<--- rank_nitle totalRow");
	
	// 시작페이지와 마지막페이지 구하기 rowPerPage -> 한페이지당 보여줄 행의 개수
	int rowPerPage = 10;
	int beginRow = (currentPage -1) * rowPerPage +1;
	int endRow = beginRow + (rowPerPage -1);
	
	if(endRow > totalRow) {
		endRow = totalRow;
	}
	
	// rank를 dense_rank(), rownumber()로 분기시키기 위하여 쿼리문에 rank만 변수값으로 넣는다
	// 초기값은 rank()
	String rank = "rank()";
	if(request.getParameter("rank") != null) {
		rank = request.getParameter("rank");
		System.out.println(rank + "현재 rank변수값");
	}
	
	// 2)계층쿼리 모델
	/* 계층쿼리 rank
		select 번호, 직원id, 이름, 급여, 급여순위, 급여랭크
		from (select rownum 번호, 직원id, 이름, 급여, 급여순위, 급여랭크
        		from (select employee_id 직원id, last_name 이름, salary 급여, rank() over(order by salary desc) 급여순위, ntile(5) over(order by salary desc) 급여랭크 
        		from employees)) 
		where 번호 between 1 and 10;

	*/
	String sql = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	
	sql="select 번호, 직원id, 이름, 급여, 급여순위, 급여랭크 from (select rownum 번호, 직원id, 이름, 급여, 급여순위, 급여랭크 from (select employee_id 직원id, last_name 이름, salary 급여, "+rank+" over(order by salary desc) 급여순위, ntile(5) over(order by salary desc) 급여랭크 from employees)) where 번호 between ? and ?";
	stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	rs = stmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("번호", rs.getInt("번호"));
		m.put("직원id", rs.getInt("직원id"));
		m.put("급여", rs.getInt("급여"));
		m.put("급여순위", rs.getInt("급여순위"));
		m.put("급여랭크", rs.getInt("급여랭크"));
		list.add(m);
	}
	
	System.out.println(stmt + "<--- rank_nitle stmt");
	System.out.println(rs + "<--- rank_nitle rs");
	System.out.println(list.size() + "<--- rank_nitle list.size");
	
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
	<h1>rank_ntile</h1>
	<form>
		<select name="rank">
			<option value="rank()">rank</option>
			<option value="dense_rank()">dense_rank</option>
			<option value="row_number()">row_number</option>
		</select>
		<button type="submit">변경</button>
	</form>
	<table>
		<tr>
			<td>번호</td>
			<td>직원id</td>
			<td>급여</td>
			<td>급여순위</td>
			<td>급여랭크</td>
		</tr>
		
		<%
			for(HashMap<String, Object> m : list) {
		%>
				<tr>
					<td><%=(Integer)m.get("번호") %></td>
					<td><%=(Integer)m.get("직원id") %></td>
					<td><%=(Integer)m.get("급여") %></td>
					<td><%=(Integer)m.get("급여순위") %></td>
					<td><%=(Integer)m.get("급여랭크") %></td>
				</tr>
		<% 	}
		%>
	</table>
	
	<!--  페이징  -->
		<% 	// 최소페이지가 1보다크면 첫페이지로 가게 해주는 버튼
			if (minPage > 1) {
		%>
					<a href="<%=request.getContextPath()%>/rank_ntile_list.jsp?currentPage=<%=1%>&rank=<%=rank%>">첫페이지로</a>
		<%
			      } 
			// 최소페이지가 1보다크면 이전페이지(이전페이지는 만약 내가 11페이지면 1페이지로 21페이지면 11페이지로)버튼
			if (minPage > 1) {
		%>
					<!-- 이전페이지 -->
					<a href="<%=request.getContextPath()%>/rank_ntile_list.jsp?currentPage=<%=minPage - pagePerPage%>&rank=<%=rank%>">이전</a>
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
						<a href="<%=request.getContextPath()%>/rank_ntile_list.jsp?currentPage=<%=i%>&rank=<%=rank%>"><%=i%></a>
		<% 
				} 
			} 	
				// maxPage가 마지막페이지와 다르다면 다음버튼 마지막페이지에서는 둘이 같으니 다음버튼이 안나오겠죠
				// 다음페이지(만약 내가 1페이지에서 누르면 11페이지로 11페이지에서 누르면 21페이지로)버튼
		      	if(maxPage != lastPage) {
		%>
						<!--  다음페이지 maxPage+1을해도 아래와 같다 -->
						<a href="<%=request.getContextPath()%>/rank_ntile_list.jsp?currentPage=<%=minPage + pagePerPage%>&rank=<%=rank%>">다음</a>
		<% 
			 	 }
				// maxPage가 lastPage보다 작으면 현재마지막페이지가 아닌것 이므로 마지막페이지로 갈 수 있는 버튼
		      	if(maxPage < lastPage) {
		%>
						<!-- 마지막페이지로  -->
					  	<a  href="<%=request.getContextPath()%>/rank_ntile_list.jsp?currentPage=<%=lastPage%>&rank=<%=rank%>">마지막페이지</a>
		<%    
			  	}
		%>
</body>
</html>