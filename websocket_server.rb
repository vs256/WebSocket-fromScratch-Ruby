require 'socket'

class WebSocketServer

    def initialize(options={path: '/', port: 4567, host: 'localhost'})
        @path, port, host = options[:path], options[:port], options[:host]
        @tcp_server = TCPServer.new(host,port)
    end
    
    def accept
        socket = @tcp_server.accept
        send_handshake(socket) && WebSocketConnection.new(socket)
    end

end