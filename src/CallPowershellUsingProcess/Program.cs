// See https://aka.ms/new-console-template for more information


using CallPowershellUsingProcess;

Console.WriteLine("Hello, World!");

var ps = new PowershellProcess();

ps.Execute("ls");

