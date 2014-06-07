#==============================================================================
# ■ Error
# Pokemon Script Project v1.0 - Palbolsky
# Intégré le 27/04/2012
# Créé par Krosk et modifié par Nagato Yuri & Palbolsky
#==============================================================================
if $RGSS_LOADED==nil
  $RGSS_LOADED=false
  module EXC
    AutoSave=false
    PSPVersion="PSP v1.0"
    def self.error_handler(exception, file_arg = nil)     
      if exception.type == SystemExit
        return
      end
      
      if exception.message == "" or exception.type.to_s == "Reset" # Reset        
        raise
      end      
      
      source=exception.backtrace[0].split(":")[0].sub("Section", "").to_i
      if $DEBUG
        source = $RGSS_SCRIPTS[source][1]
      end
      source_line = exception.backtrace[0].split(":")[1]
      
      if file_arg != nil
        file = file_arg
        source = file.path
      end
      if source == "Interpreter Bis" and source_line == "444"
        source = "évènement"
      end
      
      print("Erreur dans le script #{source}, inspectez le rapport Error.log.")
      
      logfile = File.open("Error.log", "w")
      
      # Entete
      logfile.write("---------- Erreur de script : #{source} ----------\n")
      logfile.write("----- Version du logiciel : #{PSPVersion}\n")
      
      # Heure
      logfile.write("----- Heure du bug : " + sprintf("%02d",Time.now().hour) +
      ":" + sprintf("%02d",Time.now().min) + ":" + 
      sprintf("%02d",Time.now().sec) + "\n\n")
      
      # Type
      logfile.write("----- Type\n")
      logfile.write(exception.type.to_s + "\n\n")
      
      # Message
      logfile.write("----- Message\n")
      if exception.type == NoMethodError
        logfile.write("- ARGS - #{exception.args.inspect}\n")
      end
      logfile.write(exception.message + "\n\n")
      
      # Position en fichier
      if file_arg != nil
        logfile.write("----- Position dans #{file.path}\n")
        logfile.write("Ligne #{file.lineno}\n")
        logfile.write(IO.readlines(file.path)[file.lineno-1] + "\n")
      elsif source == "évènement"
        logfile.write("----- Position de l'évènement\n")
        logfile.write($running_script + "\n\n")
      else
        logfile.write("----- Position dans #{source}\n")
        logfile.write("Ligne #{source_line}\n\n")
      end
      
      # Backtrace
      logfile.write("----- Backtrace\n")    
      for trace in exception.backtrace
        location = trace.split(":")
        if location[0]!="(eval)"
          int=location[0].sub("Section", "").to_i
          script_name = $DEBUG ? $RGSS_SCRIPTS[int][1] : int
        else
          script_name = location[0]
        end
        logfile.write("Script : #{script_name} | Ligne : #{location[1]}")
        if location[2] != nil
          logfile.write(" | Méthode : #{location[2]}")
        end
        logfile.write("\n")
      end
      logfile.close
      
      raise
    end
  end
end