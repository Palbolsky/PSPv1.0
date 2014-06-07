#==============================================================================
# ■ Pokemon_Data
# Pokemon Script Project v1.0 - Nagato Yuki
# 01/05/2012
#==============================================================================
module PokemonData
  Buffer="\x00"*256
  
  Pokemon=Struct.new(:name, :id_bis, :base_hp, :base_atk, :base_dfe, :base_spd, 
  :base_ats, :base_dfs, :skills_list, :skills_level, :skills_tech, :ability_list, 
  :evolution, :evolvelevel, :evolvebyitem, :evolvebytrade, :evolvebyloyalty, 
  :evolvebyperiod, :evolvebyplace, :base_exp, :exp_type, :type1, :type2, :rareness, 
  :female_rate, :base_loyalty, :breed_group, :hatch_step, :ev_hp, :ev_atk, :ev_dfe, 
  :ev_spd, :ev_ats, :ev_dfs, :descr, :spec, :height, :weight)
  #===
  #>Construction des méthode d'aide à l'utilisation de cette structure
  #===
  class Pokemon
    #>Constantes classiques
    RAW="Data/Pokemon/%03d"
    @@Data=[]
    #>Classe en mode Debug
    if $DEBUG
      INI=".//Data/Pokemon/%03d.ini"
      CAT="Pokemon"
      ERROR="Erreur lors du chargement du data Pokémon %03d, le membre %s est erronné : %s"
      Members=self.members
      Members.size.times do |i|
        Members[i]=Members[i].to_s
      end
      #>Types des valeurs
      #1 = string 2 = int 3 = float 4 = eval
      Types=[1,2,2,2,2,2,2,2,4,4,4,4,4,2,4,4,2,2,4,2,2,2,2,2,3,2,4,2,2,2,2,2,2,2,1,1,3,3]
      #===
      #>Sauvegarde du fichier
      #===
      def save(id,rawonly=false)
        #Sauvegarde brute
        vals=self.values
        save_data(vals,sprintf(RAW,id))
        return if rawonly
        #Sauvegarde de l'ini
        fn=sprintf(INI,id)
        Members.size.times do |i|
          API::WPPS.call(CAT,Members[i],vals[i].inspect,fn)
        end
      end
      #===
      #>Chargement du fichier
      #===
      def self.load(id)
        unless @@Data[id]
          #Chargement de l'ini
          fn=sprintf(INI,id)
          arr=Array.new(Members.size)
          Members.size.times do |i|
            Buffer.new_clear
            API::GPPS.call(CAT,Members[i],nil,Buffer,256,fn)
            case Types[i]
            when 2
              arr[i]=Buffer.to_i
            when 3
              arr[i]=Buffer.to_f
            when 4
              begin
                arr[i]=eval(Buffer)
              rescue
                arr[i]=nil
                print(sprintf(ERROR,id,Members[i],Buffer))
              end
            else
              arr[i]=Buffer.strip
            end
          end
          @@Data[id]=self.new(*arr)
        end
        return @@Data[id]
      end
    #>Classe Hors debug.
    else
      #===
      #>Chargement du fichier
      #===
      def self.load(id)
        unless @@Data[id]
          @@Data[id]=self.new(*load_data(sprintf(RAW,id)))
        end
        return @@Data[id]
      end
    end    
  end
end