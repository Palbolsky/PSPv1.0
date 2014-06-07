#==============================================================================
# ■ Skill_Data
# Pokemon Script Project v1.0 - Nagato Yuki
# 01/05/2012
#==============================================================================
module PokemonData
  Skill=Struct.new(:name,:type,:pp,:power,:prec,:class,:desc,:anim_id1,:anim_id2,
  :ccrs_type,:ccrs_power,:ccrs_desc)
  #===
  #>Construction des méthode d'aide à l'utilisation de cette structure
  #===
  class Skill
    #>Constantes classiques
    RAW="Data/Skill/%03d"
    @@Data=[]
    #>Classe en mode Debug
    if $DEBUG
      INI=".//Data/Skill/%03d.ini"
      CAT="Skill"
      ERROR="Erreur lors du chargement du data attaque %03d, le membre %s est erronné : %s"
      Members=self.members
      Members.size.times do |i|
        Members[i]=Members[i].to_s
      end
      #>Types des valeurs
      #1 = string 2 = int 3 = float 4 = eval
      Types=[1,2,2,2,2,2,1,2,2,2,2,1]
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