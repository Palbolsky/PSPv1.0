#===
#¤Classe Bitmap
#---
#%Ajout de methodes et Constantes
#---
#© 22/05/2011 - Nuri Yuri (塗 ゆり)
#===
class Bitmap
  Rect_blt=Rect.new(0,0,1,1)
  #===
  #§Draw_text_plus
  #---
  #%Dessine les texts à la pokémon
  #%color est l'id de la couleur, type est le dessin soit tout entouré soit partiellement(0)
  #===
  def draw_text_plus(x,y,w,h,text,align=0,color=0,type=0)
    col_int=Constant::Color_int[color]
    col_ext=Constant::Color_ext[color]
    col_base=self.font.color
    text=text.to_s
    #Dessin de l'exterieur du text
    self.font.color=col_ext
    draw_text(x+1,y,w,h,text,align)
    draw_text(x+1,y+1,w,h,text,align)
    draw_text(x,y+1,w,h,text,align)
    #SI c'est un dessin du type totalement entouré
    if type != 0
      draw_text(x-1,y,w,h,text,align)
      draw_text(x,y-1,w,h,text,align)
      draw_text(x-1,y-1,w,h,text,align)
      draw_text(x-1,y+1,w,h,text,align)
      draw_text(x+1,y-1,w,h,text,align)
    end
    #Dessin de l'interieur du text
    self.font.color=col_int
    draw_text(x,y,w,h,text,align)
    #Fin de la methode
    self.font.color=col_base
    true
  end
  #===
  #§Draw_window
  #---
  #%Dessine une fenêtre
  #%px,py sont les positions dans le bitmap
  #%sw,sh sont les tailles de la fenêtre (variable selon data)
  #%bmp est le bitmap où extraire les bordures de la fenêtre
  #%data est l'array qui informe sur les tailles à prendre pour le découpage.
  #===
  def draw_window(px,py,sw,sh,bmp,data)
    x=px
    y=py
    bord_w=sw-data[0]-data[2]
    bord_h=sh-data[3]-data[5]
    boucle_w=bord_w/data[1]
    boucle_h=bord_h/data[4]
    
    #dessin du bord h-g
    Rect_blt.set(0,0,data[0],data[3])
    blt(x,y,bmp,Rect_blt)
    x+=data[0]
    
    #dessin des bord h-c
    Rect_blt.set(data[0],0,data[1],data[3])
    for i in 0...boucle_w
      blt(x,y,bmp,Rect_blt)
      x+=data[1]
    end
    
    #dessin du bord h-d
    Rect_blt.set(data[0]+data[1],0,data[2],data[3])
    blt(x,y,bmp,Rect_blt)
    x=px
    y+=data[3]
    
    #Dessin de tout le coté c-g
    Rect_blt.set(0,data[3],data[0],data[4])
    for i in 0...boucle_h
      blt(x,y,bmp,Rect_blt)
      y+=data[4]
    end
    x+=data[0]
    y=py+data[3]
    
    #dessin de tout le coté c-c
    Rect_blt.set(data[0],data[3],data[1],data[4])
    for i in 0...boucle_h
      for j in 0...boucle_w
        blt(x,y,bmp,Rect_blt)
        x+=data[1]
      end
      y+=data[4]
      x=px+data[0]
    end
    x=px+data[0]+data[1]*boucle_w
    y=py+data[3]
    
    #dessin de tout le coté c-d
    Rect_blt.set(data[0]+data[1],data[3],data[2],data[4])
    for i in 0...boucle_h
      blt(x,y,bmp,Rect_blt)
      y+=data[4]
    end
    x=px
    y=py+data[3]+data[4]*boucle_h
    
    #dessin du bord b-g
    Rect_blt.set(0,data[3]+data[4],data[0],data[5])
    blt(x,y,bmp,Rect_blt)
    x+=data[0]
    
    #dessin des bord b-c
    Rect_blt.set(data[0],data[3]+data[4],data[1],data[5])
    for i in 0...boucle_w
      blt(x,y,bmp,Rect_blt)
      x+=data[1]
    end
    
    #dessin du bord b-d
    Rect_blt.set(data[0]+data[1],data[3]+data[4],data[2],data[5])
    blt(x,y,bmp,Rect_blt)
    
    true
  end
end