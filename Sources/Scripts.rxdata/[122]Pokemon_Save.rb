#==============================================================================
# ■ Pokemon_Save
# Pokemon Script Project v1.0 - Palbolsky
# 07/05/2012
# Conversion en module par Nagato Yuki le 26/06/2012 
#------------------------------------------------------------------------------

module Pokemon_Save
  Mois=[nil,"janvier","février","mars","avril","mai","juin","juillet","août","septembre","octobre","novembre","décembre"]
  module_function
  def viewport(x1=0,y1=0,x2=0,y2=200)
    #>Création des viewports
    @viewport_A = Viewport.new(x1, y1, 256, 192)
    @viewport_A.z = 1002
    @viewport_B = Viewport.new(x2, y2, 256, 192)
    @viewport_B.z = 1002   
  end
  
  def init
    @finished=false
    @index=0
    @mode=0
    @time = Time.new
    $pokemon_party.add_game_time
    temp = $pokemon_party.get_game_time.to_i
    temp-=(temp%60)
    temp/=60
    @min=temp%60
    @heure=temp/60
    @heure=999 if @heure>999
    @background = Sprite.new(@viewport_B)
    @background.bitmap = RPG::Cache.pokemon_save("background.png")
    @background.z = 0
    @fleche = Sprite.new(@viewport_A)
    @fleche.bitmap = RPG::Cache.pokemon_menu("fleche.png")
    @fleche.y = 168
    @fleche.z = 202
    @load = Sprite.new(@viewport_B)
    @load.bitmap = RPG::Cache.pokemon_save("load.png")
    @load.x = 71
    @load.y = 181
    @load.z = 1
    @load.visible = false
    @load_p = Sprite.new(@viewport_B)
    @load_p.bitmap = RPG::Cache.pokemon_save("load_p.png") 
    @load_p.src_rect.set(0, 0, 0, 6)      
    @load_p.x = 71
    @load_p.y = 181
    @load_p.z = 2
    @load_p.visible = false
    @text=Sprite.new(@viewport_B)
    @text.bitmap=Bitmap.new(256,192)
    @text.z=3
    @img = Sprite.new(@viewport_B)
    @img.bitmap = RPG::Cache.pokemon_save("draw_choice.png")
    @img.x = 194
    @img.y = 48
    @img.z = 1
    @cursor = Sprite.new(@viewport_B)
    @cursor.bitmap = RPG::Cache.pokemon_save("curseur.png")
    @cursor.x = 194
    @cursor.y = 48
    @cursor.z = 2
  end
  
  def run
    init
    while Scene_Manager.me?(self)
      Graphics.update
      Input.update
      update
    end
    finish
    GC.start
  end
  
  def update
    draw_save
    case @mode
    when 0
      @mode= choice ? 1 : 3
    when 1
      @load.visible = true     
      @load_p.visible = true
      i = 0
      wait=0
      loop do
        Graphics.update
        wait += 1
        if wait == 4
          i += 1
          wait = 0
        end
        @load_p.src_rect.set(0, 0, 12*i, 6) 
        if i == 10
          $pokemon_party.save_date_save
          File.rename(Pokemon_Load::SaveFile,Pokemon_Load::SaveFile+".bak") if(File.exist?(Pokemon_Load::SaveFile))
          f=File.new(Pokemon_Load::SaveFile,"wb")
          f.write(Marshal.dump($pokemon_party))
          f.close
          Audio.se_play("Audio/se/save.ogg")
          @mode = 2
          break
        end
      end
    when 2
      Scene_Manager.pop if Input.trigger?(Input::C) or (Input.trigger_plus2?(1) and Mouse.y>200)
    else
      Scene_Manager.pop
    end
  end
  
  def finished?() return @finished end
  
  def finish
    @text.bitmap.dispose
    @text.dispose
    @background.dispose
    @fleche.dispose
    @load.dispose
    @img.dispose
    @cursor.dispose
    @load_p.dispose
    @viewport_A.dispose
    @viewport_B.dispose
    @text=nil
    @background=nil
    @load=nil
    @img=nil
    @cursor=nil
    @load_p=nil
    @viewport_A=nil
    @viewport_B=nil
    @finished=true
  end
  
  def choice
    @text.bitmap.draw_text_plus(194, 48,62,24, "OUI",1,9)
    @text.bitmap.draw_text_plus(194, 72,62,24, "NON",1,9)
    loop do
      Graphics.update
      Input.update
      if Input.trigger_plus2?(1) and Mouse.is_in_sprite_plus?(@img)
        if $ShowCadre
          b1= Mouse.y>(272+(Pokemon_S::POS_CADRE[3]-200)) ? false : true
        else
          b1= Mouse.y>272 ? false : true
        end
      else
        b1=nil
      end
      if Input.trigger?(Input::C) and @index == 0 or b1
        $game_system.se_play($data_system.decision_se)
        @img.visible=@cursor.visible=false
        return true
      elsif Input.trigger?(Input::B) or (Input.trigger?(Input::C) and @index == 1) or b1==false
        @img.visible=@cursor.visible=false
        $game_system.se_play($data_system.cancel_se)
        Scene_Manager.pop
        return false
      end
      if Input.trigger?(Input::DOWN) and @index<1
        $game_system.se_play($data_system.cursor_se)
        @index += 1        
      elsif Input.trigger?(Input::UP) and @index>0
        $game_system.se_play($data_system.cursor_se)
        @index -= 1
      end
      @cursor.y = (@index == 0 ? 48 : 72)
    end
  end
  
  def draw_save
    @text.bitmap.clear
    bm=@text.bitmap
    if @mode == 0      
      bm.draw_text_plus(8, 8,220,16, "Voulez-vous sauvegarder la partie ?")
      if $pokemon_party.date_save != nil
        bm.draw_text_plus(29, 172, 220,16, "Partie précédente : #{$pokemon_party.date_save.day} #{Mois[$pokemon_party.date_save.month]} #{$pokemon_party.date_save.year}",0,9)
      end      
    elsif @mode == 1
      bm.draw_text_plus(8, 8, 220,16,"Sauvegarde en cours...")
      bm.draw_text_plus(8, 24, 220,16,"Ne pas éteindre.")
    elsif @mode == 2
      bm.draw_text_plus(8, 8, 220,16,"#{$pokemon_party.trainer_name} a sauvegardé la partie.")
    end
    bm.draw_text_plus(24, 56, 220,16,"#{@time.day} #{Mois[@time.month]} #{@time.year}")
    bm.draw_text_plus(128, 56, 220,16,sprintf("%02d:%02d", @time.hour, @time.min))
    bm.draw_text_plus(24, 72, 220,16,"") # A compléter pour la variable (lieu)
    bm.draw_text_plus(24, 128, 220,16,"Badges : #{$pokemon_party.number_badge}")
    bm.draw_text_plus(128, 128, 220,16,"Pokédex : #{$pokemon_party.seen.count(true)}") # A compléter pour la variable 
    bm.draw_text_plus(24, 144, 220,16,sprintf("Temps de jeu : %02d:%02d",@heure,@min))
  end
end