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
├── pom.xml
├── README.md
└── src/
    ├── main/
    │   ├── java/
    │   │   └── pl/slsolutions/devopstest/
    │   │       ├── Application.java
    │   │       └── VisitorController.java
    │   └── resources/
    │       └── application.properties
    └── test/
        ├── java/
        │   └── pl/slsolutions/devopstest/
        │       ├── ApplicationTests.java
        │       └── VisitorControllerTest.java
        └── resources/
            └── application-test.properties
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

## Notes

- Tests use H2 in-memory database configured in `application-test.properties`
- The `@SpringBootTest` and `@AutoConfigureMockMvc` annotations enable integration testing
- Tests are automatically run during the Maven build process
- The Surefire plugin is configured to run all tests matching `*Tests.java` and `*Test.java` patterns

