#==============================================================================
# ** Interpreter (psp part 1)
#------------------------------------------------------------------------------
#  This interpreter runs event commands. This class is used within the
#  Game_System class and the Game_Event class.
#==============================================================================

class Interpreter
  #===
  #§ Lancement d'un message
  #0 => Première ligne
  #1 => Seconde ligne
  #2 => Message qui se termine
  #3 => Effacement de la boite de dialogue
  #4 => Position (0 bas 1 milieur 2 Haut.)
  #5 => Affichage de l'arrow
  #===
  def psp_message_st(defile=false,trans=true)
    var=@parameters
    message=var[0]+(var[1] ? "\n"+var[1].to_s : PSP::S_Nil)
    case var[4]
    when 1
      y=90
    when 2
      y=19
    else
      y=162
    end
    Yuki::ShowMSG.run(message,6,y,1000,defile,trans,var[2],var[3],var[5])
    return @psp_msg=true
  end
  def continue_msg
    @parameters[1]=nil
    return psp_message_st(true,false)
  end
end