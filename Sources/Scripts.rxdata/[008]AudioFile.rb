#===
# AudioFile
#---
# Codé par Nagato Yuki
#===
module RPG
  class AudioFile
    def initialize(name = "", volume = 100, pitch = 100,pos = 0)
      @name = name
      @volume = volume
      @pitch = pitch
      @pos = pos
    end
    attr_accessor :name
    attr_accessor :volume
    attr_accessor :pitch
    attr_accessor :pos
  end
end