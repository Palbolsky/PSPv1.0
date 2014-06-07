# Copyright (c) 2005, Kevin Gadd
#==============================================================================
# ** FModEx
#------------------------------------------------------------------------------
#  FMOD Ex binding by Kevin Gadd (janus@luminance.org)
if $USE_FMod
module FModEx
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  # FMOD_INITFLAGS flags
  FMOD_INIT_NORMAL = 0
  # FMOD_RESULT flags
  FMOD_OK = 0
  FMOD_ERR_CHANNEL_STOLEN = 11
  FMOD_ERR_FILE_NOT_FOUND = 23
  FMOD_ERR_INVALID_HANDLE = 36
  # FMOD_MODE flags
  FMOD_DEFAULT = 0
  FMOD_LOOP_OFF = 1
  FMOD_LOOP_NORMAL = 2
  FMOD_LOOP_BIDI = 4
  FMOD_LOOP_BITMASK = 7
  FMOD_2D = 8
  FMOD_3D = 16
  FMOD_HARDWARE = 32
  FMOD_SOFTWARE = 64
  FMOD_CREATESTREAM = 128
  FMOD_CREATESAMPLE = 256
  FMOD_OPENUSER = 512
  FMOD_OPENMEMORY = 1024
  FMOD_OPENRAW = 2048
	FMOD_OPENONLY = 4096
	FMOD_OPENMEMORY_POINT = 0x10000000
  FMOD_ACCURATETIME = 8192
  FMOD_MPEGSEARCH = 16384
  FMOD_NONBLOCKING = 32768
  FMOD_UNIQUE = 65536
  # The default mode that the script uses
  FMOD_DEFAULT_SOFTWARWE = FMOD_LOOP_OFF | FMOD_2D | FMOD_HARDWARE#| FMOD_SOFTWARE
  FMOD_TEST = FMOD_OPENMEMORY | FMOD_SOFTWARE
  # FMOD_CHANNELINDEX flags
  FMOD_CHANNEL_FREE = -1
  FMOD_CHANNEL_REUSE = -2
  # FMOD_TIMEUNIT_flags
  FMOD_TIMEUNIT_MS = 1
  FMOD_TIMEUNIT_PCM = 2
  # The default time unit the script uses
  FMOD_DEFAULT_UNIT = FMOD_TIMEUNIT_MS
  # Types supported by FMOD Ex
  FMOD_FILE_TYPES = ['ogg', 'aac', 'wma', 'mp3', 'wav', 'it', 'xm', 'mod', 's3m', 'mid', 'midi']
  
  #============================================================================
  # ** DLL
  #----------------------------------------------------------------------------
  #  A class that manages importing functions from the DLL
  #============================================================================
  
  class DLL
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #--------------------------------------------------------------------------
    attr_accessor :filename           # DLL file name for instance    
    attr_accessor :functions          # hash of functions imported (by name)
			
    Functions = {}
    Sys_C='System_Create'
    W32_LL = Win32API.new('kernel32.dll', 'LoadLibrary', 'p', 'l')
    FN='fmodex.dll'
    F='f'
    L='l'
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     filename  : Name of the DLL
    #--------------------------------------------------------------------------
    def initialize(filename = FN)
      @filename = filename
      @handle = 0            # Handle to the DLL
      # Load specified library into the address space of game process
      
      @handle = W32_LL.call(filename)
      unless Functions[Sys_C]
      # System functions:
        self.import(Sys_C, 'p')
        self.import('System_Init', 'llll')
        self.import('System_Close', 'l')
        self.import('System_Release', 'l')
        self.import('System_CreateSound', 'lplpp')
        self.import('System_CreateStream', 'lplpp')
        self.import('System_PlaySound', 'llllp')
        # Sound functions:
        self.import('Sound_Release', 'l')
        self.import('Sound_GetMode', 'lp')
        self.import('Sound_SetMode', 'll')
        self.import('Sound_SetLoopPoints', 'lllll')
        self.import('Sound_GetLength', 'lpl')
        # Channel functions:
        self.import('Channel_Stop', 'l')
        self.import('Channel_IsPlaying', 'lp')
        self.import('Channel_GetPaused', 'lp')
        self.import('Channel_SetPaused', 'll')
        self.import('Channel_GetVolume', 'lp')
        self.import('Channel_SetVolume', 'll')
        self.import('Channel_GetPan', 'lp')
        self.import('Channel_SetPan', 'll')
        self.import('Channel_GetFrequency', 'lp')
        self.import('Channel_SetFrequency', 'll')
        self.import('Channel_GetPosition', 'lpl')
        self.import('Channel_SetPosition', 'lll')
      end
    end
    #--------------------------------------------------------------------------
    # * Create a Win32API Object And Add it to Hashtable
    #     name      : Function name
    #     args      : Argument types (p = pointer, l = int, v = void)
    #     returnType: Type of value returned by function
    #--------------------------------------------------------------------------
    def import(name, args = '', returnType = L)
      Functions[name] = Win32API.new(@filename, 'FMOD_' + name, args, returnType)
    end
    #--------------------------------------------------------------------------
    # * Get Function by Name
    #     key       : Function name
    #--------------------------------------------------------------------------
    def [](key)
      return Functions[key]
    end
    #--------------------------------------------------------------------------
    # * Call a Function With Passed Arguments
    #     name      : Function name
    #     args      : Argument to function
    #--------------------------------------------------------------------------
    def invoke(name, *args)
      fn = Functions[name]
      raise "function not imported: #{name}" if fn.nil?
      result = fn.call(*args)
      unless result == FMOD_OK or result == FMOD_ERR_CHANNEL_STOLEN or
        result == FMOD_ERR_FILE_NOT_FOUND
        if result==36
          FMod.se_clean unless $FMOD_CLEANING
        else
          print "FMOD Ex returned error #{result}.\n"
        end
      end
      return result
    end
    #--------------------------------------------------------------------------
    # * Store Float as Binary Int Because Floats Can't be Passed Directly
    #     f         : Float to convert
    #--------------------------------------------------------------------------
    def convertFloat(f)
      # First pack the float in a string as a native binary float
      temp = [f].pack(F)
      # Then unpack the native binary float as an integer
      return unpackInt(temp)
    end
    #--------------------------------------------------------------------------
    # * Unpack Binary Data to Integer
    #     s         : String containing binary data
    #--------------------------------------------------------------------------
    def unpackInt(s)
      return s.unpack(L)[0]
    end
    #--------------------------------------------------------------------------
    # * Unpack Binary Data to Float
    #     s         : String containing binary data
    #--------------------------------------------------------------------------
    def unpackFloat(s)
      return s.unpack(F)[0]
    end
    #--------------------------------------------------------------------------
    # * Unpack Binary Data to Boolean
    #     s         : String containing binary data
    #--------------------------------------------------------------------------
    def unpackBool(s)
      return s.unpack(L)[0] != 0
    end
  end

  #============================================================================
  # ** System
  #----------------------------------------------------------------------------
  #  A class that manages an instance of FMOD::System
  #============================================================================
  
  class System
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #-------------------------------------------------------------------------- 
    attr_accessor :fmod               # Instance of DLL class (fmodex.dll)
    attr_accessor :handle             # Handle (pointer) to System object
    attr_accessor :maxChannels        # Maximum number of channels
    System_Create='System_Create'
    System_Init='System_Init'
    System_CreateSound='System_CreateSound'
    UX="U*"
    CX="C*"
    System_CreateStream='System_CreateStream'
    System_Close='System_Close'
    System_Release='System_Release'
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     fmod            : An instance of DLL class
    #     maxChannels     : Maximum number of used channels
    #     flags           : FMOD_INITFLAGS
    #     extraDriverData : Driver specific data
    #--------------------------------------------------------------------------
    def initialize(theDLL, maxChannels = 32, flags = FMOD_INIT_NORMAL, extraDriverData = 0)
      @fmod = theDLL
      @maxChannels = maxChannels
      # Create and initialize FMOD::System
      temp = 0.chr * 4
      @fmod.invoke(System_Create, temp)
      @handle = @fmod.unpackInt(temp)
      @fmod.invoke(System_Init, @handle, maxChannels, flags, extraDriverData)
    end
    #--------------------------------------------------------------------------
    # * Create FMOD::Sound (fully loaded into memory by default)
    #     filename        : Name of file to open
    #     mode            : FMOD_MODE flags
    #--------------------------------------------------------------------------
    def createSound(filename, mode = FMOD_DEFAULT_SOFTWARWE,struc=0)
      # Create sound and return it
      temp = 0.chr * 4
      result = @fmod.invoke(System_CreateSound, @handle, filename, mode, struc, temp)
      if result == FMOD_ERR_FILE_NOT_FOUND
        result2 = @fmod.invoke(System_CreateSound, @handle, filename.unpack(UX).pack(CX), mode, 0, temp)
        raise "File not found: \"#{filename}\"" if result2 == FMOD_ERR_FILE_NOT_FOUND
      end
      newSound = Sound.new(self, @fmod.unpackInt(temp))
      return newSound
    end
    #--------------------------------------------------------------------------
    # * Create Streamed FMOD::Sound (chunks loaded on demand)
    #     filename        : Name of file to open
    #     mode            : FMOD_MODE flags
    #--------------------------------------------------------------------------
    def createStream(filename, mode = FMOD_DEFAULT_SOFTWARWE,struc=0)
      # Create sound and return it
      temp = 0.chr * 4
      result = @fmod.invoke(System_CreateStream, @handle, filename, mode, struc, temp)
      if result == FMOD_ERR_FILE_NOT_FOUND
        result2 = @fmod.invoke(System_CreateStream, @handle, filename.unpack(UX).pack(CX), mode, 0, temp)
        raise "File not found: \"#{filename}\"" if result2 == FMOD_ERR_FILE_NOT_FOUND
      end
      newSound = Sound.new(self, @fmod.unpackInt(temp))
      return newSound
    end
    #--------------------------------------------------------------------------
    # * Close And Release System
    #--------------------------------------------------------------------------
    def dispose
      if (@handle > 0)
        @fmod.invoke(System_Close, @handle)
        @fmod.invoke(System_Release, @handle)
        @handle = 0
      end
      @fmod = nil
    end
  end

  #============================================================================
  # ** Sound
  #----------------------------------------------------------------------------
  #  A class that manages an instance of FMOD::Sound
  #============================================================================
  
  class Sound
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #-------------------------------------------------------------------------- 
    attr_accessor :system             # System that created this Sound
    attr_accessor :fmod               # Instance of DLL class (fmodex.dll)
    attr_accessor :handle             # Handle (pointer) to Sound object
    
    System_PlaySound='System_PlaySound'
    Sound_GetMode='Sound_GetMode'
    Sound_SetMode='Sound_SetMode'
    Sound_GetLength='Sound_GetLength'
    Sound_SetLoopPoints='Sound_SetLoopPoints'
    Sound_Release='Sound_Release'
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     theSystem       : The System that created this Sound object
    #     handle          : Handle to the FMOD::Sound object
    #--------------------------------------------------------------------------
    def initialize(theSystem, theHandle)
      @system = theSystem
      @fmod = theSystem.fmod
      @handle = theHandle
    end
    #--------------------------------------------------------------------------
    # * Play Sound
    #     paused          : Start paused?
    #     channel         : Channel allocated to sound (nil for automatic)
    #--------------------------------------------------------------------------
    def play(paused = false, channel = nil)
      # If channel wasn't specified, let FMOD pick a free one,
      # otherwise use the passed channel (id from 0 to maxChannels)
      unless channel
        temp = 0.chr * 4
      else
        temp = [channel].pack('l')
      end
      @fmod.invoke(System_PlaySound, @system.handle, 
                (channel == nil) ? FMOD_CHANNEL_FREE : FMOD_CHANNEL_REUSE, 
                @handle,
                (paused == true) ? 1 : 0, 
                temp)
      theChannel = @fmod.unpackInt(temp)
      # Create a Channel object based on returned channel
      newChannel = Channel.new(self, theChannel)
      return newChannel
    end
    #--------------------------------------------------------------------------
    # * Get FMOD_MODE Bits
    #--------------------------------------------------------------------------
    def mode
      temp = 0.chr * 4
      @fmod.invoke(Sound_GetMode, @handle, temp)
      return @fmod.unpackInt(temp)
    end
    #--------------------------------------------------------------------------
    # * Set FMOD_MODE Bits
    #--------------------------------------------------------------------------
    def mode=(newMode)
      @fmod.invoke(Sound_SetMode, @handle, newMode)
    end
    #--------------------------------------------------------------------------
    # * Get FMOD_LOOP_MODE
    #--------------------------------------------------------------------------  
    def loopMode
      temp = 0.chr * 4
      @fmod.invoke(Sound_GetMode, @handle, temp)
      return @fmod.unpackInt(temp) & FMOD_LOOP_BITMASK
    end
    #--------------------------------------------------------------------------
    # * Set FMOD_LOOP_MODE
    #--------------------------------------------------------------------------  
    def loopMode=(newMode)
      @fmod.invoke(Sound_SetMode, @handle, (self.mode & ~FMOD_LOOP_BITMASK) | newMode)
    end
    #--------------------------------------------------------------------------
    # * Return Sound Length
    #-------------------------------------------------------------------------- 
    def length(unit = FMOD_DEFAULT_UNIT)
      temp = 0.chr * 4
      @fmod.invoke(Sound_GetLength, @handle, temp, unit)
      return @fmod.unpackInt(temp)
    end
    #--------------------------------------------------------------------------
    # * Set Loop Points
    #     first           : Loop start point in milliseconds
    #     second          : Loop end point in milliseconds
    #     unit            : FMOD_TIMEUNIT for points
    #--------------------------------------------------------------------------    
    def setLoopPoints(first, second, unit = FMOD_DEFAULT_UNIT)
      @fmod.invoke(Sound_SetLoopPoints, @handle, first, unit, second, unit)
    end
    #--------------------------------------------------------------------------
    # * Release Sound
    #-------------------------------------------------------------------------- 
    def dispose
      if (@handle > 0)
        @fmod.invoke(Sound_Release, @handle)
        @handle = 0
      end
      @fmod = nil
      @system = nil
    end
  end

  #============================================================================
  # ** Channel
  #----------------------------------------------------------------------------
  #  A class that represents an FMOD::Channel
  #============================================================================
  
  class Channel
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #-------------------------------------------------------------------------- 
    attr_accessor :system             # System that created the Sound
    attr_accessor :sound              # Sound using the Channel
    attr_accessor :fmod               # Instance of DLL class (fmodex.dll)
    attr_accessor :handle             # Handle (pointer) to Sound object
    
    
    Channel_Stop='Channel_Stop'
    Channel_IsPlaying='Channel_IsPlaying'
    Channel_GetVolume='Channel_GetVolume'
    Channel_SetVolume='Channel_SetVolume'
    Channel_GetPan='Channel_GetPan'
    Channel_SetPan='Channel_SetPan'
    Channel_GetFrequency='Channel_GetFrequency'
    Channel_SetFrequency='Channel_SetFrequency'
    Channel_GetPaused='Channel_GetPaused'
    Channel_SetPaused='Channel_SetPaused'
    Channel_GetPosition='Channel_GetPosition'
    Channel_SetPosition='Channel_SetPosition'
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     theSound        : The Sound using this Channel object
    #     handle          : Handle to the FMOD::Channel object
    #--------------------------------------------------------------------------
    def initialize(theSound, theHandle)
      @sound = theSound
      @system = theSound.system
      @fmod = theSound.system.fmod
      @handle = theHandle
    end
    #--------------------------------------------------------------------------
    # * Stop Channel and Make it Available for Other Sounds
    #--------------------------------------------------------------------------
    def stop
      @fmod.invoke(Channel_Stop, @handle)
    end
    #--------------------------------------------------------------------------
    # * Is the Channel Handle Valid?
    #--------------------------------------------------------------------------
    def valid?
      temp = 0.chr * 4
      begin
        result = @fmod.invoke(Channel_IsPlaying, @handle, temp)
      rescue
        if (result == FMOD_ERR_INVALID_HANDLE)
          return false
        else
          raise
        end
      end
      # If we get here then it's valid
      return true
    end
    #--------------------------------------------------------------------------
    # * Is the Channel Playing?
    #--------------------------------------------------------------------------
    def playing?
      temp = 0.chr * 4
      @fmod.invoke(Channel_IsPlaying, @handle, temp)
      return @fmod.unpackBool(temp)
    end
    #--------------------------------------------------------------------------
    # * Get Channel Volume Level (0.0 -> 1.0)
    #--------------------------------------------------------------------------
    def volume
      temp = 0.chr * 4
      @fmod.invoke(Channel_GetVolume, @handle, temp)
      return @fmod.unpackFloat(temp)
    end
    #--------------------------------------------------------------------------
    # * Set Channel Volume Level (0.0 -> 1.0)
    #--------------------------------------------------------------------------
    def volume=(newVolume)
      @fmod.invoke(Channel_SetVolume, @handle, @fmod.convertFloat(newVolume))
    end
    #--------------------------------------------------------------------------
    # * Get Channel Pan Position (-1.0 -> 1.0)
    #--------------------------------------------------------------------------
    def pan
      temp = 0.chr * 4
      @fmod.invoke(Channel_GetPan, @handle, temp)
      return @fmod.unpackFloat(temp)
    end
    #--------------------------------------------------------------------------
    # * Set Channel Pan Position (-1.0 -> 1.0)
    #--------------------------------------------------------------------------
    def pan=(newPan)
      @fmod.invoke(Channel_SetPan, @handle, @fmod.convertFloat(newPan))
    end
    #--------------------------------------------------------------------------
    # * Get Channel Frequency in HZ (Speed/Pitch)
    #--------------------------------------------------------------------------
    def frequency
      temp = 0.chr * 4
      @fmod.invoke(Channel_GetFrequency, @handle, temp)
      return @fmod.unpackFloat(temp)
    end
    #--------------------------------------------------------------------------
    # * Set Channel Frequency in HZ (Speed/Pitch)
    #--------------------------------------------------------------------------
    def frequency=(newFrequency)
      @fmod.invoke(Channel_SetFrequency, @handle, @fmod.convertFloat(newFrequency))
    end
    #--------------------------------------------------------------------------
    # * Is Channel Paused?
    #--------------------------------------------------------------------------
    def paused
      temp = 0.chr * 4
      @fmod.invoke(Channel_GetPaused, @handle, temp)
      return @fmod.unpackBool(temp)
    end
    #--------------------------------------------------------------------------
    # * Pause Channel
    #--------------------------------------------------------------------------
    def paused=(newPaused)
      @fmod.invoke(Channel_SetPaused, @handle, (newPaused == true) ? 1 : 0)
    end
    #--------------------------------------------------------------------------
    # * Get Current Playback Position
    #     unit            : FMOD_TIMEUNIT to return position in
    #--------------------------------------------------------------------------   
    def position(unit = FMOD_DEFAULT_UNIT)
      temp = 0.chr * 4
      @fmod.invoke(Channel_GetPosition, @handle, temp, unit)
      return @fmod.unpackInt(temp)
    end
    #--------------------------------------------------------------------------
    # * Set Current Playback Position
    #     newPosition     : New playback position
    #     unit            : FMOD_TIMEUNIT to use when setting position
    #--------------------------------------------------------------------------    
    def position=(newPosition, unit = FMOD_DEFAULT_UNIT)
      @fmod.invoke(Channel_SetPosition, @handle, newPosition, unit)
    end
    #--------------------------------------------------------------------------
    # * Dispose of Channel
    #--------------------------------------------------------------------------  
    def dispose
      @handle = 0
      @sound = nil
      @system = nil
      @fmod = nil
    end
  end
  
end

#==============================================================================
# ** FMod
#------------------------------------------------------------------------------
#  A higher level module to access FMOD Ex
#==============================================================================

module FMod
  SLP_TIME=0.01
  #============================================================================
  # ** SoundFile
  #----------------------------------------------------------------------------
  #  Represents a Sound file (BGM, BGS, SE, etc.) and associated Channel
  #============================================================================
  
  class SoundFile
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #--------------------------------------------------------------------------
    attr_accessor :name                     # File name
    attr_accessor :sound                    # FModEx::Sound object
    attr_accessor :channel                  # Channel playing sound
    attr_accessor :volume                   # Volume in RPG::AudioFile format
    attr_accessor :pitch                    # Pitch in RPG::AudioFile format
    attr_accessor :looping                  # Sound loops
    attr_accessor :streaming                # Sound is streamed
    attr_accessor :length                   # Sound length in milliseconds
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    def initialize(name, sound, channel, volume, pitch, looping, streaming, length)
      @name = name
      @sound = sound
      @channel = channel
      @volume = volume
      @pitch = pitch
      @looping = looping
      @streaming = streaming
      @length = length
    end
  end
  #--------------------------------------------------------------------------
  # * Instance Variables
  #--------------------------------------------------------------------------
  @fmod_dll = FModEx::DLL.new               # The FMOD Ex DLL
  @fmod = FModEx::System.new(@fmod_dll)     # The global System object
  @fmod_se = []                             # Array of Sound Effects
  @rtp_folder = nil                         # Name of RTP folder
  #--------------------------------------------------------------------------
  # * Get Path of RTP Folder From Registry
  #-------------------------------------------------------------------------- 
  def self.getRTPFolder
    if @rtp_folder
      return @rtp_folder
    end
    open_key = Win32API.new('advapi32.dll', 'RegOpenKeyExA', 'LPLLP', 'L')
    query_value = Win32API.new('advapi32.dll', 'RegQueryValueExA', 'LPLPPP', 'L')
    close_key = Win32API.new('advapi32', 'RegCloseKey', 'L', 'L')
    key = 0.chr * 4
    # Open a HKEY_LOCAL_MACHINE with KEY_READ attribute and save handle in key
    open_key.call(0x80000002, 'Software\Enterbrain\RGSS\RTP', 0, 0x20019, key)
    key = @fmod_dll.unpackInt(key)
    type = 0.chr * 4
    size = 0.chr * 4
    # Query to get string size
    query_value.call(key, 'Standard', 0, type, 0, size)
    data = ' ' * @fmod_dll.unpackInt(size)
    # Query the string value itself using size
    query_value.call(key, 'Standard', 0, type, data, size)
    @rtp_folder = data.chop
    close_key.call(key)
    # Make sure the directory ends with a backslash
    @rtp_folder += "\\" if @rtp_folder[-1].chr != "\\"
    return @rtp_folder
  end
  #--------------------------------------------------------------------------
  # * Return Proper File Name (With Extensions)
  #     name            : Name of the file
  #     extensions      : Extensions to add to file name
  #-------------------------------------------------------------------------- 
  def self.checkExtensions(name, extensions)
    if FileTest.exist?(name)
      return name
    end
    # Add extension if needed
    extensions.each do |ext|
      if FileTest.exist?(name + '.' + ext)
        return name + '.' + ext
      end
    end
    # File doesn't exist
    return name
  end
  #--------------------------------------------------------------------------
  # * Get Valid File Name
  #     name            : Name of the file
  #-------------------------------------------------------------------------- 
  def self.selectBGMFilename(name)
    name = name.gsub("/", "\\")
    # See if file exists in game folder
    localname = self.checkExtensions(name, FModEx::FMOD_FILE_TYPES)
    # See if file exists in RTP
    commonname = self.checkExtensions(getRTPFolder + name, FModEx::FMOD_FILE_TYPES)
    if FileTest.exist?(localname)
      return localname
    end
    if FileTest.exist?(commonname)
      return commonname
    end
    # An invalid name was provided
    return name
  end
  #--------------------------------------------------------------------------
  # * Play a Sound File Then Return it
  #     name            : Name of the file
  #     volume          : Channel volume
  #     pitch           : Channel frequency
  #     position        : Starting position in milliseconds
  #     looping         : Does the sound loop?
  #     streaming       : Stream sound or load whole thing to memory?
  #-------------------------------------------------------------------------- 
  def self.play(name, volume, pitch, position, looping, streaming)
    # Get a valid file name
    filename = self.selectBGMFilename(name)
    # Create Sound or Stream and set initial values
    sound = streaming ? @fmod.createStream(filename) : @fmod.createSound(filename)
    sound.loopMode = looping ? FModEx::FMOD_LOOP_NORMAL : FModEx::FMOD_LOOP_OFF
    channel = sound.play
    volume = volume * 1.0
    pitch = pitch * 1.0
    file_length = sound.length(FModEx::FMOD_DEFAULT_UNIT)
    sound_file = SoundFile.new(filename, sound, channel, volume, 
                                pitch, looping, streaming, file_length)
    sound_file.channel.volume = volume / 100.0
    sound_file.channel.frequency = sound_file.channel.frequency * pitch / 100
    sound_file.channel.position = position
    return sound_file
  end
  #--------------------------------------------------------------------------
  # * Stop and Dispose of Sound File
  #-------------------------------------------------------------------------- 
  def self.stop(sound_file)
    unless sound_file and sound_file.channel
      return
    end
    # Stop channel, then clear variables and dispose of bgm
    sound_file.channel.stop
    sound_file.channel = nil
    sound_file.sound.dispose
  end
  #--------------------------------------------------------------------------
  # * Return Length in Milliseconds
  #-------------------------------------------------------------------------- 
  def self.get_length(sound_file, unit = FModEx::FMOD_DEFAULT_UNIT)
    return sound_file.length#(unit)
  end
  #--------------------------------------------------------------------------
  # * Check if Another Sound File is Playing
  #-------------------------------------------------------------------------- 
  def self.already_playing?(sound_file, name, position = 0)
    # Get a valid file name
    filename = self.selectBGMFilename(name)
    if (sound_file)
      # If the same sound file is already playing don't play it again
      if (sound_file.name == filename and position == 0)
        return true
      end
      # If another sound file is playing, stop it
      if sound_file.channel
        self.stop(sound_file)
      end
    end
    # No sound file is playing or it was already stopped
    return false
  end
  #--------------------------------------------------------------------------
  # * Check if Sound File is Playing
  #--------------------------------------------------------------------------  
  def self.playing?(sound_file)
    unless sound_file and sound_file.channel
      return false
    end
    return sound_file.channel.playing?
  end
  #--------------------------------------------------------------------------
  # * Get Current Sound File Playing Position
  #-------------------------------------------------------------------------- 
  def self.get_position(sound_file)
    unless sound_file and sound_file.channel
      return 0
    end
    return sound_file.channel.position
  end
  #--------------------------------------------------------------------------
  # * Seek to a New Sound File Playing Position
  #-------------------------------------------------------------------------- 
  def self.set_position(sound_file, new_pos)
    unless sound_file and sound_file.channel
      return
    end
    sound_file.channel.position = new_pos
  end
  #--------------------------------------------------------------------------
  # * Get Current Sound File Volume
  #-------------------------------------------------------------------------- 
  def self.get_volume(sound_file)
    unless sound_file
      return 0
    end
    return sound_file.volume
  end
  #--------------------------------------------------------------------------
  # * Set Sound File Volume
  #-------------------------------------------------------------------------- 
  def self.set_volume(sound_file, volume)
    unless sound_file and sound_file.channel
      return
    end
    sound_file.volume = volume * 1.0
    sound_file.channel.volume = volume / 100.0
  end
  #--------------------------------------------------------------------------
  # * Set Loop Points
  #     first           : Loop start point in milliseconds
  #     second          : Loop end point in milliseconds (-1 for file end)
  #     unit            : FMOD_TIMEUNIT for points
  #-------------------------------------------------------------------------- 
  def self.set_loop_points(sound_file, first, second, unit = FModEx::FMOD_DEFAULT_UNIT)
    unless sound_file and sound_file.channel
      return
    end
    # If second is -1 then set loop end to the file end
    if second == -1
      second = sound_file.length - 1
    end
    # Set loop points and reflush stream buffer
    sound_file.channel.sound.setLoopPoints(first, second, unit)
    sound_file.channel.position = sound_file.channel.position
    return sound_file
  end
  #--------------------------------------------------------------------------
  # * Play ME
  #     name            : Name of the file
  #     volume          : Channel volume
  #     pitch           : Channel frequency
  #     position        : Starting position in milliseconds
  #     looping         : Does the BGM loop?
  #-------------------------------------------------------------------------- 
  def self.me_play(name, volume=100, pitch=100, position = 0, looping = false)
    return if self.already_playing?(@fmod_me, name, position) and FMod.me_playing?
    # Now play the new BGM as a stream
    @fmod_me = self.play(name, volume, pitch, position, false, true)
    Thread.new do
      if @fmod_bgm
        paused=@fmod_bgm.channel.paused
        @fmod_bgm.channel.paused=true
      else
        paused=false
      end
      loop do
        unless @fmod_me
          break
        end
        unless FMod.me_playing?
          break
        end
        sleep(SLP_TIME)
      end
      if @fmod_bgm
        @fmod_bgm.channel.paused=paused
      end
    end
    return @fmod_me
  end
  #--------------------------------------------------------------------------
  # * Stop and Dispose of ME
  #-------------------------------------------------------------------------- 
  def self.me_stop
    self.stop(@fmod_me)
    @fmod_me = nil
  end
  #--------------------------------------------------------------------------
  # * Return ME Length in Milliseconds
  #-------------------------------------------------------------------------- 
  def self.me_length(sound_file)
    self.get_length(@fmod_me)
  end
  #--------------------------------------------------------------------------
  # * Check if a ME is Playing
  #--------------------------------------------------------------------------  
  def self.me_playing?
    return self.playing?(@fmod_me)
  end
  #--------------------------------------------------------------------------
  # * Get Current ME Playing Position
  #-------------------------------------------------------------------------- 
  def self.me_position
    return self.get_position(@fmod_me)
  end
  #--------------------------------------------------------------------------
  # * Seek to New ME Playing Position
  #-------------------------------------------------------------------------- 
  def self.me_position=(new_pos)
    self.set_position(@fmod_bgm, new_pos)
  end
  #--------------------------------------------------------------------------
  # * Get Current ME Volume
  #-------------------------------------------------------------------------- 
  def self.me_volume
    return self.get_volume(@fmod_me)
  end
  #--------------------------------------------------------------------------
  # * Set ME Volume
  #-------------------------------------------------------------------------- 
  def self.me_volume=(volume)
    self.set_volume(@fmod_me, volume)
  end
  #--------------------------------------------------------------------------
  # * Set ME fade
  #-------------------------------------------------------------------------- 
  def self.me_fade(time)
    return unless @fmod_me and FMod.me_playing? and !@fading_me
    @fading_me=true
    Thread.new do
      vol=FMod.me_volume
      cnt=(time/1000.0/SLP_TIME).to_i
      cnt.times do |i|
        FMod.me_volume=(vol-(vol*i/cnt))
        sleep SLP_TIME
      end
      FMod.me_stop
      @fading_me=false
    end
  end
  
  
  #--------------------------------------------------------------------------
  # * Play BGM (or ME)
  #     name            : Name of the file
  #     volume          : Channel volume
  #     pitch           : Channel frequency
  #     position        : Starting position in milliseconds
  #     looping         : Does the BGM loop?
  #-------------------------------------------------------------------------- 
  def self.bgm_play(name, volume=100, pitch=100, position = 0, looping = true)
    return if self.already_playing?(@fmod_bgm, name, position)
    # Now play the new BGM as a stream
    @fmod_bgm = self.play(name, volume, pitch, position, looping, true)
    if @fmod_me and FMod.me_playing?
      @fmod_bgm.channel.paused=true
    end
  end
  #--------------------------------------------------------------------------
  # * Stop and Dispose of BGM
  #-------------------------------------------------------------------------- 
  def self.bgm_stop
    self.stop(@fmod_bgm)
    @fmod_bgm = nil
  end
  #--------------------------------------------------------------------------
  # * Return BGM Length in Milliseconds
  #-------------------------------------------------------------------------- 
  def self.bgm_length(sound_file)
    self.get_length(@fmod_bgm)
  end
  #--------------------------------------------------------------------------
  # * Check if a BGM is Playing
  #--------------------------------------------------------------------------  
  def self.bgm_playing?
    return self.playing?(@fmod_bgm)
  end
  #--------------------------------------------------------------------------
  # * Get Current BGM Playing Position
  #-------------------------------------------------------------------------- 
  def self.bgm_position
    return self.get_position(@fmod_bgm)
  end
  #--------------------------------------------------------------------------
  # * Seek to New BGM Playing Position
  #-------------------------------------------------------------------------- 
  def self.bgm_position=(new_pos)
    self.set_position(@fmod_bgm, new_pos)
  end
  #--------------------------------------------------------------------------
  # * Get Current BGM Volume
  #-------------------------------------------------------------------------- 
  def self.bgm_volume
    return self.get_volume(@fmod_bgm)
  end
  #--------------------------------------------------------------------------
  # * Set BGM Volume
  #-------------------------------------------------------------------------- 
  def self.bgm_volume=(volume)
    self.set_volume(@fmod_bgm, volume)
  end
  #--------------------------------------------------------------------------
  # * Set Loop Points
  #     first           : Loop start point in milliseconds
  #     second          : Loop end point in milliseconds
  #     unit            : FMOD_TIMEUNIT for points
  #-------------------------------------------------------------------------- 
  def self.bgm_set_loop_points(first, second, unit = FModEx::FMOD_DEFAULT_UNIT)
    @fmod_bgm = self.set_loop_points(@fmod_bgm, first, second, unit)
  end
  #--------------------------------------------------------------------------
  # * Set BGM fade
  #-------------------------------------------------------------------------- 
  def self.bgm_fade(time)
    return unless @fmod_bgm and FMod.bgm_playing? and !@fading_bgm
    @fading_bgm=true
    Thread.new do
      vol=FMod.bgm_volume
      cnt=(time/1000.0/SLP_TIME).to_i
      cnt.times do |i|
        Graphics::Fmod_Thread_Active(100,0.015)
        FMod.bgm_volume=(vol-(vol*i/cnt))
        sleep SLP_TIME
      end
      FMod.bgm_stop
      Graphics::Fmod_Thread_Active(40,false)
      @fading_bgm=false
    end
  end
  
  
  #--------------------------------------------------------------------------
  # * Play BGS
  #     name            : Name of the file
  #     volume          : Channel volume
  #     pitch           : Channel frequency
  #     position        : Starting position in milliseconds
  #     looping         : Does the BGS loop?
  #-------------------------------------------------------------------------- 
  def self.bgs_play(name, volume=100, pitch=100, position = 0, looping = true)
    return if self.already_playing?(@fmod_bgs, name, position)
    # Now play the new BGS as a stream
    @fmod_bgs = self.play(name, volume, pitch, position, looping, true)
  end
  #--------------------------------------------------------------------------
  # * Stop and Dispose of BGS
  #-------------------------------------------------------------------------- 
  def self.bgs_stop
    self.stop(@fmod_bgs)
    @fmod_bgs = nil
  end
  #--------------------------------------------------------------------------
  # * Return BGS Length in Milliseconds
  #-------------------------------------------------------------------------- 
  def self.bgm_length(sound_file)
    self.get_length(@fmod_bgs)
  end
  #--------------------------------------------------------------------------
  # * Check if a BGS is Playing
  #--------------------------------------------------------------------------  
  def self.bgs_playing?
    return self.playing?(@fmod_bgs)
  end
  #--------------------------------------------------------------------------
  # * Get Current BGS Playing Position
  #-------------------------------------------------------------------------- 
  def self.bgs_position
    return self.get_position(@fmod_bgs)
  end
  #--------------------------------------------------------------------------
  # * Seek to New BGS Playing Position
  #-------------------------------------------------------------------------- 
  def self.bgs_position=(new_pos)
    self.set_position(@fmod_bgs, new_pos)
  end
  #--------------------------------------------------------------------------
  # * Get Current BGS Volume
  #-------------------------------------------------------------------------- 
  def self.bgs_volume
    return self.get_volume(@fmod_bgs)
  end
  #--------------------------------------------------------------------------
  # * Set BGS Volume
  #-------------------------------------------------------------------------- 
  def self.bgs_volume=(volume)
    self.set_volume(@fmod_bgs, volume)
  end
  #--------------------------------------------------------------------------
  # * Set Loop Points
  #     first           : Loop start point in milliseconds
  #     second          : Loop end point in milliseconds
  #     unit            : FMOD_TIMEUNIT for points
  #-------------------------------------------------------------------------- 
  def self.bgs_set_loop_points(first, second, unit = FModEx::FMOD_DEFAULT_UNIT)
    @fmod_bgs = self.set_loop_points(@fmod_bgs, first, second, unit)
  end
  #--------------------------------------------------------------------------
  # * Set BGS fade
  #-------------------------------------------------------------------------- 
  def self.bgs_fade(time)
    return unless @fmod_bgs and FMod.bgs_playing? and !@fading_bgs
    @fading_bgs=true
    Thread.new do
      vol=FMod.bgs_volume
      cnt=(time/1000.0/SLP_TIME).to_i
      cnt.times do |i|
        FMod.bgs_volume=(vol-(vol*i/cnt))
        sleep SLP_TIME
      end
      FMod.me_stop
      @fading_bgs=false
    end
  end
  
  #--------------------------------------------------------------------------
  # * Play SE
  #     name            : Name of the file
  #     volume          : Channel volume
  #     pitch           : Channel frequency
  #-------------------------------------------------------------------------- 
  def self.se_play(name, volume=100, pitch=100)
    if @fmod_se.size > @fmod.maxChannels
      #msgbox_p 0
      se = @fmod_se.shift
      #msgbox_p se
      self.stop(se)  if self.playing?(se)
    end
    # Load SE into memory and play it
    @fmod_se << self.play(name, volume, pitch, 0, false, false)
  end
  #--------------------------------------------------------------------------
  # * Stop and Dispose of all SEs
  #-------------------------------------------------------------------------- 
  def self.se_stop
    for se in @fmod_se
      self.stop(se) if self.playing?(se)
    end
    @fmod_se.clear
  end
  #--------------------------------------------------------------------------
  # * Get Rid of Non-Playing SEs
  #--------------------------------------------------------------------------  
		def self.se_clean
		$FMOD_CLEANING=true
    for se in @fmod_se
      unless self.playing?(se)
        self.stop(se)
        @fmod_se.delete(se)
      end
		end
		$FMOD_CLEANING=false	
  end
  #--------------------------------------------------------------------------
  # * Check if There's Some SE in SE Array
  #--------------------------------------------------------------------------  
  def self.se_list_empty?
    return @fmod_se.empty?
  end
  #--------------------------------------------------------------------------
  # * Dispose of Everything
  #--------------------------------------------------------------------------  
  def self.dispose
    self.bgm_stop
    self.bgs_stop
    self.se_stop
    @fmod.dispose
  end
end
end