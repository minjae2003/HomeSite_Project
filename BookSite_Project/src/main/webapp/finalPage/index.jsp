<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>BookSite - 사이트맵 및 주요 기능 정리</title>
<link rel="stylesheet" type="text/css" href="../css/style.css">
<style>

	table,tr,th,td{border: 2px solid black}
	table { border-collapse: collapse;}
	td{ padding-left:5px; padding-right:5px;}
	h3{ font-size: 16px; margin-bottom: 12px; color: #423853; margin-left:10px;}
	ul{ line-height: 2.0; padding-left: 20px; font-size: 14px; color: #333;}
	
	.page-title{ margin:10px;}
	.mainpage{ background-color: #fafafa; border: 1px solid #e0e0e0; margin-left:10px; padding: 20px; border-radius: 4px; margin-bottom: 30px; line-height: 1.6; font-size: 14px;}
	.subpage{ border: 1px solid #eee; padding: 20px; background-color: #fff; margin-bottom: 30px;}
	.homepage-table{ magin-bottom:30px; margin:10px 10px;}
	.btn-style { background-color: #ffffff; border: 1px solid #b0b0b0; padding: 5px 16px; font-size: 12px; cursor: pointer; color: #333; margin-left: 4px; }
    .btn-style:hover { background-color: #f0f0f0; }
    .buttonStyle{ text-align: center; margin-bottom: 40px;}
</style>
</head>
<body>
<%@ include file="../module/header.jsp" %>

<div class="container">
    <!-- 페이지 타이틀 -->
    <h2 class="page-title">사이트맵 &gt; 전체 메뉴 및 기능 안내</h2>

    <!-- 프로젝트 개요 -->
    <div class="mainpage">
        <b>BookSite</b>는 JSP/Servlet과 DAO/DTO/VO 아키텍처 기반으로 구축된 도서 소개 및 게시판 관리 웹 프로젝트입니다.<br>
        메인 홈 화면을 비롯하여 도서 정보 제공, 자유게시판, Q&A 게시판 및 회원 관리 기능을 통합 제공합니다.
    </div>

    <!-- 1. 주요 메뉴별 기능 상세 (HOME / 도서소개 / 게시판 / Q&A / 회원관리) -->
    <h3>1. 주요 메뉴별 기능 상세</h3>
    <table class="homepage-table" >
        <tr>
            <th width="15%">메뉴명</th>
            <th width="25%">관련 페이지 (경로)</th>
            <th width="60%">상세 기능 및 역할</th>
        </tr>
        <tr>
            <td align="center"><b>HOME</b></td>
            <td><code>../main/main.jsp</code></td>
            <td>사이트의 랜딩 페이지로, 메인 비주얼과 웹사이트 소개 멘트, 주요 기능(도서소개, 게시판, Q&A)으로 바로 이동할 수 있는 대시보드 역할을 담당합니다.</td>
        </tr>
        <tr>
            <td align="center"><b>도서소개</b></td>
            <td><code>../book/booklist.jsp</code></td>
            <td>사이트에서 추천 및 제공하는 도서 목록을 보여주는 페이지입니다. 도서 이미지, 제목, 저자, 출판사 등 상세 도서 정보를 한눈에 조회할 수 있습니다.</td>
        </tr>
        <tr>
            <td align="center"><b>게시판</b></td>
            <td><code>../freeboard/list.jsp</code></td>
            <td>사용자들이 자유롭게 의견을 공유하는 커뮤니티 공간입니다. 자유게시글 작성, 수정, 삭제 및 목록 조회 기능을 제공합니다.</td>
        </tr>
        <tr>
            <td align="center"><b>Q & A</b></td>
            <td><code>../qna/qnaList.jsp</code></td>
            <td>질문과 답변을 작성하는 Q&A 게시판입니다. <code>QnaDTO</code>와 <code>QnaDAO</code>를 활용해 작성, 상세보기, 조회수 자동 증가 등의 DB CRUD 처리가 이루어집니다.</td>
        </tr>
        <tr>
            <td align="center"><b>회원관리</b></td>
            <td><code>../member/</code></td>
            <td>회원가입(<code>memberForm.jsp</code>), 로그인(<code>loginForm.jsp</code>), 로그아웃(<code>LogoutPro.jsp</code>), 회원 정보 수정(<code>memberupdateForm.jsp</code>) 등 사용자 인증 및 세션 관리를 담당합니다.</td>
        </tr>
        <tr>
            <td align="center"><b>사이트맵</b></td>
            <td><code>../finalPage/index.jsp</code></td>
            <td>현재 페이지로, 프로젝트의 기술 스택, 전체 구조, 주요 메뉴별 역할을 한눈에 파악할 수 있는 요약 및 가이드 역할을 합니다.</td>
        </tr>
    </table>

    <!-- 2. 기술 스택 (Tech Stack) -->
    <h3>2. 기술 스택 (Tech Stack)</h3>
    <table class="homepage-table">
        <tr>
            <th width="25%">구분</th>
            <th width="75%">사용 기술 및 개발 환경</th>
        </tr>
        <tr>
            <td align="center"><b>Backend</b></td>
            <td>Java, JSP (JavaServer Pages)</td>
        </tr>
        <tr>
            <td align="center"><b>Database</b></td>
            <td>MySQL, JDBC (Java Database Connectivity)</td>
        </tr>
        <tr>
            <td align="center"><b>Frontend</b></td>
            <td>HTML5, CSS3 (<code>style.css</code>)</td>
        </tr>
        <tr>
            <td align="center"><b>Architecture</b></td>
            <td>Model 1 (JSP + JavaBean/DTO + DAO)</td>
        </tr>
    </table>

    <!-- 3. 주요 구현 특징 -->
    <h3>3. 주요 구현 특징</h3>
    <div class="subpage">
        <ul>
            <li><b>통합 네비게이션 체계:</b> <code>header.jsp</code> 공통 모듈을 통해 메인(HOME), 도서소개, 게시판, Q&A, 사이트맵 간 자유로운 이동이 가능합니다.</li>
            <li><b>세션 기반 로그인 상태 처리:</b> 세션 상태에 따라 상단 메뉴가 '회원가입/로그인' 또는 'OOO님/로그아웃/정보수정'으로 자동 전환됩니다.</li>
            <li><b>객체지향 DB 연동 (DAO/DTO):</b> Q&A 게시판 및 회원 관리의 데이터 처리를 DAO 클래스로 분리하여 유지보수성을 높였습니다.</li>
        </ul>
    </div>

    <!-- 하단 메인 이동 버튼 -->
    <div class="buttonStyle">
    	<button type="button" class="btn-style" onclick="location.href='../main/main.jsp'"> 메인화면 이동</button>
    </div>
</div>

</body>
</html>