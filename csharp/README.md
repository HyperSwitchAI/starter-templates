# HyperSwitch AI C# Examples

C# examples for interacting with the HyperSwitch AI API. These examples demonstrate authentication, API key management, and strategy configuration using modern C# practices.

## Prerequisites

- .NET 6.0 or higher
- A HyperSwitch AI account and credentials

## Setup

1. Build the project:
```bash
dotnet build
```

2. Create a `.env` file in the `csharp/HyperSwitchAI` directory with your HyperSwitchAI credentials:
```env
USERNAME=your_username
PASSWORD=your_password
```

## Available Examples

### Authentication
- `GetToken.cs` - Get a new authentication token
- `CacheToken.cs` - Demonstrates token caching for efficient authentication

### API Key Management
- `AddKey.cs` - Add a new API key
- `ListKeys.cs` - List all API keys
- `DeleteKey.cs` - Delete an API key
- `AddAwsCredentials.cs` - Add AWS credentials

### Strategy Management
- `AddStrategy.cs` - Add a new strategy
- `ListStrategies.cs` - List all strategies
- `UpdateStrategy.cs` - Update an existing strategy
- `DeleteStrategy.cs` - Delete a strategy

## Usage

Run any example using the dotnet CLI:
```bash
dotnet run gettoken
dotnet run cachetoken
dotnet run addkey
dotnet run listkeys
dotnet run deletekey
dotnet run addawscredentials
dotnet run addstrategy
dotnet run liststrategies
dotnet run updatestrategy
dotnet run deletestrategy
```

## Implementation Details

- Uses `HttpClient` for HTTP operations
- Implements token caching for efficient authentication
- Uses command-line parsing with `CommandLineParser`
- Handles errors gracefully with appropriate messages
- Uses environment variables for secure credential management
- Follows C# best practices and modern coding standards

## Common Operations

### Authentication
```csharp
// Token is automatically cached and reused until expiration
var token = await CacheToken.GetToken();
```

### Making API Requests
```csharp
using (var client = new HttpClient())
{
    client.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}");
    var response = await client.PostAsync(url, content);
}
```

### Error Handling
```csharp
try
{
    if (!response.IsSuccessStatusCode)
    {
        if (response.StatusCode == System.Net.HttpStatusCode.Conflict)
        {
            // Handle specific error cases
        }
        throw new Exception($"API request failed: {response.StatusCode}");
    }
}
catch (Exception ex)
{
    Console.WriteLine($"Error: {ex.Message}");
}
```

## Dependencies

NuGet packages (from .csproj):
```xml
<ItemGroup>
    <PackageReference Include="CommandLineParser" Version="2.9.1" />
    <PackageReference Include="DotNetEnv" Version="2.5.0" />
</ItemGroup>
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
