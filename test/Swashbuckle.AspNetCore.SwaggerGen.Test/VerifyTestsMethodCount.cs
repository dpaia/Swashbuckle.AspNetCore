using System.Reflection;
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
    }
}
