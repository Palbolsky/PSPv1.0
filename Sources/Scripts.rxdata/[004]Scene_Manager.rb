#===
# Scene_Manager
#---
# Ecrit par Nagato Yuki le  26/06/2012
#===
module Scene_Manager
  #====
  #Variables d'instance
  #===
  @scene=nil
  @stack=Array.new  
  #===
  #Fonctions
  #===
  module_function  
  #===
  #Ajout d'une scene
  #===
  def push(scene)    
    @stack.push(scene)
    @scene=scene    
    viewport
  end
  #===
  #Fin de la dernière scene
  #===
  def pop(i=1)
    i.times do @stack.pop end    
    @scene=@stack[-1]    
  end
  #===
  #Vidage du Stack
  #===
  def clear()
    @stack.each do |i|
      i.finish unless i.finished?
    end
    @scene=nil
    @stack.clear
  end
  
  #===
  #Vidage du Stack et accès à Scene_Map
  #===  
  def map()
    clear
    @stack.push(Scene_Map)
    @scene = Scene_Map
    @scene.init
    viewport
  end

  #===
  #Vérifier le contenu du stack
  #===
  def stack()
    @stack
  end
  #===
  #Scene en cours
  #===
  def me?(scene)
    @scene==scene
  end
  #===
  #Lancement de la scene en cours
  #===
  def run
    @scene.run
  end
  #===
  #Si il y a une scene
  #===
  def have_scene?
    @scene != nil
  end
  
  #===
  #Chargement des viewports
  #===
  def viewport
    posc = Pokemon_S::POS_CADRE  
    if $ShowCadre
      @scene.viewport(posc[0],posc[1],posc[2],posc[3]) 
    else
      @scene.viewport
    end
  end  
  
  #===
  #>Inspection de l'objet
  #===
  def inspect
    return "#<Scene_Manager:0x#{sprintf("%08X",self.object_id*2)} @scene=#{@scene} @stack=#{@stack.inspect}>"
  end
end
=begin
Les scene devront s'executer les unes après les autres en ajoutant la suivant dans le stack
Scene_Manager.push(Scene_Nouvelle)
Biensur la nouvelle scene doit être exécutée 
  soit par Scene_Manager.push(Scene_Nouvelle).run
  soit par Scene_Nouvelle.run après le push

Lorsqu'une scene a fini son travail elle ne doit surtout pas appeler la scene qui la appeler
elle doit arrêter son fonctionnement de la manière suivant :
  Scene_Manager.pop
puis vérifier si elle est toujours en cours de la manière suivant dans la branche update :
  break if !Scene_Manager.me?(self)
=end