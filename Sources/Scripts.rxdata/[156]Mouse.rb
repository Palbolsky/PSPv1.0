#===
#¤Module Mouse
#% Permet la detection de la position relative de la souris dans l'écran de jeu
#% Des fonctions permettent la detection dans certains objets.
#---
#© 2011 - Nagato Yuki
#===
module Mouse
	@x=0
	@y=0
	Pos="\x00"*8
	module_function
  #===
  #>Mise à jour du module
  #===
	def update
		API::CP.call(Pos)
		API::STC.call(API::handle, Pos)
		@x, @y = *Pos.unpack(API::CHARx_LL)
		if @x<0
			@x=0
		elsif @x>Graphics.width
			@x=Graphics.width
		end
		if @y<0
			@y=0
		elsif @y>Graphics.height
			@y=Graphics.height
		end
	end
  #===
  #>Detection de la souris dans rectangle
  #===
	def is_here?(x,y,width,height)
    if $ShowCadre
      posc = Pokemon_S::POS_CADRE
      x += posc[0]
      if y >= 200
        y += posc[3] - 200
      else
        y += posc[1]
      end
    end
		xm=x+width
		ym=y+height
		(@x >= x and @x <= xm and @y >= y and @y <= ym)
	end
  #===
  #>Detection dans un objet de cette classe
  #===
	def is_in_rect?(rect)
		is_here?(rect.x,rect.y,rect.width,rect.height)
	end
  #===
  #>Detections dans un viewport
  #===
	def is_in_viewport?(viewport)
		is_here?(viewport.rect.x,viewport.rect.y,viewport.rect.width,viewport.rect.height)
	end
  #===
  #>Detection de la souris dans un sprite
  #% Il doit être visible et doit avoir une boite de dessin (bitmap)
  #===
  def is_in_sprite?(sprite)
		return false unless sprite.visible
		return false unless sprite.src_rect
		if sprite.viewport
			vx,vy=sprite.viewport.rect.x,sprite.viewport.rect.y
			vw,vh=sprite.viewport.rect.width,sprite.viewport.rect.height
		else
			vx=vy=0
			vw=vh=1024
		end
		sx=sprite.x-sprite.ox
		sy=sprite.y-sprite.oy
		sw=sprite.src_rect.width
		sh=sprite.src_rect.height
		if sx >= 0
			@lsp_x=x=sx+vx
		else
			x=vx  #Si sx < 0 il est donc visible au début du viewport
			sw+=sx #On ajoute donc la position x du sprite pour avoir la taille visible
			@lsp_x=sx+vx  #Utile pour in_sprite_plus?
		end
		if sy >= 0
			@lsp_y=y=sy+vy
		else
			y=vy
			@lsp_y=sy+vy
			sh+=sy
		end
		xs=vx+sx+sw
		xv=vx+vw
		ys=vy+sy+sh
		yv=vy+vh
		width=(xs > xv ? sw-(xs-xv) : sw )
		height=(ys > yv ? sh-(ys-yv) : sh)
    if $ShowCadre
      posc = Pokemon_S::POS_CADRE
      is_here?(x-posc[0],y-(posc[3]-200),width,height)
    else
      is_here?(x,y,width,height)
    end
	end
  #===
  #>Detection avancée : Detecte si la souris pointe sur un pixel non transparent
  #===
	def is_in_sprite_plus?(sprite)
		b=is_in_sprite?(sprite)
		if b
			x=@x-@lsp_x
			y=@y-@lsp_y
      px=sprite.bitmap.get_pixel(x,y).alpha    
			b2=(px != 0)
			r_value=(b & b2)
			return r_value
		end
		false
	end
  #===
  #>Detection completement useless mais bon...
  #===
	def is_in_window?(window)
		return false unless window.visible
		is_here?(window.x-window.ox,window.y-window.oy,window.height,window.width)
	end
  #===
  #>Vérification de l'activation de la souris (pour les scripts extérieurs)
  #===
	def enable?
		return @enable
	end
  #===
  #>Désactivation
  #===
	def disable
		@enable=false
	end
  #===
  #>Activation
  #===
	def enable
		@enable=true
	end
  #===
  #>Initialisation, pour l'état initial du module
  #===
	def init
		@enable=true
	end
end
#===
#>Mise des attributs lisibles x et y
#===
class << Mouse
	attr_reader :x, :y
end
#===
#Partie Init_Contener
#===
Init_Contener.push(Mouse)