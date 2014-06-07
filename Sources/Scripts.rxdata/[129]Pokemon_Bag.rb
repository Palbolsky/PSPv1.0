#==============================================================================
# ■ Pokemon_Status
# Pokemon Script Project v1.0 - Palbolsky
# 02/05/2013
#------------------------------------------------------------------------------

module Pokemon_Bag
  include Pokemon_S  
  NAME_SOCKETS=["OBJETS","MÉDICAMENTS","CT & CS","BAIES","OBJETS RARES"]
  module_function
  def viewport(x1=0,y1=0,x2=0,y2=200)
    @viewport_A = Viewport.new(x1,y1,256,192)
    @viewport_A.z = 1002
    @viewport_B = Viewport.new(x2,y2,256,192)
    @viewport_B.z = 1002
  end
  
  def init
    @finished = false
    @transition = true
    @socket = 0
    @index_list = 0
    @index_cursor = 0
    @num_c = 0 # Numéro de la case
    @bag = $pokemon_party.bag
    @background_A = Sprite.new(@viewport_A)
    @background_A.bitmap = RPG::Cache.pokemon_bag("background_A#{$pokemon_party.player_sexe}.png")
    @background_B = Sprite.new(@viewport_B)
    @background_B.bitmap = RPG::Cache.pokemon_bag("background_B#{$pokemon_party.player_sexe}.png")
    @background_A.z = @background_B.z = 0
    @img_socket = Sprite.new(@viewport_B)    
    @img_socket.y = 26-10*$pokemon_party.player_sexe
    @img_socket.z = 1
    @img_list = RPG::Cache.pokemon_bag("list.png")
    @list = Array.new
    #> Création de la liste
    6.times do |i|
      @list[i] = Sprite.new(@viewport_B)
      @list[i].bitmap = Bitmap.new(125, 24)
      @list[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 0, 125, 24))
      @list[i].ox = -116
      @list[i].y = 12+24*i
      @list[i].z = 1
      @list[i].visible = false
      next if i >= @bag[@socket].size
      @list[i].visible = true
    end
    #> Création du curseur
    @img_list_cursor = RPG::Cache.pokemon_bag("list_curseur.png")
    @sprite_cursor = Array.new
    6.times do |i|
      @sprite_cursor[i] = Sprite.new(@viewport_B)
      @sprite_cursor[i].bitmap = Bitmap.new(106, 24)
      @sprite_cursor[i].bitmap.blt(0, 0, @img_list_cursor, Rect.new(0, 0, 106, 24))    
      @sprite_cursor[i].x = 135
      @sprite_cursor[i].y = 12+24*i
      @sprite_cursor[i].z = 2
      @sprite_cursor[i].visible = false
    end
    @text_A = Sprite.new(@viewport_A)
    @text_A.bitmap = Bitmap.new(256,192)
    @img_descr = RPG::Cache.pokemon_bag("description_#{$pokemon_party.player_sexe}.png")
    @text_B = Sprite.new(@viewport_B)
    @text_B.bitmap = Bitmap.new(256,192)
    @text_A.z = @text_B.z = 1
    draw_socket
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
    if Input.trigger_plus2?(1)
      if Mouse.is_here?(197,373,14,14) # Croix
        Scene_Manager.pop(2)
        @transition = false
        Pokemon_Menu::set_transition
        return $game_system.se_play($data_system.cancel_se)
      end
      if Mouse.is_here?(229,373,14,14) # Retour
        Scene_Manager.pop
        return $game_system.se_play($data_system.cancel_se)
      end
      if Mouse.is_here?(3,373,17,14) # Flèche gauche
        @socket == 0 ? @socket = 4 : @socket -= 1
        draw_socket
        return $game_system.se_play($data_system.cursor_se)        
      end
      if Mouse.is_here?(124,373,17,14) # Flèche droite
        @socket == 4 ? @socket = 0 : @socket += 1
        draw_socket
        return $game_system.se_play($data_system.cursor_se)        
      end
      6.times do |i|
        if @list[i].visible and Mouse.is_in_sprite_plus?(@list[i]) and @index_cursor == i
          $game_system.se_play($data_system.decision_se)
          command
          return
        elsif @list[i].visible and Mouse.is_in_sprite_plus?(@list[i])
          @index_cursor = i
          draw_all
          return $game_system.se_play($data_system.cursor_se)
        end
      end 
    end
    if Input.trigger?(Input::B)
      Scene_Manager.pop
      return $game_system.se_play($data_system.cancel_se)
    end
    if Input.trigger?(Input::LEFT)
      @socket == 0 ? @socket = 4 : @socket -= 1
      draw_socket
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.trigger?(Input::RIGHT)
      @socket == 4 ? @socket = 0 : @socket += 1
      draw_socket
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.repeat?(Input::UP) and @num_c != 0
      @index_cursor -= 1
      draw_all
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.repeat?(Input::DOWN) and (@num_c+1) < @bag[@socket].size
      @index_cursor += 1
      draw_all
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.trigger?(Input::C) and @bag[@socket].size != 0
      $game_system.se_play($data_system.decision_se)
      command
      return
    end
  end
  
  def draw_socket
    @text_A.bitmap.clear
    @text_B.bitmap.clear    
    6.times do |i|
      @list[i].visible = false
      next if i >= @bag[@socket].size 
      @list[i].visible = true
    end
    @img_socket.bitmap = RPG::Cache.pokemon_bag("poche_#{@socket}_#{$pokemon_party.player_sexe}.png")
    @text_B.bitmap.draw_text_plus(23, 172, 100, 16, NAME_SOCKETS[@socket], 1, 9)
    @index_list,@index_cursor,@num_c = 0,0,0
    draw_list
    draw_list_text 
    draw_list_cursor
  end
  
  def draw_list
    #> Nettoyage de la liste et du texte
    6.times do |i|      
      @list[i].bitmap.clear     
    end
    #> Actualisation des sprites de la liste
    6.times do |i|
      next if i >= @bag[@socket].size
      case @socket
      when 4 # Objets rares
        @list[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 96, 125, 24))
      when 3 # Baies        
        @list[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 0, 125, 24))       
      when 2 # CT & CS      
        @list[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 72, 125, 24))   
      when 1 # Médicaments
        @list[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 0, 125, 24)) 
      when 0 # Objets
        id = @bag[@socket][@index_list+i][0]
        if Item.ball?(id) # Balls    
          @list[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 48, 125, 24))          
        else
          @list[i].bitmap.blt(0, 0, @img_list, Rect.new(0, 0, 125, 24)) 
        end
      end
    end    
  end
  
  def draw_list_cursor    
    6.times do |i|
      @sprite_cursor[i].bitmap.clear
      @sprite_cursor[i].visible = false
    end    
    return if @bag[@socket].size == 0 # S'il n'y a aucun objet dans la poche
    @sprite_cursor[@index_cursor].visible = true 
    @sprite_cursor[@index_cursor].bitmap.blt(0, 0, @img_list_cursor, Rect.new(0, 0, 106, 24))
    id = @bag[@socket][@num_c][0]
    @sprite_cursor[@index_cursor].bitmap.draw_text_plus(5,4,80,16,PokemonData::Item.load(id).name,0,8)
    draw_description
  end
  
  def draw_list_text
    6.times do |i|
      return if i >= @bag[@socket].size
      id = @bag[@socket][@index_list+i][0]
      @list[i].bitmap.draw_text_plus(24,4,80,16,PokemonData::Item.load(id).name,0,8)
    end
  end
  
  def draw_all
    #> On vérifie si on a besoin de déplacer la liste
    if @index_cursor < 0 or @index_cursor > 5
      if @index_cursor == -1
        @index_cursor = 0
        @index_list -= 1
      end
      if @index_cursor >= 5
        @index_cursor = 5
        @index_list += 1
      end       
      draw_list
      draw_list_text 
    end
    @num_c = @index_list + @index_cursor
    draw_list_cursor
  end
  
  def draw_description
    id = @bag[@socket][@num_c][0]
    amount = @bag[@socket][@num_c][1]
    @text_A.bitmap.clear
    @text_A.bitmap.blt(0, 30, @img_descr, Rect.new(0, 0, 256, 124)) 
    @text_A.bitmap.draw_text_plus(68,44,120,16,PokemonData::Item.load(id).name,1,17+$pokemon_party.player_sexe)
    @text_A.bitmap.draw_text_plus(160,67,120,16,"x#{amount}", 0, 17+$pokemon_party.player_sexe) if @socket != 4
    descr = string_builder(PokemonData::Item.load(id).descr, 45)
    3.times do |i|
      @text_A.bitmap.draw_text_plus(20, 97+i*16, 250, 16, descr[i], 0, 17+$pokemon_party.player_sexe)
    end
    if PokemonData::Item.load(id).icon != ""
      @text_A.bitmap.blt(115, 63, RPG::Cache.icon("Items/#{PokemonData::Item.load(id).icon}.png"), Rect.new(0, 0, 26, 26))
    end
  end
  
  def command
    id = @bag[@socket][@num_c][0]
    @command = Yuki::Command.new(152, 192, 2, false, -1, :y) 
    @command.set_bitmap(0, RPG::Cache.pokemon_party_menu("list.png"))
    @command.set_bitmap(1, RPG::Cache.pokemon_party_menu("fleche_retour.png"))    
    if Item.use_on_pokemon?(id) or Item.map_usable?(id)
      @command.push_button({:x=>9,:y=>1,:w=>80,:h=>24,:txt=>"UTILISER",:color=>8,:bitmap_id=>0},method(:use), @viewport_B)
    end
    if Item.holdable?(id)
       @command.push_button({:x=>9,:y=>1,:w=>80,:h=>24,:txt=>"DONNER",:color=>8,:bitmap_id=>0},method(:get), @viewport_B)
      @command.push_button({:x=>9,:y=>1,:w=>80,:h=>24,:txt=>"JETER",:color=>8,:bitmap_id=>0},method(:jeter), @viewport_B)     
    end  
    if @socket == 4 and Item.map_usable?(id)     
      @command.push_button({:x=>9,:y=>1,:w=>80,:h=>24,:txt=>"ENREGISTRER",:color=>8,:bitmap_id=>0},method(:use), @viewport_B)
    end   
    @command.push_button({:x=>9,:y=>1,:w=>80,:h=>24,:txt=>"RETOUR",:color=>8,:bitmap_id=>0,:bx=>82,:by=>8, :bmp=>1},method(:retour), @viewport_B)
    @command.draw
    @command.run
    if @command != nil
      @command.last_meth
      @command.dispose
    end
  end  
  
  def use

  end
  
  def get
    return if $pokemon_party.size == 0
    Scene_Manager.push(Pokemon_Party_Menu)
    Pokemon_Party_Menu.init(2,@bag[@socket][@num_c][0])    
    Graphics.transition if Pokemon_Party_Menu::transition?    
  end
  
  def jeter
  end
  
  def retour
  end
  
  def trier
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
    @img_socket.dispose
    @list.each do |i| i.dispose end
    @sprite_cursor.each do |i| i.dispose end
    @text_A.dispose
    @text_B.dispose
    @background_A = nil
    @background_B = nil
    @img_socket = nil
    @list = nil
    @sprite_cursor = nil
    @text_A = nil
    @text_B = nil
    @command = nil
  end
  
  def finished?() @finished end
  def transition?() @transition end
end