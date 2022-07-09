using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;
using Xunit;

namespace Bct.Github.Validation.Tests.Infrastructure
{
   public class PowerShellProcess
   {

      public PowerShellProcess()
      {
      }

      public string WorkingDirectory { get; set; }

      public static ProcessStartInfo CreateProcessStartInfo(string command, string workingDirectory)
      {
         var startInfo = new ProcessStartInfo()
         {
            UseShellExecute = false,
            RedirectStandardOutput = true,
            FileName = "pwsh.exe",
            Arguments = $"-NoLogo -Command {command}"
         };
         if (workingDirectory != null)
         {
            startInfo.WorkingDirectory = workingDirectory;
         }
         return startInfo;
      }

      public void Command(string command)
      {
         var startInfo = CreateProcessStartInfo(command, WorkingDirectory);
         Command(startInfo);
      }

      public void Command(ProcessStartInfo startInfo)
      {
         using var process = new Process()
         {
            StartInfo = startInfo
         };
         process.Start();
         string s = process.StandardOutput.ReadToEnd();
         process.WaitForExit();
         Assert.True(process.ExitCode == 0);
         Output.WriteLine(s);
      }
   }
}
