class Window_Dataset < Window_Selectable
  #---------------------------------
  def initialize(type)
    super(0, 0, 300, 480)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.back_opacity = 160
    self.contents.font.name = "Arial"
    self.contents.font.size = 24
    @type = type
    if @type == 1
      @item_max = $data_items.size - 1
    end
    if @type == 2
      @item_max = $data_weapons.size - 1
    end
    if @type == 3
      @item_max = $data_armors.size - 1
    end
    refresh
  end
  #---------------------------------
  def refresh
     if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    y = 0
    self.contents = Bitmap.new(width - 32, 32 * @item_max)
    self.contents.clear
    self.contents.font.name = "Arial"
    self.contents.font.size = 24
    self.opacity = 255
    self.back_opacity = 255
    if @type == 1
      for i in 1..$data_items.size - 1
      draw_item_name($data_items[i], 4, i*32 - 32)
      number = $game_party.item_number(i).to_s
      self.contents.draw_text(4, i*32 - 32, 262, 32, number, 2)
      end
    end
     if @type == 2
      for i in 1..$data_weapons.size - 1
      draw_item_name($data_weapons[i], 4, i*32 - 32)
      number = $game_party.weapon_number(i).to_s
      self.contents.draw_text(4, i*32 - 32, 262, 32, number, 2)
    end
    end
    if @type == 3
      for i in 1..$data_armors.size - 1
      draw_item_name($data_armors[i], 4, i*32 - 32)
      number = $game_party.armor_number(i).to_s
      self.contents.draw_text(4, i*32 - 32, 262, 32, number, 2)
    end
    end
  end
#---------------------------------
def update
  super
  end
end

