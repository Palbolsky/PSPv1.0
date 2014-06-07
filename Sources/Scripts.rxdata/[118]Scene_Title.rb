#==============================================================================
# ■ Scene_Title
# Pokemon Script Project v1.0 - Palbolsky
# 26/04/2012
# Conversion en module par Nagato Yuki le 26/06/2012 
#------------------------------------------------------------------------------

module Scene_Title  
  module_function  
  #===
  #>Viewports
  #===
  def viewport(x1=0,y1=0,x2=0,y2=200)
    #>Création des viewports
    @viewport_A = Viewport.new(x1, y1, 256, 192)
    @viewport_A.z = 0
    @viewport_B = Viewport.new(x2, y2, 256, 192)
    @viewport_B.z = 0
  end  
  
  #===
  #>Initialisation
  #===
  def init
    @finished=false
    unless @background
      #>Chargement du data System
      $data_system = load_data("Data/System.rxdata")
      #>Création des backgrounds
      @bg_A = Sprite.new(@viewport_A)
      @bg_A.bitmap = RPG::Cache.title("background_A.png")
      @bg_A.x = -14
      @bg_A.z = 0
      @bg_B = Sprite.new(@viewport_B)
      @bg_B.bitmap = RPG::Cache.title("background_B.png")
      @bg_B.x = -14
      @bg_B.z = 0
      #>Création du logo
      @lg = Sprite.new(@viewport_A)
      @lg.bitmap = RPG::Cache.title("logo.png")
      @lg.x = 8
      @lg.z = 1
      #>Création du message clignotant
      @mg = Sprite.new(@viewport_A)
      @mg.bitmap = RPG::Cache.title("msg.png")
      @mg.x = 57
      @mg.y = 161
      @mg.z = 1
      @mg.visible = false
      #>Création du sprite "Développé par"
      @cr = Sprite.new(@viewport_B)
      @cr.bitmap = RPG::Cache.title("credit.png")
      @cr.x = 2
      @cr.y = 181
      @cr.z = 1
      #Initialisation des autres variables
      @wait = 0
      @continue = false
      #Affichage des credits PSP
      if !$DEBUG
        @bg_A.visible=@bg_B.visible=@cr.visible=@lg.visible=false      
        sp1=Sprite.new(@viewport_A)
        sp1.bitmap=RPG::Cache.title("Pokemon SP1.png")      
        sp2=Sprite.new(@viewport_B)
        sp2.bitmap=RPG::Cache.title("Pokemon SP2.png")
        Graphics.transition(20)
        Graphics.wait(60)
        Graphics.freeze
        sp1.dispose
        sp2.dispose
        sp1=sp2=nil
        Graphics.transition(20)      
        Graphics.freeze              
        @bg_A.visible=@bg_B.visible=@cr.visible=@lg.visible=true         
      end
      #>Chargement de la musique
      bgm=$data_system.title_bgm
      Audio.bgm_play("Audio/BGM/#{bgm.name}", bgm.volume, bgm.pitch) if bgm.name.size>0
      Graphics.transition      
    end
  end
  #===
  #>Lancement de la scene
  #===
  def run
    init    
    #>Boucle de mise à jour principale
    while Scene_Manager.me?(self)
      Graphics.update
      Input.update
      update
    end
    Graphics.freeze
    finish
    GC.start
  end
  
  #===
  #>Mise à jour
  #===
  def update
    #Mise à jour de la variable Wait
    @wait >= 60 ? @wait = 0 : @wait += 1
    # Animation
    @bg_A.x >= 0 ? @bg_A.x = -14 : @bg_A.x += 1
    @bg_B.x >= 0 ? @bg_B.x = -14 : @bg_B.x += 1
    # Mise à jour du message.
    if @wait == 30
      @mg.visible = true
      @continue = true
    elsif @wait == 0
      @mg.visible = false
    end
    # Fin de l'écran titre.
    if (Input.trigger?(Input::C) or
      (Input.trigger_plus2?(1) and Mouse.is_here?(0,200,256,192))) and 
      @continue
      Audio.bgm_fade(800)
      Scene_Manager.push(Pokemon_Load)      
    end
  end

  #===
  #>Fin de la scene et nettoyage
  #===
  def finish
    return if @finished
    @viewport_A.dispose
    @viewport_B.dispose
    @bg_A.dispose
    @bg_B.dispose
    @lg.dispose
    @mg.dispose
    @cr.dispose
    @viewport_A=nil
    @viewport_B=nil
    @bg_A=nil
    @bg_B=nil
    @lg=nil
    @mg=nil
    @cr=nil    
    Graphics.transition
    Graphics.wait(20)
    @finished=true
  end
  
  def finished?
    @finished
  end
end