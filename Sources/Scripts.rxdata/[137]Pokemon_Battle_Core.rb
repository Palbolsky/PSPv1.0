#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project v1.0 - Palbolsky & Nagato Yuki
# 26/10/2012
#------------------------------------------------------------------------------

module Pokemon_Battle
  module Core
    def self.init(id,level,name,sprite,money,rotatif)
      # Les arguments
      @id = id
      @level = level
      @name = name
      @sprite = sprite
      @money = money
      @rotatif = rotatif
      
      # Récupération de nos 3 premiers pkmn pouvant combattre (KO et oeuf exclus)     
      @actors = []      
      i,j=0,0
      while (i < 3 and j < $pokemon_party.size) 
        if ($pokemon_party.actors[j].dead? or $pokemon_party.actors[j].egg)
          j += 1
        else
          @actors[i] = $pokemon_party.actors[j]
          i += 1
          j += 1       
        end                  
      end   
      if @actors.size == 0
        print("Attention, vous n'avez pas de Pokémon\nou de Pokémon pouvant combattre.") if $DEBUG
        @actors[0] = $pokemon_party.add(Pokemon_S::Pokemon.new(1, 1))   
      end
      
      # Initialisation de l'adversaire
      @enemy = Trainer_Party.new   
      if @id.size > 6
        print("Attention, trop de Pokémon ont été renseignés.\nLes Pokémon en trop seront ignorés.") if $DEBUG
      end
      if @level.size > 6
        print("Attention, trop de niveaux ont été renseignés.\nLes niveaux en trop seront ignorés.") if $DEBUG
      end
      @id.size.times do |i|   
        next if i > 5 # Ignore si plus de 6 Pokémon
        @enemy.actors[i] = Pokemon_S::Pokemon.new(@id[i],@level[i])
      end    
      
      # Initialisation du style de combat 
      if @name.size > 2 # Si il y a plus de 2 noms, on se rapporte à 2 noms
        print("Attention, le nombre de noms est trop élevé (maximum 2).") if $DEBUG        
        (@name.size-2).times do |i|          
          @name[i+2] = nil
        end
        @name.compact!       
      end
        
      case @name.size
      when 2 # Combat dresseur 2v2
        print("Combat 2v2")        
        
      when 1 # Combat dresseur 1v1
        if @rotatif
           print("Combat 1v1 rotatif")
           
        else # combat 1v1 standard          
           Scene_Manager.push(Scene_Simple)
           Scene_Simple.init(@actors,@enemy,@sprite,@name)
        end       
      when 0 # Combat sauvage     
        if @id.size == 1 # Combat sauvage 1v1
          print("Combat sauvage 1v1")
          
        elsif @id.size >= 2 # Combat sauvage 2v2
          print("Combat sauvage 2v2")          
        end     
      end         
    end
    
    def self.round_attack(skill_actor1,skill_actor2=-1)
      @skill_actor = Array.new
      @skill_actor[0] = skill_actor1
      @skill_actor[1] = skill_actor2
      # Qui attaque en premier ?
      
    end
  end
end
