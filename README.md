# Spring Boot Security Boilerplate

Spring Boot 3 + Spring Security(JWT) + JPA 기반의 웹 애플리케이션 개발을 위한 보일러플레이트입니다.

---

## 기술 스택

| 분류 | 기술 |
|------|------|
| Language | Java 17 |
| Framework | Spring Boot 3.2 |
| Security | Spring Security + JWT (JJWT 0.12) |
| ORM | Spring Data JPA + Hibernate |
| DB (로컬) | H2 (in-memory) |
| DB (운영) | PostgreSQL 16 |
| Build | Gradle 8 |
| Container | Docker + Docker Compose |
| IaC | Terraform 1.6+ |
| Cloud | AWS (ECS Fargate + RDS + ALB + ECR) |

---

## 프로젝트 구조

```
.
├── Dockerfile
├── build.gradle
├── src/
│   ├── main/
│   │   ├── java/com/boilerplate/
│   │   │   ├── BoilerplateApplication.java
│   │   │   ├── config/
│   │   │   │   ├── SecurityConfig.java       # Spring Security 설정
│   │   │   │   └── JpaAuditingConfig.java    # JPA Auditing 설정
│   │   │   ├── common/
│   │   │   │   ├── entity/BaseEntity.java    # createdAt/updatedAt/createdBy/updatedBy
│   │   │   │   ├── response/ApiResponse.java # 통일 응답 구조
│   │   │   │   └── exception/               # 전역 예외 처리
│   │   │   ├── security/
│   │   │   │   ├── JwtTokenProvider.java    # 토큰 생성·검증
│   │   │   │   ├── JwtAuthenticationFilter  # 요청마다 토큰 파싱
│   │   │   │   ├── CustomUserDetailsService
│   │   │   │   └── UserPrincipal.java
│   │   │   └── domain/
│   │   │       ├── auth/                    # 인증 API
│   │   │       └── user/                    # 사용자 API
│   │   └── resources/
│   │       ├── application.yml              # 공통 설정
│   │       ├── application-local.yml        # 로컬(H2)
│   │       └── application-prod.yml         # 운영(PostgreSQL)
│   └── test/
└── infra/
    ├── docker/docker-compose.yml            # 통합 테스트용
    └── terraform/
        ├── modules/                         # 재사용 모듈
        │   ├── ecr/      networking/
        │   ├── ecs/      rds/
        └── environments/
            ├── aws/                         # AWS 전체 스택
            └── on-prem/                     # 온프레미스 배포
```

---

## 빠른 시작

### 방법 1 — 로컬 개발 (H2, 가장 간단)

```bash
# 1. 프로젝트 클론
git clone <repo-url>
cd Spring-boot-Boilerplate

# 2. Gradle Wrapper 생성
gradle wrapper

# 3. 실행 (H2 in-memory DB 사용)
./gradlew bootRun

# 서버: http://localhost:8080
# H2 콘솔: http://localhost:8080/h2-console
#   JDBC URL : jdbc:h2:mem:boilerplate
#   Username : sa  /  Password : (없음)
```

### 방법 2 — Docker Compose (PostgreSQL 포함)

```bash
# 1. 빌드 + 실행 (앱 + PostgreSQL + Nginx 전체 기동)
docker compose -f infra/docker/docker-compose.yml up --build

# 서버: http://localhost:80
# PostgreSQL: localhost:5432
```

---

## API 명세

모든 응답은 아래 구조를 따릅니다.

```json
{
  "success": true,
  "message": "선택적 메시지",
  "data": { }
}
```

### 인증 (`/api/auth`)

| Method | URL | 인증 필요 | 설명 |
|--------|-----|----------|------|
| `POST` | `/api/auth/signup` | ✗ | 회원가입 |
| `POST` | `/api/auth/login` | ✗ | 로그인 |
| `POST` | `/api/auth/refresh` | ✗ (Refresh-Token 헤더) | 토큰 재발급 |
| `POST` | `/api/auth/logout` | ✓ | 로그아웃 |

#### 회원가입

```http
POST /api/auth/signup
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password1",
  "name": "홍길동"
}
```

> 비밀번호 규칙: 8자 이상, 영문자 + 숫자 포함

```json
{
  "success": true,
  "message": "회원가입이 완료되었습니다.",
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "tokenType": "Bearer"
  }
}
```

#### 로그인

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password1"
}
```

#### 토큰 재발급

```http
POST /api/auth/refresh
Refresh-Token: eyJ...
```

#### 로그아웃

```http
POST /api/auth/logout
Authorization: Bearer eyJ...
```

---

### 사용자 (`/api/users`)

| Method | URL | 설명 |
|--------|-----|------|
| `GET` | `/api/users/me` | 내 정보 조회 |
| `PUT` | `/api/users/me` | 이름 수정 |

모든 사용자 API는 `Authorization: Bearer <accessToken>` 헤더가 필요합니다.

#### 내 정보 조회

```http
GET /api/users/me
Authorization: Bearer eyJ...
```

```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "role": "USER",
    "createdAt": "2024-01-01T00:00:00"
  }
}
```

#### 이름 수정

```http
PUT /api/users/me
Authorization: Bearer eyJ...
Content-Type: application/json

{
  "name": "새이름"
}
```

---

## JWT 토큰

| 구분 | 만료 시간 | 용도 |
|------|----------|------|
| Access Token | 15분 | API 요청 시 `Authorization: Bearer` 헤더 |
| Refresh Token | 7일 | 토큰 재발급 시 `Refresh-Token` 헤더 |

- Refresh Token은 DB에 저장되며, 로그아웃 시 즉시 무효화됩니다.
- 재발급 시 기존 Refresh Token은 삭제되고 새 토큰 쌍이 발급됩니다.

---

## 권한(Role) 제어

현재 정의된 역할: `USER`, `ADMIN`

컨트롤러에서 메서드 레벨로 권한을 제어할 수 있습니다.

```java
// ADMIN만 접근 가능
@PreAuthorize("hasRole('ADMIN')")
@GetMapping("/admin/users")
public ResponseEntity<?> getAllUsers() { ... }

// 인증된 사용자 전체 접근
@PreAuthorize("isAuthenticated()")
@GetMapping("/protected")
public ResponseEntity<?> protectedEndpoint() { ... }
```

---

## 환경변수 (운영)

| 변수명 | 설명 | 예시 |
|--------|------|------|
| `JWT_SECRET` | Base64 인코딩된 32바이트 이상 키 | `base64로 인코딩된 값` |
| `DB_HOST` | PostgreSQL 호스트 | `localhost` |
| `DB_PORT` | PostgreSQL 포트 | `5432` |
| `DB_NAME` | 데이터베이스 이름 | `boilerplate` |
| `DB_USERNAME` | DB 사용자 | `boilerplate` |
| `DB_PASSWORD` | DB 비밀번호 | `****` |

> **JWT_SECRET 생성 방법**
> ```bash
> openssl rand -base64 32
> ```

---

## 인프라 구성

### 아키텍처 개요

```
ECR (이미지 레지스트리)
    │
    ├── AWS 환경
    │   ALB → ECS Fargate (app) → RDS PostgreSQL
    │         Secrets Manager (DB 접속정보, JWT Secret)
    │
    └── 온프레미스 환경
        SSH → Docker Compose (app + postgres + nginx)
              ECR에서 이미지 Pull
```

---

### AWS 환경 배포

#### 사전 준비

- AWS CLI 설치 및 `aws configure` 완료
- Terraform 1.6+ 설치

#### 1단계: tfvars 파일 작성

```bash
cd infra/terraform/environments/aws
cp terraform.tfvars.example terraform.tfvars
```

```hcl
# terraform.tfvars
project_name = "boilerplate"
aws_region   = "ap-northeast-2"

db_password = "강력한_비밀번호"
jwt_secret  = "$(openssl rand -base64 32)"
```

#### 2단계: 인프라 생성

```bash
terraform init
terraform plan    # 변경사항 미리 확인
terraform apply
```

#### 3단계: ECR에 이미지 Push

```bash
# terraform output으로 ECR URL 확인
ECR_URL=$(terraform output -raw ecr_repository_url)
AWS_REGION="ap-northeast-2"

# ECR 로그인
aws ecr get-login-password --region $AWS_REGION \
  | docker login --username AWS --password-stdin $ECR_URL

# 빌드 & Push
docker build -t $ECR_URL:latest .
docker push $ECR_URL:latest
```

#### 4단계: ECS 서비스 배포 확인

```bash
# ALB DNS 확인
terraform output alb_dns_name

# ECS 서비스 상태 확인
aws ecs describe-services \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --services $(terraform output -raw ecs_service_name) \
  --region ap-northeast-2
```

---

### 온프레미스 배포

#### 사전 준비

- 대상 서버에 SSH 접근 가능
- 대상 서버에 AWS CLI용 IAM 자격증명 설정 (ECR Pull 권한 필요)
  - 필요 권한: `ecr:GetAuthorizationToken`, `ecr:BatchGetImage`, `ecr:GetDownloadUrlForLayer`

#### 1단계: tfvars 파일 작성

```bash
cd infra/terraform/environments/on-prem
cp terraform.tfvars.example terraform.tfvars
```

```hcl
# terraform.tfvars
server_ips           = ["192.168.1.10", "192.168.1.11"]
ssh_private_key_path = "~/.ssh/id_rsa"

# AWS 환경에서 생성된 ECR URL
ecr_repository_url = "123456789012.dkr.ecr.ap-northeast-2.amazonaws.com/boilerplate/app"
image_tag          = "latest"

db_password = "강력한_비밀번호"
jwt_secret  = "AWS와_동일한_JWT_SECRET"
```

#### 2단계: 배포

```bash
terraform init
terraform apply
```

Terraform이 자동으로:
1. Docker가 없으면 설치
2. ECR에서 이미지 Pull
3. `docker-compose.yml` + `.env` + `nginx.conf` 업로드
4. `docker compose up -d` 실행

#### 새 버전 배포 (이미지 업데이트)

```bash
# ECR에 새 이미지 Push 후
terraform apply -var="image_tag=v1.2.0"
```

---

### Terraform 상태 관리 (권장)

여러 환경을 팀에서 관리할 경우 S3 백엔드를 사용합니다.

```bash
# S3 버킷 + DynamoDB 락 테이블 생성 (최초 1회)
aws s3 mb s3://your-terraform-state-bucket --region ap-northeast-2
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-northeast-2
```

각 환경의 `providers.tf`에서 `backend "s3"` 블록 주석을 해제하고 bucket 이름을 입력합니다.

---

## 새 도메인 추가하는 법

예시: `Post` 도메인 추가

```
src/main/java/com/boilerplate/domain/post/
├── Post.java              # @Entity, BaseEntity 상속
├── PostRepository.java    # JpaRepository<Post, Long>
├── PostService.java
├── PostController.java    # @RequestMapping("/api/posts")
└── dto/
    ├── PostRequest.java
    └── PostResponse.java
```

```java
// Post.java 예시
@Entity
@Table(name = "posts")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Post extends BaseEntity {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = false)
    private User author;

    @Column(nullable = false)
    private String title;

    @Builder
    private Post(User author, String title) {
        this.author = author;
        this.title = title;
    }
}
```

`BaseEntity`를 상속하면 `createdAt`, `updatedAt`, `createdBy`, `updatedBy`가 자동 관리됩니다.

---

## 자주 쓰는 명령어

```bash
# 로컬 실행
./gradlew bootRun

# 테스트 실행
./gradlew test

# 빌드 (JAR)
./gradlew bootJar

# Docker 빌드
docker build -t boilerplate:local .

# Docker Compose 실행
docker compose -f infra/docker/docker-compose.yml up -d

# Docker Compose 중지 + 볼륨 삭제
docker compose -f infra/docker/docker-compose.yml down -v
```
