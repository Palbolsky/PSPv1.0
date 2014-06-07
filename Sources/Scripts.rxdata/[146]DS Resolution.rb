#==============================================================================
# ■ DS Résolution
# Pokemon Script Project v1.0 - Palbolsky
# Intégré le 27/04/2012
# Créé par Nagato Yuki (alias Nuri Yuri)
#------------------------------------------------------------------------------
#¤Classe Tilemap  
#---  
#%Création de Map avec les une taille de Tile choisie.  
#%/!\ Le centrage n'est pas fonction des Characters donc veillez  
#     à bien positionner les characters dans leur positions virtuelles.  
#---  
#© 09/11/2010 - Nuri Yuri (塗 ゆり) Version Projet Communautaire  
#© 10/10/2011 - Nuri Yuri (塗 ゆり) Amélioration, correction de bugs.  
#© 25/10/2011 - Nuri Yuri (塗 ゆり) Correctiondu problème avec les tiles en supériorité 1.  
#© 15/11/2011 - Nuri Yuri (塗 ゆり) Alègissement des methodes, modification de la méthode   
#                                  de dessin des autotiles  
#===  
class Tilemap  
  #===  
  #%Déclaration des attributs.  
  #===  
  attr_accessor :viewport, :ox, :oy, :tileset, :autotiles, :update_count  
  attr_accessor :map_data, :priorities, :visible  
  #===  
  #%Déclaration des constantes  
  #===  
  Default_Tile_Size_x=16  
  Default_Tile_Size_y=16  
  Default_Update_Count=10  
  Autotiles = [  
    [ [27, 28, 33, 34], [ 5, 28, 33, 34], [27,  6, 33, 34], [ 5,  6, 33, 34],  
      [27, 28, 33, 12], [ 5, 28, 33, 12], [27,  6, 33, 12], [ 5,  6, 33, 12] ],  
    [ [27, 28, 11, 34], [ 5, 28, 11, 34], [27,  6, 11, 34], [ 5,  6, 11, 34],  
      [27, 28, 11, 12], [ 5, 28, 11, 12], [27,  6, 11, 12], [ 5,  6, 11, 12] ],  
    [ [25, 26, 31, 32], [25,  6, 31, 32], [25, 26, 31, 12], [25,  6, 31, 12],  
      [15, 16, 21, 22], [15, 16, 21, 12], [15, 16, 11, 22], [15, 16, 11, 12] ],  
    [ [29, 30, 35, 36], [29, 30, 11, 36], [ 5, 30, 35, 36], [ 5, 30, 11, 36],  
      [39, 40, 45, 46], [ 5, 40, 45, 46], [39,  6, 45, 46], [ 5,  6, 45, 46] ],  
    [ [25, 30, 31, 36], [15, 16, 45, 46], [13, 14, 19, 20], [13, 14, 19, 12],  
      [17, 18, 23, 24], [17, 18, 11, 24], [41, 42, 47, 48], [ 5, 42, 47, 48] ],  
    [ [37, 38, 43, 44], [37,  6, 43, 44], [13, 18, 19, 24], [13, 14, 43, 44],  
      [37, 42, 43, 48], [17, 18, 47, 48], [13, 18, 43, 48], [ 1,  2,  7,  8] ] ]  
  #===  
  #§Initialisation du Tilemap  
  #---  
  #%Aupdate_count est l'écart entre les mise à jour d'autotiles en frames.  
  #===  
  def initialize(viewport=false)  
    @viewport=viewport  
    @visible=true  
    @dispose=false  
    @update_count=Default_Update_Count  
    set_tile_zoom(Default_Tile_Size_x,Default_Tile_Size_y)  
    @Layers=Array.new(6) #Sprites des supériorités 0 2 3 4 5  
    @SpLayers=[] #Sprites en sup 1  
    @AtSprites={} #Sprites autotiles.  
    @bitmap_tiles=[] #Bitmaps des tiles calculés.  
    @autotile_update_ids=[] # tableau des id autotiles a mettre a jour  
    @autotile_max_count=[] # tableau contenant le nombre de frammes par autotiles  
    @autotiles=[]  
    @rect=Rect.new(0, 0, 32, 32)  
    @dest_rect = Rect.new(0, 0, @tile_size_x, @tile_size_y)  
    @rect_at=Rect.new(0,0, @tile_size_x, @tile_size_y)  
    @dest_recta=Rect.new(0,0,32,32)  
    @recta=Rect.new(0,0,32,32)  
    @autotile_bmp=Bitmap.new(320,32) #Bitmap de collage d'un autotile pas  plus de 10 frame  
  end  
    
  #===  
  #§Mise à jour du Tilemap  
  #===  
  def update(forced=false)  
    @ox /= @tile_zoom_x  
    @oy /= @tile_zoom_y  
    unless @tiled  
      @tiled=true  
      create_map  
    end  
    update_pos  
  end  
    
  #===  
  #§Dessin de la Map et detection du nombre max de frammes.  
  #===  
  def create_map  
    7.times{|i|  
      @autotile_max_count[i] = @autotiles[i].width / 96  
    }  
    @map_data.zsize.times{|c|  
      @map_data.xsize.times{|x|  
        @map_data.ysize.times{|y|  
          id = @map_data[x, y, c]  
          next if id == 0  
          z = @priorities[id]  
          next unless z  
          id < 384 ? sprite_at2(x, y, z, c, id) : sprite_t(x, y, z, c, id)  
        }  
      }  
    }  
  end  
    
  #===  
  #§Sprite_t  
  #---  
  #%Création d'un sprite de tiles/collage de tiles sur ce sprite.  
  #===  
  def sprite_t(x,y,z,c,id)  
    if z==1  
      sprite_t!(x,y,z,c,id)  
      return  
    end  
    unless @Layers[z]  
      sprite=@Layers[z]=Sprite.new(@viewport)  
      sprite.z = z*150  
      sprite.bitmap=Bitmap.new(@map_data.xsize*@tile_size_x,@map_data.ysize*@tile_size_y)  
      sprite.visible=@visible  
    else  
      sprite=@Layers[z]  
    end  
    unless @bitmap_tiles[id]  
      @rect.x=(id - 384) % 8 * 32  
      @rect.y=(id - 384) / 8 * 32  
      @bitmap_tiles[id]=Bitmap.new(@tile_size_x, @tile_size_y)  
      @bitmap_tiles[id].stretch_blt(@dest_rect, @tileset, @rect)  
    end  
    sprite.bitmap.blt(x*@tile_size_x,y*@tile_size_y,@bitmap_tiles[id],@dest_rect)  
  end  
    
  #===  
  #§Dessin des tiles en *1  
  #===  
  def sprite_t!(x,y,z,c,id)  
    unless @SpLayers[y]  
      sprite=@SpLayers[y]=Sprite.new(@viewport)  
      sprite.y = @tile_size_y*y  
      sprite.bitmap=Bitmap.new(@map_data.xsize*@tile_size_x,@tile_size_y)  
      sprite.visible=@visible  
    else  
      sprite=@SpLayers[y]  
    end  
    unless @bitmap_tiles[id]  
      @rect.x=(id - 384) % 8 * 32  
      @rect.y=(id - 384) / 8 * 32  
      @bitmap_tiles[id]=Bitmap.new(@tile_size_x, @tile_size_y)  
      @bitmap_tiles[id].stretch_blt(@dest_rect, @tileset, @rect)  
    end  
    sprite.bitmap.blt(x*@tile_size_x,0,@bitmap_tiles[id],@dest_rect)  
  end  
    
  #===  
  #§Detection du type d'autotile à dessiner.  
  #---  
  #Si c'est un autotile à une frame ça le considère comme un tile  
  #===  
  def sprite_at2(x,y,z,c,id)  
    if @autotile_max_count[id / 48 - 1]==1  
      unless @bitmap_tiles[id]  
        @rect.x=@rect.y=0  
        bitmap=get_autotile_bmp(id)  
        @bitmap_tiles[id]=Bitmap.new(@tile_size_x, @tile_size_y)  
        @bitmap_tiles[id].stretch_blt(@dest_rect, bitmap, @rect)  
      end  
      sprite_t(x,y,z,c,id)  
    else  
      sprite_at(x,y,z,c,id)  
    end  
  end  
  
  #===  
  #§Dessin d'autotile  
  #===  
  def sprite_at(x,y,z,c,id)  
    sprite=Sprite.new(@viewport)  
    sprite.x = x*@tile_size_x  
    sprite.y = y*@tile_size_y  
    sprite.z = z*150  
    sprite.visible=@visible  
    @AtSprites[sprite]=id  
    unless @bitmap_tiles[id]  
      bitmap=get_autotile_bmp(id)  
      @bitmap_tiles[id]=Bitmap.new(@dest_recta.width, @tile_size_y)  
      @bitmap_tiles[id].stretch_blt(@dest_recta, bitmap, @recta)  
    end  
    sprite.bitmap=@bitmap_tiles[id]  
    sprite.src_rect.width=@tile_size_x  
  end  
    
  #===  
  #§Capture du Bitmap d'un Autotile.  
  #===  
  def get_autotile_bmp(id)  
    autotile = @autotiles[id / 48 - 1]  
    return autotile if autotile.width < 96  
    id %= 48  
    bitmap=@autotile_bmp  
    bitmap.clear  
    tiles = Autotiles[id / 8][id % 8]  
    frames = autotile.width / 96  
    @recta.set(0,0,frames*32,32)  
    @dest_recta.set(0,0,frames*@tile_size_x,@tile_size_y)  
    (frames).times { |x|  
      anim = x % frames * 96  
      4.times{|i|  
        tile_position = tiles[i] - 1  
        @rect_at.set(tile_position % 6 * 16 + anim, tile_position / 6 * 16, 16, 16)  
        bitmap.blt(i % 2 * 16 + x*32, i / 2 * 16, autotile, @rect_at)  
      }  
    }  
    return bitmap  
  end  
    
  #===  
  #§Mise à jour des positions des Sprites du Tilemap  
  #===  
  def update_pos  
    @Layers.each { |i|  
      next unless i  
      i.ox=@ox  
      i.oy=@oy  
    }  
    @map_data.ysize.times { |y|  
      i = @SpLayers[y]  
      next unless i  
      i.z=(y*128 - $game_map.display_y + 3) / 4 + 32 +32  
      i.ox=@ox  
      i.oy=@oy  
    }  
    bool=(Graphics.frame_count % @update_count == 0)  
    @AtSprites.each_key {|i|  
      next unless i  
      id = @AtSprites[i]  
      i.ox=@ox  
      i.oy=@oy  
      i.src_rect.x=@tile_size_x*((Graphics.frame_count / @update_count) % @autotile_max_count[id / 48 - 1]) if bool  
    }  
  end  
    
  #===  
  #§Effacement du Tilemap  
  #===  
  def dispose  
    @Layers.each {|i|  
      next unless i  
      i.bitmap.dispose if i.bitmap  
      i.dispose}  
    @map_data.ysize.times{ |y|  
      i = @SpLayers[y]  
      next unless i  
      i.bitmap.dispose if i.bitmap  
      i.dispose  
    }  
    @AtSprites.each_key {|i|  
      next unless i  
      i.bitmap.dispose if i.bitmap  
      i.dispose}  
    @bitmap_tiles.each{|i|  
      i.dispose if i  
    }  
    @AtSprites.clear  
    @Layers.clear  
    @SpLayers.clear  
    @bitmap_tiles.clear  
    GC.start  
    @dispose=true  
  end  
    
  #===  
  #§Disposed?  
  #===  
  def disposed?  
    return @dispose  
  end  
    
  #===  
  #§Changement de dimentions du Tilemap  
  #===  
  def resize_tiles(x=16,y=16)  
    dispose  
    set_tile_zoom(x,y)  
    @dest_rect = Rect.new(0, 0, @tile_size_x, @tile_size_y)  
    create_map  
    @dispose=false  
  end  
    
  #===  
  #§Modification des varables size et zoom  
  #===  
  def set_tile_zoom(tile_size_x,tile_size_y)  
    @tile_size_x=tile_size_x  
    @tile_size_y=tile_size_y  
    @tile_zoom_x=(tile_size_x > 32 ? 32/tile_size_x.to_f : 32/tile_size_x)  
    @tile_zoom_y=(tile_size_y > 32 ? 32/tile_size_y.to_f : 32/tile_size_y)  
  end  
end  
  
#===  
#¤Ajout de l'attribut Tilemap dans Spriteset_Map pour un acces plus simple.  
#===  
class Spriteset_Map  
  attr_accessor :tilemap  
end  
  
#===  
#¤Ajout de l'attribut Spriteset dans Scene_Map,   
# cet attribut n'existe pas sur les versions d'RMXP  
#===  
class << Scene_Map  
  attr_accessor :spriteset  
end  