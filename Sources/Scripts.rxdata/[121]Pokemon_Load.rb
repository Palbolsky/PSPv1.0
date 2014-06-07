#==============================================================================
# ■ Pokemon_Load
# Pokemon Script Project v1.0 - Palbolsky
# 27/04/2012
# Conversion en module par Nagato Yuki le 26/06/2012 
#------------------------------------------------------------------------------

module Pokemon_Load
  SaveFile="Save.rxdata"
  TEXTS=["CONTINUER","NOUVELLE PARTIE","CADEAU MYSTÈRE","CONFIGURATION DU RÉSEAU","OPTIONS"]
  module_function
  def viewport(x1=0,y1=0,x2=0,y2=200)
    #>Création des viewports
    @viewport_A = Viewport.new(x1, y1, 256, 192)
    @viewport_A.z = 100
    @viewport_B = Viewport.new(x2, y2, 256, 192)
    @viewport_B.z = 100
    @viewport=Viewport.new(x1+32,y1,192,192)
    @viewport.z=101
  end
  def init
    @finished=false    
    #>Chargement des datas
    $data_actors        = load_data("Data/Actors.rxdata")
    $data_classes       = load_data("Data/Classes.rxdata")
    $data_skills        = load_data("Data/Skills.rxdata")
    $data_items         = load_data("Data/Items.rxdata")
    $data_weapons       = load_data("Data/Weapons.rxdata")
    $data_armors        = load_data("Data/Armors.rxdata")
    $data_enemies       = load_data("Data/Enemies.rxdata")
    $data_troops        = load_data("Data/Troops.rxdata")
    $data_states        = load_data("Data/States.rxdata")
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")     
    $game_system = Game_System.new
    #>Pour tester, de toute façon ça ne marchera pas si le projet est compilé
    if File.exist?("Data/Library")
      file = File.new("Data/Library", "rb") 
      $femelle_exist = Marshal.load(file)
      file.close 
    end   
    #>Initialisation des sprites
    @background_A = Sprite.new(@viewport_A)
    @background_A.bitmap = RPG::Cache.pokemon_load("background_A.png")    
    @background_B = Sprite.new(@viewport_B)
    @background_B.bitmap = RPG::Cache.pokemon_load("background_B.png")
    @background_A.z = @background_B.z = 0
    @Stxt=Sprite.new(@viewport)
    @Stxt.bitmap=Bitmap.new(192,256)
    @Stxt.z=1
    @Choixs=Array.new
    @Methods=Array.new
    @b1=RPG::Cache.pokemon_load("B1")
    @b2=RPG::Cache.pokemon_load("B2")
    if File.exist?(SaveFile)
      @Htxt=Sprite.new(@viewport_B)
      @Htxt.bitmap=Bitmap.new(210,100)
      @Htxt.x=24
      @Htxt.y=18
      @Htxt.z=3
      @Hfond=Sprite.new(@viewport_B)
      @Hfond.x=24
      @Hfond.y=18
      @Hfond.bitmap=RPG::Cache.pokemon_load("B3")
      @Hfond.z=2
      @Methods.push(method(:continuer))
      sp=Sprite.new(@viewport)
      sp.bitmap=@b1
      sp.y=16+@Choixs.size*24
      sp.z=0
      @Stxt.bitmap.draw_text_plus(9,sp.y,184,24,TEXTS[0],0,9)
      @Choixs.push(sp)
      file = File.new(SaveFile, "rb") 
      $pokemon_party = Marshal.load(file)
      file.close        
      temp = $pokemon_party.get_game_time.to_i
      temp-=(temp%60)
      temp/=60
      @min=temp%60
      @heure=temp/60
      @heure=999 if @heure>999
      @chara=Sprite.new(@viewport_B)
      @chara.bitmap=RPG::Cache.character(sprintf("%03d", $pokemon_party.player_sexe)+".png", 0)
      @chara.src_rect.set(0,0,@chara.bitmap.width/4,@chara.bitmap.height/4) 
      @chara.x=44
      @chara.y=41
      @chara.z=3
      @txt=Sprite.new(@viewport_B)
      @txt.bitmap=Bitmap.new(256, 192)
      @txt.z=3
      @txt.bitmap.draw_text_plus(11,22,200,16,"INFORMATIONS DE LA SAUVEGARDE",2,9) #En attente de traduction
      @txt.bitmap.draw_text_plus(81,41,80,16,$pokemon_party.trainer_name,0,$pokemon_party.player_sexe+1)
      @txt.bitmap.draw_text_plus(81,59,80,16,"Zone Mystère",0,9) #Lieu
      @txt.bitmap.draw_text_plus(41,82,80,16,"BADGES : #{$pokemon_party.number_badge}",0,9)
      @txt.bitmap.draw_text_plus(121,82,80,16,"POKÉDEX : #{$pokemon_party.seen.count(true)}",0,9)
      @txt.bitmap.draw_text_plus(41,98,150,16,sprintf("DURÉE DE JEU : %02d:%02d",@heure,@min),0,9)
    end
    @Methods.push(method(:nouvelle_partie))
    sp=Sprite.new(@viewport)
    sp.bitmap=@b1
    sp.y=16+@Choixs.size*24
    sp.z=0
    @Stxt.bitmap.draw_text_plus(9,sp.y,184,24,TEXTS[1],0,9)
    @Choixs.push(sp)
    if @Htxt
      @Methods.push(method(:cadeau_mystere))
      sp=Sprite.new(@viewport)
      sp.bitmap=@b1
      sp.y=16+@Choixs.size*24
      sp.z=0
      @Stxt.bitmap.draw_text_plus(9,sp.y,184,24,TEXTS[2],0,9)
      @Choixs.push(sp)
    end
    @Methods.push(method(:options))
    sp=Sprite.new(@viewport)
    sp.bitmap=@b1
    sp.y=16+@Choixs.size*24
    sp.z=0
    @Stxt.bitmap.draw_text_plus(9,sp.y,184,24,TEXTS[4],0,9)
    @Choixs.push(sp)
    @Methods.push(method(:reseau))
    sp=Sprite.new(@viewport)
    sp.bitmap=@b1
    sp.y=16+@Choixs.size*24
    sp.z=0
    @Stxt.bitmap.draw_text_plus(9,sp.y,184,24,TEXTS[3],0,9)
    @Choixs.push(sp)
    #>Initialisation des autres variables    
    @index = 0
  end  
  
  def run
    init
    @Choixs[0].bitmap=@b2
    Graphics.transition
    while Scene_Manager.me?(self)
      Graphics.update
      Input.update
      update
    end
    Graphics.freeze
    finish
    GC.start
  end
  
  def update
    if Input.trigger?(Input::B)
      Scene_Manager.pop     
      $game_system.se_play($data_system.cancel_se)          
      return finish      
    end
    
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      return @Methods[@index].call()
    end
    
    if Input.repeat?(Input::UP)
      @Choixs[@index].bitmap=@b1
      if @index>0
        @index-=1
        $game_system.se_play($data_system.cursor_se)
      end
      @Choixs[@index].bitmap=@b2
    elsif Input.repeat?(Input::DOWN)
      @Choixs[@index].bitmap=@b1
      if @index < (@Methods.size-1)
        @index+=1
        $game_system.se_play($data_system.cursor_se)
      end
      @Choixs[@index].bitmap=@b2
    end
    
  end
  
  def continuer
    $pokemon_party.create_globals
    $game_map.setup($game_map.map_id)
    $game_player.center($game_player.x, $game_player.y)    
    $game_party.refresh
    $game_map.autoplay
    $game_map.update
    Scene_Manager.clear
    Scene_Manager.push(Scene_Map)
  end
  
  def nouvelle_partie
    Graphics.frame_count = 0
    $pokemon_party = Pokemon_S::Pokemon_Party.new if (b = File.exist?(SaveFile) or !$pokemon_party or (!b and $pokemon_party))
    $pokemon_party.create_globals    
    $game_party.setup_starting_members
    $game_map.setup($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $game_map.autoplay
    $game_map.update
    Scene_Manager.clear
    Scene_Manager.push(Scene_Map)
  end
  
  def cadeau_mystere
    print("Le Cadeau Mystère n'est pas disponible.")
  end  
  
  def reseau
    print("Les paramètres du réseau ne sont pas disponibles.")
  end
  
  def options    
    Scene_Manager.push(Pokemon_Options)
    Pokemon_Options.run
    Graphics.transition if Pokemon_Options::transition?
  end
  
  def finish
    return if @finished
    @background_A.dispose
    @background_A=nil
    @background_B.dispose
    @background_B=nil
    @Stxt.bitmap.dispose
    @Stxt.dispose
    @Stxt=nil
    @Choixs.each do |i| i.dispose end
    @Choixs=nil
    @Methods=nil
    if @Hfond
      @Hfond.dispose
      @Hfond=nil
      @Htxt.bitmap.dispose
      @Htxt.dispose
      @Htxt=nil
      @chara.dispose
      @chara=nil
      @txt.dispose
      @txt=nil
    end
    @viewport_A.dispose
    @viewport_B.dispose
    @viewport.dispose    
    Graphics.wait(20)
    @finished=true
  end
  
  def finished?
    @finished
  end
end