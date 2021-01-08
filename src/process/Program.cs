using System;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using MQTTnet;
using MQTTnet.Client.Options;
using Xunit;
using Tests;


namespace process
{

    

    class Program
    {
        async Task Run()
        {
            var tests = new MqttTests();
            await tests.StartMqttBrokerUsingFluentDocker();
        }

        static async Task Main(string[] args)
        {
            var program = new Program();
            await program.Run();
        }

        void RunBasicProcess()
        {
            using (var proc = new Process())
            {
                try
                {
                    proc.StartInfo.UseShellExecute = false;
                    proc.StartInfo.RedirectStandardOutput = true;
                    var folder = Directory.GetCurrentDirectory();
                    var file = "powershell-script.ps1";
                    var filePath = $"{folder}/{file}";
                    proc.StartInfo.Environment["EXPECTED-ENV_VAR"] = "EXPECTED-ENV_VAR-VALUE";
                    proc.StartInfo.FileName = "powershell.exe";
                    proc.StartInfo.Arguments = filePath;
                    proc.Start();
                    string s = proc.StandardOutput.ReadToEnd();
                    proc.WaitForExit();
                    Debug.WriteLine(s);
                    Console.WriteLine(s);

                }
                catch (Exception e)
                {
                    Debug.WriteLine(e);
                }
            }
        }

        async Task RunDockerProcess()
        {

        }

    }
}
