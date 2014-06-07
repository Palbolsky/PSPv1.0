#==============================================================================
# ■ Pokedex_Info
# Pokemon Script Project v1.0 - Palbolsky
# 22/01/2013
#------------------------------------------------------------------------------

module Pokedex_Info
  PAGES=["DÉTAILS","ZONE","CRI","FORME"]
  module_function  
  def viewport(x1=0,y1=0,x2=0,y2=200)
    @viewport_A = Viewport.new(x1,y1,256,192)
    @viewport_A.z = 1005
    @viewport_B = Viewport.new(x2,y2,256,192)
    @viewport_B.z = 1005
  end
  
  def init(id=1)
    @finished = false
    @transition = true
    @id = id
    @index = 0
    @wait = 0
    @background_A = Sprite.new(@viewport_A)    
    @background_A.z = 0
    @background_B = Sprite.new(@viewport_B)
    @background_B.z = 0
    @interface_B = Sprite.new(@viewport_B)
    @interface_B.y = 3
    @interface_B.z = 1
    @barre_A = Sprite.new(@viewport_A)
    @barre_A.bitmap = RPG::Cache.pokedex_info("barre_A.png")    
    @barre_A.y = 2
    @barre_A.z = 1
    @barre_B = Sprite.new(@viewport_B)
    @barre_B.bitmap = RPG::Cache.pokedex_info("barre_B.png")    
    @barre_B.y = 168
    @barre_B.z = 1   
    @text_A = Sprite.new(@viewport_A)
    @text_A.bitmap = Bitmap.new(256, 192)
    @text_A.z = 2   
    @text_B = Sprite.new(@viewport_B)
    @text_B.bitmap = Bitmap.new(256,192)
    @text_B.z = 2
    @battler = Sprite.new(@viewport_B)
    bf = sprintf("%03d", @id)       
    @battler.bitmap = RPG::Cache.battler("Pokemon/Battler_Face/Front_Male/#{bf}.png",0)
    @battler.x = 4
    @battler.y = 4
    @battler.z = 2
    @battler.mirror = true
    draw_page
    run
  end
  
  def run 
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
    if Input.trigger_plus2?(1)
      if Mouse.is_here?(213, 373, 14, 14) # Croix    
        Scene_Manager.map
        return $game_system.se_play($data_system.cancel_se)
      end
      if Mouse.is_here?(237, 373, 14, 14) # Retour
        $pokedex.index_list = @id-1
        Scene_Manager.pop      
        return $game_system.se_play($data_system.cancel_se)
      end
      4.times do |i|
        if Mouse.is_here?(48+i*31+i,370,31,21) # Boutons pages
          @index = i
          draw_page
          return $game_system.se_play($data_system.cursor_se)
        end
      end
      if Mouse.is_here?(5,371,14,17) and @id > 1 # Flèche haut
        @id -= 1
        while(!$pokemon_party.seen?(@id) and @id != 1)
          @id -= 1    
        end
        refresh
        return $game_system.se_play($data_system.cursor_se)
      end
      if Mouse.is_here?(29,371,14,17) and @id < $pokedex.end_list # Flèche bas
        @id += 1
        while(!$pokemon_party.seen?(@id))
          @id += 1
        end
        refresh
        return $game_system.se_play($data_system.cursor_se)
      end
    end
    if Input.trigger?(Input::LEFT) and @index > 0
      @index -= 1
      draw_page
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.trigger?(Input::RIGHT) and @index < 3
      @index += 1
      draw_page
      return $game_system.se_play($data_system.cursor_se)
    end  
    if Input.trigger?(Input::UP) and @id > 1
      @id -= 1
      while(!$pokemon_party.seen?(@id) and @id != 1)
        @id -= 1    
      end
      refresh
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.trigger?(Input::DOWN) and @id < $pokedex.end_list
      @id += 1
      while(!$pokemon_party.seen?(@id))
        @id += 1
      end
      refresh
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.trigger?(Input::B)
      $pokedex.index_list = @id-1
      Scene_Manager.pop
      return $game_system.se_play($data_system.cancel_se)
    end
  end
  
  def draw_page
    @background_A.bitmap = RPG::Cache.pokedex_info("background_A#{@index}.png")
    if @index == 1
      @background_B.visible = false
    else
      @background_B.visible = true
      @background_B.bitmap = RPG::Cache.pokedex_info("background_B#{@index}.png")
    end
    if @index == 0
      @interface_B.visible = true
      @interface_B.bitmap = RPG::Cache.pokedex_info("interface_B0.png")##{@index}.png")
    else
      @interface_B.visible = false
    end
    @barre_A.src_rect.set(0,20*@index,256,20)
    @barre_B.src_rect.set(0,24*@index,256,24)
    refresh    
  end
  
  def refresh
    @text_A.bitmap.clear 
    @text_B.bitmap.clear   
    @text_A.bitmap.draw_text_plus(24, 4, 60, 16, PAGES[@index], 0, 9)
    @battler.visible = false
    case @index
    when 0 # Détails       
      if $pokemon_party.captured?(@id)
        @text_B.bitmap.blt(104, 10, RPG::Cache.pokedex_info("captured.png"), Rect.new(0,0,17,15))
        @text_B.bitmap.blt(152, 53, RPG::Cache.pokemon_status("T#{PokemonData::Pokemon.load(@id).type1}.png"), Rect.new(0, 0, 32, 14))
        @text_B.bitmap.blt(192, 53, RPG::Cache.pokemon_status("T#{PokemonData::Pokemon.load(@id).type2}.png"), Rect.new(0, 0, 32, 14)) if PokemonData::Pokemon.load(@id).type2 != 0
        spec = PokemonData::Pokemon.load(@id).spec
        #> Affichage de l'empreinte
        idx = (@id-1) % 20
        idy = (@id-1) / 20
        xrect = idx * 16
        yrect = idy * 16
        @text_B.bitmap.blt(112, 56, RPG::Cache.pokedex_info("pas.png"), Rect.new(xrect,yrect,16,16))  
        height = PokemonData::Pokemon.load(@id).height.to_s
        height.gsub!(/\./) { "," }
        weight = PokemonData::Pokemon.load(@id).weight.to_s
        weight.gsub!(/\./) { "," }        
        #> Affichage de la description
        descr = string_builder(PokemonData::Pokemon.load(@id).descr, 45)
        3.times do |i|
          @text_B.bitmap.draw_text_plus(20, 116+i*16, 250, 16, descr[i], 0, 9)
        end
      else
        spec = "?????"
        height = "???,?"
        weight = "???,?"
      end        
      @text_B.bitmap.draw_text_plus(137, 13, 35, 16, sprintf("%03d", @id))
      @text_B.bitmap.draw_text_plus(176, 13, 100, 16, PokemonData::Pokemon.load(@id).name)
      @text_B.bitmap.draw_text_plus(138, 30, 120, 16, "Pokémon #{spec}")
      @text_B.bitmap.draw_text_plus(144, 76, 50, 16, "TAILLE :")
      @text_B.bitmap.draw_text_plus(188, 76, 50, 16, "#{height} m", 2)
      @text_B.bitmap.draw_text_plus(144, 92, 40, 16, "POIDS :")
      @text_B.bitmap.draw_text_plus(194, 92, 50, 16, "#{weight} kg",2)       
      #> Affichage du battler
      bf = sprintf("%03d", @id)       
      @battler.bitmap = RPG::Cache.battler("Pokemon/Battler_Face/Front_Male/#{bf}.png",0)
      @battler.visible = true        
    when 1 # Zone
      print("Non programmé.")
    when 2 # Cri
      print("Non programmé.")
    when 3 # Forme
      print("Non programmé.")
    end
  end 
  
  def animation
    @background_A.x == -64 ? @background_A.x += 64 : (@background_A.x -= 1 and 
    @wait == 1 ? @wait = 0 : @wait += 1)
    @background_B.x = @background_A.x
  end
  
  def string_builder(text, limit)
    length = text.length
    full = Array.new
    string = Array.new
    3.times do |i|
      full[i] = false
      string[i] = ""
    end
    word = ""
    (length+1).times do |i|
      letter = text[i..i]
      if letter != " " and i != length
        word += letter.to_s
      else
        word = word + " "
        3.times do |j|
          if (string[j] + word).length < limit and not(full[j])
            string[j] += word
            word = ""
          else
            full[j] = true
          end
        end
      end
    end
    if string[2].length > 1
      string[2] = string[2][0..string[2].length-2]
    end
    return [string[0], string[1], string[2]]
  end
        
  def finish
    return if @finished
    @background_A.dispose
    @background_B.dispose  
    @interface_B.dispose
    @barre_A.dispose
    @barre_B.dispose    
    @text_A.dispose
    @text_B.dispose
    @battler.dispose
    @background_A = nil
    @background_B = nil
    @interface_B = nil
    @barre_A = nil
    @barre_B = nil   
    @text_A = nil
    @text_B = nil
    @battler = nil
    @finished = true
  end
  
  def finished?() @finished end
  def transition?() @transition end  
end
