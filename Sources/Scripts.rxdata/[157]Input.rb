#===
#¤Module Input
#---
#%Modification de la gestion d'input...
#---
#© 19/11/11 - Nuri Yuri (塗　ゆり) - Réédition
#===
class << Input
	attr_accessor :old_press, :press, :last_stat
end
module Input
	@press=API::CHR_NULL*256
	@old_press=@press.clone
	
	module_function
	def update_plus
		#Switch des variables
		v=@old_press
		@old_press=@press
		@press=v
		@last_stat=API::GKSp.call(@press)
	end
	def press_plus?(val)
		val=val.to_i
		return (@press.getbyte(val)&128 != 0)
	end
	def trigger_plus?(val)
		val=val.to_i
		bool_1=(@old_press.getbyte(val)&128 != 0)
		bool_2=(@press.getbyte(val)&128 == 0)
		return (bool_1 and bool_2)
	end
	def repeat_plus?(val)
		val=val.to_i
		return (@press.getbyte(val)==128)
	end
	def trigger_plus2?(val)
		unless press_plus?(val)
			return (@old_press.getbyte(val)&128 != 0)
		else
			return false
		end
	end
	COM={}
	COM["m_left"]=1
	COM["m_right"]=2
	COM["m_center"]=4
	COM["ret_arr"]=8 #touche <= pour effacer uen lettre
	COM["tab"]=9
	COM["enter"]=13
	COM["shift"]=16
	COM["ctrl"]=17
	COM["alt"]=18
	COM["pause"]=19
	COM["vermaj"]=20
	COM["esc"]=27
	COM["espace"]=32
	COM["pg_bas"]=33
	COM["pg_haut"]=34
	COM["fin"]=35
	COM["acceuil"]=36
	COM["gauche"]=37
	COM["haut"]=38
	COM["droite"]=39
	COM["bas"]=40
	COM["impécr"]=44
	COM["inser"]=45
	COM["suppr"]=46
	COM["à"]=48 #0
	COM["&"]=49 #1
	COM["é"]=50 #2
	COM["\""]=51 #3
	COM["'"]=52 #4
	COM["("]=53 #5
	COM["|"]=54 #6
	COM["è"]=55 #7
	COM["_"]=56 #8
	COM["ç"]=57 #9
	COM["a"]=65
	COM["b"]=66
	COM["c"]=67
	COM["d"]=68
	COM["e"]=69
	COM["f"]=70
	COM["g"]=71
	COM["h"]=72
	COM["i"]=73
	COM["j"]=74
	COM["k"]=75
	COM["l"]=76
	COM["m"]=77
	COM["n"]=78
	COM["o"]=79
	COM["p"]=80
	COM["q"]=81
	COM["r"]=82
	COM["s"]=83
	COM["t"]=84
	COM["u"]=85
	COM["v"]=86
	COM["w"]=87
	COM["x"]=88
	COM["y"]=89
	COM["z"]=90
	COM["windows"]=91
	COM["m_menu"]=93
	COM["0"]=96
	COM["1"]=97
	COM["2"]=98
	COM["3"]=99
	COM["4"]=100
	COM["5"]=101
	COM["6"]=102
	COM["7"]=103
	COM["8"]=104
	COM["9"]=105
	COM["*"]=106
	COM["+"]=107
	COM["-"]=109
	COM["."]=110
	COM["/"]=111
	COM["f1"]=112
	COM["f2"]=113
	COM["f3"]=114
	COM["f4"]=115
	COM["f5"]=116
	COM["f6"]=117
	COM["f7"]=118
	COM["f8"]=119
	COM["f9"]=120
	COM["f10"]=121
	COM["f11"]=122
	COM["f12"]=123
	COM["vernum"]=144
	COM["shift_l"]=160
	COM["shift_r"]=161
	COM["ctrl_r"]=162
	COM["ctrl_l"]=163
	COM["alt_l"]=164
	COM["alt_r"]=165
	COM["$"]=186
	COM["="]=187
	COM[","]=188
	COM[";"]=190
	COM[":"]=191
	COM["%"]=192
	COM[")"]=219
	COM["µ"]=220
	COM["^"]=221
	COM["Squared"]=222
	COM["!"]=223
	COM["<"]=226
	#COM["fn"]=225
end