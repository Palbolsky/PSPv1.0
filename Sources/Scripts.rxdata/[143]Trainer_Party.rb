#==============================================================================
# ■ Trainer_Party
# Pokemon Script Project v1.0 - Palbolsky
# 28/10/2012
#------------------------------------------------------------------------------

module Pokemon_Battle
  class Trainer_Party < Pokemon_S::Pokemon_Party
    attr_reader :actors
    
    def initialize
      @actors = []
    end
    
    def add(pokemon)
      if pokemon != nil and @actors.size < 6
        @actors.push(pokemon)
      end
    end
    
  end  
end