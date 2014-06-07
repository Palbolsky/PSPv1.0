#===
#¤Module Constant
#---
#%Contient toute les constantes
#---
#© 22/05/2011 - Nuri Yuri (塗 ゆり)
#===
module Constant
  #Couleurs des textes
  Color_int=Array.new(15)
  Color_ext=Array.new(15)
  Color_int[0]=Color.new(90, 90, 82)     #Gris foncé
  #Color_int[1]=Color.new(110, 110, 255) #Bleu
  Color_int[1]=Color.new(57, 165, 255)
  #Color_int[2]=Color.new(255, 110, 110) #Rouge
  Color_int[2]=Color.new(247, 74, 90)
  #Color_int[3]=Color.new(110, 200, 110) #Vert
  Color_int[3]=Color.new(32, 189, 4)
  Color_int[4]=Color.new(110, 255, 255) #Bleu Clair
  Color_int[5]=Color.new(255, 110, 255) #Rose
  Color_int[6]=Color.new(255, 255, 110) #Jaune
  Color_int[7]=Color.new(110, 110, 110) #Gris
  Color_int[8]=Color.new(255, 255, 255) #Blanc
  Color_int[9]=Color.new(239, 239, 239) #Pkdx inversé
  Color_int[10]=Color.new(90, 90, 90)   #Pkdx normal
  Color_int[11]=Color.new(41, 82, 57)   #Cdd
  Color_int[12]=Color.new(0, 0, 216) #Bleu Pokemon_Status
  Color_int[13]=Color.new(198, 0, 0) #Rouge Pokemon_Status
  Color_int[14]=Color.new(99, 255, 148) #Options
  Color_int[15]=Color.new(41, 41, 41) #Panneau
  Color_int[16]=Color.new(214,255,123) #Texte curseur Pokédex
  Color_int[17]=Color.new(255,255,255) #Description objet sac garçon (bleu)
  Color_int[18]=Color.new(255,255,255) #Desccription objet sac fille (rose)
  
  Color_ext[0]=Color.new(165, 165, 173)
  #Color_ext[1]=Color.new(160, 160, 255)
  Color_ext[1]=Color.new(57, 107, 173)
  #Color_ext[2]=Color.new(255, 60, 60)
  Color_ext[2]=Color.new(165, 66, 66)
  #Color_ext[3]=Color.new(60, 200, 60)
  Color_ext[3]=Color.new(62, 229, 44)
  Color_ext[4]=Color.new(60, 255, 60)
  Color_ext[5]=Color.new(255, 60, 255)
  Color_ext[6]=Color.new(255, 255, 60)
  Color_ext[7]=Color.new(60, 60, 60)
  Color_ext[8]=Color.new(132, 132, 132)
  Color_ext[9]=Color.new(140, 140, 140)
  Color_ext[10]=Color.new(214, 222, 222)
  Color_ext[11]=Color.new(90, 137, 107)
  Color_ext[12]=Color.new(115, 148, 255) #Bleu Pokemon_Status
  Color_ext[13]=Color.new(255, 115, 115) #Rouge Pokemon_Status
  Color_ext[14]=Color.new(33, 148, 140) #Options
  Color_ext[15]=Color.new(107, 132, 148) #Panneau
  Color_ext[16]=Color.new(107,173,57) #Texte curseur Pokédex
  Color_ext[17]=Color.new(123,148,173) #Description objet sac garçon (bleu)
  Color_ext[18]=Color.new(231,123,148) #Desccription objet sac fille (rose)
  
  #Fenêtres
  Window1=[5,4,5,5,4,5]  # => [width_droite,w_centre,w_gauche,h_haut,h_centre,h_bas]
  Window2=[4,15,4,8,16,4]
  Window3=[15,4,15,11,2,11]
  Message1=[14,8,22,8,6,8]
  Bouton1=[7,6,7,7,3,11]
  
  F_1s2=0.5
end