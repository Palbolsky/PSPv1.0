#==============================================================================
# ■ Pokedex_List
# Pokemon Script Project v1.0 - Palbolsky
# 30/11/2012
#------------------------------------------------------------------------------

module Pokedex_List
  module_function
  def viewport(x1=0,y1=0,x2=0,y2=200)
    @viewport_A = Viewport.new(x1,y1,256,192)
    @viewport_A.z = 1004
    @viewport_B = Viewport.new(x2,y2,256,192)
    @viewport_B.z = 1004
  end
  
  def init    
    $pokedex = Pokemon_S::Pokedex.new
    @finished = false
    @transition = true
    @index_list = $pokedex.index_list
    @index_cursor = 0  
    @national = true
    @id = 1
    @wait = 0    
    @background_A = Sprite.new(@viewport_A)
    @background_A.bitmap = RPG::Cache.pokemon_pokedex("background_A.png")
    @background_A.z = 0
    @background_B = Sprite.new(@viewport_B)
    @background_B.bitmap = RPG::Cache.pokemon_pokedex("background_B.png")
    @background_B.z = 0
    @interface = Sprite.new(@viewport_A)
    @interface.bitmap = RPG::Cache.pokemon_pokedex("interface.png")
    @interface.z = 1
    @barre = Sprite.new(@viewport_B)
    @barre.bitmap = RPG::Cache.pokemon_pokedex("barre.png")
    @barre.y = 168
    @barre.z = 1    
    @sprc = Sprite.new(@viewport_B)
    @sprc.bitmap = RPG::Cache.pokemon_pokedex("sprc.png")
    @sprc.x = 3
    @sprc.z = 1
    @front = Sprite.new(@viewport_B)    
    @front.z = 1
    @front.mirror = true
    #> Détermination de la fin de la liste
    @end_list = -1    
    649.step(0,-1) do |i|
      break if @end_list != -1
      @end_list = i+1 if $pokemon_party.seen?(i+1)          
    end
    $pokedex.end_list = @end_list
    @img_list = RPG::Cache.pokemon_pokedex("list.png") 
    #> Création de la liste
    #>> Création de la partie supérieur de la liste
    @list_A = Array.new
    6.times do |i|
      @list_A[i] = Sprite.new(@viewport_A)
      @list_A[i].bitmap = Bitmap.new(151, 22)
      @list_A[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 0, 151, 21)) 
      @list_A[i].x = 96
      @list_A[i].y = 49+i*24
      @list_A[i].z = 2 
      @list_A[i].opacity = 30+32*(i+1)
      @list_A[i].visible = false
    end    
    #>> Création de la partie inférieur de la liste        
    @list_B = Array.new
    7.times do |i|
      @list_B[i] = Sprite.new(@viewport_B)
      @list_B[i].bitmap = Bitmap.new(151, 22)
      @list_B[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 0, 151, 21)) 
      @list_B[i].x = 96
      @list_B[i].y = 1+i*24
      @list_B[i].z = 2
      @list_B[i].visible = false
      next if i > @end_list
      @list_B[i].visible = true     
    end   
    #> Création du curseur
    @img_list_cursor = RPG::Cache.pokemon_pokedex("list_curseur.png")
    @sprite_cursor = Array.new
    7.times do |i|
      @sprite_cursor[i] = Sprite.new(@viewport_B)
      @sprite_cursor[i].bitmap = Bitmap.new(151, 21)
      @sprite_cursor[i].x = 96
      @sprite_cursor[i].y = 1+i*24
      @sprite_cursor[i].z = 3
      @sprite_cursor[i].visible = false
    end
    @text = Sprite.new(@viewport_A)
    @text.bitmap = Bitmap.new(256, 192)
    @text.z = 2    
    draw_text
    draw_list
    draw_list_text
    draw_all
  end
  
  def run  
    init
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
    animation
    if Input.trigger_plus2?(1) # Recherche
      if Mouse.is_here?(3, 370, 66, 20)
        print("Mode recherche non disponible.")
      end
      if Mouse.is_here?(73, 370, 66, 20) # Mode régional/national
        #@national ? @national = false : @national = true
        #draw_text
        print("Mode régional non disponible.")
      end   
      if Mouse.is_here?(139, 373, 17, 14) # Flèche gauche
        @index_list -= 6
        @index_list = 0 if @index_list < 0
        draw_list
        draw_list_text
        draw_all
        $game_system.se_play($data_system.cursor_se)
      end
      if Mouse.is_here?(164, 373, 17, 14) # Flèche droite
        @index_list += 6
        @index_list = @end_list-7 if @index_list > (@end_list-7)
        draw_list
        draw_list_text
        draw_all
        $game_system.se_play($data_system.cursor_se)
      end
      if Mouse.is_here?(213, 373, 14, 14) # Croix
        Scene_Manager.map
        @transition = false
        Pokemon_Menu::set_transition   
      return $game_system.se_play($data_system.cancel_se)
      end
      if Mouse.is_here?(237, 373, 14, 14) # Retour
        Scene_Manager.pop(2)      
        return $game_system.se_play($data_system.cancel_se)
      end
      7.times do |i|
        if @list_B[i].visible and Mouse.is_in_sprite_plus?(@list_B[i]) and $pokemon_party.seen?(@index_list+1+i)
          @id = @index_list + 1 + i
          confirm
          return $game_system.se_play($data_system.decision_se)
        end
      end
    end
    if Input.trigger?(Input::B)
      Scene_Manager.pop(2)
      return $game_system.se_play($data_system.cancel_se)
    end
    if Input.repeat?(Input::UP) and (@id != 1)      
      @index_cursor -= 1
      draw_all
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.repeat?(Input::DOWN) and @id < @end_list
      @index_cursor += 1
      draw_all
      return $game_system.se_play($data_system.cursor_se)
    end    
    if Input.repeat?(Input::LEFT)
      @index_list -= 6
      @index_list = 0 if @index_list < 0
      draw_list
      draw_list_text
      draw_all
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.repeat?(Input::RIGHT)
      @index_list += 6
      @index_list = @end_list-7 if @index_list > (@end_list-7)
      draw_list
      draw_list_text
      draw_all
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.trigger?(Input::C) and $pokemon_party.seen?(@id)     
      confirm
      return $game_system.se_play($data_system.decision_se)
    end
  end
  
  def draw_list
    #> Nettoyage de la liste et du texte
    7.times do |i|      
      @list_A[i].bitmap.clear if i < 6
      @list_B[i].bitmap.clear      
    end      
    #> Actualisation de la partie supérieur de la liste (visible ou non)
    5.step(0,-1) do |i|
      if i <= (-(@index_list-5))
        @list_A[i].visible = false
      else
        @list_A[i].visible = true
      end     
    end
    #> Actualisation des sprites de la liste supérieur
    5.step(0,-1) do |i|
      if $pokemon_party.captured?(@index_list-5+i)
        @list_A[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 44, 151, 21))
      elsif $pokemon_party.seen?(@index_list-5+i)
        @list_A[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 22, 151, 21))
      else
        @list_A[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 0, 151, 21))
      end
    end
    #> Actualisation des sprites de la liste inférieur
    7.times do |i|
      if $pokemon_party.captured?(@index_list+i+1)
        @list_B[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 44, 151, 21))
      elsif $pokemon_party.seen?(@index_list+i+1)
        @list_B[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 22, 151, 21))
      else
        @list_B[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 0, 151, 21))
      end
    end   
    #> Affichage de l'icône des Pokémon
    #>> Liste supérieur
    5.step(0,-1) do |i|
      if $pokemon_party.seen?(@index_list-5+i)
        a = sprintf("%03d", @index_list-5+i)
        icon_a = RPG::Cache.icon("Pokemon/#{a}.png")
        @list_A[i].bitmap.blt(0, -9, icon_a, Rect.new(0, 0, 32, 32))
      end
    end
    #>> Liste inférieur
    7.times do |i|
      if $pokemon_party.seen?(@index_list+i+1)
        b = sprintf("%03d", @index_list+i+1)
        icon_b = RPG::Cache.icon("Pokemon/#{b}.png")
        @list_B[i].bitmap.blt(0, -9, icon_b, Rect.new(0, 0, 32, 32))
      end
    end    
  end 
  
  def draw_list_cursor  
    scp = @sprite_cursor
    #> Nettoyage du curseur
    7.times do |i|
      scp[i].bitmap.clear
      scp[i].visible = false
    end
    #> Affichage du curseur
    if $pokemon_party.captured?(@id)      
      scp[@index_cursor].bitmap.blt(0, 0, @img_list_cursor, Rect.new(0, 44, 151, 21))     
    elsif $pokemon_party.seen?(@id)     
      scp[@index_cursor].bitmap.blt(0, 0, @img_list_cursor, Rect.new(0, 22, 151, 21))    
    else     
      scp[@index_cursor].bitmap.blt(0, 0, @img_list_cursor, Rect.new(0, 0, 151, 21))     
    end    
    scp[@index_cursor].visible = true
    #> Affichage du texte du curseur
    scp[@index_cursor].bitmap.draw_text_plus(55,3,20,16,sprintf("%03d",(@id)).to_s,1,16)
    if $pokemon_party.seen?(@id)
      scp[@index_cursor].bitmap.draw_text_plus(83,3,80,16,PokemonData::Pokemon.load(@id).name,0,16)
    else
      scp[@index_cursor].bitmap.draw_text_plus(83,3,80,16,"?????",0,16)
    end    
    #> Affichage de l'icône du Pokémon du curseur
    if $pokemon_party.seen?(@id)
      c = sprintf("%03d", @id)
      icon_c = RPG::Cache.icon("Pokemon/#{c}.png")
      scp[@index_cursor].bitmap.blt(0, -9, icon_c, Rect.new(0, 0, 32, 32))
    end
  end
  
  def draw_list_text
    #> Texte de la liste supérieur
    5.step(0,-1) do |i|
      ida = @index_list-5+i
      @list_A[i].bitmap.draw_text_plus(55,3,20,16,sprintf("%03d",(ida)).to_s,1,9)
      if $pokemon_party.seen?(ida)
        @list_A[i].bitmap.draw_text_plus(83,3,80,16,PokemonData::Pokemon.load(ida).name,0,9)
      else
        @list_A[i].bitmap.draw_text_plus(83,3,80,16,"?????",0,9)
      end
    end
    #> Texte de la liste inférieur
    7.times do |i|
      idb = @index_list+i+1
      @list_B[i].bitmap.draw_text_plus(55,3,20,16,sprintf("%03d",(idb)).to_s,1,9)
      if $pokemon_party.seen?(idb)
        @list_B[i].bitmap.draw_text_plus(83,3,80,16,PokemonData::Pokemon.load(idb).name,0,9)
      else
        @list_B[i].bitmap.draw_text_plus(83,3,80,16,"?????",0,9)
      end
    end
  end
  
  def draw_sprite
    if $pokemon_party.seen?(@id)
      @sprc.bitmap = RPG::Cache.pokemon_pokedex("sprc.png")
      @sprc.x = 3    
      @sprc.y = 0
      f = sprintf("%03d", @id)
      @front.bitmap = RPG::Cache.battler("Pokemon/Battler_Face/Front_Male/#{f}.png",0)
      @front.visible = true
    else
      @sprc.bitmap = RPG::Cache.pokemon_pokedex("inconnu.png")
      @sprc.x = 31
      @sprc.y = 43
      @front.visible = false
    end    
  end
  
  def draw_text
    @text.bitmap.clear   
    @text.bitmap.draw_text_plus(24, 29, 100, 16, "POKÉMON VUS")
    @text.bitmap.draw_text_plus(146, 29, 100, 16, "POKÉMON PRIS")    
    if @national
      seen = $pokemon_party.seen.count(true)
      captured = $pokemon_party.captured.count(true) 
      @text.bitmap.draw_text_plus(8, 4, 100, 16, "POKÉDEX NATIONAL", 0, 9)
    else
      captured, seen = 0, 0
      for i in 494..650        
        if $pokemon_party.captured?(i)
          captured += 1
          seen += 1
        elsif $pokemon_party.seen?(i)           
          seen += 1
        end                
      end
      @text.bitmap.draw_text_plus(8, 4, 100, 16, "POKÉDEX DE #{Pokemon_S::REGION_NAME}", 0, 9)
    end
    @text.bitmap.draw_text_plus(90, 29, 30, 16, seen.to_s, 2)
    @text.bitmap.draw_text_plus(212, 29, 30, 16, captured.to_s, 2)
  end
  
  def draw_all
    #> On vérifie si on a besoin de déplacer la liste
    if @index_cursor < 0 or @index_cursor > 6
      if @index_cursor == -1
        @index_cursor = 0
        @index_list -= 1
      end
      if @index_cursor >= 6
        @index_cursor = 6
        @index_list += 1
      end       
      draw_list
      draw_list_text 
    end
    @id = @index_list + @index_cursor + 1
    draw_list_cursor    
    draw_sprite
  end
    
  def animation
    @background_A.x == -64 ? @background_A.x += 64 : (@background_A.x -= 1 and 
    @wait == 1 ? @wait = 0 : @wait += 1)
    @background_B.x = @background_A.x
  end
  
  def confirm
    Scene_Manager.push(Pokedex_Info)       
    Pokedex_Info.init(@id)   
    @index_list = $pokedex.index_list
    if (@index_list > @end_list-7)
      @index_list -= 7
      @index_cursor = @end_list - @index_cursor
    else
      @index_cursor = 0
    end
    if Scene_Manager.stack[3] == Pokedex_List
      draw_list
      draw_list_text
      draw_all
    end
    Graphics.transition if Pokedex_Info::transition?
  end
  
  def finish
    return if @finished
    @viewport_A.dispose
    @viewport_B.dispose   
    @background_A.dispose
    @background_B.dispose
    @interface.dispose
    @barre.dispose
    @sprc.dispose
    @front.dispose
    @list_A.each do |i| i.dispose end
    @list_B.each do |i| i.dispose end
    @sprite_cursor.each do |i| i.dispose end
    @text.dispose
    @viewport_A = nil
    @viewport_B = nil       
    @background_A = nil
    @background_B = nil
    @interface = nil
    @barre = nil
    @sprc = nil
    @front = nil
    @list_A = nil
    @list_B = nil
    @sprite_cursor = nil
    @text = nil
    @finished = true
  end
  
  def finished?() @finished end
  def transition?() @transition end  
end
  
module Pokemon_S
  class Pokedex
    attr_accessor :index_list
    attr_accessor :end_list
      
    def initialize
      @index_list = 0
    end
  end
end
  