#===
# Pokemon:Skill
#---
# Ecrit par Nagato Yuki
#===
module Pokemon_S
  class Pokemon
    def init_skills
      index=0
      skills_list=PokemonData::Pokemon.load(id).skills_list
      skills_level=PokemonData::Pokemon.load(id).skills_level
      1.step(@level) do |l|
        if pos=skills_level.index(l)
          if index==4
            @skills[0,3]=nil
            @skills.compact!
            index=3
          end
          id=skills_list[pos]
          @skills_learn.push(id) unless @skills_learn.include?(id)
          ppmax=PokemonData::Skill.load(id).pp
          @skills[index*3]=id
          @skills[index*3+2]=@skills[index*3+1]=ppmax
          index+=1 if index<4
        end
      end
    end
    
    def add_skill(id)
      index=4
      0.step(11,3) do |i| 
        if @skills[i]==0
          index=i
          break
        end
        return false if @skills[i]==id
      end
      if index==4
        @skills[0,3]=nil
        @skills.compact!
        index=3
      end
      @skills_learn.push(id) unless @skills_learn.include?(id)
      ppmax=PokemonData::Skill.load(id).pp
      @skills[index*3]=id
      @skills[index*3+2]=@skills[index*3+1]=ppmax
      return true
    end
    
    def replace_skill(i,id)
      return if have_skill?(id)
      @skills[i*3]=id
      ppmax=PokemonData::Skill.load(id).pp
      @skills[index*3+2]=@skills[index*3+1]=ppmax
    end
    
    def forget_skill(i)
      @skills[i*3]=@skills[i*3+2]=@skills[i*3+2]=nil
      @skills.compact!
      @skills.push(0,0,0)
    end
    
    def have_skill?(id)
      0.step(11,3) do |i|
        return true if @skills[i]==id
      end
      return false
    end
    
    def pp_plus(i)
      id=@skills[i*3]
      return 0 if id==0
      ppmax=PokemonData::Skill.load(id).pp
      pp=@skills[i*3+2]-ppmax
      return (pp/(ppmax*0.2)).to_i
    end
  end
end