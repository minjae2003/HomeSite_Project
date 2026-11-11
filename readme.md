# 🏠 자취의 품격

> 자취생들이 생활 꿀팁, 자취 요리 레시피, 질문과 일상을 나누는 자취 커뮤니티

**🔗 서비스 주소: [https://jachiclass.com](https://jachiclass.com)**

JSP/Servlet으로 만든 커뮤니티 웹사이트입니다. 게시판, 댓글, 알림 같은 기본 기능부터 AWS EC2 배포, HTTPS, 검색엔진 등록, 보안 대책까지 실제 서비스 운영에 필요한 과정을 직접 구현하고 운영하고 있습니다.

<br>

## 📌 목차
- [주요 기능](#-주요-기능)
- [기술 스택](#-기술-스택)
- [시스템 구성](#-시스템-구성)
- [보안](#-보안)
- [프로젝트 구조](#-프로젝트-구조)
- [데이터베이스](#-데이터베이스)
- [로컬 실행 방법](#-로컬-실행-방법)
- [배포](#-배포)
- [사용한 오픈소스](#-사용한-오픈소스)

<br>

## ✨ 주요 기능

### 게시판
| 기능 | 설명 |
|---|---|
| 생활 꿀팁/자유 게시판 | 자취꿀팁 · 질문/답변 · 일상/수다 · 요리레시피 카테고리 |
| 공지사항 | 관리자 전용 작성, 고정 공지 / 일반 공지 |
| 🔥 실시간 인기글 | 최근 24시간의 **조회 × 1 + 추천 × 5 + 댓글 × 3** 점수로 순위 집계 (롤링 방식) |
| 📌 상단 고정 | 관리자가 자유게시판 글을 목록 맨 위에 고정 |
| 검색 | 제목/본문 검색, 통합검색 |
| 추천 · 댓글 | 추천/취소, 댓글 작성·수정·삭제 |

### 글쓰기 에디터
- **Summernote** 기반 WYSIWYG 에디터: 사진을 원하는 위치에 자유롭게 배치
- 사진 크기 조절(100/50/25%), 좌우 정렬, 드래그로 위치 이동
- 붙여넣기(Ctrl+V)·끌어다 놓기로 즉시 업로드
- 동영상, 문서(hwp, pdf, 오피스, 압축파일) 첨부

### 링크 미리보기
- 본문에 주소만 붙여넣으면 **카카오톡처럼 미리보기 카드**(대표 이미지·제목·설명)로 표시
- **유튜브** 링크는 썸네일 + ▶ 재생 버튼 카드로 표시

### 회원
- 회원가입, 로그인, 아이디/비밀번호 찾기, 회원정보 수정, 탈퇴
- 마이페이지: 내 활동, 프로필(사진·소개·지역·자취 기간·태그), 활동 점수에 따른 등급
- 🔔 알림: 내 글의 댓글·추천, 새 공지, 문의 답변 (종류별 수신 설정)
- 닉네임 변경 시 예전 글·댓글의 작성자 이름도 함께 변경

### 운영 기능
- **📮 1:1 문의**: 회원 → 관리자 문의, 관리자 답변 시 알림 / 게시글 🚨 신고 버튼
- **🚫 금칙어 필터**: 글·댓글·닉네임 검사, 띄어쓰기·숫자·기호를 끼운 우회 표현까지 탐지, 관리자 화면에서 금칙어/예외 단어 관리
- **약관·개인정보처리방침·운영정책** 페이지, 회원가입 및 기존 회원 동의 절차(동의 기록 저장, 정책 버전 관리)
- ✅ 자취 시작 체크리스트 (계정별 저장)

### 검색엔진 최적화(SEO)
- DB 기반 자동 생성 `sitemap.xml`, `robots.txt`
- 페이지별 `canonical`, `meta description`, Open Graph 태그, 사이트 이름 구조화 데이터(JSON-LD)
- 검색엔진 봇 방문은 조회수·인기글 집계에서 제외
- Google Search Console, 네이버 서치어드바이저 등록

<br>

## 🛠 기술 스택

| 구분 | 사용 기술 |
|---|---|
| **Backend** | Java 21, JSP / Servlet (javax), JDBC (JNDI DataSource) |
| **Frontend** | HTML, CSS, JavaScript, jQuery, Summernote |
| **Database** | MySQL 8 |
| **WAS / Web Server** | Apache Tomcat 9, Nginx (리버스 프록시) |
| **Infra** | AWS EC2 (Ubuntu 24.04, 서울 리전), 탄력적 IP |
| **Domain / HTTPS** | 가비아 도메인, Let's Encrypt (Certbot 자동 갱신) |
| **Library** | jsoup (HTML 정제·파싱), MySQL Connector/J |
| **Tool** | Eclipse, Git / GitHub |

<br>

## 🏗 시스템 구성

```
                      HTTPS (443)
  사용자 브라우저  ─────────────────▶  Nginx  ───────▶  Tomcat 9  ───────▶  MySQL 8
  (jachiclass.com)                  (SSL 처리,          (JSP/Servlet)
                                     리버스 프록시)
                                    └──────────── AWS EC2 (Ubuntu) ────────────┘
```

- 가비아 DNS의 A 레코드가 EC2 탄력적 IP를 가리킴
- Nginx가 HTTPS를 처리하고 Tomcat(8080)으로 전달
- 인증서는 Let's Encrypt(Certbot)로 발급, 90일마다 자동 갱신

<br>

## 🔒 보안

| 위협 | 대응 |
|---|---|
| **XSS** | 모든 출력에 이스케이프(`HtmlUtil`), 에디터 HTML은 jsoup 화이트리스트로 허용된 태그·속성·스타일만 저장/출력 |
| **CSRF** | 모든 POST 요청에 세션별 토큰 검사(`CsrfFilter`), AJAX는 `X-CSRF-Token` 헤더 |
| **SQL Injection** | 모든 쿼리에 `PreparedStatement` 사용 |
| **비밀번호 유출** | PBKDF2-HMAC-SHA256 해시 + 솔트, 고정 시간 비교 |
| **무작위 대입** | 로그인·아이디/비밀번호 찾기 시도 횟수 제한(아이디별·IP별), 아이디 존재 여부 노출 방지 |
| **파일 업로드 공격** | 확장자 화이트리스트, 이미지 매직 넘버 검사, SVG 차단, 저장 파일명 무작위화 |
| **SSRF** (링크 미리보기) | 글에 실제로 있는 링크만 요청, 사설 IP·AWS 메타데이터 주소 차단, 리다이렉트마다 재검사, 크기·시간 제한 |
| **오픈 리다이렉트** | 이동 주소는 사이트 내부 경로만 허용 |
| **세션 탈취** | 세션 쿠키 `HttpOnly`, URL에 세션 ID 미노출 |
| **정보 노출** | 공통 에러 페이지로 스택 트레이스 숨김 |
| **권한 우회** | 수정·삭제·관리 기능은 서버에서 작성자/관리자 권한 재확인 |

<br>

## 📁 프로젝트 구조

```
BookSite_Project/src/main
├── java
│   ├── board          # 게시글·댓글 DAO/VO, 실시간 인기글 집계
│   ├── checklist      # 자취 체크리스트 저장
│   ├── filter         # 금칙어 필터
│   ├── inquiry        # 1:1 문의
│   ├── member         # 회원, 로그인 시도 제한, 약관 동의(ConsentFilter)
│   ├── mypage         # 마이페이지, 프로필, 등급
│   ├── notification   # 알림
│   ├── preview        # 링크 미리보기 (SSRF 방지)
│   ├── seo            # sitemap.xml, canonical 주소, 검색봇 판별
│   ├── upload         # 글 저장 + 파일 업로드, 에디터 사진 업로드
│   ├── util           # CSRF, XSS 이스케이프, 비밀번호 해시, HTML 정제, 사이트 정보
│   └── visit          # 방문자 집계
├── webapp
│   ├── main           # 메인, 통합검색, 체크리스트
│   ├── freeboard      # 생활 꿀팁/자유 게시판
│   ├── noticeboard    # 공지사항
│   ├── member         # 회원가입, 로그인, 찾기, 정보수정
│   ├── mypage         # 마이페이지, 알림, 프로필, 계정
│   ├── support        # 1:1 문의
│   ├── policy         # 이용약관, 개인정보처리방침, 운영정책, 동의 화면
│   ├── admin          # 문의 관리, 금칙어 관리
│   ├── module         # 공통 header / footer
│   ├── css, js        # 스타일, 스크립트
│   └── lib            # jQuery, Summernote
└── SQL                # 테이블 생성 스크립트
```

<br>

## 🗄 데이터베이스

| 테이블 | 설명 |
|---|---|
| `MEMBER` / `MEMBER_PROFILE` | 회원 / 프로필 |
| `MEMBER_CONSENT` | 약관·개인정보 동의 기록 (정책 버전별) |
| `BOARD` / `BOARD_COMMENT` / `BOARD_LIKE` / `BOARD_FILE` | 게시글 / 댓글 / 추천 / 첨부파일 |
| `BOARD_VIEW_LOG` | 실시간 인기글 집계용 조회 기록 (7일 보관) |
| `NOTIFICATION` / `NOTIFICATION_SETTING` | 알림 / 알림 수신 설정 |
| `INQUIRY` | 1:1 문의 |
| `BANNED_WORD` | 금칙어 / 예외 단어 |
| `CHECKLIST` / `USER_CHECKLIST` | 자취 체크리스트 |
| `VISIT_LOG` | 방문자 집계 (1년 보관) |

### SQL 스크립트 (`src/main/SQL`)
| 파일 | 용도 |
|---|---|
| `01_member.sql` ~ `11_banned_word.sql` | 테이블별 생성 스크립트 (`CREATE TABLE IF NOT EXISTS`) |
| `ALLSQL.sql` | 위 파일 전체를 합친 것 (DB를 처음 만들 때) |
| `00_reset.sql` | ⚠️ **모든 테이블 삭제** |

> ⚠️ `00_reset.sql`과 `ALLSQL.sql`은 기존 데이터를 모두 지웁니다. 운영 중인 DB에는 새로 추가된 테이블의 파일(예: `11_banned_word.sql`)만 실행하세요.

<br>

## 💻 로컬 실행 방법

### 1. 준비
- JDK 21
- Apache Tomcat 9
- MySQL 8
- Eclipse IDE for Enterprise Java (Dynamic Web Project)

### 2. DB 생성
```sql
CREATE DATABASE homesiteproject DEFAULT CHARACTER SET utf8mb4;
USE homesiteproject;
SOURCE BookSite_Project/src/main/SQL/ALLSQL.sql;
```
기본 관리자 계정이 함께 생성됩니다. **처음 로그인한 뒤 반드시 비밀번호를 바꾸세요.**

### 3. DB 연결 설정 (JNDI)
DB 접속 정보는 저장소에 포함하지 않습니다. Tomcat의 `context.xml`에 아래처럼 직접 추가하세요.
```xml
<Resource name="jdbc/homesiteproject"
          auth="Container"
          type="javax.sql.DataSource"
          driverClassName="com.mysql.cj.jdbc.Driver"
          url="jdbc:mysql://localhost:3306/homesiteproject?serverTimezone=Asia/Seoul&amp;characterEncoding=UTF-8"
          username="DB_사용자"
          password="DB_비밀번호"
          maxTotal="20" maxIdle="10" maxWaitMillis="10000"/>
```

### 4. 실행
Eclipse에서 프로젝트를 Tomcat 9 서버에 추가한 뒤 실행하고, `http://localhost:8080/(컨텍스트 경로)/main/index.jsp`로 접속합니다.

<br>

## 🚀 배포

1. Eclipse에서 WAR 파일로 내보내기
2. EC2 서버로 WAR 업로드 후 배포 스크립트 실행 (기존 버전 백업 → 새 버전 배포 → 응답 확인)
3. 새 테이블이 추가된 경우, 해당 테이블의 SQL만 서버 DB에 실행

> 접속 키, DB 비밀번호 등 비밀 정보는 저장소에 올리지 않습니다.

<br>

## 📦 사용한 오픈소스

| 라이브러리 | 용도 | 라이선스 |
|---|---|---|
| [jsoup](https://jsoup.org/) | HTML 정제(XSS 방지), 링크 미리보기 파싱 | MIT |
| [Summernote](https://summernote.org/) | 글쓰기 에디터 | MIT |
| [jQuery](https://jquery.com/) | Summernote 의존성 | MIT |
| [MySQL Connector/J](https://dev.mysql.com/downloads/connector/j/) | MySQL JDBC 드라이버 | GPLv2 (FOSS 예외) |

<br>

---

<p align="center">© 2026 자취의 품격</p>
