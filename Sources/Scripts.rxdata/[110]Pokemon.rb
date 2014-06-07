#==============================================================================
# ■ Pokemon
# Pokemon Script Project v1.0 - Palbolsky & Nagato Yuki
# 15/05/2012
#------------------------------------------------------------------------------
# La classe Pokemon a été divisée en plusieurs sous scripts
#==============================================================================
module Pokemon_S
  class Pokemon
    attr_reader :id        
    attr_reader :id_bis      
    attr_reader :battler_face   
    attr_reader :battler_back   
    attr_reader :cry           
    attr_reader :icon   
    attr_reader :skills_list
    attr_reader :skills_level
    attr_reader :skills_tech  
    attr_reader :skills_learn
    attr_reader :evolution
    attr_reader :evolvelevel
    attr_reader :evolvebyitem
    attr_reader :evolvebytrade
    attr_reader :evolvebyloyalty
    attr_reader :evolvebyperiod
    attr_reader :evolvebyplace
    attr_reader :base_exp
    attr_reader :exp_type
    attr_reader :exp
    attr_reader :type1
    attr_reader :type2
    attr_reader :rareness
    attr_reader :femele_rate
    attr_reader :base_loyalty
    attr_reader :breed_group
    attr_reader :breed_move
    attr_reader :hatch_step
    attr_reader :ev_hp
    attr_reader :ev_atk
    attr_reader :ev_dfe
    attr_reader :ev_spd
    attr_reader :ev_ats    
    attr_reader :ev_dfs
    attr_reader :descr
    attr_reader :spec
    attr_reader :height
    attr_reader :weight       
    attr_reader :shiny        
    attr_reader :gender
    attr_reader :ability
    attr_reader :egg    
    attr_reader :trainer_id
    attr_reader :trainer_name    
    attr_reader :level    
    attr_reader :hp
    attr_reader :max_hp
    attr_reader :skills #[id,pp,ppmax,etc.]
    attr_reader :atk_basis
    attr_reader :dfe_basis
    attr_reader :spd_basis
    attr_reader :ats_basis
    attr_reader :dfs_basis
    attr_reader :origin
    attr_reader :origin_level
    attr_reader :origin_date
    
    attr_accessor :given_name
    attr_accessor :item_hold      # ID objet tenu
    
    def name
      if @egg
        return "Oeuf"
      end
      return @given_name     
    end
    
    def new_name(string)
      @given_name = string
    end      
  
    def descr
      return PokemonData::Pokemon.load(id).descr
    end
    
    def skills_tech
      return PokemonData::Pokemon.load(id).skills_tech
    end    
    
    def breed_move
      return PokemonData::Pokemon.load(id).breed_move
    end
    
    def breed_group
      return PokemonData::Pokemon.load(id).breed_group
    end    
    
    def hatch_step
      return PokemonData::Pokemon.load(id).hatch_step
    end
    
    def icon
      if @egg
        return RPG::Cache.icon("Pokemon/000.png")
      end
      ida = sprintf("%03d", id)
      icon = RPG::Cache.icon("Pokemon/#{ida}.png")
      return icon
    end    
    
    def battler_face
      ida = sprintf("%03d", id)      
      if @egg
        battle_f = RPG::Cache.battler("Pokemon/Battler_Face/000.png", 0)
        return battle_f
      end      
      if @shiny
        shiny = "_Shiny" 
      else
        shiny = ""
      end      
      if @gender == 1 or @gender == 0
        battle_f = RPG::Cache.battler("Pokemon/Battler_Face"+shiny+"/Front_Male/#{ida}.png", 0)
      elsif @gender == 2
        battle_f = RPG::Cache.battler("Pokemon/Battler_Face"+shiny+"/Front_Femelle/#{ida}.png", 0)
      end      
      return battle_f
    end
    
    def battler_back
      ida = sprintf("%03d", id)      
      if @egg
        battle_b = RPG::Cache.battler("Pokemon/Battler_Back/000.png", 0)
        return battle_b
      end      
      if @shiny
        shiny = "_Shiny" 
      else
        shiny = ""
      end      
      if @gender == 1 or @gender == 0
        battle_b = RPG::Cache.battler("Pokemon/Battler_Back"+shiny+"/Front_Male/#{ida}.png", 0)
      elsif @gender == 2
        battle_b = RPG::Cache.battler("Pokemon/Battler_Back"+shiny+"/Front_Femelle/#{ida}.png", 0)        
      end      
      return battle_b
    end    
    
    def cry
      if @egg
        return ""
      end
      ida = sprintf("%03d", id)
      cry = "Audio/SE/Cries/#{ida}Cry.wav"
      return cry
    end  
    
    def initialize(id = 1, level = 1, shiny = false, form = 0, egg = false)
      @id = id
      @level = level       
      @form = form   #Forme
      @egg = egg
      if shiny # Shiny forcé
        @shiny = true
      else
        @shiny=rand(SHINY_RATE)==1
      end      
      @iv_hp = rand(32)
      @iv_atk = rand(32)
      @iv_dfe = rand(32)
      @iv_spd = rand(32)
      @iv_ats = rand(32)
      @iv_dfs = rand(32)
      if @shiny
        @iv_hp = @iv_hp>16 ? 31 : @iv_hp += 15
        @iv_atk = @iv_atk>16 ? 31 : @iv_atk += 15
        @iv_dfe = @iv_dfe>16 ? 31 : @iv_dfe += 15
        @iv_spd = @iv_spd>16 ? 31 : @iv_spd += 15
        @iv_ats = @iv_ats>16 ? 31 : @iv_ats += 15
        @iv_dfs = @iv_dfs>16 ? 31 : @iv_dfs += 15
      end
      @hp_plus = 0
      @atk_plus = 0
      @dfe_plus = 0
      @ats_plus = 0
      @dfs_plus = 0
      @spd_plus = 0
      @given_name = PokemonData::Pokemon.load(id).name
      @id_bis = PokemonData::Pokemon.load(id).id_bis
      @type1 = PokemonData::Pokemon.load(id).type1
      @type2 = PokemonData::Pokemon.load(id).type2
      @gender = gender_generation                               
      @loyalty = PokemonData::Pokemon.load(id).base_loyalty 
      @ability = ability_generation
      @skills = Array.new(12,0)
      @skills_learn=Array.new
      @code = rand(2**32) 
      @nature = @code % 25  
      @hp = maxhp_basis
      @exp = exp_list[@level]
      @status = 0      
      @origin = $game_map.map_id #ID de la map
      @origin_level = @level
      @origin_date = Time.new
      @trainer_name = $pokemon_party.trainer_name
      @trainer_id = $pokemon_party.trainer_id  
      @item_hold = 0
      init_skills
      reset_stat_stage      
    end  
    
    def gender_generation
      female_rate=PokemonData::Pokemon.load(id).female_rate
      i = rand(1000) # de 0 à 999
      if female_rate == -1
        @gender = 0 # Assexué
      elsif i < (female_rate*10)
        @gender = 2 # Femelle
      else
        @gender = 1 # Mâle
      end
    end
    
    def set_gender(g)
      case g
      when "M",1
        @gender=1
      when "F",2
        @gender=2
      when "I",0
        @gender=0
      end
    end
   
    def ability_generation       
      @ability = PokemonData::Pokemon.load(id).ability_list[rand(PokemonData::Pokemon.load(id).ability_list.size)]       
    end    
    
    def poisoned?() @status == 1 end
    def paralyzed?() @status == 2 end
    def burn?() @status == 3 end
    def sleep?() @status == 4 end
    def frozed?() @status == 5 end
    def toxic?() @status == 6 end
    def dead?() @status == 7 end  
    def confused?() return @confused end
    def flinch?() return @flinch end
    def status() return @status end
      
    def add_status(id, forcing = false) 
       @status = id if @status == 0 or forcing
    end    
    
    def reset_stat_stage
      @battle_stage = [0, 0, 0, 0, 0, 0, 0]
      statistic_refresh
    end    
  end 
end