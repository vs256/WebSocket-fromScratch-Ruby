require 'socket'
require 'digest/sha1'
require 'base64'


class WebSocketServer

    def initialize(options={path: '/', port: 4567, host: 'localhost'})
        @path, port, host = options[:path], options[:port], options[:host]
        @tcp_server = TCPServer.new(host,port)
    end
    
    def accept
        socket = @tcp_server.accept
        send_handshake(socket) && WebSocketConnection.new(socket)
    end

    def send_handshake(socket)
        request_line = socket.gets
        header = get_header(socket)
        if (request_line =~ /GET #{@path} HTTP\/1.1/) && (header =~ /Sec-WebSocket-Key: (.*)\r\n/)
            ws_accept = create__accept($1)
            #complete the handshake
        end
        send_400(socket)
        false # reject the handshake

    end

    WS_MAGIC_STRING = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"


    def send_400(socket)
        socket << "HTTP/1.1 400 Bad Request\r\n" +
                  "Content-Type: text/plain\r\n" +
                  "Connection: close\r\n" +
                  "\r\n" +
                  "Incorrect request"
        socket.close
    end
    
    def get_header(socket, header = "") #gets the header by recursively reading each line offered by the socket
        (line = socket.gets) == "rn" ? header : get_header(socket, header + line)
    end

end