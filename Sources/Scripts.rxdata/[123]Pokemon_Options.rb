#==============================================================================
# ■ Pokemon_Options
# Pokemon Script Project v1.0 - Palbolsky
# 01/08/2012
#------------------------------------------------------------------------------

module Pokemon_Options
  LIST=["VITESSE DU TEXTE", "ANIM. COMBAT", "STYLE DE COMBAT"]
  module_function
  def viewport(x1=0,y1=0,x2=0,y2=200)
    #>Création des viewports
    @viewport_A = Viewport.new(x1, y1, 256, 192)
    @viewport_A.z = 1002
    @viewport_B = Viewport.new(x2, y2, 256, 192)
    @viewport_B.z = 1002   
  end
  
  def init
    @finished = false
    @transition = true
    $pokemon_party = Pokemon_S::Pokemon_Party.new unless $pokemon_party
    @index = 0   
    @background_A = Sprite.new(@viewport_A)
    @background_A.bitmap = RPG::Cache.pokemon_option("background_A.png")    
    @background_B = Sprite.new(@viewport_B)
    @background_B.bitmap = RPG::Cache.pokemon_option("background_B.png")  
    @background_A.z = @background_B.z = 0
    @msg = Sprite.new(@viewport_A)
    @msg.bitmap = RPG::Cache.pokemon_option("msg.png")
    @msg.y = 144
    @msg.z = 1
    @select = Sprite.new(@viewport_B)
    @select.bitmap = RPG::Cache.pokemon_option("index_select.png")
    @select.y = 24
    @select.z = 1
    @btn = Array.new
    @img_btn = RPG::Cache.pokemon_option("btn.png")
    2.times do |i|
      @btn[i] = Sprite.new(@viewport_B)
      @btn[i].bitmap = Bitmap.new(256, 24)      
      @btn[i].bitmap.blt(0, 0, @img_btn, Rect.new(72*i, 0, 70, 24))
      @btn[i].x = 113+i*72
      @btn[i].y = 168
      @btn[i].z = 1
    end        
    @option = Array.new   
    @index_option = Array.new
    3.times do |i|
      @option[i] = Sprite.new(@viewport_B)
      @option[i].bitmap = RPG::Cache.pokemon_option("option_#{i}.png")
      @option[i].x = 113
      @option[i].y = 28+i*24
      @option[i].z = 2  
      next if i == 0
      @index_option[i] = $pokemon_party.options[i] == true ? 1 : 2
    end    
    @index_option[0] = $pokemon_party.options[0]
    @text_A = Sprite.new(@viewport_A)
    @text_A.bitmap = Bitmap.new(256, 192)
    @text_A.z = 2
    @text_B = Sprite.new(@viewport_B)
    @text_B.bitmap = Bitmap.new(256, 192)
    @text_B.z = 2 
    refresh_all
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
      if Mouse.is_here?(85,373,14,14)  
        if Scene_Manager.stack[0] == Scene_Title
          Scene_Manager.pop
        else
          Scene_Manager.pop(2)
          @transition = false
          Pokemon_Menu::set_transition
          return $game_system.se_play($data_system.cancel_se)
        end
      end
      3.times do |i|
        if Mouse.is_here?(0,224+24*i,256,24)
          @index = i  
          refresh_all
          $game_system.se_play($data_system.cursor_se)
        end
      end
      2.times do |i|
        if @btn[i].visible and Mouse.is_in_sprite_plus?(@btn[i])
          @index = i+3          
          refresh_all
          @index == 3 ? confirm : retour
        end        
      end  
      3.times do |i|
        if Mouse.is_here?(110+45*i,228,18,15)
          @index_option[0] = i+1  
          draw_option
          $game_system.se_play($data_system.cursor_se)
        end
      end
      2.times do |i|
        if Mouse.is_here?(110+72*i,252,37,15)
          @index_option[1] = i+1
          draw_option
          $game_system.se_play($data_system.cursor_se)
        end
        if Mouse.is_here?(110+72*i,276,48,15)
          @index_option[2] = i+1
          draw_option
          $game_system.se_play($data_system.cursor_se)
        end
      end
    end
    if Input.trigger?(Input::B) 
      retour
    end
    if Input.repeat?(Input::UP)
      @index == 0 ? @index = 0 : (@index -= 1 and $game_system.se_play($data_system.cursor_se))
      refresh_all
    end
    if Input.repeat?(Input::DOWN)
      @index == 4 ? @index = 4 : (@index += 1 and $game_system.se_play($data_system.cursor_se))
      refresh_all
    end
    if @index > 2
      if Input.repeat?(Input::LEFT)
        @index == 3 ? @index = 3 : (@index -= 1 and $game_system.se_play($data_system.cursor_se))
        draw_index
      end
      if Input.repeat?(Input::RIGHT)
        @index == 4 ? @index = 4 : (@index += 1 and $game_system.se_play($data_system.cursor_se))
        draw_index
      end
    end
    case @index
    when 0 #Vitesse
      if Input.trigger?(Input::LEFT)
        @index_option[0] == 1 ? @index_option[0] = 1 : (@index_option[0] -= 1 and $game_system.se_play($data_system.cursor_se))
        draw_option
      end
      if Input.trigger?(Input::RIGHT)
        @index_option[0] == 3 ? @index_option[0] = 3 : (@index_option[0] += 1 and $game_system.se_play($data_system.cursor_se))
        draw_option
      end    
    when 3 #OK
      if Input.trigger?(Input::C)
        confirm
      end
    when 4 #Annuler
      if Input.trigger?(Input::C)
        retour
      end
    else      
      if Input.trigger?(Input::LEFT)
        @index_option[@index] == 1 ? @index_option[@index] = 1 : @index_option[@index] -= 1
        draw_option
      end
      if Input.trigger?(Input::RIGHT)
        @index_option[@index] == 2 ? @index_option[@index] = 2 : @index_option[@index] += 1
        draw_option
      end      
    end   
  end
  
  def draw_index
    2.times do |i|
      @btn[i].bitmap.blt(0, 0, @img_btn, Rect.new(72*i, 0, 70, 24))
    end
    @msg.visible = true
    @select.visible = false
    if @index <= 2
      @select.y = 24+@index*24
      @select.visible = true
    elsif @index > 2
      @btn[@index-3].bitmap.blt(0, 0, @img_btn, Rect.new(72*(@index-3), 24, 70, 24))
      @msg.visible = false
    end
  end
  
  def draw_option
    3.times do |i|
      @option[i].src_rect.set(0, 15*(@index_option[i]-1), 114, 15)
    end
  end
  
  def refresh
    @text_A.bitmap.clear
    @text_B.bitmap.clear
    case @index
    when 0
      @text_A.bitmap.draw_text_plus(8, 152, 250, 16, "Vous pouvez choisir parmi 3 vitesses", 0, 14)
      @text_A.bitmap.draw_text_plus(8, 168, 250, 16, "de défilement du texte.", 0, 14)
    when 1
      @text_A.bitmap.draw_text_plus(8, 152, 250, 16, "Vous pouvez choisir de voir au non les", 0, 14)
      @text_A.bitmap.draw_text_plus(8, 168, 250, 16, "animations pendant les combats.", 0, 14)
    when 2
      @text_A.bitmap.draw_text_plus(8, 152, 250, 16, "Vous pouvez garder le même Pokémon ou en", 0, 14)
      @text_A.bitmap.draw_text_plus(8, 168, 250, 16, "changer quand votre adversaire est mis K.O.", 0, 14)      
    end    
    @text_B.bitmap.draw_text_plus(43, 4, 100, 16, "OPTIONS", 0, 8)
    @text_B.bitmap.draw_text_plus(122, 173, 100, 16, "OK", 0, 8)
    @text_B.bitmap.draw_text_plus(194, 173, 100, 16, "RETOUR", 0, 8)
    3.times do |i|
      @text_B.bitmap.draw_text_plus(8, 28+24*i, 100, 16, LIST[i], 0, 14)
    end
  end
  
  def confirm
    $pokemon_party.options[0] = @index_option[0]
    1.step(2) do |i|
      $pokemon_party.options[i] = @index_option[i] == 1
    end   
    Scene_Manager.pop
    return $game_system.se_play($data_system.decision_se)
  end
  
  def retour
    Scene_Manager.pop
    return $game_system.se_play($data_system.cancel_se)
  end
  
  def refresh_all
    refresh
    draw_index
    draw_option
  end
  
  def finish
    return if @finished
    @viewport_A.dispose
    @viewport_B.dispose
    @background_A.dispose
    @background_B.dispose
    @msg.dispose
    @select.dispose
    @btn.each do |i| i.dispose end
    @option.each do |i| i.dispose end
    @text_A.dispose
    @text_B.dispose
    @viewport_A = nil
    @viewport_B = nil
    @background_A = nil
    @background_B = nil
    @msg = nil
    @select = nil
    @btn = nil
    @option = nil
    @text_A = nil
    @text_B = nil
    @finished = true
  end
  
  def finished?() @finished end
  def transition?() @transition end
end