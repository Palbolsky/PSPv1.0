#===
#¤Class Bitmap
#% Ajout des méthodes de chargement et sauvegarde.
#---
#© 18/02/2012 - Nagato Yuki
#===
class Bitmap
	S_W2="w2"
	YLoad=Win32API.new("YukiAPI","YukiBitmapLoad","ippii","")
	#===
	# Load : Charge un Bitmap depuis un fichier 
	# Ayant une palette et le bitmap, mettez un string
	# dans pal pour utiliser une autre pallette.
	#===
	def self.load(obj,pal=nil)
		obj=Zlib::Inflate.inflate(obj)
		str=obj[0,obj.getbyte(-1)]
		w,h=str.unpack(S_W2)
		bmp=Bitmap.new(w,h)
		unless pal
			pal=obj[obj.getbyte(-1),64]
		end
		p1=obj.getbyte(-1)+64
		l1=obj.size-p1-1
		ol=obj[p1,l1]
		YLoad.call(bmp.object_id,pal,ol,pal.size,ol.size)
		return bmp
	end
end