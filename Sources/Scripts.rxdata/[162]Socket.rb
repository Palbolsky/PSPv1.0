#==========================================#
#¤Script de gestion de Socket              #
#------------------------------------------#
#©Ruby  - Réservé à pkmn Orbe doré         #
#==========================================#
module Win32
  Rtl_Move_MEM=Win32API.new("kernel32", "RtlMoveMemory", "ppl", "")
  def copymem(len)
    buf = "\0" * len
    Rtl_Move_MEM.call(buf, self, len)
    buf
  end
end
class Numeric
  include Win32
end
class String
  include Win32
end

module Winsock
  DLL = "ws2_32"
  A_ACCEPT=Win32API.new(DLL, "accept", "ppl", "l")
  A_BLIND=Win32API.new(DLL, "bind", "ppl", "l")
  A_CLOSE_S=Win32API.new(DLL, "closesocket", "p", "l")
  A_CONNECT=Win32API.new(DLL, "connect", "ppl", "l")
  A_GHBADD=Win32API.new(DLL, "gethostbyaddr", "pll", "l")
  A_GHBNAME=Win32API.new(DLL, "gethostbyname", "p", "l")
  A_GHNAME=Win32API.new(DLL, "gethostname", "pl", "")
  A_GSBNAME=Win32API.new(DLL, "getservbyname", "pp", "p")
  A_HTONL=Win32API.new(DLL, "htonl", "l", "l")
  A_HTONS=Win32API.new(DLL, "htons", "l", "l")
  A_INET_ADD=Win32API.new(DLL, "inet_addr", "p", "l")
  A_INET_NTOA=Win32API.new(DLL, "inet_ntoa", "l", "p")
  A_LISTEN=Win32API.new(DLL, "listen", "pl", "l")
  A_RECV=Win32API.new(DLL, "recv", "ppll", "l")
  A_SELECT=Win32API.new(DLL, "select", "lpppp", "l")
  A_SEND=Win32API.new(DLL, "send", "ppll", "l")
  A_SSOPT=Win32API.new(DLL, "setsockopt", "pllpl", "l")
  A_SHUT_DOWN=Win32API.new(DLL, "shutdown", "pl", "l")
  A_SOCKET=Win32API.new(DLL, "socket", "lll", "l")
  A_LAST_ERR=Win32API.new(DLL, "WSAGetLastError", "", "l")
  module_function
  def accept(a,b,c) A_ACCEPT.call(a,b,c) end
  def bind(a,b,c) A_BLIND.call(a,b,c) end
  def closesocket(a) A_CLOSE_S.call(a) end   
  def connect(a,b,c) A_CONNECT.call(a,b,c) end        
  def gethostbyaddr(a,b,c) A_GHBADD.call(a,b,c) end
  def gethostbyname(a) A_GHBNAME.call(a) end
  def gethostname(a,b) A_GHNAME.call(a,b) end
  def getservbyname(a,b) A_GSBNAME.call(a,b) end
  def htonl(a) A_HTONL.call(a) end
  def htons(a) A_HTONS.call(a) end
  def inet_addr(a) A_INET_ADD.call(a) end
  def inet_ntoa(a) A_INET_NTOA.call(a) end   
  def listen(a,b) A_LISTEN.call(a,b) end
  def recv(a,b,c,d) A_RECV.call(a,b,c,d) end
  def select(a,b,c,d,e) A_SELECT.call(a,b,c,d,e) end
  def send(a,b,c,d) A_SEND.call(a,b,c,d) end
  def setsockopt(a,b,c,d,e) A_SSOPT.call(a,b,c,d,e) end   
  def shutdown(a,b) A_SHUT_DOWN.call(a,b) end
  def socket(a,b,c) A_SOCKET.call(a,b,c) end
  def WSAGetLastError() A_LAST_ERR.call() end
end

class Socket
  API_WRITE=Win32API.new("msvcrt", "_write", "lpl", "l")
  AF_UNSPEC = 0   
  AF_UNIX = 1
  AF_INET = 2
  AF_IPX = 6
  AF_APPLETALK = 16 
  PF_UNSPEC = 0   
  PF_UNIX = 1
  PF_INET = 2
  PF_IPX = 6
  PF_APPLETALK = 16 
  SOCK_STREAM = 1
  SOCK_DGRAM = 2
  SOCK_RAW = 3
  SOCK_RDM = 4
  SOCK_SEQPACKET = 5
  IPPROTO_IP = 0
  IPPROTO_ICMP = 1
  IPPROTO_IGMP = 2
  IPPROTO_GGP = 3
  IPPROTO_TCP = 6
  IPPROTO_PUP = 12
  IPPROTO_UDP = 17
  IPPROTO_IDP = 22
  IPPROTO_ND = 77
  IPPROTO_RAW = 255
  IPPROTO_MAX = 256
  SOL_SOCKET = 65535
  SO_DEBUG = 1
  SO_REUSEADDR = 4
  SO_KEEPALIVE = 8
  SO_DONTROUTE = 16
  SO_BROADCAST = 32
  SO_LINGER = 128
  SO_OOBINLINE = 256
  SO_RCVLOWAT = 4100
  SO_SNDTIMEO = 4101
  SO_RCVTIMEO = 4102
  SO_ERROR = 4103
  SO_TYPE = 4104
  SO_SNDBUF = 4097
  SO_RCVBUF = 4098
  SO_SNDLOWAT = 4099
  TCP_NODELAY = 1
  MSG_OOB = 1
  MSG_PEEK = 2
  MSG_DONTROUTE = 4
  IP_OPTIONS = 1
  IP_DEFAULT_MULTICAST_LOOP = 1
  IP_DEFAULT_MULTICAST_TTL   = 1
  IP_MULTICAST_IF = 2
  IP_MULTICAST_TTL = 3
  IP_MULTICAST_LOOP = 4
  IP_ADD_MEMBERSHIP = 5
  IP_DROP_MEMBERSHIP = 6
  IP_TTL = 7
  IP_TOS = 8
  IP_MAX_MEMBERSHIPS = 20
  EAI_ADDRFAMILY = 1
  EAI_AGAIN = 2
  EAI_BADFLAGS = 3
  EAI_FAIL = 4
  EAI_FAMILY = 5
  EAI_MEMORY = 6
  EAI_NODATA = 7
  EAI_NONAME = 8
  EAI_SERVICE = 9
  EAI_SOCKTYPE = 10
  EAI_SYSTEM = 11
  EAI_BADHINTS = 12
  EAI_PROTOCOL = 13
  EAI_MAX = 14
  AI_PASSIVE = 1
  AI_CANONNAME = 2
  AI_NUMERICHOST = 4
  AI_MASK = 7
  AI_ALL = 256
  AI_V4MAPPED_CFG = 512
  AI_ADDRCONFIG = 1024
  AI_DEFAULT = 1536
  AI_V4MAPPED = 2048
  STR1="\x00"*8
  STR2=STR1.clone
  STR3="\x00"*4
  STR4=STR1.clone
  @@HOST={}
  def self.getaddress(host)
    gethostbyname(host)[3].unpack("C4").join(".")
  end  
  def self.getservice(serv)
    case serv
    when Numeric
      return serv
    when String
      return getservbyname(serv)
    else
      raise "Please us an interger or string for services."
    end
  end
  def self.gethostbyname(name)
    unless @@HOST[name]
      raise SocketError::ENOASSOCHOST if (ptr = Winsock.gethostbyname(name)) == 0
      host = ptr.copymem(16).unpack("iissi")
      @@HOST[name]=[host[0].copymem(64).split("\0")[0], [], host[2], host[4].copymem(4).unpack("l")[0].copymem(4)]
    end
    @@HOST[name]
  end
  def self.gethostname
    buf = "\0" * 256
    Winsock.gethostname(buf, 256)
    buf.strip
  end
  def self.getservbyname(name)
    case name
    when /echo/i
      return 7
    when /daytime/i
      return 13
    when /ftp/i
      return 21
    when /telnet/i
      return 23
    when /smtp/i
      return 25
    when /time/i
      return 37
    when /http/i
      return 80
    when /pop/i
      return 110
    else
      raise "Service not recognized."
    end
  end  
  def self.sockaddr_in(port, host)
    begin
      AF_INET.yuki_pack(STR3,0,2)
      getservice(port).rev_yuki_pack(STR3,2,2)
      STR3 + gethostbyname(host)[3] + STR4
    rescue
      0
    end
  end 
  def self.open(*args)
    socket = new(*args)
    if block_given?
      begin
          yield socket
      ensure
          socket.close
      end
    end
    nil
  end 
  def initialize(domain, type, protocol)
    SocketError.check if (@fd = Winsock.socket(domain, type, protocol)) == -1
    @fd
  end
  def accept(flags = 0)
    buf = "\0" * 16
    SocketError.check if Winsock.accept(@fd, buf, flags) == -1
    buf
  end
  def bind(sockaddr)
    SocketError.check if (ret = Winsock.bind(@fd, sockaddr, sockaddr.size)) == -1
    ret
  end
  def close
    SocketError.check if (ret = Winsock.closesocket(@fd)) == -1
    ret
  end
  def connect(sockaddr)
    SocketError.check if (ret=Winsock.connect(@fd, sockaddr, sockaddr.size)) == -1
    ret
  end
  def listen(backlog)
    SocketError.check if (ret = Winsock.listen(@fd, backlog)) == -1
    ret
  end
  def select(timeout)
    1.yuki_pack(STR1)
    @fd.yuki_pack(STR1,4)
    timeout.yuki_pack(STR2)
    (timeout*1000000).yuki_pack(STR2,4)
    SocketError.check if (ret = Winsock.select(1, STR1, 0, 0, STR2)) == -1
    ret
  end 
  def ready?
    return (select(0) != 0)
  end
  def read(len,retbuf=true)
    buf=(len.class != String ? "\0"*len : len)
    Win32API.new("msvcrt", "_read", "lpl", "l").call(@fd, buf, len)
    return (retbuf ? buf : ret)
  end  
  def recv(len,retbuf=true,flags = 0)
    buf=(len.class != String ? "\0"*len : len)
    SocketError.check if (ret=Winsock.recv(@fd, buf, buf.size, flags)) == -1
    return (retbuf ? buf[0,ret] : ret)
  end
  def send(data, flags = 0)
    SocketError.check if (ret = Winsock.send(@fd, data, data.size, flags)) == -1
    ret
  end
  alias write send
  #===
  #!>Fonction merdique à ne jamais utiliser.
  #===
  def gets
    # Create buffer
    buffer = ""
    # Loop Until "end of line"
    cm=false
    while ((char = recv(1)) != "\n" and not cm)
      if char == "\r"
        cm=true
      else
        buffer += char
      end
    end
    # Return recieved data
    return buffer
  end
end

class TCPSocket < Socket
  @@Socks=[]
  def initialize(host, port)
    super(AF_INET, SOCK_STREAM, IPPROTO_TCP)
    connect(Socket.sockaddr_in(port, host))
    @@Socks.push(self)
  end
  
  def close()
    super()
    @@Socks.delete(self)
  end
  #===
  #>Vérification de l'existance d'un serveur)
  #===
  def self.server_exist?(host)
    a=API::TCP_Ise.call(host.to_s)
    return (a==1)
  end
  
  def self.init
    s=API::CHR_NULL
    @@Socks.each do |i|
      i.write(s)
      i.close
    end
    @@Socks.clear
  end
end
Init_Contener.push(TCPSocket)

class SocketError < StandardError
  ENOASSOCHOST = "getaddrinfo: no address associated with hostname."
  def self.check
    errno = Winsock.WSAGetLastError
    errno = Errno.constants.detect { |c| Errno.const_get(c).new.errno == errno }
    if errno != nil
      $socket_error=Errno.const_get(errno)
    end
  end
end