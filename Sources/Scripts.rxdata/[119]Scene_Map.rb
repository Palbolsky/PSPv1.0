#==============================================================================
# ■ Scene_Map
# Pokemon Script Project v1.0 - Modifié par Palbolsky et Nagato Yuki
#------------------------------------------------------------------------------
# 　Module de gestion de la carte en jeu. 
#==============================================================================

module Scene_Map
  module_function
  def viewport(x1=0,y1=0,x2=0,y2=200)
    @spriteset = Spriteset_Map.new(x1,y1)    
  end
  
  def init
    @finished=false    
    @message_window = Window_Message.new
    posc = Pokemon_S::POS_CADRE
    if $ShowCadre
      Pokemon_Menu.viewport(posc[0],posc[1],posc[2],posc[3]) 
    else
      Pokemon_Menu.viewport
    end
    Pokemon_Menu.init     
  end
  
  def run
    init
    Graphics.transition
    while Scene_Manager.me?(self)
      Graphics.update
      Input.update
      update
    end
    Graphics.freeze
    finish
    Pokemon_Menu.finish    
    GC.start
  end
  
  def update
    # ループ
    loop do
      # マップ、インタプリタ、プレイヤーの順に更新
      # (この更新順序は、イベントを実行する条件が満たされているときに
      #  プレイヤーに一瞬移動する機会を与えないなどの理由で重要)
      $game_map.update
      $game_system.map_interpreter.update
      $game_player.update
      # システム (タイマー)、画面を更新
      $game_system.update
      $game_screen.update
      # プレイヤーの場所移動中でなければループを中断
      unless $game_temp.player_transferring
        break
      end
      # 場所移動を実行
      transfer_player
      # トランジション処理中の場合、ループを中断
      if $game_temp.transition_processing
        break
      end
    end
    # スプライトセットを更新
    @spriteset.update
    Yuki::TJNS.update()
    # メッセージウィンドウを更新
    Yuki::ShowMSG.update if $game_temp.message_proc
    # ゲームオーバーの場合
    #if $game_temp.gameover
    #  # ゲームオーバー画面に切り替え
    #  $scene = Scene_Gameover.new
    #  return
    #end
    # タイトル画面に戻す場合
    if $game_temp.to_title
      Scene_Manager.pop
      Scene_Manager.push(Scene_Title)
      return
    end
    # トランジション処理中の場合
    if $game_temp.transition_processing
      # トランジション処理中フラグをクリア
      $game_temp.transition_processing = false
      # トランジション実行
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
    # メッセージウィンドウ表示中の場合
    if $game_temp.message_window_showing
      return
    end
    # エンカウント カウントが 0 で、エンカウントリストが空ではない場合
    if $game_player.encounter_count == 0 and $game_map.encounter_list != []
      # イベント実行中かエンカウント禁止中でなければ
      unless $game_system.map_interpreter.running? or
             $game_system.encounter_disabled
        # トループを決定
        n = rand($game_map.encounter_list.size)
        troop_id = $game_map.encounter_list[n]
        # トループが有効なら
        if $data_troops[troop_id] != nil
          # バトル呼び出しフラグをセット
          $game_temp.battle_calling = true
          $game_temp.battle_troop_id = troop_id
          $game_temp.battle_can_escape = true
          $game_temp.battle_can_lose = false
          $game_temp.battle_proc = nil
        end
      end
    end
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # イベント実行中かメニュー禁止中でなければ
      unless $game_system.map_interpreter.running? or
             $game_system.menu_disabled
        # メニュー呼び出しフラグと SE 演奏フラグをセット
        $game_temp.menu_calling = true
        $game_temp.menu_beep = true
      end
    end
    # デバッグモードが ON かつ F9 キーが押されている場合
    if $DEBUG and Input.press?(Input::F9)
      # デバッグ呼び出しフラグをセット
      $game_temp.debug_calling = true
    end
    # プレイヤーの移動中ではない場合
    unless $game_player.moving?
      # 各種画面の呼び出しを実行
      if $game_temp.battle_calling
        call_battle
      elsif $game_temp.shop_calling
        call_shop
      elsif $game_temp.name_calling
        call_name
      elsif $game_temp.menu_calling
        call_menu
      elsif $game_temp.save_calling
        call_save
      elsif $game_temp.debug_calling
        call_debug
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● バトルの呼び出し
  #--------------------------------------------------------------------------
  def call_battle
    return
    # バトル呼び出しフラグをクリア
    $game_temp.battle_calling = false
    # メニュー呼び出しフラグをクリア
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    # エンカウント カウントを作成
    $game_player.make_encounter_count
    # マップ BGM を記憶し、BGM を停止
    $game_temp.map_bgm = $game_system.playing_bgm
    $game_system.bgm_stop
    # バトル開始 SE を演奏
    $game_system.se_play($data_system.battle_start_se)
    # バトル BGM を演奏
    $game_system.bgm_play($game_system.battle_bgm)
    # プレイヤーの姿勢を矯正
    $game_player.straighten
    # バトル画面に切り替え
    $scene = Scene_Battle.new
  end
  #--------------------------------------------------------------------------
  # ● ショップの呼び出し
  #--------------------------------------------------------------------------
  def call_shop
    return
    # ショップ呼び出しフラグをクリア
    $game_temp.shop_calling = false
    # プレイヤーの姿勢を矯正
    $game_player.straighten
    # ショップ画面に切り替え
    $scene = Scene_Shop.new
  end
  #--------------------------------------------------------------------------
  # ● 名前入力の呼び出し
  #--------------------------------------------------------------------------
  def call_name    
    # 名前入力呼び出しフラグをクリア
    $game_temp.name_calling = false
    # プレイヤーの姿勢を矯正
    $game_player.straighten
    # 名前入力画面に切り替え
    Scene_Manager.push(Scene_Name)
    Scene_Name.run
  end
  #--------------------------------------------------------------------------
  # ● メニューの呼び出し
  #--------------------------------------------------------------------------
  def call_menu
    # メニュー呼び出しフラグをクリア
    $game_temp.menu_calling = false
    # メニュー SE 演奏フラグがセットされている場合
    if $game_temp.menu_beep
      # 決定 SE を演奏
      $game_system.se_play($data_system.decision_se)
      # メニュー SE 演奏フラグをクリア
      $game_temp.menu_beep = false
    end
    # プレイヤーの姿勢を矯正
    $game_player.straighten
    # メニュー画面に切り替え
    Scene_Manager.push(Pokemon_Menu)
    Pokemon_Menu.run
  end
  #--------------------------------------------------------------------------
  # ● セーブの呼び出し
  #--------------------------------------------------------------------------
  def call_save
    return
    # プレイヤーの姿勢を矯正
    $game_player.straighten
    # セーブ画面に切り替え
    $scene = Scene_Save.new
  end
  #--------------------------------------------------------------------------
  # ● デバッグの呼び出し
  #--------------------------------------------------------------------------
  def call_debug
    return
    # デバッグ呼び出しフラグをクリア
    $game_temp.debug_calling = false
    # 決定 SE を演奏
    $game_system.se_play($data_system.decision_se)
    # プレイヤーの姿勢を矯正
    $game_player.straighten
    # デバッグ画面に切り替え
    $scene = Scene_Debug.new
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーの場所移動
  #--------------------------------------------------------------------------
  def transfer_player
    # プレイヤー場所移動フラグをクリア
    $game_temp.player_transferring = false
    # 移動先が現在のマップと異なる場合
    if $game_map.map_id != $game_temp.player_new_map_id
      # 新しいマップをセットアップ
      $game_map.setup($game_temp.player_new_map_id)
    end
    # プレイヤーの位置を設定
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    # プレイヤーの向きを設定
    case $game_temp.player_new_direction
    when 2  # 下
      $game_player.turn_down
    when 4  # 左
      $game_player.turn_left
    when 6  # 右
      $game_player.turn_right
    when 8  # 上
      $game_player.turn_up
    end
    # プレイヤーの姿勢を矯正
    $game_player.straighten
    # マップを更新 (並列イベント実行)
    $game_map.update
    # スプライトセットを再作成
    @spriteset.dispose
    posc = Pokemon_S::POS_CADRE
    if $ShowCadre
      @spriteset = Spriteset_Map.new(posc[0],posc[1]) 
    else
      @spriteset = Spriteset_Map.new(0,0)
    end            
    # トランジション処理中の場合
    if $game_temp.transition_processing
      # トランジション処理中フラグをクリア
      $game_temp.transition_processing = false
      # トランジション実行
      Graphics.transition(20)
    end
    # マップに設定されている BGM と BGS の自動切り替えを実行
    $game_map.autoplay
    # フレームリセット
    Graphics.frame_reset
    # 入力情報を更新
    Input.update    
  end
  
  def finished?
    @finished
  end
  
  def finish
    @spriteset.dispose
    @message_window.dispose unless  @message_window.disposed?
    @message_window=nil
    @spriteset=nil    
  end  
end
