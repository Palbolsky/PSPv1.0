#==============================================================================
# ■ Scene_Battle : Simple (1v1)
# Pokemon Script Project v1.0 - Palbolsky
# 01/11/2012
#------------------------------------------------------------------------------

module Pokemon_Battle     
  module Scene_Simple
    CURSEUR_X = [1,0,88,176]
    CURSEUR_Y = [24,144,152,144]
    SKILL_X = [1,129,1,129,176]
    SKILL_Y = [31,31,79,79,149] 
    module_function    
    def viewport(x1=0,y1=0,x2=0,y2=200)
      @viewport_A = Viewport.new(x1,y1,256,192)
      @viewport_A.z = 1001
      @viewport_B = Viewport.new(x2,y2,256,192)
      @viewport_B.z = 1001
    end
    
    def self.init(actors,enemy,sprite,name)
      @finished = false
      @transition = true   
      @actors = actors
      @enemy = enemy
      @sprite = sprite
      @trainer_name = name
      @index = 0
      @mode = -1
      @battleback = Sprite.new(@viewport_A)
      if $game_map.battleback_name == ""
        print("Attention, battleback des combats non spécifié.") if $DEBUG
        $game_map.battleback_name = "battle1"
      end
      if $game_switches[8] #Intérieur
         @battleback.bitmap = RPG::Cache.battleback($game_map.battleback_name)
      else
         @battleback.bitmap = RPG::Cache.battleback($game_map.battleback_name)#+"_"+Yuki::TJNS::def_moment.to_s+".png")
      end     
      @battleback.z = 1
      @dummy = Sprite.new(@viewport_A)
      @dummy.bitmap = RPG::Cache.scene_battle("dummy.png")
      @dummy.y = 147
      @dummy.z = 3    
      @background = Sprite.new(@viewport_B)
      @background.bitmap = RPG::Cache.scene_battle("background.png")
      @background.z = 1
      #Sprites actors & enemy
      @sp_actors = Sprite.new(@viewport_A)
      @sp_actors.bitmap = RPG::Cache.scene_battle("back_#{$pokemon_party.player_sexe}.png")
      @sp_actors.x = 40
      @sp_actors.y = 84
      @sp_actors.z = 2
      @sp_enemy = Sprite.new(@viewport_A)
      @sp_enemy.bitmap = RPG::Cache.battler(@sprite,0)
      @sp_enemy.x = 160
      @sp_enemy.y = 25
      @sp_enemy.z = 2
      @s_actors = RPG::Cache.scene_battle("statut_actors.png")
      @s_enemy = RPG::Cache.scene_battle("statut_enemy.png")
      #Barre de statut
      @statut_actors = Sprite.new(@viewport_A)
      @statut_actors.bitmap = Bitmap.new(128,27)
      @statut_actors.x = 128
      @statut_actors.y = 113     
      @statut_actors.z = 2
      @statut_enemy = Sprite.new(@viewport_A)      
      @statut_enemy.bitmap = Bitmap.new(124,19)      
      @statut_enemy.y = 33
      @statut_enemy.z = 2      
      #Curseur
      @curseur = Array.new
      4.times do |i|
        @curseur[i] = Sprite.new(@viewport_B)        
        @curseur[i].x = CURSEUR_X[i]
        @curseur[i].y = CURSEUR_Y[i]
        @curseur[i].z = 2
        @curseur[i].visible = false
        next if i == 3
        @curseur[i].bitmap = RPG::Cache.scene_battle("curseur_#{i}.png")           
      end
      @curseur[3].bitmap = RPG::Cache.scene_battle("curseur_1.png")  
      #Attaque
      @skill = Array.new
      4.times do |i|
        @skill[i] = Sprite.new(@viewport_B)
        @skill[i].bitmap = Bitmap.new(126,48)
        @skill[i].x = SKILL_X[i]
        @skill[i].y = SKILL_Y[i]
        @skill[i].z = 2
        @skill[i].visible = false
      end
      @skill_c = Array.new
      5.times do |i|
        @skill_c[i] = Sprite.new(@viewport_B)       
        @skill_c[i].x = SKILL_X[i]
        @skill_c[i].y = SKILL_Y[i] - 5
        @skill_c[i].z = 3
        @skill_c[i].visible = false
        next if i == 4
        @skill_c[i].bitmap = RPG::Cache.scene_battle("skill_c.png")
      end      
      @skill_c[4].bitmap = RPG::Cache.scene_battle("curseur_1.png")
      #Texte
      @text = Sprite.new(@viewport_A)
      @text.bitmap = Bitmap.new(256, 192)
      @text.z = 4         
      #Heure
      @wait = 0
      @sm = 0
      @clock = Array.new
      5.times do |i|
        @clock[i] = Sprite.new(@viewport_B)
        @clock[i].bitmap = RPG::Cache.pokemon_menu("clock.png")
        @clock[i].x = 10+8*i
        @clock[i].y = 3
        @clock[i].z = 1
      end
      @clock[2].src_rect.set(50,0,5,7)
      time_update
      pre_animation  # Dégagement des sprites pour mettre les pokémon     
      run
    end
    
    def pre_animation      
      draw_text("Un combat est lancé par","#{@trainer_name[0].to_s} !")  
      Graphics.wait(30)
      draw_text("Un #{@enemy.actors[0].name} est envoyé par","#{@trainer_name[0].to_s} !")
      #Animation ennemi à coder ici
      @sp_enemy.x = 145
      @sp_enemy.y = 30      
      @sp_enemy.bitmap = @enemy.actors[0].battler_face 
      draw_battle_statut(false,true)
      Graphics.wait(30)
      draw_text("#{@actors[0].name} ! Go !")
      #Animation actors à coder ici
      @sp_actors.x = 10
      @sp_actors.y = 110
      @sp_actors.zoom_x = @sp_actors.zoom_y = 0.666
      @sp_actors.bitmap = @actors[0].battler_back     
      draw_battle_statut(true,true)
      Graphics.wait(30)           
      battle_choice
    end
    
    def self.run            
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
      time_update
      if @mode == 0 #Battle_choice
        if Input.trigger_plus2?(1)
          if Mouse.is_here?(8,230,242,108) # attaque
            @index = 0
            draw_curseur(false)
            @mode = 1
            draw_skill
            draw_skill_c
            return $game_system.se_play($data_system.decision_se) 
          end
          if Mouse.is_here?(8,345,65,42) # sac
            @index = 1
            draw_curseur
            print("sac")
            #appel du sac
            return $game_system.se_play($data_system.decision_se) 
          end
          if Mouse.is_here?(96,358,64,31) # fuite
            @index = 2
            draw_curseur
            print("fuite")
            # fuite
            return $game_system.se_play($data_system.decision_se) 
          end
          if Mouse.is_here?(184,345,65,42) #pokemon
            @index = 3
            draw_curseur
            print("equipe pokemon")
            # appel équipe pokémon
            return $game_system.se_play($data_system.decision_se) 
          end          
        end        
        if Input.trigger?(Input::UP) and (@index == 1 or @index == 3)
          @index = 0
          draw_curseur
          return $game_system.se_play($data_system.cursor_se)
        end
        if Input.trigger?(Input::DOWN) and @index == 0
          @index = 1
          draw_curseur
          return $game_system.se_play($data_system.cursor_se)
        end
        if Input.trigger?(Input::LEFT) and @index > 1
          @index -= 1
          draw_curseur
          return $game_system.se_play($data_system.cursor_se)
        end
        if Input.trigger?(Input::RIGHT) and @index < 3
          @index += 1
          draw_curseur
          return $game_system.se_play($data_system.cursor_se)
        end        
        if Input.trigger?(Input::C)          
          case @index
          when 0
            @mode = 1            
            draw_curseur(false)
            draw_skill
            draw_skill_c
          when 1
            print("sac")
          when 2
            print("fuite") 
          when 3
            print("equipe pokemon")  
          end       
          return $game_system.se_play($data_system.decision_se) 
        end          
      elsif @mode == 1 #skill_choice
        if Input.trigger_plus2?(1)
          4.times do |i|
            if Mouse.is_here?(@skill[i].x,200+@skill[i].y,126,48)
              @index = i
              draw_skill_c
              return $game_system.se_play($data_system.decision_se) 
            end
          end
          if Mouse.is_here?(184,345,65,42)
            @index = 0
            battle_choice            
            draw_skill(false)
            draw_skill_c(false)
            return $game_system.se_play($data_system.cancel_se)
          end
        end         
        if Input.trigger?(Input::B) 
          @index = 0
          battle_choice                   
          draw_skill(false)
          draw_skill_c(false)
          return $game_system.se_play($data_system.cancel_se)
        end
        if Input.trigger?(Input::DOWN)
          if @index < 2
            @index += 2
          elsif @index != 4
            @index_tmp = @index
            @index = 4
          end
          draw_skill_c          
          return $game_system.se_play($data_system.cursor_se)
        end
        if Input.trigger?(Input::UP)
          if @index == 4
            @index = @index_tmp
          elsif @index > 1
            @index -= 2
          end          
          draw_skill_c          
          return $game_system.se_play($data_system.cursor_se)
        end
        if Input.trigger?(Input::LEFT) and (@index == 1 or @index == 3)
          @index -= 1
          draw_skill_c
          return $game_system.se_play($data_system.cursor_se)
        end
        if Input.trigger?(Input::RIGHT) and (@index == 0 or @index == 2)
          @index += 1
          draw_skill_c
          return $game_system.se_play($data_system.cursor_se)
        end
        if Input.trigger?(Input::C)
          if @index == 4            
            @index = 0
            battle_choice
            draw_skill(false)
            draw_skill_c(false)
            return $game_system.se_play($data_system.cancel_se)
          elsif @index < @actors[0].skills_learn.size
            Pokemon_Battle::Core.round_attack(@actors[0].skills_learn[@index])                       
            return $game_system.se_play($data_system.decision_se) 
          end
        end        
      end
    end     
    
    def time_update
      @sm != Time.new.min ? draw_time : @sm = Time.new.min
      @wait >= 80 ? @wait = 0 : @wait += 1    
      @clock[2].visible = false if @wait == 40        
      @clock[2].visible = true if @wait == 0   
      @wait += 1
    end    
    
    def battle_choice
      draw_text("Que doit faire #{@actors[0].name} ?")
      @background.bitmap = RPG::Cache.scene_battle("battle_choice.png")
      @mode = 0
      draw_curseur
    end    
    
    def draw_curseur(v=true)     
      4.times do |i|
        @curseur[i].visible = false
      end
      @curseur[@index].visible = true if v
    end 
    
    def draw_skill_c(v=true)
      5.times do |i|
        @skill_c[i].visible = false
      end
      @skill_c[@index].visible = true if v
    end
    
    def draw_skill(v=true)
      @background.bitmap = RPG::Cache.scene_battle("back_skill.png") if v
      skills = @actors[0].skills_learn     
      pskill = RPG::Cache.scene_battle("dummy_skill.png")
      4.times do |i|
        next if i > (skills.size-1)        
        type = PokemonData::Skill.load(skills[i]).type
        name = PokemonData::Skill.load(skills[i]).name
        @skill[i].bitmap.blt(0,0,pskill,Rect.new(0,48*(type-1),126,48))
        @skill[i].bitmap.draw_text_plus(32,9,64,16,name,1,8)
        @skill[i].bitmap.blt(15, 25, RPG::Cache.pokemon_status("T#{type}.png"), Rect.new(0, 0, 32, 14))
        @skill[i].bitmap.draw_text_plus(50,25,64,16,"PP",0,8)
        @skill[i].bitmap.draw_text_plus(70,25,34,16,"#{@actors[0].skills[i*3+1]}/#{@actors[0].skills[i*3+2]}",2,8)
        @skill[i].visible = v
      end
    end    
    
    def draw_battle_statut(v1=true,v2=true)
      @statut_actors.visible = v1
      @statut_enemy.visible = v2
      @statut_actors.bitmap.blt(0, 0, @s_actors, Rect.new(0,0,128,27))
      @statut_enemy.bitmap.blt(0, 0, @s_enemy, Rect.new(0,0,124,19))     
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
    
    def draw_text(text1="",text2="")
      @text.bitmap.clear
      @text.bitmap.draw_text_plus(8,152,240,16,text1,0,8)
      @text.bitmap.draw_text_plus(8,168,240,16,text2,0,8)
    end
    
    def finish
      return if @finished
      @viewport_A.dispose
      @viewport_B.dispose
      @battleback.dispose
      @dummy.dispose
      @background.dispose
      @sp_actors.dispose
      @sp_enemy.dispose
      @statut_actors.dispose
      @statut_enemy.dispose      
      @curseur.each do |i| i.dispose end
      @skill.each do |i| i.dispose end
      @text.dispose
      @clock.each do |i| i.dispose end
      @viewport_A = nil
      @viewport_B = nil
      @battleback = nil
      @dummy = nil
      @background = nil
      @sp_actors = nil
      @sp_enemy = nil
      @statut_actors = nil
      @statut_enemy = nil
      @curseur = nil
      @skill = nil
      @text = nil
      @clock = nil
      @finished = true
    end   
  
    def finished?() @finished end
    def transition?() @transition end    
  end
end