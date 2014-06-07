#===
# Integer
#---
# Ecrit par Nagato Yuki
#===
class Integer
  def yuki_pack(str,inipos=0,cnts=4)
    int=self
    cnts.times do |i|
      str.setbyte(i+inipos,int%256)
      int/=256
    end
    return str
  end
	def rev_yuki_pack(str,inipos=0,cnts=4)
    int=self
		(cnts-1).step(0,-1) do |i|
			str.setbyte(i+inipos,int%256)
      int/=256
		end
		return str
	end
end