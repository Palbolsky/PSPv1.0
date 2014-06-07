#==============================================================================
# ■ Pokemon_Status
# Pokemon Script Project v1.0 - Palbolsky
# 09/07/2012
#------------------------------------------------------------------------------

module Pokemon_Status
  MOIS=[nil,"jan.","fév.","mars","avr.","mai","juin","jui.","août","sep.","oct.","nov.","déc."]  
  LIST_1=["N° POKÉDEX", "NOM", "TYPE", "D.O", "N° ID", "POINT EXP.", nil, "NIVEAU SUIVANT"]
  LIST_2=["ATTAQUE", "DÉFENSE", "ATQ SPÉ", "DÉF SPÉ", "VITESSE"]  
  module_function  
  def viewport(x1=0,y1=0,x2=0,y2=200)
    @viewport_A = Viewport.new(x1,y1,256,192)
    @viewport_A.z = 1004
    @viewport_B = Viewport.new(x2,y2,256,192)
    @viewport_B.z = 1004
  end
  
  def init(index=0)
    @finished = false
    @transition = true
    @index = index    
    @page = 0
    @mode = 0    
    @wait = 0
    @background_A = Sprite.new(@viewport_A)
    @background_A.bitmap = RPG::Cache.pokemon_status("background.png")
    @background_B = Sprite.new(@viewport_B)
    @background_B.bitmap = RPG::Cache.pokemon_status("background.png")
    @background_A.z = @background_B.z = 0  
    @spr_A = Array.new
    @spr_B = Array.new
    4.times do |i|
      @spr_A[i] = Sprite.new(@viewport_A)
      @spr_A[i].bitmap = RPG::Cache.pokemon_status("#{i}A.png")
      @spr_A[i].z = 1      
      @spr_A[i].visible = false
      next if i > 2
      @spr_B[i] = Sprite.new(@viewport_B)      
      @spr_B[i].bitmap = RPG::Cache.pokemon_status("#{i}B.png") 
      @spr_B[i].z = 1
      @spr_B[i].visible = false
    end
    @spr_A[0].visible = @spr_B[0].visible = true
    @info_p = Array.new
    4.times do |i|
      @info_p[i] = Sprite.new(@viewport_A)
      @info_p[i].bitmap = RPG::Cache.pokemon_status("infop#{i}.png")
      @info_p[i].y = 9
      @info_p[i].z = 2
      @info_p[i].visible = false      
    end
    @info_p[0].visible = true
    @barre = Sprite.new(@viewport_B)
    @barre.bitmap = RPG::Cache.pokemon_status("barre.png")
    @barre.y = 168
    @barre.z = 1
    @icons = Sprite.new(@viewport_B)
    @icons.bitmap = RPG::Cache.pokemon_status("icons.png")
    @icons.x = 149
    @icons.y = 171
    @icons.z = 2
    @btn = Sprite.new(@viewport_B)
    @btn.bitmap = RPG::Cache.pokemon_status("boutons.png")
    @btn.src_rect.set(0,0,114,20) 
    @btn.x = 3
    @btn.y = 170
    @btn.z = 1
    @battler = Sprite.new(@viewport_B)
    @battler.bitmap = $pokemon_party.actors[@index].battler_face
    @battler.x = 156
    @battler.y = 56
    @battler.z = 2
    @skill = Array.new    
    4.times do |i|
      @skill[i] = Sprite.new(@viewport_B)
      @skill[i].bitmap = RPG::Cache.pokemon_status("skill_list.png")
      @skill[i].src_rect.set(0, 33*i, 136, 33)      
      @skill[i].x = 8
      @skill[i].y = 15+33*i
      @skill[i].z = 2
      @skill[i].visible = false
    end    
    @text_A = Sprite.new(@viewport_A)
    @text_A.bitmap = Bitmap.new(256, 192)
    @text_A.z = 2
    @text_B = Sprite.new(@viewport_B)
    @text_B.bitmap = Bitmap.new(256, 192)
    @text_B.z = 2
    cry_pokemon($pokemon_party.actors[@index].id)
    refresh_all
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
      if @mode == 0
        if Mouse.is_here?(149,371,14,17) #Fleche haut
          @index == 0 ? @index = 0 : (@index -= 1 and cry_pokemon($pokemon_party.actors[@index].id))
          refresh_all
          return 
        end
        if Mouse.is_here?(173,372,14,17) #Fleche Bas
          @index == ($pokemon_party.size-1) ? @index = ($pokemon_party.size-1) : (@index += 1 and cry_pokemon($pokemon_party.actors[@index].id))
          refresh_all          
          return
        end
        if Mouse.is_here?(205,373,14,14) #Croix
          Scene_Manager.map
          @transition = false
          Pokemon_Menu::set_transition          
          return $game_system.se_play($data_system.cancel_se)
        end
        if not $pokemon_party.actors[@index].egg
          3.times do |i| #Boutons page
            if Mouse.is_here?(3+38*i,370,38,20)
              @page = i
              refresh_all
              $game_system.se_play($data_system.cursor_se)
            end
          end   
          if @battler.visible and Mouse.is_in_sprite_plus?(@battler)
            @battler.bitmap == $pokemon_party.actors[@index].battler_face ? @battler.bitmap = $pokemon_party.actors[@index].battler_back : @battler.bitmap = $pokemon_party.actors[@index].battler_face
          end 
        end        
      end      
      if Mouse.is_here?(237,373,14,14) #Retour        
        if @mode == 0
          Scene_Manager.pop
        elsif @mode == 1
          @mode = 0
          refresh_all
          draw_skill_select  
        end        
        return $game_system.se_play($data_system.cancel_se)
      end
      $pokemon_party.actors[@index].skills_learn.size.times do |i|
        if @skill[i].visible and Mouse.is_in_sprite_plus?(@skill[i])
          @skill_index = i
          @mode = 1
          page_update
          draw_skill_select
          return $game_system.se_play($data_system.decision_se)
        end
      end
    end
    if Input.trigger?(Input::B)
      if @mode == 0
        Scene_Manager.pop      
      elsif @mode == 1        
        @mode = 0    
        refresh_all
        draw_skill_select
      end
      return $game_system.se_play($data_system.cancel_se)
    end
    if @mode == 0
      if not $pokemon_party.actors[@index].egg
        if Input.repeat?(Input::LEFT)
          @page == 0 ? @page = 0 : (@page -= 1 and $game_system.se_play($data_system.cursor_se))
          refresh_all
          return 
        end 
        if Input.repeat?(Input::RIGHT)
          @page == 2 ? @page = 2 : (@page += 1 and $game_system.se_play($data_system.cursor_se))
          refresh_all
          return
        end 
      end
      if Input.repeat?(Input::UP)
        @index == 0 ? @index = 0 : (@index -= 1 and cry_pokemon($pokemon_party.actors[@index].id))
        refresh_all
        return 
      end
      if Input.repeat?(Input::DOWN)
        @index == ($pokemon_party.size-1) ? @index = ($pokemon_party.size-1) : (@index += 1 and cry_pokemon($pokemon_party.actors[@index].id))
        refresh_all
        return
      end
      if Input.trigger?(Input::C) and @page == 1 and $pokemon_party.actors[@index].skills_learn.size != 0
        @skill_index = 0
        @mode = 1
        refresh_all
        draw_skill_select
        return $game_system.se_play($data_system.decision_se)
      end 
    elsif @mode == 1
      if Input.repeat?(Input::UP)
        @skill_index == 0 ? @skill_index = 0 : (@skill_index -= 1 and $game_system.se_play($data_system.cursor_se))
        draw_skill_select
        return
      end
      if Input.repeat?(Input::DOWN)
        @skill_index == $pokemon_party.actors[@index].skills_learn.size-1 ? @skill_index = $pokemon_party.actors[@index].skills_learn.size-1 : (@skill_index += 1 and $game_system.se_play($data_system.cursor_se))
        draw_skill_select
        return
      end      
    end
  end
  
  def page_update
    $pokemon_party.actors[@index].egg ? (@page = 0 and @btn.src_rect.set(0, @page*20, 38, 20)) : @btn.src_rect.set(0, @page*20, 114, 20)
    4.times do |i|      
      @spr_A[i].visible = @info_p[i].visible = false
      next if i > 2
      @spr_B[i].visible = false         
    end
    if @mode == 1
      @spr_A[3].visible = @info_p[3].visible = true
      @btn.visible = @icons.visible = false
    else
      @spr_A[@page].visible = @info_p[@page].visible = true
      @btn.visible = @icons.visible = true
    end
    if $pokemon_party.actors[@index].egg
      @spr_B[2].visible = true
    else
      @page > 1 ? @spr_B[1].visible = true : @spr_B[@page].visible = true 
    end
    4.times do |i|
      @page == 1 ? @skill[i].visible = true : @skill[i].visible = false
    end    
  end  
  
  def refresh
    @text_A.bitmap.clear    
    @text_B.bitmap.clear 
    @text_B.bitmap.draw_text_plus(177, 1, 100, 16, $pokemon_party.actors[@index].name)    
    @text_B.bitmap.draw_text_plus(162, 137, 100, 16, "OBJET") 
    item_hold = $pokemon_party.actors[@index].item_hold
    if item_hold == 0
      @text_B.bitmap.draw_text_plus(162, 153, 100, 16, "Aucun")  
    else
      @text_B.bitmap.draw_text_plus(162, 153, 100, 16, PokemonData::Item.load(item_hold).name) 
    end
    @battler.bitmap = $pokemon_party.actors[@index].battler_face
    if not $pokemon_party.actors[@index].egg
      @text_B.bitmap.draw_text_plus(161, 17, 100, 16, "N. #{$pokemon_party.actors[@index].level}")
      @text_B.bitmap.blt(241, 4, RPG::Cache.pokemon_status("gender#{$pokemon_party.actors[@index].gender}.png"), Rect.new(0, 0, 6, 10)) if $pokemon_party.actors[@index].gender != 0
      @text_B.bitmap.blt(164, 129, RPG::Cache.pokemon_status("shiny.png"), Rect.new(0, 0, 7, 7)) if $pokemon_party.actors[@index].shiny
    end
    if @page == 0
      if $pokemon_party.actors[@index].egg
        # info à changer en fonction du nombre de pas avant éclosion restant
        @text_A.bitmap.draw_text_plus(33, 41, 180, 16, "Oeuf de Pokémon mystérieux trouvé")
        @text_A.bitmap.draw_text_plus(33, 57, 100, 16, "le #{$pokemon_party.actors[@index].origin_date.day} #{MOIS[$pokemon_party.actors[@index].origin_date.month]} #{$pokemon_party.actors[@index].origin_date.year}.")
        @text_A.bitmap.draw_text_plus(33, 73, 100, 16, "Provenance :")
        @text_A.bitmap.draw_text_plus(33, 89, 100, 16, "#{$pokemon_party.actors[@index].origin}.")
        @text_A.bitmap.draw_text_plus(33, 89, 100, 16, "#{$pokemon_party.actors[@index].origin}", 0, 12)
        @text_A.bitmap.draw_text_plus(33, 105, 150, 16, "\"Surveillance de l'Oeuf\" :")
        @text_A.bitmap.draw_text_plus(33, 121, 100, 16, "Il fait du bruit.")
        @text_A.bitmap.draw_text_plus(33, 137, 100, 16, "Il va éclore !")       
      else             
        @text_A.bitmap.draw_text_plus(33, 41, 100, 16, "#{$pokemon_party.actors[@index].nature} de nature.")
        @text_A.bitmap.draw_text_plus(33, 41, 100, 16, "#{$pokemon_party.actors[@index].nature}", 0, 12)
        @text_A.bitmap.draw_text_plus(33, 57, 100, 16, "Rencontré au N. #{$pokemon_party.actors[@index].origin_level}")
        @text_A.bitmap.draw_text_plus(33, 73, 100, 16, "le #{$pokemon_party.actors[@index].origin_date.day} #{MOIS[$pokemon_party.actors[@index].origin_date.month]} #{$pokemon_party.actors[@index].origin_date.year}.")
        @text_A.bitmap.draw_text_plus(33, 89, 100, 16, "Provenance :")
        @text_A.bitmap.draw_text_plus(33, 105, 100, 16, "#{$pokemon_party.actors[@index].origin}.")
        @text_A.bitmap.draw_text_plus(33, 105, 100, 16, "#{$pokemon_party.actors[@index].origin}", 0, 12)
        @text_A.bitmap.draw_text_plus(33, 121, 100, 16, "")
        8.times do |i|
          @text_B.bitmap.draw_text_plus(17, 9+(16*i), 100, 16, LIST_1[i], 0, 8)
        end   
        @text_B.bitmap.draw_text_plus(81, 9, 100, 16, sprintf("%03d", $pokemon_party.actors[@index].id), 0, $pokemon_party.actors[@index].shiny ? 13 : 0)
        @text_B.bitmap.draw_text_plus(81, 25, 100, 16, PokemonData::Pokemon.load($pokemon_party.actors[@index].id).name)
        @text_B.bitmap.blt(80, 41, RPG::Cache.pokemon_status("T#{$pokemon_party.actors[@index].type1}.png"), Rect.new(0, 0, 32, 14))
        @text_B.bitmap.blt(114, 41, RPG::Cache.pokemon_status("T#{$pokemon_party.actors[@index].type2}.png"), Rect.new(0, 0, 32, 14)) if $pokemon_party.actors[@index].type2 != 0
        @text_B.bitmap.draw_text_plus(81, 57, 100, 16, $pokemon_party.actors[@index].trainer_name, 0, $pokemon_party.player_sexe+12)
        @text_B.bitmap.draw_text_plus(81, 73, 100, 16, $pokemon_party.actors[@index].trainer_id)
        @text_B.bitmap.draw_text_plus(81, 105, 100, 16, $pokemon_party.actors[@index].exp)
        @text_B.bitmap.draw_text_plus(81, 137, 100, 16, $pokemon_party.actors[@index].exp_list[$pokemon_party.actors[@index].level+1]-$pokemon_party.actors[@index].exp)
        draw_exp(@index)     
      end        
    elsif @page == 1
      if @mode == 0        
        @text_A.bitmap.draw_text_plus(89, 33, 100, 16, "PV", 0, 8)
        @text_A.bitmap.draw_text_plus(120, 33, 80, 16, "#{$pokemon_party.actors[@index].hp} / #{$pokemon_party.actors[@index].max_hp}", 1)
        @text_A.bitmap.blt(120, 48, RPG::Cache.pokemon_party_menu("hp_bar.png"), Rect.new(0, 0, 126, 46))
        draw_hp_bar(@index)
        5.times do |i|
          @text_A.bitmap.draw_text_plus(65, 57+i*16, 100, 16, LIST_2[i], 0, 8)
        end
        @text_A.bitmap.draw_text_plus(119, 57, 50, 16, $pokemon_party.actors[@index].atk_basis, 2)
        @text_A.bitmap.draw_text_plus(119, 73, 50, 16, $pokemon_party.actors[@index].dfe_basis, 2)
        @text_A.bitmap.draw_text_plus(119, 89, 50, 16, $pokemon_party.actors[@index].spd_basis, 2)
        @text_A.bitmap.draw_text_plus(119, 105, 50, 16, $pokemon_party.actors[@index].ats_basis, 2)
        @text_A.bitmap.draw_text_plus(119, 121, 50, 16, $pokemon_party.actors[@index].dfs_basis, 2)
        @text_A.bitmap.draw_text_plus(53, 145, 100, 16, "CAP SPÉ", 0, 8)
        @text_A.bitmap.draw_text_plus(113, 145, 100, 16, PokemonData::Ability.load($pokemon_party.actors[@index].ability).name)
        ability_descr = string_builder(PokemonData::Ability.load($pokemon_party.actors[@index].ability).desc, 32)
        2.times do |i|
          @text_A.bitmap.draw_text_plus(53, 161+i*16, 200, 16, ability_descr[i])
        end
      elsif @mode == 1     
        @text_A.bitmap.draw_text_plus(81, 49, 100, 16, "CATÉGORIE", 0, 8)
        @text_A.bitmap.blt(158, 49, RPG::Cache.pokemon_status("S#{PokemonData::Skill.load($pokemon_party.actors[@index].skills_learn[@skill_index]).class}.png"), Rect.new(0, 0, 28, 14))
        @text_A.bitmap.draw_text_plus(81, 65, 100, 16, "POUVOIR", 0, 8)
        power = PokemonData::Skill.load($pokemon_party.actors[@index].skills_learn[@skill_index]).power
        power = " -" if power == 0        
        @text_A.bitmap.draw_text_plus(165, 65, 100, 16, power) 
        @text_A.bitmap.draw_text_plus(81, 81, 100, 16, "PRÉCISION", 0, 8)
        prec = PokemonData::Skill.load($pokemon_party.actors[@index].skills_learn[@skill_index]).prec
        prec = " -" if prec == 0        
        @text_A.bitmap.draw_text_plus(165, 81, 100, 16, prec) 
        skill_descr = string_builder(PokemonData::Skill.load($pokemon_party.actors[@index].skills_learn[@skill_index]).desc, 48)
        3.times do |i|
          @text_A.bitmap.draw_text_plus(9, 105+i*16, 250, 16, skill_descr[i])
        end
        @text_B.bitmap.blt(192, 122, RPG::Cache.pokemon_status("T#{$pokemon_party.actors[@index].type1}.png"), Rect.new(0, 0, 32, 14))
        @text_B.bitmap.blt(224, 122, RPG::Cache.pokemon_status("T#{$pokemon_party.actors[@index].type2}.png"), Rect.new(0, 0, 32, 14)) if $pokemon_party.actors[@index].type2 != 0
      end             
      4.times do |i|
        if i > ($pokemon_party.actors[@index].skills_learn.size-1)   
          @text_B.bitmap.draw_text_plus(51, 18+32*i, 100, 16, "-----", 0, 8) 
          @text_B.bitmap.draw_text_plus(97, 33+32*i, 100, 16, "--", 0, 8) 
          next
        end
        @text_B.bitmap.blt(18, 18+32*i, RPG::Cache.pokemon_status("T#{PokemonData::Skill.load($pokemon_party.actors[@index].skills_learn[i]).type}.png"), Rect.new(0, 0, 32, 14))
        @text_B.bitmap.draw_text_plus(51, 18+32*i, 100, 16, PokemonData::Skill.load($pokemon_party.actors[@index].skills_learn[i]).name, 0, 8)
        @text_B.bitmap.draw_text_plus(61, 33+32*i, 100, 16, "PP", 0, 8)
        @text_B.bitmap.draw_text_plus(99, 33+32*i, 100, 16, "#{$pokemon_party.actors[@index].skills[i*3+1]}/#{$pokemon_party.actors[@index].skills[i*3+2]}", 0, 8)
      end
    end
  end  
  
  def draw_hp_bar(i)
    r = $pokemon_party.actors[i].hp.to_f / $pokemon_party.actors[i].max_hp.to_f    
    rect1 = Rect.new(136, 51, r*48.to_i, 1)
    rect2 = Rect.new(136, 52, r*48.to_i, 1)
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
    @text_A.bitmap.fill_rect(rect1, color1)
    @text_A.bitmap.fill_rect(rect2, color2)
  end 
  
  def draw_exp(i)     
    r = ($pokemon_party.actors[i].exp-$pokemon_party.actors[i].exp_list[$pokemon_party.actors[i].level]).to_f/
    ($pokemon_party.actors[i].exp_list[$pokemon_party.actors[i].level+1]-$pokemon_party.actors[i].exp_list[$pokemon_party.actors[i].level]).to_f
    rect = Rect.new(80, 155, r*64.to_i, 3)
    @text_B.bitmap.fill_rect(rect, Color.new(0, 0, 214))
  end
  
  def draw_skill_select    
    4.times do |i|
      @skill[i].bitmap = RPG::Cache.pokemon_status("skill_list.png")
      @skill[i].src_rect.set(0, 33*i, 136, 33) 
    end
    if @mode == 1
      @skill[@skill_index].bitmap = RPG::Cache.pokemon_status("skill_list_select.png")
      @skill[@skill_index].src_rect.set(0, 35*@skill_index, 136, 34)      
      refresh
    end
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
  
  def cry_pokemon(id)
    ida = sprintf("%03d", id)
    filename = "Audio/SE/Cries/" + ida + "Cry.wav"
    if FileTest.exist?(filename)
      Audio.se_play(filename)
    end    
    return true
  end 
  
  def animation
    @background_A.x == -32 ? (@background_A.x += 32 and @background_A.y += 16) : (@background_A.x -= 1 and 
    @wait == 1 ? @wait = 0 : (@wait += 1 and @background_A.y -= 1)) 
    @background_B.x = @background_A.x
    @background_B.y = @background_A.y
  end
    
  def refresh_all
    page_update
    refresh
  end  
  
  def finish
    return if @finished
    @viewport_A.dispose
    @viewport_B.dispose
    @background_A.dispose
    @background_B.dispose
    @spr_A.each do |i| i.dispose end
    @spr_B.each do |i| i.dispose end
    @info_p.each do |i| i.dispose end
    @barre.dispose
    @icons.dispose
    @btn.dispose
    @battler.dispose
    @skill.each do |i| i.dispose end
    @text_A.dispose
    @text_B.dispose
    @viewport_A = nil
    @viewport_B = nil
    @background_A = nil
    @background_B = nil
    @spr_A = nil
    @spr_B = nil
    @info_p = nil
    @barre = nil
    @icons = nil
    @btn = nil
    @battler = nil
    @skill = nil
    @text_A = nil
    @text_B = nil
    @finished = true
  end  
  
  def finished?() @finished end
  def transition?() @transition end
end