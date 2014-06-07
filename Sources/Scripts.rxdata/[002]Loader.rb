#===
# Loader : Script permettant de charger les autres scripts une seul fois
# Codé par Nagato Yuki le 19/02/2012
# Intégré le 30/04/12
#===
begin
  unless $RGSS_LOADED
    $RGSS_LOADED=true
	  #Fonction de capture des strings dans le fichier ini
	  GPPS=Win32API.new("kernel32", "GetPrivateProfileString", "pppplp", "l")
	  #Vérification de la police
	  unless Font.exist?("Pokemon DS")
      print("La police Pokemon DS n'est pas installée.\nVeuillez installer la police.")
      exit(-1)
    end
	  #Chargement des scripts
    proc=Proc.new {0}
    2.step($RGSS_SCRIPTS.length-1) do |i|
      if $RGSS_SCRIPTS[i][1][0,1] != nil and $RGSS_SCRIPTS[i][1][0,1] != "#" and $RGSS_SCRIPTS[i][1][0,1] != "_"
        scrp=Zlib::Inflate.inflate($RGSS_SCRIPTS[i][2])
        eval(scrp,proc,sprintf("Section%03d",i))
      end
    end
    proc=nil
  end
  #PSP VAR...
  Font.default_name=$fontface="Pokemon DS"
  Font.default_size=$fontsize=16
  #Initialisation de tous les modules
  Init_Contener.run
  #Modification de la taille de l'écran et affichage du cadre
  $ShowCadre=API::read_ini("PSP","Cadre").to_i == 1
  if $ShowCadre
    unless Graphics.width == 282 and Graphics.height == 432
      21.times do |i|
        Graphics.resize_screen(662-i*19,512-i*4)
      end
    end
    $cadre = Sprite.new
    $cadre.bitmap = RPG::Cache.picture("Others/cadre.png")
    $cadre.z = 10000
  else
    unless Graphics.width == 256 and Graphics.height == 392
      21.times do |i|
        Graphics.resize_screen(636-i*19,472-i*4)
      end
    end
    $cadre = Sprite.new
    $cadre.bitmap = RPG::Cache.picture("Others/barre.png")
    $cadre.y = 192
    $cadre.z = 10000
  end
  #Nettoyage des scenes après RESET
  Scene_Manager.clear
  GC.start
  Graphics.freeze
  Graphics.freeze
  #Lancement de l'écran titre comme première scène.
  Scene_Manager.push(Scene_Title)
  #Execution de la méthode Main de la scène en cours si elle existe (Modèle RMXP/VX)
  Scene_Manager.run while Scene_Manager.have_scene?
  #Transition de fin si le jeu est quitté normalement.
  Graphics.transition(20)  
rescue Exception => exception
  EXC::error_handler(exception)
end
exit(0)