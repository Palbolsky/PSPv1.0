#==============================================================================
# ■ Pokemon_Party_Menu
# Pokemon Script Project v1.0 - Palbolsky
# 03/07/2012
#------------------------------------------------------------------------------

module Pokemon_Party_Menu
  COORD_X=[1,129]
  COORD_Y=[9, 9, 57, 57, 105, 105]
  BTXT_X=[2, 10]
  BTXT_Y=[162, 146]  
  module_function 
  def viewport(x1=0,y1=0,x2=0,y2=200)
    @viewport_A = Viewport.new(x1,y1,256,192)
    @viewport_A.z = 1002
    @viewport_B = Viewport.new(x2,y2,256,192)
    @viewport_B.z = 1002
    @viewport_1 = Viewport.new(x2,y2,256,192)
    @viewport_1.z = 1003
  end
  
  def init(mode = 0, data = nil)
    # mode 0 : map ; mode 1 : command, mode 2 : item_hold
    @finished = false
    @transition = true 
    @mode = mode
    @data = data
    @index = 0
    @order = false    
    @rect = Rect.new(0, 0, 126, 46)   
    @background_A = Sprite.new(@viewport_A)
    @background_A.bitmap = RPG::Cache.pokemon_party_menu("background_A.png")
    @background_B = Sprite.new(@viewport_B)
    @background_B.bitmap = RPG::Cache.pokemon_party_menu("background_B.png")
    @background_A.z = @background_B.z = 0
    @croix = Sprite.new(@viewport_B)
    @croix.bitmap = RPG::Cache.pokemon_party_menu("croix.png")
    @croix.x = 201
    @croix.y = 173
    @croix.z = 1
    @ctete = RPG::Cache.pokemon_party_menu("cadrestete.png")
    @cparty = RPG::Cache.pokemon_party_menu("cadresparty.png")  
    @cadre = Array.new
    6.times do |i|
      @cadre[i] = Sprite.new(@viewport_B)
      @cadre[i].bitmap = Bitmap.new(126,46)
      @cadre[i].x = COORD_X[i&0x01]
      @cadre[i].y = COORD_Y[i]
      @cadre[i].z = 1      
      @cadre[i].visible = i < $pokemon_party.size
    end           
    @btext = Array.new 
    2.times do |i|
      @btext[i] = Sprite.new(@viewport_1)
      @btext[i].bitmap = RPG::Cache.pokemon_party_menu("btext#{i}.png")
      @btext[i].x = BTXT_X[i]
      @btext[i].y = BTXT_Y[i]     
      @btext[i].visible = false      
    end
    @btext[0].visible = true    
    @text = Sprite.new(@viewport_1)
    @text.bitmap = Bitmap.new(256, 192)
    @text.z = 1
    text
    draw_cadre
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
    if Input.trigger?(Input::B)
      if @order
        @order = false
        @croix.visible = true
        refresh_all
      else          
        Scene_Manager.pop
      end
      return $game_system.se_play($data_system.cancel_se)  
    end  
    
    if Input.trigger_plus2?(1)
      if Mouse.is_here?(201,373,14,14) and !@order        
        Scene_Manager.pop(2)
        @transition = false
        Pokemon_Menu::set_transition
        return $game_system.se_play($data_system.cancel_se)        
      end
      if Mouse.is_here?(229,373,14,14)
        if @order
          @order = false
          @croix.visible = true
          refresh_all
        else
          Scene_Manager.pop
        end          
        return $game_system.se_play($data_system.cancel_se)        
      end   
      @cadre.each_index do |i|
      if @cadre[i].visible and Mouse.is_in_sprite_plus?(@cadre[i])
          @index = i
          draw_cadre 
          if @order              
            anim_order if @index != @pchoice               
            @order = false
            @croix.visible = true
            refresh_all   
            return 
          elsif @item
            return
          else
            @btext[0].visible = false
            @btext[1].visible = true        
            @viewport_B.tone.set(64, 64, 64)
            @mode = 1
            text
          end
          return $game_system.se_play($data_system.decision_se) 
        end
      end
    end    
    if Input.repeat?(Input::UP)
      @index -= 2
      if @index < 0 
        if @index % 2 == 0
          $pokemon_party.size % 2 == 0 ? @index = ($pokemon_party.size-2) : @index = ($pokemon_party.size-1)              
        else
          @index = ($pokemon_party.size-1)
        end
      end
      draw_cadre
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.repeat?(Input::DOWN)      
      @index += 2              
      @index % 2 == 0 ? @index = 0 : @index = 1 if @index > ($pokemon_party.size-1)             
      draw_cadre
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.repeat?(Input::LEFT)
      @index -= 1        
      @index = ($pokemon_party.size-1) if @index < 0        
      draw_cadre
      return $game_system.se_play($data_system.cursor_se)
    end    
    if Input.repeat?(Input::RIGHT)
      @index += 1
      @index = 0 if @index > ($pokemon_party.size-1)            
      draw_cadre
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.trigger?(Input::C)  
      if @order         
        anim_order if @index != @pchoice            
        @order = false
        @croix.visible = true
        refresh_all   
        return
      elsif @mode == 2 # hold
        pokemon = $pokemon_party.actors[@index]        
        if pokemon.item_hold != 0
          
        elsif pokemon.item_hold == 0
          pokemon.item_hold = @data
          draw_text_cadre
          @text.bitmap.clear
          @text.bitmap.draw_text_plus(9, 168, 150, 16, "")      
          Graphics.wait(40)
          Scene_Manager.pop                     
        end        
      else
        @btext[0].visible = false
        @btext[1].visible = true        
        @viewport_B.tone.set(64, 64, 64)
        @mode = 1
        text          
      end    
      return $game_system.se_play($data_system.decision_se)
    end
    if @mode == 1
      command
    end    
  end  
  
  def draw_cadre
    $pokemon_party.size.times do |i|      
      if @order and @pchoice == i
        @rect.y = 188
      elsif $pokemon_party.actors[i].dead?
        @rect.y = 94
      else
        @rect.y = 0
      end
      @cadre[0].bitmap.blt(0, 0, @ctete, @rect) if i == 0
      @cadre[i].bitmap.blt(0,0,@cparty,@rect) if i > 0	
      next if @index != i      
      if @order
        @rect.y = 235
      elsif $pokemon_party.actors[@index].dead?
        @rect.y = 141
      else
        @rect.y = 47
      end
      @cadre[0].bitmap.blt(0, 0, @ctete, @rect) if @index == 0
      @cadre[@index].bitmap.blt(0, 0,@cparty, @rect) if @index > 0      
    end
    @rect.y = 0
    draw_text_cadre
  end  
  
  def draw_text_cadre
    $pokemon_party.size.times do |i|
      @cadre[i].bitmap.draw_text_plus(40,8,80,16,$pokemon_party.actors[i].name,0,8)
      @cadre[i].bitmap.blt(7, -2, $pokemon_party.actors[i].icon, @rect)
      next if $pokemon_party.actors[i].egg
      @cadre[i].bitmap.draw_text_plus(8,29,80,16,("n."+$pokemon_party.actors[i].level.to_s).to_pokemon_numbers,0,8) if $pokemon_party.actors[i].status == 0
      @cadre[i].bitmap.blt(104, 11, RPG::Cache.pokemon_party_menu("gender#{$pokemon_party.actors[i].gender}.png"), @rect) if $pokemon_party.actors[i].gender != 0
      @cadre[i].bitmap.blt(44, 23, RPG::Cache.pokemon_party_menu("hp_bar.png"), @rect)
      @cadre[i].bitmap.draw_text_plus(24, 29, 80, 16, ($pokemon_party.actors[i].hp.to_s+"/"+$pokemon_party.actors[i].max_hp.to_s).to_pokemon_numbers,2,8)
      draw_hp_bar(i) 
      $pokemon_party.actors[i].toxic? ? status = 1 : status = $pokemon_party.actors[i].status
      @cadre[i].bitmap.blt(16, 33, RPG::Cache.pokemon_party_menu("status#{status}.png"), @rect) if $pokemon_party.actors[i].status != 0
      @cadre[i].bitmap.blt(24, 22, RPG::Cache.pokemon_party_menu("item_hold.png"), @rect) if $pokemon_party.actors[i].item_hold != 0
    end
  end
  
  def draw_hp_bar(i)
    r = $pokemon_party.actors[i].hp.to_f / $pokemon_party.actors[i].max_hp.to_f    
    rect1 = Rect.new(60, 26, r*48.to_i, 1)
    rect2 = Rect.new(60, 27, r*48.to_i, 1)
    if r < 0.1
      color1 = Color.new(255, 156, 156)
      color2 = Color.new(255, 74, 57)
    elsif r >= 0.1 and r < 0.5
      color1 = Color.new(255, 222, 0)
      color2 = Color.new(239, 173, 0)
    else
      color1 = Color.new(99, 255, 99)
      color2 = Color.new(24, 198, 33)
    end
    @cadre[i].bitmap.fill_rect(rect1, color1)
    @cadre[i].bitmap.fill_rect(rect2, color2)
  end 
  
  def text
    @text.bitmap.clear
    if @order
      @text.bitmap.draw_text_plus(9, 168, 150, 16, "Où voulez-vous le mettre ?")
    elsif @mode == 2
      @text.bitmap.draw_text_plus(9, 168, 180, 16, "Quel Pokémon va tenir l'objet ?")
    else
      if @mode == 0
        @text.bitmap.draw_text_plus(9, 168, 150, 16, "Veuillez choisir un Pokémon.")
      elsif @mode == 1
        @text.bitmap.draw_text_plus(18, 153, 100, 16, $pokemon_party.actors[@index].name)
        @text.bitmap.draw_text_plus(18, 169, 100, 16, "sélectionné.")
      end     
    end
  end   
  
  def command
    @command = Yuki::Command.new(152, 192, 0, false, 3, :y) 
    @command.set_bitmap(0, RPG::Cache.pokemon_party_menu("list.png"))
    @command.set_bitmap(1, RPG::Cache.pokemon_party_menu("fleche_retour.png"))
    @command.push_button({:x=>9,:y=>1,:w=>80,:h=>24,:txt=>"RÉSUMÉ",:color=>8,:bitmap_id=>0},method(:resume), @viewport_1)
    @command.push_button({:x=>9,:y=>1,:w=>80,:h=>24,:txt=>"ORDRE",:color=>8,:bitmap_id=>0},method(:ordre), @viewport_1)
    @command.push_button({:x=>9,:y=>1,:w=>80,:h=>24,:txt=>"OBJET",:color=>8,:bitmap_id=>0},method(:objet), @viewport_1) if $pokemon_party.actors[@index].name != "Oeuf"
    @command.push_button({:x=>9,:y=>1,:w=>80,:h=>24,:txt=>"RETOUR",:color=>8,:bitmap_id=>0,:bx=>82,:by=>8, :bmp=>1},method(:retour), @viewport_1)
    @command.draw
    @command.run
    if @command != nil
      @command.last_meth
      @command.dispose
    end
  end  
  
  def resume    
    @btext[1].visible = false
    @btext[0].visible = true        
    @viewport_B.tone.set(0, 0, 0)
    @mode = 0
    text                
    $game_system.se_play($data_system.decision_se)
    @command.dispose
    @command = nil
    Scene_Manager.push(Pokemon_Status)
    Pokemon_Status.init(@index)       
    Graphics.transition if Pokemon_Status::transition?
  end  
  
  def ordre
    @pchoice = @index
    @croix.visible = false
    @order = true
    retour
    draw_cadre
  end
  
  def objet
    print("Ce choix n'est pas disponible.")
  end  
  
  def retour    
    @btext[1].visible = false
    @btext[0].visible = true        
    @viewport_B.tone.set(0, 0, 0)
    @mode = 0
    text
  end  
  
  def refresh_all
    text
    draw_cadre
  end    
  
  def anim_order
    $game_system.se_play($data_system.decision_se)
    i=0
    loop do
      Graphics.update
      i+=1
      @pchoice % 2 == 0 ? @cadre[@pchoice].x -= 8 : @cadre[@pchoice].x += 8       
      @index % 2 == 0 ? @cadre[@index].x -= 8 : @cadre[@index].x += 8      
      if i == 16
        i = 0
        break
      end      
    end    
    $pokemon_party.actors[@pchoice],$pokemon_party.actors[@index] = $pokemon_party.actors[@index],$pokemon_party.actors[@pchoice]
    draw_cadre
    loop do
      Graphics.update
      i+=1
      @pchoice % 2 == 0 ? @cadre[@pchoice].x += 8 : @cadre[@pchoice].x -= 8
      @index % 2 == 0 ? @cadre[@index].x += 8 : @cadre[@index].x -= 8      
      if i == 16        
        break
      end      
    end      
  end  
  
  def finish
    return if @finished
    @viewport_A.dispose
    @viewport_B.dispose
    @viewport_1.dispose   
    @background_A.dispose 
    @background_B.dispose
    @croix.dispose
    @cadre.each do |i| i.dispose end
    @btext.each do |i| i.dispose end
    @text.dispose
    @viewport_A = nil
    @viewport_B = nil
    @viewport_1 = nil   
    @background_A = nil
    @background_B = nil
    @croix = nil
    @cadre = nil
    @btext = nil
    @text = nil
    @command = nil
    @finished = true
  end   
  
  def finished?() @finished end
  def transition?() @transition end
end