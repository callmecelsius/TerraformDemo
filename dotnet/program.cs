using System;
using Amazon.Lambda.Core;
using Amazon.Lambda.Serialization.Json;

namespace LambdaTest
{
	public class LambdaHandler
	{
		[LambdaSerializer(typeof(JsonSerializer))]
		public string handleRequest(object evt, ILambdaContext context)
		{
			context.Logger.LogLine(evt.ToString());
			return "Hello from Lambda-dotnet!";
		}
	}
}
