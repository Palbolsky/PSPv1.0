#===
# Pokemon:Level
#---
# Ecrit par Nagato Yuki
#===
module Pokemon_S
  class Pokemon
    #====
    #>Calcul de la table d'expérience
    #===
    EXP_TABLE = Array.new(6) do [nil,0] end
    #>Rapide
    2.step(MAX_LEVEL) do |i| EXP_TABLE[0][i]=Integer(0.8*(i**3)) end
    #>Normale
    2.step(MAX_LEVEL) do |i| EXP_TABLE[1][i]=Integer(i**3) end
    #>Lente
    2.step(MAX_LEVEL) do |i| EXP_TABLE[2][i]=Integer(1.25*(i**3)) end
    #>Parabolique
    2.step(MAX_LEVEL) do |i| EXP_TABLE[3][i]=Integer((1.2*(i**3) - 15*(i**2) + 100*i - 140)) end
    #>Erratic
    2.step(50) do |i| EXP_TABLE[4][i] = Integer( i**3*(100-i)/50.0 ) end
    51.step(68) do |i| EXP_TABLE[4][i] = Integer( i**3*(150-i)/100.0 ) end
    69.step(98) do |i| 
      case i%3
      when 0
        EXP_TABLE[4][i] = Integer( i**3 * (1.274 - 1/50 * (i/3) - 0) )
      when 1
        EXP_TABLE[4][i] = Integer( i**3 * (1.274 - 1/50 * (i/3) - 0.008) )
      when 2
        EXP_TABLE[4][i] = Integer( i**3 * (1.274 - 1/50 * (i/3) - 0.014) )
      end
    end
    99.step(MAX_LEVEL) do |i| EXP_TABLE[4][i] = Integer( i**3*(160-i)/100.0 ) end
    #>Fluctuant
    2.step(15) do |i| EXP_TABLE[5][i] = Integer( i**3* (24 + (i+1)/3) / 50  ) end
    16.step(35) do |i| EXP_TABLE[5][i] = Integer( i**3* ( 14 + i) / 50 ) end
    36.step(MAX_LEVEL) do |i| EXP_TABLE[5][i] = Integer( i**3 * ( 32 + (i/2) ) / 50 ) end
    
    def exp_list()
      return EXP_TABLE[PokemonData::Pokemon.load(id).exp_type]
    end
    
    def gain_exp(exp)
      return if @level==MAX_LEVEL
      @exp+=exp
      gain_level if @exp>=exp_list[@level+1]
    end
    
    def level_check
      return false if @level >= MAX_LEVEL
      return @exp >= exp_list[@level+1]
    end
    
    def gain_level(scene=nil)
      @exp = exp_list[@level+1] if @exp < exp_list[@level+1]
      hp_minus = maxhp_basis - @hp
      list0 = [maxhp_basis, atk_basis, dfe_basis, ats_basis, dfs_basis, spd_basis]
      @level += 1
      statistic_refresh
      list1 = [maxhp_basis, atk_basis, dfe_basis, ats_basis, dfs_basis, spd_basis]
      @hp = maxhp_basis - hp_minus
      raise_loyalty
      #Mise à de l'interface de combat pour le niveau.
      scene.level_up(list0, list1) if scene
      gain_level(scene) if level_check
    end
  end
end