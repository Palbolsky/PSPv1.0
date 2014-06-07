#==============================================================================
# ■ Dresseur_Card
# Pokemon Script Project v1.0 - Palbolsky
# 01/07/2012
#------------------------------------------------------------------------------

module Dresseur_Card  
  BADGE_X = [9, 42, 68, 100, 135, 165, 196, 224]    
  MOIS=[nil,"jan.","fév.","mars","avr.","mai","juin","jui.","août","sep.","oct.","nov.","déc."]  
  module_function    
  def viewport(x1=0,y1=0,x2=0,y2=200)
    @viewport1 = Viewport.new(x1,y1,256,192)
    @viewport1.z = 1002
    @viewport = Viewport.new(x2,y2,256,192)
    @viewport.z = 1002
  end
    
  def init          
    @finished = false
    @transition = true
    temp = $pokemon_party.get_game_time.to_i
    temp -= (temp % 60)
    temp /= 60
    @min = temp % 60
    @heure = temp / 60
    @heure = 999 if @heure > 999
    @mode = 0
    @wait = 0    
    @bg1 = Sprite.new(@viewport1)
    @bg1.bitmap = RPG::Cache.dresseur_card("background.png")
    @bg = Sprite.new(@viewport)
    @bg.bitmap = RPG::Cache.dresseur_card("background.png")
    @bg1.x = @bg.x = -16
    @bg1.y = @bg.y = -16
    @bg1.z = @bg.z = 0
    @barre = Array.new
    2.times do |i|      
      @barre[i] = Sprite.new(@viewport)
      @barre[i].bitmap = RPG::Cache.dresseur_card("barre#{i+1}.png")
      @barre[i].y = 168
      @barre[i].z = 1
    end    
    @barre[0].visible = true
    @barre[1].visible = false
    @tcard = Sprite.new(@viewport)
    @tcard.bitmap = RPG::Cache.dresseur_card("tcard.png")       
    @tcard.z = 1    
    @tcard.ox = @tcard.x = @tcard.bitmap.width / 2
    @perso = Sprite.new(@viewport)
    @perso.bitmap = RPG::Cache.dresseur_card("perso#{$pokemon_party.player_sexe}.png")
    @perso.x = 168
    @perso.y = 21
    @perso.z = 2  
    @bcard = Sprite.new(@viewport)
    @bcard.bitmap = RPG::Cache.dresseur_card("backcard.png")   
    @bcard.ox = @bcard.x = @bcard.bitmap.width / 2
    @bcard.z = 1
    @bcard.zoom_x = 0
    @bcard.visible = false
    @text = Sprite.new(@viewport)
    @text.bitmap = Bitmap.new(256,192)
    @text.ox = @text.x = @text.bitmap.width / 2
    @text.z = 3 
    @text1 = Sprite.new(@viewport1)
    @text1.bitmap = Bitmap.new(256,192)
    @text1.z = 2
    @btext = Sprite.new(@viewport1)
    @btext.bitmap = RPG::Cache.dresseur_card("btext.png")  
    @btext.x = 10
    @btext.y = 74
    @btext.z = 1
    @btext.visible = false
    @fbadge = Sprite.new(@viewport)
    @fbadge.bitmap = RPG::Cache.dresseur_card("fond_badge.png")    
    @fbadge.y = 88
    @fbadge.z = 2    
    @fbadge.visible = false
    @badges = Array.new
    8.times do |i|
      @badges[i] = Sprite.new(@viewport)
      @badges[i].bitmap = RPG::Cache.dresseur_card("badge#{i+1}.png")      
      @badges[i].x = BADGE_X[i]
      @badges[i].y = 99     
      @badges[i].z = 3      
      @badges[i].visible = false
    end  
    @badge_time = Array.new
    8.times do |i|             
      @badge_time[i] = "#{$pokemon_party.badge_info[i].day} #{MOIS[$pokemon_party.badge_info[i].month]} #{$pokemon_party.badge_info[i].year}" if $pokemon_party.badge_info[i]
    end    
    @badge_info = Array.new    
    @badge_info[0] = ["BADGE TRIPLE :", "Obtenu le #{@badge_time[0]}.", "Permet de se faire obéir par les", "Pokémon jusqu'au niveau 20."]
    @badge_info[1] = ["BADGE BASIQUE :", "Obtenu le #{@badge_time[1]}.", "Permet de se faire obéir par les", "Pokémon jusqu'au niveau 30."]
    @badge_info[2] = ["BADGE ÉLYTRE :", "Obtenu le #{@badge_time[2]}.", "Permet de se faire obéir par les", "Pokémon jusqu'au niveau 40."]
    @badge_info[3] = ["BADGE VOLT :", "Obtenu le #{@badge_time[3]}.", "Permet de se faire obéir par les", "Pokémon jusqu'au niveau 50."]
    @badge_info[4] = ["BADGE SISMIQUE :", "Obtenu le #{@badge_time[4]}.", "Permet de se faire obéir par les", "Pokémon jusqu'au niveau 60."]
    @badge_info[5] = ["BADGE JET :", "Obtenu le #{@badge_time[5]}.", "Permet de se faire obéir par les", "Pokémon jusqu'au niveau 70."]
    @badge_info[6] = ["BADGE STALACTITE :", "Obtenu le #{@badge_time[6]}.", "Permet de se faire obéir par les", "Pokémon jusqu'au niveau 80."]
    @badge_info[7] = ["BADGE MYTHE :", "Obtenu le #{@badge_time[7]}.", "Permet de se faire obéir", "de n'importe quel Pokémon."]    
    text_face
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
    if Input.trigger?(Input::B)
      Scene_Manager.pop     
      return $game_system.se_play($data_system.cancel_se)                    
    end
    if Input.trigger?(Input::C) and @mode != 2
      transition(0)   
      return $game_system.se_play($data_system.decision_se)
    end
    if Input.trigger?(Input::LEFT) or Input.trigger?(Input::RIGHT)
      $game_system.se_play($data_system.decision_se)
      return transition(1)
    end    
    if Input.trigger_plus2?(1)
      if Mouse.is_here?(209,373,14,14)        
        Scene_Manager.pop(2)
        @transition=false
        Pokemon_Menu::set_transition
        return $game_system.se_play($data_system.cancel_se)        
      end
      if Mouse.is_here?(233,373,14,14)
        Scene_Manager.pop
        return $game_system.se_play($data_system.cancel_se)        
      end              
      if Mouse.is_here?(102,370,60,20) and @mode != 1  
        $game_system.se_play($data_system.decision_se)             
        return transition(1)     
      end
      if Mouse.is_here?(6,370,20,20) and @mode != 2   
        transition(0)
        return $game_system.se_play($data_system.decision_se)  
      end
      @badges.each_index do |i|
        if @badges[i].visible and Mouse.is_in_sprite_plus?(@badges[i])         
          @btext.visible = true
          bm = @text1.bitmap
          bm.clear
          4.times do |j|
            bm.draw_text_plus(16, 82+(j*16), 200, 16, @badge_info[i][j], 0)
          end          
        end
      end
    end    
  end
  
  def text_face    
    bm=@text.bitmap
    bm.draw_text_plus(24, 32, 80, 16, "NOM :", 0, 11)
    bm.draw_text_plus(72, 32, 80, 16, $pokemon_party.trainer_name.to_s, 2, 11)
    bm.draw_text_plus(72, 48, 80, 16, "Dresseur", 2, 11)
    bm.draw_text_plus(24, 64, 80, 16, "CARACTÈRE", 0, 11)
    bm.draw_text_plus(72, 64, 80, 16, "Hardi", 2, 11)
    bm.draw_text_plus(24, 104, 80, 16, "ARGENT", 0, 11)
    bm.draw_text_plus(152, 104, 80, 16, $game_party.gold.to_s + " $", 2, 11)
  end  
  
  def text_back   
    bm = @text.bitmap
    bm.draw_text_plus(16, 16, 80, 16, "N°ID :", 0, 11)
    bm.draw_text_plus(82, 16, 80, 16, $pokemon_party.trainer_id, 0, 11)
    bm.draw_text_plus(16, 32, 80, 16, "TEMPS DE JEU", 0, 11)  
    bm.draw_text_plus(152, 34, 80, 16, sprintf("%02d:%02d", @heure, @min), 2, 11)
    bm.draw_text_plus(16, 48, 120, 16, "DEBUT DE L'AVENTURE", 0, 11)  
    bm.draw_text_plus(132, 60, 100, 16, "#{$pokemon_party.begin_date.day} #{MOIS[$pokemon_party.begin_date.month]} #{$pokemon_party.begin_date.year}", 2, 11)      
  end  
  
  def transition(id=0)
    if id == 0
      case @mode
      when 0           
        @tcard.visible = @perso.visible = @barre[0].visible = false
        @text.bitmap.clear      
        @fbadge.visible = true
        8.times do |i|
          @badges[i].visible = true if $pokemon_party.badge_info[i]      
        end    
        @mode = 1
      when 1
        @fbadge.visible = false
        @btext.visible = false
        8.times do |i|
          @badges[i].visible = false
        end    
        @text1.bitmap.clear      
        @tcard.visible = @perso.visible = @barre[0].visible = true
        text_face
        @mode = 0
      end  
    else
      case @mode
      when 0
        loop do
          animation
          Graphics.update
          @tcard.zoom_x = @perso.zoom_x = @text.zoom_x -= 0.05
          @perso.x -= 2
          if @text.zoom_x < 0.01
            @barre[0].visible = false
            @tcard.visible = false 
            @text.bitmap.clear 
            @mode = 2
            @barre[1].visible = true
            @bcard.visible = true     
            text_back
            loop do
              animation
              Graphics.update
              @bcard.zoom_x = @text.zoom_x += 0.05              
              if @bcard.zoom_x >= 1
                break
              end              
            end  
            break
          end         
        end         
      else  
        loop do
          animation
          Graphics.update
          @bcard.zoom_x = @text.zoom_x -= 0.05          
          if @text.zoom_x < 0.01
            @barre[1].visible = false
            @bcard.visible = false 
            @text.bitmap.clear     
            @mode = 0  
            @barre[0].visible = true
            @tcard.visible = true        
            text_face
            loop do
              animation
              Graphics.update
              @tcard.zoom_x = @perso.zoom_x = @text.zoom_x += 0.05
              @perso.x += 2
              if @tcard.zoom_x >= 1
                break
              end              
            end  
            break
          end         
        end                
      end      
    end    
  end
  
  def animation
    @bg.x == 0 ? (@bg.x -= 16 and @bg.y -= 8) : (@bg.x += 1 and 
    @wait == 1 ? @wait = 0 : (@wait += 1 and @bg.y += 1))   
    @bg1.x = @bg.x
    @bg1.y = @bg.y
  end  
  
  def finish        
    return if @finished
    @viewport.dispose   
    @viewport1.dispose   
    @bg.dispose
    @bg1.dispose
    @barre.each do |i| i.dispose end
    @tcard.dispose
    @bcard.dispose
    @perso.dispose
    @fbadge.dispose
    @badges.each do |i| i.dispose end
    @btext.dispose
    @text.bitmap.dispose
    @text.dispose
    @text1.bitmap.dispose
    @text1.dispose
    @viewport = nil
    @viewport1 = nil    
    @bg = nil    
    @bg1 = nil
    @barre = nil
    @tcard = nil  
    @bcard = nil
    @perso = nil    
    @fbadge = nil
    @btext = nil
    @text = nil
    @text1 = nil
    @badges.clear
    @badge_info.clear
    @badge_time.clear
    @finished = true
  end
  
  def finished?() @finished end  
  def transition?() @transition end
end  