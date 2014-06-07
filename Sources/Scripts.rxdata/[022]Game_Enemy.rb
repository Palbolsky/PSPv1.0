#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
# 　エネミーを扱うクラスです。このクラスは Game_Troop クラス ($game_troop) の
# 内部で使用されます。
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     troop_id     : トループ ID
  #     member_index : トループメンバーのインデックス
  #--------------------------------------------------------------------------
  def initialize(troop_id, member_index)
    super()
    @troop_id = troop_id
    @member_index = member_index
    troop = $data_troops[@troop_id]
    @enemy_id = troop.members[@member_index].enemy_id
    enemy = $data_enemies[@enemy_id]
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = maxhp
    @sp = maxsp
    @hidden = troop.members[@member_index].hidden
    @immortal = troop.members[@member_index].immortal
  end
  #--------------------------------------------------------------------------
  # ● エネミー ID 取得
  #--------------------------------------------------------------------------
  def id
    return @enemy_id
  end
  #--------------------------------------------------------------------------
  # ● インデックス取得
  #--------------------------------------------------------------------------
  def index
    return @member_index
  end
  #--------------------------------------------------------------------------
  # ● 名前の取得
  #--------------------------------------------------------------------------
  def name
    return $data_enemies[@enemy_id].name
  end
  #--------------------------------------------------------------------------
  # ● 基本 MaxHP の取得
  #--------------------------------------------------------------------------
  def base_maxhp
    return $data_enemies[@enemy_id].maxhp
  end
  #--------------------------------------------------------------------------
  # ● 基本 MaxSP の取得
  #--------------------------------------------------------------------------
  def base_maxsp
    return $data_enemies[@enemy_id].maxsp
  end
  #--------------------------------------------------------------------------
  # ● 基本腕力の取得
  #--------------------------------------------------------------------------
  def base_str
    return $data_enemies[@enemy_id].str
  end
  #--------------------------------------------------------------------------
  # ● 基本器用さの取得
  #--------------------------------------------------------------------------
  def base_dex
    return $data_enemies[@enemy_id].dex
  end
  #--------------------------------------------------------------------------
  # ● 基本素早さの取得
  #--------------------------------------------------------------------------
  def base_agi
    return $data_enemies[@enemy_id].agi
  end
  #--------------------------------------------------------------------------
  # ● 基本魔力の取得
  #--------------------------------------------------------------------------
  def base_int
    return $data_enemies[@enemy_id].int
  end
  #--------------------------------------------------------------------------
  # ● 基本攻撃力の取得
  #--------------------------------------------------------------------------
  def base_atk
    return $data_enemies[@enemy_id].atk
  end
  #--------------------------------------------------------------------------
  # ● 基本物理防御の取得
  #--------------------------------------------------------------------------
  def base_pdef
    return $data_enemies[@enemy_id].pdef
  end
  #--------------------------------------------------------------------------
  # ● 基本魔法防御の取得
  #--------------------------------------------------------------------------
  def base_mdef
    return $data_enemies[@enemy_id].mdef
  end
  #--------------------------------------------------------------------------
  # ● 基本回避修正の取得
  #--------------------------------------------------------------------------
  def base_eva
    return $data_enemies[@enemy_id].eva
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃 攻撃側アニメーション ID の取得
  #--------------------------------------------------------------------------
  def animation1_id
    return $data_enemies[@enemy_id].animation1_id
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃 対象側アニメーション ID の取得
  #--------------------------------------------------------------------------
  def animation2_id
    return $data_enemies[@enemy_id].animation2_id
  end
  #--------------------------------------------------------------------------
  # ● 属性補正値の取得
  #     element_id : 属性 ID
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    # 属性有効度に対応する数値を取得
    table = [0,200,150,100,50,0,-100]
    result = table[$data_enemies[@enemy_id].element_ranks[element_id]]
    # ステートでこの属性が防御されている場合は半減
    for i in @states
      if $data_states[i].guard_element_set.include?(element_id)
        result /= 2
      end
    end
    # メソッド終了
    return result
  end
  #--------------------------------------------------------------------------
  # ● ステート有効度の取得
  #--------------------------------------------------------------------------
  def state_ranks
    return $data_enemies[@enemy_id].state_ranks
  end
  #--------------------------------------------------------------------------
  # ● ステート防御判定
  #     state_id : ステート ID
  #--------------------------------------------------------------------------
  def state_guard?(state_id)
    return false
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃の属性取得
  #--------------------------------------------------------------------------
  def element_set
    return []
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃のステート変化 (+) 取得
  #--------------------------------------------------------------------------
  def plus_state_set
    return []
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃のステート変化 (-) 取得
  #--------------------------------------------------------------------------
  def minus_state_set
    return []
  end
  #--------------------------------------------------------------------------
  # ● アクションの取得
  #--------------------------------------------------------------------------
  def actions
    return $data_enemies[@enemy_id].actions
  end
  #--------------------------------------------------------------------------
  # ● EXP の取得
  #--------------------------------------------------------------------------
  def exp
    return $data_enemies[@enemy_id].exp
  end
  #--------------------------------------------------------------------------
  # ● ゴールドの取得
  #--------------------------------------------------------------------------
  def gold
    return $data_enemies[@enemy_id].gold
  end
  #--------------------------------------------------------------------------
  # ● アイテム ID の取得
  #--------------------------------------------------------------------------
  def item_id
    return $data_enemies[@enemy_id].item_id
  end
  #--------------------------------------------------------------------------
  # ● 武器 ID の取得
  #--------------------------------------------------------------------------
  def weapon_id
    return $data_enemies[@enemy_id].weapon_id
  end
  #--------------------------------------------------------------------------
  # ● 防具 ID の取得
  #--------------------------------------------------------------------------
  def armor_id
    return $data_enemies[@enemy_id].armor_id
  end
  #--------------------------------------------------------------------------
  # ● トレジャー出現率の取得
  #--------------------------------------------------------------------------
  def treasure_prob
    return $data_enemies[@enemy_id].treasure_prob
  end
  #--------------------------------------------------------------------------
  # ● バトル画面 X 座標の取得
  #--------------------------------------------------------------------------
  def screen_x
    return $data_troops[@troop_id].members[@member_index].x
  end
  #--------------------------------------------------------------------------
  # ● バトル画面 Y 座標の取得
  #--------------------------------------------------------------------------
  def screen_y
    return $data_troops[@troop_id].members[@member_index].y
  end
  #--------------------------------------------------------------------------
  # ● バトル画面 Z 座標の取得
  #--------------------------------------------------------------------------
  def screen_z
    return screen_y
  end
  #--------------------------------------------------------------------------
  # ● 逃げる
  #--------------------------------------------------------------------------
  def escape
    # ヒドゥンフラグをセット
    @hidden = true
    # カレントアクションをクリア
    self.current_action.clear
  end
  #--------------------------------------------------------------------------
  # ● 変身
  #     enemy_id : 変身先のエネミー ID
  #--------------------------------------------------------------------------
  def transform(enemy_id)
    # エネミー ID を変更
    @enemy_id = enemy_id
    # バトラー グラフィックを変更
    @battler_name = $data_enemies[@enemy_id].battler_name
    @battler_hue = $data_enemies[@enemy_id].battler_hue
    # アクション再作成
    make_action
  end
  #--------------------------------------------------------------------------
  # ● アクション作成
  #--------------------------------------------------------------------------
#Script amélioré par RPG Advocate
  
  def make_action
    self.current_action.clear
    unless self.movable?
      return
    end
    available_actions = []
    rating_max = 0
    for action in self.actions
      n = $game_temp.battle_turn
      a = action.condition_turn_a
      b = action.condition_turn_b
      if (b == 0 and n != a) or
         (b > 0 and (n < 1 or n < a or n % b != a % b))
        next
      end
      if self.hp * 100.0 / self.maxhp > action.condition_hp
        next
      end
      if $game_party.max_level < action.condition_level
        next
      end
      switch_id = action.condition_switch_id
      if switch_id > 0 and $game_switches[switch_id] == false
        next
      end
      if exclude_pointless_actions(action)
        next
      end
      available_actions.push(action)
      if action.rating > rating_max
        rating_max = action.rating
      end
    end
    ratings_total = 0
    for action in available_actions
      ratings_total += action.rating
    end
    if ratings_total > 0
      choose_action = []
      for action in available_actions
        for j in 1..action.rating
          choose_action.push(action)
        end
      end
      enemy_action = choose_action[rand(choose_action.size - 1)]
      self.current_action.kind = enemy_action.kind
      self.current_action.basic = enemy_action.basic
      self.current_action.skill_id = enemy_action.skill_id
      self.current_action.decide_random_target_for_enemy
    end
  end
  # --------------------------------
  def exclude_pointless_actions(action)
    if action.kind == 0
      return false
    end
    if action.kind == 1
      s = action.skill_id
      if self.sp < $data_skills[s].sp_cost
        return true
      end
      if $data_skills[s].common_event_id > 0
        return false
      end
      if $data_skills[s].scope == 0 || $data_skills[s].scope == 1 || 
        $data_skills[s].scope == 2
        return false
      end
      if $data_skills[s].scope == 3 || $data_skills[s].scope == 4
        if $game_troop != nil
        fullhpflag = true
        statusflag = true
          for i in $game_troop.enemies
            if i.hp < i.maxhp && i.exist?
              fullhpflag = false
            end
            for j in $data_skills[s].plus_state_set
              if not i.state?(j) && i.exist?
                statusflag = false
              end
            end
            for j in $data_skills[s].minus_state_set
              if i.state?(j) && i.exist?
                statusflag = false
              end
            end
          end
        end
      if $data_skills[s].power == 0 && statusflag
        return true
      end
      if $data_skills[s].power < 0 && statusflag && fullhpflag
        return true
        end
      end
      if $data_skills[s].scope == 5 || $data_skills[s].scope == 6
        nonedeadflag = true
        if $game_troop != nil
          for i in $game_troop.enemies
            if i.dead? and not i.hidden
              nonedeadflag = false
            end
          end
        end
        if nonedeadflag
          return true
        end
      end
      if $data_skills[s].scope == 7
        if $game_troop != nil
          fullhpflag = true
          statusflag = true
          if self.hp < self.maxhp
            fullhpflag = false
          end
          for j in $data_skills[s].plus_state_set
            if not self.state?(j)
              statusflag = false
              end
            end
            for j in $data_skills[s].minus_state_set
              if self.state?(j)
                statusflag = false
              end
            end
          end
      if $data_skills[s].power == 0 && statusflag
        return true
      end
      if $data_skills[s].power < 0 && statusflag && fullhpflag
        return true
        end
      end
    end
    return false
  end
end