#==============================================================================
# ■ Pokemon_Item
# Pokemon Script Project v1.0 - Palbolsky
# 02/05/2013
#==============================================================================
module Pokemon_S
  class Item
    #------------------------------------------------------------
    # map_usable?(id)
    # Fonction qui vérifie si un objet peut être utilisé sur la map
    #------------------------------------------------------------
    def self.map_usable?(id)
      PokemonData::Item.load(id).map_usable == 1 ? (return true) : (return false)
    end
    
    #------------------------------------------------------------
    # battler_usable?(id)
    # Fonction qui vérifie si un objet peut être utilisé en combat
    #------------------------------------------------------------
    def self.battler_usable?(id)
      PokemonData::Item.load(id).battler_usable == 1 ? (return true) : (return false)
    end
    
    #------------------------------------------------------------
    # use_on_pokemon?(id)
    # Fonction qui vérifie si un objet peut être utilisé sur un Pokémon
    #------------------------------------------------------------
    def self.use_on_pokemon?(id)
      PokemonData::Item.load(id).use_on_pokemon == 1 ? (return true) : (return false)
    end
    
    #------------------------------------------------------------
    # holdable?(id)
    #  Fonction qui vérifie si un objet peut être tenu
    #------------------------------------------------------------
    def self.holdable?(id)
      PokemonData::Item.load(id).holdable == 1 ? (return true) : (return false)
    end
    
    #------------------------------------------------------------
    # ball?(id)
    #  Fonction qui vérifie si l'objet est une Ball
    #------------------------------------------------------------
    def self.ball?(id)
      return PokemonData::Item.load(id).name.include?(" Ball")
    end
  end
end
