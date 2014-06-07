#===
# Command
#---
# Ecrit par Nagato Yuki
#===
module Yuki
  class Command
    def initialize(x=0,y=0,z=0,add=false,cancel=-1,dir=:y)
      @Buttons=Array.new
      @Options=Hash.new
      @Methods=Array.new
      @Bitmaps=Array.new
      @add=add
      @dir=dir
      @x=x
      @y=y
      @z=z
      @index=0
      @cancel=cancel
    end
    
    def set_bitmap(id,bitmap)
      return if @disposed
      @Bitmaps[id]=bitmap
    end
    
    def push_button(option,method,viewport=nil)
      return if @disposed
      sprite=Sprite.new(viewport)
      if lsp=@Buttons[-1]
        sprite.x=lsp.x + (@dir==:x ? lsp.src_rect.width : 0)
        sprite.y=lsp.y + (@dir==:y ? lsp.src_rect.height : 0)
      else
        sprite.x=@x
        sprite.y=@y
      end
      sprite.z = @z
      sprite.bitmap=Bitmap.new(@Bitmaps[option[:bitmap_id]].width,
        @Bitmaps[option[:bitmap_id]].height/2)
      @Options[@Buttons.size]=option
      @Buttons.push(sprite)
      @Methods.push(method)
      return @Buttons.size
    end
    
    def draw()
      return if @disposed
      s=0
      unless @add
        @Buttons.each do |i| s+=(@dir==:x ? i.src_rect.width : i.src_rect.height) end        
      end
      @Buttons.each_index do |i|
        draw_btn(i)
        if @dir==:x
          @Buttons[i].x-=s
        else
          @Buttons[i].y-=s
        end
      end
    end
    
    def draw_btn(i,st=0)
      return if @disposed
      @Buttons[i].bitmap.clear
      h=@Buttons[i].bitmap.height
      bmp=@Bitmaps[@Options[i][:bitmap_id]]
      @Buttons[i].bitmap.blt(0,h*st,bmp,bmp.rect)
      txt=@Options[i][:txt]
      x=@Options[i][:x]
      y=@Options[i][:y]
      w=@Options[i][:w]
      h=@Options[i][:h]
      a=(@Options[i][:align] ? @Options[i][:align] : 0 )
      c=@Options[i][:color].to_i
      t=@Options[i][:type].to_i
      @Buttons[i].bitmap.draw_text_plus(x,y,w,h,txt,a,c,t)
      if bmp=@Options[i][:bmp]
        x=@Options[i][:bx]
        y=@Options[i][:by]
        rect=@Options[i][:rect]
        @Buttons[i].bitmap.blt(x,y,@Bitmaps[bmp],rect ? rect : @Bitmaps[bmp].rect)
      end
    end
      
    def index() return @index end
      
    def last_meth() return @Methods[@index] end
      
    def set_index(index)
      if index.class==Fixnum
        @index=index
      else
        @index=@Methods.index(index).to_i
      end
    end
    
    def run()
      return if @disposed
      loop do
        Graphics.update
        Input.update
        draw_btn(@index,-1)
        l_index=@index
        if @dir==:y
          if Input.repeat?(Input::UP)
            @index-=1
            @index+=@Buttons.size if @index<0
          elsif Input.repeat?(Input::DOWN)
            @index+=1
            @index-=@Buttons.size if @index>=@Buttons.size
          end
        else
          if Input.repeat?(Input::LEFT)
            @index-=1
            @index+=@Buttons.size if @index<0
          elsif Input.repeat?(Input::RIGHT)
            @index+=1
            @index-=@Buttons.size if @index>=@Buttons.size
          end
        end
        if l_index != @index
          draw_btn(l_index)
          $game_system.se_play($data_system.cursor_se)
        end
        if Input.trigger?(Input::C)
          if @cancel == -1
            if @index == (@Buttons.size-1)
              $game_system.se_play($data_system.cancel_se)
            else
              $game_system.se_play($data_system.decision_se)
            end
          elsif @index == @cancel              
            $game_system.se_play($data_system.cancel_se)
          else
            $game_system.se_play($data_system.decision_se)
          end 
          return @Methods[@index].call()
        end
        if Input.trigger?(Input::B)
          $game_system.se_play($data_system.cancel_se)
          return @Methods[@cancel].call()
        end
        if Input.trigger_plus2?(1)        
          @Buttons.each_index do |i|
            if Mouse.is_in_sprite_plus?(@Buttons[i])
              @index = i 
              if @cancel == -1
                if @index == (@Buttons.size-1)
                  $game_system.se_play($data_system.cancel_se)
                else
                  $game_system.se_play($data_system.decision_se)
                end
              elsif @index == @cancel              
                $game_system.se_play($data_system.cancel_se)
              else
                $game_system.se_play($data_system.decision_se)
              end              
              return @Methods[@index].call()
            end
          end
        end			
      end
    end
    
    def dispose
      @disposed=true
      @Buttons.each do |i|
        i.bitmap.dispose
        i.dispose
      end
      @Buttons.clear
      @Buttons=nil
      @Options.clear
      @Options=nil
      @Methods.clear
      @Methods=nil
      @Bitmaps.clear
      @Bitmaps=nil
    end
  end
end