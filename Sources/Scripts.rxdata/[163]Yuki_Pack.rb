#====
# Yuki::Pack v1
# Classe de création et lecture de pack de fichiers
#====
# Structure
# Header: char[] file_identifier,byte Addr_sizes,int File_count,void[] Addr_Array
# Content: File[] Files
# File: int size, char[] file_content
#===
module Yuki
  class Pack
    #>Constantes
    CLASS_VERSION='1.0.0.2'
    Mode_R=:r
    Mode_W=:w
    Mode_Read=:read
    Mode_Write=:write
    Mode_Create=:create
    Error_Mode="Erreur le mode spécifié doit être l'un de ces symboles : #{Mode_R},#{Mode_W},#{Mode_Read},#{Mode_Write},#{Mode_Create}."
    Error_PackFile='Erreur, le fichier ne semble pas être un pack...'
    Error_AddrSize='Erreur, la taille d\'adresse doit faire de 1 à 4 octets.'
    Error_PackObject='Erreur, le pack doit être du type Yuki::Pack ou String.'
    Error_CreateFile='Erreur, vous créez le fichier, vous devez donc savoir quelle est la taille du fichier...'
    Error_ReadFile='Erreur, vous lisez un pack, vous ne pouvez pas écrire par dessus.'
    Error_FileUnex='Erreur, le fichier n\'existe pas dans ce pack.'
    Error_Closed='Erreur, pack fermé.'
    File_Identifier='YPCK'
    #===
    #>Initialisation
    #---
    # filename : Nom de fichier si lecture de fichier, index si lecture dans un pack
    # mode : mode du pack, si on le lit ou on le créé
    # inside : si le pack se trouve dans un pack ou un string
    # pack : le pack/string concernée par inside
    #===
    def initialize(filename,mode,inside=false,pack=nil)
      @filename=filename
      @mode=mode
      @inside=inside
      @pack=pack
      @addr=nil
      @addr_size=0
      @file_count=0
      case mode
      when Mode_W,Mode_Write,Mode_Create
        initialize_create
      when Mode_R,Mode_Read
        initialize_read
      else
        raise Error_Mode
      end
    end
    
    #===
    #%Les méthodes qui suivent sont privées
    #===
    private
    #===
    #>Initialisation en création
    #===
    def initialize_create()
      @create=[]
    end
    
    #===
    #>Initialisation en lecture
    #===
    def initialize_read()
      @create=nil
      #Si c'est un fichier
      unless @inside
        @File=File.new(@filename,'rb') #Si le fichier n'existe pas ruby se chargera de stopper toute opérations
        
        #Vérification du fichier, il doit faire minimum 4 octets et contenir l'identifiant d'un Yuki_Pack
        if(@File.size>4 and @File.read(4)==File_Identifier)
          #Lecture de la taille d'une adresse
          @addr_size=@File.read(1).getbyte(0)
          #Vérification de celle-ci
          unless(@addr_size>0 and @addr_size<5)
            raise Error_AddrSize
          end
          
          #Lecture du nombre de fichier
          @file_count=get_int(@File.read(4),0,4)
          
          #Capture des addresses
          @addr=Array.new(@file_count)
          addr_str=@File.read(@file_count*@addr_size)
          @file_count.times do |i|
            @addr[i]=get_int(addr_str,i*@addr_size,@addr_size)
          end
          
        #Si le fichier ne semble pas être un Yuki_Pack => Erreur.
        else
          raise Error_PackFile
        end
        
      #Si c'est un pack interne
      else
        if(@pack.class==Yuki::Pack)
          @pack=str=@pack.get_file(@filename)
          initialize_string(str)
        elsif(@pack.class==String)
          initialize_string(@pack)
        else
          raise Error_PackObject
        end
      end
    end
    
    #===
    #>Initialize string
    #===
    def initialize_string(str)
      if(str.size>4 and str[0,4]==File_Identifier)
        @addr_size=str.getbyte(4)
        unless(@addr_size>0 and @addr_size<5)
          raise Error_AddrSize
        end
        @file_count=get_int(str,5,4)
        @addr=Array.new(@file_count)
        @file_count.times do |i|
          @addr[i]=get_int(str,9+i*@addr_size,@addr_size)
        end
      else
        raise Error_PackFile
      end
    end
    
    #===
    #%Les méthodes qui suivent sont publiques
    #===
    public
    #===
    #>Optention de la taille d'un fichier
    #===
    def get_filesize(file_id)
      unless @create
        raise Error_Closed if @closed
        addr=@addr[file_id]
        if(addr)
          unless @inside
            @File.pos=addr
            return get_int(@File.read(4),0,4)
          else
            return get_int(@pack,addr,4)
          end
        else
          raise Error_FileUnex
        end
      else
        print(Error_CreateFile)
        return @create[file_id].size if @create[file_id]
      end
      return 0
    end
    
    #===
    #>Optention du fichier
    #===
    def get_file(file_id)
      unless @create
        size=get_filesize(file_id)
        unless @inside
          @File.pos=@addr[file_id]+4
          return @File.read(size)
        else
          return @pack[@addr[file_id]+4,size]
        end
      else
        return @create[file_id]
      end
      return nil
    end
    
    #===
    #>Création d'un fichier
    #===
    def set_file(file_id,str)
      if @create
        @create[file_id]=str
      else
        raise Error_ReadFile
      end
      return nil
    end
    
    #===
    #>Pack
    #===
    def pack()
      if @create
        #===
        #>Empactage des fichiers
        #===
        addr=Array.new(@create.size)
        str=String.new
        strsize="\x00\x00\x00\x00"
        @create.each_index do |i|
          obj=@create[i]
          addr[i]=str.size+9 #Position actuelle dans le string + taille du header static, il faudra recalculer toute les addresses.
          if obj.class==String
            set_int(strsize,0,4,obj.size)
            str<<strsize
            str<<obj
          else
            set_int(strsize,0,4,0)
            str<<strsize
            print("Erreur, l'objet '#{i}' du pack n'est pas de la classe String.")
          end
        end
        file_count=@create.size
        #===
        #Calcule des addresses et de la taille de celle ci
        #===
        if(str.size<(0xfff6-file_count*2))
          addr_size=2
        elsif(str.size<(0xfffff6-file_count*3))
          addr_size=3
        elsif(str.size<(0xfffffff6-file_count*4))
          addr_size=4
        else
          raise "Erreur, le pack peut avoir des addresses de maximum 4 octets, il est impossible d'utiliser des addresses plus grandes.\n#{str.size.size}"
        end
        str_addr="\x00"*(file_count*addr_size)
        str_addr_size=str_addr.size
        addr.each_index do |i|
          set_int(str_addr,i*addr_size,addr_size,addr[i]+str_addr_size)
        end
        #===
        #Création du fichier
        #===
        set_int(strsize,0,4,file_count)
        unless @inside
          f=File.new(@filename,'wb')
          #écriture de l'header
          f.write(File_Identifier)
          f.write(addr_size.chr)
          f.write(strsize)
          f.write(str_addr)
          f.write(str)
          f.close
        else
          str2=String.new
          str2<<File_Identifier
          str2<<addr_size.chr
          str2<<strsize
          str2<<str_addr
          str2<<str
          return str2
        end
      else
        raise Error_ReadFile
      end
      return nil
    end
    
    def close()
      return if @create
      @File.close
      @closed=true
    end
    #===
    #>Get_Int
    #===
    def get_int(string,start,size)
      int=0
      (size-1).times do |i|
        int|=string.getbyte(start+i)
        int<<=8
      end
      int|=string.getbyte(start+size-1)
    end
    
    #===
    #>Set_Int MSB - - - LSB
    #===
    def set_int(string,start,size,int)
      start+=(size-1)
      (size).times do |i|
        string.setbyte(start-i,int&0xff)
        int>>=8
      end
    end
  end
end