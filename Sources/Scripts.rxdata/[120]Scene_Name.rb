#==============================================================================
# ■ Scene_Name
# Pokemon Script Project v1.0 - Palbolsky
# 14/08/2012
#------------------------------------------------------------------------------

module Scene_Name   
  MAJ_TABLE = ["A","B","C","D","E","F","G","H","I","J"," ",",",".",
               "K","L","M","N","O","P","Q","R","S","T"," ","'","-",
               "U","V","W","W","Y","Z"," "," "," "," "," ","♂","♀",
               "À","Â","Ç","É","È","Ê","Ë","Î","Ï","Ô","Ù","Û"," ",
               "0","1","2","3","4","5","6","7","8","9"," "," "," "]
             
  MIN_TABLE = ["a","b","c","d","e","f","g","h","i","j"," ",",",".",
               "k","l","m","n","o","p","q","r","s","t"," ","'","-",
               "u","v","w","x","y","z"," "," "," "," "," ","♂","♀",
               "à","â","ç","é","è","ê","ë","î","ï","ô","ù","û"," ",
               "0","1","2","3","4","5","6","7","8","9"," "," "," "]
             
  OTH_TABLE = [",",".",":",";","!","?"," "," "," ","♂","♀"," "," ",
               "«","»","“","”","‘","’","(",")"," "," "," "," "," ",
               "…","·","~","#","%","+","-","*","/","="," "," "," ",
               "@","○","□","♠","♥","♦","♣","♪"," "," "," "," "," ",
               "0","1","2","3","4","5","6","7","8","9"," "," "," "]
               
  KEYBOARD=[MAJ_TABLE,MIN_TABLE,OTH_TABLE]
  module_function  
  def viewport(x1=0,y1=0,x2=0,y2=200)
    @viewport_A = Viewport.new(x1,y1,256,192)
    @viewport_A.z = 1004
    @viewport_B = Viewport.new(x2,y2,256,192)
    @viewport_B.z = 1004
  end
  
  def init
    @finished = false    
    @mode = 0
    @index = 0     
    @background_A = Sprite.new(@viewport_A)
    @background_A.bitmap = RPG::Cache.scene_name("background_A.png")    
    @background_B = Sprite.new(@viewport_B)
    @background_B.bitmap = RPG::Cache.scene_name("background_B.png")
    @background_A.z = @background_B.z = 0
    @page = Sprite.new(@viewport_B)    
    @page.x = 24
    @page.y = 162
    @page.z = 1
    @underscore = Sprite.new(@viewport_B)
    @underscore.bitmap = RPG::Cache.scene_name("underscore.png") 
    @underscore.x = 79
    @underscore.y = 31
    @underscore.z = 1   
    @img_undscore = RPG::Cache.scene_name("underscore.png")
    @chara = Sprite.new(@viewport_B)       
    @chara.x = 18
    @chara.y = 4
    @chara.z = 1
    @curseur = Sprite.new(@viewport_B)
    @curseur.bitmap = RPG::Cache.scene_name("curseur.png")
    @curseur.x = 22
    @curseur.y = 39
    @curseur.z = 2
    @name = Array.new    
    @text_msg = Sprite.new(@viewport_A)
    @text_msg.bitmap = Bitmap.new(256, 192)
    @text_msg.z = 1            
    @text_keyboard = Sprite.new(@viewport_B)
    @text_keyboard.bitmap = Bitmap.new(256, 192)
    @text_keyboard.z = 1   
    @text_name = Sprite.new(@viewport_B)
    @text_name.bitmap = Bitmap.new(256, 192)
    @text_name.z = 1
    if $game_switches[104]
      @chara.bitmap=$pokemon_party.actors[$game_variables[102]-1].icon
      @underscore.src_rect.set(0,0,14*12,3)
      aname,j=$pokemon_party.actors[$game_variables[102]-1].name,0
      12.times do |i|
        break if j>=aname.size
        len=1
        len+=1 while aname[j+len]&0xc0==0x80
        @name[i] = aname[j,len]
        j+=len        
      end  
      @text_msg.bitmap.draw_text_plus(8, 152, 120, 16, "Surnom du Pokémon ?")
    else
      if $game_temp.name_actor_id == 1
        @chara.bitmap=RPG::Cache.character(sprintf("%03d", $pokemon_party.player_sexe)+".png", 0)        
      else
        @chara.bitmap=RPG::Cache.character("R_"+sprintf("%03d",$game_temp.name_actor_id-1)+".png", 0)                
      end      
      @chara.src_rect.set(0,0,@chara.bitmap.width/4,@chara.bitmap.height/4)
      @underscore.src_rect.set(0,0,14*$game_temp.name_max_char,3)	
      aname,j=$game_actors[$game_temp.name_actor_id].name,0
      $game_temp.name_max_char.times do |i|
      break if j>=aname.size
        len=1
        len+=1 while aname[j+len]&0xc0==0x80
        @name[i] = aname[j,len]
        j+=len
      end   
      @text_msg.bitmap.draw_text_plus(8, 152, 100, 16, $game_temp.name_actor_id == 1 ? "Votre nom ?" : "Nom du rival ?") 
    end    
    @index_name = @name.size
    draw_name    
    draw_keyboard
    draw_index
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
    if Input.trigger_plus2?(1)
      3.times do |i|
        if Mouse.is_here?(24+25*i,362,25,20)
          @mode = i
          @index = 65+i
          draw_index
          draw_keyboard
          $game_system.se_play($data_system.cursor_se)
        end
      end
      j,k=0,0
      65.times do |i|        
       if i % 13 == 0 and i != 0
          k+=1
          j=0
        end
        if Mouse.is_here?(24+16*j,241+24*k,15,22)
          @index = i
          draw_index
          write
        end
        j+=1   
      end  
      if Mouse.is_here?(102,362,63,20)
        @index = 68
        draw_index
        erase
      end
      if Mouse.is_here?(166,362,65,20)
        @index = 69
        draw_index        
        confirm
      end
    end
    if Input.trigger?(Input::B)           
      erase     
    end
    if Input.repeat?(Input::LEFT) and @index > 0 and @index != 65
      draw_index(-1) 
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.repeat?(Input::RIGHT) and @index != 64 and @index < 69
      draw_index(1) 
      return $game_system.se_play($data_system.cursor_se)
    end    
    if Input.repeat?(Input::UP)
      return if @index < 12
      if @index > 64
        @index = 0
        draw_index
      else
        draw_index(-13)
      end
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.repeat?(Input::DOWN)
      return if @index > 65
      if @index > 51
        @index = 65
        draw_index
      else
        draw_index(13)        
      end
      return $game_system.se_play($data_system.cursor_se)
    end
    if Input.trigger?(Input::C)
      if @index > 64
        if @index > 64 and @index < 68
          @mode = @index-65
          draw_keyboard
          $game_system.se_play($data_system.decision_se)
        end
        case @index
        when 68
          erase
        when 69
          confirm
        end
      else
        write
      end      
    end    
  end
  
  def draw_keyboard    
    @text_keyboard.bitmap.clear
    j,k=0,0   
    65.times do |i|      
      if i % 13 == 0 and i != 0
        k+=1
        j=0
      end
      @text_keyboard.bitmap.draw_text_plus(28+16*j,45+24*k,16,16,KEYBOARD[@mode][i],0,8)
      j+=1
    end
    draw_page
  end  
  
  def draw_index(i=0)
    @index += i      
    @curseur.y = 39+24*(@index/13) 
    if @index < 65      
      @curseur.x = 22+16*(@index-13*(@index/13))      
      @curseur.src_rect.set(0,0,19,26)
    else
      @curseur.y += 1
      if @index > 64 and @index < 68
        @curseur.src_rect.set(19,0,29,24)
        @curseur.x = 22+26*(@index-65)
      end
      case @index
      when 68        
        @curseur.src_rect.set(48,0,67,24)
        @curseur.x = 100
      when 69
        @curseur.src_rect.set(115,0,69,24)
        @curseur.x = 164
      end
    end       
  end
  
  def draw_name
    @text_name.bitmap.clear
    @name.size.times do |i| 
      @text_name.bitmap.draw_text_plus(83+14*i,16,16,16,@name[i],0,8)
    end    
    return if @index_name >= ($game_switches[104] ? 12 : $game_temp.name_max_char) 
    @text_name.bitmap.blt(79+14*@index_name, 30,@img_undscore, Rect.new(0,3,14,15))
  end
  
  def draw_page
    @page.bitmap = RPG::Cache.scene_name("page_#{@mode}.png")   
  end      
  
  def erase
    return if @index_name == 0  
    @index_name -= 1
    @name.pop
    draw_name
    $game_system.se_play($data_system.cancel_se)
  end
  
  def write
    return if @index_name == ($game_switches[104] ? 12 : $game_temp.name_max_char)
    @index_name += 1
    @name.push(KEYBOARD[@mode][@index])
    draw_name
    $game_system.se_play($data_system.decision_se)
  end
  
  def confirm  
    name = @name.join
    if $game_switches[104]
      if name.size == 0 or name.gsub(" ","").size == 0
        @text_msg.bitmap.clear
        @text_msg.bitmap.draw_text_plus(8, 152, 180, 16, "Entrez le surnom du Pokémon !")
        Graphics.wait(40)
        @text_msg.bitmap.clear
        @text_msg.bitmap.draw_text_plus(8, 152, 120, 16, "Surnom du Pokémon ?") 
        return
      end
      $pokemon_party.actors[$game_variables[102]-1].new_name(@name.join)         
    else
      if name.size == 0 or name.gsub(" ","").size == 0
        @text_msg.bitmap.clear
        @text_msg.bitmap.draw_text_plus(8, 152, 180, 16, $game_temp.name_actor_id == 1 ? "Entrez votre nom !" : "Entrez le nom du rival !")
        Graphics.wait(40)
        @text_msg.bitmap.clear
        @text_msg.bitmap.draw_text_plus(8, 152, 100, 16, $game_temp.name_actor_id == 1 ? "Votre nom ?" : "Nom du rival ?") 
        return
      end
      $game_actors[$game_temp.name_actor_id].name = @name.join   
    end
    Scene_Manager.pop
    $game_system.se_play($data_system.decision_se)
  end
  
  def finish
    return if @finished
    @background_A.dispose
    @background_B.dispose
    @page.dispose
    @underscore.dispose
    @curseur.dispose
    @text_msg.dispose
    @text_keyboard.dispose
    @text_name.dispose
    @chara.dispose
    @background_A = nil
    @background_B = nil
    @page = nil        
    @underscore = nil
    @curseur = nil
    @text_msg = nil
    @text_keyboard = nil
    @chara = nil
    @finished = true
  end
  
  def finished?() @finished end
end