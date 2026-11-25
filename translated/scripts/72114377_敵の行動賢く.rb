#==============================================================================
# ■ エネミー行動なかなか賢く　Ver0.7                                 　By むー
#------------------------------------------------------------------------------
#　敵の行動を賢くします。リアルタイムに対応しました。
#------------------------------------------------------------------------------
#
#　★簡単な仕様★
#
#　　本来、データベースでエネミーの行動を指定する際の条件は、
#　　そのエネミーがどのような状態か、です。
#　　HP20%～60%などのように指定すると、そのエネミーのHPを参考にします。
#　　このスクリプトでは、それを敵の味方(Troop)全体で判断します。
#　　HP20%～60%などのように指定すると、敵グループの中で該当者がいないかを探し、
#　　いればその行動を、その該当者に対しておこなうようになります。
#　　また、エネミーがアクターに使うスキルも、同じように条件指定が可能です。
#　　行動はリアルタイムです。
#
#　★条件★
#
#　　HP、MP、ステートのみ有効です。
#　　ターン、パーティレベル、スイッチは、賢い行動の元になりません。
#
#　★設定方法★
#
#　　本スクリプト内で設定する場所はありません。
#　　データベースの敵キャラの行動パターンに設定します。
#　　賢い行動をさせたい行動の優先度(Rate)を10または1にしてください。
#　　行動の優先順位は、同一の優先度内で行動一覧の上からになります。
#
#    優先度10: エネミーがおこなう行動を指定します。
#    優先度 1: エネミーがおこなわなくなる行動を指定します。
#
#    【例1】
#
#　　守備力アップ = 味方に行うスキル
#
#　　　[優先度]　　[スキル]　　　　　[条件]
#　　　10　　　　　守備力アップ　　　ステート"毒"
#　　　1 　　　　　守備力アップ　　　ステート"守備力アップ"
#
#　　上記のように設定すると、まず優先度10のスキルを実行候補にします。
#　　この場合は、エネミーのいずれかが毒にかかっていたら、
#　　エネミーがエネミーに守備力アップを使います。
#　　しかし、優先度1のスキルが指定されています。これは...
#
#　　　　　条件「ステート"守備力アップ"」にかかっていたら
#　　　　　その対象にはスキル「守備力アップ」を使わない。
#
#　　という意味を持たせています。これによって、エネミーが毒にかかっている限り
#　　守備力アップを使い続けるという事がなくなります。
#　　優先度10は、条件に合えば必ず使うスキル、
#　　しかし優先度1は、条件10に当てはまっても使わないという効果を持ちます。
#　　これは エネミー → アクター のスキルでも同じです。
#
#    【例2】
#
#　　甘い息単体版 = 敵(エネミーからすればアクター)に行うスキル
#
#　　　[優先度]　　[スキル]　　　　　[条件]
#　　　10　　　　　甘い息単体版　　　HP　1％～100％
#　　　1 　　　　　甘い息単体版　　　ステート"睡眠"
#
#　　上記のように設定すると、まず優先度10のスキルを実行候補にします。
#　　この場合は、アクターのいずれかのHPが1%～100%の間にあれば、睡眠攻撃を仕掛けます。
#　　1%～100%ならば、生存アクターがいれば必ず行うという意味です。
#　　しかし、優先度1のスキルが指定されています。これは...
#
#　　　　　条件「睡眠」にかかっていたら
#　　　　　その対象にはスキル「甘い息単体版」を使わない。
#
#　　という意味を持たせています。これによって、アクターが睡眠にかかっている限り、
#　　そのアクターには甘い息単体版を使うという事がなくなります。
#
#　★注意点★
#
#　　マナドレインなどのような吸収技には注意してください。
#　　使用者に掛かる回復技を、例えばMP0%～50%、優先度10などのように指定した場合、
#　　MPが減っている味方がいる限り使い続けてしまいます。
#　　減っているのは味方の誰かでも、回復するのは自分なので...。
#
#　　使わない条件として、HP/MP/ステートが使えるのですが、
#　　能力強化は判断基準にできません(元々エネミーの行動条件にありません)。
#　　ですので、例えば味方(エネミー側なのでエネミー)の守備力アップを条件にする場合、
#　　「すでに能力強化で守備力が上昇しているターゲットは優先度1で省く」
#　　などという事ができません。VX Aceの仕様です(たぶん)。
#　　なのでサンプルでは、守備力アップをステートでおこなっています。
#
#　　本スクリプトでの条件指定には、少しだけ制限があります。
#　　エネミーがエネミーにおこなうスキルの条件はエネミーの状態、
#　　エネミーがアクターにおこなうスキルの条件はアクターの状態となっています。
#　　エネミーがエネミーにおこなう際にアクターの状態、および
#　　エネミーがアクターにおこなう際にエネミーの状態を条件にする事はできません。
#　　つまり、エネミーに毒がかかったらアクターに攻撃するといった事はできません。
#　　逆の場合も然りです。
#
#==============================================================================
$moo_enemy_clever = true
module MOO_ENEMY_CLEVER

  #--------------------------------------------------------------------------
  # 設定箇所はありません。以下は通常、変更しないで下さい。
  #--------------------------------------------------------------------------

  # 本スクリプトを使う場合(何かあって止めたい時)
  USE = true

  # 強制する行動のレート(変更しないでください)
  ACT_RATE_1 = 10 # 条件に合った場合は行動する
  ACT_RATE_2 =  1 # 条件に合った場合は行動しない

  # 行動をランダム化するときの文字列
  ENEMY_ACTION_RANDOM = "賢くランダム"
  # 通常は行動リストの上から順番に優先とされます。
  # なので条件に合う限り、全ての同一エネミーが同じ行動をし続けます。
  # この文字をエネミーのメモ欄に書くと、上から順ではなく優先度を無くし、
  # 優先度10の行動の中で、ランダムに実行するようになります。
  # ランダムの中でこの行動の使用頻度を上げたいという場合は、
  # その行動をいくつか記述して下さい。
  #
  #　　ヒール　　HP10%～50%　　優先度10
  #　　ヒール　　HP10%～50%　　優先度10
  #　　ファイア　ステート眠り　優先度10
  #
  #　　エネミーのメモ欄に「賢くランダム」の記述あり
  #
  # このようにすれば、ヒールの率がファイアの2倍になります。

end

#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
# 　敵キャラを扱うクラスです。このクラスは Game_Troop クラス（$game_troop）の
# 内部で使用されます。
#==============================================================================
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ◎ 現在の状況で戦闘行動が有効か否かを判定
  #     action : RPG::Enemy::Action
  #--------------------------------------------------------------------------
  alias moo_enemy_clever_action_valid? action_valid?
  def action_valid?(action)
    # 優先度10/1(指定値)は通常行動から除く
    return false if action.rating == MOO_ENEMY_CLEVER::ACT_RATE_1
    return false if action.rating == MOO_ENEMY_CLEVER::ACT_RATE_2
    moo_enemy_clever_action_valid?(action)
  end
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ○ 定数 (特徴)
  #--------------------------------------------------------------------------
  FEATURE_STYPE_SEAL    = 42              # スキルタイプ封印
  FEATURE_SKILL_SEAL    = 44              # スキル封印
  #--------------------------------------------------------------------------
  # ○ 強制行動のレートを取得 1 → 対象に使う
  #--------------------------------------------------------------------------
  def moo_enemy_clever_rate_1
    MOO_ENEMY_CLEVER::ACT_RATE_1
  end
  #--------------------------------------------------------------------------
  # ○ 強制行動のレートを取得 2 → 対象に使わなくなる
  #--------------------------------------------------------------------------
  def moo_enemy_clever_rate_2
    MOO_ENEMY_CLEVER::ACT_RATE_2
  end
  #--------------------------------------------------------------------------
  # ○ 賢い行動システム
  #--------------------------------------------------------------------------
  def moo_enemy_clever_change
    # 配列変数初期化
    act_list_1 = []
    act_list_2 = []
    return_array = [0, -1]
    # 行動の数だけループ
    if $data_enemies[@subject.enemy_id].actions.size > 0
      for act in $data_enemies[@subject.enemy_id].actions
        # レート10/1の中で使用可能な行動だけを拾って配列に追加
        skill = $data_skills[act.skill_id]
        act_list_1 << act if act.rating == moo_enemy_clever_rate_1 and moo_enemy_clever_valid?(skill) # レート10
        act_list_2 << act if act.rating == moo_enemy_clever_rate_2 and moo_enemy_clever_valid?(skill) # レート1
      end
    end
    # 優先度をランダムにしている場合
    if moo_enemy_clever_include($data_enemies[@subject.enemy_id].note) and act_list_1.size > 0
      # 順番をランダム化
      act_rnd = act_list_1.sort_by{rand}
      act_list_1 = act_rnd
    end
    # レート10の行動がある場合
    if act_list_1.size > 0
      # エネミーのメモを取得
      # 使用可能なレート10の行動の数だけループ
      for item in act_list_1
        # スキルの対象によるフラグ
        tg = 0
        tg = 2 if $data_skills[item.skill_id].scope == 1    # 対象がアクター
        tg = 2 if $data_skills[item.skill_id].scope == 2    # 対象がアクター
        tg = 2 if $data_skills[item.skill_id].scope == 3    # 対象がアクター
        tg = 2 if $data_skills[item.skill_id].scope == 4    # 対象がアクター
        tg = 2 if $data_skills[item.skill_id].scope == 5    # 対象がアクター
        tg = 2 if $data_skills[item.skill_id].scope == 6    # 対象がアクター
        tg = 1 if $data_skills[item.skill_id].scope == 7    # 対象がエネミー
        tg = 1 if $data_skills[item.skill_id].scope == 8    # 対象がエネミー
        tg = 1 if $data_skills[item.skill_id].scope == 9    # 対象がエネミー
        tg = 1 if $data_skills[item.skill_id].scope == 10   # 対象がエネミー
        # スキルに対してのターゲット取得
        en_list = []
        en_list = moo_enemy_clever_troop_check(item, act_list_2)   if tg == 1
        en_list = moo_enemy_clever_members_check(item, act_list_2) if tg == 2
        # ターゲットがいた場合
        if en_list.size != 0
          # ターゲットが複数いた場合はランダムにする
          en_list = en_list.sort_by{rand}
          # スキルとターゲットを格納
          return_array[0] = item.skill_id
          return_array[1] = en_list
          break
        end
      end
    end
    # 返す
    return return_array
  end
  #--------------------------------------------------------------------------
  # ○ エネミーがスキルを使用可能かチェック
  #--------------------------------------------------------------------------
  def moo_enemy_clever_valid?(skill)
    moo_enemy_clever_movable? and                         # 動けるか？
    moo_enemy_clever_cost?(skill) and                     # MP/TPが足りているか？
    !moo_enemy_clever_skill_sealed?(skill.id) and         # スキル封印は？
    !moo_enemy_clever_skill_type_sealed?(skill.stype_id)  # スキルタイプ封印は？
  end
  #--------------------------------------------------------------------------
  # ○ 行動可能かチェック
  #--------------------------------------------------------------------------
  def moo_enemy_clever_movable?
    @subject.movable?
  end
  #--------------------------------------------------------------------------
  # ○ スキルのコストが足りているかチェック(MPとTP)
  #--------------------------------------------------------------------------
  def moo_enemy_clever_cost?(skill)
    s_mcr = @subject.mcr
    s_mpc = (skill.mp_cost * s_mcr).to_i
    s_tpc = skill.tp_cost
    @subject.tp >= s_tpc && @subject.mp >= s_mpc
  end
  #--------------------------------------------------------------------------
  # ○ 現在のステートをオブジェクトの配列で取得
  #--------------------------------------------------------------------------
  def moo_enemy_clever_states
    # ファイ列変数初期化
    st = []
    # 掛かっているステートを列挙
    for i in @subject.states
      st << i.id
    end
    st.collect {|id| $data_states[id] }
  end
  #--------------------------------------------------------------------------
  # ○ 特徴を保持する全オブジェクトの配列取得
  #--------------------------------------------------------------------------
  def moo_enemy_clever_feature_objects
    moo_enemy_clever_states
  end
  #--------------------------------------------------------------------------
  # ○ 全ての特徴オブジェクトの配列取得
  #--------------------------------------------------------------------------
  def moo_enemy_clever_all_features
    moo_enemy_clever_feature_objects.inject([]) {|r, obj| r + obj.features }
  end
  #--------------------------------------------------------------------------
  # ○ 特徴オブジェクトの配列取得（特徴コードを限定）
  #--------------------------------------------------------------------------
  def moo_enemy_clever_features(code)
    moo_enemy_clever_all_features.select {|ft| ft.code == code }
  end
  #--------------------------------------------------------------------------
  # ○ 特徴の集合和計算
  #--------------------------------------------------------------------------
  def moo_enemy_clever_features_set(code)
    moo_enemy_clever_features(code).inject([]) {|r, ft| r |= [ft.data_id] }
  end
  #--------------------------------------------------------------------------
  # ○ スキルタイプ封印の判定
  #--------------------------------------------------------------------------
  def moo_enemy_clever_skill_type_sealed?(stype_id)
    moo_enemy_clever_features_set(FEATURE_STYPE_SEAL).include?(stype_id)
  end
  #--------------------------------------------------------------------------
  # ○ スキル封印の判定
  #--------------------------------------------------------------------------
  def moo_enemy_clever_skill_sealed?(skill_id)
    moo_enemy_clever_features_set(FEATURE_SKILL_SEAL).include?(skill_id)
  end
  #--------------------------------------------------------------------------
  # ○ スキルを使う条件に当てはまるかの判定(エネミー→エネミー)
  #     item           : レート10のスキル
  #     no_action_list : 使用しない条件に当てはまるスキル(レート1)
  #--------------------------------------------------------------------------
  def moo_enemy_clever_troop_check(item, no_action_list)
    # 変数初期化
    target_en = []
    # パラメータ格納
    p1 = item.condition_param1
    p2 = item.condition_param2
    # 敵グループのエネミー分ループ
    for en in $game_troop.members
      # アクションの条件によって分岐
      case item.condition_type
      when 2    # HPが条件
        if moo_enemy_clever_conditions_met_hp_1?(en, p1, p2)
          # 除外リスト
          if no_action_list.size > 0
            for no_act in no_action_list
              pp1 = no_act.condition_param1
              pp2 = no_act.condition_param2
              # 除外リストに当てはまらない場合のみ対象エネミーを追加
              target_en << en.index if !moo_enemy_clever_conditions_met_hp_1?(en, pp1, pp2)
            end
          else
            target_en << en.index
          end
        end
      when 3    # MPが条件
        if moo_enemy_clever_conditions_met_mp_1?(en, p1, p2)
          # 除外リスト
          if no_action_list.size > 0
            for no_act in no_action_list
              pp1 = no_act.condition_param1
              pp2 = no_act.condition_param2
              # 除外リストに当てはまらない場合のみ対象エネミーを追加
              target_en << en.index if !moo_enemy_clever_conditions_met_mp_1?(en, pp1, pp2)
            end
          else
            # 対象エネミーを追加
            target_en << en.index
          end
        end
      when 4    # ステートが条件
        if moo_enemy_clever_conditions_met_state_1?(en, p1, p2)
          # 除外リスト
          if no_action_list.size > 0
            for no_act in no_action_list
              pp1 = no_act.condition_param1
              pp2 = no_act.condition_param2
              # 除外リストに当てはまらない場合のみ対象エネミーを追加
              target_en << en.index if !moo_enemy_clever_conditions_met_state_1?(en, pp1, pp2)
            end
          else
            # 対象エネミーを追加
            target_en << en.index
          end
        end
      end
    end
    # 返す
    return target_en
  end
  #--------------------------------------------------------------------------
  # ○ メモ欄判別
  #     note : 文字列
  #--------------------------------------------------------------------------
  def moo_enemy_clever_include(note)
    note.each_line{|line|
      if line.include?(MOO_ENEMY_CLEVER::ENEMY_ACTION_RANDOM)
        return true
      end
    }
    return false
  end
  #--------------------------------------------------------------------------
  # ○ 行動条件合致判定 [HP]
  #--------------------------------------------------------------------------
  def moo_enemy_clever_conditions_met_hp_1?(enemy, param1, param2)
    val = enemy.hp.to_f / enemy.mhp
    val >= param1 && val <= param2
  end
  #--------------------------------------------------------------------------
  # ○ 行動条件合致判定 [MP]
  #--------------------------------------------------------------------------
  def moo_enemy_clever_conditions_met_mp_1?(enemy, param1, param2)
    val = enemy.mp.to_f / enemy.mmp
    val >= param1 && val <= param2
  end
  #--------------------------------------------------------------------------
  # ○ 行動条件合致判定 [ステート]
  #--------------------------------------------------------------------------
  def moo_enemy_clever_conditions_met_state_1?(enemy, param1, param2)
    # ステートに掛かっていない場合はfalseを返す
    return false if enemy.states.size == 0
    # 配列変数初期化
    st = []
    # 掛かっているステートを列挙
    for state in enemy.states
      st << state.id
    end
    # スキル発動条件のステートに掛かっているか
    st.include?(param1)
  end
  #--------------------------------------------------------------------------
  # ○ スキルを使う条件に当てはまるかの判定(エネミー→アクター)
  #     item           : 強制行動(レート10)のスキル
  #     no_action_list : 使用しない条件に当てはまるスキル(レート1)
  #--------------------------------------------------------------------------
  def moo_enemy_clever_members_check(item, no_action_list)
    # 変数初期化
    target_ac = []
    # パラメータ格納
    p1 = item.condition_param1
    p2 = item.condition_param2
    # 敵グループのエネミー分ループ
    for ac in $game_party.battle_members
      # アクションの条件によって分岐
      case item.condition_type
      when 2    # 強制行動の条件がHP
        if moo_enemy_clever_conditions_met_hp_2?(ac, p1, p2)
          # 除外リスト
          if no_action_list.size > 0
            for no_act in no_action_list
              pp1 = no_act.condition_param1
              pp2 = no_act.condition_param2
              pp3 = no_act.condition_type
              # 除外リストに当てはまらない場合のみ対象アクターを追加
              target_ac << ac.index if moo_enemy_clever_actor_condition?(ac, pp1, pp2, pp3) #if flg == 0
            end
          else
            target_ac << ac.index
          end
        end
      when 3    # 強制行動の条件がMP
        if moo_enemy_clever_conditions_met_mp_2?(ac, p1, p2)
          # 除外リスト
          if no_action_list.size > 0
            for no_act in no_action_list
              pp1 = no_act.condition_param1
              pp2 = no_act.condition_param2
              pp3 = no_act.condition_type
              # 除外リストに当てはまらない場合のみ対象アクターを追加
              target_ac << ac.index if moo_enemy_clever_actor_condition?(ac, pp1, pp2, pp3) #if flg == 0
            end
          else
            target_ac << ac.index
          end
        end
      when 4    # 強制行動の条件がステート
        if moo_enemy_clever_conditions_met_state_2?(ac, p1, p2)
          # 除外リスト
          if no_action_list.size > 0
            for no_act in no_action_list
              pp1 = no_act.condition_param1
              pp2 = no_act.condition_param2
              pp3 = no_act.condition_type
              # 除外リストに当てはまらない場合のみ対象アクターを追加
              target_ac << ac.index if moo_enemy_clever_actor_condition?(ac, pp1, pp2, pp3) #if flg == 0
            end
          else
            target_ac << ac.index
          end
        end
      end
    end
    # 返す
    return target_ac
  end
  #--------------------------------------------------------------------------
  # ○ 行動条件合致判定 [HP]
  #--------------------------------------------------------------------------
  def moo_enemy_clever_conditions_met_hp_2?(actor, param1, param2)
    val = actor.hp.to_f / actor.mhp
    val >= param1 && val <= param2
  end
  #--------------------------------------------------------------------------
  # ○ 行動条件合致判定 [MP]
  #--------------------------------------------------------------------------
  def moo_enemy_clever_conditions_met_mp_2?(actor, param1, param2)
    val = actor.mp.to_f / actor.mmp
    val >= param1 && val <= param2
  end
  #--------------------------------------------------------------------------
  # ○ 行動条件合致判定 [ステート]
  #--------------------------------------------------------------------------
  def moo_enemy_clever_conditions_met_state_2?(actor, param1, param2)
    # ステートに掛かっていない場合はfalseを返す
    return false if actor.states.size == 0
    # 配列変数初期化
    st = []
    # 掛かっているステートを列挙
    for state in actor.states
      st << state.id
    end
    # スキル発動条件のステートに掛かっているか
    st.include?(param1)
  end
  #--------------------------------------------------------------------------
  # ○ 除外アクター判断
  #     actor  : アクター情報
  #     param1 : スキル使用条件1
  #     param2 : スキル使用条件2
  #     param3 : スキル使用条件項目(2=HP/3=MP/4=ステート)
  #--------------------------------------------------------------------------
  def moo_enemy_clever_actor_condition?(actor, param1, param2, param3)
    flg = true
    flg = false if moo_enemy_clever_conditions_met_hp_2?(actor, param1, param2) and param3 == 2
    flg = false if moo_enemy_clever_conditions_met_mp_2?(actor, param1, param2) and param3 == 3
    flg = false if moo_enemy_clever_conditions_met_state_2?(actor, param1, param2) and param3 == 4
    return flg
  end
  #--------------------------------------------------------------------------
  # ◎ 戦闘行動の実行
  #--------------------------------------------------------------------------
  alias moo_enemy_clever_execute_action execute_action
  def execute_action
    if MOO_ENEMY_CLEVER::USE and @subject.class == Game_Enemy
      # 本スクリプトを使う設定になっておりエネミーの行動の場合
      @subject.sprite_effect_type = :whiten
      moo_enemy_clever_use_item
      @log_window.wait_and_clear
    else
      # それ以外は従来通りの処理
      moo_enemy_clever_execute_action
    end
  end
  #--------------------------------------------------------------------------
  # ○ パーティメンバーへのターゲットをランダムに決定
  #--------------------------------------------------------------------------
  def moo_enemy_clever_random_actors(count, target_arr)
    # 変数初期化
    actor = []
    #　ターゲットが存在する場合
    if target_arr.size > 0
      # 行動回数分ループ
      for i in 1..count
        # ターゲットをランダム設定
        tg = target_arr.sort_by{rand}
        actor << $game_party.members[tg[0]]
      end
    end
    return actor
  end
  #--------------------------------------------------------------------------
  # ○ スキル／アイテムの使用(元をコピーして作り替え)
  #--------------------------------------------------------------------------
  def moo_enemy_clever_use_item
    # 変数初期化
    skill_target = [0, -1]
    # エネミーの行動の場合
    if @subject.class == Game_Enemy
      skill_target = moo_enemy_clever_change
    end
    # エネミーの行動を指定
    item = @subject.current_action.item  if skill_target[0] == 0
    item = $data_skills[skill_target[0]] if skill_target[0] != 0
    # 以下3行は通常処理
    @log_window.display_use_item(@subject, item)
    @subject.use_item(item)
    refresh_status
    # まずはデフォルトのターゲット設定
    targets = @subject.current_action.make_targets.compact
    # 賢い行動対象の場合
    if skill_target[0] != 0 and skill_target[1] != -1
      # ターゲット設定(強制行動のみ)
      case $data_skills[skill_target[0]].scope
      when 0
        # なし
        targets = []
      when 1
        # 敵単体の場合は敵(アクター)ランダム1体
        tg = skill_target[1][0]
        targets = [$game_party.members[tg]]
      when 2
        # 敵全体の場合は敵(アクター)全体
        targets = $game_party.members
      when 3
        # 敵ランダム1体の場合は敵(アクター)
        targets = moo_enemy_clever_random_actors(1, skill_target[1])
      when 4
        # 敵ランダム2体の場合は敵(アクター)
        targets = moo_enemy_clever_random_actors(2, skill_target[1])
      when 5
        # 敵ランダム3体の場合は敵(アクター)
        targets = moo_enemy_clever_random_actors(3, skill_target[1])
      when 6
        # 敵ランダム4体の場合は敵(アクター)
        targets = moo_enemy_clever_random_actors(4, skill_target[1])
      when 7, 9
        # 味方1体の場合は味方(エネミー)単体
        targets = [$game_troop.members[skill_target[1][0]]]
      when 8, 10
        # 味方全体の場合は味方(エネミー)全体
        targets = $game_troop.members
      when 11
        # 使用者の場合は使用者
        targets = [@subject]
      end
    end
    # 以下通常処理
    show_animation(targets, item.animation_id)
    targets.each {|target| item.repeats.times { invoke_item(target, item) } }
  end
end