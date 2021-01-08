using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Ductus.FluentDocker;
using Ductus.FluentDocker.Builders;
using Ductus.FluentDocker.Extensions;
using Ductus.FluentDocker.Model.Common;
using Ductus.FluentDocker.Services;
using Xunit;

namespace Bct.Common.Device.Communications.Api.ComponentTests
{

   // Implement IDisposable so that we have control over shutting down the
   // the Docker container when it is no longer in use

   public class MqttBrokerContainer : IDisposable
   {
      private ICompositeService _service;
      private Process _process;
      private bool _disposed = false;

      public void Dispose()
      {
         Dispose(true);
         GC.SuppressFinalize(this);
      }

      protected virtual void Dispose(bool disposing)
      {
         // Check to see if Dispose has already been called.
         if (!_disposed)
         {
            // If disposing equals true, dispose all managed
            // and unmanaged resources.
            if (disposing)
            {
               // Dispose managed resources.
               _service?.Dispose();
               _process?.Dispose();
            }
            _disposed = true;
         }
      }
        

      public void Compose()
      {
         var folder = Directory.GetCurrentDirectory();
         var file = "docker-compose-vernemq.yaml";
         var containerPath = $"{folder}/{file}";

         Console.WriteLine("Composing");

         try
         {
            _service = new Builder()
               .UseContainer()
               .UseCompose()
               .FromFile(containerPath)
               .RemoveOrphans()
               .WaitForPort("vernemq", "8883/tcp", 30000 /*30s*/)
               .Build();

            _service.Start();
         }
         catch (Exception e)
         {
            Debug.WriteLine(e);
            Console.WriteLine(e);
            throw;
         }
      }

   }




}
