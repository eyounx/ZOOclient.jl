begin
  server = listen(9999)
  sock = accept(server)
  println(readline(sock))
end
