# HyperSwitch AI Java Examples

Java examples for interacting with the HyperSwitch AI API. These examples demonstrate authentication, API key management, and strategy configuration using modern Java practices.

## Prerequisites

- Java 11 or higher
- Maven
- A HyperSwitch AI account and credentials

## Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/hyperswitchai-examples.git
cd hyperswitchai-examples/java
```

2. Build the project:
```bash
mvn clean compile
```

3. Create a `.env` file in the root directory with your credentials:
```env
USERNAME=your_username
PASSWORD=your_password
```

## Available Examples

### Authentication
- `CacheToken.java` - Demonstrates token caching for efficient authentication

### API Key Management
- `AddKey.java` - Add a new API key
- `ListKeys.java` - List all API keys
- `DeleteKey.java` - Delete an API key
- `AddAwsCredentials.java` - Add AWS credentials

### Strategy Management
- `AddStrategy.java` - Add a new strategy
- `ListStrategies.java` - List all strategies
- `UpdateStrategy.java` - Update an existing strategy
- `DeleteStrategy.java` - Delete a strategy

## Usage

First compile the project:
```bash
mvn clean compile
```

Then run any example using Maven:
```bash
mvn exec:java -Dexec.mainClass="com.hyperswitchai.examples.CacheToken"
mvn exec:java -Dexec.mainClass="com.hyperswitchai.examples.AddKey"
# etc...
```

## Implementation Details

- Uses `HttpClient` for HTTP operations
- Implements token caching for efficient authentication
- Handles errors gracefully with appropriate messages
- Uses environment variables for secure credential management
- Follows Java best practices and modern coding standards

## Common Operations

### Authentication
```java
// Token is automatically cached and reused until expiration
String token = TokenManager.getToken();
```

### Making API Requests
```java
HttpClient client = HttpClient.newHttpClient();
HttpRequest request = HttpRequest.newBuilder()
    .uri(URI.create(BASE_URL + "/endpoint"))
    .header("Content-Type", "application/json")
    .header("Authorization", "Bearer " + token)
    .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
    .build();
```

### Error Handling
```java
try {
    HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
    if (response.statusCode() != 200) {
        throw new RuntimeException("API request failed: " + response.body());
    }
} catch (Exception e) {
    System.err.println("Error: " + e.getMessage());
}
```

## Project Structure

```
java/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── hyperswitchai/
│       │           └── examples/
│       │               ├── CacheToken.java
│       │               ├── AddKey.java
│       │               ├── ListKeys.java
│       │               ├── DeleteKey.java
│       │               ├── AddAwsCredentials.java
│       │               ├── AddStrategy.java
│       │               ├── ListStrategies.java
│       │               ├── UpdateStrategy.java
│       │               └── DeleteStrategy.java
│       └── resources/
│           └── .env
├── pom.xml
└── README.md
```

## Dependencies

Maven dependencies (from pom.xml):
```xml
<dependencies>
    <!-- JSON processing -->
    <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
        <version>2.15.2</version>
    </dependency>
    <!-- .env file support -->
    <dependency>
        <groupId>io.github.cdimascio</groupId>
        <artifactId>dotenv-java</artifactId>
        <version>3.0.0</version>
    </dependency>
</dependencies>
```

## Security Notes

- Never commit the `.env` file to version control
- Keep your API keys and encryption fragments secure
- Use environment variables for sensitive data
- Follow security best practices for credential management

## Support

For questions about:
- The HyperSwitch AI service: Visit [HyperSwitchAI.com](https://HyperSwitchAI.com)
- API documentation: Check [console.hyperswitchai.com/docs.html](https://console.hyperswitchai.com/docs.html)
- These examples: Contact HyperSwitch AI support 