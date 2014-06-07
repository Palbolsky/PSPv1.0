class << Audio
  alias :ogmp :bgm_play
  alias :ogms :bgm_stop
  alias :ogmf :bgm_fade
  alias :ogsp :bgs_play
  alias :ogss :bgs_stop
  alias :ogsf :bgs_fade
  alias :omep :me_play
  alias :omes :me_stop
  alias :omef :me_fade
  alias :osep :se_play
  alias :oses :se_stop
  $USE_FMod=API::read_ini('PSP','Audio')=='FMod'
  def bgm_play(a,b=100,c=100,d=0,f=true)
    $USE_FMod ? FMod.bgm_play(a,b,c,d,f) : ogmp(a,b,c)
  end
  
  def bgm_stop
    $USE_FMod ? FMod.bgm_stop : ogms
  end
  
  def bgm_fade(a)
    $USE_FMod ? FMod.bgm_fade(a) : ogmf(a)
  end
  
  def bgs_play(a,b=100,c=100,d=0,f=true)
    $USE_FMod ? FMod.bgs_play(a,b,c,d,f) : ogsp(a,b,c)
  end
  
  def bgs_stop
    $USE_FMod ? FMod.bgs_stop : ogss
  end
  
  def bgs_fade(a)
    $USE_FMod ? FMod.bgs_fade(a) : ogsf(a)
  end
  
  def me_play(a,b=100,c=100,d=0,f=true)
    $USE_FMod ? FMod.me_play(a,b,c,d,f) : omep(a,b,c)
  end
  
  def me_stop
    $USE_FMod ? FMod.me_stop : omes
  end
  
  def me_fade(a)
    $USE_FMod ? FMod.me_fade(a) : omef(a)
  end
  
  def se_play(a,b=100,c=100)
    $USE_FMod ? FMod.se_play(a,b,c) : osep(a,b,c)
  end
  
  def se_stop
    $USE_FMod ? FMod.se_stop : oses
  end
end