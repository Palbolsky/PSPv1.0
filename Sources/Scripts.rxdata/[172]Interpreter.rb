#==============================================================================
# ■ Interpreter
# Pokemon Script Project v1.0 - Palbolsky
# 01/07/2012
#------------------------------------------------------------------------------

class Interpreter  
  include Pokemon_S
  MOIS=[nil,"jan.","fév.","mars","avr.","mai","juin","jui.","août","sep.","oct.","nov.","déc."]
  #-----------------------------------------------------------------------------
  # add_pokemon(id_data, level, shiny)
  #   Ajout d'un Pokémon dans l'équipe
  #----------------------------------------------------------------------------- 
  def add_pokemon(id, level = 1, shiny = false, form = 0, egg = false)    
    pokemon = Pokemon.new(id, level, shiny, form, egg)
    $pokemon_party.add(pokemon)             
    $pokemon_party.captured(id)
  end
  alias ajouter_pokemon add_pokemon
  
  #-----------------------------------------------------------------------------
  # choisir_sexe(id)
  #   Choix du sexe du héros ; 0 = Garçon, 1 = Fille
  #-----------------------------------------------------------------------------
  def sexe_choice(id)
    $pokemon_party.sexe_choice(id)
  end  
  alias choisir_sexe sexe_choice
  
  #-----------------------------------------------------------------------------
  # obtenir_badge(id)
  #   Ajout d'un badge
  #-----------------------------------------------------------------------------
  def obtain_badge(id)    
    $pokemon_party.get_badge(id-1)
  end
  alias obtenir_badge obtain_badge
  
  #-----------------------------------------------------------------------------
  # soigner_equipe
  #   Soigne tout les Pokémon de l'équipe
  #-----------------------------------------------------------------------------
  def team_treat # Incomplet
    $pokemon_party.size.times do |i|
      $pokemon_party.actors[i].add_statut(0)
      $pokemon_party.actors[i].hp = $pokemon_party.actors[i].max_hp
    end
  end
  alias soigner_equipe team_treat  
  
  #-----------------------------------------------------------------------------
  # activer_pokedex
  #   Active le Pokédex
  #-----------------------------------------------------------------------------
  def enable_pokedex    
    $pokemon_party.get_dex(true)
  end
  alias activer_pokedex enable_pokedex
  
  #-----------------------------------------------------------------------------
  # demarrer_combat
  #   Permet de lancer un combat contre un Pokémon sauvage, ou un combat simple,
  #   double ou rotatif
  # ----------------------------------------------------------------------------
  # Exemple : demarrer_combat([1],[1],["PSP"],"trainer001.png", 100)
  # Combat 1v1 simple, le dresseur (avec le skin trainer001.png et le nom PSP) à 
  # un Bulbizarre niveau 1, avec une récompense de 100$
  #-----------------------------------------------------------------------------
  def demarrer_combat(id=1,level=1,name="",sprite=nil,money=0,rotatif=false)
    Pokemon_Battle::Core.init(id,level,name,sprite,money,rotatif)
  end
  alias demarrer_combat demarrer_combat
end