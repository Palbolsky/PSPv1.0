#===
#¤Module Yuki::ShowMSG
#---
#%Affichage de messages.
#---
#© 23/07/2011 - Nuri Yuri (塗 ゆり)
#===
module Yuki
  module ShowMSG
    S_sl="\\"
    S_000="\000"
    S_001="\001"
    S_cr="]"
    R_SPD=[100,1,2,3]
    module_function
    def init
      @message_text=API::CHR_EMPTY
      @width=256  #Taille de la fenêtre
      @height=48
      @ay=0  #Position de l'arrow
      @msg_boxs=[]  #Sauvegarde des noms de boite de message
      @trans=false  #Si transition à l'affichage
      @trans_end=false #Si transition à l'effacement
      @trans_av=0   #Avancement de la transition
      @defile=false #Défilement entre deux msg
      @show_arr=false  #Affichage de l'arrow
      @clear_at_end=false #Disparition dès que le message est affiché
      @sp=Sprite.new  #Sprite de la boite
      @sp.bitmap=Bitmap.new(256,64)
      @spc=Sprite.new  #Sprite du texte
      @spc.bitmap=Bitmap.new(256,64) 
      @bmp_tmp=@spc.bitmap.clone
      @spa=Sprite.new  #Sprite de l'arrow      
      @spa.visible=false
      @rect=Rect.new(0,9,256,55)
      @rect2=Rect.new(0,0,256,55)
      @widthm=256-(Constant::Message1[0]+Constant::Message1[2])-2
    end
    def run(message,x=4,y=162,z=1000,defile=false,trans=false,trans_end=false,clear_at_end=false,show_arrow=true)
      @x=Constant::Message1[0]
      @y=(defile ? 1 : 0)
      @pos=0
      if $ShowCadre
        posc = Pokemon_S::POS_CADRE
        @sp.x=@spc.x=x+posc[0]
        @sp.y=@spc.y=y+posc[1]
        @spa.x=x+238+posc[0]
        @ay=@spa.y=y+30+posc[1]
      else
        @sp.x=@spc.x=x
        @sp.y=@spc.y=y
        @spa.x=x+238
        @ay=@spa.y=y+30
      end
      @sp.z=z
      @spc.z=@spa.z=z+1
      @spa.visible=false
      @trans=trans
      @trans_end=trans_end
      @trans_av=0
      @defile=defile
      @clear_at_end=clear_at_end
      @show_arr=show_arrow
      @message_text=message.to_s
    #  id=1 #3 panneau, 4 lieu, 2, information, 1  autre.
      case $game_variables[101]
      when 1 #Panneau
        id,@color,@h=3,15,8
      when 2 #Lieu
        id,@color,@h=4,15,8
      when 3 #Information
        id,@color,@h=2,8,7
      else
        id,@color,@h=1,0,7
      end
      @bmp=RPG::Cache.windowskin("M_#{id}.png")
      @spa.bitmap=RPG::Cache.windowskin("arrow_#{id}")
      #affichage des sprite.
      @sp.bitmap.clear
      @sp.bitmap.draw_window(0,0,@width,@height,@bmp,Constant::Message1) if $game_system.message_frame==0
      @spc.bitmap.clear unless defile
      @sp.visible=@spc.visible=true
      if trans
        @sp.opacity=0
      else
        @sp.opacity=255
      end
      #Remplacements
      @message_text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
      @message_text.gsub!(/\\[Nn]\[([0-9]+)\]/) { $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : "" }
      @message_text.gsub!(/\\\\/,S_000)
      @message_text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
      @message_text.gsub!(/\\[Pp]\[([0-9]+)\]/) { $pokemon_party.actors[$1.to_i-1]  ? $pokemon_party.actors[$1.to_i-1].name : "" }
    end
    
    def update
      return true unless @color
      if @trans
        @trans_av+=1
        @spc.opacity=@sp.opacity=@trans_av*30
        @trans=false if @trans_av>=10
      elsif @defile
        @trans_av+=1
        @bmp_tmp.clear
        @bmp_tmp.blt(0,8,@spc.bitmap,@rect)
        @spc.bitmap.clear
        @spc.bitmap.blt(0,9,@bmp_tmp,@rect)
        @defile=false if @trans_av>=16
      else
        R_SPD[(Input.trigger?(Input::C) ? 0 : ($pokemon_party ? $pokemon_party.options[0] : 2))].times do |i|
          if @show_arr and self.write_txt
            @spa.visible=true
            @spa.y=@ay+(@trans_av%2)*2 if (@trans_av%55)==0
            @trans_av+=1
            @trans_av=0 if @trans_av==550
            if Input.trigger?(Input::C)
              @trans_av=0
              @show_arr=false
              @spa.visible=false
            end
            return false
          elsif !@show_arr and self.write_txt
            if @trans_end
              @trans_av+=1
              @spc.opacity=@sp.opacity=255-@trans_av*30
              @trans_end=false if @trans_av>=10
              return false
            elsif @clear_at_end
              @sp.bitmap.clear
              @spc.bitmap.clear
            end
            if $game_temp.message_proc
              $game_temp.message_proc.call
              $game_temp.message_proc=nil
            end
            return true
          end
        end
      end
      return false
    end
    
    def write_txt
      return true if @pos>=@message_text.size
      #Execution du texte
      str=@message_text[@pos,1]
      @pos+=1
      if str==S_000
        str=S_sl
      elsif str==S_001
        @color=0
        while true
          d=@message_text[@pos,1]
          @pos+=1
          break if d==S_cr
          @color*=10
          @color+=d.to_i
        end
        str=@message_text[@pos,1]
        @pos+=1
      end
      if str[0]==10 #Saut de ligne
        @y+=1
        @x=Constant::Message1[0]
        return
      elsif str[0]==195
        str+=@message_text[@pos,1]
        @pos+=1
      elsif str[0]==227 or str[0]==226
        str+=@message_text[@pos,2]
        @pos+=2
      end
      unless @center
        @spc.bitmap.draw_text_plus(@x,@y*(23-@h)+@h,20,16,str,0,@color)
        @x+=@spc.bitmap.text_size(str).width
      else
        @bmp_tmp.clear
        yp=@y*16+7
        @rect2.x=(@widthm-@x)/2
        @rect2.y=yp
        @rect2.width=@x
        @bmp_tmp.blt(0,0,@spc.bitmap,@rect2)
        @bmp_tmp.draw_text_plus(@x,0,20,16,str,0,@color)
        @x+=@spc.bitmap.text_size(str).width
        @spc.bitmap.fill_rect(@rect2,Constant::C_Trans)
        @rect2.x=0
        @rect2.y=0
        @rect2.width=@x
        @spc.bitmap.blt((@widthm-@x)/2,yp,@bmp_tmp,@rect2)
      end
      false
    end
    #===
    #§ Center
    #===
    def center=(val)
      @center=val
    end
  end
end
Init_Contener.push(Yuki::ShowMSG)