

function Clear-Docker {
   docker ps -a -q | % { docker stop $_ }
   docker ps -a -q | % { docker rm $_ }
   # docker images --filter "dangling=true" -q --no-trunc | % { docker rmi $_ -f }
   docker volume ls -qf dangling=true | % { docker volume rm $_ }
   #docker system prune -a
   docker system prune 
}
