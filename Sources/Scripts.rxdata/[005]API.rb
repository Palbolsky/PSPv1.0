#===
#¤Module API
#---
#%Contient toute les constantes D'apis que les script
#%pourraient appeler.
#---
#© 14/05/2011 - Nuri Yuri (塗 ゆり)
#& 28/05/2011 - Nuri Yuri (塗 ゆり) : Ajout de WPPS
#===
module API
	begin
		#===
		#Initialisation des nom de DLL
		#===
		User32="user32"
		Kernel32="kernel32"
		$HWND=0
		#===
		#Initialisation des constante
		#%Déclarez toute vos API ICI !
		#===
		
		#Get Systeme Metrics
		GSM=Win32API.new(User32, "GetSystemMetrics", "i", "i")
		#Cusor Pos
		CP=Win32API.new(User32, "GetCursorPos", "p", "i")
		#SCP
		SCP=Win32API.new(User32, "SetCursorPos", "ii" ,"i") #x  y
		#Screen To Client
		STC=Win32API.new(User32, "ScreenToClient", "lp", "i")
		#Get Client Rect
		GCR=Win32API.new(User32, "GetClientRect", "lp", "i")
		#Read Ini | alias Get Private Profile String
		GPPS=Win32API.new(Kernel32, "GetPrivateProfileString", "pppplp", "l")
		#Write Ini
		WPPS=Win32API.new(Kernel32, "WritePrivateProfileString", "pppp","l")
		#Find Window
		FW=Win32API.new(User32, "FindWindowA", "pp", "l")
		#Capture d'une touche trigger
		GAKS=Win32API.new(User32,"GetAsyncKeyState",'i','i')
		#Capture d'une touche press
		GKS=Win32API.new(User32,"GetKeyState",'i','i')
		GKSp=Win32API.new(User32,"GetKeyboardState",'p','i')
		#Set Windows Pos
		SWP=Win32API.new(User32, "SetWindowPos", "lliiiii", "i")
		#Get Windows Rect
		GWR=Win32API.new(User32,'GetWindowRect',"lp",'i')
		#Set Windows Long
		SWL=Win32API.new(User32,"SetWindowLong","lii","i")
		#ShowCursor
		ShCur = Win32API.new(User32, "ShowCursor", 'l', 'l')
		#Keybd_event
		KBE=Win32API.new(User32,"keybd_event","iiii","i")
		#GetWindowPlacement
		GetWindowPlacement=Win32API.new(User32,"GetWindowPlacement","pp","i")
		#SetWindowPlacement
		SetWindowPlacement=Win32API.new(User32,"SetWindowPlacement","pp","i")
		#MultiByteToWideChar
		MultiByteToWideChar=Win32API.new(Kernel32,"MultiByteToWideChar","LLPLPL","L")
		#WideCharToMultiByte
		WideCharToMultiByte=Win32API.new(Kernel32,"WideCharToMultiByte","LLPLPLPI","L")
    yuki="YukiAPI"
		WS_Ini=Win32API.new(yuki,"InitWinsock","","i")
    WS_Cln=Win32API.new(yuki,"CleanWinsock","","")
    TCP_Ise=Win32API.new(yuki,"IsServerExist","p","i")
	rescue
		print("Erreur dans le script API :\n",$!.message,"\nIl se peut que ce soit un problème de chargement d'une API")
		exit(-1)
	end  
	#===
	#Initialisation des constantes destinées aux Méthodes
	#===
	RECT_ARR=[0,0,0,0]
	SECTION_GAME="Game"
	VARIABLE_TITLE="Title"
	EXE_DESC="RGSS Player"
	CHR_NULL="\x00"
	CHR_EMPTY=""
	FILE_INI="Game.ini"
	FILE_INI_GPPS=".//#{FILE_INI}"
	CHARx_LL="ll"
	CHARx_L4="l4"
	#===
	#Methodes
	#===
	module_function
	def handle
		if $HWND==0
			titlev=title()
			return $HWND=FW.call(EXE_DESC,titlev)
		else
			return $HWND
		end
	end
	def title
		GPPS.call(SECTION_GAME,VARIABLE_TITLE,CHR_EMPTY,title=CHR_NULL*256,256,FILE_INI_GPPS)
		return title.delete!(CHR_NULL)
	end
	def read_ini(cat,var,file=FILE_INI,length=256)
		GPPS.call(cat.to_s,var.to_s,CHR_EMPTY,data=CHR_NULL*length,length,".//#{file}")
		return data.delete!(CHR_NULL)
	end
	def write_ini(cat,var,value,file=FILE_INI)
		return WPPS.call(cat.to_s,var.to_s,value.to_s,".//#{file}")
	end
	#Screen To Client
	def screen_to_client(x, y)
		pos = [x.to_i, y.to_i].pack(CHARx_LL)
		STC.call(handle, pos)
		return pos.unpack(CHARx_LL)
	end
	#Client size
	def client_size    
		rect = RECT_ARR.pack(CHARx_L4)
		GCR.call(handle, rect)
		right, bottom = rect.unpack(CHARx_L4)[2,2]
		return right, bottom
	end
	#Win rect
	def window_rect   
		rect = RECT_ARR.pack(CHARx_L4)
		GWR.call(handle, rect)
		rect.unpack(CHARx_L4)
	end
end