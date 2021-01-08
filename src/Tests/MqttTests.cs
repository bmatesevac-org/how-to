using System;
using System.Diagnostics;
using System.IO;
using System.Net.Sockets;
using System.Threading;
using System.Threading.Tasks;
using Bct.Common.Device.Communications.Api.ComponentTests;
using MQTTnet;
using MQTTnet.Client;
using MQTTnet.Client.Disconnecting;
using MQTTnet.Client.Options;
using MQTTnet.Formatter;
using Xunit;

namespace Tests
{
    public class MqttTests
    {
        public bool waitForPort(string ip, int port, int timeout)
        {
            var stopwatch = new Stopwatch();
            stopwatch.Restart();
            using (var client = new TcpClient())
            {
                for (;;)
                {
                    try
                    {
                        var task = client.ConnectAsync(ip, port);
                        if (task.Wait(timeout))
                        {
                            //if fails within timeout, task.Wait still returns true.
                            if (client.Connected)
                            {
                                client.Close();
                                return true;
                            }
                        }
                    }
                    catch
                    {
                    }
                    if (stopwatch.ElapsedMilliseconds >= timeout)
                        return false;
                }
            }
            return false;
        }

        private async Task ClientConnectAsync(
            IMqttClient client, 
            IMqttClientOptions options, 
            CancellationToken token,
            int timeoutMS)
        {
            var stopwatch = new Stopwatch();
            stopwatch.Restart();
            for (; ; )
            {
                try
                {
                    await client.ConnectAsync(options, CancellationToken.None);
                    return ;
                }
                catch (Exception e)
                {
                    if (stopwatch.ElapsedMilliseconds >= timeoutMS)
                        throw;
                    Thread.Sleep(1000);
                }
            }
        }

        [Fact]
        public async Task StartMqttBrokerUsingProcess()
        {
            using (var proc = new Process())
            {
                try
                {
                    proc.StartInfo.UseShellExecute = false;
                    proc.StartInfo.RedirectStandardOutput = false;
                    var args = "docker-compose -f docker-compose-vernemq.yaml down";
                    proc.StartInfo.FileName = "powershell.exe";
                    proc.StartInfo.Arguments = args;
                    proc.Start();
                    proc.WaitForExit();


                    args = "docker-compose -f docker-compose-vernemq.yaml up";
                    proc.StartInfo.Arguments = args;
                    proc.Start();

                    var timeout = 20000;

                    var factory = new MqttFactory();
                    var mqttClient = factory.CreateMqttClient();

                    var options = new MqttClientOptionsBuilder()
                        .WithClientId("MqttTestClient")
                        .WithCleanSession()
                        .WithCommunicationTimeout(TimeSpan.FromMilliseconds(1000))
                        .WithProtocolVersion(MqttProtocolVersion.V500)
                        .WithCredentials("admin", "pass")
                        .WithTcpServer("127.0.0.1", 1883) // Port is optional
                        .Build();

                    await ClientConnectAsync(mqttClient, options, CancellationToken.None, timeout);
                    var isConnected = SpinWait.SpinUntil(() => { return (mqttClient.IsConnected); },
                        TimeSpan.FromSeconds(10));
                    Assert.True(mqttClient.IsConnected);
                }
                catch (Exception e)
                {
                    Debug.WriteLine(e);
                }
            }

        }

        [Fact]
        public async Task StartMqttBrokerUsingFluentDocker()
        {
            using (var container = new MqttBrokerContainer())
            {
                try
                {
                    container.Compose();
                    var timeout = 20000;
                    var factory = new MqttFactory();
                    var mqttClient = factory.CreateMqttClient();

                    var options = new MqttClientOptionsBuilder()
                        .WithClientId("MqttTestClient")
                        .WithCleanSession()
                        .WithCommunicationTimeout(TimeSpan.FromMilliseconds(1000))
                        .WithProtocolVersion(MqttProtocolVersion.V500)
                        .WithCredentials("admin", "pass")
                        .WithTcpServer("127.0.0.1", 1883) // Port is optional
                        .Build();

                    await ClientConnectAsync(mqttClient, options, CancellationToken.None, timeout);
                    var isConnected = SpinWait.SpinUntil(() => { return (mqttClient.IsConnected); },
                        TimeSpan.FromSeconds(10));
                    Assert.True(mqttClient.IsConnected);
                }
                catch (Exception e)
                {
                    Debug.WriteLine(e);
                }
            }

        }


    }

}
