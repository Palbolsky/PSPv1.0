#===
#¤Classe String
#---
#%Ajout de methodes
#---
#© 27/07/2011 - Nuri Yuri (塗 ゆり)
#© 08/12/2011 - - Ajout de string builder
#===
class String
  S_Esp=" "
	Ver=RUBY_VERSION.delete(".").to_i
	if Ver < 190
		def setbyte(i,j)
			self[i]=j
		end
		def getbyte(i)
			return self[i]
		end
	end
  def new_clear(val=0)
    val=val.to_i%256
    self.size.times { |i|
      self.setbyte(i,val)
    }
    self
  end
  def to_utf16
    to_format
  end
  def to_format(format=65001,mul=2,add=0)
    sizen=self.size*mul+2
    strn=0.chr*sizen
    len=API::MultiByteToWideChar.call(format,add,self,self.size,strn,sizen)
    return strn[0,len*mul+2]
  end
  def conv
    self.force_encoding(Encoding.default_external)
  end
  def to_pokemon_numbers()
    self.gsub!("0","│") if self.include?("0")
    self.gsub!("1","┤") if self.include?("1")
    self.gsub!("2","╡") if self.include?("2")
    self.gsub!("3","╢") if self.include?("3")
    self.gsub!("4","╖") if self.include?("4")
    self.gsub!("5","╕") if self.include?("5")
    self.gsub!("6","╣") if self.include?("6")
    self.gsub!("7","║") if self.include?("7")
    self.gsub!("8","╗") if self.include?("8")
    self.gsub!("9","╝") if self.include?("9")
    self.gsub!("n","‰") if self.include?("n")
    self.gsub!(".","Š") if self.include?(".")
    self.gsub!("/","▓") if self.include?("/")
    return self
  end
end