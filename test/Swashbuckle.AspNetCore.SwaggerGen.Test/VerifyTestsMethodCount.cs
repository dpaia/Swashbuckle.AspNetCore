using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using Xunit;

namespace Swashbuckle.AspNetCore.SwaggerGen.Test;

public class VerifyTestsMethodCount
{
    [Fact]
    public void TestCountMethods()
    {
        var flags = BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly;
        var methods = typeof(VerifyTests).GetMethods(flags);
        Assert.Equal(44, methods.Length);

        var sourceDir = Path.GetDirectoryName(GetThisFilePath());
        var sourceFile = Path.Combine(sourceDir!, "VerifyTests.cs");
        var nonEmptyLines = File.ReadLines(sourceFile).Count(line => !string.IsNullOrWhiteSpace(line));
        Assert.Equal(1515, nonEmptyLines);
    }

    private static string GetThisFilePath([CallerFilePath] string path = "") => path;
}
