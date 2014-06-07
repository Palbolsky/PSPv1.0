#===
# Ajout à la classe Graphics
#---
# Ecrit par Nagato Yuki
#===
class << Graphics
	unless method_defined? :old_update
		alias :old_update :update
		def update
      sleep(@wait) if @wait
			if Mouse.enable?
				Input.update_plus
				Mouse.update
				old_update
			else
				old_update
			end
		end
		alias :old_transition :transition
		def transition(*args)
			m=Mouse.enable?
			Mouse.disable
			old_transition(*args)
			Mouse.enable if m
		end
    def width=(v)
      @width=v.to_i
    end
    def height=(v)
      @height=v.to_i
    end
		def width()
			return @width
		end
		def height()
			return @height
		end
		def wait(t)
			t.times do Graphics.update end
		end
	end
end
module Graphics
  @dif=0
  @wait=false
  module_function
  def resize_screen(width=640,height=480,sup=0,x=0,y=0,t=0,center=true,jmp_gu=false)
    @width=width
    @height=height
    width+=6
    bheight=height
    height+=@dif
    if center and x==0 and y==0
      x=(API::GSM.call(0)-width)/2
      y=(API::GSM.call(1)-height)/2
    end
    API::SWP.call(API.handle, sup, x,y, width, height, t)
    Graphics.update unless jmp_gu
    if @dif==0 and API.client_size[1] != bheight
      @dif=bheight-API.client_size[1]
    end
  end
  def Fmod_Thread_Active(frame_rate,slp_time)
    Graphics.frame_rate=frame_rate
    @wait=slp_time
  end
end