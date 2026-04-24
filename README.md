# Spring Boot DevOps Test Application

Spring Boot application that demonstrates database connectivity through a REST API.

## Features

- **GET `/`** - Returns a greeting and the total number of database visits
  - Creates the `visits` table if it doesn't exist
  - Inserts a new visit record with the current timestamp
  - Returns the total count of visits
  
- **GET `/health`** - Health check endpoint that returns "UP"

## Prerequisites

- Java 17 or higher
- Maven 3.6+
- PostgreSQL 12+ (or H2 for development/testing)

## Building the Application

The build process automatically runs all unit tests:

```bash
mvn clean package
```

This command will:
1. Clean previous builds
2. Compile the source code
3. Run all unit tests (5 tests total)
4. Package the application as a JAR file

### Running Tests Only

```bash
mvn clean test
```

## Running the Application

### With PostgreSQL

1. Ensure PostgreSQL is running and create a database:
```sql
CREATE DATABASE devops_db;
```

2. Update database credentials in `src/main/resources/application.properties` if needed

3. Run the application:
```bash
mvn spring-boot:run
```

Or run the built JAR:
```bash
java -jar target/devops-test-1.0.0.jar
```

### With H2 (In-Memory Database)

The application uses H2 in-memory database for testing by default. For development:

```bash
mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=test"
```

## Testing

### Test Coverage

The project includes 5 unit tests:

1. **ApplicationTests**
   - `contextLoads` - Verifies that the Spring Boot application context loads correctly

2. **VisitorControllerTest**
   - `testHealthEndpoint` - Tests the `/health` endpoint
   - `testHelloEndpoint` - Tests the `/` endpoint returns correct response
   - `testHelloEndpointReturnsVisitCount` - Tests that visit count is tracked
   - `testMultipleVisits` - Tests multiple consecutive visits

### Running Tests

```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=VisitorControllerTest

# Run specific test method
mvn test -Dtest=VisitorControllerTest#testHealthEndpoint
```

### Testing the Application

Once the application is running, you can test the endpoints:

```bash
# Test the main endpoint
curl http://localhost:8080/

# Test the health check
curl http://localhost:8080/health
```

## Project Structure

```
sls-recruitment/
├── Dockerfile
├── docker-compose.yml        # local development with PostgreSQL
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/pl/slsolutions/devopstest/
│   │   │   ├── Application.java
│   │   │   └── VisitorController.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       ├── java/pl/slsolutions/devopstest/
│       │   ├── ApplicationTests.java
│       │   └── VisitorControllerTest.java
│       └── resources/
│           └── application-test.properties
├── terraform/                # GCP infrastructure (VPC, GKE, Cloud SQL, Artifact Registry)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   ├── apis.tf
│   └── modules/
│       ├── vpc/
│       ├── gke/
│       ├── cloud-sql/
│       ├── artifact-registry/
│       └── github-actions-wif/
├── kubernetes/               # Kubernetes manifests
│   ├── namespace.yaml
│   ├── serviceaccount.yaml   # Workload Identity binding
│   ├── deployment.yaml       # app + Cloud SQL Auth Proxy sidecar
│   └── service.yaml          # LoadBalancer
└── .github/workflows/
    ├── build.yml             # test → build → push → deploy (on push to main)
    └── terraform.yml         # plan / apply infrastructure (manual trigger)
```

## Dependencies

- Spring Boot 3.2.0
- Spring Data JDBC
- PostgreSQL Driver
- H2 Database (for development and testing)
- JUnit 5
- Spring Test

## Build Output

When you run `mvn clean package`, you'll get:

```
[INFO] Results:
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] BUILD SUCCESS
```

The packaged JAR file will be located at: `target/devops-test-1.0.0.jar`

## Configuration Profiles

- **default (production)** - Uses PostgreSQL database
- **test** - Uses H2 in-memory database for testing

## Deployment to GKE

The application runs on Google Kubernetes Engine backed by Cloud SQL (PostgreSQL). Infrastructure is managed with Terraform and deployment is automated via GitHub Actions.

### Prerequisites

Install the following tools before starting:

- [`gcloud`](https://cloud.google.com/sdk/docs/install) — Google Cloud CLI
- [`terraform`](https://developer.hashicorp.com/terraform/install) >= 1.5
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/)

### Step 1 — GCP project setup

```bash
# Authenticate
gcloud auth login
gcloud auth application-default login

# Create a new project (skip if you already have one)
gcloud projects create YOUR_PROJECT_ID --name="DevOps Test"

# Set it as the active project
gcloud config set project YOUR_PROJECT_ID

# Link billing account (required for GKE and Cloud SQL)
# List your billing accounts:
gcloud billing accounts list
gcloud billing projects link YOUR_PROJECT_ID --billing-account=YOUR_BILLING_ACCOUNT_ID
```

### Step 2 — Create the Terraform state bucket

The GCS bucket for Terraform state must exist before running `terraform init`.
Terraform cannot manage its own state bucket.

```bash
# Bucket names must be globally unique — using project ID as prefix is a safe convention
export TF_BUCKET="YOUR_PROJECT_ID-terraform-state"

gcloud storage buckets create gs://$TF_BUCKET \
  --project=YOUR_PROJECT_ID \
  --location=europe-west1 \
  --uniform-bucket-level-access

# Enable versioning so previous state files are recoverable
gcloud storage buckets update gs://$TF_BUCKET --versioning
```

### Step 3 — Bootstrap infrastructure (one-time, run locally)

The Terraform ops pipeline cannot run yet because Workload Identity Federation does not exist until after the first apply. The initial apply must be done locally.

```bash
cd terraform

# Create a local vars file — gitignored, never commit this
echo 'project_id = "YOUR_PROJECT_ID"' > terraform.tfvars

terraform init -backend-config="bucket=YOUR_PROJECT_ID-terraform-state"
terraform apply
```

### Step 4 — Add GitHub Secrets

Go to **GitHub → your repo → Settings → Secrets and variables → Actions** and add:

| Secret | Value |
|---|---|
| `GCP_PROJECT_ID` | `YOUR_PROJECT_ID` |
| `TF_BACKEND_BUCKET` | `YOUR_PROJECT_ID-terraform-state` |
| `GCP_WIF_PROVIDER` | `terraform output -raw wif_provider` |
| `GCP_SA_EMAIL` | `terraform output -raw github_actions_sa_email` |
| `GCP_TERRAFORM_SA_EMAIL` | `terraform output -raw terraform_sa_email` |
| `GCP_APP_SA_EMAIL` | `terraform output -raw app_sa_email` |
| `CLOUD_SQL_CONNECTION_NAME` | `terraform output -raw cloud_sql_connection_name` |

### Step 5 — Push to main

```bash
git push origin main
```

The app pipeline runs automatically: tests → build → push image to Artifact Registry → deploy to GKE.

### Step 6 — Get the public IP

```bash
# Configure kubectl
$(terraform output -raw get_credentials_command)

# Wait for the LoadBalancer IP to be assigned (takes ~1 minute)
kubectl get service devops-test -n devops-test

curl http://<EXTERNAL-IP>/health
```

### Ongoing workflow

| Task | How |
|---|---|
| Deploy a new app version | Push to `main` |
| Change infrastructure | GitHub → Actions → Terraform → Run workflow |

---

## Notes

- Tests use H2 in-memory database configured in `application-test.properties`
- The `@SpringBootTest` and `@AutoConfigureMockMvc` annotations enable integration testing
- Tests are automatically run during the Maven build process
- The Surefire plugin is configured to run all tests matching `*Tests.java` and `*Test.java` patterns

