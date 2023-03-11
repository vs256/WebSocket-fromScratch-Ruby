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
            #complete the handshake
            ws_accept = create__accept($1) #create websocket accept
            send_handshake_response(socket, ws_accept) #send back a response that websocket is accepted to upgrade
            return true
        end
        send_400(socket)
        false # reject the handshake
    end

    def send_handshake_response(socket, ws_accept)
        socket << "HTTP/1.1 101 Switching Protocols\r\n"
                  "Upgrade: websocket\r\n"
                  "Connection: Upgrade\r\n"
                  "Sec-WebSocket-Accept: #{ws_accept}\r\n"
    end

    WS_MAGIC_STRING = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

    def create_websocket_accept(key)
        digest = Digest::SHA1.digest(key + WS_MAGIC_STRING)
        Base64.encode64(digest)
    end

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