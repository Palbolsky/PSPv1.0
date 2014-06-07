#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
# 　トループを扱うクラスです。このクラスのインスタンスは $game_troop で参照さ
# れます。
#==============================================================================

class Game_Troop
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    # エネミーの配列を作成
    @enemies = []
  end
  #--------------------------------------------------------------------------
  # ● エネミーの取得
  #--------------------------------------------------------------------------
  def enemies
    return @enemies
  end
  #--------------------------------------------------------------------------
  # ● セットアップ
  #     troop_id : トループ ID
  #--------------------------------------------------------------------------
  def setup(troop_id)
    # トループに設定されているエネミーを配列に設定
    @enemies = []
    troop = $data_troops[troop_id]
    for i in 0...troop.members.size
      enemy = $data_enemies[troop.members[i].enemy_id]
      if enemy != nil
        @enemies.push(Game_Enemy.new(troop_id, i))
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 対象エネミーのランダムな決定
  #     hp0 : HP 0 のエネミーに限る
  #--------------------------------------------------------------------------
  def random_target_enemy(hp0 = false)
    # ルーレットを初期化
    roulette = []
    # ループ
    for enemy in @enemies
      # 条件に該当する場合
      if (not hp0 and enemy.exist?) or (hp0 and enemy.hp0?)
        # ルーレットにエネミーを追加
        roulette.push(enemy)
      end
    end
    # ルーレットのサイズが 0 の場合
    if roulette.size == 0
      return nil
    end
    # ルーレットを回し、エネミーを決定
    return roulette[rand(roulette.size)]
  end
  #--------------------------------------------------------------------------
  # ● 対象エネミーのランダムな決定 (HP 0)
  #--------------------------------------------------------------------------
  def random_target_enemy_hp0
    return random_target_enemy(true)
  end
  #--------------------------------------------------------------------------
  # ● 対象エネミーのスムーズな決定
  #     enemy_index : エネミーインデックス
  #--------------------------------------------------------------------------
  def smooth_target_enemy(enemy_index)
    # エネミーを取得
    enemy = @enemies[enemy_index]
    # エネミーが存在する場合
    if enemy != nil and enemy.exist?
      return enemy
    end
    # ループ
    for enemy in @enemies
      # エネミーが存在する場合
      if enemy.exist?
        return enemy
      end
    end
  end
end
