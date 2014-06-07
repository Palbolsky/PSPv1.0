#===
# Pokemon:IV&EV
#---
# Ecrit par Nagato Yuki & Palbolsky
#===
module Pokemon_S
  class Pokemon
    Natures=[["Hardi", 100,100,100,100,100, "", "Mange tout de bon coeur"],
    ["Solo", 110,90,100,100,100, "épicés", "Aime les aliments "],
    ["Brave", 110,100,90,100,100, "épicés", "Aime les aliments "],
    ["Rigide", 110,100,100,90,100, "épicés", "Aime les aliments "],
    ["Mauvais", 110,100,100,100,90, "épicés", "Aime les aliments "],
    ["Assuré", 90,110,100,100,100, "acides", "Aime les aliments "],
    ["Docile", 100,100,100,100,100, "", "Mange tout de bon coeur"],
    ["Relax", 100,110,90,100,100, "acides", "Aime les aliments "],
    ["Malin", 100,110,100,90,100, "acides", "Aime les aliments "],
    ["Laxiste", 100,110,100,100,90, "acides", "Aime les aliments "],
    ["Timide", 90,100,110,100,100, "sucrés", "Aime les aliments "],
    ["Pressé", 100,90,110,100,100, "sucrés", "Aime les aliments "],
    ["Sérieux", 100,100,100,100,100, "", "Mange tout de bon coeur"],
    ["Jovial", 100,100,110,90,100, "sucrés", "Aime les aliments "],
    ["Naif", 100,100,110,100,90, "sucrés", "Aime les aliments "],
    ["Modeste", 90,100,100,110,100, "secs", "Aime les aliments "],
    ["Doux", 100,90,100,110,100, "secs", "Aime les aliments "],
    ["Discret", 100,100,90,110,100, "secs", "Aime les aliments "],
    ["Bizarre", 100,100,100,100,100, "", "Mange tout de bon coeur"],
    ["Foufou", 100,100,100,110,90, "secs", "Aime les aliments "],
    ["Calme", 90,100,100,100,110, "amers", "Aime les aliments "],
    ["Gentil", 100,90,100,100,110, "amers", "Aime les aliments "],
    ["Malpoli", 100,100,90,100,110, "amers", "Aime les aliments "],
    ["Prudent", 100,100,100,90,110, "amers", "Aime les aliments "],
    ["Pudique", 100,100,100,100,100, "", "Mange tout de bon coeur"]]
    
    def nature
      return Natures[@nature][0]
    end        
    #------------------------------------------------------------    
    # Planchers
    #------------------------------------------------------------    
    def maxhp_basis
      base_hp = PokemonData::Pokemon.load(@id).base_hp
      return Integer((@iv_hp+2*base_hp+@hp_plus/4.0)*@level/100)+@level+10
    end
    alias max_hp maxhp_basis
    
    def atk_basis
      base_atk = PokemonData::Pokemon.load(@id).base_atk
      n = Integer((@iv_atk+2*base_atk+@atk_plus/4.0)*@level/100)+5
      return Integer(n * Natures[@nature][1] / 100.0)     
    end
    
    def dfe_basis
      base_dfe = PokemonData::Pokemon.load(@id).base_dfe
      n = Integer((@iv_dfe+2*base_dfe+@dfe_plus/4.0)*@level/100)+5
      return Integer(n * Natures[@nature][2] / 100.0)
    end
    
    def spd_basis
      base_spd = PokemonData::Pokemon.load(@id).base_spd
      n = Integer((@iv_spd+2*base_spd+@spd_plus/4.0)*@level/100)+5
      return Integer(n * Natures[@nature][3] / 100.0)
    end
    
    def ats_basis
      base_ats = PokemonData::Pokemon.load(@id).base_ats
      n = Integer((@iv_ats+2*base_ats+@ats_plus/4.0)*@level/100)+5
      return Integer(n * Natures[@nature][4] / 100.0)
    end    
    
    def dfs_basis
      base_dfs = PokemonData::Pokemon.load(@id).base_dfs
      n = Integer((@iv_dfs+2*base_dfs+@dfs_plus/4.0)*@level/100)+5
      return Integer(n * Natures[@nature][5] / 100.0)
    end
    
    # Bonus EV pour celui qui a mis KO le pokémon adverse
    def add_bonus(battle_list)
      points = 0
      for i in battle_list
        points += i
      end
      if total_ev + points <= 510
        if @hp_plus + battle_list[0] <= 255
          @hp_plus += battle_list[0]
        end
        if @atk_plus + battle_list[1] <= 255
          @atk_plus += battle_list[1]
        end
        if @dfe_plus + battle_list[2] <= 255
          @dfe_plus += battle_list[2]
        end
        if @spd_plus + battle_list[3] <= 255
          @spd_plus += battle_list[3]
        end
        if @ats_plus + battle_list[4] <= 255
          @ats_plus += battle_list[4]
        end
        if @dfs_plus + battle_list[5] <= 255
          @dfs_plus += battle_list[5]
        end
        return true
      else
        return false
      end
    end
    
    def total_ev
      return @hp_plus + @atk_plus + @dfe_plus + @spd_plus + @ats_plus + @dfs_plus
    end
    
    def drop_loyalty(amount = 1)
      @loyalty -= amount
      if @loyalty < 0
        @loyalty = 0
      end
    end
    
    def raise_loyalty(amount = 0)
      if amount == 0
        if @loyalty < 100
          @loyalty += 5
        elsif @loyalty < 200
          @loyalty += 3
        elsif @loyalty < 255
          @loyalty += 2
        end
        if @loyalty > 255
          @loyalty = 255
        end
      else
        @loyalty += amount
      end
    end
    
    def ev_hp() PokemonData::Pokemon.load(id).ev_hp end
    def ev_atk() PokemonData::Pokemon.load(id).ev_atk end
    def ev_dfe() PokemonData::Pokemon.load(id).ev_dfe end
    def ev_spd() PokemonData::Pokemon.load(id).ev_spd end
    def ev_ats() PokemonData::Pokemon.load(id).ev_ats end
    def ev_dfs() PokemonData::Pokemon.load(id).ev_dfs end
      
    def modifier_stage(stage)
      if stage >= 0
        return (2+stage)/2.0
      elsif stage < 0
        return 2.0/(2-stage)
      end
    end
    
    def atk_modifier
      n = 1 * modifier_stage(atk_stage)
      n *= 0.5 if burn?
      return n
    end
    
    def dfe_modifier
      n = 1 * modifier_stage(dfe_stage)
      return n
    end    
    
    def spd_modifier
      n = 1 * modifier_stage(spd_stage)
      n *= 0.25 if paralyzed?
      return n
    end    

    def ats_modifier
      n = 1 * modifier_stage(ats_stage)
      return n
    end    

    def dfs_modifier
      n = 1 * modifier_stage(dfs_stage)
      return n
    end
    
    # Modification des DV
    def dv_modifier(list)
      @dv_hp = list[0]
      @dv_atk = list[1]
      @dv_dfe = list[2]
      @dv_spd = list[3]
      @dv_ats = list[4]
      @dv_dfs = list[5]
      statistic_refresh
      @hp = max_hp
    end
    
    def statistic_refresh
      @atk = Integer(atk_basis * atk_modifier)
      @dfe = Integer(dfe_basis * dfe_modifier)
      @spd = Integer(spd_basis * spd_modifier)
      @ats = Integer(ats_basis * ats_modifier)
      @dfs = Integer(dfs_basis * dfs_modifier)
    end
    
    def atk_stage() return @battle_stage[0] end
    def dfe_stage() return @battle_stage[1] end
    def spd_stage() return @battle_stage[2] end
    def ats_stage() return @battle_stage[3] end
    def dfs_stage() return @battle_stage[4] end
    def eva_stage() return @battle_stage[5] end
    def acc_stage() return @battle_stage[6] end
  end
end