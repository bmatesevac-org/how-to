using System;
using System.Diagnostics;
using System.IO;

namespace process
{




    class Program
    {


        void Run()
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


        static void Main(string[] args)
        {
            var program = new Program();
            program.Run();
        }
    }
}
