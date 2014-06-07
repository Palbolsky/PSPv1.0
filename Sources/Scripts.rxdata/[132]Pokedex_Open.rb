#==============================================================================
# ■ Pokedex_Open
# Pokemon Script Project v1.0 - Palbolsky
# 30/11/2012
#------------------------------------------------------------------------------

module Pokedex_Open
  module_function  
  def viewport(x1=0,y1=0,x2=0,y2=200)
    w = Graphics.width
    h = Graphics.height
    @viewport_A = Viewport.new(x1,y1,w,h)
    @viewport_A.z = 1003
    @viewport_B = Viewport.new(x2,y2,256,192)
    @viewport_B.z = 1003
    @viewportf = Viewport.new(x1,y1,w,h)
    @viewportf.z = 1002
    @y1 = y1
    @y2 = y2
  end
  
  def init
    @finished = false
    @transition = true
    @wait = 0
    @bg = Sprite.new(@viewport_A)
    @bg.bitmap = RPG::Cache.pokemon_pokedex("intro_A.png")
    @bg.z = 1
    @bgA = Sprite.new(@viewport_A)
    @bgA.bitmap = RPG::Cache.pokemon_pokedex("intro_A.png")
    @bgA.z = 1    
    @bgB = Sprite.new(@viewport_B)
    @bgB.bitmap = RPG::Cache.pokemon_pokedex("intro_B#{$pokemon_party.player_sexe}.png")
    @bgB.z = 1
    @viewportf.tone.set(-255, -255, -255)
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
    @wait += 1
    if Input.trigger_plus2?(1)
      if Mouse.is_here?(0, 200, 256, 192)
        open
      end
    end
    if Input.trigger?(Input::C) or @wait == 100
      open
    end
  end
  
  def open 
    $game_system.se_play($data_system.decision_se)
    @bgA.y += (@y2-192-@y1)
    loop do  
      Graphics.update
      @bgA.y += 10
      @bgB.y += 10
      if @bgA.y >= @y2  
        @bgA.y = @y2-@y1
        Graphics.wait(20)
        loop do
          Graphics.update          
          @bgA.zoom_x += 0.02
          @bgA.zoom_y += 0.02
          @bgA.x -= 2
          @bgA.y -= 2            
          @bg.zoom_x += 0.02
          @bg.zoom_y += 0.02
          @bg.x -= 2
          @bg.y -= 2          
          if @bgA.zoom_x == 1.1           
            loop do
              Graphics.update              
              @bgA.opacity -= 25
              @bg.opacity -= 25              
              if @bgA.opacity == 0               
                @bgA.visible = @bg.visible = false                
                Scene_Manager.push(Pokedex_List)
                Pokedex_List.run
                break
              end                         
            end #fin loop 
            break
          end #fin if          
        end #fin loop
        break
      end #fin if
    end # fin loop   
    $pokedex = nil
  end
  
  def finish
    return if @finished
    @viewport_A.dispose
    @viewport_B.dispose
    @viewportf.dispose
    @bg.dispose
    @bgA.dispose   
    @bgB.dispose
    @viewport_A = nil
    @viewport_B = nil 
    @viewportf = nil
    @bg = nil
    @bgA = nil    
    @bgB = nil
    @finished = true
  end
  
  def finished?() @finished end
  def transition?() @transition end
end