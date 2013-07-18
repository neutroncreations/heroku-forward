#!/usr/bin/env ruby
# A quick and dirty implementation of an HTTP proxy server in Ruby
# because I did not want to install anything.
#
# Copyright (C) 2009 Torsten Becker <torsten.becker@gmail.com>

require 'socket'
require 'uri'


class Proxy
  def run port
    begin
      puts "Starting up..."
      # Start our server to handle connections (will raise things on errors)
      @socket = TCPServer.new port

      # Handle every request in another thread
      loop do
        s = @socket.accept
        puts "Connection Accepted."
        Thread.new s, &method(:handle_request)
      end

    # CTRL-C
    rescue Interrupt
      puts 'Got Interrupt..'
    # Ensure that we release the socket on errors
    ensure
      if @socket
        @socket.close
        puts 'Socked closed..'
      end
      puts 'Quitting.'
    end
  end

  def handle_request to_client
    request_line = to_client.readline

    verb    = request_line[/^\w+/]
    url     = request_line[/^\w+\s+(\S+)/, 1]
    version = request_line[/HTTP\/(1\.\d)\s*$/, 1]

    # Show what got requested
    puts((" %4s "%verb) + url)

    to_server = TCPSocket.new(ENV['FORWARD_HOST'], ENV['FORWARD_PORT'])
    to_server.write("#{verb} #{url} HTTP/#{version}\r\n")

    content_len = 0

    loop do
      line = to_client.readline
      # puts line

      if line =~ /^Content-Length:\s+(\d+)\s*$/
        content_len = $1.to_i
      end

      # Strip proxy headers
      if line =~ /^proxy/i
        next
      elsif line.strip.empty?
        to_server.write("Connection: close\r\n\r\n")

        if content_len >= 0
          to_server.write(to_client.read(content_len))
        end

        break
      else
        to_server.write(line)
      end
    end

    buff = ""
    while buff = to_server.read(2048)
      to_client.write(buff)
    end

    # Close the sockets
    to_client.close
    to_server.close
  rescue EOFError => e
    puts e.message
  end

end

Proxy.new.run ENV['PORT'].to_i