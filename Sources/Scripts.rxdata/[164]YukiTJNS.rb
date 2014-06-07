#===
#Module Yuki::TJNS
#Module permettant de gérer les tons jour/nuit en fonction des saisons
#---
#Crée Par Nagato Yuki
#===
module Yuki
  module TJNS
    SW_INT=8 #Switch interieur
    SW_LIG=9 #Switch de lumière
    SW_MM=10 #Switch indiquand si il fait jour ou nuit
    VAR_H=30 #Variable de l'heure
    VAR_M=31 #Variable des minutes
    VAR_S=32 #Variable des secondes
    VAR_D=33 #Variable des jours
    VAR_MT=34 #Variable des mois
    VAR_Y=35 #Variable des années
    VAR_MM=37 #Variable du moment de la journée
    TONE=[Tone.new(-60, -60, -10, 0), #Nuit
    Tone.new(0, -34, 22, 0), #Matin
    Tone.new(0, 0, 0, 0), #Jour
    Tone.new(17, -34, -17, 0)] #Soir
    ITON=[Tone.new(8, 8, -1, 0),TONE[2],TONE[2],TONE[2]]
    module_function
    def update()
      b1=(Graphics.frame_count%160 != 0)
      b2=(@time!=nil)
      b3=(@int==$game_switches[SW_INT])
      b4=(@lig==$game_switches[SW_LIG])
      return if b1 and b2 and b3 and b4
      @time=Time.now
      @saison=def_saison unless @saison
      $game_variables[VAR_MM]=@moment=def_moment
      @int=$game_switches[SW_INT]
      @lig=$game_switches[SW_LIG]
      if @tone!=@moment or !b4 or !b3
        @tone=@moment
        tn=(@int ? ITON : TONE)
        lu=(@lig ? @tone : 2)
        $game_screen.start_tone_change(tn[lu],5)
      end
      $game_variables[VAR_S]=@time.sec
      $game_variables[VAR_M]=@time.min
      $game_switches[SW_MM]=(@moment != 0)
    end
    
    def def_saison
      $game_variables[VAR_Y]=@time.year
      $game_variables[VAR_MT]=month=@time.month
      $game_variables[VAR_D]=day=@time.day
      day20=(day>20)
      day21=(day<21)
      #Si on est en été
      if month==6 and day20 or
        month>6 and month<9 or
        month==9 and day21
        return 2
      #Si on est en automne
      elsif month==9 and day20 or
        month>9 and month<12 or
        month==12 and day21
        return 3
      #Si on est en hiver
      elsif month==12 and day20 or
        month>0 and month<3 or
        month==3 and day21
        return 4
      #Sinon, printemps
      else
        return 1
      end
    end
    
    def def_moment
      $game_variables[VAR_H]=h=@time.hour
      case @saison
      when 1 #Printemps
        if h<7 or h>19
          return 0
        elsif h>6 and h<10
          return 1
        elsif h>9 and h<18
          return 2
        else 
          return 3
        end
      when 2 #Eté
        if h<6 or h>21
          return 0
        elsif h>5 and h<9
          return 1
        elsif h>8 and h<19
          return 2
        else 
          return 3
        end
      when 3 #Automne
        if h<7 or h>20
          return 0
        elsif h>6 and h<10
          return 1
        elsif h>9 and h<19
          return 2
        else 
          return 3
        end
      else #Hiver
        if h<9 or h>18
          return 0
        elsif h>8 and h<11
          return 1
        elsif h>10 and h<17
          return 2
        else 
          return 3
        end
      end
    end
  end
end