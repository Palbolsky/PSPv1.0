#==============================================================================
# ■ Pokemon_Party
# Pokemon Script Project v1.0 - Palbolsky
# 01/07/2012
#==============================================================================
module Pokemon_S
  class Pokemon_Party
    attr_reader :actors
    attr_reader :player_sexe
    attr_reader :have_dex    
    attr_reader :captured
    attr_reader :seen    
    attr_reader :badge_get
    attr_reader :badge_info
    attr_reader :trainer_id
    attr_reader :secret_id
    attr_reader :begin_date
    attr_reader :date_save
    attr_reader :options
    attr_reader :bag
    
    def initialize
      @actors = []
      @bag = [[],[],[],[],[]]
      @player_sexe = 0
      @have_dex = false
      @captured = Array.new(650,false)
      @seen = Array.new(650,false)
      @badge_get = 0
      @badge_info = Array.new(8)
      @trainer_id = rand(0xffff)
      @secret_id = rand(0xffff)
      @begin_date = Time.new
      @date_save = nil
      @options = [2,true,true] #[msg_spd,animations,style]
      @g_system        = Game_System.new
      @g_switches      = Game_Switches.new
      @g_variables     = Game_Variables.new
      @g_self_switches = Game_SelfSwitches.new
      @g_screen        = Game_Screen.new
      @g_actors        = Game_Actors.new
      @g_party         = Game_Party.new
      @g_troop         = Game_Troop.new
      @g_map           = Game_Map.new
      @g_player        = Game_Player.new
      @g_temp          = Game_Temp.new
      @g_system        = $game_system
      @GameTime=0.0
    end
    
    def create_globals
      $game_system        = @g_system 
      $game_switches      = @g_switches 
      $game_variables     = @g_variables
      $game_self_switches = @g_self_switches
      $game_screen        = @g_screen
      $game_actors        = @g_actors
      $game_party         = @g_party
      $game_troop         = @g_troop
      $game_map           = @g_map
      $game_player        = @g_player
      $game_temp          = @g_temp
      $game_system        = @g_system
      start_game_time
    end
    
    def size
      return @actors.length
    end    
    
    def full?
      return @actors.length == 6
    end
    
    def empty?
      return @actors.length == 0
    end
    
    def add(pokemon)
      if pokemon != nil and @actors.size < 6
        @actors.push(pokemon)
      end
    end
    
    def sexe_choice(id)
      @player_sexe = id
    end
    
    def player_sexe() return @player_sexe end    
    
    def get_dex(v=true)
      @have_dex=v
    end    
    
    def captured(id=-1)
      return @captured if id == -1
      @seen[id] = true
      @captured[id] = true
    end
    
    def seen(id=-1)
      return @seen if id == -1
      @seen[id] = true
    end   
    
    def captured?(id) return @captured[id] end
      
    def seen?(id) return @seen[id] end 
    
    def get_badge(id)
      return false if id > 7
      unless @badge_info[id]
        @badge_info[id] = Time.new
        @badge_get += 1
      end
      return true
    end   
    
    def number_badge() return @badge_get end
      
    def trainer_id() return @trainer_id end
      
    def secret_id() return @secret_id end
    
    def begin_date() return @begin_date end    
    
    def save_date_save
      @date_save = Time.new
    end
    
    def date_save() return @date_save end
    
    def start_game_time()
      @start_game_time=Time.new
    end
    
    def add_game_time()
      time=Time.new
      @GameTime+=(time-@start_game_time)
      @start_game_time=Time.new
    end
    
    def get_game_time() return @GameTime end    
      
    def trainer_name() return @g_actors[1].name end
      
    #------------------------------------------------------------  
    # Gestion Sac
    #  @bag = [ paramètre, [], [], [], [], [] ]
    #  id: id objet, nombre
    #  paramètre : optionnel
    #  @bag[1] : Items, objets simples, Pokéball - [id, nombre]
    #  @bag[2] : Médicaments - [id, nombre]
    #  @bag[3] : CT/CS - [id, nombre]
    #  @bag[4] : Baies - [id, nombre]
    #  @bag[5] : Objets clés - [id, 1]
    #------------------------------------------------------------
    
    #------------------------------------------------------------
    # add_item(id, nombre)
    #   Ajoute un objet
    #------------------------------------------------------------
    def add_item(id, amount=1)
      if PokemonData::Item.load(id).name == ""
        print("Erreur, cet objet n'existe pas.") if $DEBUG
        return
      end
      socket = PokemonData::Item.load(id).socket
      index = bag_list(socket).index(id)
      if index == nil # Ne possède pas cet item
        if Item.holdable?(id)
          @bag[socket].push([id, amount])
        else # Objets rares
          @bag[socket].push([id, 1])
        end
      else
        @bag[socket][index][1] += amount        
        if not Item.holdable?(id) and @bag[socket][index][1] > 1
          @bag[socket][index][1] = 1
        end
        if @bag[socket][index][1] < 0
          @bag[socket][index][1] = 0
        end        
      end         
    end
    
    #------------------------------------------------------------
    # bag_list(socket)
    #  Fonction qui liste les objets déjà possédés
    #------------------------------------------------------------
    def bag_list(socket)
      list = []
      for item in @bag[socket]
        list.push(item[0])
      end
      return list
    end
  end
end