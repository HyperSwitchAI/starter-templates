using System.Threading.Tasks;
using CommandLine;

namespace HyperSwitchAI
{
    [Verb("gettoken", HelpText = "Get an authentication token")]
    class GetTokenOptions { }

    [Verb("cachetoken", HelpText = "Get and cache an authentication token")]
    class CacheTokenOptions { }

    [Verb("addkey", HelpText = "Add a new API key")]
    class AddKeyOptions { }

    [Verb("addawscredentials", HelpText = "Add AWS credentials")]
    class AddAwsCredentialsOptions { }

    [Verb("addstrategy", HelpText = "Add a new strategy")]
    class AddStrategyOptions { }

    [Verb("listkeys", HelpText = "List all API keys")]
    class ListKeysOptions { }

    [Verb("deletekey", HelpText = "Delete an API key")]
    class DeleteKeyOptions { }

    [Verb("deletestrategy", HelpText = "Delete a strategy")]
    class DeleteStrategyOptions { }

    [Verb("liststrategies", HelpText = "List all strategies")]
    class ListStrategiesOptions { }

    [Verb("updatestrategy", HelpText = "Update a strategy")]
    class UpdateStrategyOptions { }

    class Program
    {
        static async Task<int> Main(string[] args)
        {
            return await Parser.Default.ParseArguments<GetTokenOptions, CacheTokenOptions, AddKeyOptions, AddAwsCredentialsOptions, AddStrategyOptions, ListKeysOptions, DeleteKeyOptions, DeleteStrategyOptions, ListStrategiesOptions, UpdateStrategyOptions>(args)
                .MapResult(
                    async (GetTokenOptions opts) =>
                    {
                        await GetToken.RunAsync();
                        return 0;
                    },
                    async (CacheTokenOptions opts) =>
                    {
                        await CacheToken.RunAsync();
                        return 0;
                    },
                    async (AddKeyOptions opts) =>
                    {
                        await AddKey.RunAsync();
                        return 0;
                    },
                    async (AddAwsCredentialsOptions opts) =>
                    {
                        await AddAwsCredentials.RunAsync();
                        return 0;
                    },
                    async (AddStrategyOptions opts) =>
                    {
                        await AddStrategy.RunAsync();
                        return 0;
                    },
                    async (ListKeysOptions opts) =>
                    {
                        await ListKeys.RunAsync();
                        return 0;
                    },
                    async (DeleteKeyOptions opts) =>
                    {
                        await DeleteKey.RunAsync();
                        return 0;
                    },
                    async (DeleteStrategyOptions opts) =>
                    {
                        await DeleteStrategy.RunAsync();
                        return 0;
                    },
                    async (ListStrategiesOptions opts) =>
                    {
                        await ListStrategies.RunAsync();
                        return 0;
                    },
                    async (UpdateStrategyOptions opts) =>
                    {
                        await UpdateStrategy.RunAsync();
                        return 0;
                    },
                    errs => Task.FromResult(1));
        }
    }
}
