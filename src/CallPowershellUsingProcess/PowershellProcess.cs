using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CallPowershellUsingProcess
{
    public class PowershellProcess
    {
        private TimeSpan _timeout = TimeSpan.FromSeconds(20);

        public PowershellProcess()
        {
        }

        public void Execute(string command)
        {
            Execute(command, _timeout);
        }

        public void Execute(string command, TimeSpan timeout)
        {
            using (var proc = new Process())
            {
                proc.StartInfo = new ProcessStartInfo()
                {
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true,
                    FileName = "powershell.exe",
                    Arguments = command,
                };

                proc.OutputDataReceived += (s, ev) =>
                {
                    Console.WriteLine(ev.Data);
                };
                proc.ErrorDataReceived += (s, err) =>
                {
                    Console.WriteLine(err.Data);
                };
                proc.EnableRaisingEvents = true;

                if (!proc.Start())
                {
                    throw new Exception($"Failed to execute command ({command})");
                }

                proc.BeginErrorReadLine();
                proc.BeginOutputReadLine();
                proc.WaitForExit((int)timeout.TotalMilliseconds);

                // check return code
                if (proc.ExitCode != 0)
                {
                    throw new Exception($"Command ({command}) exited with code {proc.ExitCode}");
                }

            }
        }


    }

}
