#==============================================================================
# ■ Pokemon_Menu
# Pokemon Script Project v1.0 - Palbolsky
# 05/05/2012
# Conversion en module par Nagato Yuki le 26/06/2012 
#------------------------------------------------------------------------------

module Pokemon_Menu
  include Pokemon_S
  TEXTS=["POKÉMON", "POKÉDEX", "SAC", false, "SAUVER", "OPTIONS"] 
  module_function
  def viewport(x1=0,y1=0,x2=0,y2=200)
    @viewport_A = Viewport.new(x1,y1,256,192)
    @viewport_A.z = 1001
    @viewport_B = Viewport.new(x2,y2,256,192)
    @viewport_B.z = 1001
  end
  
  def init
    @finished=false
    @index=0
    @wait = 0
    @lastmethod=nil
    @fond=Sprite.new(@viewport_B)
    @fond.bitmap = RPG::Cache.pokemon_menu("fond.png")
    @fond.z=0
    @background = Sprite.new(@viewport_B)
    @background.bitmap = RPG::Cache.pokemon_menu("background.png") 
    @background.z = 1
    @fleche = Sprite.new(@viewport_A)
    @fleche.bitmap = RPG::Cache.pokemon_menu("fleche.png")
    @fleche.y = 168
    @fleche.z = 1
    @text=Sprite.new(@viewport_B)
    @text.bitmap=Bitmap.new(256,192)
    @text.z=3
    btn=RPG::Cache.pokemon_menu("btn.png")
    icn=RPG::Cache.pokemon_menu("icn.png")
    @sprites=Array.new
    @icons=Array.new
    @methods=[method(:pokemon),method(:pokedex),method(:sac),method(:cdd),method(:save),method(:option)]
    6.times do |i| 
      sp=@sprites[i]=Sprite.new(@viewport_B)
      sp.bitmap=btn
      ic=@icons[i]=Sprite.new(@viewport_B)
      ic.bitmap=icn
      sp.x = 3 + (i&0x01)*128
      sp.y = 24 + i/2*48
      ic.x = sp.x+6
      ic.y = sp.y+4
      sp.src_rect.set(0,0,123,43)
      ic.src_rect.set(0,(i<2 ? i : i+1)*32,32,32)
      sp.z = 2
      ic.z = 2
    end
    @clock = Array.new
    5.times do |i|
      @clock[i] = Sprite.new(@viewport_B)
      @clock[i].bitmap = RPG::Cache.pokemon_menu("clock.png")
      @clock[i].x = 10+8*i
      @clock[i].y = 3
      @clock[i].z = 1
    end
    @clock[2].src_rect.set(50,0,5,7)
    @sm = 0
    set_active(false)
  end
  
  def run   
    @index=@methods.index(@lastmethod).to_i
    set_active(true)
    redraw
    draw_time
    @index+=1 until(@sprites[@index].visible)
    while Scene_Manager.me?(self)
      Graphics.update
      Input.update
      update
    end
    @sprites[@index].src_rect.y=@icons[@index].src_rect.x=0
    @lastmethod=@methods[@index]
    set_active(false)
    Graphics.transition if transition?()
  end
  
  def update    
    @sm != Time.new.min ? draw_time : @sm = Time.new.min
    @wait >= 80 ? @wait = 0 : @wait += 1    
    @clock[2].visible = false if @wait == 40        
    @clock[2].visible = true if @wait == 0             
    @sprites[@index].src_rect.y=86
    @icons[@index].src_rect.x=32
    if Input.trigger?(Input::B)      
      Scene_Manager.pop
      return $game_system.se_play($data_system.cancel_se)
    elsif Input.trigger?(Input::C)      
      @sprites[@index].src_rect.y=43
      if @index!=4
        $game_system.se_play($data_system.decision_se)
        Graphics.wait(10)
        @viewport_B.visible=false
      end
      @methods[@index].call()
      return @viewport_B.visible=true
    end
    
    if Input.trigger_plus2?(1)
      @sprites.each_index do |i|
        if @sprites[i].visible and Mouse.is_in_sprite_plus?(@sprites[i])
          @icons[@index].src_rect.x=@sprites[@index].src_rect.y=0
          @index=i
          @sprites[i].src_rect.y=43
          @icons[i].src_rect.x=32
          if @index!=4
            $game_system.se_play($data_system.decision_se)
            Graphics.wait(10)
            @viewport_B.visible=false
          end
          @methods[i].call()
          return @viewport_B.visible=true
        end
      end
      if Mouse.is_here?(229,373,14,14)
        Scene_Manager.pop
        return $game_system.se_play($data_system.cancel_se)
      end
    end
    
    if Input.repeat?(Input::UP) and @index>1
      if(@sprites[@index-2].visible)
        @sprites[@index].src_rect.y=@icons[@index].src_rect.x=0
        @index-=2
        $game_system.se_play($data_system.cursor_se)
      end
    elsif Input.repeat?(Input::DOWN) and @index<4
      if(@sprites[@index+2].visible)
        @sprites[@index].src_rect.y=@icons[@index].src_rect.x=0
        @index+=2
        $game_system.se_play($data_system.cursor_se)
      end
    elsif Input.trigger?(Input::LEFT) and @index&0x01==1
      if(@sprites[@index-1].visible)
        @sprites[@index].src_rect.y=@icons[@index].src_rect.x=0
        @index-=1
        $game_system.se_play($data_system.cursor_se)
      end
    elsif Input.trigger?(Input::RIGHT) and @index&0x01==0
      if(@sprites[@index+1].visible)
        @sprites[@index].src_rect.y=@icons[@index].src_rect.x=0
        @index+=1
        $game_system.se_play($data_system.cursor_se)
      end
    end
  end
  
  def finish
    @finished=true    
    @lastmethod=nil
    @methods=nil
    @fond.dispose
    @background.dispose
    @fleche.dispose
    @text.bitmap.dispose
    @text.dispose
    @sprites.each do |i| i.dispose end
    @icons.each do |i| i.dispose end
    @sprites.clear
    @icons.clear
    @fond=nil
    @background=nil
    @fleche=nil
    @text=nil
    @sprites=nil
    @icons=nil
  end
  def finished?() return @finished end
    
  def redraw
    @text.bitmap.clear
    TEXTS[3]=$pokemon_party.trainer_name.to_s
    unless $pokemon_party.size>0
      @sprites[0].visible=false
      @icons[0].visible=false
    else
      @text.bitmap.draw_text_plus(@sprites[0].x+48,@sprites[0].y+6,75,34,TEXTS[0],0,9)
    end
    unless $pokemon_party.have_dex
      @sprites[1].visible=false
      @icons[1].visible=false
    else
      @text.bitmap.draw_text_plus(@sprites[1].x+48,@sprites[1].y+6,75,34,TEXTS[1],0,9)
    end
    unless @sprites[0].visible or @sprites[1].visible
      2.step(5) do |i|
        @sprites[i].y = -24 + i/2*48
        @icons[i].y = @sprites[i].y+4
        @text.bitmap.draw_text_plus(@sprites[i].x+48,@sprites[i].y+6,75,34,TEXTS[i],0,9)
      end
    else
      2.step(5) do |i|
        @sprites[i].y = 24 + i/2*48
        @icons[i].y = @sprites[i].y+4
        @text.bitmap.draw_text_plus(@sprites[i].x+48,@sprites[i].y+6,75,34,TEXTS[i],0,9)
      end
    end
    @icons[2].src_rect.set(0,32*(2+$pokemon_party.player_sexe),32,32)
    @icons[1].src_rect.set(0,32*(1+$pokemon_party.player_sexe*6),32,32)
  end
  
  def draw_time
    time = Time.new   
    h1 = (time.hour/10).to_i
    h2 = time.hour - 10*h1  
    m1 = (time.min/10).to_i
    m2 = time.min - 10*m1 
    h1 == 0 ? @clock[0].visible = false : @clock[0].visible = true
    @clock[0].src_rect.set(5*h1,0,5,7)
    @clock[1].src_rect.set(5*h2,0,5,7)
    @clock[3].src_rect.set(5*m1,0,5,7)
    @clock[4].src_rect.set(5*m2,0,5,7)
  end  
  
  def set_active(bool)
    if bool
      @fond.visible=false
      @background.visible=true
      @fleche.visible=true
      @text.visible=true
      @sprites.each do |i| i.visible=true end
      @icons.each do |i| i.visible=true end
      @clock.each do |i| i.visible=true end
    else
      @fond.visible=true
      @background.visible=false
      @fleche.visible=false
      @text.visible=false
      @sprites.each do |i| i.visible=false end
      @icons.each do |i| i.visible=false end
      @clock.each do |i| i.visible=false end
    end
  end
  
  def pokemon    
    Scene_Manager.push(Pokemon_Party_Menu)
    Pokemon_Party_Menu.init
    Graphics.transition if Pokemon_Party_Menu::transition?
  end
  
  def pokedex   
    Scene_Manager.push(Pokedex_Open)
    Pokedex_Open.run
    Graphics.transition if Pokedex_Open::transition?
  end
  
  def sac
    Scene_Manager.push(Pokemon_Bag)
    Pokemon_Bag.run
    Graphics.transition if Pokemon_Bag::transition?
  end
  
  def cdd    
    Scene_Manager.push(Dresseur_Card)
    Dresseur_Card.run
    Graphics.transition if Dresseur_Card::transition?
  end
  
  def save
    return $game_system.se_play($data_system.buzzer_se) if $game_system.save_disabled
    $game_system.se_play($data_system.decision_se)
    Graphics.wait(10)
    @viewport_B.visible=false
    Scene_Manager.push(Pokemon_Save)
    Pokemon_Save.run
  end
  
  def option    
    Scene_Manager.push(Pokemon_Options)
    Pokemon_Options.run
    Graphics.transition if Pokemon_Options::transition?
  end
  
  def set_transition(b=true) @transition=b end
  def transition?()
    @transition,b=nil,@transition
    return b
  end
end